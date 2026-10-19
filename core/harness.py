import http.server
import json
import os
import queue
import re
import secrets
import subprocess
import sys
import threading
import time
import urllib.request
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
BIN = os.path.join(HERE, "..", "bin") if os.path.exists(os.path.join(HERE, "..", "bin")) else os.path.join(HERE, "bin")
RUNTIME_DIR = os.path.join(HERE, "..", "runtime") if os.path.exists(os.path.join(HERE, "..", "runtime")) else HERE
LUAU_URL = "https://github.com/luau-lang/luau/releases/latest/download/luau-windows.zip"

# Protocol constants shared with the Node driver and the Luau runtime (see
# protocol.json at the repo root and runtime/envlog.luau's PROTO table).
with open(os.path.join(HERE, "..", "protocol.json"), encoding="utf-8") as _pf:
    PROTO = json.load(_pf)

def proto_lua():
    """The PROTO table of runtime/envlog.luau, regenerated from protocol.json
    (build_harness injects it so the runtime always matches this file)."""
    ch = PROTO["chunk_hash"]
    return ("local PROTO = { hash_mult = %d, hash_mod = %d, hash_stride = %d, chunk_min = %d }"
            % (ch["multiplier"], ch["modulus"], ch["stride"], ch["min_len"]))

PROTO_LINE_RE = re.compile(r"local PROTO = \{[^}]*\}")

def _ensure_exec(p):
    if os.name != "nt" and os.path.exists(p) and not os.access(p, os.X_OK):
        try:
            os.chmod(p, 0o755)
        except OSError:
            pass
    return p

def find_luau():
    exe = "luau.exe" if os.name == "nt" else "luau"
    local = os.path.join(BIN, exe)
    if os.path.exists(local):
        return _ensure_exec(local)
    for d in os.environ.get("PATH", "").split(os.pathsep):
        p = os.path.join(d, exe)
        if os.path.exists(p):
            return _ensure_exec(p)
    if os.name != "nt":
        sys.exit("luau not found: build it with `python build_luau.py` (needs git, cmake, a C++ "
                 "compiler) or put one in " + BIN)
    print("[*] downloading Luau runtime...", file=sys.stderr)
    print("[!] stock Luau lacks the Vector3 members (v:Dot, v.Magnitude, ...): build the patched "
          "runtime with `python build_luau.py`", file=sys.stderr)
    os.makedirs(BIN, exist_ok=True)
    zpath = os.path.join(BIN, "luau.zip")
    urllib.request.urlretrieve(LUAU_URL, zpath)
    with zipfile.ZipFile(zpath) as z:
        for name in ("luau.exe", "luau-ast.exe"):
            z.extract(name, BIN)
    os.remove(zpath)
    return local

def luau_ast():
    """Path of luau-ast (prints a file's AST as JSON; decode it as latin-1)."""
    return _ensure_exec(os.path.join(BIN, "luau-ast.exe" if os.name == "nt" else "luau-ast"))

AST_TIMEOUT = 120  # seconds; 1.7 MB scripts parse in seconds, this only guards a hung binary

def run_luau_ast(path):
    """Run luau-ast on `path`; CompletedProcess with .returncode/.stdout/.stderr.
    Raises RuntimeError with an actionable message when the binary is missing
    or hangs (previously: ENOENT surfaced as a confusing parse error, and a
    hung parse blocked the pipeline forever)."""
    exe = luau_ast()
    if not os.path.exists(exe):
        for d in os.environ.get("PATH", "").split(os.pathsep):
            cand = os.path.join(d, "luau-ast.exe" if os.name == "nt" else "luau-ast")
            if os.path.exists(cand):
                exe = cand
                break
        else:
            raise RuntimeError("luau-ast not found: build it with `python build_luau.py`"
                               " (needs git, cmake, a C++ compiler) or put it in " + BIN)
    try:
        return subprocess.run([exe, path], capture_output=True, timeout=AST_TIMEOUT)
    except subprocess.TimeoutExpired:
        raise RuntimeError("luau-ast timed out after %ss on %s (binary hung or machine overloaded)"
                           % (AST_TIMEOUT, path))

