local flag = type(54179540) == "vector"
local n = 776499227
local n2 = 1117089562
local n3 = 257839108
local n4 = 0

local function fn(arg, arg2, arg3, arg4)
	bit32.bxor(bit32.bxor(arg4, 0), 3073886940)
	local n5 = 846399189
	n4 = (n4 + (arg2 and 1 or 0)) % 2147483647
	local v = table.pack(bit32.band(n5, 4294967295))
	local v2 = table.pack(bit32.band(v[1], 65535))
	bit32.bxor(bit32.band(v2[1] * 50323 + bit32.lshift(bit32.band(v2[1] * 0 + bit32.rshift(v[1], 16) * 50323, 65535), 16), 4294967295), 993724058)
	return arg2
end

local n5 = 0

while true do
	n5 += 1

	if n5 > 5 then
		break
	else
		n = bit32.bxor(n, 4158540124)
		if not (fn(24549923, nil, 2, 215282175) and fn(75075919, true, 2, 215282175)) then
			continue
		end
		break
	end
end

local v = print
bit32.lshift(n2, 18)
v("CHECKSUM:", n4)
