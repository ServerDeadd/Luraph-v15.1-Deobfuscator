import math
import struct
import unicodedata

class Unsupported(Exception):
    pass

class LTable:
    __slots__ = ("h", "tid", "meta")

    def __init__(self, h=None, tid=None):
        self.h = h if h is not None else {}
        self.tid = tid
        self.meta = None

    def get(self, k):
        return self.h.get(norm_key(k))

    def set(self, k, v):
        k = norm_key(k)
        if v is None:
            self.h.pop(k, None)
        else:
            self.h[k] = v

    def length(self):
        n = 0
        while (n + 1) in self.h:
            n += 1
        return n

    def __repr__(self):
        return "LTable#%s" % (self.tid if self.tid is not None else id(self))

class Buf:
    __slots__ = ("data",)

    def __init__(self, data):
        self.data = bytearray(data)

class Builtin:
    __slots__ = ("name", "fn")

    def __init__(self, name, fn=None):
        self.name = name
        self.fn = fn

    def __repr__(self):
        return "Builtin(%s)" % self.name

class LuaFunc:
    """A Lua function from the source AST (VM helpers such as e:G3)."""
    __slots__ = ("node", "env")

    def __init__(self, node, env):
        self.node = node
        self.env = env

def norm_key(k):
    if type(k) is int or type(k) is bytes:
        return k
    # isfinite must come first: int(float("inf")) raises OverflowError and
    # int(float("nan")) raises ValueError, and inf/nan are legal Lua keys.
    if isinstance(k, float) and math.isfinite(k) and k == int(k):
        return int(k)
    if isinstance(k, Expr):
        raise Unsupported("symbolic table key on a concrete table: %r" % (k,))
    return k

class Expr:
    """Symbolic value. Subclasses are plain data; `pure` means evaluation has
    no side effects (calls are always materialized into temps)."""
    pure = True

    def __repr__(self):
        return "<%s %s>" % (type(self).__name__, self.__dict__)

class Const(Expr):
    def __init__(self, v):
        self.v = v

class Reg(Expr):
    def __init__(self, n):
        self.n = n

    def __eq__(self, o):
        return isinstance(o, Reg) and o.n == self.n

    def __hash__(self):
        return hash(("reg", self.n))

class Pseudo(Expr):
    """Hidden VM state (numeric/generic for-loop variables), per loop depth."""

    def __init__(self, name, depth):
        self.name, self.depth = name, depth

    def __eq__(self, o):
        return isinstance(o, Pseudo) and (o.name, o.depth) == (self.name, self.depth)

    def __hash__(self):
        return hash(("pseudo", self.name, self.depth))

class Global(Expr):
    def __init__(self, name):
        self.name = name

class Upval(Expr):
    def __init__(self, idx):
        self.idx = idx

    def __eq__(self, o):
        return isinstance(o, Upval) and o.idx == self.idx

    def __hash__(self):
        return hash(("upv", self.idx))

class Index(Expr):
    def __init__(self, obj, key):
        self.obj, self.key = obj, key

class Bin(Expr):
    def __init__(self, op, a, b):
        self.op, self.a, self.b = op, a, b

class Un(Expr):
    def __init__(self, op, a):
        self.op, self.a = op, a

class IfExp(Expr):
    def __init__(self, c, a, b):
        self.c, self.a, self.b = c, a, b

class TempVal(Expr):
    """i-th value (1-based) of a materialized call."""

    def __init__(self, t, i):
        self.t, self.i = t, i

    def __eq__(self, o):
        return isinstance(o, TempVal) and (o.t, o.i) == (self.t, self.i)

    def __hash__(self):
        return hash(("tv", self.t, self.i))

class Vararg(Expr):
    """i-th value of the function's varargs (1-based)."""

    def __init__(self, i):
        self.i = i

class NewTable(Expr):
    def __init__(self, items=None):
        self.items = items or []   

class ClosureExpr(Expr):
    def __init__(self, proto, upvals):
        self.proto, self.upvals = proto, upvals

class Multi:
    """Values of a call / vararg expression: fixed prefix + optional tail."""

    def __init__(self, items, tail=None):
        self.items, self.tail = list(items), tail

    def first(self):
        if self.items:
            return self.items[0]
        if self.tail is not None:
            return self.tail.at(1)
        return None

class TempTail:
    def __init__(self, t, start=1):
        self.t, self.start = t, start

    def at(self, i):
        return TempVal(self.t, self.start + i - 1)

    def drop(self, k):
        return TempTail(self.t, self.start + k)

class VarargTail:
    def __init__(self, start=1):
        self.start = start

    def at(self, i):
        return Vararg(self.start + i - 1)

    def drop(self, k):
        return VarargTail(self.start + k)

class SymList:
    """A table built by table.pack / {...} whose length may be symbolic:
    positions 1..len(items) are known, then `tail` (a Multi tail) follows
    starting at position len(items)+1 + shift. `n` field reads give Len."""

    def __init__(self, items, tail=None, nkey=None):
        self.items = list(items)
        self.tail = tail
        self.nkey = nkey
        self.extra = {}

    def count_expr(self):
        if self.tail is None:
            return len(self.items)
        return Bin("Add", TailCount(self.tail), len(self.items)) if self.items else TailCount(self.tail)

class TailCount(Expr):
    def __init__(self, tail):
        self.tail = tail

class RegFile:
    """The VM register array: z[n] reads Reg(n), writes emit assignments."""

class EnvTable:
    """getfenv() of the script: indexing gives globals."""

class UpContainer:
    """Stand-in for the table an upvalue box points into (box[4] in Luraph's
    {[4]=registers,[7]=index} boxes): any index of it is the upvalue."""

    def __init__(self, idx):
        self.idx = idx

class BreakSig(Exception):
    pass

class ContinueSig(Exception):
    pass

class ReturnSig(Exception):
    def __init__(self, values):
        self.values = values

class YieldSig(Exception):
    """Reached a dispatch loop (instruction boundary)."""

    def __init__(self, node):
        self.node = node

def truthy(v):
    return not (v is None or v is False)

def is_sym(v):
    return isinstance(v, Expr)

