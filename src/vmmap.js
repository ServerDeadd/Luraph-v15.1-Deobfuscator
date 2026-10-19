'use strict';

const { execFileSync } = require('child_process');
const { luauAst } = require('./harness');
const fs = require('fs');

const AST_TIMEOUT_MS = 120 * 1000; // 1.7 MB scripts parse in seconds; guards a hung/broken binary

function loadAst(filePath) {
  let exe;
  try {
    exe = luauAst();
  } catch (e) {
    throw new SyntaxError(e.message);
  }
  let stdout;
  try {
    stdout = execFileSync(exe, [filePath], { encoding: 'latin1', maxBuffer: 256 * 1024 * 1024, timeout: AST_TIMEOUT_MS });
  } catch (e) {
    if (e.code === 'ENOENT' || /spawnSync.*ENOENT/.test(e.message || '')) {
      throw new SyntaxError(e.message.replace(/spawnSync .* ENOENT/, 'luau-ast binary is missing or not executable'));
    }
    if (e.code === 'ETIMEDOUT' || (e.message || '').includes('ETIMEDOUT')) {
      throw new SyntaxError(`luau-ast timed out after ${AST_TIMEOUT_MS / 1000}s (binary hung or machine overloaded)`);
    }
    const msg = e.stderr || e.message || '';
    throw new SyntaxError('not valid Luau: ' + msg.trim().split('\n').slice(0, 3).join(' | '));
  }
  return JSON.parse(stdout).root;
}

function loc(node) {
  const [a, b] = node.location.split(' - ');
  const [l1, c1] = a.split(',').map(Number);
  const [l2, c2] = b.split(',').map(Number);
  return [l1, c1, l2, c2];
}

function textOf(lines, node) {
  const [l1, c1, l2, c2] = loc(node);
  if (l1 === l2) return lines[l1].slice(c1, c2);
  return [lines[l1].slice(c1), ...lines.slice(l1 + 1, l2), lines[l2].slice(0, c2)].join('\n');
}

function walkAst(node, fn) {
  if (!node || typeof node !== 'object') return;
  if (Array.isArray(node)) { node.forEach(v => walkAst(v, fn)); return; }
  fn(node);
  Object.values(node).forEach(v => walkAst(v, fn));
}

function localName(expr) {
  if (expr && expr.type === 'AstExprLocal') return expr.local.name;
  return null;
}

const OPS = {
  CompareLt: (a, b) => a < b,
  CompareLe: (a, b) => a <= b,
  CompareGt: (a, b) => a > b,
  CompareGe: (a, b) => a >= b,
  CompareEq: (a, b) => a === b,
  CompareNe: (a, b) => a !== b,
};
const FLIP = {
  CompareLt: 'CompareGt', CompareLe: 'CompareGe',
  CompareGt: 'CompareLt', CompareGe: 'CompareLe',
  CompareEq: 'CompareEq', CompareNe: 'CompareNe',
};

function evalCond(cond, varName, value) {
  if (!cond || cond.type !== 'AstExprBinary' || !OPS[cond.op]) return null;
  const l = cond.left, r = cond.right;
  const op = cond.op;
  if (localName(l) === varName && r.type === 'AstExprConstantNumber')
    return OPS[op](value, r.value);
  if (localName(r) === varName && l.type === 'AstExprConstantNumber')
    return OPS[FLIP[op]](value, l.value);
  return null;
}

function _unwrap(e) {
  while (e && e.type === 'AstExprGroup') e = e.expr;
  return e;
}