def long_string(s):
    level = 0
    while ("]" + "=" * level + "]") in s:
        level += 1
    eq = "=" * level

    return "[" + eq + "[\n" + s + "]" + eq + "]"

def lua_value(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (list, tuple)):
        return "{" + ", ".join(lua_value(x) for x in v) + "}"
    if isinstance(v, dict):
        # plain-object CFG values (e.g. CFG.readfile_map): quoted keys, same
        # shape as luaValue() in src/harness.js -- str(dict) would emit Python
        # repr ('k': v) which is not valid Lua
        return "{" + ", ".join("[%s] = %s" % (lua_value(k), lua_value(x)) for k, x in v.items()) + "}"
    if isinstance(v, str):
        return '"' + v.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n").replace("\r", "\\r") + '"'
    return str(v)

def parse_cfg_value(v):
    """A `--cfg KEY=VALUE` value: true/false/int/string, `@file:PATH` reads a file."""
    if v.startswith("@file:"):

        with open(v[6:], encoding="utf-8") as f:
            v = f.read().strip()
    return True if v in ("", "true") else False if v == "false" else \
        int(v) if re.fullmatch(r"-?\d+", v) else v

def user_cfg(args, cfg):
    """--cfg KEY=VALUE options on top of cfg (they win over plugin defaults)."""
    for kv in args.cfg:
        k, _, v = kv.partition("=")
        cfg[k] = parse_cfg_value(v)
    return cfg

P2D_CACHE = {}

def p2d_cache_path(input_path):
    return re.sub(r"(\.luau?|\.txt)?$", ".path2d", input_path, count=1)

def load_p2d_cache(input_path, studio=False):
    """Path2D answers recorded by an earlier --studio run of this script."""
    cache_path = p2d_cache_path(input_path)
    if os.path.exists(cache_path):
        with open(cache_path, encoding="utf-8") as f:
            for line in f:
                k, _, v = line.rstrip("\n").partition("\t")
                if k:
                    P2D_CACHE[k] = v
        if not studio:
            print("[*] replaying %d recorded Path2D results from %s" % (len(P2D_CACHE), cache_path), file=sys.stderr)
    return cache_path

def take_p2d(body, cache_path, studio):
    """Strip the \\0P2D lines of a run; engine answers from Studio go to the cache file."""
    rec = re.findall(mark("P2D ") + r"([^\t\n]+)\t([^\n]*)\n", body)
    body = re.sub(mark("P2D ") + r"[^\n]*\n", "", body)
    nmodel = sum(1 for k, v in rec if v.endswith("\tmodel"))
    if nmodel:
        print("[*] %d Path2D answers computed by the offline engine model" % nmodel, file=sys.stderr)
    rec = [(k, v) for k, v in rec if not v.endswith("\tmodel")]
    if rec and studio:
        for k, v in rec:
            P2D_CACHE[k] = v
        with open(cache_path, "w", encoding="utf-8", newline="\n") as f:
            f.write("".join("%s\t%s\n" % kv for kv in P2D_CACHE.items()))
    return body

def p2d_miss(body, cache_path):
    if mark("P2DMISS") not in body:
        return body
    print("[!] this script derives keys from a Path2D call the offline model does not cover\n"
          "    (e.g. a Frame sized with Scale); run it once with --studio (writes %s)" % cache_path,
          file=sys.stderr)
    return body.replace(mark("P2DMISS") + "\n", "")

