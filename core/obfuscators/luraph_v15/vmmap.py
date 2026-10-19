import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
BIN_DIR = os.path.join(ROOT, "..", "bin") if os.path.exists(os.path.join(ROOT, "..", "bin")) else os.path.join(ROOT, "bin")

def load_ast(path):
    import harness
    r = harness.run_luau_ast(path)
    errs = r.stderr.decode("latin-1").strip().splitlines()
    if r.returncode != 0 or (errs and errs[0].startswith("Parse errors")):
        raise SyntaxError("not valid Luau (%s)" % (errs[1].strip() if len(errs) > 1 else "luau-ast exit %#x"
                                                   % (r.returncode & 0xFFFFFFFF)))
    out = r.stdout
    return json.loads(out.decode("latin-1"))["root"]

def loc(node):
    a, b = node["location"].split(" - ")
    l1, c1 = map(int, a.split(","))
    l2, c2 = map(int, b.split(","))
    return l1, c1, l2, c2

def text_of(lines, node):
    l1, c1, l2, c2 = loc(node)
    if l1 == l2:
        return lines[l1][c1:c2]
    parts = [lines[l1][c1:]] + lines[l1 + 1:l2] + [lines[l2][:c2]]
    return "\n".join(parts)

def walk(node, fn):
    stack = [node]
    pop = stack.pop
    extend = stack.extend
    while stack:
        curr = pop()
        if isinstance(curr, dict):
            fn(curr)
            extend(curr.values())
        elif isinstance(curr, list):
            extend(curr)

def local_name(expr):
    if expr.get("type") == "AstExprLocal":
        return expr["local"]["name"]
    return None

def _loop_body(n):
    """(body statements, form) of an endless while/repeat loop, else None.
    Both are Luraph v15 dispatch forms: `while true do ... end` and
    `repeat ... until false`."""
    t = n.get("type")
    if t == "AstStatWhile":
        cond = n["condition"]
        if cond.get("type") != "AstExprConstantBool" or not cond.get("value"):
            return None
        return n["body"]["body"], "while"
    if t == "AstStatRepeat":
        cond = n["condition"]
        if cond.get("type") != "AstExprConstantBool" or cond.get("value"):
            return None
        body = n.get("body")
        if not isinstance(body, dict):
            return None
        return body["body"], "repeat"
    return None

def _unwrap(e):
    while e.get("type") == "AstExprGroup":
        e = e["expr"]
    return e

def _fix_int(v):
    if isinstance(v, float) and v.is_integer():
        return int(v)
    return v

def find_dispatchers(root):
    """while true do local op = ARR[PC]; if-tree ... end -- and the
    repeat...until false form. The fetch head may be parenthesized
    (`local y=(V[W])`): an AstExprGroup the AST keeps around the index.
    Also supports the Luraph v15.1 bool-local dispatch tree:
    `local op = ARR[PC]; local b = op <cmp> K; if b then ...`"""
    found = []

    def visit(n):
        loop = _loop_body(n)
        if loop is None:
            return
        body, form = loop
        if len(body) < 2 or body[0]["type"] not in ("AstStatLocal", "AstStatAssign"):
            return
        st = body[0]
        if len(st["values"]) != 1:
            return
        if st["type"] == "AstStatLocal":
            opname = st["vars"][0]["name"]
        else:
            opname = local_name(st["vars"][0])
            if not opname:
                return
        v = _unwrap(st["values"][0])
        if v["type"] != "AstExprIndexExpr":
            return
        arr, pc = local_name(_unwrap(v["expr"])), local_name(_unwrap(v["index"]))
        if not arr or not pc:
            return
        if body[1]["type"] == "AstStatIf":
            found.append({"node": n, "op": opname, "arr": arr, "pc": pc, "tree": body[1],
                          "rest": body[2:], "form": form})
        elif len(body) >= 3 and body[1]["type"] in ("AstStatLocal", "AstStatAssign") and body[2]["type"] == "AstStatIf":
            st1 = body[1]
            if len(st1.get("values") or []) == 1:
                v1 = _unwrap(st1["values"][0])
                if v1.get("type") == "AstExprBinary" and v1.get("op") in OPS:
                    found.append({"node": n, "op": opname, "arr": arr, "pc": pc, "tree": n["body"],
                                  "rest": body[3:], "form": form})

    walk(root, visit)
    return found

