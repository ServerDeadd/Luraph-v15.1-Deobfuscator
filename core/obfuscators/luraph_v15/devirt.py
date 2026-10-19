from collections import deque
import gzip
import json
import os
import re
import struct
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))     
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)

from obfuscators.luraph_v15 import vmmap  
import backend  
import harness  
import luasym as S  
from luasym import (LTable, Builtin, LuaFunc, Buf, Unsupported, Expr, Const, Reg, Pseudo, Global,  
                    Upval, Index, Bin, Un, IfExp, TempVal, Vararg, ClosureExpr, Multi, TempTail,
                    VarargTail, SymList, TailCount, RegFile, EnvTable, UpContainer, Scope,
                    BreakSig, ReturnSig, YieldSig, is_sym)
from luasym import ContinueSig  
from ir import (IRStmt, Assign, CallStmt, SetList, GenIter, Outcome, Next, Ret, Crash, Node,  
                ForPrep, Close, Opaque, Vec, Missing, fmt_expr, fmt_any, fmt_tail, fmt_multi, fmt_const,
                fmt_stmt, fmt_node)

class PatchLog(dict):
    """A patch dict that remembers the keys written since the last `take()`
    (live requests send only what changed)."""

    def __init__(self, *a):
        super().__init__(*a)
        self.dirty = set(self)

    def __setitem__(self, k, v):
        super().__setitem__(k, v)
        self.dirty.add(k)

    def update(self, other=(), **kw):
        for k, v in dict(other, **kw).items():
            self[k] = v

    def take(self):
        d, self.dirty = self.dirty, set()
        return d

class Dump:
    def __init__(self, path):
        opener = gzip.open if str(path).endswith(".gz") else open
        with opener(path, "rt", encoding="utf-8") as f:
            d = json.load(f)
        self.raw = d
        self.tables = {}
        self.lfs = {}
        self.shared = {}        
        self.buf_loc = {}       
        self._load_tables(d["tables"])

        self.buf_patch = PatchLog()
        self.misses = {}
        self.vm_names = {"e"}     

        self.tab_patch = PatchLog()
        self.tid_of = {id(t): tid for tid, t in self.tables.items()}
        self.lazy = {int(tid) for tid, t in d["tables"].items() if t.get("mt")}

        self.decoder = {int(tid): json.dumps(t["mtf"]) for tid, t in d["tables"].items() if t.get("mtf")}

        self.overrides = {path: self.val(v) for path, v in d.get("overrides", [])}
        self.pid_of_table = {int(k): v for k, v in d["pid_of_table"].items()}
        self.protos = {}
        for key, cap in d["protos"].items():
            self.protos[key] = {k: self.val(v) for k, v in cap.items()}
        self._paths = None
        self.late = self._lazy_late(d)

        self._by_operand = self._operand_facts()

        self.fetcher = None
        self.fetched = set()
        self._fetched_any = False
        self.fetch_time = [0.0, 0.0, 0.0, 0]    
        self.extra_patches = (PatchLog(), PatchLog())   
        self._sent = {}         

    def _lazy_late(self, d):
        """Lazy constants decoded at run time from an instruction's decoded
        operand, in a proto the runtime restored to its pre-run state (envlog
        CHAIN.unscramble, "late": [slot, ...]). The dump's operand is the
        undecoded one again, so they are not plain slots: they hold for the
        operand the lifter decodes for that instruction (each decodes once).
        -> {(tid, slot): value}"""
        late = {}
        for tid, t in d["tables"].items():
            for k in t.get("late") or ():
                key = S.norm_key(self.val(k))
                v = self.tables[int(tid)].h.pop(key, None)
                if v is not None:
                    late[(int(tid), key)] = v
        return late

    def _load_tables(self, tables):
        for tid in tables:
            self.tables[int(tid)] = LTable(tid=int(tid))
        for tid, t in tables.items():
            tb = self.tables[int(tid)]
            for i, v in enumerate(t["arr"], 1):
                if v is not None:
                    tb.h[i] = self.val(v)
                    if isinstance(tb.h[i], Buf):
                        self.buf_loc[id(tb.h[i])] = (tb.h[i], int(tid), i)
            for k, v in t["kv"]:
                kk = self.val(k)
                vv = self.val(v)
                if vv is not None:
                    tb.h[("opaque", id(kk)) if isinstance(kk, Expr) else S.norm_key(kk)] = vv
                    if isinstance(vv, Buf) and isinstance(kk, int):
                        self.buf_loc[id(vv)] = (vv, int(tid), kk)

    def fetch(self, rq):
        """A missing lazy constant (request path `rq`) decoded right away by
        the live harness, instead of in the next constant round. Its new
        tables join the dump. -> the value, or None (no harness, failed,
        or asked before)."""
        if self.fetcher is None or rq in self.fetched:
            return None
        self.fetched.add(rq)
        t0 = time.time()

        bw, tw = self._patch_delta()
        send = "+" + format_patches(bw, tw) if bw or tw else "="
        t1 = time.time()
        try:

            first = not self._fetched_any
            self._fetched_any = True
            d = json.loads(self.fetcher([("*" if first else "") + rq], send))
            ft = self.fetch_time
            ft[0] += t1 - t0
            ft[1] += time.time() - t1
            ft[2] += d.get("t", 0)
            ft[3] += len(send)
        except Exception as ex:  
            print("[!] live constant request failed (%s): back to constant rounds" % str(ex)[:200],
                  file=sys.stderr)
            self.fetcher = None
            return None

        new = {tid: t for tid, t in (d.get("tables") or {}).items() if int(tid) not in self.tables}
        self._load_tables(new)
        for tid, t in new.items():
            if t.get("mt"):
                self.lazy.add(int(tid))
            if t.get("mtf"):
                self.decoder[int(tid)] = json.dumps(t["mtf"])
            self.tid_of[id(self.tables[int(tid)])] = int(tid)
        new_protos = d.get("new_protos") or {}
        if new_protos:
            by_suffix = getattr(self, "by_suffix", {})
            for key, cap in new_protos.items():
                pcap = {k: self.val(v) for k, v in cap.items()}
                mk = pcap.get("__maker")
                if mk is not None:
                    tag = mk.decode("latin-1") if isinstance(mk, bytes) else str(mk)
                    if tag not in getattr(self, "vms", {}):
                        hit = by_suffix.get(tag.rpartition("@")[2])
                        if hit is not None:
                            pcap["__maker"] = hit.encode("latin-1")
                self.protos[key] = pcap
                sv = pcap.get("self")
                if isinstance(sv, LTable) and hasattr(self, "cap_by_self"):
                    self.cap_by_self[sv.tid] = pcap
            self._paths = None
        val = None
        for path, v in d.get("values") or []:
            val = self.val(v)
            if val is None:
                continue
            self.overrides[path] = val
            if path.startswith("!"):
                continue
            pre, _, last = path.rpartition(",")
            op = last.partition("@")[2]
            t = PathResolver(self).get(pre)
            if t is not None and op:
                self._add_operand(self._by_operand, t.tid, op, val)
            elif t is not None:

                k = int(last) if re.fullmatch(r"-?\d+", last) else last.encode("latin-1")
                t.h[S.norm_key(k)] = val
            if isinstance(val, LTable) and self._paths is not None and val.tid not in self._paths \
                    and not path.startswith("!"):
                self._extend_paths(val, path.split(","))
        return val

    def _patch_delta(self):
        """Stable patches written since the last live request that the
        harness session does not have yet: (bytes, table entries)."""
        paths = self.paths()
        bw, tw = {}, {}
        for d in (self.extra_patches[0], self.extra_patches[1]):
            for k in d.take():
                if k in d:
                    (bw if len(k) == 3 else tw)[k] = d[k]
        for bid, off in self.buf_patch.take():
            v = self.buf_patch.get((bid, off))
            buf, tid, key = self.buf_loc[bid]
            if isinstance(v, int) and buf.data[off] != v and tid in paths:
                bw[(",".join(str(x) for x in paths[tid]), key, off)] = v
        for tid, key in self.tab_patch.take():
            v = self.tab_patch.get((tid, key))
            base = self.tables[tid].h.get(key)
            if tid in paths and not (isinstance(base, (int, float)) and base == v):
                tw[(",".join(str(x) for x in paths[tid]), key)] = v
        for d in (bw, tw):
            for k in [k for k, v in d.items() if self._sent.get(k, d) == v]:
                del d[k]
            self._sent.update(d)
        return bw, tw

    def _extend_paths(self, root, path):
        paths = self._paths
        paths[root.tid] = path
        queue = [root]
        i = 0
        while i < len(queue):
            t = queue[i]
            i += 1
            for k, v in t.h.items():
                if isinstance(v, LTable) and v.tid not in paths and isinstance(k, int):
                    paths[v.tid] = paths[t.tid] + [k]
                    queue.append(v)

    def miss(self, why):
        self.misses[why] = self.misses.get(why, 0) + 1

    def same_operand(self, rq, tid):
        """A lazy constant depends only on the operand it is decoded from
        (`path,slot@v`): the operand indexes the constant pool of the table's
        decoder (its shared `__index` metamethod, "mtf" in the dump; one per
        VM implementation), so any table with the same decoder decoded for
        the same v (a plain slot t[k] with t[0][k] == v, or another `@v`
        result) gives the value without a request. Only scalars and flat
        tables of scalars (upvalue descriptors, rebuilt per decode): child
        protos are distinct objects. Without this a branch on such a constant
        stopped the walk once per round (StealAnEgg: one step per round)."""
        op = rq.rpartition(",")[2].partition("@")[2]
        hit = self._by_operand.get((self.decoder.get(tid, tid), op))
        return hit[1] if hit and hit[0] is not None else None

    def _operand_facts(self):
        """(decoder, operand) -> (signature, value) for same_operand."""
        by = {}

        def add(tid, op, v):
            self._add_operand(by, tid, op, v)
        res = PathResolver(self)
        for path, v in self.overrides.items():
            pre, _, last = path.rpartition(",")
            slot, at, op = last.partition("@")
            if at:
                t = res.get(pre)
                add(t.tid if t is not None else None, op, v)
        for lt in self.lazy:
            t = self.tables[lt]
            k0 = t.h.get(0)
            if not isinstance(k0, LTable):
                continue
            for k, v in t.h.items():
                op = k0.h.get(k) if type(k) is int and k >= 1 else None
                if type(op) in (int, float):
                    add(lt, S.fmt_num(op), v)
        return by

    def _add_operand(self, by, tid, op, v):
        if v is None or tid is None:
            return
        if isinstance(v, LTable):
            if any(isinstance(x, (LTable, OpaqueFn, Buf)) for x in v.h.values()):
                return
            sig = ("t", tuple(sorted((repr(k), repr(x)) for k, x in v.h.items())))
        elif isinstance(v, (bytes, int, float, bool)):
            sig = ("v", type(v).__name__, repr(v))
        else:
            return
        key = (self.decoder.get(tid, tid), op)
        old = by.get(key)
        if old is None:
            by[key] = (sig, v)
        elif old[0] != sig:
            by[key] = (None, None)      

    def paths(self):
        """Shortest path to every table from a captured proto: [seq, name, key, key, ...]."""
        if self._paths is None:
            paths = {}
            queue = []
            for cap in self.protos.values():
                seq = cap.get("__seq")
                if seq is None:
                    continue
                for nm, v in cap.items():
                    if isinstance(v, LTable) and v.tid not in paths:
                        paths[v.tid] = [seq, nm]
                        if nm not in self.vm_names:   
                            queue.append(v)

            for rq, v in self.overrides.items():
                if isinstance(v, LTable) and v.tid not in paths and not rq.startswith("!"):
                    paths[v.tid] = rq.split(",")
                    queue.append(v)
            i = 0
            while i < len(queue):
                t = queue[i]
                i += 1
                for k, v in t.h.items():
                    if isinstance(v, LTable) and v.tid not in paths and isinstance(k, int):
                        paths[v.tid] = paths[t.tid] + [k]
                        queue.append(v)
            self._paths = paths
        return self._paths

    def val(self, v):
        if v is None or isinstance(v, bool):
            return v
        if isinstance(v, (int, float)):
            return S.fix_int(v)
        if "s" in v:
            return bytes.fromhex(v["s"])
        if "t" in v:
            return self.tables[v["t"]]
        if "f" in v:
            return Builtin(v["f"])
        if "lf" in v:
            f = self.lfs.get(v["lf"])
            if f is None:
                f = self.lfs[v["lf"]] = OpaqueFn(v["lf"])
            pf = v.get("pf")
            if pf is not None and "t" in pf:
                f.pf_tid = pf["t"]
            return f
        if "num" in v:
            return {"inf": float("inf"), "-inf": float("-inf"), "nan": float("nan"), "-0": -0.0}[v["num"]]
        if "b" in v:
            return Buf(bytes.fromhex(v["b"]))
        if "g" in v:
            return EnvTable() if v["g"] == "ENV" else Builtin(v["g"])
        if "vec" in v:
            return Vec([S.fix_int(self.val(x)) for x in v["vec"]])
        src = v.get("src") or ""
        return Opaque(v.get("u"), bytes.fromhex(src).decode("utf-8", "replace") if src else "")

class OpaqueFn:
    """A Lua function value from the dump; bound to its AST later if known."""

    def __init__(self, lfid):
        self.lfid = lfid
        self.node = None
        self.pf_tid = None      

class FrameArg(Global):
    """The caller's register frame passed as a call argument (a register
    holding the frame, `s[k] = s`, in the argument range). LPH_ENCSTR-style
    decryptors store their result into it (Program._walk evaluates such calls
    in the runtime, see frame_call); if one stays unevaluated it renders as nil."""

    def __init__(self, reg):
        Global.__init__(self, "nil --[[ the caller's registers ]]")
        self.reg = reg

class RuntimeMaker:
    """The closure maker looked up for a proto that exists only at runtime
    (ProtoLifter.index): calling it gives that value itself."""

class SharedFn(Global):
    """A VM closure the payload gets from the VM object (`R[a] = vmobj[k]`).
    Script code cannot reach the VM object, so this is Luraph's runtime
    (fetched.lua: LPH_ENCFUNC's decryptor, which deserializes the decrypted
    function with the VM's Lua-level loader): not lifted, a stub function
    named after the order of first use (lift_program)."""

    def __init__(self, fn, n):
        Global.__init__(self, "luraph_runtime%d" % n)
        self.fn = fn

class PlainProto:
    """A plain Lua function (e.g. preserved source) that captures outer locals."""

    def __init__(self, fn, node, replacements, lines):
        self.fn = fn
        self.node = node
        self.replacements = replacements
        self.lines = lines

    def render(self, capnames, upnames):
        m = re.fullmatch(r"(\d+),(\d+) - (\d+),(\d+)", self.node["location"])
        lines = self.lines
        l1, c1, l2, c2 = (int(x) for x in m.groups())
        if l1 == l2:
            text = lines[l1][c1:c2]
        else:
            text = "\n".join([lines[l1][c1:]] + lines[l1 + 1:l2] + [lines[l2][:c2]])

        for start, end, kind, data in sorted(self.replacements, key=lambda x: x[0], reverse=True):
            if kind == "reg":
                rep = capnames.get(data, "r%d" % data)
            elif kind in ("global", "builtin"):
                rep = data
            else:
                continue
            text = text[:start] + " " + rep + " " + text[end:]
        return text

def iter_nodes(n):
    stack = [n]
    pop = stack.pop
    while stack:
        curr = pop()
        if type(curr) is dict:
            yield curr
            # list(): PyPy cannot reverse some dict-values views (RPython NotImplementedError)
            for v in reversed(list(curr.values())):
                t = type(v)
                if t is dict or t is list:
                    stack.append(v)
        elif type(curr) is list:
            for v in reversed(curr):
                stack.append(v)

class VMModel:
    def __init__(self, info, dispatch_nodes, ctor_funcs):
        self.info = info
        self.maker = info["maker"]
        self.vm = info["vm"]
        self.dispatch = {id(n) for n in dispatch_nodes}
        self.ctor_funcs = ctor_funcs
        self.maker_decls = {}
        for k, nm in vmmap._decls_in(self.maker).items():
            self.maker_decls.setdefault(nm, []).append(k)
        body = self.vm["body"]["body"]

        self.tcall_idx = None
        for i, st in enumerate(body):
            if st["type"] == "AstStatLocal" and len(st["values"]) == 1 \
                    and st["values"][0]["type"] == "AstExprCall":
                args = st["values"][0]["args"]
                if args and args[0]["type"] == "AstExprFunction" and \
                        any(id(n) in self.dispatch for n in iter_nodes(args[0])):
                    self.tcall_idx = i
                    break
        if self.tcall_idx is not None:

            self.prologue = body[:self.tcall_idx]
            self.tstat = body[self.tcall_idx]
            self.post = body[self.tcall_idx + 1:]
            self.inner = self.tstat["values"][0]["args"][0]
        else:

            self.prologue = []
            self.tstat = None
            self.post = None
            self.inner = self.vm
        self.inner_body = self.inner["body"]["body"]
        self._find_state_vars()

    def _find_state_vars(self):
        """Loop-state stack K (K={...,[x]=K}), the values saved in it
        (pseudo for-loop variables) and the open-upvalue list (sink)."""
        vm_decls = vmmap._decls_in(self.vm)
        self.special = {}
        self.kstack_key = None
        self.kstack_link = None

        alias = {}
        iterated = set()
        cleared = set()
        table_assigns = []
        local_copies = []

        for n in iter_nodes(self.inner):
            t = n.get("type")
            if t == "AstStatAssign":
                vars_, vals_ = n["vars"], n["values"]
                for var, val in zip(vars_, vals_):
                    vt = var["type"]
                    if vt == "AstExprLocal":
                        vloc = var["local"]["location"]
                        valt = val["type"]
                        if valt == "AstExprLocal":
                            alias.setdefault(vloc, set()).add(val["local"]["location"])
                        elif valt == "AstExprTable" and vloc in vm_decls:
                            table_assigns.append((vloc, val["items"]))
                    elif vt == "AstExprIndexExpr":
                        if var["expr"]["type"] == "AstExprLocal" and val["type"] == "AstExprConstantNil":
                            cleared.add(var["expr"]["local"]["location"])
            elif t == "AstStatLocal":
                vars_, vals_ = n["vars"], n["values"]
                for var, val in zip(vars_, vals_):
                    if val["type"] == "AstExprLocal":
                        alias.setdefault(var["location"], set()).add(val["local"]["location"])
                        if val["local"]["location"] in vm_decls:
                            local_copies.append((var["location"], val["local"]["location"]))
            elif t == "AstStatForIn":
                vals_ = n["values"]
                if len(vals_) >= 2 and vals_[1]["type"] == "AstExprLocal":
                    iterated.add(vals_[1]["local"]["location"])

        for me, items in table_assigns:
            link = None
            saved = []
            for it in items:
                v = it["value"]
                if v["type"] == "AstExprLocal" and it["kind"] == "general" and \
                        (v["local"]["location"] == me or alias.get(v["local"]["location"]) == {me}):
                    kn = it["key"]
                    while kn.get("type") == "AstExprGroup":
                        kn = kn["expr"]
                    if kn.get("type") == "AstExprUnary" and kn.get("op") == "Minus" and "value" in kn.get("expr", {}):
                        link = -kn["expr"]["value"]
                    else:
                        link = kn.get("value")
                elif v["type"] == "AstExprLocal":
                    saved.append(v["local"])
            if link is not None:
                self.kstack_key = me
                self.kstack_link = S.fix_int(link)
                for loc in saved:
                    self.special[loc["location"]] = ("pseudo", loc["name"])

        for var_loc, val_loc in local_copies:
            if val_loc not in self.special and var_loc in iterated:
                self.special[val_loc] = "sink"

        for loc in iterated & cleared:
            if loc in vm_decls and loc not in self.special:
                self.special[loc] = "sink"

    def is_dispatch(self, node):
        return id(node) in self.dispatch

    def proto_index(self):
        return self.info.get("proto_index", 1)

    def upvals_index(self):
        return self.info.get("upvals_index", 2)

    def maker_args(self, vmobj, proto, upvals, cap=None):
        n = len(self.maker["args"])
        vals = [None] * max(n, 3)
        if self.info.get("mode") == "dispatch_local" and cap is not None:
            if self.info.get("chain"):
                return [upvals] * max(n, 3)
            # this build's factory does not take (vmobj, proto, upvals): its
            # real arguments were captured per proto (`__PA[pv]` holds every
            # free name, the parameters included)
            for i, a in enumerate(self.maker["args"]):
                nm = a["name"]
                if nm == "..." :
                    continue
                if nm in cap:
                    vals[i] = cap[nm]
            return vals
        vals[0], vals[self.proto_index()], vals[self.upvals_index()] = vmobj, proto, upvals
        return vals

    def proto_of(self, cap):
        p = cap.get("self")
        return p if p is not None else cap.get(self.maker["args"][self.proto_index()]["name"])

    def vmobj_of(self, cap):
        if self.info.get("chain"):
            c0 = self.info["chain"][0]
            if c0.get("args"):
                v = cap.get(c0["args"][0]["name"])
                if v is not None:
                    return v
        if not self.maker.get("args"):   # dispatch-local VMs: maker takes no args
            return None
        return cap.get(self.maker["args"][0]["name"])

def find_ctor_funcs(root):
    """Functions in every `setmetatable({...})`-style table constructor:
    key -> AstExprFunction. Luraph can ship several ctor tables (one per VM
    family); every function in any of them can be bound to an OpaqueFn, so
    keys from all tables merge (int keys of later tables offset by their
    position to avoid collisions)."""
    out = {}
    tables = []
    for n in iter_nodes(root):
        if n.get("type") != "AstExprTable":
            continue
        fns = sum(1 for it in n["items"] if it["value"]["type"] == "AstExprFunction")
        if fns:
            tables.append((fns, n))
    tables.sort(key=lambda t: -t[0])
    for rank, (_, table) in enumerate(tables):
        pos = 0
        for it in table["items"]:
            if it["kind"] == "item":
                pos += 1
            if it["value"]["type"] != "AstExprFunction":
                continue
            if it["kind"] == "item":
                out.setdefault(pos if rank == 0 else 100000 * (rank + 1) + pos, it["value"])
            elif it["kind"] == "record":
                out.setdefault(it["key"]["value"].encode("latin-1"), it["value"])
            elif it["kind"] == "general" and it["key"]["type"] == "AstExprConstantNumber":
                out.setdefault(S.fix_int(it["key"]["value"]), it["value"])
            elif it["kind"] == "general" and it["key"]["type"] == "AstExprConstantString":
                out.setdefault(it["key"]["value"].encode("latin-1"), it["value"])
    return out

class VMCrash(Unsupported):
    pass

class Overlay:
    """Path-sensitive writes to the proto's instruction arrays and buffers.
    Luraph decrypts code in place, in XOR layers (several decryptors can cover
    one slot); decryptors on different paths must not see each other's
    effects. Persistent chain of dicts; `h` hashes the content (vs the base)
    so equal overlays from different paths merge."""
    __slots__ = ("parent", "d", "h", "depth")
    MASK = (1 << 64) - 1

    def __init__(self, parent=None):
        self.parent = parent
        self.d = {}
        self.h = parent.h if parent else 0
        self.depth = parent.depth + 1 if parent else 0

    def get(self, key, base):
        o = self
        while o is not None:
            if key in o.d:
                return o.d[key]
            o = o.parent
        return base

    def set(self, key, value, base_value):
        old = self.get(key, base_value)
        if _differs(old, base_value):
            self.h = (self.h - hash((key, _hv(old)))) & self.MASK
        if _differs(value, base_value):
            self.h = (self.h + hash((key, _hv(value)))) & self.MASK
        self.d[key] = value

    def flattened(self):
        if self.depth < 24:
            return self
        o = Overlay()
        chain = []
        x = self
        while x is not None:
            chain.append(x)
            x = x.parent
        for x in reversed(chain):
            o.d.update(x.d)
        o.h = self.h
        return o

def _differs(a, b):
    return type(a) is not type(b) or not S.lua_eq(a, b)

def _hv(v):
    if isinstance(v, (int, float, bytes, bool)) or v is None:
        return v
    return id(v)

def _pack_sig(l):
    return re.sub(r"\d+_\d+_", "_", fmt_expr(l))

class State:
    """(mode, pc, loop-stack, known jump-register values, array overlay) at an
    instruction boundary."""
    __slots__ = ("mode", "pc", "kstack", "jregs", "ov", "packs", "locs")

    def __init__(self, mode, pc, kstack, jregs=(), ov=None, packs=(), locs=()):
        self.mode, self.pc, self.kstack, self.jregs, self.ov = mode, pc, kstack, jregs, ov
        self.packs = packs    
        self.locs = locs      

    def key(self, link):
        d = 0
        k = self.kstack
        if isinstance(k, JitFrame):
            d, k = k.depth, None
        while isinstance(k, LTable):
            d += 1
            k = k.get(link)
        return (self.mode, self.pc, d, tuple((rk, _hv(rv)) for rk, rv in self.jregs), self.ov.h if self.ov is not None else 0,
                tuple((r, _pack_sig(l)) for r, l in self.packs),
                tuple((kk, _carry_key(v)) for kk, v in self.locs))

WALK_MAX_ERRORS = 100
WALK_RESTARTS = 64
WALK_LIMIT = int(os.environ.get("DEVIRT_WALK_LIMIT", 250000))