# The analyzed script can climb the Lua stack with getfenv(2+) from inside any
# callback the harness calls into (and from the runner coroutine body), so
# every harness closure it can reach must not carry the real globals: a shield
# environment (stdlib only, no loadstring/getfenv/setfenv/_G) is set on the
# function wrapping the runtime below. Sensitive values (__MARK, __SOURCE, ...)
# are parameters of that wrapper, i.e. upvalues -- getfenv only hands out
# environment tables, so they stay invisible. The outer chunk's own frames are
# unreachable: getfenv levels cannot cross the coroutine resume boundary.
SHIELD_STDLIB = """{
        string = string, math = math, table = table, os = os, debug = debug,
        coroutine = coroutine, bit32 = bit32, buffer = buffer, utf8 = utf8, vector = vector,
        type = type, typeof = typeof, pairs = pairs, ipairs = ipairs, next = next,
        select = select, rawget = rawget, rawset = rawset, rawequal = rawequal,
        rawlen = rawlen, setmetatable = setmetatable, getmetatable = getmetatable,
        tostring = tostring, tonumber = tonumber, error = error, assert = assert, print = print,
        pcall = pcall, xpcall = xpcall, unpack = table.unpack, newproxy = newproxy,
}"""

def build_harness(source, cfg, chunks=None):
    with open(os.path.join(RUNTIME_DIR, "envlog.luau"), encoding="utf-8") as f:
        runtime = f.read()
    cfg_lua = "{" + ", ".join("%s = %s" % (k, lua_value(v)) for k, v in cfg.items()) + "}"

    runtime = runtime.replace("--!nocheck", "", 1)
    # PROTO constants: always inject the current protocol.json values so the
    # runtime can never drift from the drivers (the baked-in defaults are a
    # fallback for standalone Studio runs; protocol_test.py keeps them equal).
    if not PROTO_LINE_RE.search(runtime):
        raise RuntimeError("runtime/envlog.luau lost its `local PROTO = {...}` line; "
                           "restore it (see protocol.json)")
    runtime = PROTO_LINE_RE.sub(proto_lua(), runtime, count=1)
    with open(os.path.join(RUNTIME_DIR, "unicode_data.luau"), encoding="ascii") as f:
        udata = f.read()
    with open(os.path.join(RUNTIME_DIR, "roblox_api.luau"), encoding="ascii") as f:
        rdata = f.read()
    with open(os.path.join(RUNTIME_DIR, "datatypes.luau"), encoding="utf-8") as f:
        dtypes = f.read().replace("--!nocheck", "", 1)
    LAST_MARK[0] = secrets.token_hex(PROTO["nonce_hex_bytes"])
    return ("local __STDLIB = " + SHIELD_STDLIB + "\n"
            "local __SHIELD = setmetatable({}, { __index = __STDLIB })\n"
            "local __UNICODE = (function()\n" + udata + "\nend)()\n"
            "local __ROBLOX = (function()\n" + rdata + "\nend)()\n"
            "__ROBLOX.datatypes = (function()\n" + dtypes + "\nend)()\n"
            "local __RAW = { getfenv = getfenv, setfenv = setfenv, loadstring = loadstring }\n"
            "local __RUN = function(__MARK, __SOURCE, __CONFIG, __P2D, __CHUNKS, __UNICODE, __ROBLOX, __RAW)\n"
            + runtime + "\n"
            "end\n"
            "setfenv(__RUN, __SHIELD)\n"
            "return __RUN(" + lua_value(LAST_MARK[0]) + ", " + long_string(source) + ", " + cfg_lua + ",\n"
            "  {" + "".join("[%s] = %s,\n" % (lua_value(k), lua_value(v))
                             for k, v in P2D_CACHE.items()) + "},\n"
            "  {" + "".join("[%s] = %s,\n" % (lua_value(k), long_string(v))
                             for k, v in (chunks or {}).items()) + "}, __UNICODE, __ROBLOX, __RAW)\n")

def chunk_key(src):
    """Same key as srcKey() in envlog.luau (parameters from protocol.json; the
    only Python definition -- devirt.py imports this one)."""
    h = 0
    for b in src.encode("latin-1"):
        h = (h * PROTO["chunk_hash"]["multiplier"] + b) % PROTO["chunk_hash"]["modulus"]
    return "%d_%d" % (len(src), h)

