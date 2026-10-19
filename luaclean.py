"""Remove Luraph leftover junk from devirtualized Luau, using the real AST (luau-ast).

Deletes, to a fixpoint, only statements that provably do nothing:
  * expression statements that are pure calls  (bit32.bxor(n, 3), type(123), table.pack(...))
  * `local x, y = <pure>` whose locals are never read (outside the statement itself)
  * `x = <pure>` / `x += <pure>` to locals that are never read
  * `if <pure> then end` with empty bodies, empty `do end` blocks
  * `local function f` never referenced
"Pure" = constants, locals, arithmetic/compare/logic on pure values, bit32.* / math.* /
table.pack / type / typeof calls on pure args, indexing a local with a constant.

usage: python luaclean.py <luau-ast.exe> <in.lua> <out.lua>
"""
import bisect, json, re, subprocess, sys

ast_exe, src_path, out_path = sys.argv[1:4]
sys._luaclean_nested = "--once" in sys.argv[4:]
src = open(src_path, "rb").read()
proc = subprocess.run([ast_exe, src_path], capture_output=True)
if proc.returncode:
    sys.exit("luau-ast failed: " + proc.stderr.decode("latin1")[:500])
root = json.loads(proc.stdout.decode("utf-8", "replace"))["root"]

line_starts = [0]
for i, b in enumerate(src):
    if b == 10:
        line_starts.append(i + 1)

def span(node):
    a, b = node["location"].split(" - ")
    l1, c1 = map(int, a.split(","))
    l2, c2 = map(int, b.split(","))
    return line_starts[l1] + c1, line_starts[l2] + c2

def key(local):            # unique id of a local declaration
    return local["location"]

PURE_GLOBAL_LIBS = {"bit32", "math"}
PURE_CALLS = {"type", "typeof"}
PURE_TABLE_FNS = {"pack"}

def callee_pure(f):
    t = f.get("type")
    if t == "AstExprGlobal":
        return f["global"] in PURE_CALLS
    if t == "AstExprIndexName" and f["expr"].get("type") == "AstExprGlobal":
        g, i = f["expr"]["global"], f["index"]
        if g in PURE_GLOBAL_LIBS:
            return True
        if g == "table" and i in PURE_TABLE_FNS:
            return True
    return False

def pure(e):
    t = e.get("type")
    if t in ("AstExprConstantNumber", "AstExprConstantString", "AstExprConstantBool",
             "AstExprConstantNil", "AstExprLocal", "AstExprVarargs"):
        return True
    if t == "AstExprGroup":
        return pure(e["expr"])
    if t == "AstExprUnary":
        return pure(e["expr"])
    if t == "AstExprBinary":
        return pure(e["left"]) and pure(e["right"])
    if t == "AstExprIfElse":
        return pure(e["condition"]) and pure(e["trueExpr"]) and pure(e["falseExpr"])
    if t == "AstExprIndexExpr":
        return e["expr"].get("type") == "AstExprLocal" and \
            e["index"].get("type") == "AstExprConstantNumber"
    if t == "AstExprCall":
        return not e.get("self") and callee_pure(e["func"]) and all(pure(a) for a in e["args"])
    return False

# ---------------------------------------------------------------- collect
reads = {}          # local key -> [offset of each read]
cands = []          # (kind, stmt span, [local keys], extra)

def walk_expr(e):
    if not isinstance(e, dict):
        return
    if e.get("type") == "AstExprLocal":
        reads.setdefault(key(e["local"]), []).append(span(e)[0])
        return
    if e.get("type") == "AstExprFunction":
        walk_block(e["body"])
        return
    for k, v in e.items():
        if k in ("location", "local"):
            continue
        if isinstance(v, dict):
            if v.get("type", "").startswith("AstStat"):
                walk_stat(v)
            else:
                walk_expr(v)
        elif isinstance(v, list):
            for x in v:
                if isinstance(x, dict):
                    if x.get("type", "").startswith("AstStat"):
                        walk_stat(x)
                    else:
                        walk_expr(x)

def walk_block(b):
    # statements directly inside a block body: only these may be `do end` candidates
    for st in b.get("body", []):
        walk_stat(st, in_body=True)

def is_empty_block(b):
    return b is None or (b.get("type") == "AstStatBlock" and not b.get("body"))

