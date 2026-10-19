"""Luraph v14.7/v14.8/v14.9 devirtualizer: the v15 engine layered with the
v14 quirks. The walk, structuring and codegen are shared; what changes:

* the mapper: repeat dispatchers, parenthesized/type-asserted opcode fetch,
  prototype as maker argument 0, factories installed inside an initializer
  that close over its locals (serialized as __venvN captures);
* the maker runs in a scope rebuilt from those __venvN captures;
* flattened handler state may index an unresolved table or do arithmetic on
  a temporarily missing value: those exact holes stay symbolic (NilIndex /
  Missing) instead of aborting the walk, with writes to the unresolved base
  kept coherent in a per-proto shadow;
* native closures (LPH_NO_VIRTUALIZE) that fail to interpret are preserved
  as Luau source with their free bindings rebuilt as an IIFE;
* untagged runtime factories called as (protoTable, upvalueTable) become
  ClosureExprs, and non-array concrete tables lower to table literals.
"""
import json
import os
import re
import sys
import time

from obfuscators.luraph_v15 import devirt as D
import luasym as S
import ir
from obfuscators.luraph_v15.devirt import (LTable, Builtin, LuaFunc, Unsupported, Scope,
                                           Multi, OpaqueFn, ClosureExpr, RegFile, Missing,
                                           TempTail, walk_expr, fmt_expr, is_sym)
from luasym import NewTable

from obfuscators.luraph_v14 import vmmap

sys.setrecursionlimit(max(sys.getrecursionlimit(), 60000))


class InterpTick:
    """Statement counter for the helper-decode wall deadline."""
    n = 0


_DECODE_DEADLINE = [None]

vmmap.unwrap_group = vmmap.unwrap
_mi_orig = vmmap.maker_info


def _maker_info(root, disp=None):
    if disp is None:
        disp = vmmap.find_dispatchers(root)
    return _mi_orig(root)


vmmap.maker_info = _maker_info
D.vmmap = vmmap


class NilIndex(Missing):
    """A read through a table base the tracer could not materialize: the walk
    can fork on it (the concrete VM path drops impossible branches)."""


def _interp_patches():
    """`nil[key]` reads and reads of locals the maker never bound stay
    symbolic; nil arithmetic routes through the lifter's symbolic binop; a
    numeric for whose bounds come from an unresolved helper is skipped
    rather than crashing the walk."""
    if getattr(S.Interp, "_v14_nil_index_patch", False):
        return
    orig_eval = S.Interp.eval

    def eval_(self, node, scope):
        try:
            return orig_eval(self, node, scope)
        except Unsupported as ex:
            msg = str(ex)
            if isinstance(node, dict) and node.get("type") == "AstExprIndexExpr" \
                    and msg.startswith("index nil @"):
                obj = self.eval(node["expr"], scope)
                key = self.eval(node["index"], scope)
                if isinstance(key, Multi):
                    key = key.first()
                return self.L.index(obj, key, self)
            if isinstance(node, dict) and node.get("type") == "AstExprLocal" \
                    and msg.startswith("unbound local "):
                loc = node.get("local") or {}
                return Missing("outer:%s@%s" % (loc.get("name", "?"),
                                                 loc.get("location", "?")))
            raise
    S.Interp.eval = eval_
    S.Interp._v14_nil_index_patch = True

    orig_binop = S.Interp.binop

    def binop_(self, op, a, b):
        if op in ("Add", "Sub", "Mul", "Div", "FloorDiv", "Mod", "Pow") and (a is None or b is None):
            aa = a if a is not None else Missing("arith-left")
            bb = b if b is not None else Missing("arith-right")
            return self.L.sym_binop(op, aa, bb)
        return orig_binop(self, op, a, b)
    S.Interp.binop = binop_
    S.Interp._v14_nil_arith_patch = True

    orig_exec_stmt = S.Interp.exec_stmt

    def exec_stmt_(self, st, scope):
        if st.get("type") == "AstStatFor":
            try:
                a = self.eval(st["from"], scope)
                b = self.eval(st["to"], scope)
                c = self.eval(st["step"], scope) if st.get("step") else 1
            except S.Unsupported:
                raise
            if a is None or b is None or c is None:
                return
        InterpTick.n += 1
        if _DECODE_DEADLINE[0] is not None and InterpTick.n % 2048 == 0 \
                and time.monotonic() > _DECODE_DEADLINE[0]:
            raise Unsupported("helper decode budget exhausted")
        return orig_exec_stmt(self, st, scope)
    S.Interp.exec_stmt = exec_stmt_