def lua_num(v):
    if isinstance(v, bool) or v is None:
        return None
    if isinstance(v, (int, float)):
        return v
    if isinstance(v, bytes):
        try:
            s = v.decode("latin-1").strip()
            return int(s, 0) if s.lower().startswith(("0x", "-0x")) else float(s)
        except ValueError:
            return None
    return None

def fix_int(x):
    if isinstance(x, float) and x.is_integer() and abs(x) < 2 ** 63:
        return int(x)
    return x

def _pow(a, b):
    """C pow() semantics (what Luau's ^ uses). Python's ** differs exactly
    where it matters here: 0^-n raises ZeroDivisionError instead of giving
    inf, a negative base with a fractional exponent returns complex instead
    of nan, and overflow raises OverflowError instead of saturating to inf."""
    if a == 0 and b < 0:
        # pow(+-0, -odd) = -+inf, pow(+-0, -even or -fractional) = +inf
        if math.copysign(1.0, a) < 0 and b % 2 == 1:
            return float("-inf")
        return float("inf")
    if a < 0 and math.isfinite(b) and b != math.floor(b):
        # math.floor would raise OverflowError on +-inf (legal Lua exponents)
        return float("nan")
    try:
        r = float(a) ** float(b)
    except OverflowError:
        # only reachable with an integral b (fractional negative base returned
        # nan above): sign follows the parity of the exponent
        return float("-inf") if (a < 0 and b % 2 == 1) else float("inf")
    except ZeroDivisionError:  # defensive; a == 0 handled above
        return float("inf")
    if isinstance(r, complex):  # defensive; should be unreachable
        return float("nan")
    return r

def arith(op, a, b):
    if op == "Add":
        return fix_int(a + b)
    if op == "Sub":
        return fix_int(a - b)
    if op == "Mul":
        return fix_int(a * b)
    if op == "Div":
        if b == 0:
            if a == 0:
                return float("nan")
            return math.copysign(float("inf"), a) * (1 if not (isinstance(b, float) and math.copysign(1, b) < 0) else -1)
        return fix_int(a / b)
    if op == "FloorDiv":
        if b == 0:
            return arith("Div", a, b)
        return fix_int(math.floor(a / b)) if isinstance(a, float) or isinstance(b, float) else a // b
    if op == "Mod":
        if b == 0:
            return float("nan")
        if isinstance(a, int) and isinstance(b, int):
            return a % b
        r = math.fmod(a, b)
        if r != 0 and (r < 0) != (b < 0):
            r += b
        return fix_int(r)
    if op == "Pow":
        return fix_int(_pow(float(a), float(b)))
    raise Unsupported(op)

def u32(x):
    return int(x) & 0xFFFFFFFF

def _bit(name):
    def band(*a):
        r = 0xFFFFFFFF
        for x in a:
            r &= u32(x)
        return r

    def bor(*a):
        r = 0
        for x in a:
            r |= u32(x)
        return r

    def bxor(*a):
        r = 0
        for x in a:
            r ^= u32(x)
        return r

    def lshift(x, n):
        n = int(n)
        return 0 if abs(n) >= 32 else (u32(x) << n) & 0xFFFFFFFF if n >= 0 else u32(x) >> -n

    def rshift(x, n):
        n = int(n)
        return 0 if abs(n) >= 32 else u32(x) >> n if n >= 0 else (u32(x) << -n) & 0xFFFFFFFF

    def arshift(x, n):
        x, n = u32(x), int(n)
        if x & 0x80000000:
            x -= 1 << 32
        return u32(x >> min(n, 31)) if n >= 0 else lshift(x, -n)

    def lrotate(x, n):
        x, n = u32(x), int(n) % 32
        return ((x << n) | (x >> (32 - n))) & 0xFFFFFFFF

    def rrotate(x, n):
        return lrotate(x, -int(n))

    def bnot(x):
        return (~u32(x)) & 0xFFFFFFFF

    def extract(x, f, w=1):
        return (u32(x) >> int(f)) & ((1 << int(w)) - 1)

    def replace(x, v, f, w=1):
        m = ((1 << int(w)) - 1) << int(f)
        return (u32(x) & ~m | ((u32(v) << int(f)) & m)) & 0xFFFFFFFF

    def btest(*a):
        return band(*a) != 0

    def countlz(x):
        x = u32(x)
        return 32 - x.bit_length()

    def countrz(x):
        x = u32(x)
        return 32 if x == 0 else (x & -x).bit_length() - 1

    return locals()[name]

BIT32 = ["band", "bor", "bxor", "bnot", "lshift", "rshift", "arshift", "lrotate", "rrotate",
         "extract", "replace", "btest", "countlz", "countrz"]

def _buf_fns():
    fmt = {"i8": "<b", "u8": "<B", "i16": "<h", "u16": "<H", "i32": "<i", "u32": "<I", "f32": "<f", "f64": "<d"}
    out = {}
    for k, f in fmt.items():
        size = struct.calcsize(f)

        def rd(b, off, f=f, size=size):
            return fix_int(struct.unpack_from(f, b.data, int(off))[0])

        def wr(b, off, v, f=f, k=k):
            if k.startswith(("u", "i")):
                bits = struct.calcsize(f) * 8
                v = int(v) & ((1 << bits) - 1)
                if k.startswith("i") and v >= 1 << (bits - 1):
                    v -= 1 << bits
            struct.pack_into(f, b.data, int(off), v)
        out["buffer.read" + k] = rd
        out["buffer.write" + k] = wr
    out["buffer.len"] = lambda b: len(b.data)
    out["buffer.tostring"] = lambda b: bytes(b.data)
    out["buffer.fromstring"] = lambda s: Buf(s)
    out["buffer.create"] = lambda n: Buf(bytes(int(n)))
    out["buffer.readstring"] = lambda b, o, n: bytes(b.data[int(o):int(o) + int(n)])
    return out

def _str_byte(s, i=1, j=None):
    n = len(s)
    i = int(i)
    j = i if j is None else int(j)
    if i < 0:
        i += n + 1
    if j < 0:
        j += n + 1
    i = max(i, 1)
    j = min(j, n)
    return Multi(list(s[i - 1:j]))