function findDispatchers(root) {
  const found = [];
  walkAst(root, n => {
    let body = null;
    if (n.type === 'AstStatWhile') {
      const cond = n.condition;
      if (!cond || cond.type !== 'AstExprConstantBool' || !cond.value) return;
      body = n.body.body;
    } else if (n.type === 'AstStatRepeat') {
      // repeat ... until false: Luraph v15 dispatch form (some builds)
      const cond = n.condition;
      if (!cond || cond.type !== 'AstExprConstantBool' || cond.value) return;
      body = n.body ? n.body.body : null;
    }
    if (!body) return;
    if (body.length < 2) return;
    const st = body[0];
    if (!['AstStatLocal', 'AstStatAssign'].includes(st.type)) return;
    if ((st.values || []).length !== 1) return;
    let opname;
    if (st.type === 'AstStatLocal') {
      opname = st.vars[0].name;
    } else {
      opname = localName(st.vars[0]);
      if (!opname) return;
    }
    const v = _unwrap(st.values ? st.values[0] : null);
    if (!v || v.type !== 'AstExprIndexExpr') return;
    const arr = localName(_unwrap(v.expr)), pc = localName(_unwrap(v.index));
    if (!arr || !pc) return;
    if (body[1].type === 'AstStatIf') {
      found.push({ node: n, op: opname, arr, pc, tree: body[1], rest: body.slice(2) });
    } else if (body.length >= 3 && ['AstStatLocal', 'AstStatAssign'].includes(body[1].type) && body[2].type === 'AstStatIf') {
      const st1 = body[1];
      if ((st1.values || []).length === 1) {
        const v1 = _unwrap(st1.values[0]);
        if (v1 && v1.type === 'AstExprBinary' && OPS[v1.op]) {
          found.push({ node: n, op: opname, arr, pc, tree: n.body, rest: body.slice(3) });
        }
      }
    }
  });
  return found;
}

function resolveOp(tree, varName, value) {
  let node = tree;
  const benv = {};
  while (true) {
    if (!node) return null;
    if (node.type === 'AstStatBlock') {
      const b = node.body || [];
      if (b.length >= 1 && b[0].type === 'AstStatIf' &&
          evalCond(b[0].condition, varName, value) !== null) {
        node = b[0];
        continue;
      }
      let matched = false;
      for (let i = 0; i < b.length - 1; i++) {
        const st = b[i], nxt = b[i + 1];
        if (['AstStatLocal', 'AstStatAssign'].includes(st.type) && (st.values || []).length === 1 && nxt.type === 'AstStatIf') {
          const v = _unwrap(st.values[0]);
          const r = evalCond(v, varName, value);
          if (r !== null) {
            const bvar = st.type === 'AstStatLocal' ? st.vars[0].name : localName(st.vars[0]);
            if (bvar && localName(_unwrap(nxt.condition)) === bvar) {
              benv[bvar] = r;
              node = nxt;
              matched = true;
              break;
            }
          }
        }
      }
      if (matched) continue;
      return node;
    }
    if (node.type === 'AstStatIf') {
      let r = evalCond(node.condition, varName, value);
      if (r === null) {
        const cname = localName(_unwrap(node.condition));
        if (cname && cname in benv) r = benv[cname];
      }
      if (r === null) return node;
      node = r ? node.thenbody : (node.elsebody || null);
      continue;
    }
    return node;
  }
}

function _makerParams(maker) {
  const args = maker.args || [];
  const visible = {};
  args.forEach((a, i) => { visible[a.name] = i; });
  const counts = {}, kcounts = {}, used = new Set();

  function visit(n) {
    if (!n || typeof n !== 'object') return;
    if (Array.isArray(n)) { n.forEach(visit); return; }
    if (n.type === 'AstExprLocal') used.add(n.local.location);

    if (n.type === 'AstExprIndexExpr' && n.expr?.type === 'AstExprLocal' &&
        n.index?.type === 'AstExprIndexExpr' && n.index?.expr?.type === 'AstExprLocal' &&
        n.index.expr.local.location === n.expr.local.location) {
      const k = n.expr.local.location;
      counts[k] = (counts[k] || 0) + 1;
    }

    if (n.type === 'AstExprIndexExpr' && n.expr?.type === 'AstExprLocal' &&
        n.index?.type === 'AstExprConstantNumber') {
      const k = n.expr.local.location;
      kcounts[k] = (kcounts[k] || 0) + 1;
    }
    Object.values(n).forEach(visit);
  }
  visit(maker.body);

  const cands = Object.values(visible).filter(i => i > 0);
  let pi = cands.length
    ? cands.reduce((best, i) => {
        const bc = counts[args[best]?.location] || 0;
        const ic = counts[args[i]?.location] || 0;
        return ic > bc ? i : (ic === bc && i === 1 ? i : best);
      }, cands[0])
    : 1;
  if (!counts[args[pi]?.location]) {
    pi = 1;
    const kc = cands.filter(i => kcounts[args[i]?.location]);
    if (kc.length) pi = kc.reduce((best, i) => (kcounts[args[i].location] > kcounts[args[best].location] ? i : best), kc[0]);
  }
  const others = Object.values(visible).filter(i => i !== 0 && i !== pi && used.has(args[i]?.location)).sort();
  const ui = others.length ? others[0] : pi + 1;
  return [pi, ui];
}