_interp_patches()


def _shadow_key(lf, key):
    try:
        if not is_sym(key):
            return ("const", S.norm_key(key))
    except Exception:
        pass
    try:
        return ("sym", fmt_expr(lf.as_expr(key)))
    except Exception:
        return ("repr", repr(key))


_lf_init = D.ProtoLifter.__init__
_lf_index = D.ProtoLifter.index
_lf_newindex = D.ProtoLifter.newindex
_lf_value_of = D.ProtoLifter.value_of
_lf_call_symbolic = D.ProtoLifter.call_symbolic

if not getattr(D.ProtoLifter, "_v14_origs", None):
    D.ProtoLifter._v14_origs = (D.ProtoLifter.__init__, D.ProtoLifter.index, D.ProtoLifter.newindex,
                                D.ProtoLifter.value_of, D.ProtoLifter.call_symbolic)
_lf_init, _lf_index, _lf_newindex, _lf_value_of, _lf_call_symbolic = D.ProtoLifter._v14_origs


def _bind_unbound_nodes(cap, statics, outer_env):
    """Attach the static AST body to runtime-captured helpers that never got
    one: an OpaqueFn with .node is callable by the symbolic interpreter, but
    the runtime capture value itself is kept (state written before capture
    stays). Only truly unbound entries are touched."""
    bound = 0
    for env_ in outer_env:
        field = env_.get("field")
        t = cap.get(field) if field is not None else None
        static = statics.get(env_.get("decl"))
        if not isinstance(t, LTable) or not isinstance(static, LTable):
            continue
        seen = set()
        stack = [(t, static)]
        while stack:
            rt, st = stack.pop()
            pair = (id(rt), id(st))
            if pair in seen:
                continue
            seen.add(pair)
            for k, sv in st.h.items():
                rv = rt.h.get(S.norm_key(k))
                if isinstance(rv, OpaqueFn) and rv.node is None \
                        and isinstance(sv, LuaFunc):
                    rv.node = sv.node
                    rv.env = sv.env
                    bound += 1
                if isinstance(rv, LTable) and isinstance(sv, LTable):
                    stack.append((rv, sv))
    return bound


def _prepare_maker_env(self, env, vm, proto):
    """Rebuild the maker's lexical parent scope from the __venvN captures
    the runtime made where the factory was installed; helpers the runtime
    captured without a body get their static AST bound back onto them."""
    try:
        cap = None
        for _cap in self.dump.protos.values():
            try:
                p = vm.proto_of(_cap)
            except Exception:
                continue
            if p is proto or p == proto:
                cap = _cap
                break
        if cap is None:
            return env
        parent = Scope()
        for env_ in vm.info.get("outer_env", ()):
            field, decl = env_.get("field"), env_.get("decl")
            if field in cap:
                parent.vars[decl] = cap[field]
        statics = dict(getattr(vm.info, "static_tables", None) or
                       (vm.info.get("static_tables") if isinstance(vm.info, dict) else {}) or {})
        # Deep mode (DEOB_V14_DECODE_BUDGET env): bind the static bodies onto
        # the captured helpers so the walk executes Luraph's real decode loops.
        # It reaches far more of the payload (20+ functions on samples that
        # otherwise lift one) but takes minutes to hours, so it is opt-in.
        if statics and os.environ.get("DEOB_V14_DEEP"):
            _bind_unbound_nodes(cap, statics, vm.info.get("outer_env", ()))
        if parent.vars:
            cur = env
            while cur.parent is not None:
                cur = cur.parent
            cur.parent = parent
    except Exception:
        pass
    return env


def _proto_init(self, vm, dump, vmobj, proto, upvals, globals_tab, *args, **kwargs):
    _lf_init(self, vm, dump, vmobj, proto, upvals, globals_tab, *args, **kwargs)
    self.nil_shadow = {}


def _index(self, obj, key, it):
    if isinstance(key, Multi):
        key = key.first()
    if obj is None:
        sk = _shadow_key(self, key)
        if sk in self.nil_shadow:
            return self.nil_shadow[sk]
        return NilIndex(key)
    return _lf_index(self, obj, key, it)


def _newindex(self, obj, key, v, it):
    if obj is None:
        if isinstance(key, Multi):
            key = key.first()
        self.nil_shadow[_shadow_key(self, key)] = v
        return
    return _lf_newindex(self, obj, key, v, it)