def _carry_key(v):
    """Canonical state-key form of a carried local's value (equal states must
    merge even when the value objects differ, e.g. two Const(False))."""
    if isinstance(v, RegFile):
        return "RF"
    if isinstance(v, EnvTable):
        return "ENV"
    if isinstance(v, LTable):
        return "T%s" % v.tid
    if isinstance(v, (Builtin, OpaqueFn)):
        return repr(v)
    if isinstance(v, ClosureExpr):
        return "C<%s>" % (getattr(v.proto, "tid", None),)
    if isinstance(v, Expr):
        return fmt_expr(v)
    if isinstance(v, str):
        return sys.intern(v)
    if v is None or isinstance(v, (bytes, int, float, bool)):
        return v
    return id(v)

MAX_STACK_DEPTHS = int(os.environ.get('DEVIRT_MAX_DEPTHS', 32))
STACK_WALK_MAX = 30000

def _locs_lt(a, b):
    """Ordering over carried-local tuples that never raises. The same local
    can carry an int (the stack pointer) in one state and None in another,
    and different states carry different key sets -- raw tuple comparison
    raises (int < None). Keys compare first, then values on a total form."""
    if a == b:
        return False
    def form(l):
        ks, vs = [], []
        for k, v in l:
            ks.append((0, k, "") if isinstance(k, int) else (1, 0, str(k)))
            c = _carry_key(v)
            if isinstance(c, bool):
                c = int(c)
            if isinstance(c, (int, float)):
                vs.append((0, c, ""))
            elif c is None:
                vs.append((1, 0, ""))
            else:
                vs.append((2, 0, str(c)))
        return ks, vs
    return form(a) < form(b)