def _str_sub(s, i=1, j=-1):
    n = len(s)
    i, j = int(i), int(j)
    if i < 0:
        i = max(n + i + 1, 1)
    elif i == 0:
        i = 1
    if j < 0:
        j = n + j + 1
    elif j > n:
        j = n
    return s[i - 1:j] if i <= j else b""

CONCRETE = {"string.byte": _str_byte, "string.sub": _str_sub, "string.len": lambda s: len(s),
            "string.char": lambda *a: bytes(int(x) for x in a),
            "string.rep": lambda s, n, sep=b"": sep.join([s] * int(n)),
            "utf8.nfdnormalize": lambda s: unicodedata.normalize("NFD", s.decode("utf-8")).encode("utf-8"),
            "utf8.nfcnormalize": lambda s: unicodedata.normalize("NFC", s.decode("utf-8")).encode("utf-8"),
            "math.floor": lambda x: fix_int(math.floor(x)), "math.ceil": lambda x: fix_int(math.ceil(x)),
            "math.abs": lambda x: abs(x), "math.max": lambda *a: max(a), "math.min": lambda *a: min(a),
            "tonumber": lambda x, b=None: lua_num(x) if b is None else int(x.decode(), int(b))}
for _n in BIT32:
    CONCRETE["bit32." + _n] = _bit(_n)
CONCRETE.update(_buf_fns())

def _f32(x):
    return struct.unpack("<f", struct.pack("<f", float(x)))[0]

def _i32_round(x):
    xf = float(x)
    return int(math.floor(xf + 0.5)) if xf >= 0 else int(math.ceil(xf - 0.5))

def _udim_new(s=0, o=0):
    return {b"__type": "UDim", b"Scale": fix_int(_f32(s)), b"Offset": _i32_round(o)}

def _udim2_new(a=0, b=0, c=0, d=0):
    if isinstance(a, dict) and a.get(b"__type") == "UDim":
        ux = a
        uy = b if (isinstance(b, dict) and b.get(b"__type") == "UDim") else _udim_new(0, 0)
    else:
        ux = _udim_new(a, b)
        uy = _udim_new(c, d)
    return {b"__type": "UDim2", b"X": ux, b"Y": uy, b"Width": ux, b"Height": uy}

def _udim2_fromScale(xs=0, ys=0):
    return _udim2_new(xs, 0, ys, 0)

def _udim2_fromOffset(xo=0, yo=0):
    return _udim2_new(0, xo, 0, yo)

def _vec2_new(x=0, y=0):
    fx, fy = fix_int(_f32(x)), fix_int(_f32(y))
    mag = fix_int(math.hypot(fx, fy))
    return {b"__type": "Vector2", b"X": fx, b"Y": fy, b"x": fx, b"y": fy, b"Magnitude": mag}

def _p2d_cp_new(pos=None, left=None, right=None):
    z = _udim2_new(0, 0, 0, 0)
    return {
        b"__type": "Path2DControlPoint",
        b"Position": pos if isinstance(pos, dict) else z,
        b"LeftTangent": left if isinstance(left, dict) else z,
        b"RightTangent": right if isinstance(right, dict) else z,
    }

def _instance_new(cls, parent=None):
    z = _udim2_new(0, 0, 0, 0)
    return {b"__type": "Instance", b"ClassName": cls, b"Parent": parent, b"Size": z, b"Position": z, b"_pts": ()}

def _p2d_resolve(u, W, H):
    ux, uy = u[b"X"], u[b"Y"]
    return _f32(_f32(ux[b"Scale"] * W) + ux[b"Offset"]), _f32(_f32(uy[b"Scale"] * H) + uy[b"Offset"])

def _p2d_coeffs(s):
    n = len(s) // 2
    x0, y0 = s[0], s[1]
    c = {"n": n, "x0": x0, "y0": y0}
    if n == 2:
        c["c1x"], c["c1y"] = _f32(s[2] - x0), _f32(s[3] - y0)
    elif n == 3:
        x1, y1, x2, y2 = s[2], s[3], s[4], s[5]
        c["c1x"], c["c1y"] = _f32(_f32(x1 - x0) * 2), _f32(_f32(y1 - y0) * 2)
        c["c2x"], c["c2y"] = _f32(_f32(x0 - _f32(x1 * 2)) + x2), _f32(_f32(y0 - _f32(y1 * 2)) + y2)
    else:
        x1, y1, x2, y2, x3, y3 = s[2], s[3], s[4], s[5], s[6], s[7]
        c["c1x"], c["c1y"] = _f32(_f32(x1 - x0) * 3), _f32(_f32(y1 - y0) * 3)
        c["c2x"] = _f32(_f32(_f32(x0 - _f32(x1 * 2)) + x2) * 3)
        c["c2y"] = _f32(_f32(_f32(y0 - _f32(y1 * 2)) + y2) * 3)
        c["c3x"] = _f32(_f32(_f32(x3 - x0) + _f32(x1 * 3)) - _f32(x2 * 3))
        c["c3y"] = _f32(_f32(_f32(y3 - y0) + _f32(y1 * 3)) - _f32(y2 * 3))
    return c

def _p2d_eval(c, u):
    if c["n"] == 2:
        return _f32(c["x0"] + _f32(c["c1x"] * u)), _f32(c["y0"] + _f32(c["c1y"] * u))
    if c["n"] == 3:
        return (
            _f32(c["x0"] + _f32(_f32(c["c1x"] + _f32(c["c2x"] * u)) * u)),
            _f32(c["y0"] + _f32(_f32(c["c1y"] + _f32(c["c2y"] * u)) * u)),
        )
    ix, iy = _f32(c["c2x"] + _f32(c["c3x"] * u)), _f32(c["c2y"] + _f32(c["c3y"] * u))
    return (
        _f32(c["x0"] + _f32(_f32(c["c1x"] + _f32(ix * u)) * u)),
        _f32(c["y0"] + _f32(_f32(c["c1y"] + _f32(iy * u)) * u)),
    )