function _vmStackIdx(stack) {
  if (stack.length >= 2) {
    const f1 = stack[stack.length - 1];
    const f2 = stack[stack.length - 2];
    if (f1.vararg && (!f1.args || f1.args.length === 0) &&
        f2.vararg && (!f2.args || f2.args.length === 0)) {
      return stack.length - 2;
    }
  }
  return stack.length - 1;
}

function _curried3Of(stack, vmIdx) {
  if (vmIdx < 2) return null;
  const f3 = stack[vmIdx - 2];
  const f2 = stack[vmIdx - 1];
  const f1 = stack[vmIdx];
  const f3b = f3.body && f3.body.body;
  const retStmt = f3b && f3b[f3b.length - 1];
  if ((f3.args || []).length < 5 || !retStmt || retStmt.type !== 'AstStatReturn' || !retStmt.list || retStmt.list.length !== 1) {
    return null;
  }
  if (retStmt.list[0] === f2) {
    return { f3, f2, f1, retStmt, kind: 'anon' };
  }
  const uName = localName(retStmt.list[0]);
  const f2b = f2.body && f2.body.body;
  const f2Ret = f2b && f2b[f2b.length - 1];
  const zName = f2Ret && f2Ret.type === 'AstStatReturn' && f2Ret.list && f2Ret.list.length === 1 ? localName(f2Ret.list[0]) : null;
  if (uName && zName) {
    return { f3, f2, f1, retStmt, f2Ret, uName, zName, kind: 'named' };
  }
  return null;
}

function closureEntries(root) {
  const dispNodes = findDispatchers(root).map(d => d.node);
  const seen = new Map();

  function walk(n, stack) {
    if (!n || typeof n !== 'object') return;
    if (Array.isArray(n)) { n.forEach(v => walk(v, stack)); return; }
    if (n.type === 'AstExprFunction') stack = [...stack, n];
    if (dispNodes.includes(n)) {
      const vmIdx = _vmStackIdx(stack);
      const inner = stack[vmIdx] && stack[vmIdx].vararg && (!stack[vmIdx].args || stack[vmIdx].args.length === 0)
        ? stack[vmIdx]
        : [...stack].reverse().find(f => f.vararg && (!f.args || f.args.length === 0));
      const outer = [...stack].reverse().find(f => f.args && f.args.length >= 2);
      if (inner && outer) {
        const firstStmt = inner.body.body[0];
        if (firstStmt) {
          const [l1, c1] = loc(firstStmt);
          const [pi] = _makerParams(outer);
          let name = outer.args[pi].name;
          if (_curried3Of(stack, vmIdx)) {
            name = '__pv';
          }
          seen.set(`${l1},${c1}`, { l: l1, c: c1, name });
        }
      }
    }
    Object.values(n).forEach(v => walk(v, stack));
  }
  walk(root, []);
  return [...seen.values()].map(({ l, c, name }) => [l, c, name]);
}

function _declsIn(fn) {
  const keys = {};
  function visit(n) {
    if (!n || typeof n !== 'object') return;
    if (Array.isArray(n)) { n.forEach(visit); return; }
    const t = n.type;
    if (t === 'AstExprFunction' && n !== fn) return;
    if (t === 'AstStatLocal') (n.vars || []).forEach(v => { keys[v.location] = v.name; });
    else if (t === 'AstStatLocalFunction') keys[n.name.location] = n.name.name;
    else if (t === 'AstStatFor') keys[n.var.location] = n.var.name;
    else if (t === 'AstStatForIn') (n.vars || []).forEach(v => { keys[v.location] = v.name; });
    Object.values(n).forEach(visit);
  }
  (fn.args || []).forEach(a => { keys[a.location] = a.name; });
  visit(fn.body);
  return keys;
}

