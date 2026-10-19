'use strict';

const { loadAst, loc, walkAst, unwrapGroup } = require('./vmmap');

function unwrap(e) {
  while (e && (e.type === 'AstExprGroup' || e.type === 'AstExprTypeAssertion')) e = e.expr;
  return e;
}

function localName(expr) {
  expr = unwrap(expr);
  return expr && expr.type === 'AstExprLocal' ? expr.local.name : null;
}

function findDispatchers(root) {
  const found = [];
  walkAst(root, (n) => {
    const t = n.type;
    let body;
    if (t === 'AstStatWhile' || t === 'AstStatRepeat') {
      const cond = unwrap(n.condition);
      if (!cond || cond.type !== 'AstExprConstantBool') return;
      if (t === 'AstStatWhile' ? !cond.value : cond.value) return;
      body = n.body.body;
    } else {
      return;
    }
    if (!body || body.length < 2) return;
    const st = body[0];
    if (st.type !== 'AstStatLocal' && st.type !== 'AstStatAssign') return;
    if (!st.values || st.values.length !== 1) return;
    const opname = st.type === 'AstStatLocal' ? st.vars[0].name : localName(st.vars[0]);
    if (!opname) return;
    const v = unwrap(st.values[0]);
    if (!v || v.type !== 'AstExprIndexExpr') return;
    const arr = localName(v.expr);
    const pc = localName(v.index);
    if (!arr || !pc || body[1].type !== 'AstStatIf') return;
    found.push({ node: n, op: opname, arr, pc, tree: body[1], rest: body.slice(2) });
  });
  return found;
}

const OPS = {
  CompareLt: (a, b) => a < b, CompareLe: (a, b) => a <= b,
  CompareGt: (a, b) => a > b, CompareGe: (a, b) => a >= b,
  CompareEq: (a, b) => a === b, CompareNe: (a, b) => a !== b,
};
const FLIP = {
  CompareLt: 'CompareGt', CompareLe: 'CompareGe',
  CompareGt: 'CompareLt', CompareGe: 'CompareLe',
  CompareEq: 'CompareEq', CompareNe: 'CompareNe',
};

function evalCond(cond, varName, value) {
  if (!cond || cond.type !== 'AstExprBinary' || !OPS[cond.op]) return null;
  const l = unwrap(cond.left), r = unwrap(cond.right);
  const op = cond.op;
  if (localName(l) === varName && r.type === 'AstExprConstantNumber') return OPS[op](value, r.value);
  if (localName(r) === varName && l.type === 'AstExprConstantNumber') return OPS[FLIP[op]](value, l.value);
  return null;
}

function resolve(tree, varName, value) {
  let node = tree;
  for (;;) {
    if (node.type === 'AstStatBlock') {
      if (node.body && node.body.length && node.body[0].type === 'AstStatIf' &&
          evalCond(node.body[0].condition, varName, value) !== null) {
        node = node.body[0];
        continue;
      }
      return node;
    }
    if (node.type === 'AstStatIf') {
      const r = evalCond(node.condition, varName, value);
      if (r === null) return node;
      node = r ? node.thenbody : node.elsebody;
      if (!node) return null;
      continue;
    }
    return node;
  }
}

function declsIn(fn) {
  const keys = {};
  function visit(n) {
    if (!n || typeof n !== 'object') return;
    if (Array.isArray(n)) { n.forEach(visit); return; }
    const t = n.type;
    if (t === 'AstExprFunction' && n !== fn) return;
    if (t === 'AstStatLocal') (n.vars || []).forEach((v) => { keys[v.location] = v.name; });
    else if (t === 'AstStatLocalFunction') keys[n.name.location] = n.name.name;
    else if (t === 'AstStatFor') keys[n.var.location] = n.var.name;
    else if (t === 'AstStatForIn') (n.vars || []).forEach((v) => { keys[v.location] = v.name; });
    Object.values(n).forEach(visit);
  }
  (fn.args || []).forEach((a) => { keys[a.location] = a.name; });
  visit(fn.body);
  return keys;
}

