import json
import os
import re
import sys
import time

import harness
import traceout as trace

HERE = os.path.dirname(os.path.abspath(__file__))
MAX_RERUNS = 12
SPIN_CHECKS = 24    

def patch_spin(src):
    """Spin watchdog (envlog's --cfg spin): every VM dispatch loop head counts
    steps in __SPIN.n and calls __SPIN.f() every __SPIN.step of them. Table
    operations only, plus that rare call (no locals: see patch_entries)."""
    return re.sub(r"while true do (?:local )?[A-Za-z_]+(?:,[A-Za-z_]+)*=[A-Za-z_]+\[[A-Za-z_]+\];",
                  lambda m: m.group(0) + "__SPIN.n=__SPIN.n+1;if __SPIN.n>=__SPIN.step then __SPIN.f()end;", src)

def patch_chunk(src, tmpdir):
    """Instrument a loadstring'd VM chunk like the main script."""
    path = os.path.join(tmpdir, "_chunk_%s.luau" % harness.chunk_key(src))
    with open(path, "w", encoding="latin-1", newline="") as f:
        f.write(src)
    try:
        return patch_entries(src, path)
    except Exception as e:  
        print("[!] could not instrument chunk (%s)" % e, file=sys.stderr)
        return src
    finally:
        os.remove(path)

def patch_entries(source, path):
    """Give every VM closure an entry hook. It only uses table operations (no
    calls, no locals), so the stack looks exactly as it would without it: it numbers
    protos in first-entry order, logs recent entries and returns early for the
    protos listed in __SKIPP."""
    from obfuscators.luraph_v15 import vmmap
    root = vmmap.load_ast(path)
    lines = source.split("\n")
    edits = []
    for l1, c1, pv in vmmap.closure_entries(root):

        k = "(%s or __PID)" % pv
        edits.append((l1, c1, ("if not __PID[{k}] then __PID.n=__PID.n+1;__PID[{k}]=__PID.n;end;"
                               "__ENT.n=__ENT.n+1;__ENT[__ENT.n%64]=__PID[{k}];__PLAST[__PID[{k}]]=__ENT.n;"
                               "if __SKIPP[__PID[{k}]] then return end;").format(k=k)))

    tag = harness.chunk_key(source)
    for info in vmmap.maker_info(root):
        (l2, c2), var, pv = info["at"], info["var"], info["proto"]
        c3 = info.get("curried3")
        if c3:
            f3, f2 = c3["f3"], c3["f2"]
            f3_l0, f3_c0, _, _ = vmmap.loc(f3["body"]["body"][0])
            f3_params = list(dict.fromkeys(
                a["name"] for a in (f3.get("args") or []) if a.get("name") and a["name"] != "..."
            ))
            f3_cap = ",".join("%s=%s" % (nm, nm) for nm in f3_params)
            head_code = ("local __pv={%s};if __PA and __PA.n<8192 then __PA.n=__PA.n+1;"
                         "__PA[__pv]={__seq=__PA.n,__maker=\"%s@%d,%d\",%s} end;"
                         % (f3_cap, tag, l2, c2, f3_cap))
            edits.append((f3_l0, f3_c0, head_code))
            if c3.get("kind") == "named":
                r1_l, r1_c, _, _ = vmmap.loc(c3["retStmt"])
                r2_l, r2_c, _, _ = vmmap.loc(c3["f2Ret"])
                u_name, z_name = c3["uName"], c3["zName"]
                edits.append((r1_l, r1_c, "__PF[%s]=__pv;__PK[__pv]=%s;" % (u_name, u_name)))
                edits.append((r2_l, r2_c, "__PF[%s]=__pv;__PK[__pv]=%s;" % (z_name, z_name)))
            else:
                fn_l1, fn_c1, fn_l2, fn_c2 = vmmap.loc(f2)
                edits.append((fn_l1, fn_c1, "(function(__mk)__PF[__mk]=__pv;__PK[__pv]=__mk;return __mk end)("))
                edits.append((fn_l2, fn_c2, ")"))
            continue
        code = " __PF[%s]=%s " % (var, info.get("pf_key", pv))

        cap = "".join("__PA[%s].%s=%s;" % (pv, nm, nm) for nm in info["captures"])

        code += ("if __PA and not __PA[%s] then __PA[%s]={};__PA.n=__PA.n+1;__PA[%s].__seq=__PA.n;"
                 "__PA[%s].__maker=\"%s@%d,%d\";__PK[%s]=%s;%s end "
                 % (pv, pv, pv, pv, tag, l2, c2, info.get("pf_key", pv), var, cap))
        edits.append((l2, c2, code))
    for l, c, code in sorted(edits, reverse=True):
        lines[l] = lines[l][:c] + code + lines[l][c:]
    return "\n".join(lines)