function _locStart(key) {
  const [l, c] = String(key).split(' - ')[0].split(',').map(Number);
  return [l, c];
}

function _captures(info) {
  const makerDecls = _declsIn(info.maker);
  // v14.9-style builds nest the maker inside a helper method; the VM closure
  // reads the helper's parameters/locals (e.g. its state table) which are NOT
  // the maker's own decls. The capture code runs inside the maker where those
  // names stay lexically visible, so record them too.
  const chainDecls = {};
  if (info.chain && info.chain.length) {
    const mk = _locStart(info.maker.location);
    info.chain.forEach(fn => {
      Object.entries(_declsIn(fn)).forEach(([k, nm]) => {
        const [l1, c1] = _locStart(k);
        if (l1 < mk[0] || (l1 === mk[0] && c1 <= mk[1])) (chainDecls[nm] = chainDecls[nm] || []).push(k);
      });
    });
  }

  const usedMaker = {};   // decl key -> name, refs resolving into the maker
  const usedChain = {};   // refs resolving into an enclosing scope
  function visit(n) {
    if (!n || typeof n !== 'object') return;
    if (Array.isArray(n)) { n.forEach(visit); return; }
    if (n.type === 'AstExprLocal') {
      const k = n.local.location;
      const nm = n.local.name;
      if (makerDecls[k]) usedMaker[k] = nm;
      else if (chainDecls[nm] && chainDecls[nm].includes(k)) usedChain[k] = nm;
    }
    Object.values(n).forEach(visit);
  }
  visit(info.vm);

  function single(members, declsByName) {
    // names whose refs hit exactly one decl, with exactly one decl of that
    // name (by-name capture `__PA[p].nm=nm` must be unambiguous)
    const refKeys = {};
    Object.entries(members).forEach(([k, nm]) => { (refKeys[nm] = refKeys[nm] || []).push(k); });
    return new Set(Object.keys(refKeys).filter(nm => refKeys[nm].length === 1 && (declsByName[nm] || []).length === 1));
  }

  const makerByName = {};
  Object.entries(makerDecls).forEach(([k, nm]) => { (makerByName[nm] = makerByName[nm] || []).push(k); });
  const caps = single(usedMaker, makerByName);
  single(usedChain, chainDecls).forEach(nm => {
    if (!(nm in makerDecls)) caps.add(nm);   // a maker decl would shadow it at the hook
  });
  return [...caps].sort();
}

function _freeNames(fn) {
  // names used inside `fn` whose declaration lives OUTSIDE it (free upvalues)
  const own = new Set(Object.keys(_declsIn(fn)));
  const names = new Set();
  function visit(n) {
    if (!n || typeof n !== 'object') return;
    if (Array.isArray(n)) { n.forEach(visit); return; }
    if (n.type === 'AstExprLocal' && n.local && !own.has(n.local.location)) {
      names.add(n.local.name);
    }
    Object.values(n).forEach(visit);
  }
  visit(fn.body);
  (fn.args || []).forEach(a => own.add(a.location));
  return [...names].sort();
}

