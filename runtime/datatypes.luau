--!nocheck
-- Offline models of Roblox datatypes that are pure math (bundled into the
-- harness as __ROBLOX.datatypes). envlog.luau attaches a model value as the
-- "real twin" (REALV) of a datatype proxy built from constant arguments, so
-- members, methods and operators give the engine's numbers instead of
-- symbolic expressions (scripts and obfuscators derive values from them).
--
-- Anything a model doesn't implement, or arguments it can't take, raise
-- UNSUPPORTED: envlog then falls back to the symbolic proxy. Real Roblox
-- errors are only raised where Studio was checked.
--
-- CFrame: position + 3x3 rotation, float32 like the engine (stored as native
-- vectors, so the math is float32 per component). Verified against Studio:
-- constructors, tostring, GetComponents, * / + / -, Inverse, the space
-- conversions, Euler/axis-angle getters, Lerp.
local UNSUPPORTED = setmetatable({}, { __tostring = function() return "<datatypes: unsupported>" end })
local function unsupported() error(UNSUPPORTED, 0) end

local vec = vector.create
local vdot, vcross, vnorm, vmag = vector.dot, vector.cross, vector.normalize, vector.magnitude
local fbuf = buffer.create(4)
local function f32(x)
	buffer.writef32(fbuf, 0, x)
	return buffer.readf32(fbuf, 0)
end
local function isVec(v) return type(v) == "vector" end
local function num(v)
	if type(v) == "number" then return v end
	if type(v) == "string" and tonumber(v) then return tonumber(v) end
	return unsupported()
end

-- CFrame values: userdata -> { p = pos, x = col0, y = col1, z = col2 }
local CF = setmetatable({}, { __mode = "k" })
local CFMT = {}
local function make(p, cx, cy, cz)
	local u = newproxy(true)
	local mt = getmetatable(u)
	for k, v in CFMT do mt[k] = v end
	CF[u] = { p = p, x = cx, y = cy, z = cz }
	return u
end
local function get(v)
	local c = CF[v]
	if not c then unsupported() end
	return c
end
local X, Y, Z, O = vec(1, 0, 0), vec(0, 1, 0), vec(0, 0, 1), vec(0, 0, 0)
local IDENTITY = { p = O, x = X, y = Y, z = Z }

-- rotation from rows (row-major components as in GetComponents)
local function fromRows(p, r00, r01, r02, r10, r11, r12, r20, r21, r22)
	return make(p, vec(r00, r10, r20), vec(r01, r11, r21), vec(r02, r12, r22))
end
local function rot(c, v) return c.x * v.x + c.y * v.y + c.z * v.z end
local function rotT(c, v) return vec(vdot(c.x, v), vdot(c.y, v), vdot(c.z, v)) end
local function mul(a, b) return { p = rot(a, b.p) + a.p, x = rot(a, b.x), y = rot(a, b.y), z = rot(a, b.z) } end
local function inverse(c)
	local x = vec(c.x.x, c.y.x, c.z.x)
	local y = vec(c.x.y, c.y.y, c.z.y)
	local z = vec(c.x.z, c.y.z, c.z.z)
	local r = { p = O, x = x, y = y, z = z }
	r.p = -rot(r, c.p)
	return r
end
local function wrap(c) return make(c.p, c.x, c.y, c.z) end

-- rotation matrices (double math, rounded once per component)
local function rx(a)
	local s, c = math.sin(a), math.cos(a)
	return { 1, 0, 0, 0, c, -s, 0, s, c }
end
local function ry(a)
	local s, c = math.sin(a), math.cos(a)
	return { c, 0, s, 0, 1, 0, -s, 0, c }
end
local function rz(a)
	local s, c = math.sin(a), math.cos(a)
	return { c, -s, 0, s, c, 0, 0, 0, 1 }
end
local function mm(a, b)
	local r = {}
	for i = 0, 2 do
		for j = 0, 2 do
			r[i * 3 + j + 1] = a[i * 3 + 1] * b[j + 1] + a[i * 3 + 2] * b[j + 4] + a[i * 3 + 3] * b[j + 7]
		end
	end
	return r
end
local function fromMat(p, m)
	return fromRows(p, m[1], m[2], m[3], m[4], m[5], m[6], m[7], m[8], m[9])
end
local function fromQuat(p, qx, qy, qz, qw)
	local n = qx * qx + qy * qy + qz * qz + qw * qw
	if n == 0 then unsupported() end
	local s = 2 / n
	return fromRows(p,
		1 - s * (qy * qy + qz * qz), s * (qx * qy - qz * qw), s * (qx * qz + qy * qw),
		s * (qx * qy + qz * qw), 1 - s * (qx * qx + qz * qz), s * (qy * qz - qx * qw),
		s * (qx * qz - qy * qw), s * (qy * qz + qx * qw), 1 - s * (qx * qx + qy * qy))
end
local function toQuat(c)
	local m00, m01, m02 = c.x.x, c.y.x, c.z.x
	local m10, m11, m12 = c.x.y, c.y.y, c.z.y
	local m20, m21, m22 = c.x.z, c.y.z, c.z.z
	local tr = m00 + m11 + m22
	if tr > 0 then
		local s = math.sqrt(tr + 1) * 2
		return (m21 - m12) / s, (m02 - m20) / s, (m10 - m01) / s, s / 4
	elseif m00 > m11 and m00 > m22 then
		local s = math.sqrt(1 + m00 - m11 - m22) * 2
		return s / 4, (m01 + m10) / s, (m02 + m20) / s, (m21 - m12) / s
	elseif m11 > m22 then
		local s = math.sqrt(1 + m11 - m00 - m22) * 2
		return (m01 + m10) / s, s / 4, (m12 + m21) / s, (m02 - m20) / s
	end
	local s = math.sqrt(1 + m22 - m00 - m11) * 2
	return (m02 + m20) / s, (m12 + m21) / s, s / 4, (m10 - m01) / s
end
local function lookAt(at, target, up)
	local look = vnorm(target - at)
	local right = vcross(look, up)
	if vmag(right) < 1e-6 then unsupported() end -- the engine's degenerate case isn't modelled
	right = vnorm(right)
	local up2 = vcross(right, look)
	return make(at, right, up2, -look)
end