def _p2d_tangent(c, u):
    if c["n"] == 2:
        return c["c1x"], c["c1y"]
    if c["n"] == 3:
        k = _f32(u * 2)
        return _f32(c["c1x"] + _f32(c["c2x"] * k)), _f32(c["c1y"] + _f32(c["c2y"] * k))
    k = _f32(3 * u)
    return (
        _f32(c["c1x"] + _f32(u * _f32(_f32(c["c2x"] * 2) + _f32(c["c3x"] * k)))),
        _f32(c["c1y"] + _f32(u * _f32(_f32(c["c2y"] * 2) + _f32(c["c3y"] * k)))),
    )

def _p2d_dist(ax, ay, bx, by):
    dx, dy = _f32(bx - ax), _f32(by - ay)
    return _f32(math.sqrt(_f32(_f32(dx * dx) + _f32(dy * dy))))

def _p2d_eval0(c, u):
    if c["n"] == 2:
        return _f32(c["c1x"] * u), _f32(c["c1y"] * u)
    if c["n"] == 3:
        return _f32(_f32(c["c1x"] + _f32(c["c2x"] * u)) * u), _f32(_f32(c["c1y"] + _f32(c["c2y"] * u)) * u)
    ix, iy = _f32(c["c2x"] + _f32(c["c3x"] * u)), _f32(c["c2y"] + _f32(c["c3y"] * u))
    return _f32(_f32(c["c1x"] + _f32(ix * u)) * u), _f32(_f32(c["c1y"] + _f32(iy * u)) * u)

_P2D_TOL = _f32(1e-5)
_P2D_SIXTH = _f32(1.0 / 6.0)

def _p2d_seglen(c):
    def rec(t0, t1, x0, y0, x1, y1, depth):
        tm = _f32(_f32(t0 + t1) * 0.5)
        xm, ym = _p2d_eval0(c, tm)
        a = _p2d_dist(x0, y0, x1, y1)
        b = _f32(_p2d_dist(x0, y0, xm, ym) + _p2d_dist(xm, ym, x1, y1))
        if depth >= 30 or _f32(b - a) < _P2D_TOL:
            return b
        return _f32(rec(t0, tm, x0, y0, xm, ym, depth + 1) + rec(tm, t1, xm, ym, x1, y1, depth + 1))
    x0, y0 = _p2d_eval0(c, 0)
    x1, y1 = _p2d_eval0(c, 1)
    return rec(0, 1, x0, y0, x1, y1, 0)

def _p2d_arcU(c, s):
    d2x, d2y = _f32(c["c2x"] * 2), _f32(c["c2y"] * 2)
    d3x, d3y = (_f32(c["c3x"] * 3), _f32(c["c3y"] * 3)) if c["n"] == 4 else (0, 0)
    def inv(u):
        if c["n"] == 3:
            dx, dy = _f32(c["c1x"] + _f32(d2x * u)), _f32(c["c1y"] + _f32(d2y * u))
        else:
            dx = _f32(c["c1x"] + _f32(u * _f32(d2x + _f32(u * d3x))))
            dy = _f32(c["c1y"] + _f32(u * _f32(d2y + _f32(u * d3y))))
        return math.sqrt(_f32(_f32(dx * dx) + _f32(dy * dy)))
    h = _f32(s / 32)
    u = 0
    for _ in range(32):
        k1 = _f32(h / _f32(inv(u)))
        k2 = _f32(h / _f32(inv(_f32(u + _f32(k1 * 0.5)))))
        k3 = _f32(h / _f32(inv(_f32(u + _f32(k2 * 0.5)))))
        k4 = _f32(h / _f32(inv(_f32(u + k3))))
        u = _f32(u + _f32(_f32(_f32(k1 + _f32(2 * _f32(k2 + k3))) + k4) * _P2D_SIXTH))
    return u

def _p2d_segments(p2d):
    if not isinstance(p2d, dict):
        return None
    parent = p2d.get(b"Parent")
    sz = parent.get(b"Size") if isinstance(parent, dict) else None
    if not isinstance(sz, dict):
        return None
    ux, uy = sz[b"X"], sz[b"Y"]
    if ux[b"Scale"] != 0 or uy[b"Scale"] != 0:
        return None
    W, H = ux[b"Offset"], uy[b"Offset"]
    raw_pts = p2d.get(b"_pts")
    if isinstance(raw_pts, dict):
        cps = []
        i = 1
        while i in raw_pts:
            cps.append(raw_pts[i])
            i += 1
    elif isinstance(raw_pts, (list, tuple)):
        cps = list(raw_pts)
    else:
        return None
    if len(cps) < 2:
        return None
    pts = []
    for cp in cps:
        if not isinstance(cp, dict) or cp.get(b"__type") != "Path2DControlPoint":
            return None
        px, py = _p2d_resolve(cp[b"Position"], W, H)
        lx, ly = _p2d_resolve(cp[b"LeftTangent"], W, H)
        rx, ry = _p2d_resolve(cp[b"RightTangent"], W, H)
        pts.append((px, py, lx, ly, rx, ry))
    segs = []
    for i in range(len(pts) - 1):
        a, b = pts[i], pts[i + 1]
        s = [a[0], a[1]]
        if a[4] != 0 or a[5] != 0:
            s.extend([_f32(a[0] + a[4]), _f32(a[1] + a[5])])
        if b[2] != 0 or b[3] != 0:
            s.extend([_f32(b[0] + b[2]), _f32(b[1] + b[3])])
        s.extend([b[0], b[1]])
        c = _p2d_coeffs(s)
        c["len"] = _p2d_seglen(c)
        segs.append(c)
    return segs, W, H

def _p2d_length(p2d):
    res = _p2d_segments(p2d)
    if not res:
        raise ValueError("Path2D not ready")
    segs, _, _ = res
    t = 0
    for c in segs:
        t = _f32(t + c["len"])
    return fix_int(t)

def _p2d_locate(segs, t):
    t = _f32(t)
    t = 0 if t < 0 else (1 if t > 1 else t)
    n = len(segs)
    x = _f32(t * n)
    k = min(int(math.floor(x)), n - 1)
    return segs[k], _f32(x - k)

def _p2d_locate_arc(segs, t):
    t = _f32(t)
    t = 0 if t < 0 else (1 if t > 1 else t)
    L = 0
    for c in segs:
        L = _f32(L + c["len"])
    s = _f32(t * L)
    for c in segs:
        if s <= c["len"]:
            if c["n"] == 2:
                return c, _f32(s / c["len"])
            return c, _p2d_arcU(c, s)
        s = _f32(s - c["len"])
    return segs[0], 0