def _force_run(rerun, cfg, req_list, bufs):
    """One forced-constant rerun -> (protos_line, err). protos_line is None on
    failure; err carries the reason (e.g. a luau 'block too big' from a constant
    whose decoded value is too large to allocate)."""
    c = dict(cfg)
    c["force_req"] = ";".join(req_list)
    c["force_buf"] = bufs
    body, err = rerun(c)
    if body is None:
        return None, "run failed: " + (err or "")[-300:]
    m = re.search(re.escape(harness.mark("PROTOS ")) + r"([^\n]*)\n", body)
    if not m:
        st = re.search(r"-- run status: [^\n]*", body)
        return None, "no protos (%s)" % (st.group(0) if st else "?")
    if m.group(1).startswith("error:"):
        return None, m.group(1)[:300]
    return m.group(1), None

def _force_bisect(rerun, cfg, req_list, bufs, budget):
    """Force as many of req_list's constants as fit without 'block too big'
    (one constant can decode to a value too large to hold). Returns
    (fitting_subset, protos_line) for the largest subset that decodes together;
    a poison constant is simply left lazy. `budget` is a 1-element list bounding
    the number of reruns (each is a full, slow trace)."""
    if budget[0] <= 0 or not req_list:
        return [], None
    budget[0] -= 1
    line, err = _force_run(rerun, cfg, req_list, bufs)
    if line is not None:
        return req_list, line
    if "block too big" not in (err or "") or len(req_list) <= 1:
        return [], None     # a single poison constant, or an unrelated error
    mid = len(req_list) // 2
    lreq, lline = _force_bisect(rerun, cfg, req_list[:mid], bufs, budget)
    rreq, rline = _force_bisect(rerun, cfg, req_list[mid:], bufs, budget)
    if lreq and rreq and budget[0] > 0:
        budget[0] -= 1
        line2, _ = _force_run(rerun, cfg, lreq + rreq, bufs)
        if line2 is not None:
            return lreq + rreq, line2       # union of both halves still fits
    if len(lreq) >= len(rreq):
        return (lreq, lline) if lreq else (rreq, rline)
    return (rreq, rline) if rreq else (lreq, lline)

# --- opt-in constant MERGE (DEVIRT_MERGE): recover every requested constant by
# forcing them in fitting subsets (bisecting around luau's single-allocation cap
# 'block too big') and unioning each subset's decoded `overrides` into one dump.
# Correct without id-alignment luck: overrides are keyed by stable request paths
# (proto pid + key chain), so the union dedups by path; a decoded value that
# references a FORCED-NEW table (tid > base_max) is copied with fresh,
# non-colliding ids and its references remapped, while refs to BASE tables
# (tid <= base_max, identical across same-trace dumps) stay as they are. Any
# override whose table closure is incomplete, or from a subset whose base region
# does not match (a fallback fresh re-trace with divergent ids), is skipped --
# it stays undecoded rather than ever becoming a wrong value. Feature is OFF by
# default, so production behaviour is unchanged.
def _ref_tids(v, acc):
    if isinstance(v, dict):
        if len(v) == 1 and isinstance(v.get("t"), int):
            acc.add(v["t"]); return
        for x in v.values():
            _ref_tids(x, acc)
    elif isinstance(v, list):
        for x in v:
            _ref_tids(x, acc)

def _remap_val(v, m):
    if isinstance(v, dict):
        if len(v) == 1 and isinstance(v.get("t"), int):
            return {"t": m.get(v["t"], v["t"])}
        return {k: _remap_val(x, m) for k, x in v.items()}
    if isinstance(v, list):
        return [_remap_val(x, m) for x in v]
    return v

def _remap_table(td, m):
    out = {}
    for k, val in td.items():
        if k == "arr":
            out["arr"] = [_remap_val(x, m) for x in val]
        elif k == "kv":
            out["kv"] = [[_remap_val(kk, m), _remap_val(vv, m)] for kk, vv in val]
        else:
            out[k] = val          # mt / mtf / late / n: tid-free scalars
    return out

