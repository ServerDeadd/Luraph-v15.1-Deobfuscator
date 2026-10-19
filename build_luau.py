"""
Builds bin/luau and bin/luau-ast from Luau source with one patch: the vector
type's metatable is left writable (stock Luau freezes it in lveclib.cpp).

In Roblox, Vector3 *is* the native vector type and the engine gives it a
metatable with the Vector3 members (Magnitude, Unit, Dot, Cross, Lerp, ...).
envlog.luau installs the same members on the local VM's vector metatable;
with a stock (frozen) build, `v:Dot(w)` or `v.Magnitude` on a Vector3 value
fails with "attempt to index vector with 'Dot'".

Needs git, cmake and a C++ compiler (MSVC via a developer prompt, or gcc,
e.g. MSYS2's; Ninja is used when installed).
    python build_luau.py [--tag 0.739] [--src DIR] [--portable] [--jobs N]
"""
import argparse
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
BIN = os.path.join(HERE, "bin")
REPO = "https://github.com/luau-lang/luau.git"
TAG = "0.739"
FREEZE = "    lua_setreadonly(L, -1, true);\n    lua_pop(L, 1); // pop the metatable\n"
PATCHED = "    // deobf: left writable, envlog.luau adds Roblox's Vector3 members\n    lua_pop(L, 1); // pop the metatable\n"
TARGETS = ("Luau.Repl.CLI", "Luau.Ast.CLI")  # luau, luau-ast


def run(cmd, cwd=None):
    print("[*] " + " ".join(cmd), file=sys.stderr)
    subprocess.run(cmd, cwd=cwd, check=True)