class ProtoLifter:
    """Steps the instructions of one proto."""
    walk_only = False   

    def __init__(self, vm, dump, vmobj, proto, upvals, globals_tab, cap=None, shared=None):
        self.vm = vm
        self.vmobj = vmobj
        self.dump = dump
        self.cap = cap
        # by-name fallback for the capture's values (see Interp.getvar):
        # a captured proto gets its own capture; an uncaptured child gets the
        # VM-wide shared fields (A/P/j/l) every proto's capture agrees on
        self.cap_fallback = {}
        src = cap if cap is not None else (shared or {})
        for nm, v in src.items():
            if nm in ("self", "__maker", "__seq"):
                continue
            if v is None or isinstance(v, (LTable, Builtin, OpaqueFn, Opaque,
                                           int, float, bytes, bool)):
                self.cap_fallback[nm] = v
        self.special = vm.special
        self.globals_tab = globals_tab
        self.out = []
        self.temp_prefix = ""
        self.tcount = 0
        self.proto_arrays = set()
        self.reg_arrays = set()      
        self.children = []
        self.requests = set()
        self.jump_regs = set()
        self.need_jump_regs = set()
        self.cff_regs = set()
        self.merged_int_regs = set()
        self.arith_regs = set()
        self.int_regs = set()
        self.jvals = {}
        self.jread = set()
        self.reg_gen = {}
        self.reg_def_idx = {}
        self.war_saved = {}
        self.cur_it = None
        self.stack_base = None       
        self.captured_regs = set()   
        self.frame_uses = set()      
        self.packs = {}         
        self.pack_copies = {}
        self.pack_read = set()
        self.pack_unstable = set()   
        self.pack_killed = set()     
        self.ov = None          
        self.ov_base = None
        self.in_prologue = False
        self.cur_scope = None
        self.reg_prefix = "r"
        self.jstack = None           
        self.proto = proto
        for v in proto.h.values():
            if isinstance(v, LTable) and v is not vmobj:
                self.proto_arrays.add(id(v))
        if cap is not None and vm.info.get("mode") == "dispatch_local":
            for k, v in cap.items():
                if isinstance(v, LTable) and v is not vmobj and k not in ("self", "U"):
                    self.proto_arrays.add(id(v))
        self.making = False
        if isinstance(proto, JitProto):

            self.maker_scope = proto.env
            return

        it = S.Interp(self)
        self.making = True
        env0 = Scope()
        if cap is not None and getattr(vm, "outer", None):
            # free names of the VM closure the maker's own scope cannot
            # resolve (helpers registered in an enclosing method: A, P, ...)
            # come from the capture, bound at their real declaration keys so
            # a scope miss falls back to the same values the real run saw.
            # Attached before the maker call: the maker's body references
            # them too (it registers itself into the helper table).
            for key, nm in vm.outer.items():
                if nm not in cap:
                    continue
                v = cap[nm]
                if v is None or isinstance(v, (LTable, Builtin, OpaqueFn, Opaque,
                                               int, float, bytes, bool)):
                    env0.vars[key] = v
            for cfn in vm.info.get("chain") or ():
                cbody = cfn.get("body", {}).get("body") or ()
                lstats = [st for st in cbody if st.get("type") == "AstStatLocal"]
                if lstats:
                    try:
                        it.exec_block(lstats, env0)
                    except Exception:
                        pass
        r = it.call_lua(LuaFunc(vm.maker, env0), Multi(vm.maker_args(vmobj, proto, upvals, cap)))
        self.making = False
        f = r.first() if isinstance(r, Multi) else r
        if not isinstance(f, LuaFunc) or f.node is not vm.vm:
            raise Unsupported("closure maker did not return the VM closure")
        self.maker_scope = f.env

    def initial_state(self):
        self.in_prologue = True
        cs = Scope(self.maker_scope)
        cs.vars["..."] = Multi([], VarargTail(1))
        self.cur_scope = cs
        it = S.Interp(self)
        it.exec_block(self.vm.prologue, cs)
        self.in_prologue = False
        self.closure_scope = cs
        return cs

    def state_packs(self):
        """The unread packs carried into the next state."""
        return tuple(sorted(((r, l) for r, l in self.packs.items() if r not in self.pack_read
                             and (r, _pack_sig(l)) not in self.pack_unstable), key=lambda kv: kv[0]))

    def is_dispatch(self, node):
        return self.vm.is_dispatch(node)

    def _fix_war_expr(self, e):
        if not self.reg_gen or e is None:
            return e
        if isinstance(e, Reg):
            g = getattr(e, "_gen", None)
            if g is not None and g < self.reg_gen.get(e.n, 0):
                key = (e.n, g)
                sc = self.war_saved.get(key)
                if sc is None:
                    sc = Reg(810001 + len(self.war_saved))
                    self.war_saved[key] = sc
                    idx = self.reg_def_idx[key]
                    self.out.insert(idx, Assign(sc, Reg(e.n)))
                    for k, v in list(self.reg_def_idx.items()):
                        if v >= idx:
                            self.reg_def_idx[k] = v + 1
                    if self.cur_it is not None:
                        self.cur_it.dlog = [
                            (dp, at + 1 if at >= idx else at, cd, dv)
                            for dp, at, cd, dv in self.cur_it.dlog
                        ]
                return sc
            return e
        if isinstance(e, Index):
            return Index(self._fix_war_expr(e.obj), self._fix_war_expr(e.key))
        if isinstance(e, Bin):
            return Bin(e.op, self._fix_war_expr(e.a), self._fix_war_expr(e.b))
        if isinstance(e, Un):
            return Un(e.op, self._fix_war_expr(e.a))
        if isinstance(e, IfExp):
            return IfExp(self._fix_war_expr(e.c), self._fix_war_expr(e.a), self._fix_war_expr(e.b))
        return e

    def _resolve_jval(self, v):
        if isinstance(v, Const) and isinstance(v.v, int) and not isinstance(v.v, bool):
            return v.v
        if isinstance(v, Reg):
            for prev in reversed(self.out):
                if isinstance(prev, Assign) and isinstance(prev.target, Reg) and prev.target.n == v.n:
                    return self._resolve_jval(prev.value)
            f = getattr(self, "cur_facts", {}).get(v.n)
            if isinstance(f, tuple) and f[0] == "c" and isinstance(f[1], int) and not isinstance(f[1], bool):
                return f[1]
        return None

    def emit(self, st):
        if isinstance(st, Assign):
            if not isinstance(st.target, Reg):
                st.target = self._fix_war_expr(st.target)
            st.value = self._fix_war_expr(st.value)
        elif isinstance(st, CallStmt):
            st.fn = self._fix_war_expr(st.fn)
            st.args = Multi([self._fix_war_expr(x) for x in st.args.items], st.args.tail)
        if isinstance(st, Assign) and isinstance(st.target, Reg):
            old = self.packs.pop(st.target.n, None)
            if old is not None and st.target.n not in self.pack_read:
                self.pack_killed.add((st.target.n, _pack_sig(old)))
            self.pack_copies.pop(st.target.n, None)
            if isinstance(st.value, SymList):
                self.packs[st.target.n] = st.value
        if isinstance(st, Assign) and isinstance(st.target, Reg) and (
                self.jvals.get(st.target.n) is FRAME or isinstance(self.jvals.get(st.target.n), OpaqueFn)):
            del self.jvals[st.target.n]
        if isinstance(st, Assign) and isinstance(st.target, Reg):
            jv0 = self._resolve_jval(st.value)
            if jv0 is not None:
                self.int_regs.add(st.target.n)
            if isinstance(st.value, Bin) and st.value.op in ("Add", "Sub", "Mul", "Div", "FloorDiv", "Mod", "Pow", "Concat"):
                self.arith_regs.add(st.target.n)
                for rx in (st.value.a, st.value.b):
                    if isinstance(rx, Reg):
                        self.arith_regs.add(rx.n)
            if st.target.n in self.cff_regs and st.target.n in self.jread:
                self.arith_regs.add(st.target.n)
                self.cff_regs.discard(st.target.n)
                self.jump_regs.discard(st.target.n)
                self.jvals.pop(st.target.n, None)
                self.cff_dropped = True
        if isinstance(st, Assign) and isinstance(st.target, Reg) and st.target.n in self.cff_regs:
            jv = self._resolve_jval(st.value)
            if jv is not None:
                self.jvals[st.target.n] = jv
                self.jread.discard(st.target.n)
            else:
                self.jvals.pop(st.target.n, None)
            st.jump = True
        elif isinstance(st, Assign) and isinstance(st.target, Reg) and st.target.n in self.jump_regs \
                and self.stack_base is not None and isinstance(st.target.n, int) and st.target.n > self.stack_base:

            jv = self._resolve_jval(st.value)
            if jv is not None:
                self.jvals[st.target.n] = jv
                self.jread.discard(st.target.n)
            else:
                self.jvals.pop(st.target.n, None)
        elif isinstance(st, Assign) and isinstance(st.target, Reg) and st.target.n in self.jump_regs:
            jv = self._resolve_jval(st.value)
            if jv is not None:
                self.jvals[st.target.n] = jv
                self.jread.discard(st.target.n)
            else:
                self.jvals.pop(st.target.n, None)
            st.jump = True
        elif isinstance(st, Assign) and isinstance(st.target, Reg) and not isinstance(self.jvals.get(st.target.n), JitFrame):
            self.jvals.pop(st.target.n, None)
        if isinstance(st, Assign) and isinstance(st.target, Reg):
            if not (isinstance(st.value, Reg) and st.value.n == st.target.n):
                g = self.reg_gen.get(st.target.n, 0)
                self.reg_def_idx[(st.target.n, g)] = len(self.out)
                self.reg_gen[st.target.n] = g + 1
        self.out.append(st)

    def new_temp(self):
        self.tcount += 1
        return "%s%d" % (self.temp_prefix, self.tcount)

    def special_get(self, sp, it):
        if sp == "sink":
            return OPENUPS
        if sp[0] == "reg":

            return self.index(REGFILE, sp[1], it)
        if sp[0] == "jstack":
            return self.jstack
        if sp[0] == "upval":
            return Upval(sp[1])
        if sp[0] == "pseudo":
            return Pseudo(sp[1], self.depth(it))
        raise Unsupported(sp)

    def special_set(self, sp, v, it):
        if sp == "sink":
            return
        if sp[0] in ("reg", "jstack", "upval") and self.in_prologue:
            return      
        if sp[0] == "upval":
            self.emit(Assign(Upval(sp[1]), self.value_of(v)))
            return
        if sp[0] == "jstack":
            if isinstance(v, Multi):
                v = v.first()
            if v is None:
                self.jstack = JIT_BOTTOM
                return
            if isinstance(v, JitFrame):
                self.jstack = v         
                return
            link = [k for k, x in v.h.items() if isinstance(x, JitFrame)] if isinstance(v, LTable) else []
            if isinstance(v, LTable) and v.tid is None and len(link) <= 1:

                parent = v.h[link[0]] if link else JIT_BOTTOM
                fr = JitFrame(link[0] if link else None, parent.depth + 1)
                if link:
                    fr.h[link[0]] = parent
                for k, x in v.h.items():
                    if not link or k != link[0]:
                        pv = Pseudo("JIT%s" % k, fr.depth)
                        self.emit(Assign(pv, self.value_of(x)))
                        fr.h[k] = pv
                self.jstack = fr
                return
            raise Unsupported("LPH_JIT loop stack set to %r (%s; stack %s)" % (
                v, {k: fmt_any(x) for k, x in v.h.items()} if isinstance(v, LTable) else "", fmt_any(self.jstack)))
        if sp[0] == "reg":
            if isinstance(v, Multi):
                v = v.first()
            if isinstance(v, JitFrame):

                self.jvals[sp[1]] = v
                return
            if isinstance(self.jvals.get(sp[1]), JitFrame):
                del self.jvals[sp[1]]
            if isinstance(v, LTable) and v.tid is None and v.h:

                keys = sorted(v.h, key=lambda k: (not isinstance(k, int), repr(k)))
                seq = keys == list(range(1, len(keys) + 1))
                items = [(None if seq else self.as_expr(k), self.value_of(v.h[k])) for k in keys]
                self.newindex(REGFILE, sp[1], S.NewTable(items), it)
                return
            self.newindex(REGFILE, sp[1], v, it)
            return
        if sp[0] == "pseudo":
            self.emit(Assign(Pseudo(sp[1], self.depth(it)), self.value_of(v)))
            return
        raise Unsupported(sp)

    def depth(self, it):
        if isinstance(getattr(self, "jstack", None), JitFrame):
            return self.jstack.depth
        if not self.vm.kstack_key:
            return 0
        k = self.cur_scope.lookup(self.vm.kstack_key)
        kv = k.vars[self.vm.kstack_key] if k else None
        d = 0
        while isinstance(kv, LTable):
            d += 1
            if d > 8:
                raise Unsupported("kstack depth %d exceeds limit" % d)
            kv = kv.get(self.vm.kstack_link)
        return d

    def jit_closure(self, fn):
        """A Lua function made inside an LPH_JIT function -> ClosureExpr
        lifted with its own JitModel. The outer locals it uses are upvalues:
        registers by reference, instruction temps with a symbolic value
        copied into a register first."""
        jm = _jit_nested_model(fn.node)
        if jm is None:
            raise Unsupported("a Lua function in an LPH_JIT function that is not a state machine")
        declared = _declared_in(fn.node)
        ups, upmap = [], {}
        for n in iter_nodes(fn.node):
            if n.get("type") != "AstExprLocal":
                continue
            loc = n["local"]["location"]
            if loc in declared or loc in upmap:
                continue
            sp = self.special.get(loc)
            if sp is not None and sp[0] == "reg":
                ups.append(Reg(sp[1]))
            elif sp is not None and sp[0] == "upval":
                ups.append(Upval(sp[1]))
            else:
                sc = fn.env.lookup(loc)
                v = sc.vars[loc] if sc is not None else None
                if not is_sym(v):
                    continue        
                self.tmp_regs = getattr(self, "tmp_regs", 0) + 1
                r = Reg(JIT_TMP + self.tmp_regs)
                self.emit(Assign(r, self.value_of(v)))
                ups.append(r)
            upmap[loc] = len(ups)
        c = ClosureExpr(JitProto(fn.env, upmap), ups)
        c.vm = jm
        for u in ups:
            if isinstance(u, Reg):
                self.captured_regs.add(u.n)
        self.children.append(c)
        return c

    def parallel_values(self, targets, vals, it):
        """`a, b = b, a` / `t[1], t[2] = t[2], t[1]`: Lua evaluates every value
        before assigning, but IR assignments are statements in order and
        register reads are references. A value that reads what an earlier
        target of the same statement writes (a register, or any table slot
        when a table store came first) is copied into a fresh register
        first."""
        regs = set()
        stored = False          
        out = list(vals)
        for i, tg in enumerate(targets):
            x = out[i]
            if i > 0 and (regs or stored) and is_sym(x):
                hit = False
                for e in walk_expr(x):
                    if (isinstance(e, Reg) and e.n in regs) or (stored and isinstance(e, (Index, Pseudo))):
                        hit = True
                        break
                if hit:
                    self.tmp_regs = getattr(self, "tmp_regs", 0) + 1
                    t = Reg(JIT_TMP + self.tmp_regs)
                    self.emit(Assign(t, self.value_of(x)))
                    out[i] = t
            if tg[0] == "local":
                sp = self.special.get(tg[1]["location"])
                if sp is not None and sp[0] == "reg":
                    regs.add(sp[1])
            elif tg[0] == "index":
                if isinstance(tg[1], RegFile) and isinstance(tg[2], int):
                    regs.add(S.norm_key(tg[2]))
                elif is_sym(tg[1]) or isinstance(tg[1], JitFrame):
                    stored = True
        return out

    def global_value(self, name):
        v = self.globals_tab.get(name.encode("latin-1"))
        if v is None:

            return Global(name)
        return v

    def reg_array(self, key):
        """`R[base + e]`: Luraph keeps a local array in registers base..
        (fetched.lua: two 256-entry tables at 6 and 262). Lifted as a table
        `Reg(REG_ARRAY + base)` indexed by e, declared `{}` at entry."""
        if not (isinstance(key, S.Bin) and key.op == "Add"):
            return None
        a, b = key.a, key.b
        if isinstance(b, Const) and isinstance(b.v, int) and not isinstance(b.v, bool):
            a, b = b, a
        if not (isinstance(a, Const) and isinstance(a.v, int) and not isinstance(a.v, bool)):
            return None
        self.reg_arrays.add(a.v)
        return Reg(REG_ARRAY + a.v), b

    def library_name(self, t):
        if not hasattr(self, "_lib_names"):
            self._lib_names = {id(v): k.decode("latin-1") for k, v in self.globals_tab.h.items() if isinstance(k, bytes)}
        return self._lib_names.get(id(t))

    def set_global(self, name, v):

        self.emit(Assign(Global(name), self.value_of(v)))

    def varargs(self, scope):
        s = scope
        while s is not None:
            if "..." in s.vars:
                return s.vars["..."]
            s = s.parent
        raise Unsupported("varargs outside vararg function")

    def as_expr(self, v):
        if isinstance(v, MaybeBox):
            return Reg(v.reg)
        if isinstance(v, BoxPart):
            return Index(Upval(v.idx), self.as_expr(v.k))
        if isinstance(v, BoxProxy):
            return Upval(v.idx)
        if isinstance(v, Expr):
            return v
        if v is None or isinstance(v, (bool, int, float, bytes)):
            return Const(v)
        if isinstance(v, Multi):
            return self.as_expr(v.first())
        if isinstance(v, SymList):
            return v
        if isinstance(v, Vec):
            return v
        if isinstance(v, EnvTable):
            return Global("_ENV")
        if isinstance(v, LuaFunc) and isinstance(self.vm, JitModel):
            return self.jit_closure(v)
        if isinstance(v, OpaqueFn) and v.pf_tid is not None and v.node is None:
            n = self.dump.shared.setdefault(v.lfid, len(self.dump.shared) + 1)
            return SharedFn(v, n)
        if isinstance(v, OpaqueFn):
            if v.node is not None:
                clo = self.plain_closure(LuaFunc(v.node, Scope()))
                if clo is not None:
                    return clo
                return Opaque("function", self.plain_function_text(v.node) or "function(...) end")
            n = self.dump.shared.setdefault(v.lfid, len(self.dump.shared) + 1)
            return SharedFn(v, n)
        if isinstance(v, Buf):
            data = bytes(v.data)
            # A huge inlined buffer is the obfuscator's still-ENCRYPTED payload: it
            # only appears when the real code never decrypted (a game-locked script
            # run without the right game.GameId, so the loader is lifted instead of
            # the payload). Emitting its megabytes of \xNN escapes doubles the file
            # and is useless; leave a short placeholder that says what it is.
            # 512 KB: an encrypted payload is the whole script's bytecode (MBs);
            # a genuine inlined data buffer in real code is far smaller, so this
            # never clips legitimate data.
            cap = int(os.environ.get("DEOB_MAX_BUF", "524288"))
            if len(data) > cap:
                return Opaque("buffer",
                    "buffer.create(%d) --[[ %d bytes of encrypted Luraph payload, NOT decrypted. "
                    "This script is game-locked: its payload key mixes game.GameId, so re-run passing "
                    "the real id (--cfg-json '{\"__superz_game_id\":N,\"__superz_place_id\":M}'). ]]"
                    % (len(data), len(data)))
            t = self.new_temp()
            self.emit(CallStmt(t, Global("buffer.fromstring"), Multi([Const(data)])))
            return TempVal(t, 1)
        if isinstance(v, Builtin) and v.fn is None:

            return Global(v.name)
        if isinstance(v, LuaFunc):
            clo = self.plain_closure(v)
            if clo is not None:
                return clo
            text = self.plain_function_text(v)
            if text is not None:
                return Opaque("function", text)
            return Opaque("function", "function(...) end")
        raise Unsupported("value %r in an expression" % (v,))

    def plain_closure(self, fn):
        """A plain Lua function that captures outer locals via the maker function."""
        node = fn.node
        lines = getattr(self.vm, "src_lines", None)
        if not isinstance(node, dict) or node.get("type") != "AstExprFunction" or not lines:
            return None
        declared = _declared_in(node)
        undeclared = [n for n in iter_nodes(node) if n.get("type") == "AstExprLocal" and n["local"]["location"] not in declared]
        if not undeclared or not hasattr(fn, "env") or fn.env is None:
            return None

        parent_map = {}
        for n in iter_nodes(node):
            for k, val in n.items():
                if isinstance(val, dict):
                    parent_map[id(val)] = (n, k)
                elif isinstance(val, list):
                    for item in val:
                        if isinstance(item, dict):
                            parent_map[id(item)] = (n, k)

        m = re.fullmatch(r"(\d+),(\d+) - (\d+),(\d+)", node["location"])
        if not m:
            return None
        l1, c1, l2, c2 = (int(x) for x in m.groups())

        replacements = []
        ups = []
        for n in undeclared:
            loc = n["local"]["location"]
            sc = fn.env.lookup(loc)
            val = sc.vars[loc] if sc is not None else None
            p, _ = parent_map.get(id(n), (None, None))
            if isinstance(val, LTable) and p and p.get("type") == "AstExprIndexExpr":
                idx_node = p.get("index", {})
                if idx_node.get("type") == "AstExprConstantNumber":
                    k = int(idx_node["value"])
                    item = val.get(k)
                    if isinstance(item, Reg):
                        self.captured_regs.add(item.n)
                        ups.append(item)
                        pm = re.fullmatch(r"(\d+),(\d+) - (\d+),(\d+)", p["location"])
                        if pm:
                            _, pc1, _, pc2 = (int(x) for x in pm.groups())
                            replacements.append((pc1 - c1, pc2 - c1, "reg", item.n))
                            continue
                    elif isinstance(item, Global):
                        pm = re.fullmatch(r"(\d+),(\d+) - (\d+),(\d+)", p["location"])
                        if pm:
                            _, pc1, _, pc2 = (int(x) for x in pm.groups())
                            replacements.append((pc1 - c1, pc2 - c1, "global", item.name))
                            continue
                    elif isinstance(item, Builtin):
                        pm = re.fullmatch(r"(\d+),(\d+) - (\d+),(\d+)", p["location"])
                        if pm:
                            _, pc1, _, pc2 = (int(x) for x in pm.groups())
                            replacements.append((pc1 - c1, pc2 - c1, "builtin", item.name))
                            continue
            elif isinstance(val, Reg):
                self.captured_regs.add(val.n)
                ups.append(val)
                nm = re.fullmatch(r"(\d+),(\d+) - (\d+),(\d+)", n["location"])
                if nm:
                    _, nc1, _, nc2 = (int(x) for x in nm.groups())
                    replacements.append((nc1 - c1, nc2 - c1, "reg", val.n))
                    continue
            elif isinstance(val, Global):
                nm = re.fullmatch(r"(\d+),(\d+) - (\d+),(\d+)", n["location"])
                if nm:
                    _, nc1, _, nc2 = (int(x) for x in nm.groups())
                    replacements.append((nc1 - c1, nc2 - c1, "global", val.name))
                    continue
            return None

        proto = PlainProto(fn, node, replacements, lines)
        c = ClosureExpr(proto, ups)
        self.children.append(c)
        return c

    def plain_function_text(self, fn):
        """A trivial function Luraph compiles to plain Lua instead of bytecode
        (Script42: a closure op whose maker is `function() return function()
        return {} end end`): its source text, if it reads no outer locals."""
        node = fn.node if not isinstance(fn, dict) else fn
        lines = getattr(self.vm, "src_lines", None)
        if not isinstance(node, dict) or node.get("type") != "AstExprFunction" or not lines:
            return None
        declared = _declared_in(node)
        for n in iter_nodes(node):
            if n.get("type") == "AstExprLocal" and n["local"]["location"] not in declared:
                return None
        m = re.fullmatch(r"(\d+),(\d+) - (\d+),(\d+)", node["location"])
        if not m:
            return None
        l1, c1, l2, c2 = (int(x) for x in m.groups())
        if l1 == l2:
            text = lines[l1][c1:c2]
        else:
            text = "\n".join([lines[l1][c1:]] + lines[l1 + 1:l2] + [lines[l2][:c2]])
        return text if len(text) <= 2000 else None

    def sym_binop(self, op, a, b):
        if isinstance(a, SymList) or isinstance(b, SymList):
            if op == "Eq":
                if not isinstance(a, SymList) or not isinstance(b, SymList):
                    return False
                return a is b
            if op == "Ne":
                if not isinstance(a, SymList) or not isinstance(b, SymList):
                    return True
                return a is not b
            raise Unsupported("arith on packed list")
        if a is b and isinstance(a, Bin) and a.op == "Mod":
            if op == "CompareNe":
                return False
            if op == "CompareEq":
                return True
        if op == "Sub" and isinstance(a, Bin) and a.op == "Mod" and isinstance(a.b, Const) and a.b.v == 4294967296:
            if isinstance(b, Bin) and b.op == "Mod" and b.a is a and isinstance(b.b, Const) and b.b.v == 1:
                res = Reg(a.a.n) if isinstance(a.a, Reg) else a.a
                res._u32_trunc = True
                return res
        return Bin(op, self.as_expr(a), self.as_expr(b))

    def sym_unop(self, op, a):
        if isinstance(a, SymList):
            if op == "Len":
                return a.count_expr()
            if op == "Not":
                return False
            raise Unsupported("unop on packed list")
        return Un(op, self.as_expr(a))

    def sym_and_or(self, kind, a, rhs):
        b = rhs()
        return Bin("And" if kind == "and" else "Or", self.as_expr(a), self.as_expr(b))

    def _need_jreg(self, *xs):
        if self.stack_base is not None:
            for x in xs:
                if isinstance(x, Expr):
                    for r in expr_regs(x):
                        if isinstance(r.n, int) and r.n > self.stack_base and r.n not in self.jump_regs:
                            self.need_jump_regs.add(r.n)

    def index(self, obj, key, it):
        if isinstance(obj, Multi):
            obj = obj.first()
        if isinstance(key, Multi):
            key = key.first()
        if isinstance(obj, RegFile):
            if is_sym(key):
                arr = self.reg_array(key)
                if arr is None:
                    self._need_jreg(key)
                    raise Unsupported("symbolic register index")
                return Index(*arr)
            k = S.norm_key(key)
            if isinstance(k, (int, float)) and k < 1 and self.stack_base is not None:
                raise Unsupported("read below the stack VM's frame (register %s)" % k)
            if isinstance(k, (int, float)) and (k < 0 or (1024 < k < 800000)) and self.stack_base is None:
                raise Unsupported("corrupt/encrypted register index %s" % k)
            if self.jvals.get(k) is FRAME:
                return obj
            if k in self.jvals:
                self.jread.add(k)
                return self.jvals[k]
            if k in self.packs:
                self.pack_read.add(k)
                c = self.pack_copies.get(k)
                if c is None:
                    src = self.packs[k]
                    c = SymList(src.items, src.tail, src.nkey)
                    c.extra = dict(src.extra)
                    self.pack_copies[k] = c
                return c
            r = Reg(k)
            r._gen = self.reg_gen.get(k, 0)
            return r
        if isinstance(obj, EnvTable):
            if isinstance(key, bytes):
                return Global(key.decode("latin-1"))
            return Index(Global("_ENV"), self.as_expr(key))
        if isinstance(obj, UpContainer):
            return Upval(obj.idx)
        if isinstance(obj, UpList):
            if not isinstance(key, int):
                raise Unsupported("upvalue index %r" % (key,))
            return obj.get(key)
        if isinstance(obj, FrameProxy):
            if not isinstance(key, int):
                raise Unsupported("symbolic index into a captured frame")
            self.frame_uses.add((obj.idx, key))
            return Upval((obj.idx, key))
        if isinstance(obj, OpenUps):
            if not isinstance(key, int):
                raise Unsupported("open upvalue index %r" % (key,))
            return MaybeBox(key)
        if isinstance(obj, MaybeBox):
            return None
        if isinstance(obj, BoxProxy):
            if is_sym(key):
                return Index(Upval(obj.idx), self.as_expr(key))
            return BoxPart(obj.idx, key)
        if isinstance(obj, BoxPart):
            if isinstance(key, BoxPart) and key.idx == obj.idx:
                return Upval(obj.idx)
            return Index(self.as_expr(obj), self.as_expr(key))
        if isinstance(obj, LTable):
            if is_sym(key) and obj is self.vmobj and isinstance(key, Index) and isinstance(key.key, Index) \
                    and key.key.obj == key.obj and isinstance(key.key.key, Const):

                return RuntimeMaker()
            if is_sym(key):
                if self.walk_only and any(isinstance(x, Missing) for x in walk_expr(key)):

                    return Missing(None)
                if os.environ.get("DEVIRT_TB"):
                    print("   table tid=%s path=%s items=%s" % (obj.tid, self.dump.paths().get(obj.tid), str(list(obj.h.items())[:12])), file=sys.stderr)
                raise Unsupported("symbolic index into a concrete VM table (key %s)" % fmt_expr(key))
            v = obj.get(key)
            if self.ov_base is not None and obj.tid is not None:
                v = self.cur_ov().get((id(obj), S.norm_key(key)), v)
            if v is None and (obj.tid, S.norm_key(key)) in self.dump.late:

                return self.dump.late[(obj.tid, S.norm_key(key))]
            if obj.tid in self.dump.lazy and isinstance(key, int) and self.ov_base is not None:

                k0 = obj.get(0)
                if isinstance(k0, LTable):
                    base = k0.get(key)
                    cur = self.cur_ov().get((id(k0), key), base)
                    if _differs(cur, base):
                        path = self.dump.paths().get(obj.tid)
                        if path is None:
                            self.dump.miss("override without path")
                            return Missing(key)
                        rq = ",".join(str(x) for x in path) + ",%d@%s" % (key, S.fmt_num(cur))
                        if self.dump.overrides.get(rq) is not None:
                            return self.dump.overrides[rq]
                        same = self.dump.same_operand(rq, obj.tid)
                        if same is not None:
                            return same
                        got = self.dump.fetch(rq)
                        if got is not None:
                            return got
                        self.requests.add(rq)

                        self.dump.miss("override failed" if rq in self.dump.overrides else "override requested")
                        return Missing(key)
            if v is None and obj.tid in self.dump.lazy and isinstance(key, (int, bytes)):
                path = self.dump.paths().get(obj.tid)
                k = key.decode("latin-1") if isinstance(key, bytes) else key
                if path is not None and not (isinstance(k, str) and (k.isdigit() or "," in k or ";" in k)):
                    rq = ",".join(str(x) for x in path + [k])
                    if self.dump.overrides.get(rq) is not None:

                        return self.dump.overrides[rq]
                    k0 = obj.get(0)
                    op = k0.get(key) if isinstance(k0, LTable) and isinstance(key, int) else None
                    if type(op) in (int, float):
                        same = self.dump.same_operand("%d@%s" % (key, S.fmt_num(op)), obj.tid)
                        if same is not None:
                            return same
                    got = self.dump.fetch(rq)
                    if got is not None:
                        return got
                    self.requests.add(rq)
                if not self.making:
                    self.dump.miss("plain, path" if path is not None else "plain, no path")
                    v = Missing(key)
            return v
        if isinstance(obj, SymList):
            return self.symlist_get(obj, key)
        if isinstance(obj, Expr):
            return Index(obj, self.as_expr(key))
        if obj is None:
            raise Unsupported("index nil")
        raise Unsupported("index %r" % (obj,))

    def symlist_get(self, lst, key):
        if key == lst.nkey or (lst.nkey is None and key == b"n"):
            return lst.count_expr()
        if isinstance(key, int) and key >= 1:
            if key <= len(lst.items):
                return lst.items[key - 1]
            if lst.tail is not None:
                return lst.tail.at(key - len(lst.items))
            return None
        if key in lst.extra:
            return lst.extra[key]
        if is_sym(key):
            return Index(self.as_expr(lst), self.as_expr(key))
        raise Unsupported("packed list index %r" % (key,))

    def newindex(self, obj, key, v, it):
        if isinstance(key, Multi):
            key = key.first()
        if isinstance(obj, RegFile):
            if is_sym(key):
                arr = self.reg_array(key)
                if arr is None:
                    self._need_jreg(key)
                    raise Unsupported("symbolic register store")
                self.emit(Assign(Index(*arr), self.value_of(v)))
                return
            if isinstance(v, RegFile):
                self.jvals[S.norm_key(key)] = FRAME
                self.jread.discard(S.norm_key(key))
                return
            if isinstance(v, OpaqueFn) and v.pf_tid is not None:
                self.jvals[S.norm_key(key)] = v
                self.jread.discard(S.norm_key(key))
                return
            if isinstance(key, (int, float)) and key < 1 and self.stack_base is not None:
                raise Unsupported("store below the stack VM's frame (register %s)" % key)
            if isinstance(key, (int, float)) and (key < 0 or (1024 < key < 800000)) and self.stack_base is None:
                raise Unsupported("corrupt/encrypted register store %s" % key)
            self.emit(Assign(Reg(S.norm_key(key)), self.value_of(v)))
            return
        if isinstance(obj, FrameProxy):
            if not isinstance(key, int):
                raise Unsupported("symbolic store into a captured frame")
            self.frame_uses.add((obj.idx, key))
            self.emit(Assign(Upval((obj.idx, key)), self.value_of(v)))
            return
        if isinstance(obj, EnvTable):
            tgt = Global(key.decode("latin-1")) if isinstance(key, bytes) else Index(Global("_ENV"), self.as_expr(key))
            self.emit(Assign(tgt, self.value_of(v)))
            return
        if isinstance(obj, UpContainer):
            self.emit(Assign(Upval(obj.idx), self.value_of(v)))
            return
        if isinstance(obj, OpenUps):
            if v is None and isinstance(key, int):
                self.emit(Close(key))
            return
        if isinstance(obj, MaybeBox):
            return
        if isinstance(obj, BoxPart):
            if isinstance(key, BoxPart) and key.idx == obj.idx:
                self.emit(Assign(Upval(obj.idx), self.value_of(v)))
            else:
                self.emit(Assign(Index(self.as_expr(obj), self.as_expr(key)), self.value_of(v)))
            return
        if isinstance(obj, BoxProxy):
            self.emit(Assign(Index(Upval(obj.idx), self.as_expr(key)), self.value_of(v)))
            return
        if isinstance(obj, JitFrame) and obj.depth > 0:
            k = S.norm_key(key)
            if k == obj.link:
                raise Unsupported("store into an LPH_JIT loop stack link")
            pv = Pseudo("JIT%s" % k, obj.depth)
            self.emit(Assign(pv, self.value_of(v)))
            obj.h[k] = pv
            return
        if isinstance(obj, LTable):
            if is_sym(key):
                raise Unsupported("symbolic key store into a concrete VM table")
            if id(obj) in self.proto_arrays:
                if is_sym(v):
                    if os.environ.get("DEVIRT_SYMSTORE"):
                        print("[symstore] tid=%s key=%r v=%s" % (obj.tid, key, fmt_expr(v)[:300]), file=sys.stderr)
                    self.out.clear()
                    raise Unsupported("symbolic value store into proto array")
                self.mutated = True
            if self.ov_base is not None and obj.tid is not None:

                self.write_ov((id(obj), S.norm_key(key)), v, obj.get(key))
                return
            obj.set(key, v)
            return
        if isinstance(obj, SymList):
            if key == lst_nkey(obj):
                return  
            if isinstance(key, int) and key >= 1:
                while len(obj.items) < key and obj.tail is None:
                    obj.items.append(None)
                if key <= len(obj.items):
                    obj.items[key - 1] = v
                    return
            obj.extra[key] = v
            return
        if isinstance(obj, Expr):
            self.emit(Assign(Index(obj, self.as_expr(key)), self.value_of(v)))
            return
        if obj is None:
            # `t[k] = v` where t never materialized at capture (a nil slot of
            # an uncaptured table): skip -- raising used to poison the walk
            return
        raise Unsupported("newindex %r" % (obj,))

    def cur_ov(self):
        return self.ov if self.ov is not None else self.ov_base

    def write_ov(self, key, v, base):
        if self.ov is None:
            self.ov = Overlay(self.ov_base)
        self.ov.set(key, v, base)

    def check_decision(self, cond):

        if any(isinstance(x, Missing) for x in walk_expr(cond)):
            raise Unsupported("needs a constant that is not decoded yet")

    def value_of(self, v):
        """Value for an IR assignment: expressions, constants, closures, lists."""
        if isinstance(v, Multi):
            v = v.first()
        if isinstance(v, GenIterMaker):
            return GenIter(v.args)
        if isinstance(v, (ClosureExpr, GenIter)):
            return v
        if isinstance(v, LuaFunc) and isinstance(self.vm, JitModel):
            return self.jit_closure(v)
        if isinstance(v, SymList):
            return v
        if isinstance(v, LTable):
            if v is self.proto:

                raise VMCrash()
            if v is self.vmobj or id(v) in self.proto_arrays:
                return S.NewTable()
            if v.h:
                lib = self.library_name(v)
                if lib is not None:

                    return Global(lib)
                nkey = b"n"
                if all(isinstance(k, int) or k == nkey for k in v.h):
                    items = [self.value_of(v.h.get(i)) for i in range(1, max((k for k in v.h if isinstance(k, int)), default=0) + 1)]
                    return SymList(items, None, nkey=nkey if nkey in v.h else None)
                return self.table_ctor(v)
            return S.NewTable()
        if isinstance(v, RegFile):
            # the caller's register frame passed as a call argument
            # (`f(b, ...)`, v14.9's frame-holding decryptor calls)
            return FrameArg(0)
        return self.as_expr(v)

    def table_ctor(self, t):
        """A VM table with hash keys -> a table constructor (config-style
        tables the script builds at run time: `{url=..., method=...}`)."""
        stack = self.__dict__.setdefault("_tbl_stack", set())
        if id(t) in stack:
            raise Unsupported("cyclic VM table")
        stack.add(id(t))
        try:
            keys = sorted(t.h, key=lambda k: (not isinstance(k, int), k if isinstance(k, int) else repr(k)))
            # a leading 1..n run of ints renders positionally, the rest keyed
            n = 0
            while n < len(keys) and keys[n] == n + 1:
                n += 1
            items = [(None, self.value_of(t.h[k])) for k in keys[:n]]
            items += [(self.as_expr(k), self.value_of(t.h[k])) for k in keys[n:]]
            return S.NewTable(items)
        finally:
            stack.discard(id(t))

    def call_builtin(self, fn, args, it, stat):
        name = fn.name
        a = args
        if name in ("table.create",):
            if self.in_prologue:
                return RegFile()
            return LTable()
        if name == "getfenv":
            return EnvTable()
        if name == "setfenv":
            return Multi(a.items[:1])
        if name == "table.pack":
            return SymList(a.items, a.tail, nkey=b"n")
        if name in ("unpack", "table.unpack"):
            return self.unpack(a)
        if name == "table.move":
            return self.tmove(a)
        if name == "select":
            n = a.items[0] if a.items else None
            rest = Multi(a.items[1:], a.tail)
            if n == b"#":
                if rest.tail is None:
                    return len(rest.items)
                return TailCount(rest.tail) if not rest.items else Bin("Add", TailCount(rest.tail), Const(len(rest.items)))
            if isinstance(n, int):
                k = n - 1
                if k <= len(rest.items):
                    return Multi(rest.items[k:], rest.tail)
                return Multi([], rest.tail.drop(k - len(rest.items)) if rest.tail else None)
            raise Unsupported("select with %r" % (n,))
        if name == "coroutine.wrap":
            return GenIterMaker()
        if name == "next" and a.items and isinstance(a.items[0], OpenUps):
            return None
        if name.startswith("buffer.") and a.items and isinstance(a.items[0], Buf) and self.ov_base is not None:
            r = self.buffer_op(name, a.items)
            if r is not NotImplemented:
                return r
        if name in S.CONCRETE:
            vset = getattr(self, "vreg_set", ())
            cfacts = getattr(self, "cur_facts", {})
            vals = [cfacts[x.n][1] if isinstance(x, Reg) and x.n in vset
                    and cfacts.get(x.n, (None,))[0] == "c" else x for x in a.items]
            if a.tail is not None or any(is_sym(x) or isinstance(x, (SymList, Multi)) for x in vals):
                if name.startswith("bit32.") and a.tail is None and all(is_sym(x) or isinstance(x, int) for x in vals):

                    t = self.new_temp()
                    self.emit(CallStmt(t, Global(name), Multi([self.value_of(x) for x in vals])))
                    return Multi([], TempTail(t))
                raise Unsupported("builtin %s on symbolic values" % name)
            try:
                r = S.CONCRETE[name](*vals)
            except (struct.error, IndexError, ValueError, TypeError, OverflowError) as ex:
                raise Unsupported("%s failed: %s" % (name, ex))
            return r
        t = self.new_temp()
        self.emit(CallStmt(t, Global(name), Multi([self.value_of(x) if not isinstance(x, SymList) else x
                                                   for x in a.items], a.tail)))
        return Multi([], TempTail(t))

    _BUF_FMT = {"i8": "<b", "u8": "<B", "i16": "<h", "u16": "<H", "i32": "<i", "u32": "<I", "f32": "<f", "f64": "<d"}

    def buffer_op(self, name, args):
        """All reads/writes of VM buffers go through the byte-level path overlay."""
        b = args[0] if args else None
        if not isinstance(b, Buf):
            return NotImplemented
        if name.startswith("buffer.read") and len(args) >= 2:
            k = name[len("buffer.read"):]
            if k == "string" and len(args) >= 3 and isinstance(args[1], (int, float)) and isinstance(args[2], (int, float)):
                off, ln = int(args[1]), int(args[2])
                if off < 0 or ln < 0 or off + ln > len(b.data):
                    raise Unsupported("%s failed: offset %d..%d out of range %d" % (name, off, off + ln, len(b.data)))
                ov = self.cur_ov()
                return bytes(ov.get((id(b), off + i), b.data[off + i]) for i in range(ln))
            f = self._BUF_FMT.get(k)
            if f is not None and isinstance(args[1], (int, float)):
                off = int(args[1])
                sz = struct.calcsize(f)
                if off < 0 or off + sz > len(b.data):
                    raise Unsupported("%s failed: offset %d..%d out of range %d" % (name, off, off + sz, len(b.data)))
                ov = self.cur_ov()
                raw = bytes(ov.get((id(b), off + i), b.data[off + i]) for i in range(sz))
                return S.fix_int(struct.unpack(f, raw)[0])
        if name.startswith("buffer.write") and len(args) >= 3:
            k = name[len("buffer.write"):]
            if k == "string" and isinstance(args[1], (int, float)) and isinstance(args[2], (bytes, bytearray)):
                off = int(args[1])
                data = bytes(args[2]) if len(args) < 4 else bytes(args[2][:int(args[3])])
                if off < 0 or off + len(data) > len(b.data):
                    raise Unsupported("%s failed: offset %d..%d out of range %d" % (name, off, off + len(data), len(b.data)))
                for i, byte_v in enumerate(data):
                    self.write_ov((id(b), off + i), byte_v, b.data[off + i])
                return Multi([])
            f = self._BUF_FMT.get(k)
            if f is not None and isinstance(args[1], (int, float)) and isinstance(args[2], (int, float)):
                off = int(args[1])
                sz = struct.calcsize(f)
                if off < 0 or off + sz > len(b.data):
                    raise Unsupported("%s failed: offset %d..%d out of range %d" % (name, off, off + sz, len(b.data)))
                v = args[2]
                if k.startswith(("u", "i")):
                    bits = sz * 8
                    v = int(v) & ((1 << bits) - 1)
                    if k.startswith("i") and v >= 1 << (bits - 1):
                        v -= 1 << bits
                raw = struct.pack(f, v)
                for i, byte_v in enumerate(raw):
                    self.write_ov((id(b), off + i), byte_v, b.data[off + i])
                return Multi([])
        return NotImplemented

    def _ov_keys(self):
        o = self.cur_ov()
        keys = set()
        while o is not None:
            keys |= set(o.d)
            o = o.parent
        return keys

    def unpack(self, a):
        t = a.items[0] if a.items else None
        i = a.items[1] if len(a.items) > 1 else 1
        j = a.items[2] if len(a.items) > 2 else None
        if isinstance(t, RegFile):
            if not isinstance(i, int) or not isinstance(j, int):
                self._need_jreg(i, j)
                raise Unsupported("unpack registers with symbolic range")
            return Multi([FrameArg(n) if self.jvals.get(n) is FRAME else Reg(n) for n in range(i, j + 1)])
        if isinstance(t, SymList):
            if i != 1:
                raise Unsupported("unpack packed list from %r" % (i,))
            if j is None or is_sym(j) or (isinstance(j, int) and t.tail is not None and j >= len(t.items)):
                if isinstance(j, int) and t.tail is None:
                    return Multi(pad(t.items, j))
                return Multi(t.items, t.tail)
            return Multi(pad(t.items, j))
        if isinstance(t, LTable):
            if j is None:
                j = t.length()
            return Multi([t.get(n) for n in range(i, j + 1)])
        if isinstance(t, Expr):

            tt = self.new_temp()
            self.emit(CallStmt(tt, Global("table.unpack"),
                               Multi([self.value_of(x) if x is not None else Const(None) for x in a.items], a.tail)))
            return Multi([], TempTail(tt))
        raise Unsupported("unpack %r" % (t,))

    def tmove(self, a):
        src, f, e, t, dst = (a.items + [None] * 5)[:5]
        if dst is None:
            dst = src
        if isinstance(src, SymList) and src is dst:

            if f == 1 and isinstance(t, int) and 0 <= t - 1 <= 4096:
                src.items = [None] * (t - 1) + src.items
                return dst
            raise Unsupported("in-place move of packed list")
        if is_sym(f) or is_sym(t):
            self._need_jreg(f, t)
            raise Unsupported("table.move with symbolic positions")
        if is_sym(e) and isinstance(src, SymList) and f == 1 and isinstance(dst, Expr) and isinstance(t, int):

            self.emit(SetList(dst, t, Multi([self.value_of(x) if x is not None else Const(None) for x in src.items],
                                            src.tail)))
            return dst
        if is_sym(e) and isinstance(src, Expr) and isinstance(dst, Expr):

            tt = self.new_temp()
            self.emit(CallStmt(tt, Global("table.move"),
                               Multi([self.value_of(x) if x is not None else Const(None) for x in a.items])))
            return dst
        if is_sym(e):
            self._need_jreg(e)
            raise Unsupported("table.move with symbolic end")
        n = e - f + 1
        if not isinstance(n, int) or n < 0 or n > 4096:
            raise Unsupported("table.move count out of range: %s" % (n,))
        for k in range(n):
            v = self.elem(src, f + k)
            self.put(dst, t + k, v)
        return dst

    def elem(self, src, i):
        if isinstance(src, RegFile):
            return Reg(i)
        if isinstance(src, SymList):
            return self.symlist_get(src, i)
        if isinstance(src, LTable):
            return src.get(i)
        raise Unsupported("move from %r" % (src,))

    def put(self, dst, i, v):
        if isinstance(dst, RegFile):
            self.emit(Assign(Reg(i), self.value_of(v) if v is not None else Const(None)))
        elif isinstance(dst, Expr):
            self.emit(Assign(Index(dst, Const(i)), self.value_of(v) if v is not None else Const(None)))
        elif isinstance(dst, SymList):
            while len(dst.items) < i and dst.tail is None:
                dst.items.append(None)
            if i <= len(dst.items):
                dst.items[i - 1] = v
            else:
                raise Unsupported("store past a packed list's tail")
        elif isinstance(dst, LTable):
            dst.set(i, v)
        else:
            raise Unsupported("move into %r" % (dst,))

    def call_symbolic(self, fn, args, it, stat):
        if isinstance(fn, GenIterMaker):
            fn.args = args
            return Multi([])
        if isinstance(fn, RuntimeMaker):
            vals = args.items
            pi = self.vm.proto_index()
            return Multi([vals[pi] if len(vals) > pi else None])
        if isinstance(fn, OpaqueFn):
            if fn.pf_tid is not None and fn.pf_tid in self.dump.tables:
                return self.make_curried_closure(fn, args)
            node = self.vm_fn_node(fn)
            if node is not None and node is self.vm.maker:
                return self.make_closure(args)
            target = getattr(self.vm, "siblings", {}).get(id(node)) if node is not None else None
            if target is not None:
                return self.make_closure(args, target)
            if node is not None:
                return it.call_lua(LuaFunc(node, Scope()), args)
            # No AST node: a closure the trace never instantiated through a
            # hooked maker (e.g. a plain, non-virtualized function kept in the
            # VM's constant pool). Fall through and render the call through
            # the SharedFn stub (luraph_runtimeN, defined as error(...)) --
            # raising here would abort the lift of everything else.

        if isinstance(fn, Multi):
            fn = fn.first()
        if isinstance(fn, (GenIterMaker,)):
            return Multi([])
        if self.walk_only and any(isinstance(x, Missing) for x in walk_expr(fn)):

            return Multi([Missing(None)])
        fe = self.as_expr(fn) if not isinstance(fn, (ClosureExpr,)) else fn
        t = self.new_temp()
        self.emit(CallStmt(t, fe, Multi([self.value_of(x) if not isinstance(x, SymList) else x
                                         for x in args.items], args.tail)))
        return Multi([], TempTail(t))

    def vm_fn_node(self, fn):
        return fn.node

    def make_curried_closure(self, fn, args):
        proto = self.dump.tables[fn.pf_tid]
        cap = getattr(self.dump, "cap_by_self", {}).get(fn.pf_tid)
        cvm = self.vm
        if cap is not None and cap.get("__maker") is not None:
            mk = cap["__maker"]
            tag = mk.decode("latin-1") if isinstance(mk, bytes) else str(mk)
            cvm = getattr(self.dump, "vms", {}).get(tag, self.vm)
        vals = args.items
        ups = next((v for v in vals if isinstance(v, LTable)), None)
        entries = []
        if isinstance(ups, LTable):
            for i in range(1, ups.length() + 1):
                entries.append(ups.get(i))
        c = ClosureExpr(proto, entries)
        c.vm = cvm
        c.shared_cap = getattr(self.dump, "shared_cap", None)
        for e in entries:
            if isinstance(e, MaybeBox):
                self.captured_regs.add(e.reg)
            if isinstance(e, LTable):
                for v in e.h.values():
                    if isinstance(v, int) and any(isinstance(x, RegFile) for x in e.h.values()):
                        self.captured_regs.add(v)
        self.children.append(c)
        return c

    def make_closure(self, args, vm=None):
        """A VM closure of the proto in args; vm: the interpreter (VMModel)
        whose maker was called, when it is not this proto's."""
        vals = args.items
        vm = vm or self.vm
        if vm.info.get("mode") == "dispatch_local":
            # this build's factory takes (state table, flag): the state table
            # IS the child's proto container (V/U/Q/... slots). A table the
            # capture ran through maps to its own capture; a table the run
            # built but never called still carries the child's decoded arrays
            # in its slots, so it lifts straight from the state table
            st = vals[0] if vals and isinstance(vals[0], LTable) else None
            cap = self.dump.cap_by_state.get(st.tid) if st is not None else None
            proto = cap["self"] if cap is not None and isinstance(cap.get("self"), LTable) else st
            if proto is not None:
                c = ClosureExpr(proto, [])
                c.vm = vm
                c.state_table = st
                c.shared_cap = self.dump.shared_cap
                self.children.append(c)
                return c
        pi, ui = vm.proto_index(), vm.upvals_index()
        proto = vals[pi] if len(vals) > pi else None
        ups = vals[ui] if len(vals) > ui else None
        if not isinstance(proto, LTable) and vals and isinstance(vals[0], LTable):
            # v14.9's closure op calls the maker positionally as
            # (proto, upvals): `S[60](v, y)` -- the model's proto index points
            # at the wrong slot for that convention. The proto table doubles
            # as the child's VM state (k[3] = register count, k[6] = its
            # instruction arrays), so the child lifts from it directly.
            proto = vals[0]
            ups = vals[1] if len(vals) > 1 else None
            v149_proto_state = True
        else:
            v149_proto_state = False
        if self.walk_only and not isinstance(proto, LTable) and \
                any(isinstance(x, Missing) for x in walk_expr(proto)):

            return Missing(None)
        if not isinstance(proto, LTable):
            if os.environ.get("DEVIRT_MC_DEBUG"):
                desc = []
                dump = self.dump
                for i, v in enumerate(vals):
                    extra = ""
                    if isinstance(v, LTable):
                        ks = sorted((repr(k)[:20], repr(x)[:24]) for k, x in list(v.h.items())[:24])
                        pid = dump.pid_of_table.get(v.tid) if v.tid is not None else None
                        extra = " tid=%r pid=%r keys=%s" % (v.tid, pid, ks)
                    desc.append("%d=%s:%s%s" % (i, type(v).__name__, repr(v)[:50], extra))
                print("[mc] non-proto closure pi=%d ui=%d vals[%d]: %s"
                      % (pi, ui, len(vals), " | ".join(desc)), file=sys.stderr)
                print("[mc] last_op=%r mode=%r pc=%r misses=%r lazy_tids(paths)=%s"
                      % (getattr(self, "last_op", None), getattr(self, "cur_mode", None),
                         getattr(self, "cur_pc", None), dict(dump.misses),
                         {t: dump.paths().get(t) for t in list(dump.lazy)[:12]}), file=sys.stderr)
            raise Unsupported("closure of non-proto")
        entries = []
        if isinstance(ups, LTable):
            for i in range(1, ups.length() + 1):
                entries.append(ups.get(i))
        c = ClosureExpr(proto, entries)
        c.vm = vm
        if v149_proto_state:
            # the child's VM state is its own proto table (see above)
            c.state_table = proto
        for e in entries:
            if isinstance(e, MaybeBox):
                self.captured_regs.add(e.reg)
            if isinstance(e, LTable):
                for v in e.h.values():
                    if isinstance(v, int) and any(isinstance(x, RegFile) for x in e.h.values()):
                        self.captured_regs.add(v)
        self.children.append(c)
        return c