def _p2d_pos(p2d, t, arc=False):
    res = _p2d_segments(p2d)
    if not res:
        raise ValueError("Path2D not ready")
    segs, W, H = res
    c, u = _p2d_locate_arc(segs, t) if arc else _p2d_locate(segs, t)
    x, y = _p2d_eval(c, u)
    return _udim2_new(_f32(x / W), 0, _f32(y / H), 0)

def _p2d_tan(p2d, t, arc=False):
    res = _p2d_segments(p2d)
    if not res:
        raise ValueError("Path2D not ready")
    segs, _, _ = res
    c, u = _p2d_locate_arc(segs, t) if arc else _p2d_locate(segs, t)
    x, y = _p2d_tangent(c, u)
    return _vec2_new(x, y)

def _pcg_word(st):
    old = st
    st = (st * 6364136223846793005 + 105) & 0xFFFFFFFFFFFFFFFF
    xorshifted = (((old >> 18) ^ old) >> 27) & 0xFFFFFFFF
    rot = (old >> 59) & 31
    w = ((xorshifted >> rot) | (xorshifted << ((-rot) & 31))) & 0xFFFFFFFF
    return st, w

def _random_new(seed=0):
    if seed != seed:
        v = 0x8000000000000000
    elif isinstance(seed, (int, float)) and -9007199254740992 < seed < 9007199254740992:
        v = int(math.floor(float(seed))) & 0xFFFFFFFFFFFFFFFF
    else:
        v = 0
    st = (105 + v) & 0xFFFFFFFFFFFFFFFF
    st = (st * 6364136223846793005 + 105) & 0xFFFFFFFFFFFFFFFF
    return {b"__type": "Random", b"_st": st}

def _random_next_number(rng, a=None, b=None):
    st = rng[b"_st"]
    st, lo = _pcg_word(st)
    st, hi = _pcg_word(st)
    u = hi * (2.0 ** -32) + lo * (2.0 ** -64)
    if a is not None and b is not None:
        fa, fb = float(a), float(b)
        if fa > fb:
            fa, fb = fb, fa
        u = fa + (fb - fa) * u
    return st, fix_int(u)

def _random_next_integer(rng, a, b):
    st = rng[b"_st"]
    ia, ib = int(math.floor(float(a))), int(math.floor(float(b)))
    if ia > ib:
        ia, ib = ib, ia
    span = ib - ia + 1
    if span <= 4294967294:
        st, w = _pcg_word(st)
        return st, ia + ((w * span) >> 32)
    st, lo = _pcg_word(st)
    st, hi = _pcg_word(st)
    u64 = (hi << 32) | lo
    return st, ia + (((u64 * (span & 0xFFFFFFFFFFFFFFFF)) >> 64) & 0xFFFFFFFFFFFFFFFF)

def _lua_type(v):
    if v is None:
        return b"nil"
    if isinstance(v, bool):
        return b"boolean"
    if isinstance(v, (int, float)):
        return b"number"
    if isinstance(v, bytes):
        return b"string"
    if isinstance(v, (dict, LTable)):
        return b"table"
    raise ValueError("unknown type")

def _lua_typeof(v):
    if isinstance(v, dict) and b"__type" in v:
        t = v[b"__type"]
        return t.encode() if isinstance(t, str) else t
    return _lua_type(v)

FACT_CONCRETE = dict(CONCRETE)
FACT_CONCRETE.update({
    "type": _lua_type,
    "typeof": _lua_typeof,
    "UDim.new": _udim_new,
    "UDim2.new": _udim2_new,
    "UDim2.fromScale": _udim2_fromScale,
    "UDim2.fromOffset": _udim2_fromOffset,
    "Vector2.new": _vec2_new,
    "Path2DControlPoint.new": _p2d_cp_new,
    "Instance.new": _instance_new,
    "Path2D.GetLength": _p2d_length,
    "Path2D.GetPositionOnCurve": lambda p, t: _p2d_pos(p, t, False),
    "Path2D.GetPositionOnCurveArcLength": lambda p, t: _p2d_pos(p, t, True),
    "Path2D.GetTangentOnCurve": lambda p, t: _p2d_tan(p, t, False),
    "Path2D.GetTangentOnCurveArcLength": lambda p, t: _p2d_tan(p, t, True),
    "Random.new": _random_new,
    "Random.Clone": lambda r: {b"__type": "Random", b"_st": r[b"_st"]},
})

_SCOPE_MISSING = object()

class Scope:
    """Local variables keyed by declaration location (luau-ast)."""
    __slots__ = ("vars", "parent")

    def __init__(self, parent=None):
        self.vars = {}
        self.parent = parent

    def lookup(self, key):
        s = self
        while s is not None:
            if key in s.vars:
                return s
            s = s.parent
        return None

    def get(self, key, default=_SCOPE_MISSING):
        s = self
        while s is not None:
            v = s.vars.get(key, _SCOPE_MISSING)
            if v is not _SCOPE_MISSING:
                return v
            s = s.parent
        return default