function makerInfo(root) {
  const dispNodes = findDispatchers(root).map(d => d.node);
  const out = new Map();

  function walk(n, stack, stmts) {
    if (!n || typeof n !== 'object') return;
    if (Array.isArray(n)) { n.forEach(v => walk(v, stack, stmts)); return; }
    const t = n.type;
    if (t === 'AstExprFunction') stack = [...stack, n];
    if (t && t.startsWith('AstStat')) stmts = [...stmts, [n, stack.length]];
    if (dispNodes.includes(n)) {

      let oi = -1;
      for (let i = stack.length - 1; i >= 0; i--) {
        if ((stack[i].args || []).length >= 2) { oi = i; break; }
      }
      let registered = false;
      if (oi >= 0 && oi + 1 < stack.length) {
        const clo = stack[oi + 1];
        const makerStmts = stmts.filter(([, d]) => d === oi + 1).map(([s]) => s);
        const st = makerStmts[makerStmts.length - 1];
        if (st && st.type === 'AstStatAssign') {
          (st.vars || []).forEach((v, idx) => {
            const e = (st.values || [])[idx];
            if (e === clo && localName(v)) {
              const [, , l2, c2] = loc(st);
              const key = `${l2},${c2}`;
              if (!out.has(key)) {
                const [pi, ui] = _makerParams(stack[oi]);
                out.set(key, {
                  at: [l2, c2], var: localName(v),
                  proto: stack[oi].args[pi].name,
                  proto_index: pi, upvals_index: ui,
                  pf_key: stack[oi].args[pi].name,
                  maker: stack[oi], vm: clo, stmt: st,
                  chain: stack.slice(0, oi),
                });
                registered = true;
              }
            }
          });
        }
      }
      // v3 fallback (dispatch-local proto): some Luraph v15 builds decode the
      // proto INSIDE the dispatcher itself -- `C=function(...) local
      // P,W,o,Y,N=A[113](x),(1); repeat local y=(V[W]) ... end` -- so the
      // sephal-era maker-assign hook has no match. Hook AFTER the
      // dispatcher's first local instead: P is the live proto, and the free
      // upvalues (A, V, x, ...) are the VM state worth capturing.
      if (!registered) {
        const vmIdx = _vmStackIdx(stack);
        const clo = stack[vmIdx];
        if (clo && clo.vararg && (!clo.args || clo.args.length === 0)) {
          const bbody = clo.body && clo.body.body;
          if (bbody && bbody.length >= 2 && bbody[0].type === 'AstStatLocal' && bbody[0].vars && bbody[0].vars[0]) {
            let targetIdx = 0;
            let pv = bbody[0].vars[0].name;
            const shadowed = new Set();
            for (let si = 0; si < bbody.length - 1; si++) {
              const st = bbody[si];
              if (st.type !== 'AstStatLocal') break;
              const vals = st.values || [];
              let foundCall = false;
              for (let vi = 0; vi < vals.length; vi++) {
                if (vals[vi] && vals[vi].type === 'AstExprCall' && st.vars && st.vars[vi]) {
                  targetIdx = si;
                  pv = st.vars[vi].name;
                  foundCall = true;
                  break;
                }
              }
              if (foundCall) break;
            }
            for (let si = 0; si <= targetIdx; si++) {
              (bbody[si].vars || []).forEach(v2 => shadowed.add(v2.name));
            }
            const first = bbody[targetIdx];
            const second = bbody[targetIdx + 1];
            const [l2, c2] = loc(second);   // insert at START of statement after targetIdx
            const key = `v3:${l2},${c2}`;
            if (!out.has(key)) {
              const caps = _freeNames(clo).filter(nm2 => !shadowed.has(nm2));
              const curried3 = _curried3Of(stack, vmIdx);
              out.set(key, {
                at: [l2, c2], var: pv, proto: pv, mode: 'dispatch_local',
                pf_key: JSON.stringify(`disp@${l2},${c2}`),
                maker: vmIdx >= 1 ? stack[vmIdx - 1] : null,
                vm: clo, stmt: first, captures: caps, curried3,
                chain: vmIdx >= 1 ? stack.slice(0, vmIdx - 1) : [],
              });
            }
          }
        }
      }
    }
    Object.values(n).forEach(v => walk(v, stack, stmts));
  }
  walk(root, [], []);
  const results = [...out.values()];
  results.forEach(info => {
    if (info.mode !== 'dispatch_local') info.captures = _captures(info);
  });
  return results;
}