def lst_nkey(lst):
    return lst.nkey if lst.nkey is not None else b"n"

def pad(items, n):
    items = list(items[:n])
    while len(items) < n:
        items.append(None)
    return items

class OpenUps:
    """Luraph's table of open upvalue boxes (register -> box). Reads give a
    MaybeBox (a by-reference capture of that register); storing nil into it
    is the close op: the captured local's scope ends there."""

OPENUPS = OpenUps()

class MaybeBox:
    def __init__(self, reg):
        self.reg = reg

    def __repr__(self):     
        return "box(r%s)" % self.reg

class UpList:
    """The upvalue list of the proto being lifted. y[i] is a BoxProxy, or a
    FrameProxy for the upvalues that hold the parent's whole register frame."""

    def __init__(self, frames=()):
        self.boxes = {}
        self.frames = set(frames)

    def get(self, i):
        b = self.boxes.get(i)
        if b is None:
            b = self.boxes[i] = FrameProxy(i) if i in self.frames else BoxProxy(i)
        return b

REGFILE = RegFile()

FRAME = "<frame>"

class FrameProxy:
    """Upvalue i holding the parent's register frame: upv[i][r] is the
    parent's register r (Upval((i, r)))."""

    def __init__(self, idx):
        self.idx = idx

    def __repr__(self):
        return "frameproxy(%s)" % (self.idx,)

class BoxProxy:
    """Upvalue i. Luraph keeps shared upvalues in boxes read as box[a][box[b]];
    by-value upvalues are used directly (y[i], y[i][k])."""

    def __init__(self, idx):
        self.idx = idx

    def __repr__(self):
        return "boxproxy(%s)" % (self.idx,)

class BoxPart(Expr):
    """box[k] of upvalue `idx`: either half of a box access, or (if used any
    other way) the by-value upvalue indexed with constant k."""

    def __init__(self, idx, k):
        self.idx, self.k = idx, k

def walk_expr(e):
    stack = [e]
    while stack:
        x = stack.pop()
        if isinstance(x, Expr):
            yield x
            stack += [v for v in x.__dict__.values() if isinstance(v, Expr)]
            if isinstance(x, S.NewTable):
                stack += [y for kv in x.items for y in kv if isinstance(y, Expr)]

def meet(a, b):
    """Facts true on both paths: equal facts stay; a constant and a
    truthiness (or two constants) that agree on truthiness give that truthiness."""
    out = {}
    for r, f in a.items():
        g = b.get(r)
        if g is None:
            if isinstance(r, int) and 800000 < r < 810000 and f[0] == "c":
                out[r] = f
            continue
        if g == f:
            out[r] = f
            continue
        if (f[0] == "c" and g[0] == "c"
                and isinstance(f[1], int) and not isinstance(f[1], bool)
                and isinstance(g[1], int) and not isinstance(g[1], bool)
                and (f[1] & 0xFFFFFFFF) == (g[1] & 0xFFFFFFFF)):
            out[r] = ("c", f[1] & 0xFFFFFFFF)
            continue
        if isinstance(r, int) and 800000 < r < 810000:
            if f[0] == "c" and g[0] != "c":
                out[r] = f
                continue
            if g[0] == "c" and f[0] != "c":
                out[r] = g
                continue
        if f[0] == "idx_reg" and g[0] == "c":
            rk = b.get(f[2])
            if rk and rk[0] == "c" and f[1].get(rk[1]) == g[1]:
                out[r] = f
                continue
        if g[0] == "idx_reg" and f[0] == "c":
            rk = a.get(g[2])
            if rk and rk[0] == "c" and g[1].get(rk[1]) == f[1]:
                out[r] = g
                continue
        ta, tb = truth_of(f), truth_of(g)
        if ta is not None and ta == tb:
            out[r] = ("t",) if ta else ("f",)
    for r, g in b.items():
        if r not in a and g[0] == "c":
            if (isinstance(r, int) and 800000 < r < 810000) or (isinstance(r, tuple) and r[0] in ("up", "vararg")):
                out[r] = g
    return out

def fact_of(value):
    """Fact for a register assigned `value` (an IR expression)."""
    if isinstance(value, Const):
        v = value.v
        if isinstance(v, (int, float, bytes, bool)) or v is None:
            return ("c", v)
    if isinstance(value, Global):
        return ("g", value.name)
    if isinstance(value, S.NewTable) and not value.items:
        return ("tbl", {})
    if isinstance(value, SymList) and value.tail is None:
        return ("tbl", {i + 1: item.v for i, item in enumerate(value.items) if isinstance(item, Const)})
    if isinstance(value, ClosureExpr):
        return ("t", value)     
    if isinstance(value, (S.NewTable, Vec, Opaque)):
        return ("t",)
    return None

def eval_fact(e, facts):
    """Concrete value of an IR expression under the facts, or a truthiness
    ("t"/"f"), or None when unknown."""
    if isinstance(e, Const):
        return ("c", e.v)
    if isinstance(e, Global):
        return ("g", e.name)
    if isinstance(e, SymList) and e.tail is None:
        return ("tbl", {i + 1: item.v for i, item in enumerate(e.items) if isinstance(item, Const)})
    if isinstance(e, Reg):
        f = facts.get(e.n)
        if getattr(e, "_u32_trunc", False) and f and f[0] == "c" and isinstance(f[1], (int, float)) and not isinstance(f[1], bool):
            return ("c", int(f[1]) & 0xFFFFFFFF)
        return f
    if isinstance(e, Upval):
        return facts.get(("up", e.idx))
    if isinstance(e, Vararg):
        return facts.get(("vararg", e.i))
    if isinstance(e, TempVal):
        tf = facts.get(("tmp", e.t))
        if tf and tf[0] == "m" and 1 <= e.i <= len(tf[1]):
            return ("c", tf[1][e.i - 1])
        return None
    if isinstance(e, Index):
        of, kf = eval_fact(e.obj, facts), eval_fact(e.key, facts)
        if of and kf and kf[0] == "c":
            k = kf[1].decode("latin-1") if isinstance(kf[1], bytes) else kf[1]
            if of[0] == "g" and isinstance(k, str) and (of[1] + "." + k) in S.FACT_CONCRETE:
                return ("g", of[1] + "." + k)
            if of[0] == "c" and isinstance(of[1], bytes) and isinstance(k, str) and ("string." + k) in S.FACT_CONCRETE:
                return ("g", "string." + k)
            if of[0] == "c" and isinstance(of[1], dict):
                if kf[1] in of[1]:
                    return ("c", of[1][kf[1]])
                if of[1].get(b"__type") == "Instance" and of[1].get(b"ClassName") == b"Path2D" and isinstance(k, str):
                    if k == "SetControlPoints" or ("Path2D." + k) in S.FACT_CONCRETE:
                        return ("g", "Path2D." + k)
                if of[1].get(b"__type") == "Random" and isinstance(k, str):
                    if k in ("NextNumber", "NextInteger", "Clone"):
                        return ("g", "Random." + k)
            if of[0] == "tbl" and kf[1] in of[1]:
                return ("c", of[1][kf[1]])
        if of and of[0] == "tbl" and isinstance(e.key, Reg):
            return ("idx_reg", of[1], e.key.n)
        return None
    if isinstance(e, Un) and e.op == "Not":
        a = eval_fact(e.a, facts)
        t = truth_of(a)
        return None if t is None else ("c", not t)
    if isinstance(e, Bin) and e.op in ("Add", "Sub", "Mul", "Div", "Mod", "FloorDiv"):
        a, b = eval_fact(e.a, facts), eval_fact(e.b, facts)
        if a and b and a[0] == "c" and b[0] == "c":
            x, y = a[1], b[1]
            if isinstance(x, (int, float)) and not isinstance(x, bool) and isinstance(y, (int, float)) and not isinstance(y, bool):
                try:
                    if e.op == "Add": v = x + y
                    elif e.op == "Sub": v = x - y
                    elif e.op == "Mul": v = x * y
                    elif e.op == "Div": v = x / y
                    elif e.op == "Mod": v = x % y
                    else: v = x // y
                    return ("c", S.fix_int(v))
                except ZeroDivisionError:
                    return None
    if isinstance(e, Bin) and e.op.startswith("Compare"):
        a, b = eval_fact(e.a, facts), eval_fact(e.b, facts)
        if a and b and a[0] == "c" and b[0] == "c":
            try:
                x, y = a[1], b[1]
                if e.op == "CompareEq":
                    return ("c", S.lua_eq(x, y))
                if e.op == "CompareNe":
                    return ("c", not S.lua_eq(x, y))
                if isinstance(x, bool) or isinstance(y, bool) or x is None or y is None or isinstance(x, dict) or isinstance(y, dict):
                    return None
                if isinstance(x, bytes) != isinstance(y, bytes):
                    return None
                return ("c", {"CompareLt": x < y, "CompareLe": x <= y, "CompareGt": x > y,
                              "CompareGe": x >= y}[e.op])
            except TypeError:
                return None
        if e.op in ("CompareEq", "CompareNe"):
            if isinstance(e.a, Reg) and isinstance(e.b, Const):
                ra = e.a.n
                if ra in facts and facts[ra][0] == "r":
                    ra = facts[ra][1]
                return ("cmp", e.op, ra, e.b.v)
            if isinstance(e.b, Reg) and isinstance(e.a, Const):
                rb = e.b.n
                if rb in facts and facts[rb][0] == "r":
                    rb = facts[rb][1]
                return ("cmp", e.op, rb, e.a.v)
    return None

def truth_of(f):
    if f is None or f[0] in ("r", "m", "cmp", "idx_reg"):
        return None
    if f[0] == "c":
        return S.truthy(f[1])
    if f[0] in ("g", "tbl"):
        return True
    return f[0] == "t"

def edge_facts(cond, taken, facts):
    """Facts implied by taking one side of a branch on `cond`."""
    f = dict(facts)
    c = cond
    neg = False
    while isinstance(c, Un) and c.op == "Not":
        c, neg = c.a, not neg
    t = taken != neg
    learned_reg = None
    if isinstance(c, Reg):
        cf = f.get(c.n)
        if cf and cf[0] == "cmp":
            eq = t if cf[1] == "CompareEq" else not t
            if eq and cf[2] != c.n:
                f[cf[2]] = ("c", cf[3])
                learned_reg = (cf[2], cf[3])
            f[c.n] = ("c", bool(t))
        elif c.n not in f or f[c.n][0] != "c":
            f[c.n] = ("t",) if t else ("f",)
    elif isinstance(c, Bin) and c.op in ("CompareEq", "CompareNe"):
        eq = t if c.op == "CompareEq" else not t
        if eq:
            if isinstance(c.a, Reg) and isinstance(c.b, Const):
                f[c.a.n] = ("c", c.b.v)
                learned_reg = (c.a.n, c.b.v)
            elif isinstance(c.b, Reg) and isinstance(c.a, Const):
                f[c.b.n] = ("c", c.a.v)
                learned_reg = (c.b.n, c.a.v)
    if learned_reg is not None:
        lr, lv = learned_reg
        for rk, rv in list(f.items()):
            if rv and rv[0] == "idx_reg" and rv[2] == lr and lv in rv[1]:
                f[rk] = ("c", rv[1][lv])
    return f

def _replace_dict_fact(facts, old_d, key, val):
    new_d = dict(old_d)
    new_d[key] = val
    for rk, rv in list(facts.items()):
        if rv and rv[0] in ("c", "tbl") and rv[1] is old_d:
            facts[rk] = (rv[0], new_d)
    for rk, rv in list(facts.items()):
        if rv and rv[0] in ("c", "tbl") and isinstance(rv[1], dict):
            for dk, dv in list(rv[1].items()):
                if dv is old_d:
                    nd2 = dict(rv[1])
                    nd2[dk] = new_d
                    facts[rk] = (rv[0], nd2)

def _capture_closure_up_facts(c, facts, lf=None):
    up_facts = getattr(c, "up_facts", None) or {}
    rcf = getattr(lf, "reg_const_fact", None) or {}
    for i, u in enumerate(c.upvals, 1):
        uf = None
        if isinstance(u, Reg):
            uf = facts.get(u.n)
            if not (uf and uf[0] == "c"):
                uf = rcf.get(u.n)
        elif isinstance(u, MaybeBox):
            uf = facts.get(u.reg)
            if not (uf and uf[0] == "c"):
                uf = rcf.get(u.reg)
        elif isinstance(u, (BoxProxy, Upval)):
            uf = facts.get(("up", u.idx))
        elif isinstance(u, LTable):
            vals = list(u.h.values())
            ints = [v for v in vals if isinstance(v, int)]
            if any(isinstance(v, RegFile) for v in vals) and ints:
                uf = facts.get(ints[0])
                if not (uf and uf[0] == "c"):
                    uf = rcf.get(ints[0])
            else:
                ups = [v for v in vals if isinstance(v, UpContainer)]
                if ups:
                    uf = facts.get(("up", ups[0].idx))
        elif isinstance(u, RegFile):
            for rk, rv in facts.items():
                if isinstance(rk, int) and rk < 800000 and rv and rv[0] == "c" and isinstance(rv[1], (int, float)) and not isinstance(rv[1], bool):
                    up_facts[("up", (i, rk))] = rv
            for rk, rv in rcf.items():
                if ("up", (i, rk)) not in up_facts:
                    up_facts[("up", (i, rk))] = rv
        elif isinstance(u, FrameProxy):
            for rk, rv in facts.items():
                if isinstance(rk, tuple) and len(rk) == 2 and rk[0] == "up" and isinstance(rk[1], tuple) and rk[1][0] == u.idx and rv and rv[0] == "c" and isinstance(rv[1], (int, float)) and not isinstance(rv[1], bool):
                    up_facts[("up", (i, rk[1][1]))] = rv
        if uf and uf[0] == "c" and isinstance(uf[1], (int, float)) and not isinstance(uf[1], bool):
            up_facts[("up", i)] = uf
    c.up_facts = up_facts

def apply_stmt_facts(st, facts, lf):
    if isinstance(st, Assign) and isinstance(st.target, Reg):
        if isinstance(st.value, ClosureExpr):
            _capture_closure_up_facts(st.value, facts, lf)
        fv = fact_of(st.value)
        if fv is None:
            fv = eval_fact(st.value, facts)
        if fv is None and isinstance(st.value, Reg):
            src = facts.get(st.value.n)
            fv = src if (src and src[0] == "r") else ("r", st.value.n)
        tn = st.target.n
        for rk, rv in list(facts.items()):
            if rk != tn and rv and ((rv[0] == "r" and rv[1] == tn) or (rv[0] in ("cmp", "idx_reg") and rv[2] == tn)):
                facts.pop(rk, None)
        if fv and fv[0] == "cmp" and fv[2] == tn:
            fv = None
        rcf = lf.__dict__.setdefault("reg_const_fact", {}) if lf is not None else None
        if fv is None:
            facts.pop(st.target.n, None)
            if rcf is not None:
                rcf.pop(st.target.n, None)
        else:
            facts[st.target.n] = fv
            if fv[0] == "c" and isinstance(fv[1], (int, float)) and not isinstance(fv[1], bool):
                if rcf is not None:
                    rcf[st.target.n] = fv
                if lf is not None:
                    for ch in getattr(lf, "children", ()):
                        for ui, u in enumerate(ch.upvals, 1):
                            if isinstance(u, MaybeBox) and u.reg == st.target.n:
                                uf_map = getattr(ch, "up_facts", None)
                                if uf_map is not None and ("up", ui) not in uf_map:
                                    uf_map[("up", ui)] = fv
            elif rcf is not None:
                rcf.pop(st.target.n, None)
    elif isinstance(st, Assign) and isinstance(st.target, Index) and isinstance(st.target.obj, Reg):
        tf = facts.get(st.target.obj.n)
        kf = eval_fact(st.target.key, facts)
        vf = eval_fact(st.value, facts)
        if tf and kf and kf[0] == "c" and vf and vf[0] in ("c", "tbl"):
            if tf[0] == "tbl" or (tf[0] == "c" and isinstance(tf[1], dict)):
                _replace_dict_fact(facts, tf[1], kf[1], vf[1])
    elif isinstance(st, SetList) and isinstance(st.tbl, Reg):
        tf = facts.get(st.tbl.n)
        if tf and tf[0] == "tbl":
            old_d = tf[1]
            new_d = dict(old_d)
            vals = []
            ok = True
            for x in st.values.items:
                xf = eval_fact(x, facts)
                if xf and xf[0] == "c":
                    vals.append(xf[1])
                else:
                    ok = False
                    break
            if ok and st.values.tail is not None:
                if isinstance(st.values.tail, TempTail):
                    mf = facts.get(("tmp", st.values.tail.t))
                    if mf and mf[0] == "m":
                        vals.extend(mf[1][st.values.tail.start - 1:])
                    else:
                        ok = False
                else:
                    ok = False
            if ok:
                for idx_i, val_i in enumerate(vals):
                    new_d[st.start + idx_i] = val_i
                for rk, rv in list(facts.items()):
                    if rv and rv[0] == "tbl" and rv[1] is old_d:
                        facts[rk] = ("tbl", new_d)
    elif isinstance(st, CallStmt):
        if isinstance(st.fn, Reg):
            ff = facts.get(st.fn.n)
            if ff and ff[0] == "t" and len(ff) > 1 and isinstance(ff[1], ClosureExpr) and st.args.tail is None:
                c = ff[1]
                af_map = {}
                for j, ax in enumerate(st.args.items, 1):
                    af = eval_fact(ax, facts)
                    if af and af[0] == "c" and isinstance(af[1], (int, float)) and not isinstance(af[1], bool):
                        af_map[("vararg", j)] = af
                if not hasattr(c, "arg_facts"):
                    c.arg_facts = af_map
                else:
                    c.arg_facts = {k: v for k, v in c.arg_facts.items() if c.arg_facts.get(k) == af_map.get(k)}
        fn_f = eval_fact(st.fn, facts)
        is_pure_g = False
        if fn_f and fn_f[0] == "g" and (fn_f[1] in S.FACT_CONCRETE or fn_f[1] in ("Path2D.SetControlPoints", "Random.NextNumber", "Random.NextInteger")):
            is_pure_g = True
            arg_vals = []
            ok = True
            for x in st.args.items:
                xf = eval_fact(x, facts)
                if xf and xf[0] in ("c", "tbl"):
                    arg_vals.append(xf[1])
                else:
                    ok = False
                    break
            if ok and st.args.tail is not None:
                if isinstance(st.args.tail, TempTail):
                    mf = facts.get(("tmp", st.args.tail.t))
                    if mf and mf[0] == "m":
                        arg_vals.extend(mf[1][st.args.tail.start - 1:])
                    else:
                        ok = False
                else:
                    ok = False
            if ok:
                if fn_f[1] == "Path2D.SetControlPoints" and len(arg_vals) >= 2 and isinstance(arg_vals[0], dict) and isinstance(arg_vals[1], dict):
                    _replace_dict_fact(facts, arg_vals[0], b"_pts", dict(arg_vals[1]))
                elif fn_f[1] == "Random.NextNumber" and len(arg_vals) >= 1 and isinstance(arg_vals[0], dict) and b"_st" in arg_vals[0]:
                    try:
                        nst, val = S._random_next_number(*arg_vals)
                        _replace_dict_fact(facts, arg_vals[0], b"_st", nst)
                        facts[("tmp", st.t)] = ("m", [val])
                    except Exception:
                        pass
                elif fn_f[1] == "Random.NextInteger" and len(arg_vals) >= 3 and isinstance(arg_vals[0], dict) and b"_st" in arg_vals[0]:
                    try:
                        nst, val = S._random_next_integer(*arg_vals)
                        _replace_dict_fact(facts, arg_vals[0], b"_st", nst)
                        facts[("tmp", st.t)] = ("m", [val])
                    except Exception:
                        pass
                elif fn_f[1] in S.FACT_CONCRETE:
                    try:
                        res = S.FACT_CONCRETE[fn_f[1]](*arg_vals)
                        items = res.items if isinstance(res, Multi) else [res]
                        facts[("tmp", st.t)] = ("m", items)
                    except Exception:
                        pass
        if any(isinstance(x, FrameArg) for x in st.args.items):
            writes = frame_call(st, facts, lf)
            prev = getattr(st, "frame_eval", None)
            if writes is None or (prev is not None and prev != writes):
                st.frame_eval = False
            elif prev is None:
                st.frame_eval = writes
            if not st.frame_eval:
                facts.clear()       
                return
            for r, v in st.frame_eval.items():
                facts[r] = ("c", v)

        if lf.captured_regs and not is_pure_g:
            for r in list(facts):
                if r in lf.captured_regs and (not isinstance(facts[r], tuple) or facts[r][0] != "g"):
                    del facts[r]