def _base_fingerprint(tables, base_max):
    """(len arr, len kv) per base-region table: stable under forcing a constant
    (a decoded slot changes a value, not the array length), so a mismatch means
    the subset came from a different trace and its base-table refs cannot be
    trusted."""
    fp = {}
    for tid, td in tables.items():
        if int(tid) <= base_max:
            fp[int(tid)] = (len(td.get("arr", [])), len(td.get("kv", [])))
    return fp

def _merge_subset(base, sub, base_max, base_fp, have):
    """Union sub's decoded overrides into the base dump dict. Returns the count
    actually added (overrides already present, or ones needing an untrusted or
    incomplete table, are left out)."""
    sub_tables = sub.get("tables", {})
    if _base_fingerprint(sub_tables, base_max) != base_fp:
        print("[!]   merge: a subset's base region diverged (fresh re-trace?); skipping it",
              file=sys.stderr)
        return 0
    btables = base["tables"]
    cur_max = [max(int(t) for t in btables)]
    added = 0
    for path, val in sub.get("overrides", []):
        if path in have:
            continue
        need = set(); _ref_tids(val, need)
        new_needed = set()
        frontier = [t for t in need if t > base_max]
        ok = True
        while frontier:
            t = frontier.pop()
            if t in new_needed:
                continue
            new_needed.add(t)
            td = sub_tables.get(str(t))
            if td is None:
                ok = False; break
            refs = set()
            for x in td.get("arr", []):
                _ref_tids(x, refs)
            for kk, vv in td.get("kv", []):
                _ref_tids(kk, refs); _ref_tids(vv, refs)
            frontier.extend(t2 for t2 in refs if t2 > base_max and t2 not in new_needed)
        if not ok:
            continue              # incomplete closure: leave this one undecoded
        m = {}
        for t in sorted(new_needed):
            cur_max[0] += 1; m[t] = cur_max[0]
        for t in new_needed:
            btables[str(m[t])] = _remap_table(sub_tables[str(t)], m)
        base["overrides"].append([path, _remap_val(val, m)])
        have.add(path)
        added += 1
    return added

def _force_merge(rerun, cfg, req_list, bufs, base, budget):
    """Force req_list in fitting subsets and union every decoded override into
    `base` (a parsed dump dict). Returns the merged dump as a JSON string, or
    None if nothing new decoded."""
    have = {p for p, _ in base.get("overrides", [])}
    base.setdefault("overrides", [])
    base_max = max(int(t) for t in base["tables"])
    base_fp = _base_fingerprint(base["tables"], base_max)
    total = [0]
    todo = [r for r in req_list if r not in have]

    def go(sub):
        if budget[0] <= 0 or not sub:
            return
        budget[0] -= 1
        line, err = _force_run(rerun, cfg, sub, bufs)
        if line is not None:
            try:
                got = _merge_subset(base, json.loads(line), base_max, base_fp, have)
                total[0] += got
                print("[*]   merge: subset of %d fit -> +%d constants (%d total, budget %d left)"
                      % (len(sub), got, total[0], budget[0]), file=sys.stderr)
            except Exception as e:
                print("[!]   merge: subset merge failed (%s)" % str(e)[:200], file=sys.stderr)
            return
        if "block too big" not in (err or "") or len(sub) <= 1:
            return                # a single poison constant, or an unrelated error
        mid = len(sub) // 2
        go(sub[:mid]); go(sub[mid:])

    go(todo)
    if total[0] == 0:
        return None
    print("[*]   merge: decoded %d new constants across fitting subsets "
          "(%d requested, %d already present)"
          % (total[0], len(req_list), len(req_list) - len(todo)), file=sys.stderr)
    return json.dumps(base)