OPS = {"CompareLt": lambda a, b: a < b, "CompareLe": lambda a, b: a <= b,
       "CompareGt": lambda a, b: a > b, "CompareGe": lambda a, b: a >= b,
       "CompareEq": lambda a, b: a == b, "CompareNe": lambda a, b: a != b}
FLIP = {"CompareLt": "CompareGt", "CompareLe": "CompareGe", "CompareGt": "CompareLt",
        "CompareGe": "CompareLe", "CompareEq": "CompareEq", "CompareNe": "CompareNe"}

def eval_cond(cond, var, value):
    """Evaluate `var <op> const` for a concrete opcode value; None if not such a test."""
    if cond["type"] != "AstExprBinary" or cond["op"] not in OPS:
        return None
    l, r = cond["left"], cond["right"]
    op = cond["op"]
    if local_name(l) == var and r["type"] == "AstExprConstantNumber":
        return OPS[op](value, r["value"])
    if local_name(r) == var and l["type"] == "AstExprConstantNumber":
        return OPS[FLIP[op]](value, l["value"])
    return None

def resolve(tree, var, value):
    """Follow the if-tree for one opcode value and return the handler block."""
    node = tree
    benv = {}
    while True:
        if node["type"] == "AstStatBlock":
            b = node["body"]
            if len(b) >= 1 and b[0]["type"] == "AstStatIf" \
                    and eval_cond(b[0]["condition"], var, value) is not None:
                node = b[0]
                continue
            for i in range(len(b) - 1):
                st = b[i]
                nxt = b[i + 1]
                if st["type"] in ("AstStatLocal", "AstStatAssign") and len(st.get("values") or []) == 1 \
                        and nxt["type"] == "AstStatIf":
                    v = _unwrap(st["values"][0])
                    r = eval_cond(v, var, value)
                    if r is not None:
                        bvar = st["vars"][0]["name"] if st["type"] == "AstStatLocal" else local_name(st["vars"][0])
                        if bvar and local_name(_unwrap(nxt["condition"])) == bvar:
                            benv[bvar] = r
                            node = nxt
                            break
            else:
                return node
            continue
        if node["type"] == "AstStatIf":
            r = eval_cond(node["condition"], var, value)
            if r is None:
                cname = local_name(_unwrap(node["condition"]))
                if cname in benv:
                    r = benv[cname]
            if r is None:
                return node
            if r:
                node = node["thenbody"]
            else:
                e = node.get("elsebody")
                if e is None:
                    return None
                node = e
            continue
        return node

def handler_map(disp, lines, max_op=256):
    handlers = {}
    for op in range(max_op):
        blk = resolve(disp["tree"], disp["op"], op)
        if blk is None:
            continue
        key = blk["location"]
        handlers.setdefault(key, {"ops": [], "node": blk})["ops"].append(op)
    return handlers

def main():
    path = sys.argv[1]
    root = load_ast(path)
    with open(path, encoding="latin-1") as f:
        lines = f.read().split("\n")
    disps = find_dispatchers(root)
    if len(sys.argv) == 2:
        for i, d in enumerate(disps, 1):
            h = handler_map(d, lines)
            print("dispatch %d: op=%s arr=%s pc=%s handlers=%d at %s" % (i, d["op"], d["arr"], d["pc"], len(h),
                                                                        d["node"]["location"]))
        return
    d = disps[int(sys.argv[2]) - 1]
    want = set(int(x) for x in sys.argv[3:])
    for op in sorted(want):
        blk = resolve(d["tree"], d["op"], op)
        print("---- op %d" % op)
        print(text_of(lines, blk) if blk else "<none>")

if __name__ == "__main__":
    main()

def instrument(src, disp_index, probes, root=None, tmp_path=None):
    """Insert Lua code at the start of chosen opcode handlers of one dispatch loop.

    probes: {opcode: "lua code"}; returns modified source. Only single-line
    sources (like Luraph output) are supported.
    """
    lines = src.split("\n")
    if root is None:
        root = load_ast(tmp_path)
    d = find_dispatchers(root)[disp_index - 1]
    inserts = []
    for op, code in probes.items():
        blk = resolve(d["tree"], d["op"], op)
        if blk is None:
            continue
        l1, c1, _, _ = loc(blk)

        inserts.append((l1, c1, code))
    for l1, c1, code in sorted(inserts, reverse=True):
        s = lines[l1]
        lines[l1] = s[:c1] + " " + code + " " + s[c1:]
    return "\n".join(lines)