local lib = {}
function lib.new(...)
	local n = select("#", ...)
	local a = { ... }
	if n == 0 then return wrap(IDENTITY) end
	if n == 1 and isVec(a[1]) then return make(a[1], X, Y, Z) end
	if n == 2 and isVec(a[1]) and isVec(a[2]) then return lookAt(a[1], a[2], Y) end
	if n == 3 then return make(vec(num(a[1]), num(a[2]), num(a[3])), X, Y, Z) end
	if n == 7 then
		return fromQuat(vec(num(a[1]), num(a[2]), num(a[3])), num(a[4]), num(a[5]), num(a[6]), num(a[7]))
	end
	if n == 12 then
		for i = 1, 12 do a[i] = num(a[i]) end
		return fromRows(vec(a[1], a[2], a[3]), a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12])
	end
	return unsupported()
end
function lib.Angles(a, b, c)
	return fromMat(O, mm(mm(rx(num(a or 0)), ry(num(b or 0))), rz(num(c or 0))))
end
lib.fromEulerAnglesXYZ = lib.Angles
function lib.fromEulerAnglesYXZ(a, b, c)
	return fromMat(O, mm(mm(ry(num(b or 0)), rx(num(a or 0))), rz(num(c or 0))))
end
lib.fromOrientation = lib.fromEulerAnglesYXZ
function lib.fromAxisAngle(axis, angle)
	if not isVec(axis) then unsupported() end
	local u = vnorm(axis)
	local h = num(angle) / 2
	local s = math.sin(h)
	return fromQuat(O, u.x * s, u.y * s, u.z * s, math.cos(h))
end
function lib.lookAt(at, target, up)
	if not isVec(at) or not isVec(target) or (up ~= nil and not isVec(up)) then unsupported() end
	return lookAt(at, target, up or Y)
end
function lib.lookAlong(at, dir, up)
	if not isVec(at) or not isVec(dir) or (up ~= nil and not isVec(up)) then unsupported() end
	return lookAt(at, at + dir, up or Y)
end
function lib.fromRotationBetweenVectors(u, v)
	if not isVec(u) or not isVec(v) then unsupported() end
	local nu, nv = vnorm(u), vnorm(v)
	local d = vdot(nu, nv)
	if d >= 1 - 1e-6 then return wrap(IDENTITY) end
	if d <= -1 + 1e-6 then
		local axis = vcross(X, nu)
		if vmag(axis) < 1e-6 then axis = vcross(Y, nu) end
		axis = vnorm(axis)
		return fromQuat(O, axis.x, axis.y, axis.z, 0)
	end
	local c = vcross(nu, nv)
	local s = math.sqrt((1 + d) * 2)
	return fromQuat(O, c.x / s, c.y / s, c.z / s, s / 2)
end
function lib.fromEulerAngles(a, b, c, _order)
	return lib.fromEulerAnglesXYZ(a, b, c)
end
function lib.fromMatrix(p, vx, vy, vz)
	if not isVec(p) or not isVec(vx) or not isVec(vy) or (vz ~= nil and not isVec(vz)) then unsupported() end
	return make(p, vx, vy, vz or vnorm(vcross(vx, vy)))
end

local function components(c)
	return c.p.x, c.p.y, c.p.z, c.x.x, c.y.x, c.z.x, c.x.y, c.y.y, c.z.y, c.x.z, c.y.z, c.z.z
end
local function eulerXYZ(c)
	local r02 = math.clamp(c.z.x, -1, 1)
	return f32(math.atan2(-c.z.y, c.z.z)), f32(math.asin(r02)), f32(math.atan2(-c.y.x, c.x.x))
end
local function eulerYXZ(c)
	local r12 = math.clamp(c.z.y, -1, 1)
	return f32(math.asin(-r12)), f32(math.atan2(c.z.x, c.z.z)), f32(math.atan2(c.x.y, c.y.y))
end
local function each(f)
	-- methods taking one or more values and returning one result each
	return function(self, ...)
		local c = get(self)
		local n = select("#", ...)
		if n == 0 then unsupported() end
		local out = { ... }
		for i = 1, n do out[i] = f(c, out[i]) end
		return table.unpack(out, 1, n)
	end
end
local function vecArg(v)
	if not isVec(v) then unsupported() end
	return v
end
local METHODS = {
	Inverse = function(self) return wrap(inverse(get(self))) end,
	Orthonormalize = function(self)
		local c = get(self)
		local z = vnorm(c.z)
		local y = vnorm(c.y - z * vdot(c.y, z))
		local x = vcross(y, z)
		return make(c.p, x, y, z)
	end,
	GetComponents = function(self) return components(get(self)) end,
	ToWorldSpace = each(function(c, o) return wrap(mul(c, get(o))) end),
	ToObjectSpace = each(function(c, o) return wrap(mul(inverse(c), get(o))) end),
	PointToWorldSpace = each(function(c, v) return rot(c, vecArg(v)) + c.p end),
	PointToObjectSpace = each(function(c, v) return rotT(c, vecArg(v) - c.p) end),
	VectorToWorldSpace = each(function(c, v) return rot(c, vecArg(v)) end),
	VectorToObjectSpace = each(function(c, v) return rotT(c, vecArg(v)) end),
	ToEulerAnglesXYZ = function(self) return eulerXYZ(get(self)) end,
	ToEulerAnglesYXZ = function(self) return eulerYXZ(get(self)) end,
	ToEulerAngles = function(self, _order) return eulerXYZ(get(self)) end,
	ToOrientation = function(self) return eulerYXZ(get(self)) end,
	FuzzyEq = function(self, other, eps)
		local a, b = get(self), get(other)
		eps = type(eps) == "number" and eps or 1e-5
		local function feq(u, v)
			for _, k in { "x", "y", "z" } do
				local ux, vx = u[k], v[k]
				local m = math.max(1, math.abs(ux), math.abs(vx))
				if not (math.abs(ux - vx) <= eps * m) then return false end
			end
			return true
		end
		return feq(a.p, b.p) and feq(a.x, b.x) and feq(a.y, b.y) and feq(a.z, b.z)
	end,
	AngleBetween = function(self, other)
		local a, b = get(self), get(other)
		local ax, ay, az, aw = toQuat(a)
		local bx, by, bz, bw = toQuat(b)
		local d = math.clamp(math.abs(ax * bx + ay * by + az * bz + aw * bw), -1, 1)
		return f32(2 * math.acos(d))
	end,
	ToAxisAngle = function(self)
		local qx, qy, qz, qw = toQuat(get(self))
		if qw < 0 then qx, qy, qz, qw = -qx, -qy, -qz, -qw end
		local s = math.sqrt(math.max(0, 1 - qw * qw))
		if s < 1e-9 then return X, 0 end
		return vec(qx / s, qy / s, qz / s), f32(2 * math.acos(math.clamp(qw, -1, 1)))
	end,
	Lerp = function(self, other, t)
		local a, b = get(self), get(other)
		t = num(t)
		local ax, ay, az, aw = toQuat(a)
		local bx, by, bz, bw = toQuat(b)
		local d = ax * bx + ay * by + az * bz + aw * bw
		if d < 0 then bx, by, bz, bw, d = -bx, -by, -bz, -bw, -d end
		local wa, wb
		if d > 0.9995 then
			wa, wb = 1 - t, t
		else
			local th = math.acos(d)
			local s = math.sin(th)
			wa, wb = math.sin((1 - t) * th) / s, math.sin(t * th) / s
		end
		local p = a.p + (b.p - a.p) * t
		return fromQuat(p, ax * wa + bx * wb, ay * wa + by * wb, az * wa + bz * wb, aw * wa + bw * wb)
	end,
}
METHODS.components = METHODS.GetComponents
METHODS.inverse = METHODS.Inverse
METHODS.lerp = METHODS.Lerp
METHODS.toWorldSpace = METHODS.ToWorldSpace
METHODS.toObjectSpace = METHODS.ToObjectSpace
METHODS.pointToWorldSpace = METHODS.PointToWorldSpace
METHODS.pointToObjectSpace = METHODS.PointToObjectSpace
METHODS.vectorToWorldSpace = METHODS.VectorToWorldSpace
METHODS.vectorToObjectSpace = METHODS.VectorToObjectSpace
METHODS.toEulerAnglesXYZ = METHODS.ToEulerAnglesXYZ
METHODS.toAxisAngle = METHODS.ToAxisAngle