def take_chunks(body):
    """[(key, source)] of the big loadstring'd chunks a run reported (\\0CHUNK),
    and the body without them. Chunks passed back in `chunks` run instead of
    the original (a plugin instruments them like the main script)."""
    found = re.findall(mark("CHUNK ") + r"(\S+)\n([0-9a-f]*)\n", body)
    body = re.sub(mark("CHUNK ") + r"\S+\n[0-9a-f]*\n", "", body)
    return [(k, bytes.fromhex(hx).decode("latin-1")) for k, hx in found], body

LAST_RAW = [""]     

LAST_MARK = [""]    # per-run protocol nonce (see envlog.luau MARK); set by build_harness

def mark(s):
    """The \0-protocol line prefix of the current run. The runtime prefixes
    every marker with a per-run nonce the analyzed script never learns, so
    output the script controls (a leaked raw print, crafted error strings)
    cannot forge protocol lines the drivers parse."""
    return "\x00" + LAST_MARK[0] + s

HEARTBEAT = PROTO["heartbeat_seconds"]
STALL = PROTO["stall_seconds"]

def _communicate(cmd, timeout, stall):
    """subprocess.run(capture_output=True) that also gives up when the process
    prints nothing for `stall` seconds (the runtime's heartbeat stopped: the
    script spins without touching the environment). (stdout, stderr) bytes,
    or a TimeoutExpired."""
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    parts = {1: [], 2: []}
    last = [time.time()]

    def pump(stream, key):
        while True:
            b = stream.read1(65536) if hasattr(stream, "read1") else stream.read(65536)
            if not b:
                return
            parts[key].append(b)
            last[0] = time.time()
    threads = [threading.Thread(target=pump, args=(proc.stdout, 1), daemon=True),
               threading.Thread(target=pump, args=(proc.stderr, 2), daemon=True)]
    for t in threads:
        t.start()
    t0 = time.time()
    try:
        while proc.poll() is None:
            now = time.time()
            if now - t0 > timeout or (stall and now - last[0] > stall):
                proc.kill()
                proc.wait()
                raise subprocess.TimeoutExpired(cmd, now - t0)
            time.sleep(0.1)
    finally:
        for t in threads:
            t.join(5)
    return b"".join(parts[1]), b"".join(parts[2])

def run_once(luau, source, cfg, hpath, timeout, keep, chunks=None):
    cfg = dict(cfg, heartbeat=HEARTBEAT) if "heartbeat" not in cfg else cfg
    with open(hpath, "w", encoding="latin-1", newline="\n") as f:
        f.write(build_harness(source, cfg, chunks))
    try:
        out, errb = _communicate([luau, hpath], timeout, STALL if cfg.get("heartbeat") else None)
    except subprocess.TimeoutExpired as e:
        return None, "timed out after %ds (script is stuck in a loop the tracer cannot see)" % e.timeout
    finally:
        if not keep and os.path.exists(hpath):
            os.remove(hpath)
    stdout = re.sub(mark("HB") + r"\r?\n {16384}\r?\n", "", out.decode("utf-8", "replace")).replace("\r\n", "\n")
    LAST_RAW[0] = stdout + errb.decode("utf-8", "replace")
    m = re.search(mark("ENVLOG-BEGIN") + r"\n(.*?)" + mark("ENVLOG-END"), stdout, re.S)
    if not m:
        return None, stdout[-3000:] + "\n" + errb.decode("utf-8", "replace")[-3000:]

    body = m.group(1)
    for hp in {hpath, hpath.replace("\\", "/")}:
        if hp + ":" in body:
            body = re.sub(re.escape(hp) + r":\d+: ", "", body)
    return body, None

def save_raw(path):
    if path:
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            f.write(LAST_RAW[0])