function bindingForClosure(clo, stmts, depth) {
  for (let i = stmts.length - 1; i >= 0; i--) {
    const [st, d] = stmts[i];
    if (depth !== undefined && d !== depth) continue;
    const typ = st.type;
    if (typ === 'AstStatAssign' || typ === 'AstStatLocal') {
      const vars = st.vars || [], values = st.values || [];
      for (let k = 0; k < vars.length && k < values.length; k++) {
        if (unwrap(values[k]) !== clo) continue;
        const name = typ === 'AstStatAssign' ? localName(vars[k]) : vars[k].name;
        if (name) return [st, name];
      }
    } else if (typ === 'AstStatLocalFunction') {
      const f = unwrap(st.func || st.value || st.function);
      if (f === clo) {
        const name = st.name && st.name.name;
        if (name) return [st, name];
      }
    }
  }
  return [null, null];
}

function selectVmFactory(stack, stmts, disp) {
  const pc = disp.pc;
  for (let vi = stack.length - 1; vi > 0; vi--) {
    const vm = stack[vi];
    const declNames = new Set(Object.values(declsIn(vm)));
    if (pc && !declNames.has(pc)) continue;
    const mi = vi - 1;
    const maker = stack[mi];
    const [st, varName] = bindingForClosure(vm, stmts, vi);
    if (st && (maker.args || []).length) return [mi, maker, vm, st, varName];
  }
  for (let vi = stack.length - 1; vi > 0; vi--) {
    const vm = stack[vi];
    const declNames = new Set(Object.values(declsIn(vm)));
    if (pc && !declNames.has(pc)) continue;
    for (let mi = vi - 1; mi >= 0; mi--) {
      const maker = stack[mi];
      if (!(maker.args || []).length) continue;
      let [st, varName] = bindingForClosure(vm, stmts, mi + 1);
      if (!st) [st, varName] = bindingForClosure(vm, stmts);
      if (st) return [mi, maker, vm, st, varName];
    }
  }
  for (let mi = stack.length - 2; mi >= 0; mi--) {
    const maker = stack[mi];
    if (!(maker.args || []).length) continue;
    for (let vi = mi + 1; vi < stack.length; vi++) {
      const vm = stack[vi];
      const [st, varName] = bindingForClosure(vm, stmts, mi + 1);
      if (st) return [mi, maker, vm, st, varName];
    }
  }
  return null;
}

function makerParams(maker) {
  const args = maker.args || [];
  if (!args.length) return [0, 0];
  const visible = {};
  args.forEach((a, i) => { visible[a.name] = i; });
  const direct = {}, nested = {}, used = new Set();

  function visit(n) {
    if (!n || typeof n !== 'object') return;
    if (Array.isArray(n)) { n.forEach(visit); return; }
    if (n.type === 'AstExprLocal') used.add(n.local.location);
    if (n.type === 'AstExprIndexExpr') {
      const base = unwrap(n.expr);
      const idx = unwrap(n.index);
      if (base && base.type === 'AstExprLocal') {
        const key = base.local.location;
        if (idx && idx.type === 'AstExprConstantNumber') direct[key] = (direct[key] || 0) + 4;
        if (idx && idx.type === 'AstExprIndexExpr') {
          const ib = unwrap(idx.expr);
          if (ib && ib.type === 'AstExprLocal' && ib.local.location === key) nested[key] = (nested[key] || 0) + 8;
        }
      }
    }
    Object.values(n).forEach(visit);
  }
  visit(maker.body);

  const candidates = Object.values(visible);
  const score = (i) => [(nested[args[i].location] || 0) + (direct[args[i].location] || 0), direct[args[i].location] || 0, -i];
  let pi = candidates.length ? candidates.reduce((best, i) => (score(i) > score(best) ? i : best), candidates[0]) : 0;
  const remaining = candidates.filter((i) => i !== pi);
  let ui = pi;
  if (remaining.length) {
    ui = remaining.reduce((best, i) => {
      const bs = [used.has(args[best].location), direct[args[best].location] || 0, -best];
      const is_ = [used.has(args[i].location), direct[args[i].location] || 0, -i];
      return is_ > bs ? i : best;
    }, remaining[0]);
  }
  return [pi, ui];
}