class Interp:
    """Evaluates AST nodes. Hooks for the VM-specific parts:
      special[decl_key] -> "sink" (reads nil, writes ignored) or
                           ("pseudo", name) (for-loop state, see devirt)
      emit(stmt)        -> IR statement sink
      new_temp()        -> temp id for a materialized call
    """

    def __init__(self, lifter):
        self.L = lifter
        self.decisions = []
        self.dpos = 0
        self.dlog = []          
        self.seen = {}          
        self.steps = 0

    def decide(self, cond):
        if self.dpos < len(self.decisions):
            d = self.decisions[self.dpos]
        else:
            d = True
            self.decisions.append(d)
        self.dlog.append((self.dpos, len(self.L.out), cond, d))
        self.dpos += 1
        return d

    def cond_true(self, v):
        if is_sym(v):

            base, neg = v, False
            while isinstance(base, Un) and base.op == "Not":
                base, neg = base.a, not neg
            hit = self.seen.get(id(base))
            if hit is not None and hit[0] is base:
                return hit[1] != neg
            self.L.check_decision(v)
            d = self.decide(v)
            self.seen[id(base)] = (base, d != neg)
            return d
        if isinstance(v, (SymList, Multi, RegFile, EnvTable, UpContainer)):
            return True
        return truthy(v)

    def getvar(self, scope, local):
        key = local["location"]
        sp = self.L.special.get(key)
        if sp is not None:
            return self.L.special_get(sp, self)
        # Scope.get inlined: one call frame less on every variable read
        s = scope
        while s is not None:
            v = s.vars.get(key, _SCOPE_MISSING)
            if v is not _SCOPE_MISSING:
                return v
            s = s.parent
        # captured VM state: a free name of a VM closure reached through a
        # helper called with a fresh scope has no chain to the maker's env,
        # but the capture recorded the value the real run saw (by name)
        fb = getattr(self.L, "cap_fallback", None)
        if fb:
            try:
                return fb[local["name"]]
            except KeyError:
                pass
        raise Unsupported("unbound local %s@%s" % (local["name"], key))

    def setvar(self, scope, local, v):
        key = local["location"]
        sp = self.L.special.get(key)
        if sp is not None:
            self.L.special_set(sp, v, self)
            return
        s = scope.lookup(key)
        if s is None:
            scope.vars[key] = v
            return
        s.vars[key] = v

    def exec_block(self, stmts, scope):
        for st in stmts:
            self.exec_stmt(st, scope)

    def exec_stmt(self, st, scope):
        self.steps += 1
        if self.steps > 2_000_000:
            raise Unsupported("interpreter step limit")
        t = st["type"]
        if t == "AstStatBlock":
            self.exec_block(st["body"], Scope(scope))
        elif t == "AstStatLocal":
            vars_ = st["vars"]
            if len(vars_) == 1:
                v = vars_[0]
                loc = v["location"]
                vals_ast = st["values"]
                if len(vals_ast) == 1 and vals_ast[0]["type"] not in ("AstExprCall", "AstExprVarargs"):
                    x = self.eval(vals_ast[0], scope)
                elif vals_ast:
                    x = self.eval_list(vals_ast, scope, 1)[0]
                else:
                    x = None
                scope.vars[loc] = x
                sp = self.L.special.get(loc)
                if sp is not None and sp[0] == "reg":
                    self.L.special_set(sp, x, self)
            else:
                vals = self.eval_list(st["values"], scope, len(vars_))
                for v, x in zip(vars_, vals):
                    scope.vars[v["location"]] = x
                    sp = self.L.special.get(v["location"])
                    if sp is not None and sp[0] == "reg":
                        self.L.special_set(sp, x, self)
        elif t == "AstStatAssign":
            vars_ = st["vars"]
            if len(vars_) == 1:
                vals_ast = st["values"]
                if len(vals_ast) == 1 and vals_ast[0]["type"] not in ("AstExprCall", "AstExprVarargs"):
                    tg = self.lvalue(vars_[0], scope)
                    x = self.eval(vals_ast[0], scope)
                    self.assign(tg, x, scope)
                else:
                    tg = self.lvalue(vars_[0], scope)
                    x = self.eval_list(vals_ast, scope, 1)[0]
                    self.assign(tg, x, scope)
            else:
                targets = [self.lvalue(v, scope) for v in vars_]
                vals = self.eval_list(st["values"], scope, len(targets))
                if hasattr(self.L, "parallel_values"):
                    vals = self.L.parallel_values(targets, vals, self)
                for tg, x in zip(targets, vals):
                    self.assign(tg, x, scope)
        elif t == "AstStatCompoundAssign":
            tg = self.lvalue(st["var"], scope)
            cur = self.read_lvalue(tg, scope)
            self.assign(tg, self.binop(st["op"], cur, self.eval(st["value"], scope)), scope)
        elif t == "AstStatIf":
            if self.cond_true(self.eval(st["condition"], scope)):
                self.exec_block(st["thenbody"]["body"], Scope(scope))
            elif st.get("elsebody") is not None:
                e = st["elsebody"]
                if e["type"] == "AstStatIf":
                    self.exec_stmt(e, scope)
                else:
                    self.exec_block(e["body"], Scope(scope))
        elif t == "AstStatWhile":
            if self.L.is_dispatch(st):
                raise YieldSig(st)
            n = 0
            while self.cond_true(self.eval(st["condition"], scope)):
                n += 1
                if n > 100000:
                    raise Unsupported("while loop limit")
                try:
                    self.exec_block(st["body"]["body"], Scope(scope))
                except BreakSig:
                    break
                except ContinueSig:
                    continue
        elif t == "AstStatRepeat":
            n = 0
            while True:
                n += 1
                if n > 100000:
                    raise Unsupported("repeat loop limit")
                inner = Scope(scope)
                try:
                    self.exec_block(st["body"]["body"], inner)
                except BreakSig:
                    break
                except ContinueSig:
                    pass
                if self.cond_true(self.eval(st["condition"], inner)):
                    break
        elif t == "AstStatFor":
            a = self.eval(st["from"], scope)
            b = self.eval(st["to"], scope)
            c = self.eval(st["step"], scope) if st.get("step") else 1
            if is_sym(a) or is_sym(b) or is_sym(c):
                if hasattr(self.L, "_need_jreg"):
                    self.L._need_jreg(a, b, c)
                raise Unsupported("numeric for with symbolic bounds")
            if a is None or b is None or c is None:
                pass  # bound unknown at capture: skip, like a while with an unknown (falsy) condition
            else:
                i = a
                n = 0
                while (c > 0 and i <= b) or (c <= 0 and i >= b):
                    n += 1
                    if n > 1000000:
                        raise Unsupported("for loop limit")
                    inner = Scope(scope)
                    inner.vars[st["var"]["location"]] = i
                    try:
                        self.exec_block(st["body"]["body"], inner)
                    except BreakSig:
                        break
                    except ContinueSig:
                        pass
                    i = fix_int(i + c)
        elif t == "AstStatForIn":
            vals = self.eval_list(st["values"], scope, 3)
            f, s, ctl = vals
            n = 0
            while f is not None:
                n += 1
                if n > 1000000:
                    raise Unsupported("for-in limit")
                r = self.call(f, [s, ctl])
                r = self.adjust(r, len(st["vars"]))
                if r[0] is None:
                    break
                if is_sym(r[0]):
                    raise Unsupported("symbolic generic for")
                ctl = r[0]
                inner = Scope(scope)
                for v, x in zip(st["vars"], r):
                    inner.vars[v["location"]] = x
                try:
                    self.exec_block(st["body"]["body"], inner)
                except BreakSig:
                    break
                except ContinueSig:
                    pass
        elif t == "AstStatReturn":
            raise ReturnSig(self.eval_multi_list(st["list"], scope))
        elif t == "AstStatBreak":
            raise BreakSig()
        elif t == "AstStatContinue":
            raise ContinueSig()
        elif t == "AstStatExpr":
            e = st["expr"]
            if e["type"] != "AstExprCall":
                raise Unsupported("expression statement " + e["type"])
            self.eval_call(e, scope, stat=True)
        elif t == "AstStatLocalFunction":
            scope.vars[st["name"]["location"]] = LuaFunc(st["func"], scope)
        elif t == "AstStatFunction":
            raise Unsupported("function statement")
        else:
            raise Unsupported("statement " + t)

    def lvalue(self, node, scope):
        t = node["type"]
        if t == "AstExprLocal":
            return ("local", node["local"])
        if t == "AstExprIndexExpr":
            return ("index", self.eval(node["expr"], scope), self.eval(node["index"], scope))
        if t == "AstExprIndexName":
            idx = node.get("_idx")
            if idx is None:
                idx = node["index"].encode("latin-1")
                node["_idx"] = idx
            return ("index", self.eval(node["expr"], scope), idx)
        if t == "AstExprGlobal":
            return ("global", node["global"])
        raise Unsupported("lvalue " + t)

    def read_lvalue(self, tg, scope):
        if tg[0] == "local":
            return self.getvar(scope, tg[1])
        if tg[0] == "index":
            return self.index(tg[1], tg[2])
        raise Unsupported("read global lvalue")

    def assign(self, tg, v, scope):
        if tg[0] == "local":
            self.setvar(scope, tg[1], v)
        elif tg[0] == "index":
            self.newindex(tg[1], tg[2], v)
        elif hasattr(self.L, "set_global"):

            self.L.set_global(tg[1], v)
        else:
            raise Unsupported("assignment to global %s in VM code" % tg[1])

    def eval_list(self, nodes, scope, want):
        """Evaluate an expression list adjusted to `want` values."""
        vals = self.eval_multi_list(nodes, scope)
        return self.adjust(vals, want)

    def adjust(self, m, want):
        if not isinstance(m, Multi):
            m = Multi([m])
        out = list(m.items[:want])
        i = 1
        while len(out) < want:
            if m.tail is not None:
                out.append(m.tail.at(i))
                i += 1
            else:
                out.append(None)
        return out

    def eval_multi_list(self, nodes, scope):
        items = []
        tail = None
        for i, n in enumerate(nodes):
            if i == len(nodes) - 1 and n["type"] in ("AstExprCall", "AstExprVarargs"):
                m = self.eval_multi(n, scope)
                items += m.items
                tail = m.tail
            else:
                items.append(self.eval(n, scope))
        return Multi(items, tail)

    def eval_multi(self, node, scope):
        t = node["type"]
        if t == "AstExprCall":
            r = self.eval_call(node, scope)
            return r if isinstance(r, Multi) else Multi([r])
        if t == "AstExprVarargs":
            return self.L.varargs(scope)
        return Multi([self.eval(node, scope)])

    def eval(self, node, scope):
        f = _EVAL_DISPATCH.get(node["type"])
        if f is None:
            raise Unsupported("expression " + node["type"])
        return f(self, node, scope)

    def _ev_num(self, node, scope):
        v = node.get("_v")
        if v is None:
            v = fix_int(node["value"])
            node["_v"] = v
        return v

    def _ev_str(self, node, scope):
        v = node.get("_v")
        if v is None:
            v = node["value"].encode("latin-1")
            node["_v"] = v
        return v

    def _ev_bool(self, node, scope):
        return node["value"]

    def _ev_nil(self, node, scope):
        return None

    def _ev_local(self, node, scope):
        return self.getvar(scope, node["local"])

    def _ev_global(self, node, scope):
        return self.L.global_value(node["global"])

    def _ev_group(self, node, scope):
        return self.eval(node["expr"], scope)

    def _ev_indexexpr(self, node, scope):
        obj = self.eval(node["expr"], scope)
        if obj is None:
            raise Unsupported("index nil @%s" % node["location"])
        return self.index(obj, self.eval(node["index"], scope))

    def _ev_indexname(self, node, scope):
        obj = self.eval(node["expr"], scope)
        if obj is None:
            raise Unsupported("index nil @%s" % node["location"])
        idx = node.get("_idx")
        if idx is None:
            idx = node["index"].encode("latin-1")
            node["_idx"] = idx
        return self.index(obj, idx)

    def _ev_call(self, node, scope):
        r = self.eval_call(node, scope)
        return r.first() if isinstance(r, Multi) else r

    def _ev_varargs(self, node, scope):
        return self.L.varargs(scope).first()

    def _ev_binary(self, node, scope):
        op = node["op"]
        if op == "And":
            a = self.eval(node["left"], scope)
            return self.eval(node["right"], scope) if self.cond_true(a) else a
        if op == "Or":
            a = self.eval(node["left"], scope)
            return a if self.cond_true(a) else self.eval(node["right"], scope)
        return self.binop(op, self.eval(node["left"], scope), self.eval(node["right"], scope))

    def _ev_unary(self, node, scope):
        return self.unop(node["op"], self.eval(node["expr"], scope))

    def _ev_ifelse(self, node, scope):
        c = self.eval(node["condition"], scope)
        return self.eval(node["trueExpr"] if self.cond_true(c) else node["falseExpr"], scope)

    def _ev_table(self, node, scope):
        return self.table_ctor(node, scope)

    def _ev_func(self, node, scope):
        return LuaFunc(node, scope)

    def _ev_typeassert(self, node, scope):
        return self.eval(node["expr"], scope)

    def table_ctor(self, node, scope):
        items = node["items"]

        tb = LTable()
        pos = 1
        symbolic = False
        for i, it in enumerate(items):
            if it["kind"] == "item":
                last = i == len(items) - 1
                if last and it["value"]["type"] in ("AstExprCall", "AstExprVarargs"):
                    m = self.eval_multi(it["value"], scope)
                    if m.tail is not None:
                        lst = SymList([tb.h.get(k) for k in range(1, pos)] + m.items, m.tail,
                                      nkey=None)
                        return lst
                    for v in m.items:
                        tb.set(pos, v)
                        pos += 1
                else:
                    tb.set(pos, self.eval(it["value"], scope))
                    pos += 1
            else:
                k = it["key"]["value"].encode("latin-1") if it["kind"] == "record" else self.eval(it["key"], scope)
                v = self.eval(it["value"], scope)
                if is_sym(k):
                    symbolic = True
                tb.set(k, v)
        if symbolic:
            raise Unsupported("symbolic key in table constructor")
        return tb

    def binop(self, op, a, b):
        if is_sym(a) or is_sym(b) or isinstance(a, (SymList, RegFile)) or isinstance(b, (SymList, RegFile)):
            return self.L.sym_binop(op, a, b)
        if op in ("Add", "Sub", "Mul", "Div", "FloorDiv", "Mod", "Pow"):
            x, y = lua_num(a), lua_num(b)
            if x is None or y is None:
                raise Unsupported("arith on %r %r" % (a, b))
            return arith(op, x, y)
        if op == "Concat":
            def s(v):
                if isinstance(v, bytes):
                    return v
                if isinstance(v, (int, float)):
                    return fmt_num(v).encode()
                raise Unsupported("concat")
            return s(a) + s(b)
        if op == "CompareEq":
            return lua_eq(a, b)
        if op == "CompareNe":
            return not lua_eq(a, b)
        if op in ("CompareLt", "CompareLe", "CompareGt", "CompareGe"):
            if not ((isinstance(a, (int, float)) and isinstance(b, (int, float)) and not isinstance(a, bool)
                     and not isinstance(b, bool)) or (isinstance(a, bytes) and isinstance(b, bytes))):
                raise Unsupported("compare %r %r" % (a, b))
            return {"CompareLt": a < b, "CompareLe": a <= b, "CompareGt": a > b, "CompareGe": a >= b}[op]
        raise Unsupported("binop " + op)

    def unop(self, op, a):
        if is_sym(a) or isinstance(a, SymList):
            return self.L.sym_unop(op, a)
        if op == "Not":
            return not truthy(a)
        if op == "Minus":
            x = lua_num(a)
            if x is None:
                raise Unsupported("unm")
            return fix_int(-x)
        if op == "Len":
            if isinstance(a, bytes):
                return len(a)
            if isinstance(a, LTable):
                return a.length()
            raise Unsupported("len of %r" % (a,))
        raise Unsupported("unop " + op)

    def index(self, obj, key):
        return self.L.index(obj, key, self)

    def newindex(self, obj, key, v):
        self.L.newindex(obj, key, v, self)

    def eval_call(self, node, scope, stat=False):
        fnode = node["func"]
        if node.get("self"):
            obj = self.eval(fnode["expr"], scope)
            fn = self.index(obj, fnode["index"].encode("latin-1"))
            args = self.eval_multi_list(node["args"], scope)
            args = Multi([obj] + args.items, args.tail)
        else:
            fn = self.eval(fnode, scope)
            args = self.eval_multi_list(node["args"], scope)
        return self.call(fn, args, stat=stat)

    def call(self, fn, args, stat=False):
        if not isinstance(args, Multi):
            args = Multi(list(args))
        if isinstance(fn, LuaFunc):
            return self.call_lua(fn, args)
        if isinstance(fn, Builtin):
            return self.L.call_builtin(fn, args, self, stat)
        return self.L.call_symbolic(fn, args, self, stat)

    def call_lua(self, fn, args):
        node = fn.node
        scope = Scope(fn.env)
        vals = self.adjust(args, len(node["args"]))
        for a, v in zip(node["args"], vals):
            scope.vars[a["location"]] = v
        if node.get("vararg"):
            rest = Multi(args.items[len(node["args"]):], args.tail.drop(max(0, len(node["args"]) - len(args.items)))
                         if args.tail is not None else None)
            scope.vars["..."] = rest
        try:
            self.exec_block(node["body"]["body"], scope)
        except ReturnSig as r:
            return r.values
        return Multi([])