def loop_names(disp):
    """(register array, pc variable) used by a dispatch loop's handlers."""
    return ("Z", "W") if disp["pc"] == "W" else ("l", "O")

def _vm_stack_idx(stack):
    if len(stack) >= 2 and stack[-1].get("vararg") and not stack[-1].get("args") \
            and stack[-2].get("vararg") and not stack[-2].get("args"):
        return len(stack) - 2
    return len(stack) - 1

def _curried3_of(stack, vm_idx):
    if vm_idx < 2:
        return None
    f3 = stack[vm_idx - 2]
    f2 = stack[vm_idx - 1]
    f1 = stack[vm_idx]
    f3b = (f3.get("body") or {}).get("body") or []
    ret_stmt = f3b[-1] if f3b else None
    if len(f3.get("args") or []) < 5 or not ret_stmt or ret_stmt.get("type") != "AstStatReturn":
        return None
    rlist = ret_stmt.get("list") or []
    if len(rlist) != 1:
        return None
    if rlist[0] is f2:
        return {"f3": f3, "f2": f2, "f1": f1, "retStmt": ret_stmt, "kind": "anon"}
    u_name = local_name(rlist[0])
    f2b = (f2.get("body") or {}).get("body") or []
    f2_ret = f2b[-1] if f2b else None
    f2_rlist = (f2_ret.get("list") or []) if f2_ret and f2_ret.get("type") == "AstStatReturn" else []
    z_name = local_name(f2_rlist[0]) if len(f2_rlist) == 1 else None
    if u_name and z_name:
        return {"f3": f3, "f2": f2, "f1": f1, "retStmt": ret_stmt, "f2Ret": f2_ret,
                "uName": u_name, "zName": z_name, "kind": "named"}
    return None

def closure_entries(root):
    """For each VM interpreter closure: (line, col of its first statement, proto variable name)."""
    disp_nodes = [d["node"] for d in find_dispatchers(root)]
    seen = {}

    def walk(n, stack):
        if isinstance(n, dict):
            if n.get("type") == "AstExprFunction":
                stack = stack + [n]
            if n.get("type") in ("AstStatWhile", "AstStatRepeat") and any(n is d for d in disp_nodes):
                vm_idx = _vm_stack_idx(stack)
                inner = stack[vm_idx] if stack and stack[vm_idx].get("vararg") and not stack[vm_idx].get("args") \
                    else next(f for f in reversed(stack) if f.get("vararg") and not f["args"])
                outer = next(f for f in reversed(stack) if len(f["args"]) >= 2)
                l1, c1, _, _ = loc(inner["body"]["body"][0])
                name = "__pv" if _curried3_of(stack, vm_idx) else outer["args"][_maker_params(outer)[0]]["name"]
                seen[(l1, c1)] = name
            for v in n.values():
                walk(v, stack)
        elif isinstance(n, list):
            for v in n:
                walk(v, stack)
    walk(root, [])
    return [(l, c, name) for (l, c), name in seen.items()]

def decl_key(local):
    """Identity of a local: its declaration location."""
    return local["location"]

def _free_names(fn):
    """Names used inside `fn` whose declaration lives outside it (free
    upvalues): every AstExprLocal the function's own decl map does not know.
    Mirrors _freeNames in src/vmmap.js (the capture hook uses the same list)."""
    own = set(_decls_in(fn))
    names = set()

    def visit(n):
        if isinstance(n, dict):
            if n.get("type") == "AstExprLocal" and decl_key(n["local"]) not in own:
                names.add(n["local"]["name"])
            for v in n.values():
                visit(v)
        elif isinstance(n, list):
            for v in n:
                visit(v)
    visit(fn["body"])
    return sorted(names)