function captures(info) {
  const makerDecls = declsIn(info.maker);
  const used = {};
  function visit(n) {
    if (!n || typeof n !== 'object') return;
    if (Array.isArray(n)) { n.forEach(visit); return; }
    if (n.type === 'AstExprLocal') {
      const k = n.local.location;
      if (makerDecls[k]) used[k] = makerDecls[k];
    }
    Object.values(n).forEach(visit);
  }
  visit(info.vm);
  const names = {};
  Object.entries(used).forEach(([k, name]) => { (names[name] = names[name] || []).push(k); });
  const dup = new Set(Object.entries(names).filter(([, ks]) => ks.length > 1).map(([nm]) => nm));
  const byName = {};
  Object.entries(makerDecls).forEach(([k, nm]) => { (byName[nm] = byName[nm] || []).push(k); });
  return Object.keys(names).filter((nm) => !dup.has(nm) && (byName[nm] || []).length === 1).sort();
}

function outerEnv(info) {
  const own = new Set(Object.keys(declsIn(info.maker)));
  const found = {};
  function visit(n) {
    if (!n || typeof n !== 'object') return;
    if (Array.isArray(n)) { n.forEach(visit); return; }
    if (n.type === 'AstExprLocal') {
      const key = n.local.location;
      if (!own.has(key) && n.local.name) found[key] = n.local.name;
    }
    Object.values(n).forEach(visit);
  }
  visit(info.maker.body);
  const byName = {};
  Object.entries(found).forEach(([key, name]) => { (byName[name] = byName[name] || []).push(key); });
  const out = [];
  let idx = 0;
  Object.keys(found).sort().forEach((key) => {
    const name = found[key];
    if (byName[name].length !== 1) return;
    idx += 1;
    out.push({ decl: key, name, field: `__venv${idx}` });
  });
  return out;
}

function closureEntries(root) {
  const byNode = new Map(findDispatchers(root).map((d) => [d.node, d]));
  const seen = new Map();
  function walk(n, stack, stmts) {
    if (!n || typeof n !== 'object') return;
    if (Array.isArray(n)) { n.forEach((v) => walk(v, stack, stmts)); return; }
    const t = n.type;
    let st = stack, sm = stmts;
    if (t === 'AstExprFunction') { st = [...stack, n]; sm = stmts; }
    if (t && t.startsWith('AstStat')) sm = [...stmts, [n, stack.length + 1]];
    if ((t === 'AstStatWhile' || t === 'AstStatRepeat') && byNode.has(n)) {
      const picked = selectVmFactory(st, sm, byNode.get(n));
      if (picked) {
        const [, maker, vm] = picked;
        const body = (vm.body || {}).body || [];
        if (body.length) {
          const [l1, c1] = loc(body[0]);
          const [pi] = makerParams(maker);
          if (maker.args && pi < maker.args.length) seen.set(`${l1},${c1}`, maker.args[pi].name);
        }
      }
    }
    Object.values(n).forEach((v) => walk(v, st, sm));
  }
  walk(root, [], []);
  return [...seen.entries()].map(([k, name]) => { const [l, c] = k.split(',').map(Number); return [l, c, name]; });
}