def _value_of(self, v):
    if isinstance(v, RegFile):
        return D.FrameArg(-1)
    if isinstance(v, LTable) and v.h and id(v) not in self.proto_arrays \
            and id(v) not in self.dump.tid_of:
        stack = getattr(self, "_table_value_stack", None)
        if stack is None:
            stack = self._table_value_stack = set()
        ident = id(v)
        if ident in stack:
            raise Unsupported("cyclic VM table stored into a register")
        stack.add(ident)
        try:
            keys = sorted(v.h, key=lambda k: (not isinstance(k, int), repr(k)))
            seq = keys == list(range(1, len(keys) + 1))
            items = []
            for k in keys:
                keyexpr = None if seq else self.as_expr(k)
                items.append((keyexpr, self.value_of(v.h[k])))
            return NewTable(items)
        finally:
            stack.discard(ident)
    return _lf_value_of(self, v)


def _function_source(self, node):
    if node is None:
        return None
    m = re.fullmatch(r"(\d+),(\d+) - (\d+),(\d+)", node.get("location", ""))
    if not m:
        return None
    l1, c1, l2, c2 = (int(x) for x in m.groups())
    lines = getattr(self.vm, "src_lines", None)
    if not lines or not (0 <= l1 < len(lines) and 0 <= l2 < len(lines)):
        return None
    if l1 == l2:
        text = lines[l1][c1:c2]
    else:
        text = "\n".join([lines[l1][c1:]] + lines[l1 + 1:l2] + lines[l2][:c2])
    return text if len(text) <= 8000 else None


def _free_locals(self, node):
    declared = set(vmmap._decls_in(node).keys())
    out, seen = [], set()

    def visit(n):
        if isinstance(n, dict):
            if n.get("type") == "AstExprLocal":
                loc = n["local"].get("location")
                if loc not in declared and loc not in seen:
                    seen.add(loc)
                    out.append(n["local"])
                return
            for v in n.values():
                visit(v)
        elif isinstance(n, list):
            for v in n:
                visit(v)
    visit(node.get("body"))
    return out


def _native_opaque_fn(self, fn):
    """A native closure (LPH_NO_VIRTUALIZE / VM-object helper) preserved as
    Luau source; free locals become IIFE arguments bound from the maker
    scope so native code coexists with the lifted VM."""
    node = getattr(fn, "node", None)
    text = _function_source(self, node)
    if text is None:
        return None
    free = _free_locals(self, node)
    if not free:
        return ir.Opaque("function", text)
    env = getattr(self, "maker_scope", None)
    if env is None:
        return None
    names, values = [], []
    for decl in free:
        loc = decl.get("location")
        sc = env.lookup(loc) if hasattr(env, "lookup") else None
        if sc is None or loc not in sc.vars:
            return None
        try:
            rendered = fmt_expr(self.as_expr(sc.vars[loc]))
        except Exception:
            return None
        names.append(decl.get("name") or "__lph_up")
        values.append("(" + rendered + ")")
    return ir.Opaque("function",
                    "(function(%s) return %s end)(%s)" % (",".join(names), text, ",".join(values)))


def _call_symbolic(self, fn, args, it, stat):
    if isinstance(fn, OpaqueFn) and fn.node is None and fn.pf_tid is None:
        vals = list(args.items)
        for i, proto in enumerate(vals):
            if not isinstance(proto, LTable) or proto.tid not in self.dump.pid_of_table:
                continue
            ups = vals[i + 1] if i + 1 < len(vals) else None
            if not isinstance(ups, LTable):
                continue
            entries = [ups.get(k) for k in range(1, ups.length() + 1)]
            c = ClosureExpr(proto, entries)
            c.vm = self.vm
            return Multi([c])
    try:
        return _lf_call_symbolic(self, fn, args, it, stat)
    except Unsupported as ex:
        if isinstance(fn, OpaqueFn) and fn.node is None \
                and str(ex).startswith("call of unknown VM function"):
            # a v14 runtime helper closure with no recoverable body: keep the
            # call as a SharedFn stub so one opaque helper cannot abort the
            # whole payload lift
            fe = self.as_expr(fn)
            t = self.new_temp()
            self.emit(ir.CallStmt(t, fe,
                                  Multi([self.value_of(x) if not isinstance(x, S.SymList) else x
                                         for x in args.items], args.tail)))
            return Multi([], TempTail(t))
        if isinstance(fn, OpaqueFn) and getattr(fn, "node", None) is not None:
            native = _native_opaque_fn(self, fn)
            if native is not None:
                t = self.new_temp()
                self.emit(ir.CallStmt(t, native,
                                      Multi([self.value_of(x) if not isinstance(x, S.SymList) else x
                                             for x in args.items], args.tail)))
                return Multi([], TempTail(t))
        raise