def _register_dispatch_local(out, stack):
    """v3 'dispatch_local' maker: some Luraph v15 builds decode the proto
    INSIDE the dispatcher's own closure (`C=function(...) local
    P=W[9] and A[113](x),...`), so the sephal-era maker-assign hook has no
    match (or the assigned closure is parenthesized and never compares equal
    to the walked node). Hook after the dispatcher's first local instead: the
    first local is the live proto/register state, and the free upvalues
    (A/V/x/W ... VM state) are what a capture needs. Same shape and tag
    positions as the JS side (src/vmmap.js makerInfo v3), so dump tags made
    by either match."""
    if not stack:
        return False
    vm_idx = _vm_stack_idx(stack)
    clo = stack[vm_idx]
    if not clo.get("vararg") or clo.get("args"):
        return False
    body = clo.get("body")
    bbody = body.get("body") if isinstance(body, dict) else None
    if not bbody or len(bbody) < 2:
        return False
    if bbody[0].get("type") != "AstStatLocal" or not bbody[0].get("vars"):
        return False
    target_idx = 0
    pv = bbody[0]["vars"][0]["name"]
    for si in range(len(bbody) - 1):
        st = bbody[si]
        if st.get("type") != "AstStatLocal":
            break
        vals = st.get("values") or []
        vars_ = st.get("vars") or []
        found_call = False
        for vi, val in enumerate(vals):
            if isinstance(val, dict) and val.get("type") == "AstExprCall" and vi < len(vars_):
                target_idx = si
                pv = vars_[vi]["name"]
                found_call = True
                break
        if found_call:
            break
    first, second = bbody[target_idx], bbody[target_idx + 1]
    l2, c2, _, _ = loc(second)
    key = ("v3", l2, c2)
    if key in out:
        return True
    shadowed = {v["name"] for si in range(target_idx + 1) for v in (bbody[si].get("vars") or [])}
    caps = [nm for nm in _free_names(clo) if nm not in shadowed]
    out[key] = {"at": (l2, c2), "var": pv, "proto": pv, "mode": "dispatch_local",
                "pf_key": '"disp@%d,%d"' % (l2, c2),
                "maker": stack[vm_idx - 1] if vm_idx >= 1 else None,
                "vm": clo, "stmt": first, "captures": caps,
                "curried3": _curried3_of(stack, vm_idx),
                "chain": stack[:vm_idx - 1] if vm_idx >= 1 else []}
    return True

def maker_info(root, disp=None):
    disp_nodes = {id(d["node"]) for d in (disp if disp is not None else find_dispatchers(root))}
    out = {}

    def walk_tree(n, stack, stmts):
        if isinstance(n, dict):
            t = n.get("type")
            pushed_stack = False
            pushed_stmt = False
            if t == "AstExprFunction":
                stack.append(n)
                pushed_stack = True
            elif t and t.startswith("AstStat"):
                stmts.append((n, len(stack)))
                pushed_stmt = True
            if t in ("AstStatWhile", "AstStatRepeat") and id(n) in disp_nodes:
                registered = False
                oi = max((i for i, f in enumerate(stack) if len(f["args"]) >= 2), default=-1)
                if oi != -1 and oi + 1 < len(stack):
                    clo = stack[oi + 1]
                    st = [s for s, d in stmts if d == oi + 1]
                    st = st[-1] if st else None
                    if st and st["type"] == "AstStatAssign":
                        for v, e in zip(st["vars"], st["values"]):
                            if e is clo and local_name(v):
                                _, _, l2, c2 = loc(st)
                                if (l2, c2) not in out:
                                    pi, ui = _maker_params(stack[oi])
                                    out[(l2, c2)] = {"at": (l2, c2), "var": local_name(v),
                                                     "proto": stack[oi]["args"][pi]["name"],
                                                     "proto_index": pi, "upvals_index": ui,

                                                     "pf_key": stack[oi]["args"][pi]["name"],
                                                     "maker": stack[oi], "vm": clo, "stmt": st,
                                                     "chain": stack[:oi]}
                                registered = True
                if not registered:
                    _register_dispatch_local(out, stack)
            for v in list(n.values()):
                walk_tree(v, stack, stmts)
            if pushed_stack:
                stack.pop()
            if pushed_stmt:
                stmts.pop()
        elif isinstance(n, list):
            for v in n:
                walk_tree(v, stack, stmts)
    walk_tree(root, [], [])
    for info in out.values():
        if info.get("mode") != "dispatch_local":
            info["captures"] = _captures(info)
    return list(out.values())