function makerInfo(root) {
  const byNode = new Map(findDispatchers(root).map((d) => [d.node, d]));
  const out = new Map();
  function walk(n, stack, stmts) {
    if (!n || typeof n !== 'object') return;
    if (Array.isArray(n)) { n.forEach((v) => walk(v, stack, stmts)); return; }
    const t = n.type;
    let st = stack, sm = stmts;
    if (t === 'AstExprFunction') { st = [...stack, n]; }
    if (t && t.startsWith('AstStat')) sm = [...stmts, [n, stack.length + 1]];
    if ((t === 'AstStatWhile' || t === 'AstStatRepeat') && byNode.has(n)) {
      const disp = byNode.get(n);
      const picked = selectVmFactory(st, sm, disp);
      if (picked) {
        const [mi, maker, clo, stBind, varName] = picked;
        const [, , l2, c2] = loc(stBind);
        const key = `${l2},${c2}`;
        if (!out.has(key)) {
          const [pi, ui] = makerParams(maker);
          if (maker.args && pi < maker.args.length) {
            out.set(key, {
              at: [l2, c2], var: varName,
              proto: maker.args[pi].name, protoIndex: pi, upvalsIndex: ui,
              pfKey: maker.args[pi].name, maker, vm: clo, stmt: stBind,
              makerDepth: mi, dispatchPc: disp.pc, dispatchArr: disp.arr,
            });
          }
        }
      }
    }
    Object.values(n).forEach((v) => walk(v, st, sm));
  }
  walk(root, [], []);
  const results = [...out.values()];
  results.forEach((info) => {
    info.captures = captures(info);
    info.outerEnv = outerEnv(info);
  });
  return results;
}

function patchEntries(source, filePath, chunkTag) {
  const root = loadAst(filePath);
  const lines = source.split('\n');
  const edits = [];
  for (const [l1, c1, pv] of closureEntries(root)) {
    const k = `(${pv} or __PID)`;
    edits.push([l1, c1,
      `if not __PID[${k}] then __PID.n=__PID.n+1;__PID[${k}]=__PID.n;end;` +
      `__ENT.n=__ENT.n+1;__ENT[__ENT.n%64]=__PID[${k}];__PLAST[__PID[${k}]]=__ENT.n;` +
      `if __SKIPP[__PID[${k}]] then return end;`]);
  }
  for (const info of makerInfo(root)) {
    const [l2, c2] = info.at;
    const pv = info.proto;
    const v = info.var;
    const pfKey = info.pfKey || pv;
    let code = ` __PF[${v}]=${pfKey} `;
    const cap = info.captures.map((nm) => `__PA[${pv}].${nm}=${nm};`).join('');
    const ocap = (info.outerEnv || []).map((e) => `__PA[${pv}].${e.field}=${e.name};`).join('');
    code += `if __PA and not __PA[${pv}] then __PA[${pv}]={};__PA.n=__PA.n+1;__PA[${pv}].__seq=__PA.n;` +
            `__PA[${pv}].__maker="${chunkTag}@${l2},${c2}";__PK[${pfKey}]=${v};${cap}${ocap} end `;
    edits.push([l2, c2, code]);
  }
  edits.sort((a, b) => (b[0] !== a[0] ? b[0] - a[0] : b[1] - a[1]));
  for (const [l, c, code] of edits) {
    lines[l] = lines[l].slice(0, c) + code + lines[l].slice(c);
  }
  return lines.join('\n');
}

function patchSpin(src) {
  return src.replace(
    /\b(?:while true do|repeat) (?:local )?[A-Za-z_]\w*(?:,[A-Za-z_]\w*)*=\s*\(\s*[A-Za-z_]\w*\[[A-Za-z_]\w*\]\s*\)\s*;|\bwhile true do (?:local )?[A-Za-z_]\w*(?:,[A-Za-z_]\w*)*=\s*[A-Za-z_]\w*\[[A-Za-z_]\w*\]\s*;/g,
    (m) => m + '__SPIN.n=__SPIN.n+1;if __SPIN.n>=__SPIN.step then __SPIN.f()end;'
  );
}

module.exports = {
  loadAst, loc, unwrap, findDispatchers, evalCond, resolve,
  closureEntries, makerInfo, patchEntries, patchSpin,
};