def patch(src):
    path = os.path.join(src, "VM", "src", "lveclib.cpp")
    with open(path, encoding="utf-8") as f:
        text = f.read()
    if PATCHED not in text:
        if text.count(FREEZE) != 1:
            sys.exit("[!] lveclib.cpp changed upstream: patch createmetatable() by hand")
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            f.write(text.replace(FREEZE, PATCHED))

    # Patch lstate.cpp, ldo.h, ldo.cpp so harness/C frames at the Lua/C stack
    # ceiling (LUAI_MAXCALLS / LUAI_MAXCCALLS) do not trigger false stack
    # overflows during Luraph v15.1 stack-ceiling hook probes.
    lstate_path = os.path.join(src, "VM", "src", "lstate.cpp")
    with open(lstate_path, encoding="utf-8") as f:
        st = f.read()
    if "BASIC_CI_SIZE + 128" not in st:
        st = st.replace(
            "L1->base_ci = luaM_newarray(L, BASIC_CI_SIZE, CallInfo, L1->memcat);",
            "L1->base_ci = luaM_newarray(L, BASIC_CI_SIZE + 128, CallInfo, L1->memcat);",
        )
        st = st.replace(
            "luaM_freearray(L, L1->base_ci, L1->size_ci, CallInfo, L1->memcat);",
            "luaM_freearray(L, L1->base_ci, L1->size_ci + 128, CallInfo, L1->memcat);",
        )
        with open(lstate_path, "w", encoding="utf-8", newline="\n") as f:
            f.write(st)

    ldoh_path = os.path.join(src, "VM", "src", "ldo.h")
    with open(ldoh_path, encoding="utf-8") as f:
        dh = f.read()
    if "L->ci >= L->end_ci" not in dh:
        dh = dh.replace(
            "#define incr_ci(L) ((L->ci == L->end_ci) ? luaD_growCI(L) : (condhardstacktests(luaD_reallocCI(L, L->size_ci)), ++L->ci))",
            "#define incr_ci(L) ((L->ci >= L->end_ci) ? luaD_growCI(L) : (condhardstacktests(luaD_reallocCI(L, L->size_ci)), ++L->ci))",
        )
        dh = dh.replace(
            "#define saveci(L, p) check_exp((p) >= L->base_ci && (p) <= L->base_ci + L->size_ci, (char*)(p) - (char*)L->base_ci)",
            "#define saveci(L, p) check_exp((p) >= L->base_ci && (p) <= L->base_ci + L->size_ci + 128, (char*)(p) - (char*)L->base_ci)",
        )
        dh = dh.replace(
            "#define restoreci(L, n) check_exp((n) >= 0 && (size_t)(n) <= sizeof(CallInfo) * L->size_ci, (CallInfo*)((char*)L->base_ci + (n)))",
            "#define restoreci(L, n) check_exp((n) >= 0 && (size_t)(n) <= sizeof(CallInfo) * (L->size_ci + 128), (CallInfo*)((char*)L->base_ci + (n)))",
        )
        with open(ldoh_path, "w", encoding="utf-8", newline="\n") as f:
            f.write(dh)

    ldo_path = os.path.join(src, "VM", "src", "ldo.cpp")
    with open(ldo_path, encoding="utf-8") as f:
        dc = f.read()
    if "L->size_ci + 128" not in dc:
        dc = dc.replace(
            "luaM_reallocarray(L, L->base_ci, L->size_ci, newsize, CallInfo, L->memcat);",
            "luaM_reallocarray(L, L->base_ci, L->size_ci + 128, newsize + 128, CallInfo, L->memcat);",
        )
        dc = dc.replace(
            "CallInfo* luaD_growCI(lua_State* L)",
            """static bool is_harness_closure(Closure* cl)
{
    if (!cl)
        return false;
    if (cl->isC)
        return true;
    if (!cl->l.p || !cl->l.p->source)
        return false;
    const char* s = getstr(cl->l.p->source);
    return strstr(s, "harness") != nullptr || strstr(s, "envlog") != nullptr ||
           strcmp(s, "=prelude") == 0 || strcmp(s, "=plugin_rt") == 0;
}

CallInfo* luaD_growCI(lua_State* L)""",
        )
        dc = dc.replace(
            "    if (L->size_ci >= hardlimit)\n        luaD_throw(L, LUA_ERRERR); // error while handling stack error",
            """    if (L->size_ci >= LUAI_MAXCALLS && L->ci >= L->base_ci && L->ci < L->base_ci + L->size_ci + 120)
    {
        Closure* cl = (L->ci->func && ttisfunction(L->ci->func)) ? clvalue(L->ci->func) : nullptr;
        if (is_harness_closure(cl))
            return ++L->ci;
    }

    if (L->size_ci >= hardlimit)
        luaD_throw(L, LUA_ERRERR); // error while handling stack error""",
        )
        dc = dc.replace(
            "    if (L->nCcalls == LUAI_MAXCCALLS)\n        luaG_runerror(L, \"C stack overflow\");",
            """    if (L->nCcalls == LUAI_MAXCCALLS)
    {
        if (L->ci > L->base_ci)
        {
            Closure* cl = (L->ci->func && ttisfunction(L->ci->func)) ? clvalue(L->ci->func) : nullptr;
            if (is_harness_closure(cl))
                return;
        }
        luaG_runerror(L, "C stack overflow");
    }""",
        )
        dc = dc.replace(
            "    L->baseCcalls = ++L->nCcalls;",
            "    L->baseCcalls = from ? ++L->nCcalls : 0;",
        )
        dc = dc.replace(
            "    L->nCcalls = oldnCcalls - 1;",
            "    L->nCcalls = oldnCcalls > 0 ? oldnCcalls - 1 : 0;",
        )
        with open(ldo_path, "w", encoding="utf-8", newline="\n") as f:
            f.write(dc)

    # NOTE (2026-10-18): the LUAI_MAXCALLS 20000->40000 raise was REVERTED. Real
    # Roblox Luau caps non-tail recursion at exactly 19997 (= stock LUAI_MAXCALLS
    # 20000), and v15.1's stack-ceiling probe is a FINGERPRINT of that stock limit:
    # a 40000 ceiling makes the sandbox recurse past 19997 where real Roblox stops,
    # DIVERGING from the engine. It did not help (h1 self-destructs on an unrelated
    # check regardless) and it REGRESSED scripts that probe the ceiling (sample
    # 2153 -> 728KB garbage instead of the correct 372-byte output). Keep stock.
    _RAISE_MAXCALLS = False
    import re as _re
    conf_path = os.path.join(src, "VM", "include", "luaconf.h")
    if _RAISE_MAXCALLS and os.path.exists(conf_path):
        with open(conf_path, encoding="utf-8") as f:
            cf = f.read()
        m = _re.search(r"#define\s+LUAI_MAXCALLS\s+(\d+)", cf)
        if m and int(m.group(1)) < 40000:
            cf = cf[:m.start()] + "#define LUAI_MAXCALLS 40000" + cf[m.end():]
            with open(conf_path, "w", encoding="utf-8", newline="\n") as f:
                f.write(cf)
            print("[+] raised LUAI_MAXCALLS %s -> 40000" % m.group(1), file=sys.stderr)


def fetch_binary(build, exe, name):
    for cand in (os.path.join(build, "Release", exe), os.path.join(build, exe)):
        if os.path.exists(cand):
            os.makedirs(BIN, exist_ok=True)
            dest = os.path.join(BIN, name)
            shutil.copy2(cand, dest)
            print("[+] wrote " + dest, file=sys.stderr)
            return True
    return False


