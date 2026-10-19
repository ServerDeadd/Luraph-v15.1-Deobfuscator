#!/usr/bin/env python3
"""Unit test for the offline datatype models in runtime/datatypes.luau, focused
on the 2026-10-18 additions/fixes:
  * BrickColor model (Number/Name/Color for the named colors + new(num|name)),
    values verified against real Roblox Studio.
  * the f32-scale rounding principle behind the Path2D `resolve` fix
    (UDim.Scale is f32 in the engine, so round BEFORE multiplying).

Loads datatypes.luau standalone (it only needs the `vector`/`buffer`/stdlib
globals) and asserts in luau. Run: python3 tests/test_datatypes.py
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DTYPES = os.path.join(ROOT, "runtime", "datatypes.luau")
LUAU = os.path.join(ROOT, "bin", "luau.exe" if os.name == "nt" else "luau")

TEST_BODY = r"""
local DT = _DT
local bad = {}
local function chk(name, got, want)
    if got ~= want then bad[#bad + 1] = name .. " got=" .. tostring(got) .. " want=" .. tostring(want) end
end
local fb = buffer.create(4)
local function f32(x) buffer.writef32(fb, 0, x); return buffer.readf32(fb, 0) end

-- BrickColor (values verified in Studio 2026-10-18)
local bc = DT.BrickColor
chk("White.Number", bc.White().Number, 1)
chk("White.Name", bc.White().Name, "White")
chk("Gray.Number", bc.Gray().Number, 194)
chk("Gray.Name", bc.Gray().Name, "Medium stone grey")
chk("DarkGray.Number", bc.DarkGray().Number, 199)
chk("DarkGray.Name", bc.DarkGray().Name, "Dark stone grey")
chk("Black.Number", bc.Black().Number, 26)
chk("Red.Name", bc.Red().Name, "Bright red")
chk("Yellow.Number", bc.Yellow().Number, 24)
chk("Green.Name", bc.Green().Name, "Dark green")
chk("Blue.Number", bc.Blue().Number, 23)
chk("new(194).Name", bc.new(194).Name, "Medium stone grey")
chk("new(bad num).Name", bc.new(999999).Name, "Medium stone grey")  -- invalid -> default
chk("new('Really red').Number", bc.new("Really red").Number, 1004)
chk("tostring(White)", tostring(bc.White()), "White")
chk("White.Color.R", bc.White().Color.R, f32(242 / 255))
chk("White.Color.G", bc.White().Color.G, f32(243 / 255))
chk("Black.Color.B", bc.Black().Color.B, f32(53 / 255))

-- CFrame.identity + Vector2 constants
chk("CFrame.identity", tostring(DT.CFrame.identity), "0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1")
chk("Vector2.one", tostring(DT.Vector2.one), "1, 1")

-- tostring of the common datatypes, verified against Studio 2026-10-18
chk("Color3", tostring(DT.Color3.new(0.1, 0.2, 0.3)), "0.1, 0.2, 0.3")
chk("Color3.fromRGB", tostring(DT.Color3.fromRGB(10, 20, 30)), "0.0392157, 0.0784314, 0.117647")
chk("Color3.ToHex", DT.Color3.new(0.1, 0.2, 0.3):ToHex(), "1a334d")
chk("UDim", tostring(DT.UDim.new(0.5, 10)), "0.5, 10")
chk("UDim2", tostring(DT.UDim2.new(0.5, 10, 0.25, 5)), "{0.5, 10}, {0.25, 5}")
chk("Rect", tostring(DT.Rect.new(1, 2, 3, 4)), "1, 2, 3, 4")
chk("NumberRange2", tostring(DT.NumberRange.new(1, 2)), "1 2 ")
chk("Vector3int16", tostring(DT.Vector3int16.new(1, 2, 3)), "1, 2, 3")
chk("NumberSequence", tostring(DT.NumberSequence.new(0.5)), "0 0.5 0 1 0.5 0 ")
chk("NSKeypoint", tostring(DT.NumberSequenceKeypoint.new(0.1, 0.2, 0.3)), "0.1 0.2 0.3 ")
chk("CSKeypoint", tostring(DT.ColorSequenceKeypoint.new(0.5, DT.Color3.new(1, 0, 0))), "0.5 1 0 0 0 ")
chk("V2.Magnitude(3,4)", DT.Vector2.new(3, 4).Magnitude, 5)
-- Vector2 stores f32 components (3rd arg ignored)
local v = DT.Vector2.new(0.1395949425122287, 0.31729449003873411, 0.22774256429534945)
chk("Vector2 X f32", v.X, f32(0.1395949425122287))
chk("Vector2 Y f32", v.Y, f32(0.31729449003873411))

-- the Path2D resolve f32 principle: f32(f32(scale)*W)+offset == engine value
-- (scale 0.87769402574956845, W 380, offset 169 -> 502.52371215820312 in Studio)
chk("resolve f32", f32(f32(f32(0.87769402574956845) * 380) + 169), 502.52371215820312)

if #bad == 0 then
    print("DATATYPES_OK")
else
    for _, m in ipairs(bad) do print("FAIL: " .. m) end
    print("DATATYPES_FAIL " .. #bad)
end
"""


def main():
    if not os.path.exists(LUAU):
        sys.exit("[!] luau not found at %s" % LUAU)
    dt = open(DTYPES, encoding="latin-1").read()
    wrapped = "local _DT = (function()\n" + dt + "\nend)()\n" + TEST_BODY
    import tempfile
    with tempfile.NamedTemporaryFile("w", suffix=".luau", delete=False, encoding="latin-1", newline="\n") as f:
        f.write(wrapped)
        path = f.name
    try:
        r = subprocess.run([LUAU, path], capture_output=True, text=True)
    finally:
        os.remove(path)
    out = (r.stdout or "") + (r.stderr or "")
    print(out.strip())
    sys.exit(0 if "DATATYPES_OK" in out else 1)


if __name__ == "__main__":
    main()