local PROPS = {
	Position = function(c) return c.p end,
	X = function(c) return c.p.x end,
	Y = function(c) return c.p.y end,
	Z = function(c) return c.p.z end,
	LookVector = function(c) return -c.z end,
	RightVector = function(c) return c.x end,
	UpVector = function(c) return c.y end,
	XVector = function(c) return c.x end,
	YVector = function(c) return c.y end,
	ZVector = function(c) return c.z end,
	Rotation = function(c) return make(O, c.x, c.y, c.z) end,
}
PROPS.p, PROPS.x, PROPS.y, PROPS.z = PROPS.Position, PROPS.X, PROPS.Y, PROPS.Z
PROPS.lookVector, PROPS.rightVector, PROPS.upVector = PROPS.LookVector, PROPS.RightVector, PROPS.UpVector

CFMT.__index = function(self, k)
	local c = get(self)
	local prop = PROPS[k]
	if prop then return prop(c) end
	local m = METHODS[k]
	if m then return m end
	if type(k) == "string" then error(k .. " is not a valid member of CFrame", 0) end
	return unsupported()
end
CFMT.__newindex = function() unsupported() end
CFMT.__mul = function(a, b)
	local c = get(a)
	if isVec(b) then return rot(c, b) + c.p end
	return wrap(mul(c, get(b)))
end
CFMT.__add = function(a, b)
	if not isVec(b) then unsupported() end
	local c = get(a)
	return make(c.p + b, c.x, c.y, c.z)
end
CFMT.__sub = function(a, b)
	if not isVec(b) then unsupported() end
	local c = get(a)
	return make(c.p - b, c.x, c.y, c.z)
end
CFMT.__eq = function(a, b)
	local x, y = CF[a], CF[b]
	return x ~= nil and y ~= nil and x.p == y.p and x.x == y.x and x.y == y.y and x.z == y.z
end
CFMT.__tostring = function(self)
	local t = { components(get(self)) }
	for i = 1, 12 do t[i] = string.format("%.9g", t[i]) end
	return table.concat(t, ", ")
end
CFMT.__metatable = "The metatable is locked"
-- Create the identity CFrame only now: make() snapshots CFMT into each proxy's
-- metatable, so a CFrame built before CFMT was populated (the old position of
-- this line, up with the constructors) had an empty metatable -> tostring/index/
-- operators silently failed on CFrame.identity. Build it after CFMT is complete.
lib.identity = wrap(IDENTITY)

