"""Static analysis for Luraph v14.7/v14.8/v14.9: maps dispatch loops to their
opcode handlers and closure factories to the runtime capture metadata.

Unlike v15, the maker's prototype parameter can be argument 0, the opcode fetch
is commonly parenthesized (AstExprGroup) or type-asserted, and the dispatcher
can be a `repeat ... until false` loop. The VM closure is identified by the
local that directly declares the dispatcher's program counter, then bound
back to its lexical factory.
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
BIN_DIR = os.path.join(ROOT, "..", "bin") if os.path.exists(os.path.join(ROOT, "..", "bin")) else os.path.join(ROOT, "bin")

def _normalize(n):
    """Fold parser-only wrappers (parenthesised expressions, type assertions)
    into their operands and turn `repeat ... until false` into `while true`,
    so the shared v15 engine sees one canonical shape."""
    if isinstance(n, dict):
        for k in list(n.keys()):
            v = n[k]
            if isinstance(v, dict) and v.get("type") in ("AstExprGroup", "AstExprTypeAssertion"):
                inner = v.get("expr") or v.get("expression")
                if inner is not None:
                    n[k] = _normalize(inner)
                    continue
            n[k] = _normalize(v)
        if n.get("type") == "AstStatRepeat":
            cond = n.get("condition")
            if isinstance(cond, dict) and cond.get("type") == "AstExprConstantBool" and not cond.get("value"):
                n["type"] = "AstStatWhile"
                n["condition"] = {"type": "AstExprConstantBool", "value": True,
                                  "location": cond.get("location", "")}
        return n
    if isinstance(n, list):
        for i, v in enumerate(n):
            if isinstance(v, dict) and v.get("type") in ("AstExprGroup", "AstExprTypeAssertion"):
                inner = v.get("expr") or v.get("expression")
                if inner is not None:
                    n[i] = _normalize(inner)
                    continue
            _normalize(v)
        return n
    return n


def load_ast(path):
    exe = os.path.join(BIN_DIR, "luau-ast.exe" if os.name == "nt" else "luau-ast")
    r = subprocess.run([exe, path], capture_output=True)
    errs = r.stderr.decode("latin-1").strip().splitlines()
    if r.returncode != 0 or (errs and errs[0].startswith("Parse errors")):
        raise SyntaxError("not valid Luau (%s)" % (errs[1].strip() if len(errs) > 1 else "luau-ast exit %#x"
                                                   % (r.returncode & 0xFFFFFFFF)))
    return _normalize(json.loads(r.stdout.decode("latin-1"))["root"])


def loc(node):
    a, b = node["location"].split(" - ")
    l1, c1 = map(int, a.split(","))
    l2, c2 = map(int, b.split(","))
    return l1, c1, l2, c2


def text_of(lines, node):
    l1, c1, l2, c2 = loc(node)
    if l1 == l2:
        return lines[l1][c1:c2]
    parts = [lines[l1][c1:]] + lines[l1 + 1:l2] + lines[l2][:c2]
    return "\n".join(parts)


def walk(node, fn):
    stack = [node]
    while stack:
        curr = stack.pop()
        if isinstance(curr, dict):
            fn(curr)
            stack.extend(curr.values())
        elif isinstance(curr, list):
            stack.extend(curr)


def unwrap(e):
    while isinstance(e, dict) and e.get("type") in ("AstExprGroup", "AstExprTypeAssertion"):
        e = e.get("expr") or e.get("expression")
    return e


def local_name(expr):
    expr = unwrap(expr)
    if isinstance(expr, dict) and expr.get("type") == "AstExprLocal":
        return expr["local"]["name"]
    return None


def find_dispatchers(root):
    found = []

    def visit(n):
        t = n.get("type")
        if t not in ("AstStatWhile", "AstStatRepeat"):
            return
        cond = unwrap(n.get("condition"))
        if not isinstance(cond, dict) or cond.get("type") != "AstExprConstantBool":
            return
        if t == "AstStatWhile" and not cond.get("value"):
            return
        if t == "AstStatRepeat" and cond.get("value"):
            return
        body = n["body"]["body"]
        if len(body) < 2 or body[0]["type"] not in ("AstStatLocal", "AstStatAssign"):
            return
        st = body[0]
        if len(st["values"]) != 1:
            return
        opname = st["vars"][0]["name"] if st["type"] == "AstStatLocal" else local_name(st["vars"][0])
        if not opname:
            return
        v = unwrap(st["values"][0])
        if not isinstance(v, dict) or v.get("type") != "AstExprIndexExpr":
            return
        arr, pc = local_name(v["expr"]), local_name(v["index"])
        if not arr or not pc or body[1]["type"] != "AstStatIf":
            return
        found.append({"node": n, "op": opname, "arr": arr, "pc": pc, "tree": body[1],
                      "rest": body[2:]})

    walk(root, visit)
    return found


OPS = {"CompareLt": lambda a, b: a < b, "CompareLe": lambda a, b: a <= b,
       "CompareGt": lambda a, b: a > b, "CompareGe": lambda a, b: a >= b,
       "CompareEq": lambda a, b: a == b, "CompareNe": lambda a, b: a != b}
FLIP = {"CompareLt": "CompareGt", "CompareLe": "CompareGe", "CompareGt": "CompareLt",
        "CompareGe": "CompareLe", "CompareEq": "CompareEq", "CompareNe": "CompareNe"}


def eval_cond(cond, var, value):
    if cond["type"] != "AstExprBinary" or cond["op"] not in OPS:
        return None
    l, r = unwrap(cond["left"]), unwrap(cond["right"])
    op = cond["op"]
    if local_name(l) == var and r["type"] == "AstExprConstantNumber":
        return OPS[op](value, r["value"])
    if local_name(r) == var and l["type"] == "AstExprConstantNumber":
        return OPS[FLIP[op]](value, l["value"])
    return None


def resolve(tree, var, value):
    node = tree
    while True:
        if node["type"] == "AstStatBlock":
            if len(node["body"]) >= 1 and node["body"][0]["type"] == "AstStatIf" \
                    and eval_cond(node["body"][0]["condition"], var, value) is not None:
                node = node["body"][0]
                continue
            return node
        if node["type"] == "AstStatIf":
            r = eval_cond(node["condition"], var, value)
            if r is None:
                return node
            node = r and node["thenbody"] or node["elsebody"]
            if node is None:
                return None
            continue
        return node


def decl_key(local):
    return local["location"]


def _decls_in(fn):
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
            elif t == "AstStatFor":
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
    return keys


def _binding_for_closure(clo, stmts, depth=None):
    for st, d in reversed(stmts):
        if depth is not None and d != depth:
            continue
        typ = st.get("type")
        if typ in ("AstStatAssign", "AstStatLocal"):
            for v, e in zip(st.get("vars", []), st.get("values", [])):
                if unwrap(e) is not clo:
                    continue
                name = local_name(v) if typ == "AstStatAssign" else v.get("name")
                if name:
                    return st, name
        elif typ == "AstStatLocalFunction":
            f = unwrap(st.get("func") or st.get("value") or st.get("function"))
            if f is clo:
                name = (st.get("name") or {}).get("name")
                if name:
                    return st, name
    return None, None


def _select_vm_factory(stack, stmts, disp):
    pc = disp.get("pc")
    for vi in range(len(stack) - 1, 0, -1):
        vm = stack[vi]
        try:
            decl_names = set(_decls_in(vm).values())
        except Exception:
            decl_names = set()
        if pc and pc not in decl_names:
            continue
        mi = vi - 1
        maker = stack[mi]
        st, var = _binding_for_closure(vm, stmts, vi)
        if st is not None and maker.get("args"):
            return mi, maker, vm, st, var
    for vi in range(len(stack) - 1, 0, -1):
        vm = stack[vi]
        try:
            decl_names = set(_decls_in(vm).values())
        except Exception:
            decl_names = set()
        if pc and pc not in decl_names:
            continue
        for mi in range(vi - 1, -1, -1):
            maker = stack[mi]
            if not maker.get("args"):
                continue
            st, var = _binding_for_closure(vm, stmts, mi + 1)
            if st is None:
                st, var = _binding_for_closure(vm, stmts)
            if st is not None:
                return mi, maker, vm, st, var
    for mi in range(len(stack) - 2, -1, -1):
        maker = stack[mi]
        if not maker.get("args"):
            continue
        for vi in range(mi + 1, len(stack)):
            vm = stack[vi]
            st, var = _binding_for_closure(vm, stmts, mi + 1)
            if st is not None:
                return mi, maker, vm, st, var
    return None


def closure_entries(root):
    dispatches = find_dispatchers(root)
    by_node = {id(d["node"]): d for d in dispatches}
    seen = {}

    def walk_tree(n, stack, stmts):
        if isinstance(n, dict):
            t = n.get("type")
            if t == "AstExprFunction":
                stack = stack + [n]
            if t and t.startswith("AstStat"):
                stmts = stmts + [(n, len(stack) + 1)]
            if t in ("AstStatWhile", "AstStatRepeat") and id(n) in by_node:
                picked = _select_vm_factory(stack, stmts, by_node[id(n)])
                if picked is not None:
                    _, maker, vm, _st, _var = picked
                    body = vm.get("body", {}).get("body", [])
                    if body:
                        l1, c1, _, _ = loc(body[0])
                        pi, _ui = _maker_params(maker)
                        args = maker.get("args", [])
                        if args and pi < len(args):
                            seen[(l1, c1)] = args[pi]["name"]
            for v in n.values():
                walk_tree(v, stack, stmts)
        elif isinstance(n, list):
            for v in n:
                walk_tree(v, stack, stmts)

    walk_tree(root, [], [])
    return [(l, c, name) for (l, c), name in seen.items()]


def maker_info(root):
    dispatches = find_dispatchers(root)
    by_node = {id(d["node"]): d for d in dispatches}
    out = {}

    def walk_tree(n, stack, stmts):
        if isinstance(n, dict):
            t = n.get("type")
            if t == "AstExprFunction":
                stack = stack + [n]
            if t and t.startswith("AstStat"):
                stmts = stmts + [(n, len(stack) + 1)]
            if t in ("AstStatWhile", "AstStatRepeat") and id(n) in by_node:
                picked = _select_vm_factory(stack, stmts, by_node[id(n)])
                if picked is not None:
                    mi, maker, clo, st, var = picked
                    _, _, l2, c2 = loc(st)
                    if (l2, c2) not in out:
                        pi, ui = _maker_params(maker)
                        args = maker.get("args", [])
                        if args and pi < len(args):
                            out[(l2, c2)] = {
                                "at": (l2, c2), "var": var,
                                "proto": args[pi]["name"],
                                "proto_index": pi, "upvals_index": ui,
                                "pf_key": args[pi]["name"],
                                "maker": maker, "vm": clo, "stmt": st,
                                "maker_depth": mi,
                                "dispatch_pc": by_node[id(n)].get("pc"),
                                "dispatch_arr": by_node[id(n)].get("arr"),
                            }
            for v in n.values():
                walk_tree(v, stack, stmts)
        elif isinstance(n, list):
            for v in n:
                walk_tree(v, stack, stmts)

    walk_tree(root, [], [])
    for info in out.values():
        info["captures"] = _captures(info)
        info["outer_env"] = _outer_captures(info)
    return list(out.values())


def _maker_params(maker):
    args = maker.get("args", [])
    if not args:
        return 0, 0
    visible = {}
    for i, a in enumerate(args):
        visible[a["name"]] = i
    direct, nested, used = {}, {}, set()

    def visit(n):
        if isinstance(n, dict):
            if n.get("type") == "AstExprLocal":
                used.add((n.get("local") or {}).get("location"))
            if n.get("type") == "AstExprIndexExpr":
                base = unwrap(n.get("expr"))
                idx = unwrap(n.get("index"))
                if isinstance(base, dict) and base.get("type") == "AstExprLocal":
                    key = (base.get("local") or {}).get("location")
                    if isinstance(idx, dict) and idx.get("type") == "AstExprConstantNumber":
                        direct[key] = direct.get(key, 0) + 4
                    if isinstance(idx, dict) and idx.get("type") == "AstExprIndexExpr":
                        ib = unwrap(idx.get("expr"))
                        if isinstance(ib, dict) and ib.get("type") == "AstExprLocal" \
                                and (ib.get("local") or {}).get("location") == key:
                            nested[key] = nested.get(key, 0) + 8
            for v in n.values():
                visit(v)
        elif isinstance(n, list):
            for v in n:
                visit(v)
    visit(maker.get("body"))
    candidates = list(visible.values())

    def score(i):
        key = args[i].get("location")
        return (nested.get(key, 0) + direct.get(key, 0), direct.get(key, 0), -i)

    pi = max(candidates, key=score) if candidates else 0
    remaining = [i for i in candidates if i != pi]
    if remaining:
        ui = max(remaining, key=lambda i: (args[i].get("location") in used,
                                            direct.get(args[i].get("location"), 0), -i))
    else:
        ui = pi
    return pi, ui


def _captures(info):
    maker_decls = _decls_in(info["maker"])
    used = {}

    def visit(n):
        if isinstance(n, dict):
            if n.get("type") == "AstExprLocal":
                k = decl_key(n["local"])
                if k in maker_decls:
                    used[k] = maker_decls[k]
            for v in n.values():
                visit(v)
        elif isinstance(n, list):
            for v in n:
                visit(v)
    visit(info["vm"])
    names = {}
    for k, name in used.items():
        names.setdefault(name, []).append(k)
    dup = {nm for nm, ks in names.items() if len(ks) > 1}
    by_name = {}
    for k, nm in maker_decls.items():
        by_name.setdefault(nm, []).append(k)
    return sorted(nm for nm in names if nm not in dup and len(by_name[nm]) == 1)


def _outer_captures(info):
    own = set(_decls_in(info["maker"]))
    found = {}

    def visit(n):
        if isinstance(n, dict):
            if n.get("type") == "AstExprLocal":
                loc_ = n.get("local") or {}
                key = decl_key(loc_)
                if key not in own and loc_.get("name"):
                    found.setdefault(key, loc_["name"])
            for v in n.values():
                visit(v)
        elif isinstance(n, list):
            for v in n:
                visit(v)
    visit(info["maker"].get("body"))
    by_name = {}
    for key, name in found.items():
        by_name.setdefault(name, []).append(key)
    out = []
    idx = 0
    for key in sorted(found, key=repr):
        name = found[key]
        if len(by_name[name]) != 1:
            continue
        idx += 1
        out.append({"decl": key, "name": name, "field": "__venv%d" % idx})
    return out


if __name__ == "__main__":
    src = sys.argv[1]
    root = load_ast(src)
    print("dispatchers: %d  entries: %d  makers: %d"
          % (len(find_dispatchers(root)), len(closure_entries(root)), len(maker_info(root))))