class HarnessServer:
    """One harness process kept alive for many dumps: the script runs once,
    then each request only repeats the dump for new force_req / force_buf
    (CHAIN.serve in envlog.luau). luau.exe has no file or stdin API,
    but its REPL reads statements from stdin and require() reads files: the
    harness is require()d (it returns CHAIN.serve) and every request is a small
    module holding the long strings, called by a one-line statement.
    Its output is read in raw chunks up to the ENVLOG-END sentinel: stdout to a
    pipe is block-buffered, and the padding the harness prints after the
    sentinel only pushes the buffer out."""

    def __init__(self, luau, source, cfg, chunks):
        import tempfile
        _ensure_exec(luau)
        self.dir = tempfile.mkdtemp(prefix="deobf_serve_")
        with open(os.path.join(self.dir, "harness.luau"), "w", encoding="latin-1", newline="\n") as f:
            f.write(build_harness(source, dict(cfg, serve=True), chunks))
        self.END = mark("ENVLOG-END").encode()   # after build_harness: same nonce
        self.proc = subprocess.Popen([luau], cwd=self.dir, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                     stderr=subprocess.STDOUT)
        self.buf = b""
        self.eof = False
        self.nreq = 0

        self.deadline = None
        self.timed_out = False
        threading.Thread(target=self._watchdog, daemon=True).start()

        self._send(b'__S = require("./harness")\n__S("", "", "start")\n')

    def _watchdog(self):
        while self.proc.poll() is None:
            d = self.deadline
            if d is not None and time.time() > d:
                self.timed_out = True
                self.proc.kill()
                return
            time.sleep(0.25)

    def _send(self, line):
        try:
            self.proc.stdin.write(line)
            self.proc.stdin.flush()
        except OSError:
            pass    

    def reply(self, timeout):
        """The next response (the text between ENVLOG-BEGIN and ENVLOG-END), or
        (None, error)."""
        self.deadline = time.time() + timeout
        try:
            start = 0
            while self.END not in self.buf[start:]:
                start = max(0, len(self.buf) - len(self.END))
                b = b"" if self.eof else self.proc.stdout.read1(1 << 20)
                if not b:
                    self.eof = True
                    out = self.buf.decode("utf-8", "replace")
                    self.close()
                    return None, ("no reply within %ds" % timeout if self.timed_out else
                                  "harness process exited") + ": " + out[-3000:]
                self.buf += b
        finally:
            self.deadline = None
        i = self.buf.index(self.END) + len(self.END)
        out, self.buf = self.buf[:i], self.buf[i:]
        out = out.decode("utf-8", "replace").replace("\r\n", "\n")
        LAST_RAW[0] = out
        m = re.search(mark("ENVLOG-BEGIN") + r"\n(.*?)" + mark("ENVLOG-END"), out, re.S)
        if not m:
            return None, out[-3000:]
        return m.group(1), None

    def request(self, cfg, timeout, mode="dump"):
        # the process may have died on a previous reply (e.g. a constant request
        # too big to allocate), which also removed self.dir; don't crash the whole
        # run trying to use a dead server -- let the caller fall back / keep the
        # best lift so far.
        if self.eof or self.proc.poll() is not None or not os.path.isdir(self.dir):
            return None, "harness process exited"
        req, buf = cfg.get("force_req") or "", cfg.get("force_buf") or ""
        if len(req) + len(buf) < 2000 and re.fullmatch(r"[\w,@.;=+/:*\-]*", req + buf):

            self._send(('__S("%s", "%s", "%s")\n' % (req, buf, mode)).encode())
            return self.reply(timeout)
        self.nreq += 1
        name = "req_%d" % self.nreq
        # the server process can die mid-run (a constant request that crashes or
        # OOMs the luau), and its temp dir may already be gone; writing the req
        # file then raises FileNotFoundError and used to abort the whole devirt.
        # Degrade to the normal "process exited" path so the caller falls back to
        # per-round reruns / keeps the best lift so far.
        try:
            with open(os.path.join(self.dir, name + ".luau"), "w", encoding="utf-8", newline="\n") as f:
                f.write("return {%s, %s, %s}\n" % (long_string(cfg.get("force_req") or ""),
                                                  long_string(cfg.get("force_buf") or ""), long_string(mode)))
        except OSError as e:
            self.eof = True
            return None, "harness temp dir gone (%s)" % e
        self._send(b'__S(table.unpack(require("./%s")))\n' % name.encode())
        return self.reply(timeout)

    def fetch(self, paths, bufs, timeout):
        """Constants decoded right away, in the session of the last dump
        (CHAIN.fetch): JSON {"values": [[path, value]], "tables": {...}}."""
        body, err = self.request({"force_req": ";".join(paths), "force_buf": bufs}, timeout, "fetch")
        if body is None:
            raise RuntimeError("harness fetch failed: " + err[-300:])
        m = re.search(mark("FETCH ") + r"([^\n]*)\n", body)
        if not m or m.group(1).startswith("error:"):
            raise RuntimeError("harness fetch failed: " + (m.group(1)[:300] if m else body[-300:]))
        return m.group(1)

    def close(self):
        if self.proc.poll() is None:
            self.proc.kill()
            self.proc.wait()
        import shutil
        shutil.rmtree(self.dir, ignore_errors=True)

