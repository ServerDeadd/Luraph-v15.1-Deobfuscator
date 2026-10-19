'use strict';

// Runs the Python devirtualization stage as several candidates at once and keeps
// the best result.
//
// Why: the lifter iterates some sets of strings, so its result depends on the
// interpreter's string-hash order (PYTHONHASHSEED). For one input every seed is
// deterministic, but different seeds can differ a lot (code2: 27 vs 242 unlifted
// blocks). PyPy runs the same code ~2x faster with its own fixed order. Running a
// few candidates in parallel costs about the wall time of one (the machine has
// many cores) and keeps the best: fewest unlifted blocks, then most functions.
// A candidate that finishes with 0 unlifted blocks wins at once (the rest stop).
//
// DEOB_PY_CANDIDATES  comma list of "pypy", "python" or "python:<seed>"
//                     default: "pypy,python:1,python:2" when pypy\pypy3.exe exists,
//                     else "python:1,python:2,python:3"
// DEOB_FAST=1         only the first candidate (PyPy when bundled): fastest, no best-of

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');
const { getPythonBin } = require('./pyenv');

const ROOT = path.join(__dirname, '..');
// DEOB_PYPY overrides; else the bundled Windows build, else a Linux tree next to the tool
const PYPY = process.env.DEOB_PYPY ||
  [path.join(ROOT, 'pypy', 'pypy3.exe'), path.join(ROOT, 'pypy', 'bin', 'pypy3'),
   path.join(ROOT, '..', 'pypy', 'bin', 'pypy3')].find(p => fs.existsSync(p)) ||
  path.join(ROOT, 'pypy', 'pypy3.exe');

function candidateList() {
  let spec = process.env.DEOB_PY_CANDIDATES;
  if (!spec) spec = fs.existsSync(PYPY) ? 'pypy,python:1,python:2' : 'python:1,python:2,python:3';
  let list = spec.split(',').map(s => s.trim()).filter(Boolean).map(s => {
    const [kind, seed] = s.split(':');
    if (kind === 'pypy') return { label: 'pypy', exe: PYPY, seed: seed || '0' };
    return { label: seed ? `python:${seed}` : 'python', exe: getPythonBin(), seed: seed || null };
  });
  list = list.filter(c => c.label !== 'pypy' || fs.existsSync(PYPY));
  if (process.env.DEOB_FAST) list = list.slice(0, 1);
  return list.length ? list : [{ label: 'python', exe: getPythonBin(), seed: null }];
}

function parseStats(text) {
  const all = [...text.matchAll(/\[\*\]\s+(\d+) functions, (\d+) unlifted blocks/g)];
  const kept = /keeping the full lift of round \d+ \((\d+) unlifted blocks, (\d+) functions\)/.exec(text);
  if (kept) return { errors: +kept[1], functions: +kept[2] };
  if (!all.length) return null;
  const m = all[all.length - 1];
  return { functions: +m[1], errors: +m[2] };
}

// cfgData: the bridge input; returns once dpath holds the chosen result
async function runCandidates(cfgData, job) {
  const cands = candidateList();
  const bridgePy = path.join(__dirname, 'devirt_bridge.py');
  const coreDir = path.join(ROOT, 'core');
  if (cands.length > 1) {
    process.stderr.write(`[*] devirtualizing with ${cands.length} parallel candidates: ${cands.map(c => c.label).join(', ')}\n`);
  }

  const runs = cands.map((c, i) => {
    const tag = cands.length > 1 ? `.c${i}` : '';
    const own = Object.assign({}, cfgData, {
      trace_path: cfgData.trace_path + tag,
      ppath: cfgData.ppath + tag,
      dpath: cfgData.dpath + tag,
    });
    if (tag) fs.copyFileSync(cfgData.ppath, own.ppath);   // constant rounds rewrite it
    const cfgPath = job.path(`.cfg${tag}.json`);
    fs.writeFileSync(cfgPath, JSON.stringify(own), 'utf8');
    const env = Object.assign({}, process.env, { PYTHONPATH: coreDir });
    if (c.seed !== null) env.PYTHONHASHSEED = c.seed;
    const t0 = Date.now();
    const proc = spawn(c.exe, [bridgePy, 'pipeline', cfgPath], { env, stdio: ['ignore', 'ignore', 'pipe'] });
    const run = { c, own, cfgPath, proc, log: '', done: false, t0 };
    proc.stderr.on('data', d => {
      const s = d.toString();
      run.log += s;
      if (cands.length === 1) process.stderr.write(s);     // single run: live progress as before
    });
    run.promise = new Promise(resolve => proc.on('close', code => {
      run.done = true;
      run.code = code;
      run.secs = (Date.now() - t0) / 1000;
      run.stats = fs.existsSync(own.dpath) ? parseStats(run.log) : null;
      resolve(run);
    }));
    return run;
  });

  // first perfect result (0 unlifted blocks) wins immediately
  const pending = new Set(runs);
  let winner = null;
  while (pending.size && !winner) {
    const r = await Promise.race([...pending].map(x => x.promise));
    pending.delete(r);
    if (cands.length > 1) {
      const st = r.stats ? `${r.stats.functions} functions, ${r.stats.errors} unlifted` : `failed (exit ${r.code})`;
      process.stderr.write(`[*]   candidate ${r.c.label}: ${st} (${r.secs.toFixed(0)}s)\n`);
    }
    if (r.stats && r.stats.errors === 0) winner = r;
  }
  for (const r of pending) { try { r.proc.kill(); } catch {} }
  await Promise.all([...pending].map(r => r.promise));

  if (!winner) {
    const ok = runs.filter(r => r.stats);
    ok.sort((a, b) => (a.stats.errors - b.stats.errors) || (b.stats.functions - a.stats.functions) ||
                      (runs.indexOf(a) - runs.indexOf(b)));
    winner = ok[0] || null;
  }
  if (!winner) {
    for (const r of runs) process.stderr.write(r.log.slice(-1500));
    throw new Error('every devirtualization candidate failed');
  }
  if (cands.length > 1) {
    process.stderr.write(`[*] keeping candidate ${winner.c.label} (${winner.stats.errors} unlifted blocks, ${winner.stats.functions} functions)\n`);
    fs.copyFileSync(winner.own.dpath, cfgData.dpath);
  }

  for (const r of runs) {
    if (cands.length > 1) {
      for (const p of [r.own.dpath, r.own.ppath]) { try { fs.unlinkSync(p); } catch {} }
    }
    if (!process.env.DEOB_KEEP_CFG) { try { fs.unlinkSync(r.cfgPath); } catch {} }
  }
  return winner;
}

module.exports = { runCandidates, candidateList, parseStats };