def walk_stat(st, in_body=False):
    t = st["type"]
    sp = span(st)
    if t == "AstStatBlock":
        # a structural body (if/for/while/function) is never removed, only a bare `do end`
        if in_body and not st.get("body"):
            cands.append(("empty", sp, [], None))
        walk_block(st)
        return
    if t == "AstStatExpr":
        if st["expr"].get("type") == "AstExprCall" and pure(st["expr"]):
            cands.append(("always", sp, [], None))
        walk_expr(st["expr"])
        return
    if t == "AstStatLocal":
        vals = st.get("values", [])
        if all(pure(v) for v in vals):
            cands.append(("unread", sp, [key(v) for v in st["vars"]], None))
        for v in vals:
            walk_expr(v)
        return
    if t == "AstStatLocalFunction":
        # never removed: detached payload closures are real code nobody names
        walk_expr(st["func"])
        return
    if t == "AstStatAssign":
        tgts = st["vars"]
        if all(x.get("type") == "AstExprLocal" for x in tgts) and all(pure(v) for v in st["values"]):
            cands.append(("unread", sp, [key(x["local"]) for x in tgts], None))
            for v in st["values"]:
                walk_expr(v)
            return          # targets are writes, not reads
        for x in tgts:
            walk_expr(x)
        for v in st["values"]:
            walk_expr(v)
        return
    if t == "AstStatCompoundAssign":
        tgt = st["var"]
        if tgt.get("type") == "AstExprLocal" and pure(st["value"]):
            cands.append(("unread", sp, [key(tgt["local"])], None))
            walk_expr(st["value"])
            return
        walk_expr(tgt)
        walk_expr(st["value"])
        return
    if t == "AstStatIf":
        cond = st["condition"]
        # NOTE: `if nil then` is NOT dead code here: the lifter prints `nil` for a
        # value it could not resolve (an unknown upvalue), so the branch may run.
        if is_empty_block(st.get("thenbody")) and is_empty_block(st.get("elsebody")) and pure(cond):
            cands.append(("always", sp, [], None))
        walk_expr(st["condition"])
        walk_block(st["thenbody"])
        eb = st.get("elsebody")
        if eb:
            if eb.get("type") == "AstStatBlock":
                walk_block(eb)
            else:
                walk_stat(eb)      # elseif chain: an AstStatIf
        return
    # everything else (for/while/repeat/return/...): walk children; loop bodies are
    # structural, so blocks go through walk_block (never deletion candidates)
    for k, v in st.items():
        if k == "location":
            continue
        if isinstance(v, dict):
            if v.get("type") == "AstStatBlock":
                walk_block(v)
            elif v.get("type", "").startswith("AstStat"):
                walk_stat(v)
            else:
                walk_expr(v)
        elif isinstance(v, list):
            for x in v:
                if isinstance(x, dict):
                    if x.get("type", "").startswith("AstStat"):
                        walk_stat(x)
                    else:
                        walk_expr(x)
    # AstStatFor/ForIn/LocalFunction vars are declarations, not reads

walk_block(root)
for k in reads:
    reads[k].sort()

# ---------------------------------------------------------------- liveness
# mark & sweep (handles junk cycles: v43 -> v48 -> ... -> v55 -> v43):
#   a local is live if real code reads it; a junk-candidate statement is live if it
#   defines a live local, and then everything it reads becomes live too.
always = sorted(sp for kind, sp, _, _ in cands if kind in ("always", "empty"))
unread = sorted((sp, i) for i, (kind, sp, _, _) in enumerate(cands) if kind == "unread")
u_starts = [sp[0] for sp, _ in unread]

def in_always(pos):
    i = bisect.bisect_right(always, (pos, float("inf"))) - 1
    while i >= 0:
        s, e = always[i]
        if s <= pos < e:
            return True
        if pos - s > 2000000:
            break
        i -= 1
    return False

def owner(pos):            # the junk candidate whose span holds this read, if any
    i = bisect.bisect_right(u_starts, pos) - 1
    if i >= 0:
        (s, e), ci = unread[i]
        if s <= pos < e:
            return ci
    return None

live = set()
cand_reads = {}
for k, ps in reads.items():
    for p in ps:
        if in_always(p):
            continue
        ci = owner(p)
        if ci is None:
            live.add(k)
        else:
            cand_reads.setdefault(ci, set()).add(k)

defs_of = {}
for i, (kind, sp, keys, _) in enumerate(cands):
    if kind == "unread":
        for k in keys:
            defs_of.setdefault(k, []).append(i)

live_cands = set()
work = list(live)
while work:
    k = work.pop()
    for ci in defs_of.get(k, ()):
        if ci in live_cands:
            continue
        live_cands.add(ci)
        for r in cand_reads.get(ci, ()):
            if r not in live:
                live.add(r)
                work.append(r)