function patchEntries(source, filePath, chunkTag) {
  const root = loadAst(filePath);
  const lines = source.split('\n');
  const tag = chunkTag;
  const edits = [];

  for (const [l1, c1, name] of closureEntries(root)) {
    const k = `(${name} or __PID)`;
    edits.push([l1, c1,
      `if not __PID[${k}] then __PID.n=__PID.n+1;__PID[${k}]=__PID.n;end;` +
      `__ENT.n=__ENT.n+1;__ENT[__ENT.n%64]=__PID[${k}];__PLAST[__PID[${k}]]=__ENT.n;` +
      `if __SKIPP[__PID[${k}]] then return end;`
    ]);
  }

  for (const info of makerInfo(root)) {
    const [l2, c2] = info.at;
    if (info.curried3) {
      const { f3, f2, retStmt, f2Ret, uName, zName, kind } = info.curried3;
      const f3b = f3.body.body;
      const [f3_l0, f3_c0] = loc(f3b[0]);
      const f3Params = [...new Set((f3.args || []).map(a => a.name).filter(nm => nm && nm !== '...'))];
      const f3Cap = f3Params.map(nm => `${nm}=${nm}`).join(',');
      const headCode = `local __pv={${f3Cap}};if __PA and __PA.n<8192 then __PA.n=__PA.n+1;__PA[__pv]={__seq=__PA.n,__maker="${tag}@${l2},${c2}",${f3Cap}} end;`;
      edits.push([f3_l0, f3_c0, headCode]);
      if (kind === 'named') {
        const [r1_l, r1_c] = loc(retStmt);
        const [r2_l, r2_c] = loc(f2Ret);
        edits.push([r1_l, r1_c, `__PF[${uName}]=__pv;__PK[__pv]=${uName};`]);
        edits.push([r2_l, r2_c, `__PF[${zName}]=__pv;__PK[__pv]=${zName};`]);
      } else {
        const [fn_l1, fn_c1, fn_l2, fn_c2] = loc(f2);
        edits.push([fn_l1, fn_c1, `(function(__mk)__PF[__mk]=__pv;__PK[__pv]=__mk;return __mk end)(`]);
        edits.push([fn_l2, fn_c2, `)`]);
      }
      continue;
    }
    const pv = info.proto;
    const v = info.var;
    const pfKey = info.pf_key || pv;
    let code = ` __PF[${v}]=${pfKey} `;
    const cap = info.captures.map(nm => `__PA[${pv}].${nm}=${nm};`).join('');
    // __PA.n cap: dispatch-local protos are keyed by a FRESH table per call
    // (A[49](x)) -- without a cap every call re-registers 14 captures and
    // __PA grows unbounded (observed: run crawls to a halt). Standard makers
    // register once per proto (`not __PA[pv]` guard), but a script can hold
    // hundreds of distinct closures in its constant pool -- all of them need
    // a capture, so only dispatch-local mode stays at the tight limit.
    const palimit = info.mode === 'dispatch_local' ? 64 : 8192;
    code += `if __PA and __PA.n<${palimit} and ${pv}~=nil and not __PA[${pv}] then __PA[${pv}]={};__PA.n=__PA.n+1;__PA[${pv}].__seq=__PA.n;` +
            `__PA[${pv}].__maker="${tag}@${l2},${c2}";__PK[${pfKey}]=${v};${cap} end `;
    if (info.mode === 'dispatch_local') code = code + ' ';   // standalone statement at stmt-2 start
    edits.push([l2, c2, code]);
  }

  edits.sort((a, b) => b[0] !== a[0] ? b[0] - a[0] : b[1] - a[1]);
  for (const [l, c, code] of edits) {
    lines[l] = lines[l].slice(0, c) + code + lines[l].slice(c);
  }
  return lines.join('\n');
}

function patchSpin(src) {
  const INJ = '__SPIN.n=__SPIN.n+1;if __SPIN.n>=__SPIN.step then __SPIN.f()end;';
  // classic:  while true do X=Y[Z];            (Luraph v15 dispatch)
  let out = src.replace(
    /while true do (?:local )?[A-Za-z_]+(?:,[A-Za-z_]+)*=[A-Za-z_]+\[[A-Za-z_]+\];/g,
    m => m + INJ
  );
  // repeat form:  repeat local y=(V[W]);       (Luraph v15 dispatch, some builds)
  out = out.replace(
    /repeat (?:local )?[A-Za-z_]+=\([A-Za-z_]+\[[A-Za-z_]+\]\);/g,
    m => m + INJ
  );
  return out;
}

module.exports = {
  loadAst, loc, textOf, walkAst, localName,
  findDispatchers, resolveOp, evalCond,
  closureEntries, makerInfo, patchEntries, patchSpin,
};