def _maker_params(maker):
    """(proto parameter index, upvalue-list parameter index) of a closure maker.
    Layouts differ: function(e, proto, upvals) or, with repeated names,
    function(g, d, d, d, d, j) where the proto is the last one. The proto is
    the parameter indexed through itself (P[P[k]]: its fields are keyed by
    its own entries); the upvalue list is the first other parameter the body
    uses (only the last of repeated names is visible).

    Some makers read the proto through an alias local (`local Y = r` or
    `local d,K,... = r`, then `Y[Y[10]]`), so the self-index pattern never
    names the parameter directly. Those aliases are resolved and, when no
    direct self-index count exists, their counts select the proto param
    (sephal x==223 factory: `local Y=r; Y[Y[10]]...` -> proto at index 4)."""
    args = maker["args"]
    visible = {}
    for i, a in enumerate(args):
        visible[a["name"]] = i
    counts = {}
    kcounts = {}
    acounts = {}
    used = set()

    param_locs = {a["location"] for a in args}
    aliases = {}

    def collect_aliases(n):
        if isinstance(n, dict):
            if n.get("type") == "AstStatLocal":
                for var, val in zip(n["vars"], n["values"]):
                    if var.get("type") == "AstLocal" and val.get("type") == "AstExprLocal":
                        src = val["local"]["location"]
                        if src in param_locs or src in aliases:
                            aliases[var["location"]] = src
            for v in n.values():
                collect_aliases(v)
        elif isinstance(n, list):
            for v in n:
                collect_aliases(v)

    collect_aliases(maker["body"])

    def resolve(loc, depth=0):
        while depth < 10 and loc not in param_locs and loc in aliases:
            loc = aliases[loc]
            depth += 1
        return loc

    def visit(n):
        if isinstance(n, dict):
            if n.get("type") == "AstExprLocal":
                used.add(n["local"]["location"])
            if n.get("type") == "AstExprIndexExpr" and n["expr"].get("type") == "AstExprLocal" \
                    and n["index"].get("type") == "AstExprIndexExpr" \
                    and n["index"]["expr"].get("type") == "AstExprLocal" \
                    and n["index"]["expr"]["local"]["location"] == n["expr"]["local"]["location"]:
                k = n["expr"]["local"]["location"]
                counts[k] = counts.get(k, 0) + 1
                ak = resolve(k)
                if ak is not k:
                    acounts[ak] = acounts.get(ak, 0) + 1
            if n.get("type") == "AstExprIndexExpr" and n["expr"].get("type") == "AstExprLocal" \
                    and n["index"].get("type") == "AstExprConstantNumber":
                k = n["expr"]["local"]["location"]
                kcounts[k] = kcounts.get(k, 0) + 1
            for v in n.values():
                visit(v)
        elif isinstance(n, list):
            for v in n:
                visit(v)
    visit(maker["body"])
    cands = [i for i in visible.values() if i > 0]
    pi = max(cands, key=lambda i: (counts.get(args[i]["location"], 0), i == 1)) if cands else 1
    if not counts.get(args[pi]["location"]):
        # blind fallback: alias-resolved self-index counts first (a maker whose
        # proto is only read through `local Y = <param>`), then const-indexed
        # params, then param 1
        aliased = [(acounts.get(args[i]["location"], 0), i) for i in cands]
        best = max(aliased) if aliased else None
        kc = [i for i in cands if kcounts.get(args[i]["location"])]
        if best and best[0] > 0:
            pi = best[1]
        else:
            pi = 1
            if kc:
                pi = max(kc, key=lambda i: kcounts[args[i]["location"]])
    others = sorted(i for i in visible.values() if i not in (0, pi) and args[i]["location"] in used)
    ui = others[0] if others else pi + 1
    return pi, ui

def ctor_assignments(root):
    """Functions assigned by index into a captured table anywhere in the
    source: `(A)[0x3c]=function(W,m) ...` -> {("A", 60): fn}. Luraph builds
    that register their closure factory at run time (a plain assignment, not
    a table constructor) are invisible to find_ctor_funcs; the dump's captured
    table for `A` still holds the function under the same index, so binding
    needs the assignment form too."""
    out = {}

    def visit(n):
        if isinstance(n, dict):
            if n.get("type") == "AstStatAssign":
                for var, val in zip(n["vars"], n["values"]):
                    if _unwrap(val).get("type") != "AstExprFunction" or \
                            var.get("type") != "AstExprIndexExpr":
                        continue
                    val = _unwrap(val)
                    base = local_name(_unwrap(var["expr"]))
                    idx = _unwrap(var["index"])
                    if not base:
                        continue
                    if idx.get("type") == "AstExprConstantNumber":
                        out.setdefault((base.encode("latin-1"), _fix_int(idx["value"])), val)
                    elif idx.get("type") == "AstExprConstantString":
                        out.setdefault((base.encode("latin-1"), idx["value"].encode("latin-1")), val)
            for v in list(n.values()):
                visit(v)
        elif isinstance(n, list):
            for v in n:
                visit(v)
    visit(root)
    return out