def build_direct_gcc(src, jobs, portable):
    import concurrent.futures
    import glob

    opt = ["-O3", "-DNDEBUG"] + ([] if portable else ["-march=native"])
    inc = [
        "-ICommon/include", "-IAst/include", "-IBytecode/include", "-IBytecode/src",
        "-IInliner/include", "-IInliner/src", "-ICompiler/include", "-IConfig/include",
        "-ICodeGen/include", "-IVM/include", "-IVM/src", "-IRequire/include",
        "-IRequire/src", "-ICLI/include", "-Iextern", "-Iextern/isocline/include",
    ]
    cpp_dirs = [
        "Common/src", "Ast/src", "Bytecode/src", "Inliner/src", "Compiler/src",
        "Config/src", "CodeGen/src", "VM/src", "Require/src",
    ]
    cli_files = [
        "CLI/src/FileUtils.cpp", "CLI/src/Flags.cpp", "CLI/src/VfsNavigator.cpp",
        "CLI/src/Counters.cpp", "CLI/src/Coverage.cpp", "CLI/src/Profiler.cpp",
        "CLI/src/Repl.cpp", "CLI/src/ReplEntry.cpp", "CLI/src/ReplRequirer.cpp",
    ]
    cpp_files = []
    for d in cpp_dirs:
        cpp_files.extend(sorted(glob.glob(os.path.join(src, d, "*.cpp"))))
    cpp_files.extend(os.path.join(src, f) for f in cli_files)
    c_file = os.path.join(src, "extern/isocline/src/isocline.c")

    obj_dir = os.path.join(src, "build-gcc-objs")
    os.makedirs(obj_dir, exist_ok=True)

    tasks = []
    objs = []
    for f in cpp_files:
        rel = os.path.relpath(f, src).replace("/", "_").replace("\\", "_")
        obj = os.path.join(obj_dir, rel + ".o")
        objs.append(obj)
        if not os.path.exists(obj) or os.path.getmtime(f) > os.path.getmtime(obj):
            cmd = ["g++", "-std=c++17", "-fno-math-errno", "-Wno-unused", "-Wno-maybe-uninitialized"] + opt + inc + ["-c", f, "-o", obj]
            tasks.append(cmd)
    c_obj = os.path.join(obj_dir, "isocline.o")
    objs.append(c_obj)
    if not os.path.exists(c_obj) or os.path.getmtime(c_file) > os.path.getmtime(c_obj):
        tasks.append(["gcc", "-Wno-unused-function"] + opt + inc + ["-c", c_file, "-o", c_obj])

    print(f"[*] compiling {len(tasks)} source files with {jobs} jobs...", file=sys.stderr)
    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as ex:
        futs = [ex.submit(subprocess.run, cmd, cwd=src, check=True) for cmd in tasks]
        for fut in futs:
            fut.result()

    os.makedirs(BIN, exist_ok=True)
    exe = os.path.join(BIN, "luau.exe" if os.name == "nt" else "luau")
    run(["g++"] + opt + objs + ["-lpthread", "-lm", "-o", exe], cwd=src)
    print("[+] wrote " + exe, file=sys.stderr)


def main():
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument("--tag", default=TAG, help="Luau release tag (default %(default)s)")
    ap.add_argument("--src", help="existing checkout to use (default: fresh clone in a temp folder)")
    ap.add_argument("--portable", action="store_true",
                    help="gcc: no -march=native (for a binary copied to another machine)")
    ap.add_argument("--jobs", type=int, default=os.cpu_count() or 2,
                    help="parallel build jobs (default: CPU count)")
    args = ap.parse_args()
    tmp = None
    src = args.src
    if not src:
        tmp = tempfile.mkdtemp(prefix="luau-build-")
        src = os.path.join(tmp, "luau")
        run(["git", "clone", "-q", "--depth", "1", "--branch", args.tag, REPO, src])
    patch(src)
    if not shutil.which("cmake") and shutil.which("g++"):
        build_direct_gcc(src, args.jobs, args.portable)
        if tmp:
            shutil.rmtree(tmp, ignore_errors=True)
        return
    build = os.path.join(src, "build-deobf")
    cfg = ["cmake", "-S", src, "-B", build, "-DCMAKE_BUILD_TYPE=Release",
           "-DLUAU_BUILD_TESTS=OFF", "-DLUAU_STATIC_CRT=ON"]
    if shutil.which("ninja"):
        cfg += ["-G", "Ninja"]
    if not shutil.which("cl") and shutil.which("g++"):
        # MinGW/Linux gcc; static so the binary needs no compiler runtime DLLs.
        # Plain -O3 ran the pipeline ~30% slower than the official MSVC build;
        # with -march=native + LTO it is a bit faster (fetched.lua 33 s vs 35 s).
        opt = "-O3 -flto" + ("" if args.portable else " -march=native")
        cfg += ["-DCMAKE_C_COMPILER=gcc", "-DCMAKE_CXX_COMPILER=g++",
                "-DCMAKE_C_FLAGS_RELEASE=%s -DNDEBUG" % opt,
                "-DCMAKE_CXX_FLAGS_RELEASE=%s -DNDEBUG" % opt,
                "-DCMAKE_EXE_LINKER_FLAGS=-static " + opt]
    run(cfg)
    for target, exe in zip(TARGETS, ("luau.exe" if os.name == "nt" else "luau",
                                     "luau-ast.exe" if os.name == "nt" else "luau-ast")):
        run(["cmake", "--build", build, "--config", "Release", "--target", target,
             "--parallel", str(args.jobs)])
        if not fetch_binary(build, exe, exe):
            sys.exit("[!] built binary not found under " + build)
    if tmp:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main()