done = set()
deleted = []
for i, (kind, sp, keys, _) in enumerate(cands):
    if kind in ("always", "empty") or (kind == "unread" and i not in live_cands):
        done.add(i)
        deleted.append(sp)
rounds = 1

# merge nested/overlapping spans
BLOCK_OPEN = (b"then", b"do", b"else", b"repeat")

def keep_semicolon(s, e):
    """A deleted statement's span can include its ';'. Keep that ';' only where it is
    needed: the next statement starts with '(' AND what precedes ends an expression
    (else `f()` + `(x)()` would glue). After `then`/`do`/`function(..)`/'(' a ';'
    is a syntax error in Luau, so drop it there."""
    j = e
    while j < len(src) and src[j:j + 1] in (b" ", b"\t", b"\r", b"\n"):
        j += 1
    if src[j:j + 1] != b"(":
        return False
    k = s
    while k > 0 and src[k - 1:k] in (b" ", b"\t", b"\r", b"\n", b";"):
        k -= 1
    before = src[max(0, k - 8):k]
    if not before or before[-1:] in (b"(", b"{", b",", b"=", b"[") or \
            any(before.endswith(w) and not before[-len(w) - 1:-len(w)].isalnum() for w in BLOCK_OPEN):
        return False
    m = re.search(rb"function\s*[\w.:]*\s*\([^()]*\)\s*$", src[max(0, k - 200):k])
    return m is None

merged = []
for s, e in sorted(deleted):
    if e > s and src[e - 1:e] == b";" and keep_semicolon(s, e):
        e -= 1
    if merged and s < merged[-1][1]:
        merged[-1][1] = max(merged[-1][1], e)
    else:
        merged.append([s, e])

out = bytearray()
pos = 0
for s, e in merged:
    out += src[pos:s]
    pos = e
out += src[pos:]
# latin-1 maps every byte to one char and back: strings that are not valid
# UTF-8 (Luraph keeps raw bytes) survive untouched
text = out.decode("latin-1")

# the cosmetic passes below must never touch string contents: park every string
# literal (quoted and [[long]]) and comment behind a placeholder first
parked = []
def _park(s):
    parked.append(s)
    return "\x00%d\x00" % (len(parked) - 1)
buf, i, n = [], 0, len(text)
while i < n:
    c = text[i]
    if c == "-" and text.startswith("--", i):
        m = re.match(r"--\[(=*)\[", text[i:])
        if m:
            end = text.find("]" + m.group(1) + "]", i)
            end = n if end < 0 else end + len(m.group(1)) + 2
        else:
            end = text.find("\n", i)
            end = n if end < 0 else end
        buf.append(_park(text[i:end])); i = end; continue
    if c in "\"'":
        j = i + 1
        while j < n and text[j] != c and text[j] != "\n":
            j += 2 if text[j] == "\\" else 1
        buf.append(_park(text[i:j + 1])); i = j + 1; continue
    if c == "[":
        m = re.match(r"\[(=*)\[", text[i:])
        if m:
            end = text.find("]" + m.group(1) + "]", i)
            end = n if end < 0 else end + len(m.group(1)) + 2
            buf.append(_park(text[i:end])); i = end; continue
    buf.append(c); i += 1
text = "".join(buf)

text = re.sub(r"[ \t]+\n", "\n", text)          # lines left blank by deletions
text = re.sub(r"\n{3,}", "\n\n", text)
text = re.sub(r"(\n[^\n]*(?:\bthen|\bdo|\belse|\brepeat|\bfunction\b[^\n]*\)))\n(?:[ \t]*\n)+", r"\1\n", text)  # blank right after a block opens
text = re.sub(r"\n(?:[ \t]*\n)+([ \t]*(?:end|else|elseif|until)\b)", r"\n\1", text)                         # blank right before it closes
text = re.sub("\x00(\\d+)\x00", lambda m: parked[int(m.group(1))], text)                                    # strings back, byte for byte
open(out_path, "wb").write(text.encode("latin-1"))
sys.stderr.write("removed %d junk statements (%d -> %d bytes)\n"
                 % (len(done), len(src), len(text.encode("latin-1"))))
# deleting statements can empty an `if` or orphan another local: repeat on the result
if done and not getattr(sys, "_luaclean_nested", False):
    for _ in range(8):
        r = subprocess.run([sys.executable, "-I", __file__, ast_exe, out_path, out_path, "--once"],
                           capture_output=True, text=True)
        sys.stderr.write(r.stderr)
        if r.returncode or "removed 0 " in r.stderr:
            break