def frame_call(st, facts, lf):
    """A call that gets the caller's register frame (FrameArg), of a closure
    without upvalues, all other arguments constant: run it in the runtime on
    a fresh table ("!proto!args" request, envlog callPath). -> {register:
    value} it wrote (LPH_ENCSTR-style decryptors: the plaintext), or None."""
    f = eval_fact(st.fn, facts) if isinstance(st.fn, Reg) else None
    c = f[1] if f and f[0] == "t" and len(f) > 1 else None
    if not isinstance(c, ClosureExpr) or c.upvals or not isinstance(c.proto, LTable) or st.args.tail is not None:
        return None
    path = lf.dump.paths().get(c.proto.tid)
    if path is None:
        return None
    specs = []
    for x in st.args.items:
        v = eval_fact(x, facts) if not isinstance(x, FrameArg) else ("F",)
        if v is None or v[0] not in ("c", "F"):
            return None
        if v[0] == "F":
            specs.append("F")
        elif v[1] is None:
            specs.append("z")
        elif isinstance(v[1], bool):
            specs.append("t" if v[1] else "f")
        elif isinstance(v[1], bytes):
            specs.append("s" + v[1].hex())
        elif isinstance(v[1], (int, float)) and v[1] == v[1] and abs(v[1]) != float("inf"):
            specs.append("n" + S.fmt_num(v[1]))
        else:
            return None
    rq = "!%s!%s" % ("~".join(str(x) for x in path), "/".join(specs))
    got = lf.dump.overrides.get(rq)
    if got is None:
        got = lf.dump.fetch(rq)
        if got is None:
            lf.requests.add(rq)
    if not isinstance(got, LTable):
        return None
    out = {}
    for k, v in got.h.items():
        if not isinstance(k, int) or not isinstance(v, (bytes, int, float, bool)):
            return None
        out[k] = v
    c.frame_evaluated = True    
    return out

def drop_idle_closes(order, captured):
    """Close ops of registers no closure of this function captures: no-ops
    (Luraph closes whole ranges), but they would keep otherwise identical
    copies of an instruction apart (structure.merge_equivalent)."""
    stack = [n for _, n in order]
    while stack:
        n = stack.pop()
        if n is None:
            continue
        if any(isinstance(x, Close) and x.reg not in captured for x in n.stmts):
            n.stmts = [x for x in n.stmts if not (isinstance(x, Close) and x.reg not in captured)]
        stack += [n.then, n.els]

def apply_frame_calls(order):
    """Evaluated frame-writing calls (frame_call) -> the register writes."""
    stack = [n for _, n in order]
    while stack:
        n = stack.pop()
        if n is None:
            continue
        if any(getattr(x, "frame_eval", None) for x in n.stmts):
            new = []
            for x in n.stmts:
                w = getattr(x, "frame_eval", None)
                if w:
                    new += [Assign(Reg(r), Const(v)) for r, v in sorted(w.items())]
                else:
                    new.append(x)
            n.stmts = new
        stack += [n.then, n.els]

def _check_cff_bin(e, f, lf):
    if lf.stack_base is not None:
        return False
    if isinstance(e, Bin) and e.op in ("CompareLe", "CompareLt", "CompareGe", "CompareGt", "CompareEq"):
        for side, other in ((e.a, e.b), (e.b, e.a)):
            if isinstance(side, Reg) and isinstance(other, Const) and isinstance(other.v, int) and not isinstance(other.v, bool):
                r = side.n
                if r in f and f[r][0] == "r":
                    r = f[r][1]
                if (r in lf.merged_int_regs and r not in lf.cff_regs
                        and r not in lf.arith_regs and (r not in f or f[r][0] != "c")):
                    lf.cff_regs.add(r)
                    lf.jump_regs.add(r)
                    return True
    return False

def propagate(node, facts, succ, lf):
    """Walk one instruction's IR tree under the facts, collecting feasible
    successors with their facts."""
    stack = [(node, facts)]
    while stack:
        n, f = stack.pop()
        if n is None:
            continue
        for st in n.stmts:
            if isinstance(st, Assign) and _check_cff_bin(st.value, f, lf):
                return "cff_restart"
            apply_stmt_facts(st, f, lf)
        if n.cond is not None:
            if _check_cff_bin(n.cond, f, lf):
                return "cff_restart"
            v = truth_of(eval_fact(n.cond, f))
            n.decided = getattr(n, "decided", "unset")
            if v is None:
                n.decided = None
                stack.append((n.then, edge_facts(n.cond, True, f)))
                stack.append((n.els, edge_facts(n.cond, False, f)))
            else:
                if n.decided == "unset":
                    n.decided = v
                elif n.decided is not None and n.decided != v:
                    n.decided = None
                stack.append((n.then if v else n.els, f))
        elif isinstance(n.outcome, Next):
            succ.append((n.outcome.state, f))
    return None

def expr_regs(e):
    """Registers read by an expression."""
    out = []
    stack = [e]
    while stack:
        x = stack.pop()
        if isinstance(x, Reg):
            out.append(x)
        elif isinstance(x, Expr):
            stack += [v for v in x.__dict__.values() if isinstance(v, Expr)]
            if isinstance(x, S.NewTable):
                stack += [y for kv in x.items for y in kv if isinstance(y, Expr)]
    return out

class GenIterMaker:
    """coroutine.wrap(helper) of Luraph's generic-for: called once with
    (vm, f, s, ctl); then stored as the loop state and called per iteration."""

    def __init__(self):
        self.args = None

class _AccessLog(dict):
    """A scope's variables that remember which ones were read before being
    written, and which were written (Stepper.carry)."""
    __slots__ = ("read_first", "written")

    def __init__(self, *a):
        super().__init__(*a)
        self.read_first = set()
        self.written = set()

    def __getitem__(self, k):
        if k not in self.written:
            self.read_first.add(k)
        return dict.__getitem__(self, k)

    def get(self, k, default=None):
        if dict.__contains__(self, k):
            if k not in self.written:
                self.read_first.add(k)
            return dict.__getitem__(self, k)
        return default

    def __setitem__(self, k, v):
        self.written.add(k)
        dict.__setitem__(self, k, v)

class Stepper:
    def __init__(self, vm, lifter):
        self.vm = vm
        self.lf = lifter
        cs = lifter.initial_state()
        self.cs = cs

        self.loops = []
        self.first_init = []
        for i, st in enumerate(vm.inner_body):
            if st["type"] == "AstStatIf":
                tb = st["thenbody"]["body"]
                for j, sub in enumerate(tb):
                    if sub["type"] in ("AstStatWhile", "AstStatRepeat") and vm.is_dispatch(sub):
                        if not self.loops and j > 0:
                            self.first_init = tb[:j]
                        self.loops.append((i, st, sub))
                        break
        self.mode_decl = None
        self.mode_init_decl = None
        if not self.loops:

            for i, st in enumerate(vm.inner_body):
                if st["type"] in ("AstStatWhile", "AstStatRepeat") and vm.is_dispatch(st):
                    self.loops.append((i, None, st))
                    break
        if not self.loops:
            raise Unsupported("no dispatch loops in the VM function")
        w = self.loops[0][2]
        head = w["body"]["body"][0]["values"][0]
        while head.get("type") == "AstExprGroup":
            head = head["expr"]
        pcname = head["index"]["local"]
        self.pc_decl = pcname["location"]

        self.conds = {}
        for i, st, _ in self.loops:
            if st is None:
                continue
            cond = st["condition"]
            if cond["type"] == "AstExprLocal":
                cond = self._local_value(cond["local"]["location"], i) or cond
            self.conds[i] = cond
            if cond["type"] == "AstExprBinary":
                mv = cond["left"] if cond["left"]["type"] == "AstExprLocal" else cond["right"]
                if self.mode_init_decl is None:
                    self.mode_init_decl = mv["local"]["location"]
                self.mode_decl = mv["local"]["location"]
        self.first_inner = self.loops[0][0]
        self.gov = Overlay()

        self._detect_regfile()
        self._fix_vararg_pointers()

        self.carry = set()
        self.vreg_of = {}
        self.vreg_init = {}
        self.last_written_val = {}
        self.lf.vreg_set = set()
        self.lf.cur_facts = {}
        self.read_first = set()
        self.written = set()
        self.not_carried = set()
        self.new_carry = False
        self.fixed_decls = {d for d in (self.pc_decl, self.mode_decl, vm.kstack_key) if d}
        for _, _, lw in self.loops:
            lbody = lw.get("body", {}).get("body") or ()
            if lbody and lbody[0].get("type") in ("AstStatAssign", "AstStatLocal"):
                for vr in lbody[0].get("vars", ()):
                    loc = vr.get("local", vr).get("location")
                    if loc:
                        self.fixed_decls.add(loc)
            for n in iter_nodes(lw):
                if n.get("type") == "AstStatLocal":
                    for vr in n.get("vars", ()):
                        loc = vr.get("location")
                        if loc:
                            self.fixed_decls.add(loc)
        self.sp_cands = self._stack_pointer_candidates()
        self._init_vregs()
        if not hasattr(vm, "_mode_loop_cache"):
            vm._mode_loop_cache = {}
        self._mode_loop_cache = vm._mode_loop_cache

    def _init_vregs(self):
        """Pre-populate virtual registers for prologue/dispatcher locals whose
        handler assignments only cache register file reads (`Z = J[o[F]]`)."""
        if self.lf.stack_base is not None:
            return
        cache = self.vm.__dict__.setdefault("_static_vregs", {})
        if None not in cache:
            _, inner = self._fresh_scopes(None, S.Interp(self.lf))
            self.lf.out = []
            regfiles = set()
            sc = inner
            while sc is not None:
                for k, v in sc.vars.items():
                    if isinstance(v, RegFile):
                        regfiles.add(k)
                sc = sc.parent
            reads, reg_writes, other_writes = set(), set(), set()
            for _, _, w in self.loops:
                for n in iter_nodes(w):
                    t = n.get("type")
                    if t == "AstExprLocal":
                        reads.add(n["local"]["location"])
                    elif t == "AstStatAssign":
                        for vr, vl in zip(n.get("vars", []), n.get("values", [])):
                            if vr.get("type") == "AstExprLocal":
                                loc = vr["local"]["location"]
                                if (vl.get("type") == "AstExprIndexExpr"
                                        and vl.get("expr", {}).get("type") == "AstExprLocal"
                                        and vl["expr"]["local"]["location"] in regfiles):
                                    reg_writes.add(loc)
                                else:
                                    other_writes.add(loc)
                    elif t == "AstStatCompoundAssign":
                        var = n.get("var")
                        if isinstance(var, dict) and var.get("type") == "AstExprLocal":
                            other_writes.add(var["local"]["location"])
            cands = ((reg_writes - other_writes) & reads & set(inner.vars)) - self.sp_cands - self.fixed_decls
            cache[None] = sorted(cands)
        for loc in cache[None]:
            if loc not in self.vreg_of:
                vreg = 800000 + len(self.vreg_of) + 1
                self.vreg_of[loc] = vreg
                self.lf.vreg_set.add(vreg)

    def _cross_handler_temps(self):
        """Dispatch temps (declared valueless in the loop function) that some
        handler reads and some handler writes: their values live across
        instruction boundaries in this build."""
        reads, writes = set(), set()
        for _, _, w in self.loops:
            for n in iter_nodes(w):
                t = n.get("type")
                if t == "AstExprLocal":
                    reads.add(n["local"]["location"])
                elif t == "AstStatLocal":
                    for v in n.get("vars", []):
                        writes.add(v["location"])
                elif t == "AstStatAssign":
                    for v in n.get("vars", []):
                        if v.get("type") == "AstExprLocal":
                            writes.add(v["local"]["location"])
                elif t == "AstStatCompoundAssign":
                    var = n.get("var")
                    if isinstance(var, dict) and var.get("type") == "AstExprLocal":
                        writes.add(var["local"]["location"])
        out = set()
        for st in self.vm.inner_body[:self.first_inner]:
            if st.get("type") != "AstStatLocal" or st.get("values"):
                continue
            for v in st.get("vars", []):
                k = v["location"]
                if k in reads and k in writes:
                    out.add(k)
        return out

    def _fix_vararg_pointers(self):
        """The prologue places the entry varargs with a VM runtime helper
        (`local w,W = S[59](...)`) the walk cannot evaluate (a stub call). At
        closure entry the multret region is empty: the pointer local is 0 and
        the value table empty, which is all the split handlers need."""
        for st in self.vm.prologue:
            if st.get("type") != "AstStatLocal":
                continue
            vals = st.get("values", [])
            if len(vals) != 1 or vals[0].get("type") != "AstExprCall":
                continue
            call = vals[0]
            args = call.get("args", [])
            if len(args) != 1 or args[0].get("type") != "AstExprVarargs":
                continue
            vars_ = st.get("vars", [])
            if len(vars_) != 2:
                continue
            vd, wd = vars_[0]["location"], vars_[1]["location"]
            if isinstance(self.cs.vars.get(vd), TempVal):
                self.cs.vars[vd] = 0
            if isinstance(self.cs.vars.get(wd), TempVal):
                self.cs.vars[wd] = LTable()

    def _detect_regfile(self):
        """v14.9 builds create the register file with a VM runtime helper call
        in the prologue (`local b = S[32](w)` -- a plain function behind a
        state-table slot), not a direct table.create(), so the walk sees a
        stub call. Detect the prologue local the handlers use as the register
        array -- element calls `b[v](...)`, numeric stores `b[...]=...`,
        regfile copies `p=(b)` -- and model it as a RegFile."""
        cands = {k for k, v in self.cs.vars.items() if isinstance(v, TempVal)}
        if not cands:
            return
        calluse, storeuse, copysrc = set(), set(), set()
        for _, _, w in self.loops:
            for n in iter_nodes(w):
                t = n.get("type")
                if t == "AstExprCall":
                    f = n.get("func")
                    if isinstance(f, dict) and f.get("type") == "AstExprIndexExpr" \
                            and f.get("expr", {}).get("type") == "AstExprLocal":
                        calluse.add(f["expr"]["local"]["location"])
                elif t in ("AstStatAssign", "AstStatCompoundAssign"):
                    vs = n.get("vars") if t == "AstStatAssign" else [n.get("var")]
                    for var in vs:
                        if isinstance(var, dict) and var.get("type") == "AstExprIndexExpr" \
                                and var.get("expr", {}).get("type") == "AstExprLocal":
                            storeuse.add(var["expr"]["local"]["location"])
                    if t == "AstStatAssign":
                        for val in n.get("values", []):
                            if isinstance(val, dict) and val.get("type") == "AstExprLocal":
                                copysrc.add(val["local"]["location"])
                elif t == "AstStatLocal":
                    for val in n.get("values", []):
                        if isinstance(val, dict) and val.get("type") == "AstExprLocal":
                            copysrc.add(val["local"]["location"])
        hits = [k for k in cands if k in calluse and (k in storeuse or k in copysrc)]
        if len(hits) != 1:
            return
        self.cs.vars[hits[0]] = RegFile()

    def _stack_pointer_candidates(self):
        """Prologue locals the handlers use directly as a register index
        (`R[M]`): only these can be a stack pointer. (A register VM's
        multret top is carried too, but the lifter models it otherwise.)"""

        cache = self.vm.__dict__.setdefault("_sp_cands", {})
        if None not in cache:

            pairs = set()
            for _, _, w in self.loops:
                for n in iter_nodes(w):
                    if n.get("type") == "AstExprIndexExpr" and n["expr"].get("type") == "AstExprLocal" \
                            and n["index"].get("type") == "AstExprLocal":
                        pairs.add((n["expr"]["local"]["location"], n["index"]["local"]["location"]))
            cache[None] = pairs
        _, inner = self._fresh_scopes(None, S.Interp(self.lf))
        self.lf.out = []
        regfiles = set()
        sc = inner
        while sc is not None:
            for k, v in sc.vars.items():
                if isinstance(v, RegFile):
                    regfiles.add(k)
            sc = sc.parent
        return {i for r, i in cache[None] if r in regfiles} & set(inner.vars)

    def _local_value(self, loc, before):
        """The expression a local of the loop function is declared or last assigned with."""
        for st in reversed(self.vm.inner_body[:before]):
            if st["type"] == "AstStatLocal":
                for k, v in enumerate(st["vars"]):
                    if v["location"] == loc and k < len(st["values"]):
                        return st["values"][k]
            elif st["type"] == "AstStatAssign":
                for k, v in enumerate(st["vars"]):
                    if v.get("type") == "AstExprLocal" and v["local"]["location"] == loc and k < len(st["values"]):
                        return st["values"][k]
        return None

    def _sp_value(self, locs):
        """The (int) stack-pointer value among the carried locals, if any."""
        cands = getattr(self, "sp_cands", None)
        ints = [v for k, v in locs if (cands is None or k in cands) and isinstance(v, int) and not isinstance(v, bool)]
        return ints[0] if ints else None

    def initial(self):
        if not hasattr(self, "_init_scope_vars"):
            self._init_scope_vars = []
            sc = self.cs
            while sc is not None:
                self._init_scope_vars.append((sc, dict(sc.vars)))
                sc = sc.parent
        else:
            for sc, vdict in self._init_scope_vars:
                sc.vars = dict(vdict)
            self.gov = Overlay()
        it = S.Interp(self.lf)
        cs, inner = self._fresh_scopes(None, it)
        for k, vreg in self.vreg_of.items():
            iv = inner.vars.get(k)
            if isinstance(iv, (int, float, bytes, bool)) or iv is None:
                self.vreg_init[vreg] = iv
        pc = inner.lookup(self.pc_decl).vars[self.pc_decl]
        mode = inner.lookup(self.mode_decl).vars[self.mode_decl] if self.mode_decl else 0
        ks = inner.lookup(self.vm.kstack_key) if self.vm.kstack_key else None
        locs = self._carried(inner)
        if locs:
            sb = self._sp_value(locs)
            if sb is not None:
                self.lf.stack_base = sb
        return State(mode, pc, ks.vars[self.vm.kstack_key] if ks else None, locs=locs)

    def _carried(self, inner):
        """State.locs: the carried locals' current values. Values the state
        cannot represent (impure/symbolic chains) are SKIPPED: the next
        handler then sees nil, the pre-carry behaviour -- raising here would
        discard the whole step's output."""
        out = []
        for k in sorted(self.carry):
            v = inner.vars.get(k)
            if v is None or isinstance(v, (RegFile, EnvTable, LTable, Builtin, OpaqueFn, Opaque, Buf)):
                # nil before first write; a register-file alias (v14.9's
                # `p=(b)` holding the register array between handlers); the
                # proto table, env, and other concrete VM values
                out.append((k, v))
                continue
            if isinstance(v, (Reg, Pseudo, Global)):
                # pure register reads / pseudo vars / env reads carried
                # between v14.9's split handlers
                out.append((k, v))
                continue
            if isinstance(v, Const) and (v.v is None or isinstance(v.v, (bool, int, float, bytes, str))):
                out.append((k, v))
                continue
            if isinstance(v, (bytes, str)) or \
                    (isinstance(v, (int, float)) and not isinstance(v, complex)):
                # numbers and booleans (v14.9 carries e.g. the upvalue flag)
                out.append((k, v))
                continue
            # uncarryable (symbolic chain, closure, temp): skip it
            continue
        return tuple(out)

    def _fresh_scopes(self, state, it):
        """Scopes at the top of the loop function, before the first loop;
        pc / mode / loop stack set from `state` (None: initial values)."""
        cs = Scope(self.cs.parent)
        cs.vars = dict(self.cs.vars)
        if state is not None and self.mode_init_decl:
            sc_init = cs.lookup(self.mode_init_decl)
            if sc_init is not None:
                sc_init.vars[self.mode_init_decl] = state.mode
        inner = Scope(cs)
        inner.vars["..."] = cs.vars["..."]
        self.lf.cur_scope = inner
        self.lf.in_prologue = True
        it.exec_block(self.vm.inner_body[:self.first_inner], inner)
        if self.first_init:
            it.exec_block(self.first_init, inner)
        self.lf.in_prologue = False
        for k, v in cs.vars.items():
            if k not in inner.vars:
                inner.vars[k] = v
        if state is not None:
            inner.lookup(self.pc_decl).vars[self.pc_decl] = state.pc
            if self.mode_decl:
                inner.lookup(self.mode_decl).vars[self.mode_decl] = state.mode
            if self.vm.kstack_key:
                inner.lookup(self.vm.kstack_key).vars[self.vm.kstack_key] = state.kstack
            for k, v in state.locs:
                inner.vars[k] = v
            for k, vreg in self.vreg_of.items():
                inner.vars[k] = Reg(vreg)
        return cs, inner

    def run_once(self, state, decisions, tprefix):
        lf = self.lf
        lf.out = []
        lf.tcount = 0
        lf.temp_prefix = tprefix
        lf.mutated = False
        lf.jvals = dict(state.jregs) if state is not None else {}
        lf.jread = set()
        lf.reg_gen = {}
        lf.reg_def_idx = {}
        lf.war_saved = {}

        lf.ov_base = self.gov
        lf.ov = None
        lf.packs = dict(state.packs) if state is not None else {}
        lf.pack_copies = {}
        lf.pack_read = set()
        it = S.Interp(lf)
        lf.cur_it = it
        it.decisions = list(decisions)
        cs, inner = self._fresh_scopes(state, it)
        inner.vars = acc = _AccessLog(inner.vars)
        loop_i = self._mode_loop_cache.get(state.mode) if state is not None else None
        if loop_i is None:
            for i, st, w in self.loops:
                if st is None or S.truthy(it.eval(self.conds[i], inner)):
                    loop_i = (i, st, w)
                    break
            if loop_i is not None and state is not None:
                self._mode_loop_cache[state.mode] = loop_i
        if loop_i is None:
            raise Unsupported("mode %r selects no dispatch loop" % (state.mode,))
        i, st, w = loop_i
        try:
            lf.last_op = (state.mode, it.eval(w["body"]["body"][0]["values"][0], inner))
        except Unsupported:
            lf.last_op = (state.mode, None)
        outcome = None
        try:
            try:
                it.exec_block(w["body"]["body"], Scope(inner))
                outcome = ("next",)
            except BreakSig:

                try:
                    if st is not None:
                        tb = st["thenbody"]["body"]
                        wi = tb.index(w) if w in tb else 0
                        it.exec_block(tb[wi + 1:], Scope(inner))
                    it.exec_block(self.vm.inner_body[i + 1:], inner)
                    outcome = ("ret", Multi([]))
                except YieldSig:
                    outcome = ("next",)
        except VMCrash:
            return it, Crash()
        except ReturnSig as r:
            if self.vm.post is None:
                outcome = ("ret", r.values)
            else:
                for k in list(cs.vars):
                    if k in acc.written:
                        cs.vars[k] = dict.get(acc, k)
                outcome = ("ret", self.post_return(it, cs, r.values))
        if outcome[0] == "ret" and outcome is not None and len(outcome) == 2 and outcome[1] is None:
            outcome = ("ret", Multi([]))
        if outcome[0] == "ret":
            m = outcome[1] if isinstance(outcome[1], Multi) else Multi([outcome[1]])
            outcome = ("ret", Multi([lf.value_of(x) if not isinstance(x, SymList) else x for x in m.items], m.tail))
        self._note_access(acc)
        if outcome[0] == "next":
            for k, vreg in self.vreg_of.items():
                if k in acc.written:
                    v = dict.get(acc, k)
                    if not (isinstance(v, Reg) and v.n == vreg):
                        lf.emit(Assign(Reg(vreg), lf.value_of(v)))
            def get(k):
                return inner.lookup(k).vars[k]
            locs = self._carried(inner)
            sb = lf.stack_base
            if sb is not None and locs:
                ints = [v for k, v in locs if k in self.sp_cands and isinstance(v, int) and not isinstance(v, bool)]
                top = max(ints) if ints else -1
                jr = tuple(sorted((k, v) for k, v in lf.jvals.items() if (k not in lf.jread or k in lf.cff_regs)
                                  and (k in lf.cff_regs or not (isinstance(k, int) and k > top))))
            else:
                jr = tuple(sorted((k, v) for k, v in lf.jvals.items() if k not in lf.jread or k in lf.cff_regs))
            nxt = State(get(self.mode_decl) if self.mode_decl else 0, get(self.pc_decl), get(self.vm.kstack_key) if self.vm.kstack_key else None,
                        jr, None, lf.state_packs(), locs)
            return it, Next(nxt)
        return it, Ret(outcome[1])

    def _note_access(self, acc):
        """Collect which prologue locals handlers read first / write; a new
        carried local (see __init__) sets `new_carry`."""
        if getattr(self, "no_carry", False):
            return
        for k in acc.written:
            if k not in self.vreg_of:
                self.last_written_val[k] = dict.get(acc, k)
        self.read_first |= acc.read_first
        self.written |= acc.written
        # sorted(): these are sets of decl-location strings -- iterating them in hash
        # order made the result depend on PYTHONHASHSEED (27 vs 242 unlifted blocks)
        for k in sorted((self.read_first & self.written & self.sp_cands) - self.carry - self.not_carried - self.fixed_decls, key=str):
            v = dict.get(acc, k)
            if k in self.lf.special or not (isinstance(v, int) and not isinstance(v, bool)):
                self.not_carried.add(k)
                continue
            self.carry.add(k)
            self.new_carry = True
        # v14.9: handler temps holding state across instructions (`p=(b)` in
        # one handler, `p=p[y]` in a later one) -- carry only STABLE values:
        # concrete VM objects, register reads, constants. Growing chains
        # (Bin/Index built from the temp's own previous value) would explode
        # the state space over loops, so they stay out.
        for k in sorted((self.read_first & self.written) - self.sp_cands - self.carry - set(self.vreg_of) - self.not_carried - self.fixed_decls, key=str):
            v = dict.get(acc, k)
            lw = self.last_written_val.get(k, v)
            if self.lf.stack_base is None and isinstance(lw, Reg):
                vreg = 800000 + len(self.vreg_of) + 1
                self.vreg_of[k] = vreg
                self.lf.vreg_set.add(vreg)
                self.new_carry = True
                continue
            if v is None or isinstance(v, (RegFile, EnvTable, LTable, Builtin, OpaqueFn, Opaque, Buf, bytes, str)) or \
                    isinstance(v, (Reg, Pseudo, Global)) or \
                    (isinstance(v, Const) and (v.v is None or isinstance(v.v, (bool, int, float, bytes, str)))):
                self.carry.add(k)
                self.new_carry = True
        if self.lf.stack_base is None:
            for k in sorted(self.carry, key=str):
                lw = self.last_written_val.get(k)
                if isinstance(lw, Reg) and lw.n not in self.lf.vreg_set:
                    self.carry.discard(k)
                    vreg = 800000 + len(self.vreg_of) + 1
                    self.vreg_of[k] = vreg
                    self.lf.vreg_set.add(vreg)
                    self.new_carry = True

    def post_return(self, it, cs, values):
        """The handler returned from the protected function: run the code after it."""
        vals = it.adjust(values, 4)
        ps = Scope(cs)
        names = self.vm.tstat["vars"]
        ps.vars[names[0]["location"]] = True
        for v, x in zip(names[1:], vals):
            ps.vars[v["location"]] = x
        try:
            it.exec_block(self.vm.post, ps)
        except ReturnSig as r:
            return r.values
        return Multi([])

    def step(self, state, tprefix):
        """All paths of one instruction -> Node tree. Decoders re-dispatch."""
        for _ in range(8):
            paths = []
            writes = None
            todo = [[]]
            while todo:
                dec = todo.pop()
                it, oc = self.run_once(state, dec, tprefix)
                if len(paths) > 64:
                    raise Unsupported("too many paths in one instruction")
                taken = [d[3] for d in it.dlog]
                for j in range(len(dec), len(taken)):
                    todo.append(taken[:j] + [not taken[j]])
                paths.append((taken, it.dlog, list(self.lf.out), oc))
                if len(paths) == 1:
                    writes = self.lf.ov
            if writes is not None:

                for k, v in writes.d.items():
                    if k[0] not in self.lf.proto_arrays or not is_sym(v):
                        self.gov.d[k] = v
                dump = self.lf.dump
                for k, v in writes.d.items():
                    if k[0] in dump.buf_loc and isinstance(k[1], int):
                        dump.buf_patch[k] = v
                    elif k[0] in dump.tid_of and k[0] not in self.lf.proto_arrays and                             isinstance(k[1], int) and isinstance(v, (int, float)) and not isinstance(v, bool):
                        dump.tab_patch[(dump.tid_of[k[0]], k[1])] = v
            if len(paths) == 1 and not paths[0][2] and isinstance(paths[0][3], Next) \
                    and self.lf.mutated and paths[0][3].state.pc == state.pc:

                state = paths[0][3].state
                continue
            node = build_tree(paths, 0, 0)
            node.op = self.lf.last_op
            return node
        raise Unsupported("instruction keeps re-decoding itself")