def trace_text(body):
    """The shape of a run's trace, to tell whether two runs behaved the same:
    no machine-readable lines, and string/number literals masked (scripts
    that use random values trace differently every run; a wrong key
    changes what runs, not just literals)."""
    body = re.sub(r"\x00[0-9a-f]{8,32}CHUNK \S+\n[0-9a-f]*\n", "", body)
    body = re.sub(r"\x00[0-9a-f]{8,32}(PROTOS|FORCE|P2D|TRIGGER)[^\n]*\n?", "", body)

    body = re.sub(r"(?<=[ \t])(?=\S)(?:[A-Za-z]:)?[^:\n]*?\.luau:", "harness:", body)
    body = re.sub(r"harness:\d+: ", "", body)
    body = re.sub(r'"(?:[^"\\\n]|\\.)*"', '""', body)
    # the sign too: random offsets trace as "-3" in one run and "5" in the next
    # (code3: the long-lived harness was dropped for one "-0" vs "0")
    return re.sub(r"-?\d+(?:\.\d+)?(?:e[-+]?\d+)?", "0", body)

def same_trace(a, b):
    """trace_text(a) == trace_text(b), ignoring words only one of the two
    runs has: scripts that make up random names every run (diaz.txt:
    getgenv() keys, bait URLs) trace the same statements with other names
    (in another order too: pairs() over other keys). Last resort: the same
    lines in any order, local names masked."""
    if a == b:
        return True
    wa, wb = set(re.findall(r"\w+", a)), set(re.findall(r"\w+", b))
    only = (wa ^ wb)
    mask = lambda t: re.sub(r"\w+", lambda m: "_" if m.group(0) in only else m.group(0), t)  
    ma, mb = mask(a), mask(b)
    if ma == mb:
        return True

    decl = r"\blocal\s+([\w ,]+)|\bfor\s+([\w ,]+)\bin\b|\bfunction\s*\w*\s*\(([\w ,.]*)\)"
    names = set()
    for m in re.finditer(decl, a + "\n" + b):
        names.update(re.findall(r"\w+", "".join(g or "" for g in m.groups())))
    anon = lambda t: sorted(re.sub(r"\w+", lambda m: "_" if m.group(0) in names else m.group(0), t)  
                            .splitlines())
    return anon(ma) == anon(mb)

STUDIO_LOADER = r"""-- deobf Studio loader: run in the Studio command bar (Edit mode).
-- Fetches each harness from deob.py, runs it natively and posts the trace back.
-- HTTP is only on while talking to 127.0.0.1 (never while the script runs)
-- and is restored to its previous setting at the end.
local HS = game:GetService("HttpService")
local base = "http://127.0.0.1:%d"
local was = HS.HttpEnabled
HS.HttpEnabled = true
local ok0, err0 = pcall(function()
        while true do
                local src = HS:GetAsync(base .. "/harness", true)
                if src == "" then break end
                HS.HttpEnabled = false
                local f, err = loadstring(src, "=harness")
                local ok, out = false, err
                if f then ok, out = pcall(f) end
                HS.HttpEnabled = true
                out = ok and tostring(out) or ("\0ENVLOG-FAIL\n" .. tostring(out))
                -- HttpService posts are limited to 1 MB: send in parts
                local n = math.max(1, math.ceil(#out / 900000))
                for i = 1, n do
                        HS:PostAsync(base .. "/result?part=" .. i .. "&of=" .. n, string.sub(out, (i - 1) * 900000 + 1, i * 900000),
                                Enum.HttpContentType.TextPlain)
                end
        end
end)
HS.HttpEnabled = was
return ok0 and "deobf: done" or ("deobf loader error: " .. tostring(err0))
"""

