--!nocheck
-- Regression test for core/structure.py `lower_fors` (the for/forin -> primitive
-- lowering that lets state_machine emit functions with for-loops, deployed
-- 2026-10-18 to recover h2's 271 unstructured jumps).
--
-- It checks the LOWERING FORMULAS against real Luau for-loops, which is the
-- correctness core of the CFG transform:
--   numeric  for v=a,b,c do ... end
--     == v=a; while (c>0 and v<=b) or (c<=0 and v>=b) do ...; v=v+c end
--   generic  for vars in explist do ... end
--     == f,s,ctrl=explist; while true do vars=f(s,ctrl); if vars1==nil then break end; ctrl=vars1; ... end
--
-- Run:  bin/luau tests/test_for_lowering.luau   (expects "ALL_FORMULAS_OK")

local fails = 0
local function eq(a, b)
	if #a ~= #b then return false end
	for i = 1, #a do if a[i] ~= b[i] then return false end end
	return true
end

-- numeric for, integer bounds/steps (incl. negative step, empty ranges)
math.randomseed(1)
for _ = 1, 200000 do
	local a = math.random(-20, 20)
	local b = math.random(-20, 20)
	local c = math.random(-5, 5); if c == 0 then c = 1 end
	local r1 = {}
	for v = a, b, c do r1[#r1 + 1] = v; if #r1 > 1000 then break end end
	local r2 = {}
	do local v = a while (c > 0 and v <= b) or (c <= 0 and v >= b) do r2[#r2 + 1] = v; if #r2 > 1000 then break end; v = v + c end end
	if not eq(r1, r2) then fails += 1; if fails <= 5 then print("NUMFAIL", a, b, c, #r1, #r2) end end
end
print("numeric-for (int) fails:", fails)

-- numeric for, float bounds/steps
math.randomseed(2)
for _ = 1, 50000 do
	local a = math.random() * 10 - 5
	local b = math.random() * 10 - 5
	local c = (math.random() * 4 - 2); if math.abs(c) < 0.01 then c = 0.5 end
	local r1 = {}
	for v = a, b, c do r1[#r1 + 1] = v; if #r1 > 500 then break end end
	local r2 = {}
	do local v = a while (c > 0 and v <= b) or (c <= 0 and v >= b) do r2[#r2 + 1] = v; if #r2 > 500 then break end; v = v + c end end
	if not eq(r1, r2) then fails += 1; if fails <= 10 then print("FLOATFAIL", a, b, c, #r1, #r2) end end
end
print("after float, total fails:", fails)

-- generic for (ipairs / pairs)
local function test_forin(mk)
	local tbl = { 10, 20, 30, 40 }
	local r1 = {}
	for k, v in mk(tbl) do r1[#r1 + 1] = tostring(k) .. "=" .. tostring(v) end
	local r2 = {}
	do
		local f, s, ctrl = mk(tbl)
		while true do
			local k, v = f(s, ctrl)
			if k == nil then break end
			ctrl = k
			r2[#r2 + 1] = tostring(k) .. "=" .. tostring(v)
		end
	end
	return eq(r1, r2)
end
local forin_ok = test_forin(ipairs) and test_forin(pairs)
print("forin (ipairs/pairs) ok:", forin_ok)

print((fails == 0 and forin_ok) and "ALL_FORMULAS_OK" or "FORMULA_ISSUES")