JIT_ENTRY = -(1 << 40)     
JIT_TMP = 900000           

def jit_maker_parts(node):
    """LPH_JIT functions are VM-object methods `function(g, upvals, P) local
    W = P[P[k]]; return function(params) <prologue> while c do <if tree on
    a state variable> end end`: plain Lua (a control-flow-flattened state
    machine over the constant array W), not bytecode. -> (index of the proto
    parameter, the inner function) for such a maker, else None."""
    if not isinstance(node, dict) or node.get("type") != "AstExprFunction":
        return None
    body = node["body"]["body"]
    if len(body) != 2 or body[0]["type"] != "AstStatLocal" or body[1]["type"] != "AstStatReturn":
        return None
    vals, ret = body[0]["values"], body[1]["list"]
    if len(vals) != 1 or len(ret) != 1 or ret[0]["type"] != "AstExprFunction":
        return None
    v = vals[0]
    if v["type"] != "AstExprIndexExpr" or v["expr"]["type"] != "AstExprLocal" \
            or v["index"]["type"] != "AstExprIndexExpr" or v["index"]["expr"]["type"] != "AstExprLocal":
        return None
    p = v["expr"]["local"]["location"]
    if v["index"]["expr"]["local"]["location"] != p:
        return None
    pis = [i for i, a in enumerate(node["args"]) if a["location"] == p]
    inner = ret[0]
    if not pis or not any(st["type"] == "AstStatWhile" for st in inner["body"]["body"]):
        return None
    return pis[-1], inner

class JitModel(VMModel):
    """An LPH_JIT function (jit_maker_parts), lifted like a one-mode VM: one
    pass of its dispatch loop is an instruction, the state variable is the
    pc, and its parameters and the locals of its prologue are registers
    (except those holding a fixed value, see JitStepper). Registered as a
    sibling maker: the closure op that calls this maker makes a ClosureExpr
    with this model."""

    def __init__(self, maker, ctor, pi, inner):
        self.info = {"maker": maker, "vm": inner, "proto_index": pi, "upvals_index": 1}
        self.maker, self.vm, self.ctor_funcs = maker, inner, ctor
        self.maker_decls = {}
        self.inner = inner
        self.inner_body = inner["body"]["body"]
        self.prologue, self.tstat, self.post = [], None, None
        self.kstack_key = self.kstack_link = None
        self.wi = next(i for i, st in enumerate(self.inner_body) if st["type"] == "AstStatWhile")
        w = self.inner_body[self.wi]
        self.dispatch = {id(w)}
        c = w["condition"]
        self.cond_decl = c["local"]["location"] if c["type"] == "AstExprLocal" else None
        self.pc_decl = None
        for st in w["body"]["body"]:
            if st["type"] == "AstStatIf":
                c = st["condition"]
                if c["type"] == "AstExprBinary" and c["left"]["type"] == "AstExprLocal":
                    self.pc_decl = c["left"]["local"]["location"]
                break
            if st["type"] != "AstStatLocal" or st["values"]:
                break
        if self.pc_decl is None:
            raise Unsupported("LPH_JIT function without a state dispatch")
        self.assigned = set()       
        for n in iter_nodes(w):
            if n.get("type") == "AstStatAssign":
                self.assigned |= {v["local"]["location"] for v in n["vars"] if v["type"] == "AstExprLocal"}
            elif n.get("type") == "AstStatCompoundAssign" and n["var"]["type"] == "AstExprLocal":
                self.assigned.add(n["var"]["local"]["location"])
        self.params = [a["location"] for a in inner["args"]]
        self.locals = [v["location"] for st in self.inner_body[:self.wi] if st["type"] == "AstStatLocal"
                       for v in st["vars"]]

        self.jstack = None
        for n in iter_nodes(w):
            if n.get("type") == "AstExprTable":
                for it in n["items"]:
                    v = it["value"]
                    if v["type"] == "AstExprLocal" and v["local"]["location"] in self.locals:
                        self.jstack = v["local"]["location"]

        live = _jit_live_in(w, self.pc_decl, set(self.params + self.locals))
        self.special = {}
        if self.jstack is not None:
            self.special[self.jstack] = ("jstack",)
        for loc in self.params + self.locals:
            if loc not in (self.pc_decl, self.cond_decl) and loc not in self.special and loc in live:
                self.special[loc] = ("reg", len(self.special) + 1)

class JitFrame(LTable):
    """One entry of an LPH_JIT function's loop stack (`N = {..., N, ...}`,
    the link slot varies per loop): its other slots are Pseudo variables of
    that depth, like the VM's loop stack K. JIT_BOTTOM is the empty stack."""
    __slots__ = ("link", "depth")

    def __init__(self, link, depth):
        LTable.__init__(self)
        self.link, self.depth = link, depth

JIT_BOTTOM = JitFrame(None, 0)

class JitProto(LTable):
    """The "proto" of a function an LPH_JIT function defines (a Lua closure,
    itself a state machine): where it was made (env) and which outer locals
    it uses as upvalues (upmap: declaration -> upvalue index)."""
    __slots__ = ("env", "upmap")

    def __init__(self, env, upmap):
        LTable.__init__(self)
        self.env, self.upmap = env, upmap

_JIT_NESTED = {}
_JIT_TAGGED = {}       

def _jit_nested_model(node):
    if id(node) not in _JIT_NESTED:
        try:
            jm = JitModel(None, {}, None, node)
            jm.tag = "jit-nested@%s" % (node.get("location"),)
            _JIT_TAGGED[jm.tag] = jm
            _JIT_NESTED[id(node)] = (node, jm)
        except (Unsupported, StopIteration, KeyError):
            _JIT_NESTED[id(node)] = (node, None)
    return _JIT_NESTED[id(node)][1]

def _declared_in(node):
    cache = node.get("_decl_in")
    if cache is not None:
        return cache
    out = {a["location"] for a in node.get("args", [])}
    for n in iter_nodes(node):
        t = n.get("type")
        if t in ("AstStatLocal", "AstStatForIn"):
            out |= {v["location"] for v in n["vars"]}
        elif t == "AstStatFor":
            out.add(n["var"]["location"])
        elif t == "AstStatLocalFunction":
            out.add(n["name"]["location"])
        elif t == "AstExprFunction":
            out |= {a["location"] for a in n["args"]}
    node["_decl_in"] = out
    return out

def _jit_live_in(w, pc_decl, cands):
    """Candidates (declarations) some step of the dispatch loop `w` reads
    before it assigns them, or that a function made inside reads. A step is
    the loop body's statements before the dispatch `if` plus one leaf of the
    `if pc <= K` tree."""
    live = set()

    def is_dispatch(st):
        c = st.get("condition") if st.get("type") == "AstStatIf" else None
        return c is not None and c["type"] == "AstExprBinary" and c["left"]["type"] == "AstExprLocal" \
            and c["left"]["local"]["location"] == pc_decl

    def expr(e, done):
        for n in iter_nodes(e):
            t = n.get("type")
            if t == "AstExprLocal" and n["local"]["location"] in cands and n["local"]["location"] not in done:
                live.add(n["local"]["location"])
            elif t == "AstExprFunction":
                live.update(x["local"]["location"] for x in iter_nodes(n)
                            if x.get("type") == "AstExprLocal" and x["local"]["location"] in cands)

    def block(stmts, done):
        done = set(done)
        for st in stmts:
            t = st["type"]
            if t == "AstStatLocal":
                for v in st["values"]:
                    expr(v, done)
            elif t == "AstStatAssign":
                for v in st["values"]:
                    expr(v, done)
                for v in st["vars"]:
                    if v["type"] != "AstExprLocal":
                        expr(v, done)
                for v in st["vars"]:
                    if v["type"] == "AstExprLocal":
                        done.add(v["local"]["location"])
            elif t == "AstStatCompoundAssign":
                expr(st["var"], done)
                expr(st["value"], done)
            elif t == "AstStatIf":
                expr(st["condition"], done)
                a = block(st["thenbody"]["body"], done)
                e = st.get("elsebody")
                if e is None:
                    b = done
                elif e["type"] == "AstStatIf":
                    b = block([e], done)
                else:
                    b = block(e["body"], done)
                done = a & b
            elif t in ("AstStatWhile", "AstStatRepeat"):
                expr(st["condition"], done)
                block(st["body"]["body"], done)
            elif t == "AstStatFor":
                for k in ("from", "to", "step"):
                    if st.get(k):
                        expr(st[k], done)
                block(st["body"]["body"], done)
            elif t == "AstStatForIn":
                for v in st["values"]:
                    expr(v, done)
                block(st["body"]["body"], done)
            elif t == "AstStatBlock":
                done = block(st["body"], done)
            else:
                expr(st, done)
        return done

    def leaves(stmts, done):

        if len(stmts) == 1 and is_dispatch(stmts[0]):
            st = stmts[0]
            leaves(st["thenbody"]["body"], done)
            e = st.get("elsebody")
            if e is not None:
                leaves([e] if e["type"] == "AstStatIf" else e["body"], done)
        else:
            block(stmts, done)

    body = w["body"]["body"]
    i = next((k for k, st in enumerate(body) if is_dispatch(st)), len(body))
    done = block(body[:i], set())
    leaves(body[i:i + 1], done)
    if i + 1 < len(body):
        block(body[i + 1:], set())
    expr(w["condition"], set())
    return live

def _fixed_value(v):
    """A prologue local's value that is the same on every entry (the
    environment, library functions, constants, dump tables): kept as a value."""
    if v is None or isinstance(v, (bool, int, float, bytes, EnvTable, Builtin, OpaqueFn, LuaFunc,
                                   UpList, BoxProxy, FrameProxy)):
        return True
    if isinstance(v, LTable):
        return v.tid is not None
    if isinstance(v, SymList):
        return not v.items and v.tail is None
    return False

class JitStepper(Stepper):
    """Stepper for a JitModel. The entry (pc JIT_ENTRY) runs the prologue
    and assigns the registers; every other step runs the prologue again
    only to rebuild the fixed values, then one pass of the loop body."""

    def __init__(self, vm, lifter):
        self.vm = vm
        self.lf = lifter
        self.cs = lifter.initial_state()
        self.loops = [(vm.wi, None, vm.inner_body[vm.wi])]
        self.mode_decl = None
        self.pc_decl = vm.pc_decl
        self.conds = {}
        self.first_inner = vm.wi
        self.gov = Overlay()
        lifter.special = dict(vm.special)
        if isinstance(lifter.proto, JitProto):
            for loc, k in lifter.proto.upmap.items():
                lifter.special[loc] = ("upval", k)
        lifter.out = []
        _, inner = self._fresh_scopes(None, S.Interp(lifter))
        for loc in vm.locals:
            if loc in lifter.special and loc not in vm.assigned and _fixed_value(inner.vars.get(loc)):
                del lifter.special[loc]
        lifter.out = []

    def _fresh_scopes(self, state, it, entry=False):
        vm, lf = self.vm, self.lf
        cs = Scope(self.cs.parent)
        cs.vars = dict(self.cs.vars)
        inner = Scope(cs)
        lf.in_prologue = not entry
        lf.jstack = JIT_BOTTOM
        for i, loc in enumerate(vm.params, 1):
            inner.vars[loc] = Vararg(i)
            if lf.special.get(loc):
                lf.special_set(lf.special[loc], Vararg(i), it)
        if vm.inner.get("vararg"):
            inner.vars["..."] = Multi([], VarargTail(len(vm.params) + 1))
        lf.cur_scope = inner
        it.exec_block(vm.inner_body[:vm.wi], inner)
        lf.in_prologue = False
        if state is not None and isinstance(state.kstack, JitFrame):
            lf.jstack = state.kstack
        if not entry and state is not None:
            inner.lookup(self.pc_decl).vars[self.pc_decl] = state.pc
        return cs, inner

    def initial(self):
        return State(0, JIT_ENTRY, JIT_BOTTOM)

    def step(self, state, tprefix):
        node = Stepper.step(self, state, tprefix)
        _jit_forloop(node, self.lf)
        return node

    def run_once(self, state, decisions, tprefix):
        lf = self.lf
        vm = self.vm
        lf.out = []
        lf.tcount = 0
        lf.temp_prefix = tprefix
        lf.mutated = False
        lf.jvals = dict(state.jregs)
        lf.jread = set()
        lf.ov_base = self.gov
        lf.ov = None
        lf.packs = dict(state.packs)
        lf.pack_copies = {}
        lf.pack_read = set()
        it = S.Interp(lf)
        it.decisions = list(decisions)
        lf.last_op = (0, state.pc)
        entry = state.pc == JIT_ENTRY
        try:
            cs, inner = self._fresh_scopes(state, it, entry)
            if not entry:
                lf.out = []         
                ended = False
                try:
                    it.exec_block(vm.inner_body[vm.wi]["body"]["body"], Scope(inner))
                except ContinueSig:
                    pass
                except BreakSig:
                    ended = True
                if not ended and vm.cond_decl is not None:
                    cv = inner.lookup(vm.cond_decl).vars[vm.cond_decl]
                    if is_sym(cv):
                        raise Unsupported("symbolic LPH_JIT loop condition")
                    ended = not S.truthy(cv)
                if ended:
                    it.exec_block(vm.inner_body[vm.wi + 1:], inner)
                    raise ReturnSig(Multi([]))
        except VMCrash:
            return it, Crash()
        except ReturnSig as r:
            m = r.values if isinstance(r.values, Multi) else Multi([r.values])
            return it, Ret(Multi([lf.value_of(x) if not isinstance(x, SymList) else x for x in m.items], m.tail))
        pc = inner.lookup(self.pc_decl).vars[self.pc_decl]
        jr = tuple(sorted((k, v) for k, v in lf.jvals.items() if k not in lf.jread))
        return it, Next(State(0, pc, lf.jstack, jr, None,
                              lf.state_packs()))

def _jit_forloop(node, lf):
    """An LPH_JIT numeric-for header (`c, s, l = N[..]; u = c + s; N[c] = u;
    if (s <= 0 and u >= l) or (s > 0 and u <= l) then var = u; body else
    exit`) in the shape of the VM's FORLOOP handler (loops.try_numeric):
    `c = c + s; if s <= 0 then (if c >= l ...) else (if c <= l ...)`."""
    c0 = node.cond
    if node.stmts or not (isinstance(c0, Bin) and c0.op == "CompareLe" and isinstance(c0.a, Pseudo)
                          and isinstance(c0.b, Const) and c0.b.v == 0):
        return
    step = c0.a
    found = None
    for side, op in ((node.then, "CompareGe"), (node.els, "CompareLe")):
        cc = getattr(side, "cond", None)
        if side is None or len(side.stmts) > 1 or not (isinstance(cc, Bin) and cc.op == op
                                                       and isinstance(cc.b, Pseudo)):
            return
        sm = cc.a
        if not (isinstance(sm, Bin) and sm.op == "Add" and isinstance(sm.a, Pseudo) and sm.b == step
                and sm.a.depth == step.depth and cc.b.depth == step.depth):
            return
        t, e = side.then, side.els
        if t is None or e is None or t.cond is not None or e.cond is not None:
            return
        f = fmt_expr(sm)

        if side.stmts and len(t.stmts) <= 1 and not e.stmts:
            a1, a3 = side.stmts[0], side.stmts[0]
            a2 = t.stmts[0] if t.stmts else None
        elif not side.stmts and len(t.stmts) in (1, 2) and len(e.stmts) == 1:
            a1, a3 = t.stmts[0], e.stmts[0]
            a2 = t.stmts[1] if len(t.stmts) == 2 else None
        else:
            return
        if not all(isinstance(x, Assign) for x in (a1, a2 or a1, a3)):
            return
        if not (a1.target == sm.a and a3.target == sm.a and fmt_expr(a1.value) == f and fmt_expr(a3.value) == f
                and (a2 is None or (isinstance(a2.target, Reg) and fmt_expr(a2.value) == f))):
            return
        key = (sm.a, cc.b, a2.target.n if a2 is not None else None)
        if found is not None and found != key:
            return
        found = key
    cnt, lim, var = found
    if var is None:
        lf.tmp_regs = getattr(lf, "tmp_regs", 0) + 1
        var = JIT_TMP + lf.tmp_regs
    node.stmts = [Assign(cnt, Bin("Add", cnt, step))]
    for side in (node.then, node.els):
        side.stmts = []
        side.cond = Bin(side.cond.op, cnt, lim)
        side.then.stmts = [Assign(Reg(var), cnt)]
        side.els.stmts = []

def make_stepper(vm, lifter):
    return JitStepper(vm, lifter) if isinstance(vm, JitModel) else Stepper(vm, lifter)

_BT_WARNED = [False]

def build_tree(paths, d, start):
    """paths share decisions[:d]; statements before `start` were emitted already."""
    if len(paths) == 1 and len(paths[0][0]) <= d:
        taken, dlog, out, oc = paths[0]
        return Node(out[start:], outcome=oc)

    p0 = paths[0]
    if len(p0[0]) <= d or len(p0[1]) <= d:
        # decisions exhausted -- or the decision log is shorter than the
        # decision list (a re-dispatch edge case): there is no logged branch
        # position at depth d to split on, so the only sound shape is a leaf
        # carrying p0's statements.
        if len(p0[0]) > d and not _BT_WARNED[0]:
            _BT_WARNED[0] = True
            print("[!] devirt: decision log shorter than the decision list at depth %d; "
                  "emitting the prefix as a leaf (one branch may be partial)" % d, file=sys.stderr)
        taken, dlog, out, oc = p0
        return Node(out[start:], outcome=oc)
    _, cond, _ = p0[1][d][1], p0[1][d][2], None
    at = p0[1][d][1]
    stmts = p0[2][start:at]
    tp = [p for p in paths if p[0][d]]
    fp = [p for p in paths if not p[0][d]]
    then = build_tree(tp, d + 1, at) if tp else None
    els = build_tree(fp, d + 1, at) if fp else None
    return Node(stmts, cond=cond, then=then, els=els)

def chunk_key(src):
    """Same key as deob.chunk_key / srcKey() in envlog.luau (the __maker tag prefix)."""
    return harness.chunk_key(src)

_SOURCE_CACHE = {}      

def analyze_source(path):
    """AST, VM models and constructor functions of one VM source file. Depends
    only on the text, so constant rounds reuse it."""
    with open(path, encoding="latin-1", newline="") as f:
        text = f.read()
    hit = _SOURCE_CACHE.get(text)
    if hit is not None:
        return hit
    root = vmmap.load_ast(path)
    key = chunk_key(text)
    disp = vmmap.find_dispatchers(root)
    ctor = find_ctor_funcs(root)
    assign_ctor = vmmap.ctor_assignments(root)
    vms = {}
    for info in vmmap.maker_info(root, disp):
        vm_node = info["vm"]
        ids = {id(n) for n in iter_nodes(vm_node)}
        inside = [d["node"] for d in disp if id(d["node"]) in ids]
        tag = "%s@%d,%d" % ((key,) + tuple(info["at"]))
        vms[tag] = VMModel(info, inside, ctor)
        vms[tag].tag = tag
        vms[tag].outer = vmmap.outer_decls(root, vm_node)
        vms[tag].assign_ctor = assign_ctor

    for k, node in ctor.items():
        parts = jit_maker_parts(node)
        if parts is not None:
            try:
                jm = JitModel(node, ctor, parts[0], parts[1])
            except Unsupported:
                continue
            jm.tag = "%s@jit:%s" % (key, k.decode("latin-1") if isinstance(k, bytes) else k)
            vms[jm.tag] = jm

    siblings = {id(vm.maker): vm for vm in vms.values()}
    for vm in vms.values():
        vm.siblings = siblings
    hit = _SOURCE_CACHE[text] = (root, text.split("\n"), vms, ctor)
    return hit

_WALK_HINTS = {}

