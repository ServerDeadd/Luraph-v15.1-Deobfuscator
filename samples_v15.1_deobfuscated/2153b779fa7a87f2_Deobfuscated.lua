local flag = type(0) == "buffer"
local n = 586209937
local n2 = 0
local n3 = 3676792201
local n4 = 555795890

local obj = setmetatable({}, { __index = function()
	local flag2 = bit32.bxor(bit32.bxor(n4, 0), 137613777) == 67171384
	n2 += 1
	local n5 = 436894725

	return function()
	end
end })

print("--")
local hmm = obj.hmm

for i = 1, 5 do
	hmm(1)
end

assert(n2 == 1)