D.ProtoLifter._prepare_maker_env = _prepare_maker_env
D.ProtoLifter.__init__ = _proto_init
D.ProtoLifter.index = _index
D.ProtoLifter.newindex = _newindex
D.ProtoLifter.value_of = _value_of
D.ProtoLifter.call_symbolic = _call_symbolic
D.ProtoLifter.native_opaque_fn = _native_opaque_fn


def _scaffold_score(text):
    """Lower is better; mirrors src/driver.js v14ScaffoldScore."""
    if not text:
        return 10 ** 6
    score = 0
    score += min(80, text.count("the caller's registers") * 5)
    runtime = text.count("luraph_runtime")
    score += min(60, runtime * 2)
    score += min(40, text.count("handlers[") * 2)
    score += min(30, len(re.findall(r"\b(?:if|elseif)\s+state\s*==", text)) // 3)
    if len(re.findall(r"^\s*\[\d+\]\s*=", text, re.M)) >= 200:
        score += 30
    if "local ... = ..." in text:
        score += 40
    stubs = len(re.findall(r'error\("Luraph runtime function', text))
    if stubs:
        score += 20 + min(60, stubs * 5)
    junk = len(re.findall(r"^\s*--\s{2,}(?:Script:|.*harness\.luau)", text, re.M))
    if junk:
        score += 20 + min(60, junk * 2)
    guards = len(re.findall(r'error\("devirt:', text))
    if guards:
        score += 25 + min(50, guards * 5)
    return score


_orig_lift_program = D.lift_program


def _lift_candidates(protos_path):
    """Payload-root candidates the runtime call-chain vote ranked, in order."""
    try:
        d = D._load_json_loose(protos_path)
    except Exception:
        return []
    return [int(p) for p in (d.get("root_candidates") or [])]


def _set_dump_root(protos_path, pid):
    """Point root_callee at one candidate; returns a backup path to restore."""
    try:
        d = D._load_json_loose(protos_path)
        if str(pid) not in (d.get("protos") or {}):
            return None
        old = d.get("root_callee")
        d["root_callee"] = int(pid)
        with open(protos_path, "w", encoding="utf-8", newline="\n") as f:
            json.dump(d, f, separators=(",", ":"))
        return old
    except Exception:
        return None


def lift_program(source, protos_path, chunk_paths=(), fetch=None):
    """Lift the payload root, trying every ranked candidate when the first
    lift still looks like Luraph bootstrap scaffolding; the cleanest result
    wins (the reference's alternate-root selection, done engine-side)."""
    budget = float(os.environ.get("DEOB_V14_DECODE_BUDGET", "300"))
    old_deadline = _DECODE_DEADLINE[0]
    _DECODE_DEADLINE[0] = time.monotonic() + budget
    try:
        return _lift_program_inner(source, protos_path, chunk_paths, fetch)
    finally:
        _DECODE_DEADLINE[0] = old_deadline


def _lift_program_inner(source, protos_path, chunk_paths=(), fetch=None):
    candidates = _lift_candidates(protos_path)
    best = None
    best_score = None
    best_out = None
    tried = set()
    order = [None] + candidates[:4]
    for pid in order:
        if pid in tried:
            continue
        tried.add(pid)
        old_root = None
        if pid is not None:
            old_root = _set_dump_root(protos_path, pid)
            if old_root is None:
                continue
        try:
            text, stats, reqs, bufs = _orig_lift_program(source, protos_path, chunk_paths, fetch)
        except Exception:
            continue
        finally:
            if pid is not None and old_root is not None:
                _set_dump_root(protos_path, old_root)
        if not text:
            continue
        score = _scaffold_score(text)
        if best_score is None or score < best_score:
            best, best_score = text, score
            best_out = (text, stats, reqs, bufs)
        if best_score <= 0:
            break
    if best_out is None:
        return _orig_lift_program(source, protos_path, chunk_paths, fetch)
    return best_out


collect_requests = D.collect_requests
program_roots = D.program_roots
Program = D.Program
Dump = D.Dump
WalkCache = D.WalkCache
run_big_stack = D.run_big_stack
same_patches = D.same_patches
LAST_DUMP = D.LAST_DUMP
show_op = D.show_op


def __getattr__(name):
    return getattr(D, name)