class Program:
    def __init__(self, source_path, dump_path, chunk_paths=()):
        """source_path: the obfuscated script; chunk_paths: original sources of
        VM chunks it loadstring'd (their protos are tagged with their key)."""
        self.dump = Dump(dump_path)
        self.vms = {}
        self.ctors = {}
        for i, path in enumerate([source_path] + list(chunk_paths)):
            root, lines, vms, ctor = analyze_source(path)
            if i == 0:
                self.root = root
                self.lines = lines
            for tag, vm in vms.items():
                self.vms[tag] = vm
                self.ctors[id(vm)] = ctor
                vm.src_lines = lines
        self.dump.vm_names = {vm.maker["args"][0]["name"] for vm in self.vms.values()
                              if vm.maker.get("args")} | {
            vm.info["chain"][0]["args"][0]["name"] for vm in self.vms.values()
            if vm.info.get("chain") and vm.info["chain"][0].get("args")
        }

        # dump protos captured under a different chunk name (the harness may
        # tag a captured chunk "payload") still match by their @line,col
        # suffix: rewrite the tag so vm_of finds the analyzed VM model
        by_suffix = {}
        for tag in self.vms:
            by_suffix[tag.rpartition("@")[2]] = tag
        self.dump.vms = self.vms
        self.dump.by_suffix = by_suffix
        for cap in self.dump.protos.values():
            mk = cap.get("__maker")
            if mk is None:
                continue
            tag = mk.decode("latin-1") if isinstance(mk, bytes) else str(mk)
            if tag not in self.vms:
                hit = by_suffix.get(tag.rpartition("@")[2])
                if hit is not None:
                    cap["__maker"] = hit.encode("latin-1")

        # index the captures by their self table so a lifted child proto finds
        # its own captured state (its W/V/... tables) instead of its parent's
        self.dump.cap_by_self = {}
        self.dump.cap_by_state = {}
        for cap in self.dump.protos.values():
            sv = cap.get("self")
            if isinstance(sv, LTable):
                self.dump.cap_by_self[sv.tid] = cap
            mk = cap.get("__maker")
            vmk = None
            if mk is not None:
                t = mk.decode("latin-1") if isinstance(mk, bytes) else str(mk)
                vmk = self.vms.get(t)
            st = cap.get(vmk.maker["args"][0]["name"]) if vmk is not None and isinstance(vmk.maker, dict) \
                and vmk.maker.get("args") else None
            if isinstance(st, LTable):
                self.dump.cap_by_state[st.tid] = cap

        # VM-wide capture fields every proto's capture agrees on (helpers,
        # shared tables): the values uncaptured children still need
        shared = {}
        caps_list = [c for c in self.dump.protos.values() if c.get("__maker") is not None]
        if caps_list:
            for nm in caps_list[0]:
                if nm in ("self", "__maker", "__seq"):
                    continue
                vs = [c.get(nm) for c in caps_list]
                ids = {v.get("t") if isinstance(v, dict) else id(v) for v in vs}
                if len(ids) == 1:
                    v = vs[0]
                    if v is None or isinstance(v, (LTable, Builtin, OpaqueFn, Opaque,
                                                   int, float, bytes, bool)):
                        shared[nm] = v
        self.dump.shared_cap = shared

        for cap in self.dump.protos.values():
            try:
                vm = self.vm_of(cap)
            except Unsupported:
                # a proto whose __maker tag has no saved VM source (loadstring'd
                # chunk that was not written out): skip it instead of aborting
                # the whole Program construction
                continue
            ctor = self.ctors[id(vm)]
            assign_ctor = getattr(vm, "assign_ctor", {})
            for nm, e in cap.items():
                if not isinstance(e, LTable):
                    continue
                for k, v in e.h.items():
                    if not isinstance(v, OpaqueFn) or v.node is not None:
                        continue
                    fn = None
                    if k in ctor:
                        fn = ctor[k]
                    elif isinstance(k, int) and k in ctor:
                        fn = ctor[k]
                    elif isinstance(k, int):
                        fn = assign_ctor.get((nm.encode("latin-1"), k))
                    elif isinstance(k, bytes):
                        fn = assign_ctor.get((nm.encode("latin-1"), S.fix_int(k)))
                    if fn is not None:
                        v.node = fn
        g = LTable()
        for lib in ("bit32", "string", "table", "math", "buffer", "utf8"):
            t = LTable()
            for nm in list(S.CONCRETE) + ["table.pack", "table.unpack", "table.move", "table.create"]:
                if nm.startswith(lib + "."):
                    t.set(nm.split(".", 1)[1].encode(), Builtin(nm))
            g.set(lib.encode(), t)
        for nm in ("select", "unpack", "getfenv", "setfenv", "tonumber"):
            g.set(nm.encode(), Builtin(nm))
        self.globals = g

    def vm_of(self, cap):
        tag = cap.get("__maker").decode("latin-1")
        if tag not in self.vms:
            raise Unsupported("no source for VM %s (a loadstring'd chunk that was not saved?)" % tag)
        return self.vms[tag]

    def lift_raw(self, key, upvals=None, limit=200000):
        cap = self.dump.protos[key]
        vm = self.vm_of(cap)
        if upvals is None:
            upvals = UpList()
        proto = vm.proto_of(cap)
        lf = ProtoLifter(vm, self.dump, vm.vmobj_of(cap), proto, upvals, self.globals, cap=cap)
        st = make_stepper(vm, lf)
        for _ in range(WALK_RESTARTS):
            s0, order, restart = self._walk(vm, lf, st, limit)
            if not restart:
                break
        return s0, order, lf

    def _walk(self, vm, lf, st, limit):
        """Sparse conditional constant propagation over the instruction graph.
        Each state (mode, pc, loop depth, jump registers, packs) is stepped
        once; register facts (constant / truthy / falsy) flow along edges and
        meet at merges. A branch whose condition the facts decide only enables
        one edge, so Luraph's opaque predicates never lead into junk code
        (which would also run bogus in-place decryptors).
        Returns (entry, [(key, node)], restart)."""
        hkey = (id(vm), getattr(lf.proto, "tid", None))
        if hkey[1] is not None and hkey in _WALK_HINTS:
            hj, hcff, hpu, hcar, hvr, hvrs = _WALK_HINTS[hkey]
            lf.jump_regs |= hj - lf.arith_regs
            lf.cff_regs |= hcff - lf.arith_regs
            lf.pack_unstable |= hpu
            if hasattr(st, "carry") and not getattr(st, "no_carry", False):
                st.carry |= hcar
            if hasattr(st, "vreg_of"):
                st.vreg_of.update(hvr)
                lf.vreg_set |= hvrs
        s0 = st.initial()
        link = vm.kstack_link
        nodes = {}          
        states = {}         
        facts = {}          
        order = []
        pred = {}          # (walk-local: nothing reads these after the
        edges = {}         #  walk; holding them through lower() OOM'd runs)
        work = deque([s0.key(link)])
        states[work[0]] = s0
        init_f = dict(getattr(lf, "init_facts", None) or {})
        for vr, iv in getattr(st, "vreg_init", {}).items():
            init_f[vr] = ("c", iv)
        facts[work[0]] = init_f
        inwork = {work[0]}
        pack_sets = {}      
        pending = set()     
        need_restart = False
        depth_at = {}       
        hubs = set()        
        steps = 0
        nerr = 0
        unique_seen = 0
        plateau = 0
        while work and len(order) < limit:
            k = work.popleft()
            inwork.discard(k)
            s = states[k]
            node = nodes.get(k)
            if node is None:
                try:
                    lf.cur_facts = facts.get(k, {})
                    node = st.step(s, "%d_%d_" % (s.pc, len(order)))
                except Unsupported as e:
                    if os.environ.get("DEVIRT_TB"):
                        import traceback
                        print("-- at %s:%s op %s" % (s.mode, s.pc, lf.last_op), file=sys.stderr)
                        for arr in [v_ for v_ in lf.proto.h.values() if isinstance(v_, LTable)]:
                            for pc_ in range(s.pc - 2, s.pc + 2):
                                base = arr.get(pc_)
                                print("   arr#%s[%d] = %s -> %s" % (arr.tid, pc_, base, st.gov.d.get((id(arr), pc_), base)), file=sys.stderr)
                        traceback.print_exc()
                    node = Node([], outcome=None)
                    node.error = str(e)
                    nerr += 1
                if getattr(st, "new_carry", False):

                    st.new_carry = False
                    return s0, order, True
                if getattr(lf, "cff_dropped", False):
                    lf.cff_dropped = False
                    return s0, order, True
                nodes[k] = node
                order.append((k, node))
                if len(order) % 5000 == 0:
                    seen_now = len(set((kk[0], kk[1]) for kk, _ in order))
                    if seen_now == unique_seen:
                        plateau += 5000
                        if plateau >= 25000:
                            break
                    else:
                        unique_seen = seen_now
                        plateau = 0
                if lf.walk_only and nerr > WALK_MAX_ERRORS:

                    break
            steps += 1
            if steps > limit * 20:
                break
            if lf.stack_base is not None and len(order) > STACK_WALK_MAX and getattr(st, "carry", None):

                st.carry = set()
                st.no_carry = True
                lf.stack_base = None
                lf.jump_regs = set()
                return s0, order, True
            succ = []
            restart = propagate(node, dict(facts[k]), succ, lf)
            if restart == "cff_restart":
                return s0, order, True
            if restart:
                node.error = restart
            for ns, nf in succ:
                sym_mode, sym_pc = getattr(node, "_sym_outcome", (ns.mode, ns.pc))
                if not isinstance(sym_pc, int) or not isinstance(sym_mode, int):
                    node._sym_outcome = (sym_mode, sym_pc)
                    regs = {r.n for x in (sym_pc, sym_mode) if not isinstance(x, int)
                            for r in expr_regs(x)} - lf.jump_regs
                    if regs and lf.stack_base is not None:

                        pending |= regs
                        continue
                    npc, nmode = sym_pc, sym_mode
                    if not isinstance(npc, int):
                        pf = eval_fact(npc, nf)
                        if pf and pf[0] == "c" and isinstance(pf[1], int) and not isinstance(pf[1], bool):
                            npc = pf[1]
                    if not isinstance(nmode, int):
                        mf = eval_fact(nmode, nf)
                        if mf and mf[0] == "c" and isinstance(mf[1], int) and not isinstance(mf[1], bool):
                            nmode = mf[1]
                    resolved = isinstance(npc, int) and isinstance(nmode, int)
                    if regs and not resolved:
                        valid_regs = set()
                        for r in regs:
                            if r not in lf.int_regs:
                                continue
                            rf = eval_fact(Reg(r), nf)
                            if r in lf.merged_int_regs or (rf and rf[0] == "c" and isinstance(rf[1], int) and not isinstance(rf[1], bool)):
                                valid_regs.add(r)
                        if valid_regs:
                            lf.jump_regs |= valid_regs
                            need_restart = True
                    if resolved:
                        ns = State(nmode, npc, ns.kstack, ns.jregs, ns.ov, ns.packs, ns.locs)
                        if node.cond is None and isinstance(node.outcome, Next):
                            node.outcome = Next(ns)
                    else:
                        if need_restart:
                            return s0, order, True
                        node.error = "symbolic next pc/mode: %s / %s" % (fmt_any(sym_pc), fmt_any(sym_mode))
                        continue
                if ns.locs:

                    if ns.pc != s.pc + 1 and s.locs and _locs_lt(ns.locs, s.locs):
                        hubs.add((s.mode, s.pc))
                    seen_locs = depth_at.setdefault(
                        (ns.mode, ns.pc, tuple((rk, _hv(rv)) for rk, rv in ns.jregs)), set())
                    # the depth limiter tracks the STACK POINTER value only:
                    # keying on the whole locs tuple multiplied states wherever
                    # a carried local held a concrete object (a decryptor's
                    # buffer, an opaque helper), exhausting MAX_STACK_DEPTHS
                    # on semantically equal states
                    spv = st._sp_value(ns.locs)
                    if spv not in seen_locs and len(seen_locs) >= MAX_STACK_DEPTHS \
                            and (ns.mode, ns.pc) not in hubs:
                        node.error = "stack depth %s at %s:%s (seen %s)" % (
                            st._sp_value(ns.locs), ns.mode, ns.pc,
                            sorted(seen_locs, key=repr))
                        continue
                    seen_locs.add(spv)
                nk = ns.key(link)

                core = nk[:5]
                seen = pack_sets.setdefault(core, nk[5])
                if seen != nk[5]:
                    bad = (set(seen) ^ set(nk[5])) & lf.pack_killed
                    if bad - lf.pack_unstable:
                        lf.pack_unstable |= bad
                        return s0, order, True
                edges.setdefault(k, set()).add(nk)
                if nk not in facts:
                    facts[nk] = nf
                    states[nk] = ns
                    pred[nk] = k
                    changed = True
                else:
                    old = facts[nk]
                    for rk, ov in old.items():
                        nv = nf.get(rk)
                        if (ov and nv and ov[0] == "c" and nv[0] == "c"
                                and isinstance(ov[1], int) and not isinstance(ov[1], bool)
                                and isinstance(nv[1], int) and not isinstance(nv[1], bool)
                                and ov[1] != nv[1]):
                            lf.merged_int_regs.add(rk)
                    m = meet(old, nf)
                    changed = m != old
                    facts[nk] = m
                if changed and nk not in inwork:
                    if nk in nodes:
                        work.appendleft(nk)
                    else:
                        work.append(nk)
                    inwork.add(nk)
        self.facts = facts
        if lf.need_jump_regs - lf.jump_regs:
            pending |= (lf.need_jump_regs - lf.jump_regs)
        if pending or need_restart:
            lf.jump_regs |= pending
            return s0, order, True
        if hkey[1] is not None:
            _WALK_HINTS[hkey] = (
                set(lf.jump_regs), set(lf.cff_regs), set(lf.pack_unstable),
                set(getattr(st, "carry", ())), dict(getattr(st, "vreg_of", {})), set(lf.vreg_set)
            )
        return s0, order, False

def show_op(prog, key, mode, pc, force_op=None):
    cap = prog.dump.protos[key]
    vm = prog.vm_of(cap)
    lf = ProtoLifter(vm, prog.dump, vm.vmobj_of(cap), vm.proto_of(cap),
                     LTable(), prog.globals, cap=cap)
    st = make_stepper(vm, lf)
    lines = prog.lines
    for i, ifn, w in st.loops:
        c = st.conds[i]
        k = c["right"] if c["right"]["type"] == "AstExprConstantNumber" else c["left"]
        if S.fix_int(k["value"]) != mode:
            continue
        d = [x for x in vmmap.find_dispatchers(prog.root) if x["node"] is w][0]
        arrs = {}
        for nm, keys in vm.maker_decls.items():
            if len(keys) == 1 and keys[0] in lf.maker_scope.vars:
                v = lf.maker_scope.vars[keys[0]]
                if isinstance(v, LTable) and id(v) in lf.proto_arrays:
                    arrs[nm] = v

        opname = d["arr"]
        cs = st.cs
        it = S.Interp(lf)
        _, inner = st._fresh_scopes(None, it)
        stmt = w["body"]["body"][0]
        opv = it.eval(stmt["values"][0]["expr"], inner)
        op = opv.get(pc) if force_op is None else force_op
        print("mode %d pc %d: op %s (array %s)" % (mode, pc, op, opname))
        for nm, v in sorted(arrs.items()):
            print("   %s[%d] = %s" % (nm, pc, fmt_any(v.get(pc))))
        blk = vmmap.resolve(d["tree"], d["op"], op)
        print(vmmap.text_of(lines, blk) if blk else "<no handler>")
        return
    print("no loop for mode", mode)

def main():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("source")
    ap.add_argument("protos")
    ap.add_argument("--raw", help="print the raw listing of one proto key")
    ap.add_argument("--lift", help="lift one proto key (with its closures) to Luau")
    ap.add_argument("--op", nargs=2, metavar=("PROTO", "MODE:PC[:OP]"), help="show the handler of one instruction (OP: as decrypted)")
    ap.add_argument("--all", metavar="OUT", help="lift every VM root (what deob.py --devirt writes) into OUT")
    ap.add_argument("--chunk", action="append", default=[], metavar="FILE",
                    help="original source of a loadstring'd VM chunk (*.chunk_<key>.luau written by deob.py)")
    a = ap.parse_args()
    if a.all:
        text, stats, reqs, bufs = lift_program(a.source, a.protos, a.chunk)
        with open(a.all, "w", encoding="utf-8", newline="\n") as f:
            f.write(finish_text(text) + "\n")
        print("%d functions, %d unlifted blocks, %d unstructured jumps, %d constant requests"
              % (stats["functions"], stats["errors"], stats["fallbacks"], len(reqs)))
        print("missing constants:", LAST_DUMP[0].misses if LAST_DUMP else None)
        return
    prog = Program(a.source, a.protos, a.chunk)
    if a.op:
        show_op(prog, a.op[0], *[int(x) for x in a.op[1].split(":")])
        return
    if a.lift:
        prog.requests = set()
        cap = prog.dump.protos[a.lift]
        vm = prog.vm_of(cap)
        fl = FunctionLifter(prog)
        lines = fl.lift(vm, vm.vmobj_of(cap), vm.proto_of(cap), UpList(), {})
        import codegen
        print("\n".join(lines).replace(codegen.LONG_NL, "\n"))
        print("-- stats %s, %d constant requests" % (fl.stats, len(prog.requests)))
        return
    if a.raw:
        s0, order, lf = prog.lift_raw(a.raw)
        print("-- proto %s entry %s:%s" % (a.raw, s0.mode, s0.pc))
        for k, node in sorted(order, key=lambda kn: kn[0][1]):
            print("[%s:%d d%d]%s" % (k[0], k[1], k[2], " op %s" % (getattr(node, "op", None),) if os.environ.get("DEVIRT_TB") else ""))
            if getattr(node, "error", None):
                print("  !! " + node.error)
            for line in fmt_node(node, "  "):
                print(line)
        print("-- %d constant requests" % len(lf.requests))

REG_PREFIX = "rstuvwxyzabcdefghijklmnopq"
REG_ARRAY = 1000000     

class FunctionLifter:
    """Lifts one proto (and, recursively, the closures it creates) to Luau lines."""

    def __init__(self, prog):
        self.prog = prog
        self.stats = {"functions": 0, "errors": 0, "fallbacks": 0}
        self.lifted = set()
        self.lifted_tids = set()
        self.active = set()     # protos being lifted right now (the real recursion guard)

    def lift(self, vm, vmobj, proto, upvals, upnames, depth=0, shared=None, init_facts=None):
        self.active.add(id(proto))
        try:
            return self._lift(vm, vmobj, proto, upvals, upnames, depth, shared, init_facts)
        finally:
            self.active.discard(id(proto))

    def _lift(self, vm, vmobj, proto, upvals, upnames, depth=0, shared=None, init_facts=None):
        self.stats["functions"] += 1
        self.lifted.add(id(proto))
        if getattr(proto, "tid", None) is not None:
            self.lifted_tids.add(proto.tid)
        prefix = REG_PREFIX[depth % len(REG_PREFIX)]
        cap = self.prog.dump.cap_by_self.get(proto.tid)
        if cap is None and proto.tid is not None:
            # v14.9: the closure op passes the proto as the maker's first arg,
            # so the child's capture holds it under that name (keyed by its
            # fresh upvalue table) -- adopt it when it really is this proto
            st = self.prog.dump.cap_by_state.get(proto.tid)
            if st is not None and vm.maker.get("args"):
                k0 = st.get(vm.maker["args"][0]["name"])
                if isinstance(k0, LTable) and k0.tid == proto.tid:
                    cap = st
        if cap is not None:
            # a captured child proto: its own state tables (W/V/...) beat the
            # parent's vmobj the recursive call would otherwise reuse
            w = vm.vmobj_of(cap)
            if isinstance(w, LTable):
                vmobj = w
        lf = ProtoLifter(vm, self.prog.dump, vmobj, proto, upvals, self.prog.globals,
                         cap=cap, shared=shared if cap is None else None)
        lf.init_facts = init_facts
        lf.reg_prefix = prefix
        st = make_stepper(vm, lf)
        for _ in range(WALK_RESTARTS):
            s0, order, restart = self.prog._walk(vm, lf, st, WALK_LIMIT)
            if not restart:
                break
        self.prog.requests |= lf.requests
        if lf.reg_arrays:
            k0 = s0.key(vm.kstack_link)
            for k, node in order:
                if k == k0:
                    node.stmts[0:0] = [Assign(Reg(REG_ARRAY + b), S.NewTable()) for b in sorted(lf.reg_arrays)]
                    break
        frames = {}
        for c in lf.children:
            if any(isinstance(e, (RegFile, FrameProxy)) for e in c.upvals):
                if id(c.proto) not in frames:
                    frames[id(c.proto)] = self.frame_regs(vm, vmobj, c)
                c.frame_map = frames[id(c.proto)]
                c.frame_regs = sorted({r for i, e in enumerate(c.upvals, 1) if isinstance(e, RegFile)
                                       for r in c.frame_map.get(i, ())})
        me = sys.modules[__name__]
        apply_frame_calls(order)
        drop_idle_closes(order, lf.captured_regs)
        lines, self.params, nerr, fallbacks = backend.lower(
            s0.key(vm.kstack_link), order, me, vm.kstack_link, prefix, upnames,
            lambda x, names: self.closure(vm, vmobj, x, names, depth, lf))
        self.stats["fallbacks"] += fallbacks
        if os.environ.get("DEVIRT_DEBUG"):
            pid = self.prog.dump.pid_of_table.get(proto.tid)
            lines.insert(0, "-- proto %s" % (pid if pid is not None else "t%s" % proto.tid))
        self.stats["errors"] += nerr
        return lines

    def frame_regs(self, vm, vmobj, c, depth=0):
        """{upvalue index: registers} a closure reads or writes through the
        register frames it captured (`s[k] = s`), found by walking it (and
        its own closures that get the frame passed through)."""
        idx = [i for i, e in enumerate(c.upvals, 1) if isinstance(e, (RegFile, FrameProxy))]
        cvm = getattr(c, "vm", None) or vm
        memo = self.__dict__.setdefault("_frame_memo", {})
        mkey = (id(c.proto), id(cvm), tuple(idx))
        if mkey in memo:
            return memo[mkey]
        uses = memo[mkey] = {}
        try:
            cap = self.prog.dump.cap_by_self.get(c.proto.tid)
            if cap is not None:
                w = cvm.vmobj_of(cap)
                if isinstance(w, LTable):
                    vmobj = w
            lf = ProtoLifter(cvm, self.prog.dump, vmobj, c.proto, UpList(idx), self.prog.globals, cap=cap)
            init_facts = dict(getattr(c, "up_facts", None) or {})
            init_facts.update(getattr(c, "arg_facts", None) or {})
            lf.init_facts = init_facts
            lf.walk_only = True
            st = make_stepper(cvm, lf)
            for _ in range(WALK_RESTARTS):
                _, _, restart = self.prog._walk(cvm, lf, st, WALK_LIMIT)
                if not restart:
                    break
        except Unsupported:
            return uses
        for i, r in lf.frame_uses:
            uses.setdefault(i, set()).add(r)
        if depth < 8:
            for g in lf.children:
                if any(isinstance(e, FrameProxy) for e in g.upvals):
                    for gi, regs in self.frame_regs(cvm, vmobj, g, depth + 1).items():
                        e = g.upvals[gi - 1]
                        if isinstance(e, FrameProxy):
                            uses.setdefault(e.idx, set()).update(regs)
        return uses

    def closure(self, vm, vmobj, c, parent_names, depth, parent_lf=None):
        import codegen as CG
        proto = c.proto
        if isinstance(proto, PlainProto):
            capnames = getattr(c, "capnames", {})
            upnames = {}
            for i, e in enumerate(c.upvals, 1):
                if isinstance(e, Reg):
                    upnames[i] = capnames.get(e.n, "r%d" % e.n)
            text = proto.render(capnames, upnames)
            f = CG.FuncE(text.splitlines())
            f.captures = set(upnames.values())
            return f
        # only a proto that is being lifted right now is recursion; one lifted earlier
        # elsewhere (a callback created at several sites) is lifted again here, in place
        if id(proto) in self.active:
            return CG.FuncE(["function(...) --[[ recursive proto ]] end"])
        capnames = getattr(c, "capnames", {})
        upnames = {}
        fmap = getattr(c, "frame_map", {})
        for i, e in enumerate(c.upvals, 1):
            if isinstance(e, RegFile):

                for r in fmap.get(i, ()):
                    upnames[(i, r)] = capnames.get(r, "nil")
            elif isinstance(e, FrameProxy):

                for r in fmap.get(i, ()):
                    upnames[(i, r)] = parent_names.get(("up", (e.idx, r)), "upv%d_%d" % (e.idx, r))
            elif isinstance(e, LTable):
                vals = list(e.h.values())
                ints = [v for v in vals if isinstance(v, int)]
                if any(isinstance(v, RegFile) for v in vals) and ints:
                    upnames[i] = capnames.get(ints[0], "nil")
                else:

                    ups = [v for v in vals if isinstance(v, UpContainer)]
                    upnames[i] = parent_names.get(("up", ups[0].idx), "upv%d" % ups[0].idx) if ups else "nil"
            elif isinstance(e, Reg):
                upnames[i] = capnames.get(e.n, "nil")
            elif isinstance(e, MaybeBox):
                upnames[i] = capnames.get(e.reg, "nil")
            elif isinstance(e, (BoxProxy, Upval)):
                upnames[i] = parent_names.get(("up", e.idx), "upv%d" % e.idx)
            else:
                upnames[i] = "nil"
        params = ["..."]
        fidx = [i for i, e in enumerate(c.upvals, 1) if isinstance(e, (RegFile, FrameProxy))]
        cvm = getattr(c, "vm", None) or vm

        init_facts = dict(getattr(c, "up_facts", None) or {})
        init_facts.update(getattr(c, "arg_facts", None) or {})
        ckey = (id(proto), id(cvm), tuple(fidx), depth, tuple(sorted(upnames.items(), key=repr)), tuple(sorted(init_facts.items(), key=repr)))
        memo = self.__dict__.setdefault("_closure_memo", {})
        if ckey in memo:
            lines, params = memo[ckey]
        elif os.environ.get("DEVIRT_SHALLOW"):
            # memory escape hatch: lift each proto's own instructions only;
            # children become markers that a per-proto --lift run fills in
            # (deep single-process chains OOM the container)
            pid = self.prog.dump.pid_of_table.get(proto.tid)
            tag = "p%s" % pid if pid is not None else "t%s" % proto.tid
            memo[ckey] = (["__DEVIRT_CHILD__(%s)" % tag], ["..."])
            lines, params = memo[ckey]
        else:
            try:
                sh = dict(getattr(c, "shared_cap", None) or {})
                # a child without its own capture (a path the trace never
                # took) still needs the VM's shared values (the state table
                # S, ...): fall back to the parent's by-name captures
                sh.update(getattr(parent_lf, "cap_fallback", {}) or {})
                lines = self.lift(cvm, getattr(c, "state_table", None) or vmobj, proto,
                                  UpList(fidx), upnames, depth + 1,
                                  shared=sh, init_facts=init_facts)
                params = self.params
            except Unsupported as ex:
                lines = ["error(\"devirt: could not lift closure: %s\")" % str(ex).replace("\"", "'")]
                params = ["..."]
            except Exception as ex:
                # one broken function must not abort the whole 1000-function run:
                # mark it explicitly and keep lifting the rest (same convention
                # as the "unexplored successor" markers).
                pid = self.prog.dump.pid_of_table.get(proto.tid)
                print("[!] lifting closure %s failed: %s: %s (stubbed with an error marker)"
                      % ("#%s" % pid if pid is not None else "t%s" % proto.tid,
                         type(ex).__name__, ex), file=sys.stderr)
                if os.environ.get("DEVIRT_TB"):
                    import traceback
                    traceback.print_exc()
                lines = ["error(\"devirt: could not lift closure: %s: %s\")"
                         % (type(ex).__name__, str(ex).replace("\"", "'"))]
                params = ["..."]
            memo[ckey] = (lines, params)
        self.lifted.discard(id(proto))
        # deep proto chains hold every level's lower() frame; collect the
        # cyclic garbage periodically so the peak stays bounded
        gc_counter = self.__dict__.setdefault("_gc_i", 0) + 1
        self._gc_i = gc_counter
        if gc_counter % 32 == 0:
            import gc
            gc.collect()
        f = CG.FuncE(["function(%s)" % ", ".join(params)] + ["\t" + l for l in lines] + ["end"])
        f.captures = set(upnames.values())
        return f