class StudioBridge:
    """Local HTTP endpoint the Studio loader talks to. GET /harness blocks until
    the next harness is ready ("" when finished); POST /result takes the trace."""

    def __init__(self, port):
        self.jobs = queue.Queue()
        self.results = queue.Queue()
        self.parts = []
        bridge = self

        class Handler(http.server.BaseHTTPRequestHandler):
            def log_message(self, *a):
                pass

            def do_GET(self):
                if self.path != "/harness":
                    self.send_error(404)
                    return
                body = bridge.jobs.get()
                self.send_response(200)
                self.send_header("Content-Type", "text/plain")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)

            def do_POST(self):
                data = self.rfile.read(int(self.headers.get("Content-Length", 0)))
                self.send_response(200)
                self.send_header("Content-Length", "0")
                self.end_headers()
                m = re.search(r"part=(\d+)&of=(\d+)", self.path)
                part, of = (int(m.group(1)), int(m.group(2))) if m else (1, 1)
                bridge.parts.append(data)
                if part == of:
                    bridge.results.put(b"".join(bridge.parts))
                    bridge.parts = []

        self.server = http.server.ThreadingHTTPServer(("127.0.0.1", port), Handler)
        threading.Thread(target=self.server.serve_forever, daemon=True).start()

    def run(self, harness, timeout):
        self.jobs.put(harness.encode("latin-1"))
        try:
            return self.results.get(timeout=timeout).decode("utf-8", "replace")
        except queue.Empty:
            return None

    def finish(self):
        self.jobs.put(b"")
        time.sleep(1)  

def run_once_studio(bridge, source, cfg, timeout, chunks=None):
    out = bridge.run(build_harness(source, dict(cfg, native=True), chunks), timeout)
    if out is None:
        return None, "no result from Studio within %ds (is the loader running?)" % timeout
    out = out.replace("\r\n", "\n")
    LAST_RAW[0] = out
    # ENVLOG-FAIL here is emitted by the Studio loader itself (it cannot know
    # the per-run nonce); it only fires when the harness chunk failed to load
    # or run at all, so the analyzed script can never produce it.
    if out.startswith("\x00ENVLOG-FAIL"):
        return None, "harness failed in Studio: " + out[len("\x00ENVLOG-FAIL\n"):]
    m = re.search(mark("ENVLOG-BEGIN") + r"\n(.*?)" + mark("ENVLOG-END"), out, re.S)
    if not m:
        return None, out[-3000:]
    return m.group(1), None

class Runner:
    """Runs harnesses for one job: offline with luau.exe, or in Studio with
    --studio (writes the loader next to the output and waits for it)."""

    def __init__(self, job):
        self.job = job
        args = job.args
        self.bridge = None
        self.luau = None
        self.hpath = job.trace_path + ".harness.luau"
        if args.studio:
            self.bridge = StudioBridge(args.port)
            lpath = re.sub(r"\.luau$", "", job.trace_path) + ".studio_loader.luau"
            with open(lpath, "w", encoding="utf-8", newline="\n") as f:
                f.write(STUDIO_LOADER % args.port)
            print("[*] Studio mode: run %s in the Studio command bar (Edit mode)" % lpath, file=sys.stderr)
        else:
            self.luau = find_luau()

    def run(self, source, cfg, chunks=None):
        """(body, None) or (None, error)."""
        a = self.job.args
        if self.bridge:
            return run_once_studio(self.bridge, source, cfg, a.studio_wait, chunks)
        return run_once(self.luau, source, cfg, self.hpath, a.timeout, a.keep_harness, chunks)

    def finish(self):
        if self.bridge:
            self.bridge.finish()
            self.bridge = None