def devirtualize(job, ppath, dpath, cfg, rerun, chunk_paths=(), live=None):
    """Lift the captured protos; constants that only Luraph's lazy decoder can
    produce (code that never ran) are requested from further runs. With a
    live harness (`live()` -> fetch function, while the long-lived harness
    made the current dump) the walks ask for them right away (a chain of
    constants, each needed to find the next, then takes one round instead
    of one round per link)."""
    from obfuscators.luraph_v15 import devirt
    args = job.args
    requested = set()
    last_bufs = ""
    text = None
    rounds = args.devirt_rounds

    quick = not os.environ.get("DEVIRT_FULL_ROUNDS")
    cache = devirt.WalkCache()
    t0 = time.time()
    last_errors = None
    best = None
    worse = 0
    best_errors = None
    block_stall = 0
    # stop the constant-request loop after this many full lifts that recover no
    # further block, or after this many seconds total (0 = no cap). Both tunable.
    BLOCK_STALL_MAX = int(os.environ.get("DEVIRT_BLOCK_STALL", "3"))
    ROUND_BUDGET = float(os.environ.get("DEVIRT_ROUND_BUDGET", "240"))
    for rnd in range(1, rounds + 1):
        t1 = time.time()

        # hard wall-clock cap, checked at the TOP of every round (quick or full)
        # so no single candidate can run away (a slow CPython seed spent 601s in
        # quick-collect rounds that never check the budget before this was here).
        over_budget = bool(ROUND_BUDGET) and time.time() - t0 > ROUND_BUDGET
        if over_budget and best is not None:
            print("[*]   constant-round time budget (%.0fs) reached: keeping round %d"
                  % (ROUND_BUDGET, best[2]), file=sys.stderr)
            break

        if quick and (last_errors == 0 or (rnd == 1 and (live and live()) is not None)):
            full = True
        elif over_budget:
            # over budget with nothing kept yet: do ONE full lift now for output,
            # then the post-lift break (new/rounds/budget) ends the loop
            full = True
            rounds = rnd
        else:
            full = not quick

        if not full and quick:
            stats, reqs, bufs = devirt.run_big_stack(devirt.collect_requests, job.source_path, ppath, chunk_paths, cache,
                                                     live and live())
            last_errors = stats.get("errors", 0)
            new = reqs - requested
            print("[*] devirt round %d: %d functions (%d walked), %d unlifted blocks, %d new constant requests%s "
                  "(%.1fs)" % (rnd, stats["functions"], stats["walked"], stats["errors"], len(new),
                               " (%d decoded live)" % stats["fetched"] if stats.get("fetched") else "",
                               time.time() - t1), file=sys.stderr)
            if os.environ.get("DEVIRT_REQS"):
                for rq in sorted(new):
                    print("[*]     request %s" % rq, file=sys.stderr)
            if (not new and (not (requested | reqs) or devirt.same_patches(last_bufs, bufs))) or rnd == rounds:
                full = True
        if full:
            print("[*] devirtualizing (round %d)..." % rnd, file=sys.stderr)
            t1 = time.time()
            text, stats, reqs, bufs = devirt.run_big_stack(devirt.lift_program, job.source_path, ppath, chunk_paths,
                                                           live and live())
            # constant rounds can oscillate (a newly decoded constant opens
            # code that then misses others): keep the best full lift seen
            score = (stats["errors"], -stats["functions"])
            if best is None or score < best[0]:
                best = (score, text, rnd)
                worse = 0
            else:
                worse += 1
            # unlifted blocks are the goal; track a plateau on them alone so we do
            # not keep re-running the script for many rounds that only add a few
            # functions without recovering any block (ls4: 22 rounds -> ~4)
            if best_errors is None or stats["errors"] < best_errors:
                best_errors = stats["errors"]
                block_stall = 0
            else:
                block_stall += 1
            new = reqs - requested
            print("[*]   %d functions, %d unlifted blocks, %d unstructured jumps, %d new constant requests (%.1fs)"
                  % (stats["functions"], stats["errors"], stats["fallbacks"], len(new), time.time() - t1),
                  file=sys.stderr)
            if (not new and (not (requested | reqs) or devirt.same_patches(last_bufs, bufs))) or rnd == rounds:
                break
            if stats["errors"] == 0:
                print("[*]   every block recovered: stopping", file=sys.stderr)
                break
            # full lifts that keep getting worse (code2: 27 -> 66 -> 105 -> 155
            # unlifted blocks, 150s each) will not come back: keep the best
            if worse >= 2:
                print("[*]   two full lifts in a row without improving: keeping round %d" % best[2],
                      file=sys.stderr)
                break
            # no block recovered for BLOCK_STALL_MAX rounds in a row: the chain is
            # only adding stray functions now, not worth more full reruns
            if block_stall >= BLOCK_STALL_MAX:
                print("[*]   %d rounds without recovering a block: keeping round %d"
                      % (block_stall, best[2]), file=sys.stderr)
                break
            if ROUND_BUDGET and time.time() - t0 > ROUND_BUDGET:
                print("[*]   constant-round time budget (%.0fs) reached: keeping round %d"
                      % (ROUND_BUDGET, best[2]), file=sys.stderr)
                break
            if quick:
                print("[*]   the full lift needs more constants: continuing with full lifts", file=sys.stderr)
                quick = False
        requested |= reqs
        last_bufs = bufs
        c = dict(cfg)
        c["force_buf"] = bufs
        req_list = sorted(requested)
        t1 = time.time()
        line, err = _force_run(rerun, c, req_list, bufs)
        if line is None and "block too big" in (err or "") and os.environ.get("DEVIRT_MERGE"):
            # the whole set does not fit one luau allocation: force fitting
            # subsets and union every decoded override into the current dump,
            # recovering constants the single big force cannot (opt-in: slow).
            print("[!] constant decode hit 'block too big'; forcing subsets and merging decoded constants",
                  file=sys.stderr)
            budget = [int(os.environ.get("DEVIRT_MERGE_BUDGET", "64"))]
            try:
                with open(ppath, encoding="utf-8") as f:
                    base = json.load(f)
                line = _force_merge(rerun, c, req_list, bufs, base, budget)
            except Exception as e:
                print("[!]   merge failed to start (%s); keeping the current dump" % str(e)[:200],
                      file=sys.stderr)
        elif line is None and "block too big" in (err or "") and os.environ.get("DEVIRT_BISECT"):
            # a constant decodes to a value too large for luau to allocate; skip
            # the oversized one(s) and keep the rest (opt-in: bisection is slow).
            print("[!] constant decode hit 'block too big'; bisecting to skip the oversized constant(s)",
                  file=sys.stderr)
            budget = [int(os.environ.get("DEVIRT_BISECT_BUDGET", "24"))]
            kept, line = _force_bisect(rerun, c, req_list, bufs, budget)
            if line is not None:
                print("[*]   bisect kept %d/%d constants (dropped %d oversized)"
                      % (len(kept), len(req_list), len(req_list) - len(kept)), file=sys.stderr)
        if os.environ.get("DEVIRT_TIMING"):
            print("[*]   constant run %.1fs (total %.0fs)" % (time.time() - t1, time.time() - t0), file=sys.stderr)
        if line is None:
            print("[!] constant request run failed/gave no protos: " + (err or "?")[:400], file=sys.stderr)
            break
        with open(ppath, "w", encoding="utf-8", newline="\n") as f:
            f.write(line)
    header = job.credit_header()
    prefix = (header + "\n") if header else ""
    if best is not None and best[1] is not text:
        print("[*] keeping the full lift of round %d (%d unlifted blocks, %d functions)"
              % (best[2], best[0][0], -best[0][1]), file=sys.stderr)
        text = best[1]
    if text is None:
        # every round failed before the first full lift (the "constant request
        # run failed" path breaks out with text still None): finish_text(None)
        # used to crash with a TypeError that hid the real error
        sys.exit("[!] no devirtualized output was produced: the constant-request run failed "
                 "before the first full lift (see the error above); re-run with "
                 "DEVIRT_FULL_ROUNDS=1 to lift the first round without extra constant runs")
    job.write(dpath, prefix + devirt.finish_text(text) + "\n")