-- UDim / UDim2 / Path2DControlPoint (verified against Studio: tostring,
-- int32 offsets truncated toward zero, float32 scales, + - unary -, ==,
-- Lerp rounding offsets, the control point's 0/1/3-argument constructor)
local TYPE = setmetatable({}, { __mode = "k" }) -- value -> type name
local VAL = setmetatable({}, { __mode = "k" }) -- value -> fields
local function valueType(name, index, ops)
	local mt = { __metatable = "The metatable is locked" }
	for k, v in ops do mt[k] = v end
	mt.__index = function(self, k)
		local r = index(VAL[self], k)
		if r ~= nil then return r end
		if type(k) == "string" then error(k .. " is not a valid member of " .. name, 0) end
		return unsupported()
	end
	mt.__newindex = function() unsupported() end
	return function(fields)
		local u = newproxy(true)
		local m = getmetatable(u)
		for k, v in mt do m[k] = v end
		TYPE[u], VAL[u] = name, fields
		return u
	end
end
local function field(v, name)
	if TYPE[v] ~= name then unsupported() end
	return VAL[v]
end
local function int32(x)
	x = num(x)
	if x ~= x or x >= 2147483648 or x < -2147483648 then return -2147483648 end
	return x < 0 and math.ceil(x) or math.floor(x)
end

local newUDim
newUDim = valueType("UDim", function(f, k)
	if k == "Scale" then return f.s end
	if k == "Offset" then return f.o end
	return nil
end, {
	__add = function(a, b) local x, y = field(a, "UDim"), field(b, "UDim") return newUDim({ s = f32(x.s + y.s), o = int32(x.o + y.o) }) end,
	__sub = function(a, b) local x, y = field(a, "UDim"), field(b, "UDim") return newUDim({ s = f32(x.s - y.s), o = int32(x.o - y.o) }) end,
	__unm = function(a) local x = field(a, "UDim") return newUDim({ s = -x.s, o = int32(-x.o) }) end,
	__eq = function(a, b) local x, y = VAL[a], VAL[b] return TYPE[a] == TYPE[b] and x.s == y.s and x.o == y.o end,
	__tostring = function(a) local x = VAL[a] return string.format("%.9g, %d", x.s, x.o) end,
})
local function udim(s, o) return newUDim({ s = f32(num(s or 0)), o = int32(o or 0) }) end

local newUDim2
local function udim2Str(f)
	local x, y = VAL[f.x], VAL[f.y]
	return string.format("{%.9g, %d}, {%.9g, %d}", x.s, x.o, y.s, y.o)
end
local function lerpUDim(a, b, t)
	local x, y = VAL[a], VAL[b]
	return newUDim({ s = f32(x.s + (y.s - x.s) * t), o = int32(math.floor(x.o + (y.o - x.o) * t + 0.5)) })
end
newUDim2 = valueType("UDim2", function(f, k)
	if k == "X" or k == "Width" then return f.x end
	if k == "Y" or k == "Height" then return f.y end
	if k == "Lerp" or k == "lerp" then
		return function(self, other, t)
			local a, b = field(self, "UDim2"), field(other, "UDim2")
			t = num(t)
			return newUDim2({ x = lerpUDim(a.x, b.x, t), y = lerpUDim(a.y, b.y, t) })
		end
	end
	return nil
end, {
	__add = function(a, b) local x, y = field(a, "UDim2"), field(b, "UDim2") return newUDim2({ x = x.x + y.x, y = x.y + y.y }) end,
	__sub = function(a, b) local x, y = field(a, "UDim2"), field(b, "UDim2") return newUDim2({ x = x.x - y.x, y = x.y - y.y }) end,
	__unm = function(a) local x = field(a, "UDim2") return newUDim2({ x = -x.x, y = -x.y }) end,
	__eq = function(a, b) return TYPE[a] == TYPE[b] and VAL[a].x == VAL[b].x and VAL[a].y == VAL[b].y end,
	__tostring = function(a) return udim2Str(VAL[a]) end,
})
local UDimLib = { new = function(s, o) return udim(s, o) end }
local UDim2Lib = {}
function UDim2Lib.new(...)
	local n = select("#", ...)
	local a, b, c, d = ...
	if n == 2 and TYPE[a] == "UDim" and TYPE[b] == "UDim" then return newUDim2({ x = a, y = b }) end
	for i = 1, n do
		local v = select(i, ...)
		if v ~= nil and type(v) ~= "number" and not (type(v) == "string" and tonumber(v)) then unsupported() end
	end
	return newUDim2({ x = udim(a, b), y = udim(c, d) })
end
function UDim2Lib.fromScale(x, y) return newUDim2({ x = udim(x, 0), y = udim(y, 0) }) end
function UDim2Lib.fromOffset(x, y) return newUDim2({ x = udim(0, x), y = udim(0, y) }) end

local newCP = valueType("Path2DControlPoint", function(f, k)
	if k == "Position" then return f.p end
	if k == "LeftTangent" then return f.l end
	if k == "RightTangent" then return f.r end
	return nil
end, {
	__eq = function(a, b)
		local x, y = VAL[a], VAL[b]
		return TYPE[a] == TYPE[b] and x.p == y.p and x.l == y.l and x.r == y.r
	end,
	__tostring = function(a)
		local f = VAL[a]
		return string.format("Path2DControlPoint { Position = %s, LeftTangent = %s, RightTangent = %s }",
			udim2Str(VAL[f.p]), udim2Str(VAL[f.l]), udim2Str(VAL[f.r]))
	end,
})
local CPLib = {}
function CPLib.new(...)
	local n = select("#", ...)
	local p, l, r = ...
	local zero = UDim2Lib.new()
	if n == 0 then return newCP({ p = zero, l = zero, r = zero }) end
	if n ~= 1 and n ~= 3 then error("Trying to create a Path2DControlPoint with wrong number of arguments", 0) end
	for i = 1, n do
		if TYPE[(select(i, ...))] ~= "UDim2" then unsupported() end
	end
	return newCP({ p = p, l = l or zero, r = r or zero })
end

-- Vector2 (userdata in Roblox, float32 components: kept as a native vector
-- with z = 0 so the arithmetic is float32), Rect (corners sorted), Ray.
-- Verified against Studio: tostring, operators, members, the methods below.
local newV2
local function v2(v) return newV2({ v = v }) end
local function v2val(v)
	if TYPE[v] ~= "Vector2" then unsupported() end
	return VAL[v].v
end
local function v2arith(op)
	return function(a, b)
		local x = TYPE[a] == "Vector2" and VAL[a].v or (type(a) == "number" and vec(a, a, 0)) or unsupported()
		local y = TYPE[b] == "Vector2" and VAL[b].v or (type(b) == "number" and vec(b, b, 0)) or unsupported()
		local r = op(x, y)
		return v2(vec(r.x, r.y, 0))
	end
end
local V2METHODS = {
	Dot = function(a, b) return vdot(v2val(a), v2val(b)) end,
	Cross = function(a, b) local x, y = v2val(a), v2val(b) return f32(f32(x.x * y.y) - f32(x.y * y.x)) end,
	Lerp = function(a, b, t) local x, y = v2val(a), v2val(b) return v2(x + (y - x) * num(t)) end,
	Abs = function(a) return v2(vector.abs(v2val(a))) end,
	Floor = function(a) return v2(vector.floor(v2val(a))) end,
	Ceil = function(a) return v2(vector.ceil(v2val(a))) end,
	Sign = function(a) return v2(vector.sign(v2val(a))) end,
	Max = function(a, b) return v2(vector.max(v2val(a), v2val(b))) end,
	Min = function(a, b) return v2(vector.min(v2val(a), v2val(b))) end,
	Angle = function(a, b, signed)
		local x, y = v2val(a), v2val(b)
		local ang = math.atan2(math.abs(x.x * y.y - x.y * y.x), x.x * y.x + x.y * y.y)
		if signed and x.x * y.y - x.y * y.x < 0 then ang = -ang end
		return f32(ang)
	end,
	FuzzyEq = function(a, b, eps)
		local x, y = v2val(a), v2val(b)
		eps = type(eps) == "number" and eps or 1e-5
		for _, c in { "x", "y" } do
			local vx, vy = x[c], y[c]
			local m = math.max(1, math.abs(vx), math.abs(vy))
			if not (math.abs(vx - vy) <= eps * m) then return false end
		end
		return true
	end,
}
V2METHODS.lerp = V2METHODS.Lerp
newV2 = valueType("Vector2", function(f, k)
	local v = f.v
	if k == "X" or k == "x" then return v.x end
	if k == "Y" or k == "y" then return v.y end
	if k == "Magnitude" or k == "magnitude" then return vmag(v) end
	if k == "Unit" or k == "unit" then return v2(vnorm(v)) end
	return V2METHODS[k]
end, {
	__add = v2arith(function(a, b) return a + b end),
	__sub = v2arith(function(a, b) return a - b end),
	__mul = v2arith(function(a, b) return a * b end),
	__div = v2arith(function(a, b) return a / b end),
	__idiv = v2arith(function(a, b) return a // b end),
	__unm = function(a) return v2(-v2val(a)) end,
	__eq = function(a, b) return TYPE[a] == TYPE[b] and VAL[a].v == VAL[b].v end,
	__tostring = function(a) local v = VAL[a].v return string.format("%.9g, %.9g", v.x, v.y) end,
})
local V2Lib = {
	new = function(x, y) return v2(vec(num(x or 0), num(y or 0), 0)) end,
	zero = v2(vec(0, 0, 0)),
	one = v2(vec(1, 1, 0)),
	xAxis = v2(vec(1, 0, 0)),
	yAxis = v2(vec(0, 1, 0)),
}

local newRect = valueType("Rect", function(f, k)
	if k == "Min" then return v2(f.lo) end
	if k == "Max" then return v2(f.hi) end
	if k == "Width" then return f.hi.x - f.lo.x end
	if k == "Height" then return f.hi.y - f.lo.y end
	return nil
end, {
	__eq = function(a, b) return TYPE[a] == TYPE[b] and VAL[a].lo == VAL[b].lo and VAL[a].hi == VAL[b].hi end,
	__tostring = function(a)
		local f = VAL[a]
		return string.format("%.9g, %.9g, %.9g, %.9g", f.lo.x, f.lo.y, f.hi.x, f.hi.y)
	end,
})
local RectLib = {}
function RectLib.new(...)
	local n = select("#", ...)
	local a, b, c, d = ...
	local p, q
	if n == 2 then
		p, q = v2val(a), v2val(b)
	elseif n == 0 or n == 4 then
		p, q = vec(num(a or 0), num(b or 0), 0), vec(num(c or 0), num(d or 0), 0)
	else
		return unsupported()
	end
	return newRect({ lo = vector.min(p, q), hi = vector.max(p, q) })
end

local newRay
local function closest(f, p)
	if not isVec(p) then unsupported() end
	local u = vnorm(f.d)
	local t = math.max(0, vdot(p - f.o, u))
	return f.o + u * t
end
newRay = valueType("Ray", function(f, k)
	if k == "Origin" then return f.o end
	if k == "Direction" then return f.d end
	if k == "Unit" then return newRay({ o = f.o, d = vnorm(f.d) }) end
	if k == "ClosestPoint" then return function(self, p) return closest(field(self, "Ray"), p) end end
	if k == "Distance" then return function(self, p) return vmag(p - closest(field(self, "Ray"), p)) end end
	return nil
end, {
	__eq = function(a, b) return TYPE[a] == TYPE[b] and VAL[a].o == VAL[b].o and VAL[a].d == VAL[b].d end,
	__tostring = function(a)
		local f = VAL[a]
		return string.format("{%s}, {%s}", tostring(f.o), tostring(f.d))
	end,
})
local RayLib = {
	new = function(o, d)
		if (o ~= nil and not isVec(o)) or (d ~= nil and not isVec(d)) then unsupported() end
		return newRay({ o = o or O, d = d or O })
	end,
}

-- NumberRange, Color3, Vector3int16/Vector2int16, Number/ColorSequence(Keypoint).
-- tostring uses C++ stream formatting (%g, 6 digits), keypoints and ranges
-- end in a space; float32 fields; int16 wraps around (all as in Studio).
local function g(x) return string.format("%g", x) end
local newNR = valueType("NumberRange", function(f, k)
	if k == "Min" then return f.lo end
	if k == "Max" then return f.hi end
	return nil
end, {
	__eq = function(a, b) return TYPE[a] == TYPE[b] and VAL[a].lo == VAL[b].lo and VAL[a].hi == VAL[b].hi end,
	__tostring = function(a) return g(VAL[a].lo) .. " " .. g(VAL[a].hi) .. " " end,
})
local NRLib = {
	new = function(lo, hi)
		lo = f32(num(lo))
		hi = hi == nil and lo or f32(num(hi))
		if lo > hi then error("NumberRange: invalid range", 0) end
		return newNR({ lo = lo, hi = hi })
	end,
}

local newC3
local function c3(r, g_, b) return newC3({ v = vec(r, g_, b) }) end
local function c3val(c)
	if TYPE[c] ~= "Color3" then unsupported() end
	return VAL[c].v
end
local function toHSV(v)
	local r, gg, b = math.clamp(v.x, 0, 1), math.clamp(v.y, 0, 1), math.clamp(v.z, 0, 1) -- the engine clamps first
	local mx, mn = math.max(r, gg, b), math.min(r, gg, b)
	local d = mx - mn
	local h = 0
	if d ~= 0 then
		if mx == r then
			h = ((gg - b) / d) % 6
		elseif mx == gg then
			h = (b - r) / d + 2
		else
			h = (r - gg) / d + 4
		end
		h /= 6
	end
	return f32(h), f32(mx == 0 and 0 or d / mx), f32(mx)
end
local function byte(x) return math.clamp(math.floor(x * 255 + 0.5), 0, 255) end
local C3METHODS = {
	Lerp = function(a, b, t) local x, y = c3val(a), c3val(b) return newC3({ v = x + (y - x) * num(t) }) end,
	ToHSV = function(a) return toHSV(c3val(a)) end,
	ToHex = function(a) local v = c3val(a) return string.format("%02x%02x%02x", byte(v.x), byte(v.y), byte(v.z)) end,
}
C3METHODS.lerp = C3METHODS.Lerp
newC3 = valueType("Color3", function(f, k)
	if k == "R" or k == "r" then return f.v.x end
	if k == "G" or k == "g" then return f.v.y end
	if k == "B" or k == "b" then return f.v.z end
	return C3METHODS[k]
end, {
	__eq = function(a, b) return TYPE[a] == TYPE[b] and VAL[a].v == VAL[b].v end,
	__tostring = function(a) local v = VAL[a].v return g(v.x) .. ", " .. g(v.y) .. ", " .. g(v.z) end,
})
local function hsv(h, s, v)
	h, s, v = num(h), num(s), num(v)
	h = (h % 1) * 6
	local i = math.floor(h)
	local f = h - i
	local p, q, t = v * (1 - s), v * (1 - s * f), v * (1 - s * (1 - f))
	if i == 0 then return c3(v, t, p) elseif i == 1 then return c3(q, v, p) elseif i == 2 then return c3(p, v, t)
	elseif i == 3 then return c3(p, q, v) elseif i == 4 then return c3(t, p, v) end
	return c3(v, p, q)
end
local C3Lib = {
	new = function(r, g_, b) return c3(num(r or 0), num(g_ or 0), num(b or 0)) end,
	fromRGB = function(r, g_, b) return c3(num(r or 0) / 255, num(g_ or 0) / 255, num(b or 0) / 255) end,
	fromHSV = hsv,
	fromHex = function(s)
		if type(s) ~= "string" then unsupported() end
		local h = string.match(s, "^#?(%x%x%x%x%x%x)$")
		if not h then
			local r, g_, b = string.match(s, "^#?(%x)(%x)(%x)$")
			if not r then unsupported() end
			h = r .. r .. g_ .. g_ .. b .. b
		end
		return c3(tonumber(string.sub(h, 1, 2), 16) / 255, tonumber(string.sub(h, 3, 4), 16) / 255,
			tonumber(string.sub(h, 5, 6), 16) / 255)
	end,
	toHSV = function(c) return toHSV(c3val(c)) end,
}

local function int16(x)
	x = num(x or 0)
	x = x < 0 and math.ceil(x) or math.floor(x)
	return (x + 32768) % 65536 - 32768
end
local function intVector(name, n)
	local new
	local function make(...)
		local t = { ... }
		for i = 1, n do t[i] = int16(t[i]) end
		return new({ c = t })
	end
	local function arith(op)
		return function(a, b)
			if TYPE[a] ~= name or TYPE[b] ~= name then unsupported() end
			local x, y, r = VAL[a].c, VAL[b].c, {}
			for i = 1, n do r[i] = op(x[i], y[i]) end
			return make(table.unpack(r, 1, n))
		end
	end
	local KEYS = { X = 1, Y = 2, Z = n == 3 and 3 or nil, x = 1, y = 2, z = n == 3 and 3 or nil }
	new = valueType(name, function(f, k)
		local i = KEYS[k]
		return i and f.c[i] or nil
	end, {
		__add = arith(function(a, b) return a + b end),
		__sub = arith(function(a, b) return a - b end),
		__mul = arith(function(a, b) return a * b end),
		__div = arith(function(a, b) return a / b end),
		__unm = function(a) local c = VAL[a].c return make(-c[1], -c[2], -(c[3] or 0)) end,
		__eq = function(a, b)
			if TYPE[a] ~= TYPE[b] then return false end
			for i = 1, n do if VAL[a].c[i] ~= VAL[b].c[i] then return false end end
			return true
		end,
		__tostring = function(a) return table.concat(VAL[a].c, ", ", 1, n) end,
	})
	return { new = make }
end

local newNSK = valueType("NumberSequenceKeypoint", function(f, k)
	if k == "Time" then return f.t end
	if k == "Value" then return f.v end
	if k == "Envelope" then return f.e end
	return nil
end, {
	__eq = function(a, b) local x, y = VAL[a], VAL[b] return TYPE[a] == TYPE[b] and x.t == y.t and x.v == y.v and x.e == y.e end,
	__tostring = function(a) local f = VAL[a] return g(f.t) .. " " .. g(f.v) .. " " .. g(f.e) .. " " end,
})
local NSKLib = {
	new = function(t, v, e) return newNSK({ t = f32(num(t)), v = f32(num(v)), e = f32(num(e or 0)) }) end,
}
local newCSK = valueType("ColorSequenceKeypoint", function(f, k)
	if k == "Time" then return f.t end
	if k == "Value" then return f.c end
	return nil
end, {
	__eq = function(a, b) return TYPE[a] == TYPE[b] and VAL[a].t == VAL[b].t and VAL[a].c == VAL[b].c end,
	__tostring = function(a)
		local f = VAL[a]
		local v = VAL[f.c].v
		return g(f.t) .. " " .. g(v.x) .. " " .. g(v.y) .. " " .. g(v.z) .. " 0 "
	end,
})
local CSKLib = {
	new = function(t, c)
		c3val(c)
		return newCSK({ t = f32(num(t)), c = c })
	end,
}
local function sequence(name, kpType, fromValues)
	local new
	new = valueType(name, function(f, k)
		if k == "Keypoints" then return table.clone(f.k) end
		return nil
	end, {
		__eq = function(a, b)
			if TYPE[a] ~= TYPE[b] or #VAL[a].k ~= #VAL[b].k then return false end
			for i, kp in VAL[a].k do if not (kp == VAL[b].k[i]) then return false end end
			return true
		end,
		__tostring = function(a)
			local parts = {}
			for i, kp in VAL[a].k do parts[i] = tostring(kp) end
			return table.concat(parts)
		end,
	})
	return {
		new = function(...)
			local a = ...
			if type(a) == "table" then
				for _, kp in a do if TYPE[kp] ~= kpType then unsupported() end end
				if #a < 2 then unsupported() end
				return new({ k = table.clone(a) })
			end
			return new({ k = fromValues(...) })
		end,
	}
end
local NSLib = sequence("NumberSequence", "NumberSequenceKeypoint", function(a, b)
	b = b == nil and a or b
	return { NSKLib.new(0, a), NSKLib.new(1, b) }
end)
local CSLib = sequence("ColorSequence", "ColorSequenceKeypoint", function(a, b)
	b = b == nil and a or b
	return { CSKLib.new(0, a), CSKLib.new(1, b) }
end)

-- typeof() ignores __type on newproxy userdata: envlog asks here instead
local function typeOf(v)
	if CF[v] then return "CFrame" end
	return TYPE[v]
end

local BC_PALETTE = {
	[1]={"White",242,243,243},
	[2]={"Grey",161,165,162},
	[3]={"Light yellow",249,233,153},
	[5]={"Brick yellow",215,197,154},
	[6]={"Light green (Mint)",194,218,184},
	[9]={"Light reddish violet",232,186,200},
	[11]={"Pastel Blue",128,187,219},
	[12]={"Light orange brown",203,132,66},
	[18]={"Nougat",204,142,105},
	[21]={"Bright red",196,40,28},
	[22]={"Med. reddish violet",196,112,160},
	[23]={"Bright blue",13,105,172},
	[24]={"Bright yellow",245,205,48},
	[25]={"Earth orange",98,71,50},
	[26]={"Black",27,42,53},
	[27]={"Dark grey",109,110,108},
	[28]={"Dark green",40,127,71},
	[29]={"Medium green",161,196,140},
	[36]={"Lig. Yellowich orange",243,207,155},
	[37]={"Bright green",75,151,75},
	[38]={"Dark orange",160,95,53},
	[39]={"Light bluish violet",193,202,222},
	[40]={"Transparent",236,236,236},
	[41]={"Tr. Red",205,84,75},
	[42]={"Tr. Lg blue",193,223,240},
	[43]={"Tr. Blue",123,182,232},
	[44]={"Tr. Yellow",247,241,141},
	[45]={"Light blue",180,210,228},
	[47]={"Tr. Flu. Reddish orange",217,133,108},
	[48]={"Tr. Green",132,182,141},
	[49]={"Tr. Flu. Green",248,241,132},
	[50]={"Phosph. White",236,232,222},
	[100]={"Light red",238,196,182},
	[101]={"Medium red",218,134,122},
	[102]={"Medium blue",110,153,202},
	[103]={"Light grey",199,193,183},
	[104]={"Bright violet",107,50,124},
	[105]={"Br. yellowish orange",226,155,64},
	[106]={"Bright orange",218,133,65},
	[107]={"Bright bluish green",0,143,156},
	[108]={"Earth yellow",104,92,67},
	[110]={"Bright bluish violet",67,84,147},
	[111]={"Tr. Brown",191,183,177},
	[112]={"Medium bluish violet",104,116,172},
	[113]={"Tr. Medi. reddish violet",229,173,200},
	[115]={"Med. yellowish green",199,210,60},
	[116]={"Med. bluish green",85,165,175},
	[118]={"Light bluish green",183,215,213},
	[119]={"Br. yellowish green",164,189,71},
	[120]={"Lig. yellowish green",217,228,167},
	[121]={"Med. yellowish orange",231,172,88},
	[123]={"Br. reddish orange",211,111,76},
	[124]={"Bright reddish violet",146,57,120},
	[125]={"Light orange",234,184,146},
	[126]={"Tr. Bright bluish violet",165,165,203},
	[127]={"Gold",220,188,129},
	[128]={"Dark nougat",174,122,89},
	[131]={"Silver",156,163,168},
	[133]={"Neon orange",213,115,61},
	[134]={"Neon green",216,221,86},
	[135]={"Sand blue",116,134,157},
	[136]={"Sand violet",135,124,144},
	[137]={"Medium orange",224,152,100},
	[138]={"Sand yellow",149,138,115},
	[140]={"Earth blue",32,58,86},
	[141]={"Earth green",39,70,45},
	[143]={"Tr. Flu. Blue",207,226,247},
	[145]={"Sand blue metallic",121,136,161},
	[146]={"Sand violet metallic",149,142,163},
	[147]={"Sand yellow metallic",147,135,103},
	[148]={"Dark grey metallic",87,88,87},
	[149]={"Black metallic",22,29,50},
	[150]={"Light grey metallic",171,173,172},
	[151]={"Sand green",120,144,130},
	[153]={"Sand red",149,121,119},
	[154]={"Dark red",123,46,47},
	[157]={"Tr. Flu. Yellow",255,246,123},
	[158]={"Tr. Flu. Red",225,164,194},
	[168]={"Gun metallic",117,108,98},
	[176]={"Red flip/flop",151,105,91},
	[178]={"Yellow flip/flop",180,132,85},
	[179]={"Silver flip/flop",137,135,136},
	[180]={"Curry",215,169,75},
	[190]={"Fire Yellow",249,214,46},
	[191]={"Flame yellowish orange",232,171,45},
	[192]={"Reddish brown",105,64,40},
	[193]={"Flame reddish orange",207,96,36},
	[194]={"Medium stone grey",163,162,165},
	[195]={"Royal blue",70,103,164},
	[196]={"Dark Royal blue",35,71,139},
	[198]={"Bright reddish lilac",142,66,133},
	[199]={"Dark stone grey",99,95,98},
	[200]={"Lemon metalic",130,138,93},
	[208]={"Light stone grey",229,228,223},
	[209]={"Dark Curry",176,142,68},
	[210]={"Faded green",112,149,120},
	[211]={"Turquoise",121,181,181},
	[212]={"Light Royal blue",159,195,233},
	[213]={"Medium Royal blue",108,129,183},
	[216]={"Rust",144,76,42},
	[217]={"Brown",124,92,70},
	[218]={"Reddish lilac",150,112,159},
	[219]={"Lilac",107,98,155},
	[220]={"Light lilac",167,169,206},
	[221]={"Bright purple",205,98,152},
	[222]={"Light purple",228,173,200},
	[223]={"Light pink",220,144,149},
	[224]={"Light brick yellow",240,213,160},
	[225]={"Warm yellowish orange",235,184,127},
	[226]={"Cool yellow",253,234,141},
	[232]={"Dove blue",125,187,221},
	[268]={"Medium lilac",52,43,117},
	[301]={"Slime green",80,109,84},
	[302]={"Smoky grey",91,93,105},
	[303]={"Dark blue",0,16,176},
	[304]={"Parsley green",44,101,29},
	[305]={"Steel blue",82,124,174},
	[306]={"Storm blue",51,88,130},
	[307]={"Lapis",16,42,220},
	[308]={"Dark indigo",61,21,133},
	[309]={"Sea green",52,142,64},
	[310]={"Shamrock",91,154,76},
	[311]={"Fossil",159,161,172},
	[312]={"Mulberry",89,34,89},
	[313]={"Forest green",31,128,29},
	[314]={"Cadet blue",159,173,192},
	[315]={"Electric blue",9,137,207},
	[316]={"Eggplant",123,0,123},
	[317]={"Moss",124,156,107},
	[318]={"Artichoke",138,171,133},
	[319]={"Sage green",185,196,177},
	[320]={"Ghost grey",202,203,209},
	[321]={"Lilac",167,94,155},
	[322]={"Plum",123,47,123},
	[323]={"Olivine",148,190,129},
	[324]={"Laurel green",168,189,153},
	[325]={"Quill grey",223,223,222},
	[327]={"Crimson",151,0,0},
	[328]={"Mint",177,229,166},
	[329]={"Baby blue",152,194,219},
	[330]={"Carnation pink",255,152,220},
	[331]={"Persimmon",255,89,89},
	[332]={"Maroon",117,0,0},
	[333]={"Gold",239,184,56},
	[334]={"Daisy orange",248,217,109},
	[335]={"Pearl",231,231,236},
	[336]={"Fog",199,212,228},
	[337]={"Salmon",255,148,148},
	[338]={"Terra Cotta",190,104,98},
	[339]={"Cocoa",86,36,36},
	[340]={"Wheat",241,231,199},
	[341]={"Buttermilk",254,243,187},
	[342]={"Mauve",224,178,208},
	[343]={"Sunrise",212,144,189},
	[344]={"Tawny",150,85,85},
	[345]={"Rust",143,76,42},
	[346]={"Cashmere",211,190,150},
	[347]={"Khaki",226,220,188},
	[348]={"Lily white",237,234,234},
	[349]={"Seashell",233,218,218},
	[350]={"Burgundy",136,62,62},
	[351]={"Cork",188,155,93},
	[352]={"Burlap",199,172,120},
	[353]={"Beige",202,191,163},
	[354]={"Oyster",187,179,178},
	[355]={"Pine Cone",108,88,75},
	[356]={"Fawn brown",160,132,79},
	[357]={"Hurricane grey",149,137,136},
	[358]={"Cloudy grey",171,168,158},
	[359]={"Linen",175,148,131},
	[360]={"Copper",150,103,102},
	[361]={"Medium brown",86,66,54},
	[362]={"Bronze",126,104,63},
	[363]={"Flint",105,102,92},
	[364]={"Dark taupe",90,76,66},
	[365]={"Burnt Sienna",106,57,9},
	[1001]={"Institutional white",248,248,248},
	[1002]={"Mid gray",205,205,205},
	[1003]={"Really black",17,17,17},
	[1004]={"Really red",255,0,0},
	[1005]={"Deep orange",255,176,0},
	[1006]={"Alder",180,128,255},
	[1007]={"Dusty Rose",163,75,75},
	[1008]={"Olive",193,190,66},
	[1009]={"New Yeller",255,255,0},
	[1010]={"Really blue",0,0,255},
	[1011]={"Navy blue",0,32,96},
	[1012]={"Deep blue",33,84,185},
	[1013]={"Cyan",4,175,236},
	[1014]={"CGA brown",170,85,0},
	[1015]={"Magenta",170,0,170},
	[1016]={"Pink",255,102,204},
	[1017]={"Deep orange",255,175,0},
	[1018]={"Teal",18,238,212},
	[1019]={"Toothpaste",0,255,255},
	[1020]={"Lime green",0,255,0},
	[1021]={"Camo",58,125,21},
	[1022]={"Grime",127,142,100},
	[1023]={"Lavender",140,91,159},
	[1024]={"Pastel light blue",175,221,255},
	[1025]={"Pastel orange",255,201,201},
	[1026]={"Pastel violet",177,167,255},
	[1027]={"Pastel blue-green",159,243,233},
	[1028]={"Pastel green",204,255,204},
	[1029]={"Pastel yellow",255,255,204},
	[1030]={"Pastel brown",255,204,153},
	[1031]={"Royal purple",98,37,209},
	[1032]={"Hot pink",255,0,191},
}
local BC_BYNAME = {}
for __n, __e in BC_PALETTE do if BC_BYNAME[__e[1]] == nil then BC_BYNAME[__e[1]] = __n end end
local newBC
newBC = valueType("BrickColor", function(f, k)
	if k == "Number" then return f.n end
	if k == "Name" then return f.name end
	if k == "Color" then return c3(f.r / 255, f.g / 255, f.b / 255) end
	if k == "r" then return f32(f.r / 255) end
	if k == "g" then return f32(f.g / 255) end
	if k == "b" then return f32(f.b / 255) end
	return nil
end, {
	__eq = function(a, b) return TYPE[a] == TYPE[b] and VAL[a].n == VAL[b].n end,
	__tostring = function(a) return VAL[a].name end,
})
local function bcNum(n)
	local e = BC_PALETTE[n]
	if not e then n = 194; e = BC_PALETTE[194] end
	return newBC({ n = n, name = e[1], r = e[2], g = e[3], b = e[4] })
end
local function bcName(nm)
	local n = BC_BYNAME[nm]
	if not n then return bcNum(194) end
	return bcNum(n)
end
local function bcRGB(r, g_, b)
	r, g_, b = num(r) * 255, num(g_) * 255, num(b) * 255
	local best, bestd
	for n, e in BC_PALETTE do
		local dr, dg, db = e[2] - r, e[3] - g_, e[4] - b
		local d = dr * dr + dg * dg + db * db
		if not bestd or d < bestd or (d == bestd and n < best) then bestd, best = d, n end
	end
	return bcNum(best)
end
local BCLib = {
	new = function(a, b, c)
		if type(a) == "string" then return bcName(a) end
		if b ~= nil then return bcRGB(a, b, c) end
		return bcNum(num(a))
	end,
	White = function() return bcNum(1) end,
	Gray = function() return bcNum(194) end,
	DarkGray = function() return bcNum(199) end,
	Black = function() return bcNum(26) end,
	Red = function() return bcNum(21) end,
	Yellow = function() return bcNum(24) end,
	Green = function() return bcNum(28) end,
	Blue = function() return bcNum(23) end,
	palette = function(i) i = num(i); local keys = {}; for n in BC_PALETTE do keys[#keys+1]=n end; table.sort(keys); local e = keys[(i % #keys) + 1]; return bcNum(e) end,
	random = function() return bcNum(1) end,
}

return {
	UNSUPPORTED = UNSUPPORTED,
	BrickColor = BCLib,
	typeOf = typeOf,
	CFrame = lib,
	UDim = UDimLib,
	UDim2 = UDim2Lib,
	Path2DControlPoint = CPLib,
	Vector2 = V2Lib,
	Rect = RectLib,
	Ray = RayLib,
	NumberRange = NRLib,
	Color3 = C3Lib,
	Vector3int16 = intVector("Vector3int16", 3),
	Vector2int16 = intVector("Vector2int16", 2),
	NumberSequenceKeypoint = NSKLib,
	ColorSequenceKeypoint = CSKLib,
	NumberSequence = NSLib,
	ColorSequence = CSLib,
}
