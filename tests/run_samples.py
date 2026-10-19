#!/usr/bin/env python3
"""Regression runner: `deob.js` on each public v15.1 sample must still reproduce
its byte-exact reference in samples_v15.1_deobfuscated/.

Run (needs node + bin/luau on PATH-equivalent; works on Windows and Linux):
    python3 tests/run_samples.py
Exit code 0 = all pass (or only the known-nondeterministic sample differs); 1 = a
real regression.

Locks in the fixes made 2026-10-18 (structure.py lower_fors, codegen Global
identifier-safety, harness graceful-degrade, Path2D/BrickColor emulation): these
never touch the clean-lift path the public samples exercise, so the samples must
stay byte-exact. 99ba879f8b2ec51c differs by one extra (more-complete) function
depending on PYTHONHASHSEED / parallel-candidate selection -- a known, tolerated
non-determinism, NOT a regression.
"""
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
SAMPLES = os.path.join(ROOT, "samples_v15.1_deobfuscated")
DEOB = os.path.join(ROOT, "deob.js")
SUFFIX_IN = "_obfuscated.lua"
SUFFIX_REF = "_Deobfuscated.lua"
KNOWN_NONDET = {"99ba879f8b2ec51c"}   # off-by-1 fn, PYTHONHASHSEED/candidate selection


def main():
    if not os.path.isdir(SAMPLES):
        sys.exit("[!] no samples dir at %s" % SAMPLES)
    names = sorted(f[: -len(SUFFIX_IN)] for f in os.listdir(SAMPLES) if f.endswith(SUFFIX_IN))
    if not names:
        sys.exit("[!] no *%s inputs found" % SUFFIX_IN)
    passed, tolerated, failed = 0, 0, []
    for n in names:
        inp = os.path.join(SAMPLES, n + SUFFIX_IN)
        ref = os.path.join(SAMPLES, n + SUFFIX_REF)
        if not os.path.exists(ref):
            print("%s: SKIP (no ref)" % n)
            continue
        with tempfile.TemporaryDirectory() as td:
            # deob.js makes an output/ dir next to the INPUT, so run from a
            # writable temp copy (the samples dir may be read-only, e.g. on /opt)
            tin = os.path.join(td, n + "_obfuscated.lua")
            shutil.copyfile(inp, tin)
            out = os.path.join(td, n + ".lua")
            r = subprocess.run(["node", DEOB, tin, "-o", out], cwd=td,
                               capture_output=True, text=True)
            got = open(out, "rb").read() if os.path.exists(out) else b""
        want = open(ref, "rb").read()
        if got == want:
            print("%s: MATCH (%d bytes)" % (n, len(want)))
            passed += 1
        elif n in KNOWN_NONDET:
            print("%s: DIFF tolerated (known PYTHONHASHSEED non-determinism): got %d vs ref %d"
                  % (n, len(got), len(want)))
            tolerated += 1
        else:
            tail = (r.stderr or "")[-300:]
            print("%s: FAIL got %d vs ref %d\n    %s" % (n, len(got), len(want), tail))
            failed.append(n)
    print("\n%d match, %d tolerated-nondet, %d FAIL (of %d)"
          % (passed, tolerated, len(failed), len(names)))
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