def run(job):
    """The whole Luraph pipeline; returns the result file's path."""
    args = job.args
    devirt_on = not args.no_devirt
    source = job.source
    try:
        patched = source if args.no_hooks else patch_entries(source, job.source_path)
    except SyntaxError as e:
        sys.exit("[!] the input is %s: the file is damaged (truncated, or mangled by a paste/upload); "
                 "nothing to run" % e)
    cache_path = harness.load_p2d_cache(job.input, args.studio)
    runner = harness.Runner(job)
    bridge = runner.bridge

    skip = []

    spin = not os.environ.get("DEOB_SPIN_LATE")
    if spin:
        patched = patch_spin(patched)
    chunks = {}
    raw_chunks = {}     
    body = None
    trapped = None      
    cfg = None
    for attempt in range(1, args.max_runs + 1):

        cfg = {"time_budget": args.budget, "dump_strings": args.strings, "executor": args.executor,
               "skip_protos": skip}
        if args.input_text is not None:
            cfg["input_text"] = args.input_text
        if args.no_fold:
            cfg["fold"] = False
        if devirt_on:
            cfg["devirt"] = True
        harness.user_cfg(args, cfg)
        if spin:
            cfg["spin"] = SPIN_CHECKS
        print("[*] tracing %s (run %d)..." % (job.input, attempt), file=sys.stderr)
        body, err = runner.run(patched, cfg, chunks)
        if body is None and not spin and err.startswith("timed out") and not bridge:

            print("[*] the script never finished; re-running with a spin watchdog", file=sys.stderr)
            spin = True
            patched = patch_spin(patched)
            chunks = {k: patch_spin(v) for k, v in chunks.items()}
            cfg["spin"] = SPIN_CHECKS
            body, err = runner.run(patched, cfg, chunks)
        if body is None:
            harness.save_raw(args.raw)
            runner.finish()
            sys.exit("[!] " + err)
        body = harness.take_p2d(body, cache_path, bridge is not None)
        found, body = harness.take_chunks(body)
        added = 0
        for key, src in found:
            if key not in chunks and args.no_hooks:
                chunks[key] = src
            elif key not in chunks:
                raw_chunks[key] = src
                chunks[key] = patch_chunk(src, job.outdir)
                if spin:
                    chunks[key] = patch_spin(chunks[key])
                added += 1
        if added:
            print("[*] script loadstring'd %d new VM chunk(s); instrumenting and re-running" % added, file=sys.stderr)
            continue
        trig = re.search(re.escape(harness.mark("TRIGGER ")) + r"(\d+)", body)
        if trapped is not None and trace.stmt_count(body) < trace.stmt_count(trapped[0]):

            print("[*] disabling function #%d made the script stop earlier: it is the script's own "
                  "crash check; keeping run %d" % (skip[-1], attempt - 1), file=sys.stderr)
            body, harness.LAST_RAW[0] = trapped
            skip.pop()
            break
        if not trig:
            break
        trapped = (body, harness.LAST_RAW[0])
        pid = int(trig.group(1))
        if pid in skip:
            print("[!] anti-tamper trigger %d fired again; giving up on reruns" % pid, file=sys.stderr)
            break
        print("[*] anti-tamper trap reached through function #%d; disabling it and re-running" % pid,
              file=sys.stderr)
        skip.append(pid)

    run_text = harness.trace_text(body)     
    body = harness.p2d_miss(body, cache_path)
    if not devirt_on:
        runner.finish()
    harness.save_raw(args.raw)
    body = re.sub(re.escape(harness.mark("TRIGGER ")) + r"\d+\n?", "", body)
    protos_json, body = trace.take_line(body, "PROTOS")
    force, body = trace.take_line(body, "FORCE")
    if force is not None and devirt_on:
        print("[*] constants decoded on request: " + force, file=sys.stderr)
    unscrambled, body = trace.take_line(body, "UNSCRAMBLED")
    if unscrambled is not None and devirt_on:
        print("[*] %s function(s) scrambled by the script's LPH_CRASH(): dumped as they were "
              "when first created" % unscrambled, file=sys.stderr)
    body, strings = trace.take_strings(body)

    notes = ["anti-tamper trap functions disabled: %s" % ", ".join("#%d" % p for p in skip)] if skip else []
    text = trace.header(job.input, notes) + body

    def write_trace():
        job.write(job.trace_path, trace.render(text, args))

    if not (devirt_on and not job.debug):
        write_trace()
    if strings is not None:
        job.write(job.path(".strings.txt"), strings)
    dpath = job.path(".devirt.luau")
    if protos_json is not None:
        ppath = job.path(".protos.json")
        if protos_json.startswith("error:"):
            print("[!] proto capture failed: " + protos_json, file=sys.stderr)
        else:
            job.write(ppath, protos_json)
            if devirt_on:

                chunk_paths = [job.write(job.path(".chunk_%s.luau" % key), src, encoding="latin-1")
                               for key, src in raw_chunks.items()]
                lift(job, runner, patched, cfg, chunks, run_text, ppath, dpath, chunk_paths)
    runner.finish()
    trace.status_line(body)
    if devirt_on and os.path.exists(dpath):

        with open(dpath, encoding="utf-8", errors="replace") as f:
            lifted = f.read()
        nil_calls = lifted.count("(nil)(")
        if nil_calls < 50 or nil_calls * 100 < lifted.count("\n"):
            return dpath
        print("[!] the devirtualized output is broken (%d calls of nil); writing the behaviour trace "
              "instead" % nil_calls, file=sys.stderr)
        if not job.debug:
            os.remove(dpath)
        write_trace()
        return job.trace_path
    if devirt_on:
        print("[!] devirtualization produced no output; writing the behaviour trace instead", file=sys.stderr)
        if not os.path.exists(job.trace_path):
            write_trace()
    return job.trace_path