def stmt_exprs(st):
    import codegen as CG
    out = []
    if isinstance(st, CG.AssignS):
        out += [t for t in st.targets]
        out += list(st.values.items)
    elif isinstance(st, (CG.CallS, CG.TempDef)):
        out.append(st.call)
    elif isinstance(st, CG.SetListS):
        out.append(st.tbl)
        out += list(st.values.items)
    return out

def _vm_roots(prog):
    """[(maker tag, [(seq, pid, cap), ...] sorted)] with the payload VM last, and its tag."""
    by_vm = {}
    for key, cap in prog.dump.protos.items():
        if cap.get("__maker") is None:
            continue

        by_vm.setdefault(cap["__maker"], []).append((cap.get("__seq") or 0, key, cap))

    vms = sorted(by_vm.items(), key=lambda kv: min(x[0] for x in kv[1]))
    payload = vms[-1][0] if vms else None
    vms.sort(key=lambda kv: kv[0] == payload)
    for _, lst in vms:
        lst.sort(key=lambda x: (x[0], x[1]))

    # DEVIRT_ROOT_SEQ=<n>: lift the proto created n-th as the script root. A
    # decrypted payload (game-locked v15.1) runs on the SAME VM maker as the
    # anti-tamper loader, so the default "first proto of the last VM" misses it.
    want = os.environ.get("DEVIRT_ROOT_SEQ")
    if want:
        for tag, lst in vms:
            hit = [x for x in lst if str(x[0]) == want]
            if hit:
                lst.remove(hit[0])
                lst.insert(0, hit[0])
                payload = tag
                vms.sort(key=lambda kv: kv[0] == payload)
                return vms, payload

    rc = prog.dump.raw.get("root_callee")
    for tag, lst in vms:
        hit = [x for x in lst if rc is not None and str(x[1]) == str(rc)]
        if hit:
            lst.remove(hit[0])
            lst.insert(0, hit[0])
            payload = tag
            vms.sort(key=lambda kv: kv[0] == payload)
            break
    return vms, payload

def program_roots(prog):
    """[(tag, pid, cap)] of the root protos lift_program lifts, in order."""
    roots = auto_roots(prog) if auto_active() else []
    if roots:
        return [(None, r["key"], r["cap"]) for r in roots]
    vms, payload = _vm_roots(prog)
    loaders = bool(os.environ.get("DEVIRT_LOADERS"))
    return [(tag, lst[0][1], lst[0][2]) for tag, lst in vms if tag == payload or loaders]

def payload_extra_roots(vms, payload):
    """[(seq, pid, cap)] lifted after the root under DEVIRT_ALL_FROM, in order.
    DEVIRT_ALL_VMS: also sibling VM instances the payload spins up.
    DEVIRT_EXTRA_SEQS=47,52: specific closures created before <seq> to lift too
    (e.g. the UI builder of a sibling VM created just before the payload root)."""
    all_from = os.environ.get("DEVIRT_ALL_FROM")
    if not all_from or payload is None:
        return []
    lo = int(all_from)
    all_vms = bool(os.environ.get("DEVIRT_ALL_VMS"))
    extra_seqs = {s.strip() for s in os.environ.get("DEVIRT_EXTRA_SEQS", "").split(",") if s.strip()}
    out = []
    for tag, lst in vms:
        if tag != payload and not all_vms and not extra_seqs:
            continue
        for seq, pid, cap in sorted(lst, key=lambda x: (x[0], str(x[1]))):
            if str(seq) in extra_seqs:
                pass
            elif seq < lo or (tag != payload and not all_vms):
                continue
            out.append((seq, pid, cap))
    return out

def auto_active():
    """Automatic payload roots (the default): off when a root is given by hand."""
    return os.environ.get("DEVIRT_AUTO", "1") != "0" and not os.environ.get("DEVIRT_ROOT_SEQ") \
        and not os.environ.get("DEVIRT_ALL_FROM") and not os.environ.get("DEVIRT_LOADERS")

_BOOT_SEQS = []     # creation numbers of Luraph's bootstrap functions (walked once per file)

def auto_roots(prog):
    """The script's root candidates, found from the dump alone (any v15.1 file):

    * the function created FIRST is Luraph's own bootstrap (the run starts in
      it: anti-tamper, environment checks, decryption); it and everything its
      closure instructions create are not part of the script (one walk, cached
      for the later constant rounds);
    * every other captured function that ran (entered functions get a numeric
      id in the dump, the others a "t" one) is a candidate, in creation order:
      the lift/walk takes them in that order and skips the ones an earlier
      root already reached, so the roots are the functions no other function
      creates -- the main function Luraph's bootstrap deserializes, a payload
      a loader decrypts and runs (game-locked scripts, Coquette-style
      loaders), a separate VM, a loose closure.
    -> [{"seq", "key", "cap"}] in creation order."""
    dump = prog.dump
    caps = []
    for key, cap in dump.protos.items():
        if cap.get("__maker") is None:
            continue
        try:
            vm = prog.vm_of(cap)
            proto = vm.proto_of(cap)
        except Unsupported:
            continue
        if proto is None or getattr(proto, "tid", None) is None:
            continue
        caps.append((cap.get("__seq") or 0, str(key), cap, vm, proto))
    caps.sort(key=lambda x: (x[0], x[1]))
    if len(caps) < 2:
        return []
    boot = set(_BOOT_SEQS)
    if not boot or caps[0][0] not in boot:
        t0 = time.time()
        pkey = {tid: ",".join(str(x) for x in p) for tid, p in dump.paths().items()}
        res = PathResolver(dump)
        seq_of = {c[4].tid: c[0] for c in caps}
        owned = set()
        _, _, cap0, vm0, proto0 = caps[0]
        vmobj = vm0.vmobj_of(cap0)
        # the walk must leave no trace: the bootstrap's constants are not wanted
        # and the runtime functions it meets are not the script's
        saved = (dump.fetcher, dict(dump.shared), dict(dump.misses))
        dump.fetcher = None
        todo = [(vm0, proto0)]
        while todo:
            v, p = todo.pop()
            if p.tid in owned:
                continue
            owned.add(p.tid)
            try:
                ent = _walk_one(prog, v, vmobj, p, pkey)
            except Exception:
                continue
            kids = [res.get(c) if isinstance(c, str) else c for c in ent["children"]]
            kvms = [prog.vms.get(t) or _JIT_TAGGED.get(t) or v for t in ent.get("child_vms") or [None] * len(kids)]
            todo += [(kv, c) for c, kv in zip(kids, kvms)
                     if isinstance(c, LTable) and getattr(c, "tid", None) is not None]
        dump.fetcher = saved[0]
        dump.shared.clear()
        dump.shared.update(saved[1])
        dump.misses.clear()
        dump.misses.update(saved[2])
        boot = {seq_of[t] for t in owned if t in seq_of}
        _BOOT_SEQS[:] = sorted(boot)
        if os.environ.get("DEVIRT_DEBUG") or os.environ.get("DEVIRT_TIMING"):
            sys.stderr.write("[*] Luraph bootstrap: %d functions from #%s (%.1fs)\n"
                             % (len(boot), caps[0][0], time.time() - t0))
    # functions that never ran: Luraph's if created before the script started
    # (the first non-bootstrap function that ran), the script's after it -- a
    # callback nobody fired that no lifted code creates (code3: 18 of them)
    first = next((s for s, k, _, _, _ in caps if s not in boot and not k.startswith("t")), None)
    if first is None:
        return []
    return [{"seq": s, "key": k, "cap": c} for s, k, c, _, _ in caps
            if s not in boot and (s > first or not k.startswith("t"))]

def _lift_auto(prog, fl, roots):
    """auto_roots -> lines: each candidate no earlier root reached is lifted
    as a root; the biggest is the script body, the others (a second payload,
    functions the script made at run time that no lifted code creates) are
    local functions declared before it."""
    blocks = []
    for r in roots:
        cap = r["cap"]
        try:
            vm = prog.vm_of(cap)
            proto = vm.proto_of(cap)
        except Unsupported:
            continue
        if proto is None or id(proto) in fl.lifted or proto.tid in fl.lifted_tids:
            continue
        n0 = fl.stats["functions"]
        try:
            lines = fl.lift(vm, vm.vmobj_of(cap), proto, UpList(), {}, 0)
        except Exception as ex:          # keep going: one bad function must not lose the rest
            blocks.append((r["seq"], 0, ["-- function created %s-th: not lifted: %s" % (r["seq"], ex)], ""))
            continue
        blocks.append((r["seq"], fl.stats["functions"] - n0, lines, ", ".join(fl.params)))
    if not blocks:
        return None
    if os.environ.get("DEVIRT_DEBUG") or os.environ.get("DEVIRT_TIMING"):
        sys.stderr.write("[*] script roots: %s\n" % ", ".join("#%s (%d functions)" % (b[0], b[1]) for b in blocks))
    main = max(blocks, key=lambda b: (b[1], -b[0]))
    out = []
    for b in blocks:
        if b is main:
            continue
        if not b[1]:
            out += [""] + b[2]
            continue
        out.append("")
        out.append("-- function created %s-th by the script at run time" % b[0])
        out.append("local function payload_fn_%s(%s)" % (b[0], b[3]))
        out += ["\t" + l for l in b[2]]
        out.append("end")
    out.append("")
    params = [p.strip() for p in main[3].split(",") if p.strip() and p.strip() != "..."]
    if params:
        out.append("local %s = ..." % ", ".join(params))
    return out + main[2]

def lift_program(source, protos_path, chunk_paths=(), fetch=None):
    """The root proto of every VM -> Luau text (plus stats and constant requests)."""
    prog = Program(source, protos_path, chunk_paths)
    prog.dump.fetcher = fetch
    LAST_DUMP[:] = [prog.dump]
    prog.requests = set()
    fl = FunctionLifter(prog)
    out = []
    vms, payload = _vm_roots(prog)
    payload_pid = None

    roots = auto_roots(prog) if auto_active() else []
    if roots:
        auto_out = _lift_auto(prog, fl, roots)
        if auto_out is not None:
            out = auto_out
            vms = []
    loaders = bool(os.environ.get("DEVIRT_LOADERS"))
    for tag, lst in vms:
        _, pid, cap = lst[0]          
        where = tag.decode("latin-1")
        if tag != payload and not loaders:
            if os.environ.get("DEVIRT_DEBUG"):
                out.append("-- (Luraph loader VM %s, %d protos: not part of the script, not lifted)"
                           % (where, len(lst)))
            continue
        try:
            vm = prog.vm_of(cap)
        except Unsupported as ex:
            out.append("-- VM %s: root proto #%s not lifted: %s" % (where, pid, ex))
            out.append("")
            continue
        proto = vm.proto_of(cap)
        vmobj = vm.vmobj_of(cap)
        role = "the script" if tag == payload else "Luraph loader, not called"
        if loaders or os.environ.get("DEVIRT_DEBUG"):
            out.append("-- VM %s: root proto #%s (%d protos captured; %s)" % (where, pid, len(lst), role))
        if tag == payload:
            payload_pid = pid
        lines = fl.lift(vm, vmobj, proto, UpList(), {}, 0)
        if tag == payload and not loaders:
            out.append("")
            params = [p for p in fl.params if p != "..."]
            if params:
                out.append("local %s = ..." % ", ".join(params))
            out += lines
            payload_pid = None
            continue
        out.append("local function vm_root_%s(%s)" % (pid, ", ".join(fl.params)))
        out += ["\t" + l for l in lines]
        out.append("end")
        out.append("")
    if payload_pid is not None:
        out.append("return vm_root_%s(...)" % payload_pid)

    # DEVIRT_ALL_FROM=<seq>: a decrypted payload starts several independent
    # top-level closures (pcall'd modules, task.spawn bodies) that the root
    # never references as constants. Lift every captured proto of the payload
    # VM created at/after <seq> that no earlier lift reached, as its own block.
    all_from = os.environ.get("DEVIRT_ALL_FROM")
    if all_from and payload is not None:
        extra = 0
        for seq, pid, cap in payload_extra_roots(vms, payload):
                try:
                    vm = prog.vm_of(cap)
                    proto = vm.proto_of(cap)
                except Unsupported:
                    continue
                if proto is None or id(proto) in fl.lifted or \
                        (getattr(proto, "tid", None) is not None and proto.tid in fl.lifted_tids):
                    continue
                vmobj = vm.vmobj_of(cap)
                try:
                    lines = fl.lift(vm, vmobj, proto, UpList(), {}, 0)
                except Exception as ex:          # keep going: one bad proto must not lose the rest
                    out.append("-- payload proto #%s (created %s-th): not lifted: %s" % (pid, seq, ex))
                    out.append("")
                    continue
                extra += 1
                out.append("")
                out.append("-- payload closure created %s-th (proto #%s)" % (seq, pid))
                out.append("local function payload_fn_%s(%s)" % (seq, ", ".join(fl.params)))
                out += ["\t" + l for l in lines]
                out.append("end")
        sys.stderr.write("[*] DEVIRT_ALL_FROM=%s: %d extra top-level payload closures lifted\n" % (all_from, extra))

    shared = []
    for n in sorted(prog.dump.shared.values()):
        shared += ["-- Luraph runtime function (from the VM object, not part of the script: not lifted).",
                   "-- LPH_ENCFUNC decrypts a function this way: (key, encrypted buffer, ...) -> function.",
                   "local function luraph_runtime%d(...)" % n,
                   "\terror(\"Luraph runtime function, not devirtualized\")",
                   "end", ""]
    if shared:
        at = next((i for i, l in enumerate(out) if l and not l.startswith("--")), len(out))
        out[at:at] = shared
    text = backend.polish("\n".join(out))
    return text, fl.stats, prog.requests, buffer_patches(prog.dump)

finish_text = backend.finish_text

LAST_DUMP = []

def buffer_patches(dump):
    """The lifter's in-place string decryption as a request for the runtime:
    "path,to,holder,key/offset:hexbytes/...;..." (only bytes that differ)."""
    return format_patches(*stable_patches(dump))

def stable_patches(dump):
    """dump.buf_patch / tab_patch keyed by table path instead of object id
    (table ids differ between runs): ({(holder path, offset): byte},
    {(table path, key): number}), only values that differ from the dump."""
    paths = dump.paths()
    bw = {}
    for (bid, off), v in dump.buf_patch.items():
        buf, tid, key = dump.buf_loc[bid]
        if not isinstance(v, int) or buf.data[off] == v or tid not in paths:
            continue
        bw[(",".join(str(x) for x in paths[tid]), key, off)] = v
    tw = {}
    for (tid, key), v in dump.tab_patch.items():
        base = dump.tables[tid].h.get(key)
        if tid in paths and not (isinstance(base, (int, float)) and base == v):
            tw[(",".join(str(x) for x in paths[tid]), key)] = v
    return bw, tw

def format_patches(bw, tw):
    per = {}
    for (path, key, off), v in bw.items():
        per.setdefault("%s,%s" % (path, key), {})[off] = v
    out = []
    for holder, bs in per.items():
        runs = []
        for off in sorted(bs):
            if runs and runs[-1][0] + len(runs[-1][1]) == off:
                runs[-1][1].append(bs[off])
            else:
                runs.append((off, [bs[off]]))
        out.append(holder + "".join("/%d:%s" % (off, bytes(b).hex()) for off, b in runs))
    out.sort()      

    tabs = {}
    for (path, key), v in tw.items():
        tabs.setdefault(path, []).append((key, v))
    tab_out = [path + "".join("/=%d:%s" % (k, S.fmt_num(v)) for k, v in sorted(kv))
               for path, kv in tabs.items()]
    return ";".join(out + sorted(tab_out))

def same_patches(old, new):
    """Whether `old` (the patches of an earlier round, paths of that run's
    dump) are the patches `new` of the last lift (LAST_DUMP). The shortest
    path to a table changes between runs on ties, so the old paths are
    resolved in the new dump and written with its paths first."""
    if old == new:
        return True
    if not LAST_DUMP:
        return False
    dump = LAST_DUMP[0]
    res = PathResolver(dump)
    pkey = {tid: ",".join(str(x) for x in p) for tid, p in dump.paths().items()}

    def cur(path):
        t = res.get(path)
        return pkey.get(t.tid, path) if t is not None else path
    out, tabs = [], []
    for spec in old.split(";") if old else []:
        head, sep, rest = spec.partition("/")
        if rest.startswith("="):
            tabs.append(cur(head) + sep + rest)
        else:
            path, _, key = head.rpartition(",")
            out.append("%s,%s" % (cur(path), key) + sep + rest)
    return ";".join(sorted(out) + sorted(tabs)) == new

class WalkCache:
    """Results of walking single protos (collect_requests), kept across
    constant rounds by the proto's table path. A walk that asked for no
    constant (and missed none) sees the same data next round, so it is not
    repeated. Table ids differ between runs and so can the shortest path to a
    table (ties), so stored paths are resolved by walking them (PathResolver)."""

    def __init__(self):
        self.entries = {}       

class PathResolver:
    """A table path as written by Dump.paths() ("seq,name,key,..." with
    "slot@value" steps) -> the table it names in this dump, or None."""

    def __init__(self, dump):
        self.dump = dump
        self.caps = {}
        for cap in dump.protos.values():
            if cap.get("__seq") is not None:
                self.caps[str(cap["__seq"])] = cap
        self.memo = {}

    def get(self, path):
        if path in self.memo:
            return self.memo[path]
        t = self.dump.overrides.get(path)
        if not isinstance(t, LTable):
            parts = path.split(",")
            t = None
            if len(parts) == 2:
                cap = self.caps.get(parts[0])
                t = cap.get(parts[1]) if cap is not None else None
            elif len(parts) > 2 and "@" not in parts[-1]:
                parent = self.get(",".join(parts[:-1]))
                try:
                    k = int(parts[-1])
                except ValueError:
                    k = None
                if isinstance(parent, LTable) and k is not None:
                    t = parent.h.get(k)
            if not isinstance(t, LTable):
                t = None
        self.memo[path] = t
        return t

def collect_requests(source, protos_path, chunk_paths=(), cache=None, fetch=None):
    """What an intermediate constant round needs from lift_program, without
    the structuring/codegen/naming: every proto lift_program would lift is
    walked (SCCP, which is where requests and in-place decryption happen),
    its closures followed. -> (stats, requests, buffer patches)."""
    prog = Program(source, protos_path, chunk_paths)
    LAST_DUMP[:] = [prog.dump]
    dump = prog.dump
    if cache is None:
        cache = WalkCache()
    paths = dump.paths()
    pkey = {tid: ",".join(str(x) for x in p) for tid, p in paths.items()}
    res = PathResolver(dump)
    live = {}
    for (path, vmid), ent in cache.entries.items():
        t = res.get(path)
        if t is not None:
            live[(t.tid, vmid)] = (path, ent)
    kept = {}
    stats = {"functions": 0, "errors": 0, "fallbacks": 0, "walked": 0}
    requests = set()
    bw, tw = PatchLog(), PatchLog()
    dump.fetcher = fetch
    dump.extra_patches = (bw, tw)
    todo = []
    # the DEVIRT_ALL_FROM closures lift_program adds after the root: walked
    # last (bottom of the stack), so the root and its closures go first as there
    vms, payload = _vm_roots(prog)
    for seq, pid, cap in reversed(payload_extra_roots(vms, payload)):
        try:
            vm = prog.vm_of(cap)
            proto = vm.proto_of(cap)
        except Unsupported:
            continue
        if proto is not None:
            todo.append((vm, vm.vmobj_of(cap), proto))
    for tag, pid, cap in reversed(program_roots(prog)):
        try:
            vm = prog.vm_of(cap)
        except Unsupported:
            continue
        todo.append((vm, vm.vmobj_of(cap), vm.proto_of(cap)))
    seen = set()
    while todo:
        vm, vmobj, proto = todo.pop()
        if id(proto) in seen:
            continue
        seen.add(id(proto))
        found = live.get((proto.tid, id(vm)))
        use = found and _translate(found[1], res, pkey)
        if use:
            kept[(found[0], id(vm))] = found[1]
            ent = found[1]
            kids, ebw, etw = use
        else:
            ent = _walk_one(prog, vm, vmobj, proto, pkey)
            stats["walked"] += 1
            key = pkey.get(proto.tid)
            if key is not None and ent["clean"]:
                kept[(key, id(vm))] = ent
            kids = [res.get(c) if isinstance(c, str) else c for c in ent["children"]]
            ebw, etw = ent["bw"], ent["tw"]
        stats["functions"] += 1
        stats["errors"] += ent["errors"]
        requests |= ent["requests"]
        bw.update(ebw)
        tw.update(etw)
        kvms = [prog.vms.get(t) or _JIT_TAGGED.get(t) or vm for t in ent.get("child_vms") or [None] * len(kids)]
        todo += [(kvm, vmobj, c) for c, kvm in reversed(list(zip(kids, kvms))) if c is not None]
    cache.entries = kept
    stats["fetched"] = len(dump.fetched)
    if os.environ.get("DEVIRT_TIMING") and dump.fetched:
        print("[*]   live requests: %d, patches %.1fs, round trips %.1fs (harness %.1fs), %d KB of patches sent"
              % ((len(dump.fetched),) + tuple(dump.fetch_time[:3]) + (dump.fetch_time[3] // 1024,)),
              file=sys.stderr)
    prog.requests = requests
    return stats, requests, format_patches(bw, tw)

def _walk_one(prog, vm, vmobj, proto, pkey):
    dump = prog.dump
    saved = dump.buf_patch, dump.tab_patch
    dump.buf_patch, dump.tab_patch = PatchLog(), PatchLog()
    nmiss = sum(dump.misses.values())
    ent = {"requests": set(), "children": [], "errors": 0, "clean": False, "bw": {}, "tw": {}}
    try:
        lf = ProtoLifter(vm, dump, vmobj, proto, UpList(), prog.globals,
                         cap=dump.cap_by_self.get(proto.tid))
        lf.walk_only = True
        st = make_stepper(vm, lf)
        for _ in range(WALK_RESTARTS):
            s0, order, restart = prog._walk(vm, lf, st, WALK_LIMIT)
            if not restart:
                break
    except Unsupported:
        ent["errors"] = 1
        return ent
    finally:
        ent["bw"], ent["tw"] = stable_patches(dump)
        dump.buf_patch, dump.tab_patch = saved
    ent["requests"] = lf.requests
    ent["errors"] = sum(1 for _, n in order if getattr(n, "error", None))
    if os.environ.get("DEVIRT_ERRS"):
        for s, n in order:
            if getattr(n, "error", None):
                print("[walk] %s %s %s" % (pkey.get(proto.tid, proto.tid), s[:2], n.error),
                      file=sys.stderr)
    kids = [c for c in lf.children if isinstance(c.proto, LTable)]
    ent["children"] = [pkey.get(c.proto.tid, c.proto) for c in kids]
    ent["child_vms"] = [getattr(getattr(c, "vm", None), "tag", None) for c in kids]
    ent["clean"] = not lf.requests and sum(dump.misses.values()) == nmiss and \
        all(isinstance(c, str) for c in ent["children"])
    return ent

def _translate(ent, res, pkey):
    """A cached entry's paths -> this dump: (child tables, buffer patches,
    table patches), patches keyed by the current shortest path (the one the
    runtime looks up); None if a path no longer resolves."""
    kids = []
    for c in ent["children"]:
        t = res.get(c)
        if t is None:
            return None
        kids.append(t)
    out = []
    for d in (ent["bw"], ent["tw"]):
        nd = {}
        for k, v in d.items():
            t = res.get(k[0])
            if t is None or t.tid not in pkey:
                return None
            nd[(pkey[t.tid],) + k[1:]] = v
        out.append(nd)
    return kids, out[0], out[1]

run_big_stack = backend.run_big_stack

if __name__ == "__main__":
    run_big_stack(main)