def outer_decls(root, target):
    """{decl key: name} of every declaration outside `target` (a function
    node) that encloses it: params and locals of the functions on the
    root->target path. The innermost declaration of a name wins, so the VM
    closure's free names resolve to the same decl keys the interpreter sees."""
    found = {}

    def visit(n, stack):
        if isinstance(n, dict):
            t = n.get("type")
            pushed = False
            if t == "AstExprFunction":
                stack.append(n)
                pushed = True
            if n is target:
                for fn in stack[:-1]:
                    for k, nm in _decls_in(fn).items():
                        found[k] = nm
            for v in list(n.values()):
                visit(v, stack)
            if pushed:
                stack.pop()
        elif isinstance(n, list):
            for v in n:
                visit(v, stack)
    visit(root, [])
    return found

def _decls_in(fn):
    cache = fn.get("_decls")
    if cache is not None:
        return cache
    keys = {}

    def visit(n):
        if isinstance(n, dict):
            t = n.get("type")
            if t == "AstExprFunction" and n is not fn:
                return
            if t == "AstStatLocal":
                for v in n["vars"]:
                    keys[decl_key(v)] = v["name"]
            elif t == "AstStatLocalFunction":
                keys[decl_key(n["name"])] = n["name"]["name"]
            elif t in ("AstStatFor",):
                keys[decl_key(n["var"])] = n["var"]["name"]
            elif t == "AstStatForIn":
                for v in n["vars"]:
                    keys[decl_key(v)] = v["name"]
            for v in n.values():
                visit(v)
        elif isinstance(n, list):
            for v in n:
                visit(v)
    for a in fn["args"]:
        keys[decl_key(a)] = a["name"]
    visit(fn["body"])
    fn["_decls"] = keys
    return keys

def _loc_start(key):
    """(line, col) of a location string's start ("2,21450 - 2,21451" -> (2, 21450))."""
    a = str(key).split(" - ")[0]
    l, c = a.split(",")
    return int(l), int(c)

def _captures(info):
    maker_decls = _decls_in(info["maker"])
    # v14.9-style builds nest the maker inside a helper method; the VM closure
    # reads the helper's parameters/locals (e.g. its state table) which are NOT
    # the maker's own decls. The capture code runs inside the maker where those
    # names stay lexically visible, so record them too.
    chain_decls = {}
    if info.get("chain"):
        mk = _loc_start(info["maker"]["location"])
        for fn in info["chain"]:
            for k, nm in _decls_in(fn).items():
                if _loc_start(k) <= mk:
                    chain_decls.setdefault(nm, []).append(k)

    used_maker = {}     # decl key -> name, refs resolving into the maker
    used_chain = {}     # refs resolving into an enclosing scope

    def visit(n):
        if isinstance(n, dict):
            if n.get("type") == "AstExprLocal":
                k = decl_key(n["local"])
                nm = n["local"]["name"]
                if k in maker_decls:
                    used_maker[k] = nm
                elif nm in chain_decls and k in chain_decls[nm]:
                    used_chain[k] = nm
            for v in n.values():
                visit(v)
        elif isinstance(n, list):
            for v in n:
                visit(v)
    visit(info["vm"])

    def single(members, decls_by_name):
        """names whose refs hit exactly one decl, with exactly one decl of
        that name (by-name capture `__PA[p].nm=nm` must be unambiguous)."""
        names = {}
        for k, nm in members.items():
            names.setdefault(nm, set()).add(k)
        return {nm for nm, ks in names.items() if len(ks) == 1 and len(decls_by_name.get(nm, [])) == 1}

    maker_by_name = {}
    for k, nm in maker_decls.items():
        maker_by_name.setdefault(nm, []).append(k)
    caps = single(used_maker, maker_by_name)
    for nm in single(used_chain, chain_decls):
        if nm not in maker_decls:   # a maker decl would shadow it at the hook
            caps.add(nm)
    return sorted(caps)