def lift(job, runner, patched, cfg, chunks, run_text, ppath, dpath, chunk_paths):
    """devirtualize() with its constant rounds answered by one long-lived
    harness (started now, so the script runs while round 1 walks); a fresh
    run per round if it fails or behaves differently."""
    args = job.args
    bridge = runner.bridge
    server = [None]
    synced = [False]    
    if not bridge and not os.environ.get("DEOB_NO_SERVE"):
        hs = harness.HarnessServer(runner.luau, patched, cfg, chunks)
        server[0] = hs
        first, err = hs.reply(args.timeout)
        server.append(True)
        # the lift reads the proto dump, the live fetches read this harness's
        # state: they must be the same run. Scripts with random values (or a
        # random branch) never trace two runs alike, so instead of requiring a
        # matching trace, lift from THIS run's own dump (code3: 153 "index nil"
        # blocks from reading the first run's tables against the second's)
        served = None
        if first is not None:
            served, _ = trace.take_line(first, "PROTOS")
            if served is not None and served.startswith("error:"):
                served = None
        if served is not None:
            with open(ppath, "w", encoding="utf-8", newline="\n") as f:
                f.write(served)
            synced[0] = True
        elif first is not None and harness.same_trace(harness.trace_text(first), run_text):
            synced[0] = True
        else:
            if first is None:
                print("[!] the long-lived harness failed: %s; running the script once per round instead" % err[-300:], file=sys.stderr)
            else:
                print("[!] the long-lived harness traced differently; running the script once per round instead",
                      file=sys.stderr)
                if os.environ.get("DEOB_SERVE_DIFF"):
                    for nm, tx in (("run", run_text), ("served", harness.trace_text(first))):
                        with open(job.path(".serve_%s.txt" % nm), "w", encoding="utf-8") as f:
                            f.write(tx)
            hs.close()
            server[0] = None    

    def live():
        hs = server[0]
        if hs is None or not synced[0] or os.environ.get("DEOB_NO_FETCH"):
            return None
        def do_fetch(paths, bufs):
            # a single fetch can fail (a constant too big to allocate, or the serve
            # harness having exited). Don't abort the whole lift and don't disable
            # the server on one miss -- just signal "unavailable" for THIS fetch so
            # the walk keeps that one block and resolves the rest. The best lift is
            # still written at the end, and a dead server degrades to per-round reruns.
            try:
                return hs.fetch(paths, bufs, args.timeout)
            except Exception:
                return None
        return do_fetch

    def rerun(c):
        synced[0] = False
        if bridge:
            return runner.run(patched, c, chunks)
        hs = server[0]
        if hs is not None and not server[1]:
            server[1] = True
            first, err = hs.reply(args.timeout)
            if os.environ.get("DEOB_SERVE_DIFF") and first is not None:
                for nm, tx in (("run", run_text), ("served", harness.trace_text(first))):
                    with open(job.path(".serve_%s.txt" % nm), "w", encoding="utf-8") as f:
                        f.write(tx)
            if first is None or not harness.same_trace(harness.trace_text(first), run_text):
                print("[!] the long-lived harness %s; running the script once per round instead"
                      % ("failed: " + err[-300:] if first is None else "traced differently"),
                      file=sys.stderr)
                hs.close()
                hs = server[0] = None
        if hs is not None:
            res = hs.request(c, args.timeout)
            if res[0] is not None:
                synced[0] = True
                return res
            print("[!] the long-lived harness failed: %s; running the script once per round "
                  "instead" % res[1][-300:], file=sys.stderr)
            hs.close()
            server[0] = None
        return runner.run(patched, c, chunks)
    try:
        devirtualize(job, ppath, dpath, cfg, rerun, chunk_paths, live)
    except Exception as e:

        print("[!] devirtualization failed: %s: %s" % (type(e).__name__, e), file=sys.stderr)
        if os.environ.get("DEVIRT_TB"):
            import traceback
            traceback.print_exc()
    finally:
        if server[0] is not None:
            server[0].close()