# expression-type dispatch (eval used to be a 15-branch string if-chain; it
# is one of the hottest functions of the whole pipeline)
_EVAL_DISPATCH = {
    "AstExprConstantNumber": Interp._ev_num,
    "AstExprConstantString": Interp._ev_str,
    "AstExprConstantBool": Interp._ev_bool,
    "AstExprConstantNil": Interp._ev_nil,
    "AstExprLocal": Interp._ev_local,
    "AstExprGlobal": Interp._ev_global,
    "AstExprGroup": Interp._ev_group,
    "AstExprIndexExpr": Interp._ev_indexexpr,
    "AstExprIndexName": Interp._ev_indexname,
    "AstExprCall": Interp._ev_call,
    "AstExprVarargs": Interp._ev_varargs,
    "AstExprBinary": Interp._ev_binary,
    "AstExprUnary": Interp._ev_unary,
    "AstExprIfElse": Interp._ev_ifelse,
    "AstExprTable": Interp._ev_table,
    "AstExprFunction": Interp._ev_func,
    "AstExprTypeAssertion": Interp._ev_typeassert,
}

def lua_eq(a, b):
    if isinstance(a, bool) or isinstance(b, bool):
        return a is b
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return a == b
    if isinstance(a, bytes) and isinstance(b, bytes):
        return a == b
    return a is b

def fmt_num(v):
    if isinstance(v, int):
        return str(v)
    if v != v:
        return "nan"
    if math.isinf(v):
        return "inf" if v > 0 else "-inf"
    if v.is_integer() and abs(v) < 1e15:
        return str(int(v))
    r = "%.14g" % v
    if float(r) != v:
        r = "%.17g" % v
    return r
