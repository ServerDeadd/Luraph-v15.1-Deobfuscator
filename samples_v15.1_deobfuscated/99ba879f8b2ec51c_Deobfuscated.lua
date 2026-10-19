local Players, Workspace, RunService, ReplicatedStorage, UserInputService, CoreGui, GuiService, localPlayer, fn, fn2
local fn3, v, tbl, n, v2, v3

do
	local TweenService, HttpService, mouse, currentCamera, cider, tbl2, v4, n2

	do
		local v5
		v5 = shared
		local cider2
		cider2 = { Globals = { Key = "CIDER", ["Config Mode"] = "File" } }
		local main

		main = {
			["Silent Aim"] = { Selection = "Target" },
			Triggerbot = { Selection = "Target" },
			Brand = {
				Enabled = true,
				Feature = Color3.fromRGB(255, 255, 255),
				Accent = Color3.fromRGB(100, 180, 255),
				Position = "Low Center",
			},
		}

		do
			local checks = {
				Targeting = {
					Knocked = true,
					Grabbed = true,
					Vehicle = true,
					Visible = false,
					Tool = false,
					["Self Knocked"] = false,
					Crew = true,
				},
				Aimbot = {
					Knocked = true,
					Grabbed = true,
					Vehicle = true,
					Visible = true,
					Tool = false,
					["Self Knocked"] = false,
					Crew = true,
				},
				["Silent Aim"] = {
					Knocked = true,
					Grabbed = true,
					Vehicle = true,
					Visible = true,
					Tool = false,
					["Self Knocked"] = false,
					Crew = true,
				},
			}

			local v6 = table.pack(50133)
			local v7 = bit32.band(57936 * v6[1] + bit32.lshift(bit32.band(3535254720 + 4569 * v6[1], 65535), 16), 4294967295)

			checks.Triggerbot = {
				Knocked = true,
				Grabbed = true,
				Vehicle = true,
				Visible = true,
				Tool = false,
				["Self Knocked"] = false,
				Crew = true,
			}

			main.Checks = checks
		end

		local fov, n3

		do
			local binds = { Target = "C", Aimbot = "C", ESP = "B", ["Walk Speed"] = "V" }
			local v6 = table.pack(bit32.band(1082866915, 4294967295))
			local v7 = table.pack(bit32.band(v6[1], 65535))
			local v8 = bit32.band(v7[1] * 39380 + bit32.lshift(bit32.band(v7[1] * 0 + bit32.rshift(v6[1], 16) * 39380, 65535), 16), 4294967295)
			binds["Jump Power"] = "Z"
			binds["Double Tap"] = "Y"
			binds.Sorter = "U"
			binds["Anti Future"] = "N"
			binds["Panic Ground"] = "X"
			main.Binds = binds
			local n4 = (v8 - 371198102) // 88

			main["Gun Whitelist"] = {
				Silent = { "[Double-Barrel SG]", "[Revolver]", "[TacticalShotgun]" },
				Aimbot = { "[Double-Barrel SG]", "[Revolver]", "[TacticalShotgun]" },
				Triggerbot = { "[Double-Barrel SG]", "[Revolver]", "[TacticalShotgun]" },
			}

			fov = {}

			local silent = {
				Options = "2D",
				Width = { 1, 1 },
				Height = { 1, 1 },
				["3D"] = { Width = 6, Height = 6, Depth = 10 },
			}

			local visualize = {}
			local v9 = bit32.bor(n4 // 13, 371198102)
			visualize.Enabled = false
			visualize.Color = Color3.fromRGB(255, 255, 255)
			silent.Visualize = visualize
			fov.Silent = silent
			n3 = v9 // 193
		end

		local aimbot
		aimbot = { Options = "2D", Width = { 1, 1 } }
		local triggerbot, tbl3, n4, aimbot2, v6, triggerbot2, v7, v8

		do
			local height = {}
			local v9 = table.pack(bit32.band(n3, 4294967295))
			local v10 = table.pack(36641)
			local v11 = table.pack(553)
			local v12 = table.pack(bit32.band(v9[1], 65535))
			local v13 = bit32.band(v10[1] * v12[1] + bit32.lshift(bit32.band(v10[1] * bit32.rshift(v9[1], 16) + v11[1] * v12[1], 65535), 16), 4294967295)
			height[1] = 1
			height[2] = 1
			aimbot.Height = height
			local tbl4 = { Width = 6 }
			local v14 = bit32.lshift(v13, 18)
			tbl4.Height = 6
			tbl4.Depth = 10
			aimbot["3D"] = tbl4
			local n5 = n3 + 4137528241
			aimbot.Visualize = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) }
			fov.Aimbot = aimbot
			triggerbot = { Options = "2D", Width = { 1, 1 }, Height = { 1, 1 } }
			local tbl5 = {}
			local v15 = bit32.bor(n5 - 829191077, 18064885)
			tbl5.Width = 6
			tbl5.Height = 6
			tbl5.Depth = 10
			triggerbot["3D"] = tbl5
			local n6 = v14 // n5 // 18064885
			local visualize = { Enabled = false }
			local v16 = table.pack(bit32.band(v15, 4294967295))
			local v17 = table.pack(bit32.band(v16[1], 65535))
			local v18 = bit32.band(v17[1] * 62167 + bit32.lshift(bit32.band(v17[1] * 0 + bit32.rshift(v16[1], 16) * 62167, 65535), 16), 4294967295)
			visualize.Color = Color3.fromRGB(255, 255, 255)
			local v19 = bit32.bor(n6, 3287106713)
			triggerbot.Visualize = visualize
			fov.Triggerbot = triggerbot
			main.FOV = fov
			cider2.Main = main

			tbl3 = {
				Enabled = true,
				["Max Range"] = math.huge,
				["Closest Point"] = { Enabled = true, Mode = "Scaled", Scale = 3 },
			}

			local v20 = bit32.bxor(v18, 4294967295)
			local tbl6 = { Enabled = false }
			local v21 = Color3
			local v22 = bit32.bxor(v19 + 3987430786, 18064885)
			tbl6.Color = v21.fromRGB(255, 85, 85)
			tbl6.Thickness = 0.5
			tbl3["Target Tracer"] = tbl6
			tbl3["Target Part"] = { Part = "Head" }
			local prediction = {}
			local v23 = bit32.band(v20, 3261482160)
			prediction.Enabled = false
			local values = { X = 0.13 }
			local v24 = bit32.band(v22, 997121901)
			values.Y = 0.13
			values.Z = 0.13
			prediction.Values = values
			tbl3.Prediction = prediction
			local tbl7 = {}
			local n7 = v23 // bit32.bxor(155375421, 0)
			tbl7.Enabled = true
			tbl7["Wall Check"] = true
			tbl7["Limit To Weapon Range"] = true
			local v25 = bit32.bor(v24, n7)
			tbl3["Auto Shoot"] = tbl7
			tbl3["Offscreen Targeting"] = { Enabled = true }
			local future = { Enabled = true }
			local v26 = bit32.band(v25, n7)
			future.Lure = true
			local v27 = bit32.rshift(n7, 29)
			future.Pistols = { Values = { X = 0.023, Y = 0.023, Z = 0.023 } }
			local v28 = bit32.band(v26, 3203584560)
			future.Shotguns = { Values = { X = 0.018, Y = 0.018, Z = 0.018 } }
			local others = {}
			local v29 = bit32.bor(v27, 970165267)
			local values2 = { X = 0.013, Y = 0.013 }
			local n8 = v28 * bit32.bxor(155375421, 0)
			values2.Z = 0.013
			others.Values = values2
			future.Others = others
			tbl3.Future = future
			cider2["Silent Aim"] = tbl3
			local n9 = v29 - 1355798264
			n4 = n8 - n9

			aimbot2 = {
				Enabled = true,
				Mode = "Toggle",
				["Max Range"] = math.huge,
				["Target Part"] = { Part = "Head" },
			}

			local tbl8 = { Enabled = true }
			local v30 = bit32.bor(n9, n4)
			tbl8.Mode = "Scaled"
			tbl8.Scale = 3
			aimbot2["Closest Point"] = tbl8
			local smoothing = { Enabled = true, X = 0.1, Y = 0.1, Z = 0.1 }
			local v31 = bit32.bxor(n4, 2582068718)
			smoothing.Easing = { In = "Linear", Out = "InOut" }
			aimbot2.Smoothing = smoothing
			local prediction2 = {}
			local v32 = bit32.bxor(155375421, 129564116)
			prediction2.Enabled = false
			prediction2.Values = { X = 0.13, Y = 0.13, Z = 0.13 }
			v6 = bit32.lshift(v30 // n4 * 48644, 10)
			aimbot2.Prediction = prediction2
			cider2.Aimbot = aimbot2
			triggerbot2 = { Enabled = false, ["Max Range"] = math.huge, ["Limit To Weapon Range"] = true }
			local v33 = table.pack(bit32.band(bit32.bxor(v32, 0), 4294967295))
			local v34 = table.pack(bit32.band(v33[1], 65535))
			v7 = bit32.band(v34[1] * 65165 + bit32.lshift(bit32.band(v34[1] * 0 + bit32.rshift(v33[1], 16) * 65165, 65535), 16), 4294967295)
			v8 = bit32.bxor(v32, 341995783)
		end

		triggerbot2.Delay = 0
		triggerbot2.Bind = { Key = "MouseButton1", Mode = "Keybind", Type = "Hold" }
		triggerbot2["Trigger Mode"] = "FOV"
		triggerbot2.Prediction = { Enabled = false, Values = { X = 0.13, Y = 0.13, Z = 0.13 } }
		local modifications, v9, tbl4, tbl5, weapons, n5, others, v10

		do
			local tbl6 = {}
			local v11 = table.pack(bit32.band(bit32.band(v7, 122494949), 4294967295))
			local v12 = table.pack(bit32.band(v11[1], 65535))
			local v13 = bit32.band(v12[1] * 47002 + bit32.lshift(bit32.band(v12[1] * 0 + bit32.rshift(v11[1], 16) * 47002, 65535), 16), 4294967295)
			tbl6.Enabled = true
			triggerbot2["Offscreen Targeting"] = tbl6
			cider2.Triggerbot = triggerbot2
			local n6 = v6 // v7 * 64548 * 349

			cider2["Name ESP"] = {
				Enabled = true,
				Color = Color3.fromRGB(255, 255, 255),
				["Target Color"] = Color3.fromRGB(100, 180, 255),
				["Text Size"] = 13,
				Font = "SourceSansBold",
			}

			local v14 = bit32.bxor(v13, 4294967295)

			local tbl7 = {
				Enabled = true,
				Position = "Bottom",
				["Show Armor"] = true,
				["Health Color"] = Color3.fromRGB(90, 255, 90),
			}

			local v15 = Color3
			local v16 = bit32.band(v14, 3518639819)
			tbl7["Armor Color"] = v15.fromRGB(115, 115, 255)
			cider2["Health Bar"] = tbl7
			modifications = {}
			local tbl8 = {}
			local v17 = bit32.bxor(n6, 4294967295)
			tbl8.Enabled = true
			tbl8.Mode = "Toggle"
			local n7 = v16 + bit32.bxor(v8, 0)
			local tbl9 = { Enabled = true, Shotguns = { Enabled = true } }
			local pistols = {}
			local v18 = bit32.rshift(v17, 7)
			pistols.Enabled = true
			tbl9.Pistols = pistols
			tbl9.Others = { Enabled = false }
			tbl8["Weapon Configs"] = tbl9
			modifications["Double Tap"] = tbl8
			local v19 = bit32.bxor(n7, 1562697695)
			local n8 = v18 // v19
			local tbl10 = { Enabled = true, Value = 0.2 }
			local randomizer = { Enabled = false }
			v9 = bit32.bxor(v8, 371067416)
			local v20 = bit32.band(v19, n8)
			randomizer.Min = 0.3
			randomizer.Max = 0.5
			tbl10.Randomizer = randomizer
			local n9 = n8 - v20
			tbl10["Spread Angles"] = { Enabled = false, Game = "zee" }
			modifications["Spread Modifications"] = tbl10
			local tbl11 = {}
			local v21 = bit32.band(v20, n9)
			tbl11["No Recoil"] = true
			local n10 = v21 + n9
			tbl11["Range Enhancer"] = { Enabled = true, Value = 16, ["Use Hooks"] = true }
			modifications["Misc Gun Modifications"] = tbl11
			tbl4 = {}
			local tbl12 = {}
			local v22 = bit32.bor(n9, n10)
			tbl12.Enabled = false
			tbl4["Inf Range"] = tbl12
			tbl4.Wallbang = { Enabled = false }
			local n11 = v22 + n10
			tbl5 = { Enabled = true }
			weapons = {}
			local v23 = bit32.band(n10, 3918772567)
			weapons.Shotguns = { Enabled = true, Mode = "full" }
			local pistols2 = {}
			n5 = n11 // bit32.bxor(v9, 0)
			pistols2.Enabled = true
			pistols2.Mode = "full"
			weapons.Pistols = pistols2
			others = {}
			v10 = bit32.band(v23, n5)
		end

		others.Enabled = true
		local v11 = table.pack(bit32.band(v9, 4294967295))
		local v12 = table.pack(bit32.band(v11[1], 65535))
		local n6

		do
			local n7 = bit32.band(40819 * v12[1] + bit32.lshift(bit32.band(40819 * bit32.rshift(v11[1], 16) + 7801 * v12[1], 65535), 16), 4294967295) + 193716594
			local v13 = table.pack(bit32.band(bit32.bor(v9, 510302278), 4294967295))
			local v14 = table.pack(bit32.band(v13[1], 65535))
			local v15 = bit32.band(24718 * v14[1] + bit32.lshift(bit32.band(24718 * bit32.rshift(v13[1], 16) + 57734 * v14[1], 65535), 16), 4294967295)
			local v16 = table.pack(bit32.band(bit32.band(v9, 510302278), 4294967295))
			local v17 = table.pack(bit32.band(v16[1], 65535))
			n6 = n7 + v15 + bit32.band(24716 * v17[1] + bit32.lshift(bit32.band(24716 * bit32.rshift(v16[1], 16) + 57734 * v17[1], 65535), 16), 4294967295)
		end

		others.Mode = "full"
		weapons.Others = others
		tbl5.Weapons = weapons
		tbl4["Damage Modifier"] = tbl5
		modifications["Das Hood"] = tbl4
		local tbl6
		tbl6 = { Enabled = true }
		local v13
		local v14 = bit32.bxor(n6, 0)
		v13 = bit32.band(n5, v14)
		tbl6.Delay = 0
		local n7, v15

		do
			local tbl7 = {}
			local v16 = bit32.bor(v10 * 6, v13)
			tbl7.Enabled = false
			tbl7.Shotguns = { Delay = 0.05 }
			tbl7.Pistols = { Delay = 0.01 }
			local others2 = {}
			n7 = v16 // bit32.bxor(n6, 0)
			others2.Delay = 0.02
			tbl7.Others = others2
			v15 = bit32.bxor(n6, 495227083)
			tbl6["Weapon Configs"] = tbl7
		end

		modifications["Delay Changer"] = tbl6
		cider2.Modifications = modifications
		local movement
		movement = { ["Anti Trip"] = true, ["No Jump Cooldown"] = true }
		local tbl7
		tbl7 = { Enabled = true, Mode = "Number", Values = { Number = 600, Multiplier = 6.2 } }
		local conditions
		conditions = {}
		local n8

		do
			local normal = { Enabled = true }
			local v16 = bit32.bor(n7, 612840520)
			normal.Multiplier = 1
			conditions.Normal = normal
			local knife = {}
			local v17 = bit32.bxor((v13 - n7) // 5, 4294967295)
			knife.Enabled = true
			knife.Multiplier = 1
			conditions.Knife = knife
			local reload = { Enabled = true }
			n8 = v17 + bit32.bxor(v15, 0)
			reload.Multiplier = 1
			conditions.Reload = reload
			local shooting = { Enabled = true }
			local v18 = bit32.bxor(v16, n8)
			shooting.Multiplier = 1
			conditions.Shooting = shooting
			local tbl8 = {}
			local n9 = v18 - bit32.bxor(v15, 0)
			tbl8.Enabled = true
			tbl8.Multiplier = 1
			conditions["Low Health"] = tbl8
		end

		tbl7.Conditions = conditions
		movement["Speed Modifications"] = tbl7
		local tbl8
		tbl8 = { Enabled = true }
		local conditions2, v16, utilities, tbl9, skins, n9, n10

		do
			local v17 = bit32.bxor(v15, 0)
			local v18 = bit32.bxor(n8, v17)
			tbl8["Spiderman Mode"] = false
			tbl8.Mode = "Number"
			local values = {}
			local v19 = bit32.bxor(v15, 0)
			values.Number = 300
			values.Multiplier = 4
			tbl8.Values = values
			conditions2 = {}
			local normal = {}
			local n11 = v18 - bit32.bxor(v15, 0)
			normal.Enabled = true
			v16 = bit32.bxor(v15, 11615346)
			normal.Multiplier = 1
			conditions2.Normal = normal
			local v20 = bit32.bor(v19, n11)
			conditions2.Knife = { Enabled = true, Multiplier = 1 }
			local reload = { Enabled = true }
			local v21 = bit32.bxor(v16, 0)
			local v22 = bit32.bor(n11, v21)
			reload.Multiplier = 1
			conditions2.Reload = reload
			local shooting = {}
			local n12 = v20 + bit32.bxor(v16, 0)
			shooting.Enabled = true
			shooting.Multiplier = 1
			conditions2.Shooting = shooting
			local tbl10 = { Enabled = true }
			local v23 = bit32.lshift(v22, 14)
			tbl10.Multiplier = 1
			conditions2["Low Health"] = tbl10
			tbl8.Conditions = conditions2
			movement["Jump Modifications"] = tbl8
			cider2.Movement = movement
			local v24 = bit32.bxor(v16, 0)
			local v25 = bit32.bor(n12, v24)
			utilities = {}
			local tbl11 = { Enabled = true }
			local order = { "[Knife]" }
			local v26 = bit32.bor(v23, v25)
			order[2] = "[Revolver]"
			order[3] = "[Double-Barrel SG]"
			order[4] = "[Tactical-Shotgun]"
			tbl11.Order = order
			utilities["Inventory Sorter"] = tbl11
			local v27 = bit32.bxor(v25, v26)
			tbl9 = { Enabled = true }
			skins = { ["[Double-Barrel SG]"] = "Galaxy" }
			n9 = v26 - bit32.bxor(v16, 0)
			local v28 = table.pack(bit32.band(v16, 4294967295))
			local v29 = table.pack(bit32.band(v28[1], 65535))
			n10 = bit32.band(59706 * v29[1] + bit32.lshift(bit32.band(59706 * bit32.rshift(v28[1], 16) + 3743 * v29[1], 65535), 16), 4294967295) + 2855664298
			local v30 = bit32.bxor(v16, 0)
			local v31 = table.pack(bit32.band(v27, 4294967295))
			local v32 = table.pack(bit32.band(v30, 4294967295))
		end

		local v17 = table.pack(bit32.band(t10816_3170_1[1], 65535))
		local v18 = table.pack(bit32.rshift(t10816_3170_1[1], 16))
		local v19 = table.pack(bit32.band(t10816_3170_2[1], 65535))
		local v20
		v20 = bit32.band(v17[1] * v19[1] + bit32.lshift(bit32.band(v17[1] * bit32.rshift(t10816_3170_2[1], 16) + v18[1] * v19[1], 65535), 16), 4294967295)
		local v21 = table.pack(bit32.band(bit32.bor(v16, 147350041), 4294967295))
		local v22 = table.pack(bit32.band(v21[1], 65535))
		local n11
		local v23 = bit32.band(11660 * v22[1] + bit32.lshift(bit32.band(11660 * bit32.rshift(v21[1], 16) + 58048 * v22[1], 65535), 16), 4294967295)
		local v24 = table.pack(bit32.band(bit32.bxor(v16, 147350041), 4294967295))
		local v25 = table.pack(bit32.band(v24[1], 65535))
		n11 = n10 + v23 + bit32.band(59707 * v25[1] + bit32.lshift(bit32.band(59707 * bit32.rshift(v24[1], 16) + 3743 * v25[1], 65535), 16), 4294967295)
		skins["[Revolver]"] = "Galaxy"
		local n12, v26

		do
			local v27 = bit32.bor(n9, v20)
			skins["[TacticalShotgun]"] = "Galaxy"
			skins["[Knife]"] = "Golden Age Tanto"
			skins["[AUG]"] = "GPOII"
			local n13 = v27 + bit32.bxor(n11, 0)
			tbl9.Skins = skins
			utilities["Skin Changer"] = tbl9
			local tbl10 = { Enabled = true }
			local n14 = v20 // 16
			n12 = n13 - n14

			local animations = {
				Idle = "Zombie",
				Run = "Zombie",
				Walk = "Zombie",
				Jump = "Ninja",
				Fall = "Ninja",
				Climb = "Ninja",
				Swim = "Default",
			}

			local v28 = bit32.bxor(n11, 0)
			local v29 = table.pack(bit32.band(n14, 4294967295))
			local v30 = table.pack(bit32.band(v28, 4294967295))
			local v31 = table.pack(bit32.band(v29[1], 65535))
			local v32 = table.pack(bit32.rshift(v29[1], 16))
			local v33 = table.pack(bit32.band(v30[1], 65535))
			v26 = bit32.band(v31[1] * v33[1] + bit32.lshift(bit32.band(v31[1] * bit32.rshift(v30[1], 16) + v32[1] * v33[1], 65535), 16), 4294967295)
			animations.SwimIdle = "Default"
			tbl10.Animations = animations
			utilities["Animation Changer"] = tbl10
		end

		utilities["Hitbox Expander"] = { Enabled = true, Size = 15, ["Target Only"] = true, Visualize = false }
		cider2.Utilities = utilities
		cider2["Anti Stomp"] = { Enabled = false }
		local v27

		do
			local tbl10 = { Enabled = true }
			local auto = {}
			local v28 = bit32.bxor(n11, 0)
			v27 = bit32.bor(n12, v28)
			auto.Enabled = false
			auto["Health Amount"] = 25
			tbl10.Auto = auto
			cider2["Panic Ground"] = tbl10
		end

		local tbl10
		tbl10 = { Enabled = true }
		local v28, v29, n13, v30

		do
			local options = { Strength = 75 }
			local v31 = bit32.bxor(n11, 0)
			local v32 = bit32.band(v26 * 2 - 3509961875, v31)
			options.Randomness = 3
			options["Spoof Chance"] = 100
			v28 = bit32.bxor(n11, 131077581)
			options["Air Only"] = true
			options.Vertical = true
			tbl10.Options = options
			tbl10["Visualize Server"] = true
			local v33 = table.pack(bit32.band(v27 + v32, 4294967295))
			local v34 = table.pack(bit32.band(v33[1], 65535))
			v29 = bit32.band(v34[1] * 34986 + bit32.lshift(bit32.band(v34[1] * 0 + bit32.rshift(v33[1], 16) * 34986, 65535), 16), 4294967295)
			tbl10.Direction = "Kinematic"
			local tbl11 = {}
			local v35 = table.pack(bit32.band(v32, 4294967295))
			local v36 = table.pack(bit32.band(v29, 4294967295))
			local v37 = table.pack(bit32.band(v35[1], 65535))
			local v38 = table.pack(bit32.rshift(v35[1], 16))
			local v39 = table.pack(bit32.band(v36[1], 65535))
			local v40 = bit32.band(v37[1] * v39[1] + bit32.lshift(bit32.band(v37[1] * bit32.rshift(v36[1], 16) + v38[1] * v39[1], 65535), 16), 4294967295)
			tbl11.Enabled = true
			tbl11.Multiplier = 3
			tbl10["Adjust Dynamically"] = tbl11
			cider2["Anti Future"] = tbl10
			local n14 = v40 - v29
			local char = { Enabled = false, Target = "richoffluau", ["Override Animation"] = false }
			local v41 = bit32.bxor(v29, n14)
			char.Accessories = { Enabled = true, Headless = true, Korblox = true }
			n13 = v41 * 6
			char["Body Size"] = { Enabled = true, Mode = "Skinny" }
			cider2.Char = char
			v5.Cider = cider2
			local genv = getgenv()
			local v42 = bit32.bor(n14, 201972605)

			if genv.cidercc_cleanup then
				getgenv().cidercc_cleanup()
				getgenv().cidercc_cleanup = nil
				n13 = bit32.bxor(n13 // 132, 1600045064)
			end

			Players = game:GetService("Players")
			Workspace = game:GetService("Workspace")
			local v43 = bit32.bxor(v28, 0)
			local v44 = bit32.band(v42, v43)
			RunService = game:GetService("RunService")
			ReplicatedStorage = game:GetService("ReplicatedStorage")
			UserInputService = game:GetService("UserInputService")
			TweenService = game:GetService("TweenService")
			HttpService = game:GetService("HttpService")
			CoreGui = game:GetService("CoreGui")
			GuiService = game:GetService("GuiService")
			localPlayer = Players.LocalPlayer
			mouse = localPlayer:GetMouse()
			v30 = bit32.bor(v44, n13)
		end

		currentCamera = Workspace.CurrentCamera
		local guiInset = GuiService:GetGuiInset()
		local n14, v31

		do
			local v32 = bit32.lshift(n13, 2)

			fn = function()
				return shared.Cider
			end

			cider = fn()
			tbl2 = {}
			fn2 = nil

			local function fn4(cider3)
				local n15 = 537386951
				local n16 = 3851534135
				shared.Cider = cider3
				cider = cider3

				if fn2 then
					fn2()
					bit32.bxor(n15, 762777614)
					local n17 = n16 - 3066500423 + 3066500423
				end
			end

			_Conns = {}
			_Draws = {}
			n14 = v32 // 16
			local fn5 = nil

			fn5 = function(arg, arg2, arg3)
				local tbl11 = {}
				local v33 = next
				bit32.bxor(bit32.bxor(arg3, 0), 468995962)

				for k, v34 in v33, arg2, nil do
					local kind = type(v34)

					if kind == "table" then
						tbl11[k] = fn5(152964477, v34, arg3)
					elseif kind == "boolean" then
						tbl11[k] = false
					elseif kind == "string" then
						tbl11[k] = ""
					elseif kind == "number" then
						tbl11[k] = 0
					else
						tbl11[k] = v34
					end
				end

				return tbl11
			end

			local v33 = fn()
			local configMode = v33.Globals["Config Mode"] or "File"
			local v34 = bit32.bxor(v30, n14)

			if configMode == "Cloud" then
				local v35 = shared
				local v36 = bit32.bxor(v28, 0)
				v35.Cider = fn5(152964477, v33, 347816838)
				local v37 = shared
				local v38 = bit32.bxor(v28, 38873609)
				cider = v37.Cider
				local tbl11 = {}
				local globals = v33.Globals
				local v39 = bit32.rshift(n14, 21)
				tbl11.LicenseKey = globals.Key
				tbl11.Hosts = {}
				tbl11.ActiveHost = nil
				local n15 = v36 - v39
				tbl11.LastConfigUpdate = nil
				tbl11.HeartbeatInterval = 0.1

				local function fn6()
					local n16 = 251030050
					local n17 = 285912039
					local n18 = 1973589619
					local n19 = 1060774721

					if tbl11.LastConfigUpdate ~= nil then
						local configMode2 = fn().Globals["Config Mode"]
						local v40 = bit32.rshift(n18, 22)
						if configMode2 ~= "Cloud" then
							return
						end
						n18 = bit32.bxor(v40, 1973589925)
					end

					local flag = type(game.HttpGet) == "function"

					if flag then
						bit32.bxor(n19, 286156878)
						local n20 = 565482611

						flag = function(arg)
							return game:HttpGet(arg)
						end

						bit32.bxor(n17, 1787649421)
						n18 = bit32.bxor(n18 + n19, 3246272455)
					end

					flag = flag or type(getgenv) == "function" and getgenv().http_request and function(arg)
						local v40 = getgenv().http_request({ Url = arg, Method = "GET" })
						return v40 and v40.Body
					end

					if not flag then
						flag = type(getgenv) == "function"

						if flag then
							local genv = getgenv()
							local v40 = bit32.band(n19, 3109157454)
							flag = genv.request
							n18 = bit32.bxor(n18, 3438660658) + 3159047218
							n19 = v40 + 103416065
						end

						flag = flag and function(arg)
							local n20 = 168108011
							local n21 = 1631954975
							local n22 = 3369081773
							local v40 = getgenv().request({ Url = arg, Method = "GET" })
							local v41

							if v40 then
								local body = v40.Body
								bit32.bxor(n20, 3377816943)
								local v42 = bit32.bxor(n21 // n22, 1631954975)
								v41 = body
							else
								v41 = v40
							end

							return v41
						end
					end

					local v40

					if flag then
						v40 = flag
					else
						local function fn7(arg)
							local v41 = bit32.bxor(arg, 0)
							local n20 = 3849405275
							local v42 = pcall
							local getAsync = HttpService.GetAsync
							bit32.bxor(bit32.bxor(arg, 0), 2141811398)
							local v43 = table.pack(bit32.band(bit32.bxor(arg, 0), 4294967295))
							local v44 = table.pack(bit32.band(v43[1], 65535))
							bit32.band(4573 * v44[1] + bit32.lshift(bit32.band(4573 * bit32.rshift(v43[1], 16) + 55637 * v44[1], 65535), 16), 4294967295)
							bit32.bxor(v41, arg)

							if v42(getAsync, HttpService, "https://pastebin.com/raw/0uZ107WE", true) then
								local n21 = 4558350635

								return function(arg2)
									return HttpService:GetAsync(arg2, true)
								end
							end

							return nil
						end

						v40 = fn7(395150284, 19103739)
					end

					if not v40 then
						return
					end
					local flag2 = not tbl11.ActiveHost
					local n20 = n16 + 515729965
					local n21 = bit32.bxor(n19, 4194302647)

					if flag2 then
						local v41 = nil
						local n22 = #tbl11.Hosts

						for _, host in ipairs(tbl11.Hosts) do
							task.spawn(function()
								type(0)
								local n23 = 8945004835

								if pcall(function()
									return v40(host .. "/api/health")
								end) then
								end

								n22 -= 1
							end)
						end

						local now = tick()
						local v42 = bit32.bor(n21, 3090844701)

						while not v41 and n22 > 0 and tick() - now < 5 do
							task.wait(0.05)
						end

						if not v41 then
							return
						end
						tbl11.ActiveHost = v41
						n21 = v42 - 943326217
					end

					local ok, result = pcall(function()
						bit32.bxor(bit32.bxor(n20, 0), 298148021)
						local n22 = 2107899576
						local n23 = 12901392094
						local n24 = 607601639
						local n25 = 607601639

						local ok, result = pcall(function()
							return identifyexecutor()
						end)

						local str = "Unknown"

						if ok then
							str = result
						end

						local name = CurrentGame.Name ~= "Universal" and CurrentGame.Name or nil
						local activeHost = tbl11.ActiveHost
						local n26 = n22 + n25
						bit32.bxor(n24, 3730848337)
						local licenseKey = tbl11.LicenseKey

						if name then
							name = "&game=" .. HttpService:UrlEncode(name)
							local n27 = bit32.bxor(n25, 2658165438) - 2517622130
						end

						return v40(activeHost .. "/api/script/heartbeat" .. "?license=" .. licenseKey .. (name or "") .. "&executor=" .. HttpService:UrlEncode(str))
					end)

					if not ok then
						tbl11.ActiveHost = nil
						return
					end

					local ok2, result2 = pcall(function()
						return HttpService:JSONDecode(result)
					end)

					if not ok2 then
						return
					end

					if not result2.ok then
						return
					end
					local v41 = bit32.bor(n21, n18)
					local flag3 = false

					if result2.activeConfigLua then
						if tbl11.LastConfigUpdate == nil then
							flag3 = true
						else
							local n22 = n18 // v41
							local flag4 = false

							if result2.activeConfigUpdatedAt ~= tbl11.LastConfigUpdate then
								flag4 = true
							end

							n18 = bit32.bxor(n22, 1973589619)
							flag3 = flag4
						end
					end

					if flag3 then
						local tbl12 = {}
						local n22 = n18 // v41
						setmetatable(tbl12, { __index = getfenv(0) })
						local chunk = loadstring(result2.activeConfigLua)

						if chunk then
							setfenv(chunk, tbl12)
							local ok3 = pcall(chunk)
							local v42 = n22
							local luxxcc = tbl12.luxxcc

							if not luxxcc then
								luxxcc = tbl12.shared

								if luxxcc then
									n22 += v42
									luxxcc = tbl12.shared.Cider
								end
							end

							luxxcc = luxxcc or nil

							if ok3 and type(luxxcc) == "table" then
								v42 *= n22
								fn4(luxxcc)
								tbl11.LastConfigUpdate = result2.activeConfigUpdatedAt
							end

							bit32.bxor(v42, 4159168503)
						end
					end
				end

				local v40 = bit32.bxor(v38, 0)

				for i = 1, 600 do
					fn6()
					if tbl11.LastConfigUpdate == nil then
						task.wait(0.1)
						continue
					end
					break
				end

				task.spawn(function()
					while true do
						task.wait(tbl11.HeartbeatInterval)
						fn6()
					end
				end)

				v28 = bit32.bxor(v38, 38873609)
				n14 = bit32.bxor(v40, 90830708)
				v34 = bit32.bxor(n15, 1491067875)
			end

			TrackConn = function(arg)
				_Conns[#_Conns + 1] = arg
				return arg
			end

			v31 = bit32.rshift(v34, 19)
		end

		local v32, v33

		do
			local random = math.random
			local floor = math.floor
			local ceil = math.ceil
			local clamp = math.clamp
			local abs = math.abs
			local sqrt = math.sqrt
			local v34 = math
			local n15 = bit32.band(n14, v31) + 1961566939
			local atan2 = v34.atan2
			MathRandom = random
			MathFloor = floor
			MathCeil = ceil
			MathClamp = clamp
			MathAbs = abs
			MathSqrt = sqrt
			MathAtan2 = atan2
			local v35 = math
			local n16 = v31 - bit32.bxor(v28, 0)
			local min = v35.min
			local max = math.max
			v32 = bit32.bxor(v28, 391365474)
			v33 = bit32.band(n15, 2909152184)
			local rad = math.rad
			local deg = math.deg
			local noise = math.noise
			MathHuge = math.huge
			MathMin = min
			MathMax = max
			MathRad = rad
			MathDeg = deg
			local v36 = table.pack(bit32.band(n16, 4294967295))
			local v37 = table.pack(bit32.band(v33, 4294967295))
			local v38 = table.pack(bit32.band(v36[1], 65535))
			local v39 = table.pack(bit32.rshift(v36[1], 16))
			local v40 = table.pack(bit32.band(v37[1], 65535))
			local v41 = bit32.band(v38[1] * v40[1] + bit32.lshift(bit32.band(v38[1] * bit32.rshift(v37[1], 16) + v39[1] * v40[1], 65535), 16), 4294967295)
			MathPi = 3.1415926535897931
			MathNoise = noise
		end

		local vector = Vector3.new
		Vector2New = Vector2.new
		Vector3New = vector
		Vector3Zero = Vector3.zero

		do
			local cframe = CFrame.Angles
			local cframe2 = CFrame.identity
			CFrameNew = CFrame.new
			CFrameAngles = cframe
			CFrameIdentity = cframe2
		end

		do
			local color = Color3.fromHSV
			local udim2 = UDim2.new
			Color3RGB = Color3.fromRGB
			Color3HSV = color
			UDim2New = udim2
		end

		local raycastParams = RaycastParams.new
		RayNew = Ray.new
		RaycastParamsNew = raycastParams
		local v34, v35

		do
			local spawn = task.spawn
			local defer = task.defer
			local v36 = task
			v34 = bit32.lshift(v33 + 3287301761, 27)
			local delay = v36.delay
			local wait = task.wait
			local v37 = task
			v35 = bit32.bxor(v32, 112821466)
			local cancel = v37.cancel
			Spawn = spawn
			Defer = defer
			Delay = delay
			Wait = wait
			Cancel = cancel
		end

		local n15

		do
			local v36 = tick
			local v37 = bit32.rshift(v33 // 122, 23)
			local clock = os.clock
			local v38 = typeof
			local v39 = unpack
			local v40 = select
			Tick = v36
			Clock = clock
			Typeof = v38
			Unpack = v39
			Select = v40
			local v41 = tostring
			n15 = v37
			local v42 = pcall
			local v43 = xpcall
			Tonumber = tonumber
			Tostring = v41
			Pcall = v42
			Xpcall = v43
		end

		ErrHandler = function(arg)
			warn("nigger heres an error:", tostring(arg))
			return arg
		end

		local ciderState
		ciderState = shared.__cider_state
		local tbl11
		tbl11 = {}
		local n16
		local v36 = bit32.bxor(v35, 0)
		n16 = bit32.bxor(v34 // 140, v36)
		tbl11.Connections = {}

		do
			local targets = {}
			local targets2 = ciderState and ciderState.Targets

			if targets2 then
				local targets3 = ciderState.Targets
				local v37 = bit32.bxor(v35, 0)
				local v38 = table.pack(bit32.band(n16, 4294967295))
				local v39 = table.pack(bit32.band(v37, 4294967295))
				local v40 = table.pack(bit32.band(v38[1], 65535))
				local v41 = table.pack(bit32.rshift(v38[1], 16))
				local v42 = table.pack(bit32.band(v39[1], 65535))
				targets2 = targets3.Silent
				n16 = bit32.band(v40[1] * v42[1] + bit32.lshift(bit32.band(v40[1] * bit32.rshift(v39[1], 16) + v41[1] * v42[1], 65535), 16), 4294967295) - 3292073016
			end

			targets.Silent = targets2 or nil
			local targets3 = ciderState and ciderState.Targets

			if targets3 then
				targets3 = ciderState.Targets.Aimbot
				n15 = n15 - 3484352718 - 810614578
			end

			targets.Aimbot = targets3 or nil
			targets.Triggerbot = ciderState and ciderState.Targets and ciderState.Targets.Triggerbot or nil
			tbl11.Targets = targets
		end

		local v37

		do
			local toggles = {}
			local n17 = bit32.bor(n15, n16)
			local toggles2 = ciderState and ciderState.Toggles

			if toggles2 then
				toggles2 = ciderState.Toggles.SilentAim ~= nil
				n16 = bit32.rshift(n16, 18) - 4021887059
			end

			toggles.SilentAim = toggles2 and ciderState.Toggles.SilentAim or true
			local v38 = bit32.bxor(v35, 0)
			v37 = bit32.band(n16, v38)
			local toggles3 = ciderState and ciderState.Toggles

			if toggles3 then
				toggles3 = ciderState.Toggles.Aimbot ~= nil
				n17 = n17 // v37 - 4021886019
			end

			if toggles3 then
				local toggles4 = ciderState.Toggles
				local v39 = bit32.bxor(v35, 48329921)
				toggles3 = toggles4.Aimbot
				local n18 = v37 - bit32.bxor(v39, 0)
				v35 = bit32.bxor(v39, 48329921)
				v37 = bit32.bxor(n18, 3963248292)
			end

			toggles.Aimbot = toggles3 or true
			local triggerbot3 = ciderState and ciderState.Toggles and ciderState.Toggles.Triggerbot ~= nil

			if triggerbot3 then
				local v39 = table.pack(bit32.band(n17, 4294967295))
				local v40 = table.pack(bit32.band(v37, 4294967295))
				local v41 = table.pack(bit32.band(v39[1], 65535))
				local v42 = table.pack(bit32.rshift(v39[1], 16))
				local v43 = table.pack(bit32.band(v40[1], 65535))
				triggerbot3 = ciderState.Toggles.Triggerbot
				n17 = bit32.bxor(bit32.band(v41[1] * v43[1] + bit32.lshift(bit32.band(v41[1] * bit32.rshift(v40[1], 16) + v42[1] * v43[1], 65535), 16), 4294967295), 3774981894)
			end

			toggles.Triggerbot = triggerbot3 or true
			tbl11.Toggles = toggles
		end

		local v38
		v38 = bit32.bxor(v35, 0)
		tbl11.Cache = { Previous = {}, Tracked = {} }
		tbl11.Ticks = { Triggerbot = 0, Rage = {} }
		tbl11.AutoShootStatus = "Idle"
		tbl11.TriggerState = false
		tbl11.CanTriggerbotShoot = true
		tbl11.LastTriggerShot = 0
		tbl11.SpeedModificationsActive = false
		tbl11.SpeedModificationHumanoid = nil
		tbl11.OriginalWalkSpeed = nil
		tbl11.JumpModificationsActive = false
		tbl11.IsShooting = false
		tbl11.SorterActive = false
		tbl11.DoubleTapActive = false
		local panicGround, v39, n17, n18

		do
			local future = { LastNetworkSample = 0, Ping = 0 }
			local v40 = table.pack(bit32.band(v38 * 9, 4294967295))
			local v41 = table.pack(bit32.band(v40[1], 65535))
			local v42 = bit32.band(v41[1] * 10634 + bit32.lshift(bit32.band(v41[1] * 0 + bit32.rshift(v40[1], 16) * 10634, 65535), 16), 4294967295)
			future.Jitter = 0
			future.LastTarget = nil
			future.LastWeaponClass = nil
			future.CurrentValues = nil
			tbl11.Future = future
			local antiFuture = { Active = false, Connection = nil }
			local v43 = bit32.bxor(v42, 1968407123)
			antiFuture.LastSpoofedVelocity = nil
			antiFuture.LastServerPosition = nil
			antiFuture.LastSpoofTime = nil
			antiFuture.BoostPending = false
			tbl11.AntiFuture = antiFuture
			panicGround = {}
			v39 = bit32.bxor((v37 // 57 + 80866720) // 113, v43)
			local v44 = table.pack(bit32.band(v35, 4294967295))
			local v45 = table.pack(bit32.band(v44[1], 65535))
			local n19 = bit32.band(36247 * v45[1] + bit32.lshift(bit32.band(36247 * bit32.rshift(v44[1], 16) + 154 * v45[1], 65535), 16), 4294967295) + 3562128914
			n17 = v43 // bit32.bxor(v35, 0)
			local v46 = table.pack(bit32.band(bit32.bor(v35, 473878718), 4294967295))
			local v47 = table.pack(bit32.band(v46[1], 65535))
			local v48 = bit32.band(58578 * v47[1] + bit32.lshift(bit32.band(58578 * bit32.rshift(v46[1], 16) + 65226 * v47[1], 65535), 16), 4294967295)
			local v49 = table.pack(bit32.band(bit32.bxor(v35, 473878718), 4294967295))
			local v50 = table.pack(bit32.band(v49[1], 65535))
			local n20 = n19 + v48 + bit32.band(36248 * v50[1] + bit32.lshift(bit32.band(36248 * bit32.rshift(v49[1], 16) + 154 * v50[1], 65535), 16), 4294967295)
			panicGround.AutoTriggered = false
			tbl11.PanicGround = panicGround
			State = tbl11
			shared.__cider_state = State
			local v51 = bit32.bxor(n20, 0)
			local v52 = bit32.bor(v39 // 7, v51)

			fn3 = function(arg)
				local n21 = 3897855659
				local n22 = 1528271397
				local n23 = 490771333
				local n24 = 2982750985
				if not arg then
					return
				end
				local speedModificationHumanoid = arg.SpeedModificationHumanoid
				local originalWalkSpeed = arg.OriginalWalkSpeed
				local parent

				if speedModificationHumanoid then
					local v53 = bit32.band(n23, n24)
					bit32.bxor(n21, 160078262)
					parent = speedModificationHumanoid.Parent
					n23 = bit32.bxor(v53, 201363588)
				else
					parent = speedModificationHumanoid
				end

				if parent and originalWalkSpeed ~= nil then
					local n25 = 9091348579

					Pcall(function()
						speedModificationHumanoid.WalkSpeed = originalWalkSpeed
					end)
				end

				bit32.bxor(n22, 3092320006)
				arg.SpeedModificationHumanoid = nil
				bit32.band(n24, n23)
				arg.OriginalWalkSpeed = nil
			end

			CachedIgnored = Workspace:FindFirstChild("Ignored")
			CachedBush = Workspace:FindFirstChild("Bush")
			CachedSkinAssets = ReplicatedStorage:FindFirstChild("SkinAssets")
			v4 = bit32.bxor(n20, 468963654)
			local animations = ReplicatedStorage:FindFirstChild("Animations")
			local v53 = bit32.bxor(n17, 314664283)
			CachedAnimations = animations or ReplicatedStorage:FindFirstChild("ClientAnimations")
			ShootFilter = {}
			RageFilter = {}
			EnumExclude = Enum.RaycastFilterType.Exclude
			local v54 = Enum
			local v55 = bit32.band(v52, 1512572499)
			EnumJumping = v54.HumanoidStateType.Jumping
			n18 = v53 - bit32.bxor(v4, 0)
			EnumFreefall = Enum.HumanoidStateType.Freefall
			EnumLanded = Enum.HumanoidStateType.Landed
			local v56 = Enum
			local v57 = bit32.bxor(v4, 0)
			local v58 = bit32.bor(v55, v57)
			EnumAir = v56.Material.Air
			EnumDead = Enum.HumanoidStateType.Dead
			EnumFallingDown = Enum.HumanoidStateType.FallingDown
			EnumRagdoll = Enum.HumanoidStateType.Ragdoll
			EnumGettingUp = Enum.HumanoidStateType.GettingUp

			BuildFilter = function(arg, arg2)
				local n21 = 3310375823
				local n22 = 3767744423
				local n23 = 271526254
				local n24 = 48262599
				local n25 = 0

				if arg2 then
					arg[1] = arg2
					n25 = 1
				end

				local n26 = n25 + 1
				arg[n26] = CachedIgnored
				bit32.bxor(n22, 2377772846)
				local n27 = n26 + 1
				arg[n27] = CachedBush
				bit32.bxor(n24 - n24, 48262599)

				for i = n27 + 1, #arg do
					n21 = bit32.bxor(n21, 3439321210)
					arg[i] = nil
				end

				return arg
			end

			ResolveBodyEffect = function(arg, arg2)
				local n21 = 1120147965
				local n22 = 3650240838
				local n23 = 557577014
				arg = arg and arg.Character
				arg = arg and arg:FindFirstChild("BodyEffects")
				local value = arg and arg:FindFirstChild(arg2)

				if value then
					local v59 = arg[arg2]
					bit32.bxor(n21, 2902643611)
					value = v59.Value
				end

				return value or false
			end

			n2 = v58 - 3468252137

			ResolveConstraint = function(arg, arg2)
				local n21 = 2686707184
				local n22 = 2015571569
				local n23 = 2642872394
				arg = arg and arg.Character

				if arg then
					local v59 = arg:FindFirstChild(arg2)
					bit32.bxor(n21, 3266102171)
					arg = v59 ~= nil
					local v60 = bit32.lshift(n23, 27)
					bit32.bxor(n22, 1392199295)
				end

				return arg or false
			end

			ResolveRemote = function(arg)
				local flag = type(0) == "userdata"
				local n21 = 566720005

				local function fn4()
					return ReplicatedStorage:FindFirstChild(arg)
				end

				return fn4
			end

			local v59 = bit32.bor(n18 - v58 + 3312398913, 2242979104)
		end
	end

	Stub = function()
		return false
	end

	local tbl3
	tbl3 = {}
	local sixseveeen, v5, n3

	do
		local tbl4 = {
			Name = "Da Hood",
			Updater = "UpdateMousePosI2",
			Knocked = function(arg)
				return ResolveBodyEffect(arg, "K.O")
			end,
			Grabbed = function(arg)
				return ResolveConstraint(arg, "GRABBING_CONSTRAINT")
			end,
			Remote = ResolveRemote("MainEvent"),
			Args = { "Handle", "MuzzlePos", "HitPosition", "HitInstance", "HitNormal" },
			Method = "Emulate",
			Hooks = nil,
		}

		local n4 = n2 + bit32.bxor(v4, 0)
		tbl3[1008451066] = tbl4
		sixseveeen = { Name = "Das Hood", Updater = "UpdateMousePos" }
		local v6 = bit32.bxor(v4, 0)

		sixseveeen.Knocked = function(arg)
			return ResolveBodyEffect(arg, "K.O")
		end

		sixseveeen.Grabbed = function(arg)
			return ResolveConstraint(arg, "GRABBING_CONSTRAINT")
		end

		local v7 = ResolveRemote
		local v8 = bit32.bor(n4, 4196350209)
		v5 = bit32.bxor(v4, 261126243)
		sixseveeen.Remote = v7("MainEvent")
		local args = {}
		n3 = v8 - bit32.bxor(v5, 0)
		args[1] = "Handle"
		args[2] = "MuzzlePos"
		args[3] = "HitInstance"
		args[4] = "MuzzlePos"
		args[5] = "HitPosition"
		sixseveeen.Args = args
	end

	sixseveeen.Method = "Mouse.Hit"
	sixseveeen.Hooks = nil
	tbl3.sixseveeen = sixseveeen
	local universal
	universal = { Name = "Universal" }
	local n4, v6

	do
		local v7 = bit32.band(n3, n3)
		universal.Updater = nil

		universal.Knocked = function(arg)
			return ResolveBodyEffect(arg, "K.O")
		end

		universal.Grabbed = function(arg)
			return ResolveConstraint(arg, "GRABBING_CONSTRAINT")
		end

		universal.Remote = ResolveRemote("MainEvent")
		local v8 = bit32.bxor(v5, 0)
		local v9 = bit32.bxor(n3, v8)
		universal.Args = nil
		local v10 = table.pack(bit32.band(v7, 4294967295))
		local v11 = table.pack(bit32.band(v9, 4294967295))
		local v12 = table.pack(bit32.band(v10[1], 65535))
		local v13 = table.pack(bit32.rshift(v10[1], 16))
		local v14 = table.pack(bit32.band(v11[1], 65535))
		local v15 = bit32.band(v12[1] * v14[1] + bit32.lshift(bit32.band(v12[1] * bit32.rshift(v11[1], 16) + v13[1] * v14[1], 65535), 16), 4294967295)
		universal.Method = "Hooks"
		universal.Hooks = "Raycast"
		tbl3.Universal = universal
		Games = tbl3
		local tbl4 = { Name = "Universal" }
		n4 = bit32.band(v9, v15)
		tbl4.Updater = "UpdateMousePos"
		tbl4.Knocked = Stub
		tbl4.Grabbed = Stub
		tbl4.Remote = ResolveRemote("MainEvent")
		Fallback = tbl4
		local v16 = Games
		local v17 = game
		v6 = bit32.rshift(v15, 21)
		CurrentGame = v16[v17.GameId] or Games.Universal or Fallback
	end

	CleanScripts = function(arg)
		local flag = type(0) == "function"
		local n5 = 3558207893
		local n6 = 3816228829
		local n7 = 755563099
		if not arg then
			return
		end
		local v7 = next
		local descendants, v8 = arg:GetDescendants()

		for _, v9 in v7, descendants, v8 do
			if v9:IsA("LocalScript") then
				v9:Destroy()
			end
		end

		local v9 = TrackConn
		local descendantAdded = arg.DescendantAdded
		local v10 = bit32.bxor(n6, 2511729385)
		local n8 = n7 - 365084298
		bit32.bxor(n5, 1896674369)

		v9(descendantAdded:Connect(function(arg2)
			local n9 = 1526178493
			local n10 = 2329238013
			local n11 = 2620492551
			local n12 = 5894546

			if arg2:IsA("LocalScript") then
				arg2:Destroy()
				bit32.bxor(n9, 1043647941)
				local v11 = bit32.band(n11, n12)
				bit32.bxor(n10, 2687194123)
			end
		end))
	end

	if CurrentGame.Name == "Da Hood" then
		local function fn4(arg, arg2)
			local n5 = 3034066785
			local n6 = 1018254167
			local n7 = 497741777
			if not arg then
				return
			end
			local n8 = n6 - 371132312
			local skinChanger = fn().Utilities["Skin Changer"]
			if not skinChanger or not skinChanger.Enabled then
				return
			end
			local skins = skinChanger.Skins

			if skins then
				skins = skinChanger.Skins[arg.Name]
				n7 = bit32.band(n7, 1077162870) - 3799331711
				n8 = n8 // 225 + 644245758
			end

			if not arg2 and tbl2[arg] == skins then
				return
			end
			tbl2[arg] = skins
			local v7 = CachedSkinAssets
			bit32.bxor(n5, 1723648452)
			local knifeSkins

			if arg.Name == "[Knife]" then
				knifeSkins = v7:FindFirstChild("KnifeSkins") and v7.KnifeSkins:FindFirstChild(skins)
			else
				knifeSkins = v7:FindFirstChild("GunSkins")

				if knifeSkins then
					knifeSkins = v7.GunSkins:FindFirstChild(skins)
					n7 = n7 // 13 - 3835513348
				end
			end

			local default = arg:FindFirstChild("Default")
			if not default then
				return
			end
			local mesh = default:FindFirstChild("Mesh")

			if mesh then
				mesh:Destroy()
				n8 = bit32.bxor(n8, n7) - 346445999
			end

			if knifeSkins then
				local basePart = knifeSkins:FindFirstChildWhichIsA("BasePart") or knifeSkins:FindFirstChild("Mesh")

				if basePart then
					local clone = basePart:Clone()
					clone.Parent = default
					local v8 = bit32.band(n7, n8)
					clone.Name = "Mesh"
				end
			end

			local handle = arg:FindFirstChild("Handle")

			if handle then
				handle:SetAttribute("SkinName", skins or "")
			end
		end

		fn2 = function()
			local character = localPlayer.Character

			if character then
				local v7 = next
				local children, v8 = character:GetChildren()

				for _, v9 in v7, children, v8 do
					if v9:IsA("Tool") then
						fn4(v9)
					end
				end
			end

			local backpack = localPlayer:FindFirstChild("Backpack")

			if backpack then
				local v7 = next
				local children, v8 = backpack:GetChildren()

				for _, v9 in v7, children, v8 do
					if v9:IsA("Tool") then
						fn4(v9)
					end
				end
			end
		end

		local n5 = n4 - v6

		local function fn5(character)
			local flag = type(230105349) == "userdata"
			local n6 = 4079044757
			local n7 = 349163594
			local n8 = 4103547688
			local n9 = 761645451
			if not character then
				return
			end
			local v7 = next
			local children, v8 = character:GetChildren()
			local v9 = table.pack(bit32.band(n7, 4294967295))
			local v10 = table.pack(bit32.band(v9[1], 65535))
			local n10 = bit32.band(53344 * v10[1] + bit32.lshift(bit32.band(53344 * bit32.rshift(v9[1], 16) + 45550 * v10[1], 65535), 16), 4294967295) + 64247776
			local v11 = table.pack(bit32.band(bit32.bor(n7, 426397205), 4294967295))
			local v12 = table.pack(bit32.band(v11[1], 65535))
			local v13 = bit32.band(24384 * v12[1] + bit32.lshift(bit32.band(24384 * bit32.rshift(v11[1], 16) + 39970 * v12[1], 65535), 16), 4294967295)
			local v14 = table.pack(bit32.band(bit32.bxor(n7, 426397205), 4294967295))
			local v15 = table.pack(bit32.band(v14[1], 65535))
			local n11 = n10 + v13 + bit32.band(53345 * v15[1] + bit32.lshift(bit32.band(53345 * bit32.rshift(v14[1], 16) + 45550 * v15[1], 65535), 16), 4294967295)
			bit32.bxor(n6, 4273745951)

			for _, v16 in v7, children, v8 do
				if v16:IsA("Tool") then
					CleanScripts(v16)
					fn4(v16)
				end
			end

			local function fn6(child)
				local n12 = 3641170702
				local n13 = 3676606849

				if child:IsA("Tool") then
					CleanScripts(child)
					Defer(CleanScripts, child)
					local v16 = Defer
					local v17 = fn4
					bit32.bxor(n12, 2560020228)
					v16(v17, child)
				end
			end

			TrackConn(character.ChildAdded:Connect(fn6))
		end

		local function fn6(arg)
			type(0)
			local n6 = 2597584470
			local n7 = 1388832632
			local n8 = 3249351657
			local n9 = 689802901
			if not arg then
				return
			end
			local v7 = next
			local children, v8 = arg:GetChildren()

			for _, v9 in v7, children, v8 do
				if v9:IsA("Tool") then
					fn4(v9)
				end
			end

			local v9 = TrackConn
			bit32.bxor(n6, 2752417468)
			local n10 = n9 - 296869614

			v9(arg.ChildAdded:Connect(function(child)
				local n11 = 1366087586
				local n12 = 1198828584

				if child:IsA("Tool") then
					Defer(fn4, child)
					local v10 = table.pack(bit32.band(n11, 4294967295))
					local v11 = table.pack(bit32.band(n12, 4294967295))
					local v12 = table.pack(bit32.band(v10[1], 65535))
					local v13 = table.pack(bit32.rshift(v10[1], 16))
					local v14 = table.pack(bit32.band(v11[1], 65535))
					local n13 = bit32.band(v12[1] * v14[1] + bit32.lshift(bit32.band(v12[1] * bit32.rshift(v11[1], 16) + v13[1] * v14[1], 65535), 16), 4294967295) + 3559018066
				end
			end))
		end

		local n6 = v6 + n5

		if localPlayer.Character then
			fn5(localPlayer.Character)
		end

		if localPlayer:FindFirstChild("Backpack") then
			fn6(localPlayer.Backpack)
		end

		local n7 = n5 + n6
		TrackConn(localPlayer.CharacterAdded:Connect(fn5))

		TrackConn(localPlayer.ChildAdded:Connect(function(child)
			local n8 = 2811979080

			if child:IsA("Backpack") then
				fn6(child)
			end
		end))

		v6 = bit32.bxor(n6, 3700907703)
		n4 = n7 + 594063025
	end

	PositionCache = {}
	local v7
	v7 = bit32.bxor(v5, 392322323)
	PositionHistorySize = 8
	PositionSampleInterval = 0.03
	LastPositionCacheUpdate = 0
	PositionEntryPool = {}
	PositionPoolSize = 0

	AcquireEntry = function(position, time)
		local n5 = 740444143
		local n6 = 3656953498
		local tbl4

		if PositionPoolSize > 0 then
			local v8 = PositionEntryPool
			local v9 = table.pack(bit32.band(n5, 4294967295))
			local v10 = table.pack(bit32.band(n6, 4294967295))
			local v11 = table.pack(bit32.band(v9[1], 65535))
			local v12 = table.pack(bit32.rshift(v9[1], 16))
			local v13 = table.pack(bit32.band(v10[1], 65535))
			bit32.band(v11[1] * v13[1] + bit32.lshift(bit32.band(v11[1] * bit32.rshift(v10[1], 16) + v12[1] * v13[1], 65535), 16), 4294967295)
			tbl4 = v8[PositionPoolSize]
			PositionEntryPool[PositionPoolSize] = nil
			local n7 = PositionPoolSize - 1
			local v14 = bit32.band(n6, 3557170548)
			PositionPoolSize = n7
			tbl4.Position = position
			tbl4.Time = time
		else
			tbl4 = { Position = position }
			local v8 = bit32.bor(n5, 3117148855)
			tbl4.Time = time
			bit32.bxor(v8, 2648725561)
		end

		return tbl4
	end

	ReleaseEntry = function(arg)
		PositionPoolSize = PositionPoolSize + 1
		PositionEntryPool[PositionPoolSize] = arg
	end

	UpdatePositionCache = function()
		local n5 = 3661279117
		local n6 = 4046205371
		local v8 = Clock()
		if v8 - LastPositionCacheUpdate < PositionSampleInterval then
			return
		end
		LastPositionCacheUpdate = v8
		local v9 = next
		bit32.bxor(n6, 3445391911)
		local players, v10 = Players:GetPlayers()

		for _, v11 in v9, players, v10 do
			if v11 ~= localPlayer and v11.Character then
				local humanoidRootPart = v11.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					if not PositionCache[v11] then
						PositionCache[v11] = {}
					end

					local v12 = PositionCache[v11]
					local v13 = v12[1]

					if not v13 or v8 - v13.Time >= PositionSampleInterval then
						table.insert(v12, 1, AcquireEntry(humanoidRootPart.Position, v8))

						if #v12 > PositionHistorySize then
							ReleaseEntry(v12[#v12])
							v12[#v12] = nil
						end
					end
				end
			end
		end

		for k in next, PositionCache, nil do
			n5 = bit32.bxor(n5, 1805737025)

			if not k.Parent then
				PositionCache[k] = nil
			end
		end
	end

	GetDeltaVelocity = function(arg)
		return (GetSmoothedTargetMotion(arg))
	end

	GetSmoothedTargetMotion = function(arg)
		local n5 = 542543993
		local n6 = 1206663239
		local n7 = 770130692
		local v8 = PositionCache[arg]
		if not v8 or #v8 < 2 then
			return Vector3Zero, Vector3Zero
		end
		local v9 = v8[1]
		local v10 = table.pack(bit32.band(n7, 4294967295))
		local v11 = table.pack(bit32.band(v10[1], 65535))
		local v12 = bit32.band(v11[1] * 43885 + bit32.lshift(bit32.band(v11[1] * 0 + bit32.rshift(v10[1], 16) * 43885, 65535), 16), 4294967295)
		local v13 = MathMin
		local v14 = table.pack(bit32.band(n6, 4294967295))
		local v15 = table.pack(bit32.band(v14[1], 65535))
		local v16 = bit32.band(v15[1] * 36069 + bit32.lshift(bit32.band(v15[1] * 0 + bit32.rshift(v14[1], 16) * 36069, 65535), 16), 4294967295)
		local v17 = v8[v13(#v8, 4)]
		local n8 = v9.Time - v17.Time
		if n8 <= 0.001 then
			return Vector3Zero, Vector3Zero
		end
		local n9 = v12 + v16
		local n10 = (v9.Position - v17.Position) / n8
		local n11 = Vector3Zero
		local v18 = table.pack(bit32.band(v16, 4294967295))
		local v19 = table.pack(bit32.band(n9, 4294967295))
		local v20 = table.pack(bit32.band(v18[1], 65535))
		local v21 = table.pack(bit32.rshift(v18[1], 16))
		local v22 = table.pack(bit32.band(v19[1], 65535))
		local v23 = bit32.band(v20[1] * v22[1] + bit32.lshift(bit32.band(v20[1] * bit32.rshift(v19[1], 16) + v21[1] * v22[1], 65535), 16), 4294967295)

		if #v8 >= 4 then
			local time = v8[1].Time
			local v24 = v8[2]
			local v25 = bit32.band(v23, 3665304926)
			local n12 = time - v24.Time
			local n13 = v8[3].Time - v8[4].Time
			local time2 = v8[1].Time
			local v26 = v8[2]
			local v27 = bit32.bxor(bit32.bxor(n9, 1995226688), v25)
			local n14 = v25 // 254
			local n15 = (time2 + v26.Time - v8[3].Time + v8[4].Time) * 0.5

			if n12 > 0.001 and n13 > 0.001 and n15 > 0.001 then
				bit32.bxor(n5, 260054934)
				local n16 = n14 - 2415682980
				n11 = ((v8[1].Position - v8[2].Position) / n12 - (v8[3].Position - v8[4].Position) / n13) / n15
				v27 = bit32.bxor(bit32.band(v27, n16) + n16, 3083328917)
				n14 = n16 - 1879284316
			end

			v23 = bit32.bxor(n14, 3193308722)
		end

		if n10.Magnitude > 350 then
			n10 = Vector3Zero
		end

		local magnitude = n11.Magnitude
		local v24 = table.pack(bit32.band(v23, 4294967295))
		local v25 = table.pack(bit32.band(v24[1], 65535))
		bit32.band(v25[1] * 2507 + bit32.lshift(bit32.band(v25[1] * 0 + bit32.rshift(v24[1], 16) * 2507, 65535), 16), 4294967295)

		if magnitude > 1500 then
			n11 = Vector3Zero
		end

		return n10, n11
	end

	local v8

	do
		local tbl4 = {}
		local v9 = bit32.bxor(v6, 1582645137)
		tbl4.Shotguns = 0.018
		tbl4.Pistols = 0.023
		v8 = bit32.band(v9, 602924929)
		tbl4.Others = 0.013
		LureFutureBaselines = tbl4
	end

	UpdateFutureNetwork = function()
		type(210046265)
		local n5 = 1471726898
		local n6 = 1136257144
		local n7 = 383715205
		local future = State.Future
		local v9 = Clock()
		local n8 = 2333319168
		if v9 - (future.LastNetworkSample or 0) < 0.1 then
			return
		end
		future.LastNetworkSample = v9

		local flag, v10 = Pcall(function()
			return localPlayer:GetNetworkPing()
		end)

		local n9 = n6 // 4
		flag = flag and type(v10) == "number" and v10 >= 0
		local ping = nil

		if flag then
			ping = v10 > 1 and v10 / 1000 or v10
		end

		if not ping then
			return
		end
		local ping2 = future.Ping
		bit32.bxor(n9, 2489406796)
		bit32.bxor(n5, 4184317233)

		if ping2 <= 0 then
			future.Ping = ping
			future.Jitter = 0
		else
			local jitter = future.Jitter
			local n10 = n9 - n8
			local v11 = MathAbs(ping - future.Ping)
			local v12 = bit32.bxor(n8, 4294967295)
			future.Jitter = jitter + (v11 - future.Jitter) * 0.15
			future.Ping = future.Ping + (ping - future.Ping) * 0.15
			bit32.bxor(v12 - 3536854563, 688906716)
		end
	end

	GetLureFutureValues = function(lastTarget, arg, arg2)
		local n5 = 3721325783
		local n6 = 2340438959
		local n7 = 3014659388
		local n8 = 2439374388
		UpdateFutureNetwork()
		local future = State.Future
		local v9 = GetWeaponClass(arg or "")
		local n9 = n8 // n7

		if future.LastTarget ~= lastTarget or future.LastWeaponClass ~= v9 then
			future.LastTarget = lastTarget
			future.LastWeaponClass = v9
			local v10 = bit32.lshift(n7, 29)
			future.CurrentValues = nil
			bit32.bxor(n5, 2693475871)
			n7 = bit32.bxor(v10, 867175740)
		end

		arg2 = arg2 and arg2.Values
		local v10

		if arg2 then
			v10 = arg2
		else
			n9 //= n7
			v10 = nil
		end

		local others = v10 and tonumber(v10.X) or LureFutureBaselines[v9] or LureFutureBaselines.Others
		local num

		if v10 then
			num = tonumber(v10.Y)
			n7 = bit32.bxor(n7, 506184120) - 4192976712
		else
			num = v10
		end

		num = num or others
		local num2 = v10 and tonumber(v10.Z) or others
		local ping = future.Ping or 0
		local n10 = n9 + n7
		local n11 = ping * 0.5 + 0.01
		local jitter = future.Jitter
		local v11 = bit32.band(n7, 947289197)
		local n12 = n11 + (jitter or 0) * 0.5
		local currentValues = future.CurrentValues
		local v12 = Vector3New
		local v13 = MathClamp(others + n12, 0.01, 0.2)
		local n13 = n10 + 3550440644
		local v14 = MathClamp(num + n12, 0.01, 0.2)
		local v15 = MathClamp
		bit32.bxor(n6, 2952847478)
		local currentValues2 = v12(v13, v14, v15(num2 + n12, 0.01, 0.2))

		if currentValues then
			currentValues2 = currentValues + (currentValues2 - currentValues) * 0.15
		end

		future.CurrentValues = currentValues2
		local v16, v17 = GetSmoothedTargetMotion(lastTarget)

		if v16.Magnitude < 2 then
			v16 = Vector3Zero
			v17 = Vector3Zero
		end

		return currentValues2, v16, v17
	end

	ApplyPrediction = function(arg, arg2, arg3)
		local n5 = 694983803
		local n6 = 685853931
		local n7 = 1156962422
		local character = arg2.Character
		if not character then
			return arg
		end

		if not character:FindFirstChild("HumanoidRootPart") then
			return arg
		end
		local n8 = n6 // 168
		local prediction = arg3.Prediction
		local flag = not prediction

		if not flag then
			flag = prediction.Enabled ~= true
			bit32.bxor(n5, 3418967786)
		end

		if flag then
			return arg
		end
		local v9 = GetDeltaVelocity(arg2)
		local values = prediction.Values
		local n9 = 1156962422

		if not values then
			values = {}
			n7 = bit32.bxor(n7 + n8, 29490147)
		end

		local x = values.X or 0.13
		local y = values.Y

		if not y then
			bit32.bxor(bit32.band(n7, n8), 1153536096)
			y = 0.13
		end

		return arg + v9 * Vector3New(x, y, values.Z or 0.13)
	end

	ApplyFuture = function(arg, arg2, arg3, arg4)
		local n5 = 793628479
		local n6 = 3517563548
		local n7 = 1802310988
		local character = arg2 and arg2.Character
		if not character then
			return arg
		end

		if not character:FindFirstChild("HumanoidRootPart") then
			return arg
		end

		if not arg4 then
			return arg
		end
		local enabled = arg4.Enabled
		local v9 = bit32.bxor(n6, n7)
		if enabled == false then
			return arg
		end
		local others = arg4[GetWeaponClass(arg3 or "")] or arg4.Others
		local lure = arg4.Lure
		local v10 = bit32.band(n7, v9)

		if not (lure == true) then
			others = others and others.Values
			local tbl4 = others or {}
			local v11 = GetDeltaVelocity(arg2)
			local v12 = Vector3New
			bit32.bxor(n5, 1950626826)
			local x = tbl4.X or 0.02301
			local y = tbl4.Y or 0.08002
			local z = tbl4.Z

			if not z then
				local n8 = bit32.band(v10, 3114838469) + 38016000
				z = 0.013005
			end

			return arg + v11 * v12(x, y, z)
		end

		local v11, v12, v13 = GetLureFutureValues(arg2, arg3, others)
		local n8 = v9 // bit32.rshift(v10, 13)
		local n9 = Vector3New(v11.X * v11.X, v11.Y * v11.Y, v11.Z * v11.Z) * 0.5
		return arg + v12 * v11 + Vector3New(v13.X * n9.X, v13.Y * n9.Y, v13.Z * n9.Z)
	end

	local v9, tbl4

	do
		local v10 = RaycastParamsNew()
		local v11 = bit32.bxor(v7, 0)
		local v12 = bit32.band(n4 + 4050468627, v11)
		VisibilityParams = v10
		VisibilityParams.FilterType = EnumExclude
		VisibilityParams.IgnoreWater = true

		IsTyping = function()
			return UserInputService:GetFocusedTextBox() ~= nil
		end

		IsCrew = function(arg)
			local n5 = 2688758709
			local n6 = 2704075137
			arg = arg and arg:GetAttribute("CrewID")
			bit32.bxor(n5, 3489853919)
			local attribute = localPlayer:GetAttribute("CrewID")
			return arg and attribute and arg == attribute or false
		end

		local v13 = bit32.bxor(v7, 0)
		local v14 = bit32.band(v8, v13)
		VisibilityFilter = {}
		VisibilityCache = {}
		VisibilityCacheFrame = 0
		local v15 = bit32.bxor(v7, 0)
		local v16 = bit32.bor(v12, v15)

		IsVisible = function(arg, arg2)
			local n5 = 3312633823
			local n6 = 2384374854
			local v17 = MathFloor(Clock() * 60 + 0.5)
			local n7 = 1607431853

			if v17 ~= VisibilityCacheFrame then
				VisibilityCacheFrame = v17
				table.clear(VisibilityCache)
			end

			local flag

			if arg2 then
				flag = VisibilityCache[arg2] ~= nil
				n6 = n6 // 162 + 2369656491
			else
				flag = arg2
			end

			if flag then
				return VisibilityCache[arg2]
			end
			local n8 = n6 // 2
			local position = currentCamera.CFrame.Position
			local n9 = arg - position
			local character = localPlayer.Character
			local n10 = 0

			if character then
				local v18 = VisibilityFilter
				local v19 = bit32.bor(n7, 2217576266)
				v18[1] = character
				n7 = bit32.bxor(v19, 2149613890)
				n10 = 1
			end

			local n11 = n10 + 1
			VisibilityFilter[n11] = CachedIgnored
			local n12 = n11 + 1
			VisibilityFilter[n12] = CachedBush
			bit32.bxor(n5, 57820822)

			for i = n12 + 1, #VisibilityFilter do
				VisibilityFilter[i] = nil
			end

			local v18 = VisibilityParams
			local v19 = bit32.rshift(n7, 22)
			v18.FilterDescendantsInstances = VisibilityFilter
			local hit = Workspace:Raycast(position, n9, VisibilityParams)
			local flag2 = true

			if hit then
				local instance = hit.Instance

				if instance then
					local model = instance:FindFirstAncestorOfClass("Model")

					if not model or not model:FindFirstChildOfClass("Humanoid") then
						flag2 = false
					end
				else
					flag2 = false
				end
			end

			if arg2 then
				local v20 = VisibilityCache
				local v21 = bit32.rshift(v19, 2)
				v20[arg2] = flag2
				bit32.bxor(v21, 288)
			end

			return flag2
		end

		GetGroundPosition = function(arg, filterDescendantsInstances)
			local n5 = 1087401355
			local n6 = 71345305
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = EnumExclude
			raycastParams.FilterDescendantsInstances = filterDescendantsInstances or {}
			local v17 = table.pack(bit32.band(n5, 4294967295))
			local v18 = table.pack(bit32.band(v17[1], 65535))
			bit32.band(v18[1] * 48601 + bit32.lshift(bit32.band(v18[1] * 0 + bit32.rshift(v17[1], 16) * 48601, 65535), 16), 4294967295)
			local hit = Workspace:Raycast(arg, Vector3New(0, -2000, 0), raycastParams)

			if hit then
				bit32.bxor(n6, 2289970894)
				hit = hit.Position
			end

			return hit or nil
		end

		RunPanicGround = function()
			local n5 = 2463821825
			local n6 = 3330007318
			local n7 = 1811531341
			local character = localPlayer.Character
			local n8 = 22305150
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not humanoidRootPart then
				return
			end
			local v17 = GetGroundPosition(humanoidRootPart.Position, { character })
			local n9 = n7 // n8
			if not v17 then
				return
			end
			local v18 = CFrameNew
			bit32.bxor(n6, 844202191)
			local v19 = v18(v17.X, v17.Y + 3, v17.Z)
			local n10 = humanoidRootPart.CFrame - humanoidRootPart.CFrame.Position
			bit32.bxor(n5, 2657212107)
			local n11 = n8 - n9 * n8
			humanoidRootPart.CFrame = v19 * n10
			humanoidRootPart.AssemblyLinearVelocity = Vector3Zero
			humanoidRootPart.AssemblyAngularVelocity = Vector3Zero

			if humanoid then
				local v20 = bit32.bxor(n11, 1259432286)
				humanoid.Jump = false
				humanoid:ChangeState(EnumLanded)
				bit32.bxor(v20, 1259432286)
			end
		end

		GetAntiFutureBoostMultiplier = function(arg)
			local n5 = 3179270375
			local n6 = 404904091
			local adjustDynamically = arg["Adjust Dynamically"]
			local flag = not adjustDynamically
			local v17 = table.pack(bit32.band(n6, 4294967295))
			local v18 = table.pack(bit32.band(v17[1], 65535))
			local v19 = bit32.band(41666 * v18[1] + bit32.lshift(bit32.band(41666 * bit32.rshift(v17[1], 16) + 6841 * v18[1], 65535), 16), 4294967295)

			if not flag then
				local enabled = adjustDynamically.Enabled
				bit32.bxor(n5, 4175654227)
				flag = not enabled
			end

			if flag or not State.AntiFuture.BoostPending then
				return 1
			end
			State.AntiFuture.BoostPending = false
			local multiplier = adjustDynamically.Multiplier
			return multiplier or 3
		end

		TriggerAntiFutureBoost = function()
			local n5 = 341751752
			local antiFuture = fn()["Anti Future"]
			local adjustDynamically = antiFuture["Adjust Dynamically"]
			local flag = not antiFuture.Enabled
			local n6 = 3895846722
			local n7 = 341751752
			local flag2

			if flag then
				flag2 = flag
			else
				flag2 = not State.AntiFuture.Active
				bit32.bxor(n6, 85358711)
				n5 = n5 // 40 - 3961759337
			end

			if flag2 or not adjustDynamically or not adjustDynamically.Enabled then
				return
			end
			local v17 = State
			bit32.bxor(n5, 4078342610)
			v17.AntiFuture.BoostPending = true
		end

		DistancePointToSegment = function(arg, arg2, arg3)
			local n5 = 1683959447
			local n6 = 370933650
			local n7 = arg3 - arg2
			local v17 = n7:Dot(n7)
			if v17 <= 1e-06 then
				return (arg - arg2).Magnitude
			end
			local v18 = MathClamp
			local n8 = arg - arg2
			local n9 = n5 // bit32.bxor(n6, n5)
			return (arg - arg2 + n7 * v18(n8:Dot(n7) / v17, 0, 1)).Magnitude
		end

		RunAntiFutureToggle = function()
			local n5 = 3098175936
			local n6 = 1812911380
			local v17 = n6
			local n7 = 806093167
			if not fn()["Anti Future"].Enabled then
				return
			end

			if State.AntiFuture.Active then
				State.AntiFuture.Active = false
				State.AntiFuture.LastSpoofedVelocity = nil
				local n8 = n6 - v17
				local n9 = v17 // 165
				State.AntiFuture.LastServerPosition = nil
				State.AntiFuture.LastSpoofTime = nil
				State.AntiFuture.BoostPending = false
				local v18 = State
				local v19 = bit32.band(n8, n9)

				if v18.AntiFuture.Connection then
					State.AntiFuture.Connection:Disconnect()
					State.AntiFuture.Connection = nil
				end

				return
			end

			State.AntiFuture.Active = true
			local antiFuture = State.AntiFuture
			local v18 = bit32.bor(n6, 2096101540)
			local n8 = n7 + 88190071
			antiFuture.BoostPending = false

			local function fn4(arg, arg2)
				local v19 = MathRandom(arg, arg2)
				local n9

				if MathRandom(0, 1) == 0 then
					n9 = -v19
				else
					n9 = v19
				end

				return n9
			end

			local v19 = State
			bit32.bxor(n5, 600436116)
			local antiFuture2 = v19.AntiFuture
			local v20 = TrackConn
			local v21 = RunService
			bit32.lshift(v18, 15)

			antiFuture2.Connection = v20(v21.Heartbeat:Connect(function()
				local n9 = 4204173035
				local v22 = bit32.bxor(n8, 2990090777)
				local n10 = 3818728003
				local n11 = 313109903
				local antiFuture3 = fn()["Anti Future"]
				local v23 = bit32.band(v22, 665843042)
				local options = antiFuture3.Options or {}
				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

				if character then
					character = character:FindFirstChildOfClass("Humanoid")
					n10 = bit32.bxor(n10 + 1596305238, 2707420122)
				end

				local v24 = State
				local v25 = bit32.bxor(n11, 304049558)
				local flag = not v24.AntiFuture.Active
				bit32.bxor(n9, 313109903)

				if flag then
					local antiFuture4 = State.AntiFuture
					local n12 = n10 - bit32.bxor(v25, 0)
					antiFuture4.LastSpoofedVelocity = nil
					State.AntiFuture.LastServerPosition = nil
					State.AntiFuture.LastSpoofTime = nil
					local antiFuture5 = State.AntiFuture
					local v26 = bit32.rshift(v23, 5)
					antiFuture5.BoostPending = false
					local v27 = State
					bit32.bxor(n12, 4294967295)

					if v27.AntiFuture.Connection then
						State.AntiFuture.Connection:Disconnect()
						local antiFuture6 = State.AntiFuture
						local v28 = bit32.lshift(v26, 18)
						antiFuture6.Connection = nil
						bit32.bxor(v28, 2425693227)
					end

					return
				end

				if not humanoidRootPart then
					return
				end

				if options["Air Only"] and character then
					local state = character:GetState()
					local flag2 = state ~= EnumJumping

					if flag2 then
						local v26 = EnumFreefall
						local v27 = table.pack(bit32.band(v25, 4294967295))
						local v28 = table.pack(bit32.band(v27[1], 65535))
						local v29 = bit32.band(2957 * v28[1] + bit32.lshift(bit32.band(2957 * bit32.rshift(v27[1], 16) + 3006 * v28[1], 65535), 16), 4294967295)
						local v30 = bit32.band(n10, v23)
						local v31 = table.pack(bit32.band(bit32.bor(v25, 331181839), 4294967295))
						local v32 = table.pack(bit32.band(v31[1], 65535))
						local v33 = bit32.band(62580 * v32[1] + bit32.lshift(bit32.band(62580 * bit32.rshift(v31[1], 16) + 62529 * v32[1], 65535), 16), 4294967295)
						local v34 = bit32.band(v30, v23)
						local v35 = table.pack(bit32.band(bit32.band(v25, 331181839), 4294967295))
						local v36 = table.pack(bit32.band(v35[1], 65535))
						flag2 = state ~= v26
						v25 = bit32.bxor(v29 + 356372547 + v33 + bit32.band(62578 * v36[1] + bit32.lshift(bit32.band(62578 * bit32.rshift(v35[1], 16) + 62529 * v36[1], 65535), 16), 4294967295), 331181839)
						n10 = bit32.bxor(v34, 3768134145)
					end

					if flag2 then
						local antiFuture4 = State.AntiFuture
						local n12 = v23 + bit32.bxor(v25, 0)
						antiFuture4.LastServerPosition = humanoidRootPart.Position
						State.AntiFuture.LastSpoofedVelocity = nil
						State.AntiFuture.LastSpoofTime = nil
						return
					end
				end

				local spoofChance = options["Spoof Chance"]

				if not spoofChance then
					local v26 = table.pack(bit32.band(n10, 4294967295))
					local v27 = table.pack(bit32.band(v23, 4294967295))
					local v28 = table.pack(bit32.band(v26[1], 65535))
					local v29 = table.pack(bit32.rshift(v26[1], 16))
					local v30 = table.pack(bit32.band(v27[1], 65535))
					n10 = bit32.bxor(bit32.band(v28[1] * v30[1] + bit32.lshift(bit32.band(v28[1] * bit32.rshift(v27[1], 16) + v29[1] * v30[1], 65535), 16), 4294967295), 1813501669)
					spoofChance = 100
				end

				if spoofChance < 100 and MathRandom(1, 100) > spoofChance then
					State.AntiFuture.LastServerPosition = humanoidRootPart.Position
					State.AntiFuture.LastSpoofedVelocity = nil
					local v26 = State
					local v27 = bit32.bxor(v25, 0)
					bit32.bxor(v23, v27)
					v26.AntiFuture.LastSpoofTime = nil
					return
				end

				local n12 = (options.Strength or 400) * GetAntiFutureBoostMultiplier(antiFuture3)
				local n13 = bit32.rshift(n10, 20)
				local randomness = options.Randomness or 3
				local n14 = v23 - 1076768364

				if randomness < 1 then
					randomness = 1
				end

				local flag2 = options.Vertical ~= false
				local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
				local v26

				if antiFuture3.Direction == "Vertical" then
					local v27 = Vector3New
					local n15 = n13 * 22471
					flag2 = flag2 and fn4(n12, n12 * randomness) or 0
					v26 = v27(0, flag2, 0)
					n13 = n15 - 81813270
				else
					local v27 = n13
					local n15

					if antiFuture3.Direction == "Behind" then
						local n16 = n13 // 11
						local v28 = Vector3New(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)
						local n17 = v28.Magnitude > 1 and -v28.Unit or -humanoidRootPart.CFrame.LookVector
						local v29 = MathRandom
						local v30 = bit32.bxor(v25, 0)
						local v31 = table.pack(bit32.band(v27, 4294967295))
						local v32 = table.pack(bit32.band(v30, 4294967295))
						local v33 = table.pack(bit32.band(v31[1], 65535))
						local v34 = table.pack(bit32.rshift(v31[1], 16))
						local v35 = table.pack(bit32.band(v32[1], 65535))
						local v36 = bit32.band(v33[1] * v35[1] + bit32.lshift(bit32.band(v33[1] * bit32.rshift(v32[1], 16) + v34[1] * v35[1], 65535), 16), 4294967295)
						local v37 = bit32.bxor(v25, 130806500)
						local n18 = n16 // 17
						local v38 = v29(n12, n12 * randomness)
						flag2 = flag2 and fn4(n12, n12 * randomness) or 0
						n15 = v36 - 1103789264
						v26 = Vector3New(n17.X * v38, flag2, n17.Z * v38)
						v25 = bit32.bxor(v37, 130806500)
						n13 = n18 + 3622
					else
						local n16

						if antiFuture3.Direction == "Kinematic" then
							local gravity = Workspace.Gravity

							if not gravity then
								n13 = n13 // 11 + 3310
								gravity = 196.2
							end

							n16 = v27 - n13
							local n17 = -assemblyLinearVelocity * n12 / MathMax(assemblyLinearVelocity.Magnitude, 16)

							if flag2 then
								n16 //= n13
								flag2 = n17.Y - gravity * MathRandom(n12, n12 * randomness) / 100
							end

							flag2 = flag2 or 0
							local v28 = Vector3New
							local v29 = bit32.bxor(v25, 300511279)
							local x = n17.X
							local z = n17.Z
							local v30 = bit32.bxor(v29, 0)
							local v31 = table.pack(bit32.band(n13, 4294967295))
							local v32 = table.pack(bit32.band(v30, 4294967295))
							local v33 = table.pack(bit32.band(v31[1], 65535))
							local v34 = table.pack(bit32.rshift(v31[1], 16))
							local v35 = table.pack(bit32.band(v32[1], 65535))
							local v36 = bit32.band(v33[1] * v35[1] + bit32.lshift(bit32.band(v33[1] * bit32.rshift(v32[1], 16) + v34[1] * v35[1], 65535), 16), 4294967295)
							v26 = v28(x, flag2, z)
							v25 = bit32.bxor(v29, 300511279)
							n13 = v36 - 435233229
						else
							local v28 = Vector3New
							local v29 = fn4(n12, n12 * randomness)
							local n17 = v27 // n13
							v26 = v28(v29, flag2 and fn4(n12, n12 * randomness) or 0, fn4(n12, n12 * randomness))
							n16 = bit32.bxor(n17, 1)
						end

						n15 = n16 - 446191935
					end

					n14 = n15 - 510742475
				end

				local antiFuture4 = State.AntiFuture
				local v27 = bit32.bxor(v25, 0)
				local v28 = bit32.bxor(n13, v27)
				antiFuture4.LastSpoofedVelocity = v26
				State.AntiFuture.LastServerPosition = humanoidRootPart.Position
				State.AntiFuture.LastSpoofTime = Clock()
				humanoidRootPart.AssemblyLinearVelocity = v26
				RunService.RenderStepped:Wait()
				local n15 = n14 // bit32.bxor(v25, 0)
				humanoidRootPart.AssemblyLinearVelocity = assemblyLinearVelocity
			end))
		end

		v9 = bit32.band(v14, 254543665)

		PassesConditions = function(arg, arg2)
			local n5 = 665721686
			local n6 = 517397629
			local n7 = 6011219918
			local n8 = n7
			local checks = fn().Main.Checks
			arg2 = arg2 and checks[arg2] or {}
			local character

			if arg then
				character = arg.Character
				n6 = bit32.bxor(bit32.bxor(n6, n8), 1716252622)
			else
				character = arg
			end

			if not character then
				return false
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if arg2.Knocked then
				local flag = not humanoid or humanoid.Health <= 0

				if not flag then
					local v17 = EnumDead
					flag = humanoid:GetState() == v17
					n8 = n8 - n6 + 517397629
				end

				if flag then
					return false
				end

				if CurrentGame.Knocked(arg) then
					return false
				end
			end

			if arg2.Grabbed then
				if CurrentGame.Grabbed(arg) then
					return false
				end
			end

			if arg2.Vehicle then
				if humanoid and humanoid.Sit then
					return false
				end
			end

			local v17 = bit32.band(n8, 1717798527)

			if arg2.Visible then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				if humanoidRootPart and not IsVisible(humanoidRootPart.Position, arg) then
					return false
				end
			end

			if arg2.Tool then
				local v18 = localPlayer
				local v19 = bit32.bor(n6, 31101394)
				local character2 = v18.Character
				if character2 and not character2:FindFirstChildOfClass("Tool") then
					bit32.band(v17, v19)
					return false
				end
				n6 = bit32.bxor(v19, 17301890)
			end

			if arg2["Self Knocked"] then
				if CurrentGame.Knocked(localPlayer) then
					return false
				end
			end

			if arg2.Crew then
				local v18 = IsCrew
				bit32.bxor(n5, 1312546055)
				local n9 = n6 - 4192650396
				if v18(arg) then
					return false
				end
			end

			return true
		end

		tbl4 = {}
		local v17 = table.pack(bit32.band(v16, 4294967295))
	end

	local v10 = table.pack(bit32.band(t10568_7092_1[1], 65535))
	local v11, n5, v12

	do
		local v13 = bit32.band(v10[1] * 10695 + bit32.lshift(bit32.band(v10[1] * 0 + bit32.rshift(t10568_7092_1[1], 16) * 10695, 65535), 16), 4294967295)
		tbl4["[Deagle]"] = CFrameNew(0, 0.382, -1.568)
		tbl4["[Revolver]"] = CFrameNew(-0.1, 0.4, 1.8)
		tbl4["[Double-Barrel SG]"] = CFrameNew(0, 0.25, -2.5)
		tbl4["[TacticalShotgun]"] = CFrameNew(0, 0.7, -3.8)
		local v14 = CFrameNew
		local v15 = bit32.band(v13 * 4, 1347026750)
		tbl4["[Silencer]"] = v14(0, 0.4, 1.3)
		v11 = bit32.bxor(v7, 263403988)
		tbl4["[SMG]"] = CFrameNew(2.5, 0.35, 0)
		n5 = v9 // 13 - v15
		local v16 = CFrameNew(0, 0.2, -1.7)
		local v17 = table.pack(bit32.band(v15, 4294967295))
		local v18 = table.pack(bit32.band(v17[1], 65535))
		v12 = bit32.band(v18[1] * 12222 + bit32.lshift(bit32.band(v18[1] * 0 + bit32.rshift(v17[1], 16) * 12222, 65535), 16), 4294967295)
		tbl4["[Rifle]"] = v16
	end

	tbl4["[Shotgun]"] = CFrameNew(0, 0.4, 2.4)
	tbl4["[Flintlock]"] = CFrameNew(0, 0.25, 2.5)
	tbl4["[AK47]"] = CFrameNew(0.6, 0.25, 0)
	tbl4["[Glock]"] = CFrameNew(0, 0.4, 1.5)
	tbl4["[AR]"] = CFrameNew(0, 0.3, -2)
	local v13, v14, v15

	do
		local v16 = CFrameNew(0, 0.3, -2.5)
		local v17 = bit32.bxor(v11, 0)
		local v18 = bit32.bxor(v12, v17)
		tbl4["[AUG]"] = v16
		tbl4["[Drum-Shotgun]"] = CFrameNew(0, 0.4, -2)
		tbl4["[DrumGun]"] = CFrameNew(0, 0.3, -1.5)
		tbl4["[LMG]"] = CFrameNew(0, 0.3, -2.5)
		local v19 = bit32.lshift((n5 // 2 - v12) // 253, 21)
		tbl4["[P90]"] = CFrameNew(0, 0.3, -1.8)
		tbl4["[SilencerAR]"] = CFrameNew(0, 0.3, -2)
		MuzzleOffsets = tbl4
		v13 = bit32.bxor(v11, 193555802)
		local tbl5 = { ["[Double-Barrel SG]"] = true }
		local n6 = v18 // 3 + bit32.bxor(v13, 0)
		tbl5["[TacticalShotgun]"] = true
		tbl5["[Tactical Shotgun]"] = true
		local v20 = bit32.bxor(v13, 0)
		local v21 = bit32.bxor(v19, v20)
		tbl5["[Tactical-Shotgun]"] = true
		tbl5["[Shotgun]"] = true
		tbl5["[Drum-Shotgun]"] = true
		ShotgunWeapons = tbl5
		local v22 = bit32.bxor(v13, 0)
		v14 = bit32.band(n6, v22)
		PistolWeapons = { ["[Revolver]"] = true, ["[Silencer]"] = true, ["[Glock]"] = true, ["[Deagle]"] = true }
		local v23 = bit32.bxor(v13, 0)
		v15 = bit32.band(v21, v23)
	end

	local fn4

	fn4 = function(arg)
		local n6 = 3657579624
		if ShotgunWeapons[arg] then
			return "Shotguns"
		end

		if PistolWeapons[arg] then
			return "Pistols"
		end
		return "Others"
	end

	local fn5

	fn5 = function(arg)
		local n6 = 1444264405
		local n7 = 100525450
		local n8 = 2226821600
		local shootingCooldown = arg and arg:FindFirstChild("ShootingCooldown")
		local n9 = 0.3

		if shootingCooldown then
			n9 = shootingCooldown.Value
		end

		local n10 = n8 // n7
		local delayChanger = fn().Modifications["Delay Changer"]
		local enabled = delayChanger.Enabled
		bit32.bxor(n6, 3256100364)
		local v16 = bit32.bor(n7, n10)
		if not enabled then
			return n9
		end
		local delay = delayChanger.Delay
		local weaponConfigs = delayChanger["Weapon Configs"]

		if weaponConfigs and weaponConfigs.Enabled and arg then
			local n11 = v16 * n10
			delay = weaponConfigs[fn4(arg.Name)].Delay or delay
			bit32.bxor(n11, 2251054602)
		end

		return delay
	end

	local fn6

	do
		local v16 = nil
		local flag = false

		local str = [[

local t = {
	"[Shotgun]",
	"[Drum-Shotgun]",
	"[Rifle]",
	"[TacticalShotgun]",
	"[AR]",
	"[AUG]",
	"[AK47]",
	"[LMG]",
	"[SilencerAR]"
}
local t2 = {
	Brainrot = "All"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CurrentCamera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local v1 = LocalPlayer:GetMouse()
local SkinAssets = ReplicatedStorage.SkinAssets
local v2 = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local v3 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage:WaitForChild("Animations"):WaitForChild("GunCombat"):WaitForChild("Shoot"))
local v4 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage:WaitForChild("Animations"):WaitForChild("GunCombat"):WaitForChild("ShootLeft"))
local v5 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Animations.GunCombat.ShootRight)
local v6 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage:WaitForChild("Animations"):WaitForChild("GunCombat"):WaitForChild("AimShoot"))
local v7 = workspace:GetServerTimeNow()
local isPlaceId = game.PlaceId == 88976059384565
local GunSoundPlay = require(ReplicatedStorage:WaitForChild("GunSoundPlay"))

local function evalColorSequence(p1, p2)
	if p2 == 0 then
		return p1.Keypoints[1].Value
	end

	if p2 == 1 then
		return p1.Keypoints[#p1.Keypoints].Value
	end

	for i = 1, #p1.Keypoints - 1 do
		local v1 = p1.Keypoints[i]
		local v2 = p1.Keypoints[i + 1]

		if v1.Time <= p2 and p2 < v2.Time then
			local v3 = (p2 - v1.Time) / (v2.Time - v1.Time)

			return Color3.new((v2.Value.R - v1.Value.R) * v3 + v1.Value.R, (v2.Value.G - v1.Value.G) * v3 + v1.Value.G, (v2.Value.B - v1.Value.B) * v3 + v1.Value.B)
		end
	end
end

local function playerShot(p1)
	if v2 ~= LocalPlayer.Character then
		v3 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Animations.GunCombat.Shoot)
		v4 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Animations.GunCombat.ShootLeft)
		v5 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Animations.GunCombat.ShootRight)
		v6 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Animations.GunCombat.AimShoot)
	end

	if _G.Aimed or (_G.MobleAimingIn or table.find(t, p1.Parent.Name)) then
		v6:Play()

		return
	end

	if p1:GetAttribute("DualWield") then
		v4:Play()
		v5:Play()
	else
		v3:Play()
	end
end

shared.playerShot = playerShot

local t3 = {
	getCanShoot = require(script.CanShoot),
	getAim = function(p1, p2)
		local v12 = RaycastParams.new()
		local t = { LocalPlayer.Character }
		local v2 = p2 or 200

		for v3, v4 in workspace.Ignored:GetChildren() do
			table.insert(t, v4)
		end

		v12.FilterDescendantsInstances = t
		v12.FilterType = Enum.RaycastFilterType.Exclude
		v12.IgnoreWater = true

		local v5

		if _G.MobileShiftLock or _G.MobleAimingIn then
			local Position = CurrentCamera.CFrame.Position
			local v6 = CurrentCamera.CFrame.LookVector * v2
			local v7 = workspace:Raycast(Position, v6, v12)

			v5 = if v7 then v7.Position else Position + v6
		else
			local v8 = CurrentCamera:ScreenPointToRay(v1.X, v1.Y)
			local v9 = workspace:Raycast(v8.Origin, v8.Direction * v2, v12)

			if v9 then
				v5 = v9.Position
			else
				local v10 = CurrentCamera.CFrame
				local LookVector = v10.LookVector
				local Origin = v8.Origin
				local Direction = v8.Direction

				v5 = Origin + Direction * ((v10.Position + v10.LookVector * v2 - Origin):Dot(LookVector) / Direction:Dot(LookVector))
			end
		end

		local v122 = v5 - p1

		return v122.Unit, v122.Magnitude
	end
}
local t4 = {}

function t3.shoot(p1)
	local Shooter = p1.Shooter
	local Handle = p1.Handle
	local BeamColor = p1.BeamColor
	local isReflecting = p1.isReflecting
	local Hit = p1.Hit
	local v1 = p1.Range or 200
	local v2 = Handle and Handle:GetAttribute("SkinName")
	local IsLeftHand = p1.IsLeftHand
	local v3 = Players:GetPlayerFromCharacter(Shooter)
	local v4 = v3 and v3:GetAttribute("GunFX") == true
	local _, v5 = t3.getAim(Handle.Position, v1)

	if Shooter ~= LocalPlayer.Character then
		v5 = v1
	end

	local v6 = p1.ForcedOrigin or Handle.Muzzle.WorldPosition
	local Unit = (p1.AimPosition - v6).Unit
	local v72 = RaycastParams.new()
	local t = {}
	local Ignored = require(game.ReplicatedStorage.MainModule).Ignored

	t[1] = Shooter
	t[2] = unpack(Ignored)
	v72.FilterDescendantsInstances = t
	v72.FilterType = Enum.RaycastFilterType.Exclude
	v72.IgnoreWater = true

	local v8, v9, v10

	if Hit then
		v8 = p1.Hit
		v9 = p1.AimPosition
		v10 = p1.Normal
	else
		local v11 = workspace:Raycast(v6, Unit * v1, v72)

		if v11 then
			v8 = v11.Instance
			v9 = v11.Position
			v10 = v11.Normal
		else
			v9 = v6 + Unit * math.min(v5, v1)
			v8 = nil
			v10 = nil
		end
	end

	if v8 then
		local isName = v8.Name == "Head"
	end

	if Shooter ~= LocalPlayer.Character then
		local BoostChar = LocalPlayer.Character;
		local BoostHRP = BoostChar and BoostChar:FindFirstChild('HumanoidRootPart');
		if BoostHRP then
			local RayTouchingMe = (v8 and v8:IsDescendantOf(BoostChar)) or DistancePointToSegment(BoostHRP.Position, v6, v9) <= 4;
			if RayTouchingMe then
				TriggerAntiFutureBoost();
			end;
		end;
	end;

	local BULLET_RAYS = Instance.new("Part")

	BULLET_RAYS:SetAttribute("OwnerCharacter", Shooter.Name)
	BULLET_RAYS.Name = "BULLET_RAYS"
	BULLET_RAYS.Anchored = true
	BULLET_RAYS.CanCollide = false
	BULLET_RAYS.Size = Vector3.new(0, 0, 0)
	BULLET_RAYS.Transparency = 1
	game.Debris:AddItem(BULLET_RAYS, 1)
	BULLET_RAYS.CFrame = CFrame.new(v6, v9)
	BULLET_RAYS.Material = Enum.Material.SmoothPlastic
	BULLET_RAYS.Parent = workspace.Ignored.Siren.Radius

	local Attachment = Instance.new("Attachment")

	Attachment.Position = Vector3.new(0, 0, 0)
	Attachment.Parent = BULLET_RAYS

	local Attachment2 = Instance.new("Attachment")
	local v12 = -(v9 - v6).magnitude

	Attachment2.Position = Vector3.new(0, 0, v12)
	Attachment2.Parent = BULLET_RAYS

	local v13 = false
	local v14 = nil
	local NewGunBeam

	if Handle then
		local v15 = Handle.Parent and Handle.Parent.Name

		if v15 and not v4 and (v2 and v2 ~= "" or SkinAssets.GunSkinMuzzleParticle:FindFirstChild(v15)) then
			v2 = v2 ~= "" and v2 or v15

			local v19 = if IsLeftHand then "LeftMuzzle" else "Muzzle"

			if SkinAssets.GunSkinMuzzleParticle:FindFirstChild(v2) then
				if not isReflecting and (SkinAssets.GunSkinMuzzleParticle[v2]:FindFirstChild(v19) or IsLeftHand) then
					local v20 = Handle.Parent:FindFirstChild("Default") and Handle.Parent.Default:FindFirstChild("Mesh") and Handle.Parent.Default.Mesh:FindFirstChild(v19) or Handle:FindFirstChild(v19)
					local v21

					if IsLeftHand then
						local v22 = Handle.Parent:FindFirstChild("Default") and Handle.Parent.Default:FindFirstChild("Mesh") and Handle.Parent.Default.Mesh.DualWieldLeftHandMesh:FindFirstChild(v19) or v20

						v21 = if v22 == v20 then false else true

						if v21 then
							v20 = v22
						end
					else
						v21 = false
					end

					if v20 then
						for v24, v25 in (if v21 then v20 elseif SkinAssets.GunSkinMuzzleParticle[v2].Muzzle:FindFirstChild("Different_GunMuzzle") then SkinAssets.GunSkinMuzzleParticle[v2][v19].Different_GunMuzzle[v15] else SkinAssets.GunSkinMuzzleParticle[v2][v19]):GetChildren() do
							local v26 = v25:GetAttribute("EmitCount") or 1
							local v27 = IsLeftHand and v25 or v25:Clone()

							v27.Parent = v20
							v27:Emit(v26)

							if not v21 then
								task.delay(v27.Lifetime.Max, function()
									v27:Destroy()
								end)
							end
						end
					end
				elseif not isReflecting then
					local v28 = SkinAssets.GunSkinMuzzleParticle[v2]:GetChildren()
					local v29 = v28[math.random(#v28)]:Clone()

					v29.Parent = Attachment
					v29:Emit(v29.Rate)
				end

				v13 = true
			end

			if SkinAssets.GunBeam:FindFirstChild(v2) then
				local v30 = SkinAssets.GunBeam[v2]
				local v31 = if IsLeftHand then "LeftGunBeam" else "GunBeam"
				local v32 = v30:FindFirstChild(v31) or v30.GunBeam
				local _2 = IsLeftHand and (v32:IsA("BasePart") and v32:FindFirstChild("LeftHandBeam"))

				if v32:IsA("BasePart") then
					local t5 = {
						Parent = nil,
						Attachment0 = nil,
						Attachment1 = nil
					}
					local Different_GunBeam = v32:FindFirstChild("Different_GunBeam")

					if Different_GunBeam and Different_GunBeam:FindFirstChild(v15) then
						local v33 = Different_GunBeam[v15][v31]

						if v33 and v33:IsA("BasePart") then
							v14 = v33:Clone()
							NewGunBeam = t5
						else
							NewGunBeam = v33 and v33:Clone() or t5
						end
					else
						v14 = v32:Clone()
						NewGunBeam = t5
					end
				else
					NewGunBeam = v32:Clone()
				end
			else
				local v36 = game.ReplicatedStorage.GunBeam:Clone()

				NewGunBeam = v36
				v36.Color = BeamColor and ColorSequence.new(BeamColor) or v36.Color
			end
		else
			local v16, v17

			v16 = game.ReplicatedStorage.GunBeam:Clone()
			v17 = BeamColor and ColorSequence.new(BeamColor) or v16.Color
			NewGunBeam = v16
			v16.Color = v17
		end
	else
		NewGunBeam = nil
	end

	task.spawn(function()
		if v14 then
			local magnitude = (v9 - v6).magnitude
			local v1 = magnitude / 725

			v14.Anchored = true
			v14.CanCollide = false
			v14.CanQuery = false
			v14.CFrame = CFrame.new(v6, v9)

			local v22 = v14.CFrame * CFrame.new(0, 0, -magnitude)

			v14.Parent = workspace.Ignored.Siren.Radius
			task.delay(v1 + 5, function()
				v14:Destroy()
				v14 = nil
			end)

			if v14:GetAttribute("SpecialEffects") then
				for k, v in pairs(v14:GetDescendants()) do
					if v:IsA("Trail") and v:GetAttribute("ColorRandom") then
						v.Color = ColorSequence.new(evalColorSequence(v:GetAttribute("ColorRandom"), math.random()))
					end
				end
			end

			local v42 = game:GetService("TweenService"):Create(v14, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
				CFrame = v14.CFrame * CFrame.new(0, 0, -0.1)
			})

			v42:Play()
			task.wait(0.05)

			if v42.PlaybackState ~= Enum.PlaybackState.Completed then
				v42:Pause()
			end

			local v5 = nil

			if _G.Reduce_Lag and not v14:GetAttribute("NoSlow") or v14:GetAttribute("LOWGFX") then
				v14.CFrame = v22
			else
				local v62 = game:GetService("TweenService"):Create(v14, TweenInfo.new(v1, Enum.EasingStyle.Linear), {
					CFrame = v22
				})

				v62:Play()
				task.wait(v1)
				v5 = v62
			end

			if v14:FindFirstChild("Impact") and (v8 and (v10 and not v8.Parent:FindFirstChild("Humanoid"))) then
				if v5 and v5.PlaybackState ~= Enum.PlaybackState.Completed then
					task.wait(0.05)
				end

				if not v14:FindFirstChild("NoNormal") then
					v14.CFrame = CFrame.new(v9, v9 - v10)
				end

				for k, v in pairs(v14.Impact:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						v:Emit(v:GetAttribute("EmitCount") or 1)
					end
				end
			else
				for k, v in pairs(v14:GetChildren()) do
					if v:IsA("BasePart") then
						v.Transparency = 1
					end
				end
			end

			if v14 then
				for k, v in pairs(v14:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					end
				end
			end
		elseif v8 and (v8:IsDescendantOf(workspace.MAP) and (not v4 and (v2 and (SkinAssets.GunBeam:FindFirstChild(v2) and SkinAssets.GunBeam[v2]:FindFirstChild("Impact"))))) then
			local v7 = SkinAssets.GunBeam[v2].Impact:Clone()

			v7.Parent = workspace.Ignored
			v7:PivotTo(CFrame.new(v9, v9 + v10 * 5) * CFrame.Angles(-1.5707963267948966, 0, 0))

			for k, v in pairs(v7:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(v:GetAttribute("EmitCount") or 1)
				end
			end

			task.delay(1.5, function()
				v7:Destroy()
				v7 = nil
			end)
		end

		local PointLight = Instance.new("PointLight")

		PointLight.Brightness = 0.5
		PointLight.Range = 15
		PointLight.Shadows = true
		PointLight.Color = Color3.new(255 / 255, 255 / 255, 255 / 255)
		PointLight.Parent = BULLET_RAYS

		local ShootBBGUI = Handle:FindFirstChild("ShootBBGUI")

		if not ShootBBGUI or v13 then
			return
		end

		local Shoot = ShootBBGUI:FindFirstChild("Shoot")

		if not Shoot then
			return
		end

		Shoot.Size = UDim2.new(0, 0, 0, 0)
		Shoot.ImageTransparency = 1
		Shoot.Visible = true
		TweenService:Create(Shoot, TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.In, 0, false, 0), {
			ImageTransparency = 0.4,
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
		TweenService:Create(PointLight, TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.In, 0, false, 0), {
			Range = 0
		}):Play()
		wait(0.4)
		BULLET_RAYS:Destroy()
		TweenService:Create(Shoot, TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.In, 0, false, 0), {
			ImageTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
		wait(0.2)
		Shoot.Visible = false
	end)
	NewGunBeam.Attachment0 = Attachment
	NewGunBeam.Attachment1 = Attachment2
	NewGunBeam.Name = "NewGunBeam"
	NewGunBeam.Parent = BULLET_RAYS

	if Shooter == LocalPlayer.Character and workspace:GetServerTimeNow() - v7 > 0.95 then
		playerShot(Handle)
	end

	if not t4[Handle] then
		local v39 = v2 or "None"

		task.spawn(GunSoundPlay.SoundPlay, Handle, t2[v39] ~= "All" and not (t2[v39] and t2[v39][Handle.Parent.Name]), v4)
		t4[Handle] = true
		task.delay(0.021, function()
			t4[Handle] = nil
		end)
	end

	task.spawn(function()
		if not Handle:GetAttribute("DualWield") or IsLeftHand then
			return
		end

		t3.shoot({
			IsLeftHand = true,
			Shooter = Shooter,
			Handle = Handle,
			ForcedOrigin = Handle.Parent.Default.Mesh.DualWieldLeftHandMesh.LeftMuzzle.WorldPosition,
			AimPosition = v9,
			BeamColor = BeamColor,
			Hit = Hit,
			Range = v1
		})
	end)

	return v9, v8, v10
end

return t3
]]

		fn6 = function()
			type(0)
			local n6 = 482603243
			local n7 = 1011625239
			local n8 = 494308117
			local n9 = 891617809
			local n10 = 8803859192
			if flag then
				return v16
			end
			flag = true
			local v17 = type
			local v18 = bit32.bxor(n10, 465923852)
			local n11 = n9 * 3
			if v17(loadstring) ~= "function" then
				return nil
			end

			local flag2 = type([[

local t = {
	"[Shotgun]",
	"[Drum-Shotgun]",
	"[Rifle]",
	"[TacticalShotgun]",
	"[AR]",
	"[AUG]",
	"[AK47]",
	"[LMG]",
	"[SilencerAR]"
}
local t2 = {
	Brainrot = "All"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CurrentCamera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local v1 = LocalPlayer:GetMouse()
local SkinAssets = ReplicatedStorage.SkinAssets
local v2 = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local v3 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage:WaitForChild("Animations"):WaitForChild("GunCombat"):WaitForChild("Shoot"))
local v4 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage:WaitForChild("Animations"):WaitForChild("GunCombat"):WaitForChild("ShootLeft"))
local v5 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Animations.GunCombat.ShootRight)
local v6 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage:WaitForChild("Animations"):WaitForChild("GunCombat"):WaitForChild("AimShoot"))
local v7 = workspace:GetServerTimeNow()
local isPlaceId = game.PlaceId == 88976059384565
local GunSoundPlay = require(ReplicatedStorage:WaitForChild("GunSoundPlay"))

local function evalColorSequence(p1, p2)
	if p2 == 0 then
		return p1.Keypoints[1].Value
	end

	if p2 == 1 then
		return p1.Keypoints[#p1.Keypoints].Value
	end

	for i = 1, #p1.Keypoints - 1 do
		local v1 = p1.Keypoints[i]
		local v2 = p1.Keypoints[i + 1]

		if v1.Time <= p2 and p2 < v2.Time then
			local v3 = (p2 - v1.Time) / (v2.Time - v1.Time)

			return Color3.new((v2.Value.R - v1.Value.R) * v3 + v1.Value.R, (v2.Value.G - v1.Value.G) * v3 + v1.Value.G, (v2.Value.B - v1.Value.B) * v3 + v1.Value.B)
		end
	end
end

local function playerShot(p1)
	if v2 ~= LocalPlayer.Character then
		v3 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Animations.GunCombat.Shoot)
		v4 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Animations.GunCombat.ShootLeft)
		v5 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Animations.GunCombat.ShootRight)
		v6 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Animations.GunCombat.AimShoot)
	end

	if _G.Aimed or (_G.MobleAimingIn or table.find(t, p1.Parent.Name)) then
		v6:Play()

		return
	end

	if p1:GetAttribute("DualWield") then
		v4:Play()
		v5:Play()
	else
		v3:Play()
	end
end

shared.playerShot = playerShot

local t3 = {
	getCanShoot = require(script.CanShoot),
	getAim = function(p1, p2)
		local v12 = RaycastParams.new()
		local t = { LocalPlayer.Character }
		local v2 = p2 or 200

		for v3, v4 in workspace.Ignored:GetChildren() do
			table.insert(t, v4)
		end

		v12.FilterDescendantsInstances = t
		v12.FilterType = Enum.RaycastFilterType.Exclude
		v12.IgnoreWater = true

		local v5

		if _G.MobileShiftLock or _G.MobleAimingIn then
			local Position = CurrentCamera.CFrame.Position
			local v6 = CurrentCamera.CFrame.LookVector * v2
			local v7 = workspace:Raycast(Position, v6, v12)

			v5 = if v7 then v7.Position else Position + v6
		else
			local v8 = CurrentCamera:ScreenPointToRay(v1.X, v1.Y)
			local v9 = workspace:Raycast(v8.Origin, v8.Direction * v2, v12)

			if v9 then
				v5 = v9.Position
			else
				local v10 = CurrentCamera.CFrame
				local LookVector = v10.LookVector
				local Origin = v8.Origin
				local Direction = v8.Direction

				v5 = Origin + Direction * ((v10.Position + v10.LookVector * v2 - Origin):Dot(LookVector) / Direction:Dot(LookVector))
			end
		end

		local v122 = v5 - p1

		return v122.Unit, v122.Magnitude
	end
}
local t4 = {}

function t3.shoot(p1)
	local Shooter = p1.Shooter
	local Handle = p1.Handle
	local BeamColor = p1.BeamColor
	local isReflecting = p1.isReflecting
	local Hit = p1.Hit
	local v1 = p1.Range or 200
	local v2 = Handle and Handle:GetAttribute("SkinName")
	local IsLeftHand = p1.IsLeftHand
	local v3 = Players:GetPlayerFromCharacter(Shooter)
	local v4 = v3 and v3:GetAttribute("GunFX") == true
	local _, v5 = t3.getAim(Handle.Position, v1)

	if Shooter ~= LocalPlayer.Character then
		v5 = v1
	end

	local v6 = p1.ForcedOrigin or Handle.Muzzle.WorldPosition
	local Unit = (p1.AimPosition - v6).Unit
	local v72 = RaycastParams.new()
	local t = {}
	local Ignored = require(game.ReplicatedStorage.MainModule).Ignored

	t[1] = Shooter
	t[2] = unpack(Ignored)
	v72.FilterDescendantsInstances = t
	v72.FilterType = Enum.RaycastFilterType.Exclude
	v72.IgnoreWater = true

	local v8, v9, v10

	if Hit then
		v8 = p1.Hit
		v9 = p1.AimPosition
		v10 = p1.Normal
	else
		local v11 = workspace:Raycast(v6, Unit * v1, v72)

		if v11 then
			v8 = v11.Instance
			v9 = v11.Position
			v10 = v11.Normal
		else
			v9 = v6 + Unit * math.min(v5, v1)
			v8 = nil
			v10 = nil
		end
	end

	if v8 then
		local isName = v8.Name == "Head"
	end

	if Shooter ~= LocalPlayer.Character then
		local BoostChar = LocalPlayer.Character;
		local BoostHRP = BoostChar and BoostChar:FindFirstChild('HumanoidRootPart');
		if BoostHRP then
			local RayTouchingMe = (v8 and v8:IsDescendantOf(BoostChar)) or DistancePointToSegment(BoostHRP.Position, v6, v9) <= 4;
			if RayTouchingMe then
				TriggerAntiFutureBoost();
			end;
		end;
	end;

	local BULLET_RAYS = Instance.new("Part")

	BULLET_RAYS:SetAttribute("OwnerCharacter", Shooter.Name)
	BULLET_RAYS.Name = "BULLET_RAYS"
	BULLET_RAYS.Anchored = true
	BULLET_RAYS.CanCollide = false
	BULLET_RAYS.Size = Vector3.new(0, 0, 0)
	BULLET_RAYS.Transparency = 1
	game.Debris:AddItem(BULLET_RAYS, 1)
	BULLET_RAYS.CFrame = CFrame.new(v6, v9)
	BULLET_RAYS.Material = Enum.Material.SmoothPlastic
	BULLET_RAYS.Parent = workspace.Ignored.Siren.Radius

	local Attachment = Instance.new("Attachment")

	Attachment.Position = Vector3.new(0, 0, 0)
	Attachment.Parent = BULLET_RAYS

	local Attachment2 = Instance.new("Attachment")
	local v12 = -(v9 - v6).magnitude

	Attachment2.Position = Vector3.new(0, 0, v12)
	Attachment2.Parent = BULLET_RAYS

	local v13 = false
	local v14 = nil
	local NewGunBeam

	if Handle then
		local v15 = Handle.Parent and Handle.Parent.Name

		if v15 and not v4 and (v2 and v2 ~= "" or SkinAssets.GunSkinMuzzleParticle:FindFirstChild(v15)) then
			v2 = v2 ~= "" and v2 or v15

			local v19 = if IsLeftHand then "LeftMuzzle" else "Muzzle"

			if SkinAssets.GunSkinMuzzleParticle:FindFirstChild(v2) then
				if not isReflecting and (SkinAssets.GunSkinMuzzleParticle[v2]:FindFirstChild(v19) or IsLeftHand) then
					local v20 = Handle.Parent:FindFirstChild("Default") and Handle.Parent.Default:FindFirstChild("Mesh") and Handle.Parent.Default.Mesh:FindFirstChild(v19) or Handle:FindFirstChild(v19)
					local v21

					if IsLeftHand then
						local v22 = Handle.Parent:FindFirstChild("Default") and Handle.Parent.Default:FindFirstChild("Mesh") and Handle.Parent.Default.Mesh.DualWieldLeftHandMesh:FindFirstChild(v19) or v20

						v21 = if v22 == v20 then false else true

						if v21 then
							v20 = v22
						end
					else
						v21 = false
					end

					if v20 then
						for v24, v25 in (if v21 then v20 elseif SkinAssets.GunSkinMuzzleParticle[v2].Muzzle:FindFirstChild("Different_GunMuzzle") then SkinAssets.GunSkinMuzzleParticle[v2][v19].Different_GunMuzzle[v15] else SkinAssets.GunSkinMuzzleParticle[v2][v19]):GetChildren() do
							local v26 = v25:GetAttribute("EmitCount") or 1
							local v27 = IsLeftHand and v25 or v25:Clone()

							v27.Parent = v20
							v27:Emit(v26)

							if not v21 then
								task.delay(v27.Lifetime.Max, function()
									v27:Destroy()
								end)
							end
						end
					end
				elseif not isReflecting then
					local v28 = SkinAssets.GunSkinMuzzleParticle[v2]:GetChildren()
					local v29 = v28[math.random(#v28)]:Clone()

					v29.Parent = Attachment
					v29:Emit(v29.Rate)
				end

				v13 = true
			end

			if SkinAssets.GunBeam:FindFirstChild(v2) then
				local v30 = SkinAssets.GunBeam[v2]
				local v31 = if IsLeftHand then "LeftGunBeam" else "GunBeam"
				local v32 = v30:FindFirstChild(v31) or v30.GunBeam
				local _2 = IsLeftHand and (v32:IsA("BasePart") and v32:FindFirstChild("LeftHandBeam"))

				if v32:IsA("BasePart") then
					local t5 = {
						Parent = nil,
						Attachment0 = nil,
						Attachment1 = nil
					}
					local Different_GunBeam = v32:FindFirstChild("Different_GunBeam")

					if Different_GunBeam and Different_GunBeam:FindFirstChild(v15) then
						local v33 = Different_GunBeam[v15][v31]

						if v33 and v33:IsA("BasePart") then
							v14 = v33:Clone()
							NewGunBeam = t5
						else
							NewGunBeam = v33 and v33:Clone() or t5
						end
					else
						v14 = v32:Clone()
						NewGunBeam = t5
					end
				else
					NewGunBeam = v32:Clone()
				end
			else
				local v36 = game.ReplicatedStorage.GunBeam:Clone()

				NewGunBeam = v36
				v36.Color = BeamColor and ColorSequence.new(BeamColor) or v36.Color
			end
		else
			local v16, v17

			v16 = game.ReplicatedStorage.GunBeam:Clone()
			v17 = BeamColor and ColorSequence.new(BeamColor) or v16.Color
			NewGunBeam = v16
			v16.Color = v17
		end
	else
		NewGunBeam = nil
	end

	task.spawn(function()
		if v14 then
			local magnitude = (v9 - v6).magnitude
			local v1 = magnitude / 725

			v14.Anchored = true
			v14.CanCollide = false
			v14.CanQuery = false
			v14.CFrame = CFrame.new(v6, v9)

			local v22 = v14.CFrame * CFrame.new(0, 0, -magnitude)

			v14.Parent = workspace.Ignored.Siren.Radius
			task.delay(v1 + 5, function()
				v14:Destroy()
				v14 = nil
			end)

			if v14:GetAttribute("SpecialEffects") then
				for k, v in pairs(v14:GetDescendants()) do
					if v:IsA("Trail") and v:GetAttribute("ColorRandom") then
						v.Color = ColorSequence.new(evalColorSequence(v:GetAttribute("ColorRandom"), math.random()))
					end
				end
			end

			local v42 = game:GetService("TweenService"):Create(v14, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
				CFrame = v14.CFrame * CFrame.new(0, 0, -0.1)
			})

			v42:Play()
			task.wait(0.05)

			if v42.PlaybackState ~= Enum.PlaybackState.Completed then
				v42:Pause()
			end

			local v5 = nil

			if _G.Reduce_Lag and not v14:GetAttribute("NoSlow") or v14:GetAttribute("LOWGFX") then
				v14.CFrame = v22
			else
				local v62 = game:GetService("TweenService"):Create(v14, TweenInfo.new(v1, Enum.EasingStyle.Linear), {
					CFrame = v22
				})

				v62:Play()
				task.wait(v1)
				v5 = v62
			end

			if v14:FindFirstChild("Impact") and (v8 and (v10 and not v8.Parent:FindFirstChild("Humanoid"))) then
				if v5 and v5.PlaybackState ~= Enum.PlaybackState.Completed then
					task.wait(0.05)
				end

				if not v14:FindFirstChild("NoNormal") then
					v14.CFrame = CFrame.new(v9, v9 - v10)
				end

				for k, v in pairs(v14.Impact:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						v:Emit(v:GetAttribute("EmitCount") or 1)
					end
				end
			else
				for k, v in pairs(v14:GetChildren()) do
					if v:IsA("BasePart") then
						v.Transparency = 1
					end
				end
			end

			if v14 then
				for k, v in pairs(v14:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					end
				end
			end
		elseif v8 and (v8:IsDescendantOf(workspace.MAP) and (not v4 and (v2 and (SkinAssets.GunBeam:FindFirstChild(v2) and SkinAssets.GunBeam[v2]:FindFirstChild("Impact"))))) then
			local v7 = SkinAssets.GunBeam[v2].Impact:Clone()

			v7.Parent = workspace.Ignored
			v7:PivotTo(CFrame.new(v9, v9 + v10 * 5) * CFrame.Angles(-1.5707963267948966, 0, 0))

			for k, v in pairs(v7:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(v:GetAttribute("EmitCount") or 1)
				end
			end

			task.delay(1.5, function()
				v7:Destroy()
				v7 = nil
			end)
		end

		local PointLight = Instance.new("PointLight")

		PointLight.Brightness = 0.5
		PointLight.Range = 15
		PointLight.Shadows = true
		PointLight.Color = Color3.new(255 / 255, 255 / 255, 255 / 255)
		PointLight.Parent = BULLET_RAYS

		local ShootBBGUI = Handle:FindFirstChild("ShootBBGUI")

		if not ShootBBGUI or v13 then
			return
		end

		local Shoot = ShootBBGUI:FindFirstChild("Shoot")

		if not Shoot then
			return
		end

		Shoot.Size = UDim2.new(0, 0, 0, 0)
		Shoot.ImageTransparency = 1
		Shoot.Visible = true
		TweenService:Create(Shoot, TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.In, 0, false, 0), {
			ImageTransparency = 0.4,
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
		TweenService:Create(PointLight, TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.In, 0, false, 0), {
			Range = 0
		}):Play()
		wait(0.4)
		BULLET_RAYS:Destroy()
		TweenService:Create(Shoot, TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.In, 0, false, 0), {
			ImageTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
		wait(0.2)
		Shoot.Visible = false
	end)
	NewGunBeam.Attachment0 = Attachment
	NewGunBeam.Attachment1 = Attachment2
	NewGunBeam.Name = "NewGunBeam"
	NewGunBeam.Parent = BULLET_RAYS

	if Shooter == LocalPlayer.Character and workspace:GetServerTimeNow() - v7 > 0.95 then
		playerShot(Handle)
	end

	if not t4[Handle] then
		local v39 = v2 or "None"

		task.spawn(GunSoundPlay.SoundPlay, Handle, t2[v39] ~= "All" and not (t2[v39] and t2[v39][Handle.Parent.Name]), v4)
		t4[Handle] = true
		task.delay(0.021, function()
			t4[Handle] = nil
		end)
	end

	task.spawn(function()
		if not Handle:GetAttribute("DualWield") or IsLeftHand then
			return
		end

		t3.shoot({
			IsLeftHand = true,
			Shooter = Shooter,
			Handle = Handle,
			ForcedOrigin = Handle.Parent.Default.Mesh.DualWieldLeftHandMesh.LeftMuzzle.WorldPosition,
			AimPosition = v9,
			BeamColor = BeamColor,
			Hit = Hit,
			Range = v1
		})
	end)

	return v9, v8, v10
end

return t3
]]) ~= "string"

			local v19 = str
			local v20 = bit32.bxor(bit32.band(n8, n11), 1083652)
			if v19 == "" then
				return nil
			end

			local chunk, v21 = loadstring([[

local t = {
	"[Shotgun]",
	"[Drum-Shotgun]",
	"[Rifle]",
	"[TacticalShotgun]",
	"[AR]",
	"[AUG]",
	"[AK47]",
	"[LMG]",
	"[SilencerAR]"
}
local t2 = {
	Brainrot = "All"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CurrentCamera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local v1 = LocalPlayer:GetMouse()
local SkinAssets = ReplicatedStorage.SkinAssets
local v2 = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local v3 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage:WaitForChild("Animations"):WaitForChild("GunCombat"):WaitForChild("Shoot"))
local v4 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage:WaitForChild("Animations"):WaitForChild("GunCombat"):WaitForChild("ShootLeft"))
local v5 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Animations.GunCombat.ShootRight)
local v6 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage:WaitForChild("Animations"):WaitForChild("GunCombat"):WaitForChild("AimShoot"))
local v7 = workspace:GetServerTimeNow()
local isPlaceId = game.PlaceId == 88976059384565
local GunSoundPlay = require(ReplicatedStorage:WaitForChild("GunSoundPlay"))

local function evalColorSequence(p1, p2)
	if p2 == 0 then
		return p1.Keypoints[1].Value
	end

	if p2 == 1 then
		return p1.Keypoints[#p1.Keypoints].Value
	end

	for i = 1, #p1.Keypoints - 1 do
		local v1 = p1.Keypoints[i]
		local v2 = p1.Keypoints[i + 1]

		if v1.Time <= p2 and p2 < v2.Time then
			local v3 = (p2 - v1.Time) / (v2.Time - v1.Time)

			return Color3.new((v2.Value.R - v1.Value.R) * v3 + v1.Value.R, (v2.Value.G - v1.Value.G) * v3 + v1.Value.G, (v2.Value.B - v1.Value.B) * v3 + v1.Value.B)
		end
	end
end

local function playerShot(p1)
	if v2 ~= LocalPlayer.Character then
		v3 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Animations.GunCombat.Shoot)
		v4 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Animations.GunCombat.ShootLeft)
		v5 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Animations.GunCombat.ShootRight)
		v6 = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Animations.GunCombat.AimShoot)
	end

	if _G.Aimed or (_G.MobleAimingIn or table.find(t, p1.Parent.Name)) then
		v6:Play()

		return
	end

	if p1:GetAttribute("DualWield") then
		v4:Play()
		v5:Play()
	else
		v3:Play()
	end
end

shared.playerShot = playerShot

local t3 = {
	getCanShoot = require(script.CanShoot),
	getAim = function(p1, p2)
		local v12 = RaycastParams.new()
		local t = { LocalPlayer.Character }
		local v2 = p2 or 200

		for v3, v4 in workspace.Ignored:GetChildren() do
			table.insert(t, v4)
		end

		v12.FilterDescendantsInstances = t
		v12.FilterType = Enum.RaycastFilterType.Exclude
		v12.IgnoreWater = true

		local v5

		if _G.MobileShiftLock or _G.MobleAimingIn then
			local Position = CurrentCamera.CFrame.Position
			local v6 = CurrentCamera.CFrame.LookVector * v2
			local v7 = workspace:Raycast(Position, v6, v12)

			v5 = if v7 then v7.Position else Position + v6
		else
			local v8 = CurrentCamera:ScreenPointToRay(v1.X, v1.Y)
			local v9 = workspace:Raycast(v8.Origin, v8.Direction * v2, v12)

			if v9 then
				v5 = v9.Position
			else
				local v10 = CurrentCamera.CFrame
				local LookVector = v10.LookVector
				local Origin = v8.Origin
				local Direction = v8.Direction

				v5 = Origin + Direction * ((v10.Position + v10.LookVector * v2 - Origin):Dot(LookVector) / Direction:Dot(LookVector))
			end
		end

		local v122 = v5 - p1

		return v122.Unit, v122.Magnitude
	end
}
local t4 = {}

function t3.shoot(p1)
	local Shooter = p1.Shooter
	local Handle = p1.Handle
	local BeamColor = p1.BeamColor
	local isReflecting = p1.isReflecting
	local Hit = p1.Hit
	local v1 = p1.Range or 200
	local v2 = Handle and Handle:GetAttribute("SkinName")
	local IsLeftHand = p1.IsLeftHand
	local v3 = Players:GetPlayerFromCharacter(Shooter)
	local v4 = v3 and v3:GetAttribute("GunFX") == true
	local _, v5 = t3.getAim(Handle.Position, v1)

	if Shooter ~= LocalPlayer.Character then
		v5 = v1
	end

	local v6 = p1.ForcedOrigin or Handle.Muzzle.WorldPosition
	local Unit = (p1.AimPosition - v6).Unit
	local v72 = RaycastParams.new()
	local t = {}
	local Ignored = require(game.ReplicatedStorage.MainModule).Ignored

	t[1] = Shooter
	t[2] = unpack(Ignored)
	v72.FilterDescendantsInstances = t
	v72.FilterType = Enum.RaycastFilterType.Exclude
	v72.IgnoreWater = true

	local v8, v9, v10

	if Hit then
		v8 = p1.Hit
		v9 = p1.AimPosition
		v10 = p1.Normal
	else
		local v11 = workspace:Raycast(v6, Unit * v1, v72)

		if v11 then
			v8 = v11.Instance
			v9 = v11.Position
			v10 = v11.Normal
		else
			v9 = v6 + Unit * math.min(v5, v1)
			v8 = nil
			v10 = nil
		end
	end

	if v8 then
		local isName = v8.Name == "Head"
	end

	if Shooter ~= LocalPlayer.Character then
		local BoostChar = LocalPlayer.Character;
		local BoostHRP = BoostChar and BoostChar:FindFirstChild('HumanoidRootPart');
		if BoostHRP then
			local RayTouchingMe = (v8 and v8:IsDescendantOf(BoostChar)) or DistancePointToSegment(BoostHRP.Position, v6, v9) <= 4;
			if RayTouchingMe then
				TriggerAntiFutureBoost();
			end;
		end;
	end;

	local BULLET_RAYS = Instance.new("Part")

	BULLET_RAYS:SetAttribute("OwnerCharacter", Shooter.Name)
	BULLET_RAYS.Name = "BULLET_RAYS"
	BULLET_RAYS.Anchored = true
	BULLET_RAYS.CanCollide = false
	BULLET_RAYS.Size = Vector3.new(0, 0, 0)
	BULLET_RAYS.Transparency = 1
	game.Debris:AddItem(BULLET_RAYS, 1)
	BULLET_RAYS.CFrame = CFrame.new(v6, v9)
	BULLET_RAYS.Material = Enum.Material.SmoothPlastic
	BULLET_RAYS.Parent = workspace.Ignored.Siren.Radius

	local Attachment = Instance.new("Attachment")

	Attachment.Position = Vector3.new(0, 0, 0)
	Attachment.Parent = BULLET_RAYS

	local Attachment2 = Instance.new("Attachment")
	local v12 = -(v9 - v6).magnitude

	Attachment2.Position = Vector3.new(0, 0, v12)
	Attachment2.Parent = BULLET_RAYS

	local v13 = false
	local v14 = nil
	local NewGunBeam

	if Handle then
		local v15 = Handle.Parent and Handle.Parent.Name

		if v15 and not v4 and (v2 and v2 ~= "" or SkinAssets.GunSkinMuzzleParticle:FindFirstChild(v15)) then
			v2 = v2 ~= "" and v2 or v15

			local v19 = if IsLeftHand then "LeftMuzzle" else "Muzzle"

			if SkinAssets.GunSkinMuzzleParticle:FindFirstChild(v2) then
				if not isReflecting and (SkinAssets.GunSkinMuzzleParticle[v2]:FindFirstChild(v19) or IsLeftHand) then
					local v20 = Handle.Parent:FindFirstChild("Default") and Handle.Parent.Default:FindFirstChild("Mesh") and Handle.Parent.Default.Mesh:FindFirstChild(v19) or Handle:FindFirstChild(v19)
					local v21

					if IsLeftHand then
						local v22 = Handle.Parent:FindFirstChild("Default") and Handle.Parent.Default:FindFirstChild("Mesh") and Handle.Parent.Default.Mesh.DualWieldLeftHandMesh:FindFirstChild(v19) or v20

						v21 = if v22 == v20 then false else true

						if v21 then
							v20 = v22
						end
					else
						v21 = false
					end

					if v20 then
						for v24, v25 in (if v21 then v20 elseif SkinAssets.GunSkinMuzzleParticle[v2].Muzzle:FindFirstChild("Different_GunMuzzle") then SkinAssets.GunSkinMuzzleParticle[v2][v19].Different_GunMuzzle[v15] else SkinAssets.GunSkinMuzzleParticle[v2][v19]):GetChildren() do
							local v26 = v25:GetAttribute("EmitCount") or 1
							local v27 = IsLeftHand and v25 or v25:Clone()

							v27.Parent = v20
							v27:Emit(v26)

							if not v21 then
								task.delay(v27.Lifetime.Max, function()
									v27:Destroy()
								end)
							end
						end
					end
				elseif not isReflecting then
					local v28 = SkinAssets.GunSkinMuzzleParticle[v2]:GetChildren()
					local v29 = v28[math.random(#v28)]:Clone()

					v29.Parent = Attachment
					v29:Emit(v29.Rate)
				end

				v13 = true
			end

			if SkinAssets.GunBeam:FindFirstChild(v2) then
				local v30 = SkinAssets.GunBeam[v2]
				local v31 = if IsLeftHand then "LeftGunBeam" else "GunBeam"
				local v32 = v30:FindFirstChild(v31) or v30.GunBeam
				local _2 = IsLeftHand and (v32:IsA("BasePart") and v32:FindFirstChild("LeftHandBeam"))

				if v32:IsA("BasePart") then
					local t5 = {
						Parent = nil,
						Attachment0 = nil,
						Attachment1 = nil
					}
					local Different_GunBeam = v32:FindFirstChild("Different_GunBeam")

					if Different_GunBeam and Different_GunBeam:FindFirstChild(v15) then
						local v33 = Different_GunBeam[v15][v31]

						if v33 and v33:IsA("BasePart") then
							v14 = v33:Clone()
							NewGunBeam = t5
						else
							NewGunBeam = v33 and v33:Clone() or t5
						end
					else
						v14 = v32:Clone()
						NewGunBeam = t5
					end
				else
					NewGunBeam = v32:Clone()
				end
			else
				local v36 = game.ReplicatedStorage.GunBeam:Clone()

				NewGunBeam = v36
				v36.Color = BeamColor and ColorSequence.new(BeamColor) or v36.Color
			end
		else
			local v16, v17

			v16 = game.ReplicatedStorage.GunBeam:Clone()
			v17 = BeamColor and ColorSequence.new(BeamColor) or v16.Color
			NewGunBeam = v16
			v16.Color = v17
		end
	else
		NewGunBeam = nil
	end

	task.spawn(function()
		if v14 then
			local magnitude = (v9 - v6).magnitude
			local v1 = magnitude / 725

			v14.Anchored = true
			v14.CanCollide = false
			v14.CanQuery = false
			v14.CFrame = CFrame.new(v6, v9)

			local v22 = v14.CFrame * CFrame.new(0, 0, -magnitude)

			v14.Parent = workspace.Ignored.Siren.Radius
			task.delay(v1 + 5, function()
				v14:Destroy()
				v14 = nil
			end)

			if v14:GetAttribute("SpecialEffects") then
				for k, v in pairs(v14:GetDescendants()) do
					if v:IsA("Trail") and v:GetAttribute("ColorRandom") then
						v.Color = ColorSequence.new(evalColorSequence(v:GetAttribute("ColorRandom"), math.random()))
					end
				end
			end

			local v42 = game:GetService("TweenService"):Create(v14, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
				CFrame = v14.CFrame * CFrame.new(0, 0, -0.1)
			})

			v42:Play()
			task.wait(0.05)

			if v42.PlaybackState ~= Enum.PlaybackState.Completed then
				v42:Pause()
			end

			local v5 = nil

			if _G.Reduce_Lag and not v14:GetAttribute("NoSlow") or v14:GetAttribute("LOWGFX") then
				v14.CFrame = v22
			else
				local v62 = game:GetService("TweenService"):Create(v14, TweenInfo.new(v1, Enum.EasingStyle.Linear), {
					CFrame = v22
				})

				v62:Play()
				task.wait(v1)
				v5 = v62
			end

			if v14:FindFirstChild("Impact") and (v8 and (v10 and not v8.Parent:FindFirstChild("Humanoid"))) then
				if v5 and v5.PlaybackState ~= Enum.PlaybackState.Completed then
					task.wait(0.05)
				end

				if not v14:FindFirstChild("NoNormal") then
					v14.CFrame = CFrame.new(v9, v9 - v10)
				end

				for k, v in pairs(v14.Impact:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						v:Emit(v:GetAttribute("EmitCount") or 1)
					end
				end
			else
				for k, v in pairs(v14:GetChildren()) do
					if v:IsA("BasePart") then
						v.Transparency = 1
					end
				end
			end

			if v14 then
				for k, v in pairs(v14:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					end
				end
			end
		elseif v8 and (v8:IsDescendantOf(workspace.MAP) and (not v4 and (v2 and (SkinAssets.GunBeam:FindFirstChild(v2) and SkinAssets.GunBeam[v2]:FindFirstChild("Impact"))))) then
			local v7 = SkinAssets.GunBeam[v2].Impact:Clone()

			v7.Parent = workspace.Ignored
			v7:PivotTo(CFrame.new(v9, v9 + v10 * 5) * CFrame.Angles(-1.5707963267948966, 0, 0))

			for k, v in pairs(v7:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(v:GetAttribute("EmitCount") or 1)
				end
			end

			task.delay(1.5, function()
				v7:Destroy()
				v7 = nil
			end)
		end

		local PointLight = Instance.new("PointLight")

		PointLight.Brightness = 0.5
		PointLight.Range = 15
		PointLight.Shadows = true
		PointLight.Color = Color3.new(255 / 255, 255 / 255, 255 / 255)
		PointLight.Parent = BULLET_RAYS

		local ShootBBGUI = Handle:FindFirstChild("ShootBBGUI")

		if not ShootBBGUI or v13 then
			return
		end

		local Shoot = ShootBBGUI:FindFirstChild("Shoot")

		if not Shoot then
			return
		end

		Shoot.Size = UDim2.new(0, 0, 0, 0)
		Shoot.ImageTransparency = 1
		Shoot.Visible = true
		TweenService:Create(Shoot, TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.In, 0, false, 0), {
			ImageTransparency = 0.4,
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
		TweenService:Create(PointLight, TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.In, 0, false, 0), {
			Range = 0
		}):Play()
		wait(0.4)
		BULLET_RAYS:Destroy()
		TweenService:Create(Shoot, TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.In, 0, false, 0), {
			ImageTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
		wait(0.2)
		Shoot.Visible = false
	end)
	NewGunBeam.Attachment0 = Attachment
	NewGunBeam.Attachment1 = Attachment2
	NewGunBeam.Name = "NewGunBeam"
	NewGunBeam.Parent = BULLET_RAYS

	if Shooter == LocalPlayer.Character and workspace:GetServerTimeNow() - v7 > 0.95 then
		playerShot(Handle)
	end

	if not t4[Handle] then
		local v39 = v2 or "None"

		task.spawn(GunSoundPlay.SoundPlay, Handle, t2[v39] ~= "All" and not (t2[v39] and t2[v39][Handle.Parent.Name]), v4)
		t4[Handle] = true
		task.delay(0.021, function()
			t4[Handle] = nil
		end)
	end

	task.spawn(function()
		if not Handle:GetAttribute("DualWield") or IsLeftHand then
			return
		end

		t3.shoot({
			IsLeftHand = true,
			Shooter = Shooter,
			Handle = Handle,
			ForcedOrigin = Handle.Parent.Default.Mesh.DualWieldLeftHandMesh.LeftMuzzle.WorldPosition,
			AimPosition = v9,
			BeamColor = BeamColor,
			Hit = Hit,
			Range = v1
		})
	end)

	return v9, v8, v10
end

return t3
]], "@embedded dumped gunhandler.lua")

			if not chunk then
				warn("cider error: gunhandler emulation failed;", v21)
				return nil
			end
			local n12 = v20 // 98

			local tbl5 = { CanShoot = function()
				return CanShoot
			end }

			local n13 = n11 - n12

			local obj = setmetatable({
				script = tbl5,
				require = function(arg)
					local n14 = 3526940870
					if arg == tbl5.CanShoot then
						return CanShoot
					end
					return require(arg)
				end,
			}, {
				__index = function(arg, arg2)
					return getfenv()[arg2]
				end,
				__newindex = function(arg, arg2, arg3)
					getfenv()[arg2] = arg3
				end,
			})

			local v22 = bit32.bor(n12, n13)
			setfenv(chunk, obj)
			local ok, result = pcall(chunk)
			local flag3 = not ok
			local flag4

			if flag3 then
				flag4 = flag3
			else
				local flag5 = type(result) ~= "table"
				bit32.bxor(n6, 1692879295)
				flag4 = flag5
			end

			if not flag4 then
				local v23 = type
				local v24 = bit32.bor(n13, v22)
				flag4 = v23(result.shoot) ~= "function"
				n13 = v24 + 4289924928
				bit32.bxor(n7, 2690136914)
			end

			if flag4 or type(result.getAim) ~= "function" then
				warn("cider error: gunhandler emulation failed;", result)
				local v23 = table.pack(bit32.band(n13, 4294967295))
				local v24 = table.pack(bit32.band(v23[1], 65535))
				bit32.band(v24[1] * 16310 + bit32.lshift(bit32.band(v24[1] * 0 + bit32.rshift(v23[1], 16) * 16310, 65535), 16), 4294967295)
				return nil
			end

			v16 = result
			shared.__cider_emulated_gunhandler = true
			return v16
		end
	end

	local v16 = hookfunction

	if not shared.__cider_require_gunhandler_hooked then
		local v17 = nil

		v17 = v16(require, function(arg)
			local n6 = 705796354
			local n7 = 3821556942
			local n8 = 3237375570
			local modules = ReplicatedStorage:FindFirstChild("Modules")
			modules = modules and modules:FindFirstChild("GunHandler")

			if modules and arg == modules then
				local v18 = fn6()

				if v18 then
					shared.__cider_require_gunhandler_source = "emulated"
					bit32.bxor(n6, 3180580712)
					bit32.bor(n7, n8)
					return v18
				end
			end

			return v17(arg)
		end)

		local v18 = shared
		local v19 = table.pack(bit32.band(v15, 4294967295))
		local v20 = table.pack(bit32.band(v19[1], 65535))
		local v21 = bit32.band(v20[1] * 51263 + bit32.lshift(bit32.band(v20[1] * 0 + bit32.rshift(v19[1], 16) * 51263, 65535), 16), 4294967295)
		v18.__cider_require_gunhandler_hooked = true
		local v22 = v21
		local v23 = table.pack(bit32.band(v22, 4294967295))
		local v24 = table.pack(bit32.band(v23[1], 65535))
		v15 = bit32.bxor(bit32.band(v24[1] * 24322 + bit32.lshift(bit32.band(v24[1] * 0 + bit32.rshift(v23[1], 16) * 24322, 65535), 16), 4294967295), 2769730777)
	end

	local tbl5
	tbl5 = { ["[SMG]"] = true }
	local v17
	v17 = bit32.bxor(v13, 23445440)
	tbl5["[Rifle]"] = true
	tbl5["[Shotgun]"] = true
	local v18 = bit32.bxor(v17, 0)
	local v19 = table.pack(bit32.band(v14, 4294967295))
	local v20 = table.pack(bit32.band(v18, 4294967295))
	local v21 = table.pack(bit32.band(v19[1], 65535))
	local v22 = table.pack(bit32.rshift(v19[1], 16))
	local v23 = table.pack(bit32.band(v20[1], 65535))
	local fn7

	do
		local v24 = bit32.band(v21[1] * v23[1] + bit32.lshift(bit32.band(v21[1] * bit32.rshift(v20[1], 16) + v22[1] * v23[1], 65535), 16), 4294967295)
		tbl5["[AK47]"] = true
		tbl5["[AR]"] = true
		tbl5["[Drum-Shotgun]"] = true
		tbl5["[DrumGun]"] = true
		tbl5["[LMG]"] = true
		tbl5["[P90]"] = true
		tbl5["[SilencerAR]"] = true
		AutoWeapons = tbl5
		local tbl6 = {}
		local v25 = bit32.bor(v24 // 106, 2355442344)
		tbl6["[AUG]"] = true
		BurstWeapons = tbl6
		ShootRayParams = RaycastParamsNew()
		ShootRayParams.FilterType = EnumExclude
		local v26 = bit32.band(v15, 2871841713)
		ShootRayParams.IgnoreWater = true

		CanShootCheck = function(arg, arg2)
			local n6 = 9975534
			local n7 = 3983743453
			local n8 = 2811535643
			local n9 = 2865598036
			if not arg then
				return false
			end
			local humanoid = arg:FindFirstChild("Humanoid")
			local flag = not humanoid

			if not flag then
				flag = humanoid.Health <= 0
				n9 = n9 + 4145819713 + 149147583
			end

			if not flag then
				local v27 = EnumDead
				flag = humanoid:GetState() == v27
			end

			if flag then
				return false
			end
			local bodyEffects = arg:FindFirstChild("BodyEffects")
			if not bodyEffects then
				bit32.bor(n8, n9)
				return false
			end
			local tool = arg:FindFirstChildOfClass("Tool")
			if not tool or not tool:FindFirstChild("Handle") or not tool:FindFirstChild("Ammo") then
				return false
			end
			local n10 = n8 + n9
			if tool.Ammo.Value <= 0 then
				return false
			end
			local n11 = n9 // 2
			local n12 = n11
			if arg:FindFirstChild("FULLY_LOADED_CHAR") == nil then
				return false
			end

			if arg:FindFirstChild("FORCEFIELD") then
				return false
			end

			if arg:FindFirstChild("GRABBING_CONSTRAINT") then
				return false
			end

			if arg:FindFirstChild("Christmas_Sock") then
				bit32.bxor(n6, 979407281)
				return false
			end

			if bodyEffects:FindFirstChild("Cuff") and bodyEffects.Cuff.Value then
				return false
			end
			local attacking = bodyEffects:FindFirstChild("Attacking")

			if attacking then
				attacking = bodyEffects.Attacking.Value
				n11 = n12 // n10 - 2862168279
				n12 = n11
			end

			if attacking then
				return false
			end

			if bodyEffects:FindFirstChild("K.O") and bodyEffects["K.O"].Value then
				return false
			end
			local grabbed = bodyEffects:FindFirstChild("Grabbed")

			if grabbed then
				grabbed = bodyEffects.Grabbed.Value
				local v27 = bit32.bor(n12, n10)
				bit32.bxor(n7, 998756674)
				n12 = v27 - 33564741
			end

			if grabbed then
				return false
			end

			if bodyEffects:FindFirstChild("Reload") and bodyEffects.Reload.Value then
				return false
			end
			local dead = bodyEffects:FindFirstChild("Dead")
			local v27 = n12
			if dead and bodyEffects.Dead.Value then
				return false
			end

			if bodyEffects:FindFirstChild("Block") then
				return false
			end
			local flag2 = not arg2
			local n13 = v27 - n12
			if flag2 and tool:GetAttribute("Cooldown") then
				return false
			end
			local attribute = arg:GetAttribute("LastGunShot")

			if not (tool.Name == "[Shotgun]" or tool.Name == "[Double-Barrel SG]" or tool.Name == "TacticalShotgun") then
			end

			local name = tool.Name
			bit32.rshift(n13, 30)
			if attribute ~= name and arg:GetAttribute("ShotgunDebounce") then
				return false
			end
			return true
		end

		CanShoot = function(arg)
			local n6 = 1935978584
			local n7 = 3031015220
			local n8 = 2971849717
			if not CanShootCheck(arg) then
				return false
			end
			local tool = arg:FindFirstChildOfClass("Tool")
			local v27 = table.pack(bit32.band(n7, 4294967295))
			local v28 = table.pack(bit32.band(n8, 4294967295))
			local v29 = table.pack(bit32.band(v27[1], 65535))
			local v30 = table.pack(bit32.rshift(v27[1], 16))
			local v31 = table.pack(bit32.band(v28[1], 65535))
			local v32 = bit32.band(v29[1] * v31[1] + bit32.lshift(bit32.band(v29[1] * bit32.rshift(v28[1], 16) + v30[1] * v31[1], 65535), 16), 4294967295)
			local flag = tool.Name == "[Shotgun]"

			if not flag then
				flag = tool.Name == "[Double-Barrel SG]"
				n8 = v32 - 475161807
			end

			if not flag then
				bit32.bxor(n6, 2871073261)
				flag = tool.Name == "TacticalShotgun"
			end

			local flag2 = flag or tool.Name == "Drum-Shotgun"

			if flag2 then
				flag2 = not arg:GetAttribute("ShotgunDebounce")
				n8 = bit32.bxor(n8, 4294967295) - 2646235157
			end

			if flag2 then
				bit32.bxor(v32, 437322493)
				arg:SetAttribute("ShotgunDebounce", true)
				local v33 = task
				local v34 = bit32.bxor(v32, n8)
				local n9 = 113420405

				v33.delay(0.65, function()
					arg:SetAttribute("ShotgunDebounce", nil)
				end)
			end

			arg:SetAttribute("LastGunShot", tool.Name)
			return true
		end

		GetMuzzlePosition = function(arg)
			local n6 = 3228005349
			local n7 = 472198648
			local handle = arg:FindFirstChild("Handle")
			local n8 = 360928078
			if not handle then
				return nil
			end
			local v27 = MuzzleOffsets[arg.Name]

			if not v27 then
				v27 = CFrameNew(0, 0.4, 1.8)
				local v28 = bit32.rshift(n7, 9)
				bit32.bxor(n6, 3295685916)
			end

			local position = (handle.CFrame * v27).Position
			local default = arg:FindFirstChild("Default")

			if default then
				local mesh = default:FindFirstChild("Mesh")

				if mesh then
					local muzzle = mesh:FindFirstChild("Muzzle")
					if muzzle then
						return muzzle.WorldPosition
					end
				end
			end

			local muzzle = handle:FindFirstChild("Muzzle")
			if muzzle then
				return muzzle.WorldPosition
			end
			return position
		end

		fn7 = function()
			local guiInset = GuiService:GetGuiInset()
			return UserInputService:GetMouseLocation() - guiInset
		end

		local n6 = v25 - 124230690
	end

	GetClosestPointOnPart = function(arg, arg2, arg3)
		local n6 = 3950834065
		local n7 = 1127215391
		local n8 = 1878687683
		local currentCamera2 = Workspace.CurrentCamera

		if not arg3 then
			local v24 = bit32.bor(n8, n7)
			arg3 = fn7()
			n8 = v24 - 360476
		end

		local v24 = currentCamera2:ViewportPointToRay(arg3.X, arg3.Y)
		local v25 = v24.Direction:Dot(v24.Direction)
		local flag = v25 > 0
		local v26 = table.pack(bit32.band(n7, 4294967295))
		local v27 = table.pack(bit32.band(v26[1], 65535))
		local v28 = bit32.band(v27[1] * 10388 + bit32.lshift(bit32.band(v27[1] * 0 + bit32.rshift(v26[1], 16) * 10388, 65535), 16), 4294967295)
		local n9 = flag and v24.Direction:Dot(arg.Position - v24.Origin) / v25 or 0
		local origin = v24.Origin
		local n10 = v24.Direction * MathMax(n9, 0)
		local v29 = bit32.lshift(v28, 20)
		local v30 = arg.CFrame:PointToObjectSpace(origin + n10)
		local n11 = arg.Size * (arg2 or 1) / 2
		local cFrame = arg.CFrame
		local v31 = Vector3New
		local v32 = MathClamp(v30.X, -n11.X, n11.X)
		local v33 = MathClamp
		local y = v30.Y
		local n12 = -n11.Y
		local v34 = bit32.band(v29, n8 // 152 // 11)
		local y2 = n11.Y
		bit32.bxor(n6, 3008666135)
		return cFrame * v31(v32, v33(y, n12, y2), MathClamp(v30.Z, -n11.Z, n11.Z))
	end

	GetClosestPartToCursor = function(arg, arg2, arg3)
		local currentCamera2 = Workspace.CurrentCamera
		local v24 = fn7()
		local v25 = MathHuge
		local v26 = next
		local children, v27 = arg:GetChildren()
		local v28 = nil
		local v29 = nil

		for _, v30 in v26, children, v27 do
			if v30:IsA("BasePart") then
				local position = arg2 and GetClosestPointOnPart(v30, arg3, v24) or v30.Position
				local v31, v32 = currentCamera2:WorldToViewportPoint(position)

				if not (not v32 or v31.Z <= 0) then
					local magnitude = (v24 - Vector2New(v31.X, v31.Y)).Magnitude

					if magnitude < v25 then
						v25 = magnitude
						v28 = v30
						v29 = position
					end
				end
			end
		end

		return v28, v29
	end

	local fn8

	fn8 = function(arg, arg2)
		local n6 = 3149923359
		local n7 = 3975601964
		local n8 = 1365365099
		local targetPart = arg2["Target Part"]
		local part = type(targetPart) == "table" and targetPart.Part or targetPart or "HumanoidRootPart"
		local v24 = n8
		local n9 = n8 * 3
		local closestPoint = type(targetPart) == "table" and targetPart["Closest Point"] or arg2["Closest Point"]
		local flag = type(closestPoint) == "table" and closestPoint.Enabled == true
		local n10 = v24 // n9
		local v25 = string.lower(tostring(part))
		local n11 = n9 + n10
		local flag2 = type(closestPoint) == "table"

		if flag2 then
			flag2 = string.lower(tostring(closestPoint.Mode)) == "scaled"
			n10 = bit32.bxor(n10 + 1004236500, 1004236500)
		end

		local n12 = nil

		if flag2 then
			local v26 = MathClamp
			local n13 = n11 - 3793744009
			n12 = 1 - v26(closestPoint.Scale or 0, 0, 100) / 100
			n11 = n13 - 501223287
		end

		if v25 == "closest point" then
			n6 = n11
			part = "Head"
			flag = true
		elseif v25 == "closest part" then
			part = "Closest"
			flag = false
		end

		local v26, v27

		if part == "Closest" then
			v26, v27 = GetClosestPartToCursor(arg, flag, n12)
		else
			v26 = arg:FindFirstChild(part)
			n10 = bit32.bxor(n10 - n11, 198871999)
			v27 = nil
		end

		if v26 then
			return v27 or flag and GetClosestPointOnPart(v26, n12) or v26.Position, v26
		end
		local humanoidRootPart = arg:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			flag = flag and GetClosestPointOnPart(humanoidRootPart, n12)

			if not flag then
				flag = humanoidRootPart.Position
				bit32.bxor(n6, 2672014476)
				bit32.bxor(bit32.band(n11, n10), 4096095297)
			end

			return flag, humanoidRootPart
		end

		return nil, nil
	end

	local fn9
	fn9 = nil
	local fn10

	fn10 = function()
		local n6 = 1732224085
		local n7 = 2846408121
		local n8 = 629771067
		local n9 = 2147254195
		local silentAim = fn()["Silent Aim"]
		local enabled = silentAim.Enabled
		local v24

		if enabled then
			local silent = State.Targets.Silent
			n8 = bit32.bxor(bit32.bxor(n8, n9), 2147254195)
			v24 = silent
		else
			v24 = enabled
		end

		if v24 then
			v24 = PassesConditions(State.Targets.Silent, "Silent Aim")
			local v25 = table.pack(bit32.band(n9, 4294967295))
			local v26 = table.pack(bit32.band(n8, 4294967295))
			local v27 = table.pack(bit32.band(v25[1], 65535))
			local v28 = table.pack(bit32.rshift(v25[1], 16))
			local v29 = table.pack(bit32.band(v26[1], 65535))
			local v30 = bit32.band(v27[1] * v29[1] + bit32.lshift(bit32.band(v27[1] * bit32.rshift(v26[1], 16) + v28[1] * v29[1], 65535), 16), 4294967295)
			bit32.bxor(n7, 19142235)
			n9 = bit32.bxor(v30, 2981028082)
		end

		if v24 then
			local silent = State.Targets.Silent
			local character = silent.Character

			if character then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					local currentCamera2 = Workspace.CurrentCamera
					local v25 = table.pack(bit32.band(n8, 4294967295))
					local v26 = table.pack(bit32.band(n9, 4294967295))
					local v27 = table.pack(bit32.band(v25[1], 65535))
					local v28 = table.pack(bit32.rshift(v25[1], 16))
					local v29 = table.pack(bit32.band(v26[1], 65535))
					local v30 = bit32.band(v27[1] * v29[1] + bit32.lshift(bit32.band(v27[1] * bit32.rshift(v26[1], 16) + v28[1] * v29[1], 65535), 16), 4294967295)
					local maxRange = silentAim["Max Range"]

					if maxRange and maxRange < MathHuge then
						local n10 = n9 // 5
						if (currentCamera2.CFrame.Position - humanoidRootPart.Position).Magnitude > maxRange then
							return mouse.Hit.Position
						end
						n9 = n10 - 2577163940
					end

					local offscreenTargeting = silentAim["Offscreen Targeting"]
					offscreenTargeting = offscreenTargeting and offscreenTargeting.Enabled
					local v31, flag = currentCamera2:WorldToViewportPoint(humanoidRootPart.Position)
					local n10 = bit32.bor(v30, n9)
					flag = offscreenTargeting or flag and v31.Z > 1
					local flag2 = fn9

					if fn9 then
						flag2 = not fn9(humanoidRootPart.Position, "Silent Aim")
						bit32.bxor(n6, 1131742306)
					end

					if flag2 then
						n10 = bit32.rshift(n10, 25) - 65676
						flag = false
					end

					if flag then
						if not offscreenTargeting then
							local n11 = n9 + n10
							local silent2 = fn().Main.FOV.Silent

							if string.lower(tostring(silent2.Options or "2D")) == "3d" then
								n11 = bit32.lshift(n11, 25) + 872120230
								offscreenTargeting = true
							else
								local n12 = n10 - 816096926

								if not silent2.Visualize.Enabled then
									offscreenTargeting = true
								else
									local mouseLocation = UserInputService:GetMouseLocation()
									local y = currentCamera2.ViewportSize.Y
									local fieldOfView = currentCamera2.FieldOfView
									local size = humanoidRootPart.Size
									local n13 = bit32.bor(n11, n12)
									local n14 = n12 // 9
									local n15 = size.Y * y / v31.Z * 2 * 80 / fieldOfView
									local n16 = (silent2.Width and (silent2.Width[1] or 150) or 150) * n15
									local v32 = n13
									local height = silent2.Height

									if height then
										local n17 = n13 // v32
										height = silent2.Height[1] or 150
										n13 = n17 - 294922
									end

									local n17 = (height or 150) * n15
									local n18 = v32 + 3370068185
									local n19 = Vector2New(v31.X, v31.Y) - mouseLocation
									offscreenTargeting = MathAbs(n19.X) <= n16 / 2

									if offscreenTargeting then
										local v33 = MathAbs(n19.Y)
										local v34 = table.pack(bit32.band(n13, 4294967295))
										local v35 = table.pack(bit32.band(v34[1], 65535))
										offscreenTargeting = v33 <= n17 / 2
										n13 = bit32.band(v35[1] * 21154 + bit32.lshift(bit32.band(v35[1] * 0 + bit32.rshift(v34[1], 16) * 21154, 65535), 16), 4294967295) - 2351470679
									end

									n11 = bit32.bxor(n13, 2147483729)
									n12 = bit32.bxor(n18, 125890949)
								end

								n10 = n12 + 816096926
							end

							n9 = bit32.bxor(n11, 458773)
						end

						if offscreenTargeting then
							local position = fn8(character, silentAim)
							position = position or humanoidRootPart.Position
							local tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool")
							local v32 = bit32.bxor(n9, 1970002405)
							local future = silentAim.Future
							local v33

							if future and future.Enabled ~= false then
								v33 = ApplyFuture(position, silent, tool and tool.Name, future)
							else
								v33 = ApplyPrediction(position, silent, silentAim)
							end

							return v33
						end
					end

					bit32.bxor(n10, 3665261768)
				end
			end
		end

		return mouse.Hit.Position
	end

	local v24
	v24 = bit32.bxor(v17, 388441728)
	local tbl6
	tbl6 = {}
	local flag
	flag = false
	local v25
	local tbl7 = {}
	v25 = bit32.bxor(v24, 0)
	tbl7[1] = "[Shotgun]"
	tbl7[2] = "[Drum-Shotgun]"
	tbl7[3] = "[Rifle]"
	tbl7[4] = "[TacticalShotgun]"
	tbl7[5] = "[AR]"
	tbl7[6] = "[AUG]"
	tbl7[7] = "[AK47]"
	tbl7[8] = "[LMG]"
	tbl7[9] = "[SilencerAR]"
	ScopedWeapons = tbl7
	local tbl8
	tbl8 = { SoulII = Vector3New(-90, 0, 0) }
	local v26

	do
		local v27 = bit32.bxor(v24, 0)
		tbl8.Sushi = "Position"
		local v28 = Vector3New
		local v29 = bit32.lshift(v25, 18)
		tbl8.XMAS = v28(180, 0, 0)
		tbl8.Gift = Vector3New(180, 0, 0)
		tbl8.Jellyfish = Vector3New(180, 0, 0)
		tbl8.Halloween23 = Vector3New(180, 0, 0)
		local n6 = v29 // 4
		tbl8["Wild West"] = Vector3New(180, 0, 0)
		local v30 = Vector3New
		local v31 = bit32.bor(v27 + 1273088883, n6)
		tbl8.Cat = v30(180, 0, 0)
		local v32 = Vector3New
		local v33 = bit32.bxor(v24, 0)
		local v34 = bit32.band(n6, v33)
		tbl8.Ninja = v32(180, 0, 0)
		tbl8.Void = Vector3New(180, 0, 0)
		local v35 = Vector3New
		local n7 = v31 + bit32.bxor(v24, 0)
		tbl8.Ice = v35(180, 0, 0)
		local beary = {}
		local v36 = CFrameNew
		local n8 = v34 // bit32.bxor(v24, 0)
		local v37 = v36(0, 0, -0.45)
		local v38 = Vector3New
		v26 = bit32.bxor(n7, 3903982293)
		beary[1] = v37

		do
			local values = table.pack(v38(180, 0, 0))
			table.move(values, 1, values.n, 2, beary)
		end

		tbl8.Beary = beary
		tbl8.XMAS24 = Vector3New(-90, 0, 0)
		tbl8.Heartbreak = "Position"
		tbl8.Blaze = "Position"
		tbl8["Short Cake"] = "Position"
		tbl8.Shrimp = Vector3New(-90, 0, 0)
		local v39 = Vector3New(-90, 0, 0)
		local v40 = bit32.bor(n8 - 744170845, 2192477834)
		tbl8.Arcane = v39
	end

	tbl8.PrestigeCandyCane = "Position"
	local n6
	n6 = v26 - bit32.bxor(v24, 0)
	tbl8.Duck = "Position"
	local v27 = table.pack(bit32.band(v24, 4294967295))
	local v28 = table.pack(bit32.band(v27[1], 65535))
	local n7, v29, tbl9, n8, tbl10, defaultConfig, v30

	do
		local n9 = bit32.band(46017 * v28[1] + bit32.lshift(bit32.band(46017 * bit32.rshift(v27[1], 16) + 39728 * v28[1], 65535), 16), 4294967295) + 4097589907
		local v31 = table.pack(bit32.band(bit32.bor(v24, 153402195), 4294967295))
		local v32 = table.pack(bit32.band(v31[1], 65535))
		local v33 = bit32.band(39038 * v32[1] + bit32.lshift(bit32.band(39038 * bit32.rshift(v31[1], 16) + 51614 * v32[1], 65535), 16), 4294967295)
		local v34 = table.pack(bit32.band(bit32.bxor(v24, 153402195), 4294967295))
		local v35 = table.pack(bit32.band(v34[1], 65535))
		local n10 = n9 + v33 + bit32.band(46018 * v35[1] + bit32.lshift(bit32.band(46018 * bit32.rshift(v34[1], 16) + 39728 * v35[1], 65535), 16), 4294967295)
		tbl8.Flower = Vector3New(180, 0, 0)
		local v36 = Vector3New
		local v37 = bit32.bxor(n10, 0)
		n7 = n6 // 164 - bit32.bxor(n10, 0)
		tbl8.Car = v36(180, 0, 0)
		local v38 = Vector3New(180, 0, 0)
		local n11 = v37 - bit32.bxor(n10, 0)
		tbl8.Music = v38
		local brainrot = {}
		local v39 = CFrameNew(0, 0, -0.25)
		local v40 = Vector3New
		local v41 = bit32.bxor(n11, 2212980608)
		v29 = bit32.bxor(n10, 199146709)
		brainrot[1] = v39

		do
			local values = table.pack(v40(0, 0, 0))
			table.move(values, 1, values.n, 2, brainrot)
		end

		tbl8.Brainrot = brainrot
		CustomBulletHoleRotations = tbl8
		tbl9 = {}
		local color = Color3.fromRGB
		local v42 = bit32.bor(n7, 3929575622)
		local v43 = color(248, 147, 255)
		local color2 = Color3.fromRGB
		local v44 = table.pack(bit32.band(v41, 4294967295))
		local v45 = table.pack(bit32.band(v44[1], 65535))
		local v46 = bit32.band(v45[1] * 19493 + bit32.lshift(bit32.band(v45[1] * 0 + bit32.rshift(v44[1], 16) * 19493, 65535), 16), 4294967295)
		local v47 = color2(255, 160, 64)
		local color3 = Color3.fromRGB(76, 255, 82)
		local color4 = Color3.fromRGB
		local n12 = v42 + v46
		tbl9[1] = v43
		tbl9[2] = v47
		tbl9[3] = color3

		do
			local values = table.pack(color4(110, 149, 255))
			table.move(values, 1, values.n, 4, tbl9)
		end

		UndeadBeamColors = tbl9
		n8 = v46 - n12

		DoMuzzleEmit = function(arg, arg2)
			local flag2 = type(469388884) == "userdata"
			local n13 = 942823150

			local function fn11()
				local n14 = 1718137599

				local function fn12()
					local flag3 = bit32.bxor(n14, 0) + 133787656 == 92478617
					local n15 = 315983147
					local n16 = 1629413971
					local n17 = 173919811
					local v48 = bit32.bxor(n14, 2303318583)
					local n18 = 904674985
					if not arg2 then
						return
					end
					local tool = arg2:FindFirstChildOfClass("Tool")
					if not tool then
						return
					end
					local handle = tool:FindFirstChild("Handle")
					local n19 = n18 // v48
					if not handle then
						return
					end
					local default = tool:FindFirstChild("Default")

					if default then
						bit32.bxor(n16, 1028678837)
						default = tool.Default:FindFirstChild("Mesh")
						v48 = bit32.bxor(v48, n19)
					end

					default = default and tool.Default.Mesh:FindFirstChild("Muzzle") or handle:FindFirstChild("Muzzle")
					if not default then
						return
					end

					if handle:GetAttribute("Emitted") then
						return
					end
					handle:SetAttribute("Emitted", true)
					local v49 = Delay
					local n20 = n15 - 31796055

					local function fn13()
						local n21 = 3827880045
						local n22 = 40423252

						if handle then
							handle:SetAttribute("Emitted", nil)
							local v50 = table.pack(bit32.band(n21, 4294967295))
							local v51 = table.pack(bit32.band(v50[1], 65535))
							local v52 = bit32.band(v51[1] * 62952 + bit32.lshift(bit32.band(v51[1] * 0 + bit32.rshift(v50[1], 16) * 62952, 65535), 16), 4294967295)
							bit32.bxor(n22, 1747876246)
							bit32.bxor(v52, 811459493)
						end
					end

					bit32.bxor(n17, 1170954870)
					v49(0.05, fn13)
					local v50 = next
					local children, v51 = arg:GetChildren()

					for _, v52 in v50, children, v51 do
						if v52:IsA("ParticleEmitter") then
							local clone = v52:Clone()
							clone.Parent = default
							clone.Enabled = true
							clone:Emit(clone:GetAttribute("EmitCount") or 1)
							clone.Enabled = false
							game.Debris:AddItem(clone, 2)
						end
					end
				end

				Xpcall(fn12, ErrHandler)
			end

			Spawn(fn11)
		end

		CachedGunBeam = ReplicatedStorage:FindFirstChild("GunBeam")
		CachedAnimChar = nil
		CachedShootAnim = nil
		CachedAimShootAnim = nil
		local v48 = bit32.lshift(n12, 28)

		Animate = function(arg)
			local n13 = 1009500541
			local n14 = 226923098
			local n15 = 1389109620
			if not arg then
				return
			end
			local character = localPlayer.Character
			local flag2 = not character

			if not flag2 then
				local humanoid = character:FindFirstChild("Humanoid")
				bit32.bxor(n14, 729232694)
				flag2 = not humanoid
			end

			local v49

			if flag2 then
				v49 = flag2
			else
				local humanoid = character.Humanoid
				local v50 = table.pack(bit32.band(n15, 4294967295))
				local v51 = table.pack(bit32.band(n13, 4294967295))
				local v52 = table.pack(bit32.band(v50[1], 65535))
				local v53 = table.pack(bit32.rshift(v50[1], 16))
				local v54 = table.pack(bit32.band(v51[1], 65535))
				local v55 = bit32.band(v52[1] * v54[1] + bit32.lshift(bit32.band(v52[1] * bit32.rshift(v51[1], 16) + v53[1] * v54[1], 65535), 16), 4294967295)
				local flag3 = not humanoid:FindFirstChild("Animator")
				n15 = bit32.bxor(v55, 1940711632)
				v49 = flag3
			end

			if v49 then
				return
			end
			local gunCombat = CachedAnimations:FindFirstChild("GunCombat")
			if not gunCombat then
				return
			end
			local v50 = table.pack(bit32.band(n13, 4294967295))
			local v51 = table.pack(bit32.band(v50[1], 65535))
			local v52 = bit32.band(v51[1] * 65371 + bit32.lshift(bit32.band(v51[1] * 0 + bit32.rshift(v50[1], 16) * 65371, 65535), 16), 4294967295)
			local animator = character.Humanoid.Animator

			if CachedAnimChar ~= character then
				CachedAnimChar = character
				local v53 = animator:LoadAnimation(gunCombat.Shoot)
				local v54 = bit32.bor(n15, v52)
				CachedShootAnim = v53
				CachedAimShootAnim = animator:LoadAnimation(gunCombat.AimShoot)
				n15 = bit32.bxor(v54, 2835433995)
			end

			CachedShootAnim:Stop(0)
			local v53 = bit32.bxor(bit32.bor(n15, 1440249973), 84957185)
			CachedAimShootAnim:Stop(0)

			if flag or table.find(ScopedWeapons, arg.Name) then
				CachedAimShootAnim:Play()
			else
				CachedShootAnim:Play()
			end
		end

		ShowPellet = function(arg, parent, arg2, arg3, arg4, arg5, arg6)
			local n13 = 216185858
			local flag2 = type(0) ~= "number"
			local n14 = 2549696370
			local n15 = 2243263626
			local n16 = 964360876
			local n17 = 271360246
			arg5 = arg5 or Color3.new(1, 0.54509800672531128, 0.1490200012922287)
			local v49 = bit32.bxor(n17, 0)
			local n18 = v49
			local unit = (arg3 - arg2).Unit
			ShootRayParams.FilterDescendantsInstances = BuildFilter(ShootFilter, arg)
			local hit = Workspace:Raycast(arg2, unit * arg4, ShootRayParams)
			local n19 = bit32.bxor(n15, 4016504801)
			local position = hit and hit.Position or arg2 + unit * arg4
			local normal

			if hit then
				n14 = n19
				normal = hit.Normal
			else
				normal = hit
			end

			local v50 = normal or nil
			local instance = hit and hit.Instance or nil
			if arg6 then
				return position, instance, v50
			end
			local parent2 = parent and parent.Parent
			local n20

			if parent2 then
				parent2 = parent.Parent.Name
				local v51 = table.pack(bit32.band(v49, 4294967295))
				local v52 = table.pack(bit32.band(v51[1], 65535))
				local v53 = bit32.band(15882 * v52[1] + bit32.lshift(bit32.band(15882 * bit32.rshift(v51[1], 16) + 46953 * v52[1], 65535), 16), 4294967295)
				local v54 = table.pack(bit32.band(bit32.bnot(v49), 4294967295))
				local v55 = table.pack(bit32.band(v54[1], 65535))
				local n21 = 3515798756 + n13 + v53 + bit32.band(15882 * v55[1] + bit32.lshift(bit32.band(15882 * bit32.rshift(v54[1], 16) + 46953 * v55[1], 65535), 16), 4294967295)
				n18 = bit32.lshift(n18, 2) - 814080738
				n20 = n21 - 438671066
			else
				n20 = n13
			end

			local str = parent2 or ""
			local attribute = nil

			Pcall(function()
				attribute = parent:GetAttribute("SkinName")
			end)

			local flag3 = not attribute

			if flag3 or attribute == "" then
				local v51 = Pcall
				bit32.bxor(n14, 4207441962)
				local n21 = n18 - bit32.bxor(n17, 0)
				local n22 = n17 + 455887478

				v51(function()
					local n23 = 3698198805
					local n24 = 1431585718
					local n25 = 855717462
					local n26 = 1365360386
					local data = HttpService:JSONDecode(localPlayer.DataFolder.Information.EquipSkins.Value)
					data = data and data[str]
					local v52

					if data then
						v52 = data
					else
						bit32.bxor(n24, 3417087930)
						bit32.bxor(n23, 3627041788)
						local n27 = n25 - 3785324372
						v52 = nil
					end

					attribute = v52
				end)

				local v52 = bit32.bxor(n22, 0)
				local v53 = table.pack(bit32.band(n19, 4294967295))
				local v54 = table.pack(bit32.band(v52, 4294967295))
				local v55 = table.pack(bit32.band(v53[1], 65535))
				local v56 = table.pack(bit32.rshift(v53[1], 16))
				local v57 = table.pack(bit32.band(v54[1], 65535))
				n17 = n22 - 455887478
				n18 = n21 - 4023607050
				n19 = bit32.band(v55[1] * v57[1] + bit32.lshift(bit32.band(v55[1] * bit32.rshift(v54[1], 16) + v56[1] * v57[1], 65535), 16), 4294967295) - 4124255929
			end

			if flag3 or attribute == "" then
				attribute = "Default"
			end

			local v51 = CachedSkinAssets
			local part = Instance.new("Part")
			part.Name = "BULLET_RAYS"
			part.Anchored = true
			local v52 = bit32.band(n19, 853828784)
			part.CanCollide = false
			local v53 = table.pack(bit32.band(n17, 4294967295))
			local v54 = table.pack(bit32.band(v53[1], 65535))
			local v55 = bit32.band(1801 * v54[1] + bit32.lshift(bit32.band(1801 * bit32.rshift(v53[1], 16) + 44209 * v54[1], 65535), 16), 4294967295)
			local v56 = table.pack(bit32.band(bit32.bnot(n17), 4294967295))
			local v57 = table.pack(bit32.band(v56[1], 65535))
			local n21 = 3020539679 + n20 + v55 + bit32.band(1801 * v57[1] + bit32.lshift(bit32.band(1801 * bit32.rshift(v56[1], 16) + 44209 * v57[1], 65535), 16), 4294967295)
			part.CanTouch = false
			part.CanQuery = false
			local v58 = Vector3New
			local n22 = bit32.bxor(n18, 4294967295)
			part.Size = v58(0, 0, 0)
			part.Transparency = 1
			local n23 = v52 // n22
			part.CFrame = CFrameNew(arg2, position)
			local siren = CachedIgnored:FindFirstChild("Siren")

			if siren then
				local v59 = CachedIgnored
				local v60 = bit32.bxor(n22, 1623636340)
				siren = v59.Siren:FindFirstChild("Radius")
				n22 = bit32.bxor(v60, 1623636340)
			end

			if siren then
				siren = CachedIgnored.Siren.Radius
				n23 = bit32.bxor(bit32.bxor(n23, 444544200), 444544200)
			end

			part.Parent = siren or CachedIgnored
			local v59 = CachedGunBeam
			local impact = nil
			local n24 = n17 + 308750657
			local gunBeam = v51:FindFirstChild("GunBeam")

			if gunBeam then
				gunBeam = v51.GunBeam:FindFirstChild(attribute)
				n22 = bit32.bxor(n22, n23)
			end

			local gunBeam2, leftGunBeam, flag4

			if gunBeam then
				local v60 = v51.GunBeam[attribute]

				if v60:FindFirstChildOfClass("Beam") then
					local gunBeam3 = v60:FindFirstChild("GunBeam")
					n23 //= 92

					if gunBeam3 and v60:FindFirstChild("LeftGunBeam") then
						gunBeam2 = v60:FindFirstChild("GunBeam")
						leftGunBeam = v60:FindFirstChild("LeftGunBeam")
					else
						gunBeam2 = v60:FindFirstChildOfClass("Beam")
						leftGunBeam = nil
					end

					if v60:FindFirstChild("Impact") then
						impact = v60.Impact
					end

					flag4 = false
				else
					if v60:FindFirstChildWhichIsA("BasePart") then
						gunBeam2 = v60:FindFirstChildWhichIsA("BasePart")

						if gunBeam2:FindFirstChild("Different_GunBeam") then
							local differentGunBeam = gunBeam2.Different_GunBeam
							local n25 = n22 - bit32.bxor(n24, 0)
							flag4 = false

							if differentGunBeam:FindFirstChild(str) then
								local v61 = differentGunBeam[str]

								if v61:FindFirstChildWhichIsA("BasePart") then
									gunBeam2 = v61:FindFirstChildWhichIsA("BasePart")

									if gunBeam2:FindFirstChild("Impact") then
										local v62 = bit32.bxor(n24, 0)
										impact = gunBeam2.Impact
										n23 = bit32.bor(n23, v62) + 3714856393
									end
								elseif v61:FindFirstChildOfClass("Beam") then
									gunBeam2 = v61:FindFirstChildOfClass("Beam")

									if v61:FindFirstChild("Impact") then
										impact = v61.Impact
									end
								else
									gunBeam2 = CachedGunBeam
									flag4 = true
								end
							else
								gunBeam2 = v59
							end

							n22 = n25 - 3714856393
						else
							if gunBeam2:FindFirstChild("Impact") then
								impact = gunBeam2.Impact
							end

							flag4 = false
						end
					else
						gunBeam2 = CachedGunBeam
						n22 = bit32.bxor(n22, 506884881) + 4260246257
						flag4 = true
					end

					leftGunBeam = nil
				end
			else
				gunBeam2 = v59
				leftGunBeam = nil
				flag4 = true
			end

			local clone = gunBeam2 and gunBeam2:Clone() or nil
			local n25 = n23 + 1750784904
			local magnitude = (position - arg2).Magnitude
			local n26 = magnitude / 725

			if not clone then
				game.Debris:AddItem(part, 0.5)
				n22 = n22 + 2979557824 + 1315409472
			elseif clone:IsA("Beam") then
				game.Debris:AddItem(part, 0.5)
			else
				game.Debris:AddItem(part, n26 + 5)
			end

			if clone then
				local new = Instance.new
				local n27 = n22 // bit32.bxor(n24, 0)
				local n28 = n24 - 231616222
				local Attachment = new("Attachment")
				local v60 = bit32.bxor(n28, 0)
				local v61 = table.pack(bit32.band(n25, 4294967295))
				local v62 = table.pack(bit32.band(v60, 4294967295))
				local v63 = table.pack(bit32.band(v61[1], 65535))
				local v64 = table.pack(bit32.rshift(v61[1], 16))
				local v65 = table.pack(bit32.band(v62[1], 65535))
				local v66 = bit32.band(v63[1] * v65[1] + bit32.lshift(bit32.band(v63[1] * bit32.rshift(v62[1], 16) + v64[1] * v65[1], 65535), 16), 4294967295)
				Attachment.Position = Vector3New(0, 0, 0)
				Attachment.Parent = part
				local v67 = Instance
				local v68 = table.pack(bit32.band(n27, 4294967295))
				local v69 = table.pack(bit32.band(v66, 4294967295))
				local v70 = table.pack(bit32.band(v68[1], 65535))
				local v71 = table.pack(bit32.rshift(v68[1], 16))
				local v72 = table.pack(bit32.band(v69[1], 65535))
				local n29 = bit32.band(v70[1] * v72[1] + bit32.lshift(bit32.band(v70[1] * bit32.rshift(v69[1], 16) + v71[1] * v72[1], 65535), 16), 4294967295)
				local Attachment2 = v67.new("Attachment")
				Attachment2.Position = Vector3New(0, 0, -magnitude)
				Attachment2.Parent = part
				local isBeam = clone:IsA("Beam")
				local n30 = bit32.bxor(n28, 0)

				if isBeam then
					if flag4 and arg5 then
						clone.Color = ColorSequence.new(arg5)
						n30 = bit32.bxor(n30 + bit32.bxor(n28, 0), 1028566507)
					end

					clone.Attachment0 = Attachment
					clone.Attachment1 = Attachment2
					clone.Parent = part
					n28 = n28 + 6492984 - 6492984
				elseif clone:IsA("BasePart") then
					clone.Anchored = true
					clone.CanCollide = false
					clone.CanQuery = false
					local n31 = (n29 - 2715954310) // n30
					clone.CFrame = CFrameNew(arg2, position)
					local n32 = clone.CFrame * CFrameNew(0, 0, -magnitude)
					local parent3 = part.Parent
					local n33 = bit32.bxor(n30, 4294967295)
					clone.Parent = parent3

					if clone:GetAttribute("SpecialEffects") then
						local v73 = next
						local descendants, v74 = clone:GetDescendants()

						for _, v75 in v73, descendants, v74 do
							if v75:IsA("Trail") and v75:GetAttribute("ColorRandom") then
								local attribute2 = v75:GetAttribute("ColorRandom")
								v75.Color = ColorSequence.new(Color3.new(attribute2.X, attribute2.Y, attribute2.Z):Lerp(Color3.new(1, 1, 1), MathRandom()))
							end
						end
					end

					if attribute == "Undead" and str == "[Revolver]" then
						local n34 = n31 // n33
						local n35 = n28 + 185264757
						local n36 = n34
						local v73 = UndeadBeamColors[MathRandom(1, #UndeadBeamColors)]
						local trail = clone:FindFirstChildOfClass("Trail")

						if trail then
							local colorSequence = ColorSequence.new
							local tbl11 = {}
							local new2 = ColorSequenceKeypoint.new
							local v74 = bit32.bor(n36, 759384994)
							local v75 = new2(0, v73)
							local new3 = ColorSequenceKeypoint.new
							tbl11[1] = v75

							do
								local values = table.pack(new3(1, v73))
								table.move(values, 1, values.n, 2, tbl11)
							end

							trail.Color = colorSequence(tbl11)
							n36 = v74 - 759384994
						end

						local v74 = bit32.bxor(n35, 0)
						n28 = n35 - 185264757
						n31 = bit32.bxor(v74, 533759435)
						n33 = n36 - 348494682
					end

					Spawn(function()
						local tween = TweenService:Create(clone, TweenInfo.new(0.05, Enum.EasingStyle.Linear), { CFrame = clone.CFrame * CFrameNew(0, 0, -0.1) })
						tween:Play()
						local n34 = 7538900760
						Wait(0.05)
						local playbackState = tween.PlaybackState
						local playbackState2 = Enum.PlaybackState
						local v73 = table.pack(bit32.band(n34, 4294967295))
						local v74 = table.pack(bit32.band(v73[1], 65535))
						local v75 = bit32.band(48890 * v74[1] + bit32.lshift(bit32.band(48890 * bit32.rshift(v73[1], 16) + 52504 * v74[1], 65535), 16), 4294967295)

						if playbackState ~= playbackState2.Completed then
							tween:Pause()
						end

						local tbl11 = { CFrame = n32 }
						local tween2 = TweenService:Create(clone, TweenInfo.new(n26, Enum.EasingStyle.Linear), tbl11)
						tween2:Play()
						Wait(n26)
						local n35 = n34 // v75
						local impact2 = clone:FindFirstChild("Impact")

						if impact2 then
							impact2 = instance and v50

							if impact2 then
								impact2 = not instance.Parent:FindFirstChild("Humanoid")
								v75 = bit32.bxor(bit32.lshift(v75, 13), 1667100016)
							end
						end

						if impact2 then
							if tween2.PlaybackState ~= Enum.PlaybackState.Completed then
								Wait(0.05)
							end

							if not clone:FindFirstChild("NoNormal") then
								local v76 = n35
								clone.CFrame = CFrameNew(position, position - v50)
								n35 = n35 * v76 + 4294967266
								v75 = bit32.bxor(v76, 519302518)
							end

							local v76 = next
							local children, v77 = clone.Impact:GetChildren()

							for _, v78 in v76, children, v77 do
								if v78:IsA("ParticleEmitter") then
									v78:Emit(v78:GetAttribute("EmitCount") or 1)
								end
							end
						else
							local v76 = next
							local children, v77 = clone:GetChildren()

							for _, v78 in v76, children, v77 do
								if v78:IsA("BasePart") then
									v78.Transparency = 1
								end
							end
						end

						if clone then
							local v76 = next
							local n36 = v75 + n35
							local descendants, v77 = clone:GetDescendants()

							for _, v78 in v76, descendants, v77 do
								if v78:IsA("ParticleEmitter") then
									v78.Enabled = false
								end
							end

							local n37 = n36 - 6
						end
					end)

					n29 = bit32.bxor(n31, 486145461)
					n30 = n33 + 696989363
				end

				if leftGunBeam then
					local v73 = bit32.lshift(n29, 11)
					local n31 = v73
					local parent3 = parent and parent.Parent
					local v74 = nil

					if parent3 then
						local default = parent3:FindFirstChild("Default")
						v74 = nil

						if default then
							local mesh = default:FindFirstChild("Mesh")
							v74 = nil

							if mesh then
								local v75 = next
								local children, v76 = mesh:GetChildren()
								v74 = nil

								for _, v77 in v75, children, v76 do
									if v77:IsA("BasePart") and v77:GetAttribute("SecondaryMesh") then
										v74 = v77
									end
								end
							end
						end
					end

					if v74 then
						local leftMuzzle = v74:FindFirstChild("LeftMuzzle") or v74:FindFirstChildOfClass("Attachment")

						if leftMuzzle then
							local worldPosition = leftMuzzle.WorldPosition
							local magnitude2 = (position - worldPosition).Magnitude
							local v75 = bit32.bor(n30, n31)
							local n32 = magnitude2 / 725
							local part2 = Instance.new("Part")
							part2.Name = "BULLET_RAYS"
							part2.Size = Vector3New(0, 0, 0)
							part2.Transparency = 1
							part2.CanCollide = false
							local v76 = bit32.bor(v75, 1869555581)
							part2.CanTouch = false
							part2.CanQuery = false
							local v77 = bit32.band(n31, 2743926200)
							part2.Anchored = true
							local n33 = n28 + 118460878
							part2.CFrame = CFrameNew(worldPosition, position)
							local v78 = bit32.bor(v76, v77)
							part2.Parent = part.Parent
							local n34 = bit32.bor(v77, 2568862716)
							local clone2 = leftGunBeam:Clone()

							if clone2:IsA("Beam") then
								local attachment = Instance.new("Attachment")
								attachment.Position = Vector3New(0, 0, 0)
								local n35 = bit32.bxor(v78, 1022306626)
								attachment.Parent = part2
								local attachment2 = Instance.new("Attachment")
								local v79 = table.pack(bit32.band(n34, 4294967295))
								local v80 = table.pack(bit32.band(v79[1], 65535))
								local v81 = bit32.band(v80[1] * 34428 + bit32.lshift(bit32.band(v80[1] * 0 + bit32.rshift(v79[1], 16) * 34428, 65535), 16), 4294967295)
								attachment2.Position = Vector3New(0, 0, -magnitude2)
								attachment2.Parent = part2

								if flag4 and arg5 then
									clone2.Color = ColorSequence.new(arg5)
									n35 = n35 - 359847583 + 359847583
								end

								clone2.Attachment0 = attachment
								clone2.Attachment1 = attachment2
								local v82 = bit32.bor(v81, 2923751285)
								clone2.Parent = part2
								game.Debris:AddItem(part2, 0.5)
								n33 = n33 - 186041803 + 186041803
								n34 = v82 - 1664039801
								v78 = bit32.bxor(n35, 1022306626)
							elseif clone2:IsA("BasePart") then
								clone2.Anchored = true
								clone2.CanCollide = false
								clone2.CanQuery = false
								local v79 = CFrameNew
								local v80 = bit32.bxor(n33, 0)
								local v81 = table.pack(bit32.band(v78, 4294967295))
								local v82 = table.pack(bit32.band(v80, 4294967295))
								local v83 = table.pack(bit32.band(v81[1], 65535))
								local v84 = table.pack(bit32.rshift(v81[1], 16))
								local v85 = table.pack(bit32.band(v82[1], 65535))
								local v86 = bit32.band(v83[1] * v85[1] + bit32.lshift(bit32.band(v83[1] * bit32.rshift(v82[1], 16) + v84[1] * v85[1], 65535), 16), 4294967295)
								clone2.CFrame = v79(worldPosition, position)
								local n35 = clone2.CFrame * CFrameNew(0, 0, -magnitude2)
								clone2.Parent = part2.Parent
								game.Debris:AddItem(part2, n32 + 5)
								local v87 = Spawn
								local v88 = bit32.bxor(n33, 0)
								local v89 = table.pack(bit32.band(n34 - 2990341830, 4294967295))
								local v90 = table.pack(bit32.band(v88, 4294967295))
								local v91 = table.pack(bit32.band(v89[1], 65535))
								local v92 = table.pack(bit32.rshift(v89[1], 16))
								local v93 = table.pack(bit32.band(v90[1], 65535))
								local v94 = bit32.band(v91[1] * v93[1] + bit32.lshift(bit32.band(v91[1] * bit32.rshift(v90[1], 16) + v92[1] * v93[1], 65535), 16), 4294967295)

								v87(function()
									local tbl11 = { CFrame = n35 }
									TweenService:Create(clone2, TweenInfo.new(n32, Enum.EasingStyle.Linear), tbl11):Play()
									Wait(n32)
									local v95 = next
									local n36 = 587550112
									local descendants, v96 = clone2:GetDescendants()

									for _, v97 in v95, descendants, v96 do
										if v97:IsA("ParticleEmitter") then
											v97.Enabled = false
										end
									end
								end)

								n34 = v94 + 3970984642
								v78 = bit32.bxor(v86, 1541380726)
							end

							Spawn(function()
								local n35 = 3250703572
								local v79 = next
								local children, v80 = leftMuzzle:GetChildren()

								for _, v81 in v79, children, v80 do
									local isParticleEmitter = v81:IsA("ParticleEmitter")
									n35 = bit32.bxor(n35, 2868424982)

									if isParticleEmitter then
										v81:Emit(v81:GetAttribute("EmitCount") or 1)
									end
								end
							end)

							n28 = n33 - 118460878
							n31 = n34 + 877642756
							n30 = v78 - 2300452430 + 2650012202
						end
					end

					n29 = n31 + 1292664240
				end

				Spawn(function()
					local n31 = 2605602976
					local n32 = 4243249561

					if hit and impact then
						type(1641498569)
						local n33 = 387158931

						Xpcall(function()
							local n34 = 3534853675
							local n35 = 391583089
							local v73 = bit32.bxor(n33, 3142329640)
							local n36 = 1703557554
							local flag5 = instance

							if instance then
								flag5 = not instance.Parent:FindFirstChildOfClass("Humanoid")
								n36 = bit32.bxor(n36 // v73, 1703557554)
							end

							if flag5 then
								local n37 = 494295395

								if type(flag5) == "number" then
									bit32.bxor(n37, 2746807461)
								end

								local v74 = Instance
								local v75 = table.pack(bit32.band(n37, 4294967295))
								local v76 = table.pack(bit32.band(v75[1], 65535))
								local n38 = bit32.band(18144 * v76[1] + bit32.lshift(bit32.band(18144 * bit32.rshift(v75[1], 16) + 24205 * v76[1], 65535), 16), 4294967295) + 1933259872
								local v77 = table.pack(bit32.band(bit32.bor(n37, 238806517), 4294967295))
								local v78 = table.pack(bit32.band(v77[1], 65535))
								local v79 = bit32.band(47393 * v78[1] + bit32.lshift(bit32.band(47393 * bit32.rshift(v77[1], 16) + 41330 * v78[1], 65535), 16), 4294967295)
								local v80 = table.pack(bit32.band(bit32.band(n37, 238806517), 4294967295))
								local v81 = table.pack(bit32.band(v80[1], 65535))
								local n39 = n38 + v79 + bit32.band(47391 * v81[1] + bit32.lshift(bit32.band(47391 * bit32.rshift(v80[1], 16) + 41330 * v81[1], 65535), 16), 4294967295)
								local Part = v74.new("Part")
								local v82 = Delay
								local v83 = n36

								local function fn11()
									local n40 = 2646936981
									local n41 = 3686712485
									local n42 = 1816767921

									if Part then
										bit32.bxor(n40, 2184334225)
										Part:Destroy()
										bit32.bxor(n41, 984929335)
										local n43 = n42 - 1118740378 + 1118740378
									end
								end

								local n40 = bit32.bxor(n33, 0) + 233479458
								v82(5, fn11)
								Part.Transparency = 1
								Part.Name = "BULLETHOLE"
								local n41 = bit32.band(n36, v83)
								local v84 = Vector3New
								bit32.bxor(n35, 3829086068)
								Part.Size = v84(0.83, 0.731, 0.001)
								Part.Anchored = true
								Part.CanCollide = false
								local n42 = bit32.bxor(v83, n41)
								Part.CanTouch = false
								Part.CanQuery = false
								local clone2 = impact:Clone()
								clone2.Parent = Part
								local n43 = v50

								if v50 then
									n43 = v50 * 0.1
									n42 = n42 + n41 + 2591409742
								end

								if not n43 then
									local v85 = Vector3New
									local v86 = bit32.band(n41, n42)
									n43 = v85(0, 0, 0)
									n41 = v86 - 2591409742
								end

								Part.Position = position + n43
								local v85 = CFrameNew
								local n44 = position + n43
								local v86 = position
								local v87 = v50

								if not v50 then
									v87 = Vector3New(0, 1, 0)
									n41 = n41 * 2 + 2591409742
								end

								Part.CFrame = v85(n44, v86 + v87)
								local v88 = CustomBulletHoleRotations[attribute]

								if v88 then
									if typeof(v88) == "string" then
										if v88 == "Position" then
											clone2.Position = Part.Position
										else
											clone2.CFrame = Part.CFrame
										end
									else
										local n45 = n42 * 24064

										if typeof(v88) == "table" then
											n42 = n45 * n41 * n45
											local v89 = MathRad
											local z = v88[2].Z
											clone2.CFrame = clone2.CFrame * v88[1] * CFrame.Angles(MathRad(v88[2].X), MathRad(v88[2].Y), v89(z))
										else
											local v89 = MathRad
											local z = v88.Z
											clone2.CFrame = clone2.CFrame * CFrame.Angles(MathRad(v88.X), MathRad(v88.Y), v89(z))
											n42 = n45 + 2236316148 - 2236316148
										end
									end
								else
									local isPart = clone2:IsA("Part")
									local v89 = bit32.band(n41, 2867087819)

									if isPart then
										clone2.CFrame = Part.CFrame
										bit32.bxor(n34, 4142081637)
										n42 = bit32.bxor(bit32.bxor(n42, 2613489180), 2613489180)
									end
								end

								Part.Parent = part.Parent
								local v89 = next
								local descendants, v90 = Part:GetDescendants()

								for _, v91 in v89, descendants, v90 do
									if v91:IsA("ParticleEmitter") then
										v91:Emit(v91:GetAttribute("EmitCount") or 1)
									end
								end

								bit32.bxor(n42, 2891953851)
							end
						end, ErrHandler)

						local v73 = bit32.bxor(n31 // n32, 2605602976)
					end
				end)

				n24 = n28 + 231616222
				n22 = n29 - 757505703
				n25 = n30 + 1402290223
			end

			local function fn11(parent3, arg7)
				local n27 = 1314660962
				local n28 = 2428956155
				local n29 = bit32.bxor(n21, 2703424159)
				local n30 = 2971541264
				local shootSound = parent3:FindFirstChild("ShootSound")
				if not shootSound then
					return
				end
				local flag5 = attribute

				if attribute then
					local v60 = attribute
					local v61 = table.pack(bit32.band(n29, 4294967295))
					local v62 = table.pack(bit32.band(n30, 4294967295))
					local v63 = table.pack(bit32.band(v61[1], 65535))
					local v64 = table.pack(bit32.rshift(v61[1], 16))
					local v65 = table.pack(bit32.band(v62[1], 65535))
					flag5 = v60 ~= "Default"
					n29 = bit32.band(v63[1] * v65[1] + bit32.lshift(bit32.band(v63[1] * bit32.rshift(v62[1], 16) + v64[1] * v65[1], 65535), 16), 4294967295) + 828687639
				end

				if flag5 and v51 then
					local gunShootSounds = v51:FindFirstChild("GunShootSounds")

					if gunShootSounds then
						local v60 = gunShootSounds:FindFirstChild(str)

						if v60 then
							local v61 = v60:FindFirstChild(attribute)
							local isStringValue = v61 and v61:IsA("StringValue")

							if isStringValue then
								isStringValue = v61.Value ~= ""
								n30 = n30 - 4116259762 + 4116259762
							end

							if isStringValue then
								shootSound.SoundId = v61.Value
							end
						end
					end
				end

				local attribute2 = shootSound:GetAttribute("SequenceSFX")

				if attribute2 then
					local n31 = n30 - n29

					if shootSound:GetAttribute("CurrentSequence") == nil then
						shootSound:SetAttribute("CurrentSequence", 1)
					else
						shootSound:SetAttribute("CurrentSequence", shootSound:GetAttribute("CurrentSequence") + 1)
					end

					local attribute3 = shootSound:GetAttribute("CurrentSequence")
					local tbl11 = {}

					for match in string.gmatch(attribute2, "%d+") do
						table.insert(tbl11, match)
					end

					bit32.bxor(n27, 3835873281)
					local v60 = bit32.bxor(n29, n31)

					if #tbl11 > 0 then
						local v61 = bit32.bxor(n31, v60)
						shootSound.SoundId = "rbxassetid://" .. tbl11[attribute3 % #tbl11 + 1]
						n31 = v61 - 3105156606
					end

					n29 = bit32.bxor(v60, 4228159625)
				end

				if arg7 then
					local flag6 = type("ShootSound") == "thread"
					local clone2 = shootSound:Clone()
					clone2.Name = "\0"
					bit32.bxor(n28, 662841902)
					clone2.Parent = parent3
					local n31 = 8887143318
					clone2:Play()

					clone2.Ended:Once(function()
						if clone2.Parent then
							clone2:Destroy()
						end
					end)
				else
					shootSound:Play()
				end
			end

			if ShotgunWeapons[str] then
				local flag5 = not parent:GetAttribute("PlayingSound")
				local n27 = n22 // bit32.bxor(n24, 0)

				if flag5 then
					parent:SetAttribute("PlayingSound", true)
					local n28 = n25 - bit32.bxor(n24, 0)

					Delay(0.075, function()
						local n29 = 2058744943
						local n30 = 2403445014
						local n31 = 701566281
						local parent3 = parent

						if parent then
							local v60 = parent
							bit32.bxor(n29, 3494090405)
							local n32 = n30 // n31 + 2403445011
							parent3 = v60.Parent
						end

						if parent3 then
							parent:SetAttribute("PlayingSound", nil)
						end
					end)

					Spawn(function()
						local n29 = 2787613681
						local n30 = 64094941
						local n31 = 2316149130

						if not tbl6[parent] then
							local flag6 = bit32.bxor(n31, 425362778) == 303103690
							local v60 = fn11
							bit32.bxor(n29, 2899114963)
							v60(parent, true)
							local n32 = 261161892
							tbl6[parent] = true

							Delay(0.021, function()
								tbl6[parent] = nil
							end)

							bit32.bxor(n30 // 168, 64475280)
						end
					end)

					n25 = bit32.bxor(n28, 765315801)
				end

				n22 = n27 - 271360253
			else
				local v60

				if attribute == "Toilet" then
					local tbl11 = { 125391056005695, 132466522418892, 129999172684348 }
					local new = Instance.new
					local v61 = bit32.bxor(n24, 0)
					local Sound = new("Sound")
					local v62 = bit32.bxor(n24, 0)
					v60 = bit32.bxor(n25, v62)
					Sound.Name = "ShootSound"
					Sound.SoundId = "rbxassetid://" .. tbl11[MathRandom(1, #tbl11)]
					local v63 = bit32.bxor(37486489, 393481486)
					Sound.Parent = parent
					local v64 = bit32.bxor(v63, 312618928)
					local v65 = bit32.bxor(n24, 0)
					local v66 = bit32.bor(v61, v65)
					local v67 = bit32.bxor(v64, 20467051)

					Sound.Ended:Once(function()
						Sound:Destroy()
					end)

					Sound:Play()
					n22 = v66 + 3443496146
				else
					Spawn(function()
						local n27 = 691691434
						local n28 = 517580048
						local n29 = 13150892

						if not tbl6[parent] then
							fn11(parent, true)
							tbl6[parent] = true
							local v61 = Delay
							local n30 = 618070708
							bit32.bxor(n27, 1961182141)

							v61(0.021, function()
								tbl6[parent] = nil
							end)
						end
					end)

					v60 = bit32.bxor(bit32.band(n25, n22), 580602551)
				end

				n25 = bit32.bxor(v60, 580110903)
			end

			local flag5 = false

			Spawn(function()
				local n27 = 3204630166
				local n28 = 3843537688
				local n29 = 3620030825
				if not v51 then
					return
				end
				local gunSkinMuzzleParticle = v51:FindFirstChild("GunSkinMuzzleParticle")
				local v60 = n29
				if not gunSkinMuzzleParticle then
					return
				end
				local v61 = gunSkinMuzzleParticle:FindFirstChild(str)

				if v61 then
					local muzzle = v61:FindFirstChild("Muzzle")

					if muzzle then
						DoMuzzleEmit(muzzle, arg)
					else
						local v62 = DoMuzzleEmit
						local v63 = table.pack(bit32.band(n28, 4294967295))
						local v64 = table.pack(bit32.band(n29, 4294967295))
						local v65 = table.pack(bit32.band(v63[1], 65535))
						local v66 = table.pack(bit32.rshift(v63[1], 16))
						local v67 = table.pack(bit32.band(v64[1], 65535))
						local v68 = bit32.band(v65[1] * v67[1] + bit32.lshift(bit32.band(v65[1] * bit32.rshift(v64[1], 16) + v66[1] * v67[1], 65535), 16), 4294967295)
						v62(v61, arg)
					end

					flag5 = true
				else
					local v62 = gunSkinMuzzleParticle:FindFirstChild(attribute)

					if v62 then
						local muzzle = v62:FindFirstChild("Muzzle")

						if muzzle then
							local differentGunMuzzle = muzzle:FindFirstChild("Different_GunMuzzle")

							if differentGunMuzzle and differentGunMuzzle:FindFirstChild(str) then
								local v63 = DoMuzzleEmit
								local v64 = differentGunMuzzle[str]
								local v65 = bit32.bxor(n29, n28)
								v63(v64, arg)
							else
								DoMuzzleEmit(muzzle, arg)
							end

							flag5 = true
						else
							local particleEmitter = v62:FindFirstChildOfClass("ParticleEmitter")

							if particleEmitter then
								local v63 = parent
								bit32.bxor(n27, 146983385)
								local parent3 = v63.Parent
								local muzzle2 = nil

								if parent3 then
									local default = parent3:FindFirstChild("Default")
									muzzle2 = nil

									if default then
										local mesh = default:FindFirstChild("Mesh")
										muzzle2 = nil

										if mesh then
											muzzle2 = mesh:FindFirstChild("Muzzle")
											n28 = n29 + 223506863
										end
									end
								end

								muzzle2 = muzzle2 or parent:FindFirstChild("Muzzle")

								if muzzle2 then
									local clone2 = particleEmitter:Clone()
									bit32.bxor(v60, 1163322566)
									clone2.Rotation = NumberRange.new(MathRandom(-180, 180))
									clone2.RotSpeed = NumberRange.new(MathRandom(-90, 90))
									local v64 = bit32.lshift(n29 + 2282186775, 28)
									clone2.Parent = muzzle2
									clone2:Emit(1)
									flag5 = true
									bit32.bxor(v64, 3620030825)
									bit32.bxor(n28 - 3905150934, 423911514)
								end
							end
						end
					end
				end
			end)

			Xpcall(function()
				local n27 = 3862760632
				local shootBBGUI = parent.Parent.Handle:FindFirstChild("ShootBBGUI")

				if shootBBGUI then
					shootBBGUI.Enabled = not flag5
					bit32.bxor(n27, 807340317)
				end
			end, ErrHandler)

			local n27 = n24 + 102645620
			local pointLight = Instance.new("PointLight")
			local n28 = n25 - bit32.bxor(n27, 0)
			pointLight.Brightness = 0.5
			pointLight.Range = 15
			local v60 = bit32.bxor(n27, 0)
			local v61 = bit32.bxor(n22, v60)
			pointLight.Shadows = false
			local v62 = table.pack(bit32.band(v61, 4294967295))
			local v63 = table.pack(bit32.band(v62[1], 65535))
			local v64 = bit32.band(v63[1] * 13327 + bit32.lshift(bit32.band(v63[1] * 0 + bit32.rshift(v62[1], 16) * 13327, 65535), 16), 4294967295)
			pointLight.Color = Color3.new(1, 1, 1)
			pointLight.Parent = part
			local tween = TweenService:Create(pointLight, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.In), { Range = 0 })
			tween:Play()
			local connection = nil

			connection = tween.Completed:Connect(function()
				local n29 = 363020365
				local n30 = 2041244090

				if pointLight then
					pointLight:Destroy()
					bit32.bxor(n29, 1069649477)
				end

				local v65 = connection
				bit32.bxor(n30, 3113416746)
				v65:Disconnect()
			end)

			local v65 = bit32.bxor(n27, 0)
			local v66 = bit32.bxor(n28, v65)
			local bodyEffects = arg:FindFirstChild("BodyEffects")

			if bodyEffects then
				local movement = bodyEffects:FindFirstChild("Movement")

				if movement then
					local intValue = Instance.new("IntValue")
					local n29 = v66 * 11
					intValue.Name = "ReduceWalk"
					intValue.Value = 5
					intValue.Parent = movement
					local shootingCooldown = parent.Parent and parent.Parent:FindFirstChild("ShootingCooldown")

					Delay(shootingCooldown and tonumber(shootingCooldown.Value) or 0.3, function()
						local n30 = 720286221
						local n31 = 1700471801
						local parent3 = intValue

						if intValue then
							local v67 = intValue
							bit32.bxor(n30, 1816043878)
							parent3 = v67.Parent
							bit32.bxor(n31 // 213, 1696789170)
						end

						if parent3 then
							intValue:Destroy()
						end
					end)

					v66 = bit32.bxor(n29, 3913127268)
				end
			end

			local function fn12()
				Animate(parent.Parent)
			end

			Spawn(fn12)
			return position, instance, v50
		end

		GetDoubleTapCount = function(arg)
			local n13 = 411510554
			local modifications = fn().Modifications
			local v49 = table.pack(bit32.band(n13, 4294967295))
			local v50 = table.pack(bit32.band(v49[1], 65535))
			local v51 = bit32.band(26467 * v50[1] + bit32.lshift(bit32.band(26467 * bit32.rshift(v49[1], 16) + 58714 * v50[1], 65535), 16), 4294967295)
			local doubleTap = modifications["Double Tap"]
			if not doubleTap.Enabled then
				return 1
			end
			local mode = doubleTap.Mode
			local v52 = table.pack(bit32.band(n13, 4294967295))
			local v53 = table.pack(bit32.band(v52[1], 65535))
			local v54 = bit32.band(v53[1] * 52966 + bit32.lshift(bit32.band(v53[1] * 0 + bit32.rshift(v52[1], 16) * 52966, 65535), 16), 4294967295)
			if mode ~= "Always" and not State.DoubleTapActive then
				return 1
			end
			local weaponConfigs = doubleTap["Weapon Configs"]
			local enabled

			if weaponConfigs then
				enabled = weaponConfigs.Enabled
				bit32.bxor(v54 - 4222507737, 97632223)
			else
				enabled = weaponConfigs
			end

			if enabled then
				local flag2 = weaponConfigs[fn4(arg)]

				if flag2 then
					flag2 = not flag2.Enabled
					local n14 = bit32.rshift(v51, 13) - 568548366
				end

				if flag2 then
					return 1
				end
			end

			return 2
		end

		tbl10 = {}
		defaultConfig = { Enabled = true }
		v30 = bit32.bor(v48, 3341290039)
	end

	local v31, v32, n9

	do
		local weapons = { Shotguns = { Enabled = true, Mode = "half" } }
		local pistols = { Enabled = true }
		local v33 = bit32.band(n8, 278829241)
		local v34 = bit32.bxor(v29, 0)
		local v35 = table.pack(bit32.band(v33, 4294967295))
		local v36 = table.pack(bit32.band(v34, 4294967295))
		local v37 = table.pack(bit32.band(v35[1], 65535))
		local v38 = table.pack(bit32.rshift(v35[1], 16))
		local v39 = table.pack(bit32.band(v36[1], 65535))
		local v40 = bit32.band(v37[1] * v39[1] + bit32.lshift(bit32.band(v37[1] * bit32.rshift(v36[1], 16) + v38[1] * v39[1], 65535), 16), 4294967295)
		pistols.Mode = "full"
		weapons.Pistols = pistols
		weapons.Others = { Enabled = true, Mode = "full" }
		defaultConfig.Weapons = weapons
		tbl10.DefaultConfig = defaultConfig
		local shotgunWeapons = { ["[Double-Barrel SG]"] = true }
		v31 = bit32.rshift(v30, 19)
		shotgunWeapons["[TacticalShotgun]"] = true
		shotgunWeapons["[Tactical Shotgun]"] = true
		shotgunWeapons["[Tactical-Shotgun]"] = true
		local v41 = bit32.bxor(v29, 77640843)
		local bxor = bit32.bxor
		local v42 = bit32.bxor(v29, 0)
		local v43 = bxor(v40, v42)
		v32 = v41
		shotgunWeapons["[Shotgun]"] = true
		shotgunWeapons["[Drum-Shotgun]"] = true
		tbl10.ShotgunWeapons = shotgunWeapons
		n9 = v43 // 5
	end

	tbl10.PistolWeapons = { ["[Revolver]"] = true, ["[Silencer]"] = true, ["[Glock]"] = true, ["[Deagle]"] = true }

	tbl10.GetWeaponClass = function(arg)
		local n10 = 1271867127
		local n11 = 1972944403
		local n12 = 1453903168
		if tbl10.ShotgunWeapons[arg] then
			return "Shotguns"
		end
		local v33 = tbl10
		bit32.bxor(n11, 2753554585)
		bit32.bxor(n10, 914362760)
		if v33.PistolWeapons[arg] then
			return "Pistols"
		end
		return "Others"
	end

	tbl10.GetOverridePart = function(arg, arg2)
		local n10 = 3185125164
		local n11 = 162070573
		local n12 = 3764916373
		local n13 = 1774649109
		if not arg then
			return nil
		end
		bit32.bxor(n11, 971406627)
		local n14 = n13 * 2
		if arg2 == "full" then
			return arg:FindFirstChild("Head")
		end

		if arg2 == "half" then
			return arg:FindFirstChild("HumanoidRootPart")
		end

		if arg2 == "min" then
			return arg:FindFirstChild("Right Leg") or arg:FindFirstChild("RightLeg")
		end
		bit32.bor(n12, n14)
		bit32.bxor(n10, 3280064424)
		return nil
	end

	tbl10.GetConfig = function(arg)
		local n10 = 1880852506
		local n11 = 141278101
		local n12 = 831069765
		local n13 = 831069765
		local defaultConfig2

		if arg then
			defaultConfig2 = arg
		else
			local v33 = tbl10
			bit32.bxor(n10, 3714470484)
			local v34 = bit32.lshift(n12, 20)
			bit32.bxor(n11, 1920013300)
			defaultConfig2 = v33.DefaultConfig
		end

		return defaultConfig2
	end

	tbl10.Apply = function(arg, arg2, arg3, arg4, arg5, arg6)
		local n10 = 4021117613
		local n11 = 5054980
		local v33 = tbl10.GetConfig(arg5)
		if not v33 or not v33.Enabled or not arg3 or not arg3.Parent then
			return arg2, arg3, arg4
		end
		local weapons = v33.Weapons
		if not weapons then
			return arg2, arg3, arg4
		end
		local v34 = (arg6 or tbl10.GetWeaponClass)(arg)
		bit32.lshift(n11, 24)
		weapons = weapons and weapons[v34]
		if not weapons or not weapons.Enabled then
			return arg2, arg3, arg4
		end
		local model = arg3:FindFirstAncestorOfClass("Model")
		if not model or not model:FindFirstChildOfClass("Humanoid") then
			return arg2, arg3, arg4
		end
		local v35 = tbl10.GetOverridePart(model, weapons.Mode)
		if not v35 then
			return arg2, arg3, arg4
		end
		return arg2, v35, arg4
	end

	local v33 = tbl10

	ApplyDamageModifierHit = function(arg, arg2, arg3, arg4)
		local n10 = 3117479255
		local n11 = 531569633
		local n12 = 397412906
		local damageModifier = fn().Modifications["Das Hood"]["Damage Modifier"]
		local flag2 = v33
		local n13 = 531569633

		if v33 then
			local v34 = type
			local v35 = bit32.bxor(n12, 4294967295)
			local v36 = v34(v33.Apply)
			local v37 = bit32.bor(n11, v35)
			flag2 = v36 == "function"
			n12 = v35 - 3500141483
			n11 = bit32.bxor(v37, 3762349076)
		end

		if flag2 then
			return v33.Apply(arg, arg2, arg3, arg4, damageModifier, fn4)
		end
		local flag3 = not damageModifier
		local flag4

		if flag3 then
			flag4 = flag3
		else
			flag4 = not damageModifier.Enabled
			n11 = n11 - 1196279959 - 3098687337
		end

		if flag4 or not arg3 or not arg3.Parent then
			return arg2, arg3, arg4
		end
		local weapons = damageModifier.Weapons
		if not weapons then
			return arg2, arg3, arg4
		end
		local v34 = weapons[fn4(arg)]
		local flag5 = not v34
		local flag6

		if flag5 then
			flag6 = flag5
		else
			n12 = n12 * 7 - 2384477436
			flag6 = not v34.Enabled
		end

		if flag6 then
			return arg2, arg3, arg4
		end
		local model = arg3:FindFirstAncestorOfClass("Model")
		if not model or not model:FindFirstChildOfClass("Humanoid") then
			return arg2, arg3, arg4
		end
		local flag7 = v34.Mode == "full"
		bit32.bxor(n10, 312562640)
		local head

		if flag7 then
			head = model:FindFirstChild("Head")
		elseif v34.Mode == "half" then
			head = model:FindFirstChild("HumanoidRootPart")
		else
			local n14 = n12 - 1162199893
			head = nil

			if v34.Mode == "min" then
				head = model:FindFirstChild("Right Leg") or model:FindFirstChild("RightLeg")
			end
		end

		if not head then
			return arg2, arg3, arg4
		end
		return arg2, head, arg4
	end

	local fn11, v34, v35, v36, fn12, v37, v38, v39, v40

	do
		local n10 = v31 // bit32.bxor(v32, 0)

		EmulateGunFire = function(arg)
			local n11 = 768001326
			local n12 = 2865560201
			local n13 = 1979691782
			local n14 = 2197132819
			local character = localPlayer.Character
			if not character then
				return
			end

			if _G.GUN_COMBAT_TOGGLE then
				return
			end
			local v41 = CanShoot(character)
			local n15 = bit32.bor(n13, 2616851235)
			if not v41 then
				return
			end
			local handle = arg:FindFirstChild("Handle")
			if not handle then
				return
			end
			local ammo = arg:FindFirstChild("Ammo")
			local flag2 = not ammo

			if not flag2 then
				n11 = n14
				flag2 = ammo.Value <= 0
			end

			if flag2 then
				local noAmmo = handle:FindFirstChild("NoAmmo")

				if noAmmo then
					noAmmo:Play()
				end

				return
			end

			local range = arg:FindFirstChild("Range")

			if range then
				range = range.Value
				n15 = n15 // n14 - 1242
			end

			range = range or 200
			local remoteEvent = arg:FindFirstChild("RemoteEvent")

			if not remoteEvent then
				remoteEvent = {}
				local n16 = 68755041

				local function fireServer()
				end

				local flag3 = bit32.bxor(n15, 33364622) == 27421514
				remoteEvent.FireServer = fireServer
			end

			local v42 = GetMuzzlePosition(arg)
			if not v42 then
				return
			end
			local v43 = ShotgunWeapons
			local name = arg.Name
			local v44 = bit32.bxor(n14, n15)
			local flag3 = v43[name] or false
			ShootRayParams.FilterDescendantsInstances = BuildFilter(ShootFilter, character)
			remoteEvent:FireServer("Shoot")
			local v45 = GetDoubleTapCount
			local name2 = arg.Name
			bit32.bxor(n12, 3250385191)

			for i = 1, v45(name2) do
				if flag3 then
					local serverTimeNow = Workspace:GetServerTimeNow()
					local spreadModifications = fn().Modifications["Spread Modifications"]
					local n16 = 1

					if spreadModifications.Enabled then
						n16 = spreadModifications.Value or 1
						local randomizer = spreadModifications.Randomizer

						if randomizer and randomizer.Enabled then
							local min = randomizer.Min or 1
							local max = randomizer.Max or 1
							local v46 = MathRandom
							n11 = bit32.bxor(n11, 3161877352)
							n16 *= min + (max - min) * v46()
						end
					end

					for i2 = 1, 5 do
						local v46 = Vector3New((MathRandom() > 0.5 and MathRandom() * 0.05 or -MathRandom() * 0.05) * n16, (MathRandom() > 0.5 and MathRandom() * 0.1 or -MathRandom() * 0.1) * n16, (MathRandom() > 0.5 and MathRandom() * 0.05 or -MathRandom() * 0.05) * n16)
						local n17 = (fn10(v42, range) - v42).Unit + v46
						local n18 = v42 + n17 * range
						local position = nil
						local instance = nil
						local hit = nil

						if i == 1 then
							position, instance, hit = ShowPellet(character, handle, v42, n18, range)
						end

						if not position then
							local n19 = n17 * range
							hit = Workspace:Raycast(v42, n19, ShootRayParams)
							position = hit and hit.Position or v42 + n19
							instance = hit and hit.Instance or nil
							hit = hit and hit.Normal or Vector3New(0, 1, 0)
						end

						local v47, v48, v49 = ApplyDamageModifierHit(arg.Name, position, instance, hit)
						ReplicatedStorage.MainEvent:FireServer("ShootGun", handle, v42, v47, v48, v49, serverTimeNow)
					end
				else
					local v46 = fn10(v42, range)
					local n16 = v42 + (v46 - v42).Unit * range
					local v47 = nil
					local v48 = nil
					local v49 = nil

					if i == 1 then
						v47, v48, v49 = ShowPellet(character, handle, v42, n16, range)
					end

					if not v47 then
						local n17 = (v46 - v42).Unit * range
						local hit = Workspace:Raycast(v42, n17, ShootRayParams)
						local position = hit and hit.Position or v42 + n17
						local instance = hit and hit.Instance or nil
						hit = hit and hit.Normal

						if hit then
							v47 = position
							v48 = instance
							v49 = hit
						else
							v47 = position
							v48 = instance
							v49 = Vector3New(0, 1, 0)
						end
					end

					local v50, v51, v52 = ApplyDamageModifierHit(arg.Name, v47, v48, v49)
					ReplicatedStorage.MainEvent:FireServer("ShootGun", handle, v42, v50, v51, v52)
				end
			end

			remoteEvent:FireServer()
		end

		CachedMainEvent = nil
		HookedTools = {}

		HookGunActivation = function(arg)
			local n11 = 678611859
			if not arg then
				return
			end

			arg.ChildAdded:Connect(function(child)
				local n12 = 240756739
				local n13 = 1702816030
				local v41 = bit32.bxor(n11, 2757824356)
				local n14 = 907615377
				if not child:IsA("Tool") then
					return
				end
				local v42 = MuzzleOffsets
				local name = child.Name
				local v43 = bit32.bxor(n12, 373159364)
				local v44 = table.pack(bit32.band(n14, 4294967295))
				local v45 = table.pack(bit32.band(v41, 4294967295))
				local v46 = table.pack(bit32.band(v44[1], 65535))
				local v47 = table.pack(bit32.rshift(v44[1], 16))
				local v48 = table.pack(bit32.band(v45[1], 65535))
				local v49 = bit32.band(v46[1] * v48[1] + bit32.lshift(bit32.band(v46[1] * bit32.rshift(v45[1], 16) + v47[1] * v48[1], 65535), 16), 4294967295)
				if not v42[name] then
					return
				end

				if HookedTools[child] then
					return
				end
				local v50 = HookedTools
				local v51 = table.pack(bit32.band(v43, 4294967295))
				local v52 = table.pack(bit32.band(v51[1], 65535))
				local n15 = bit32.band(19364 * v52[1] + bit32.lshift(bit32.band(19364 * bit32.rshift(v51[1], 16) + 7310 * v52[1], 65535), 16), 4294967295) + 1113052652
				local v53 = table.pack(bit32.band(bit32.bor(v43, 167763651), 4294967295))
				local v54 = table.pack(bit32.band(v53[1], 65535))
				local v55 = bit32.band(26808 * v54[1] + bit32.lshift(bit32.band(26808 * bit32.rshift(v53[1], 16) + 50915 * v54[1], 65535), 16), 4294967295)
				local v56 = table.pack(bit32.band(bit32.bxor(v43, 167763651), 4294967295))
				local v57 = table.pack(bit32.band(v56[1], 65535))
				local n16 = n15 + v55 + bit32.band(19365 * v57[1] + bit32.lshift(bit32.band(19365 * bit32.rshift(v56[1], 16) + 7310 * v57[1], 65535), 16), 4294967295)
				v50[child] = true
				local n17 = 0

				local function fn13()
					return fn5(child)
				end

				local flag2 = AutoWeapons[child.Name]

				if not flag2 then
					local v58 = bit32.bxor(v41, 1916037069)
					bit32.bxor(n13, 3371710776)
					bit32.bxor(v58, 1916037069)
					flag2 = false
				end

				local n18 = v49 + 1615816401
				local flag3 = BurstWeapons[child.Name] or false
				local v58 = n18

				child.Activated:Connect(function()
					local n19 = 1872017036
					local v59 = bit32.bxor(v58, 766694577)
					State.IsShooting = true
					local n20 = 4196148876 // v59
					local v60 = fn13()

					if flag2 then
						local n21 = Tick() - n17
						local n22 = 293204248
						local v61 = bit32.lshift(v59, 22)
						if n21 < v60 + 0.0095 then
							return
						end
						n17 = Tick()
						local flag4 = true
						local n23 = n22 + 507792738

						Spawn(function()
							local n24 = 2488579499

							while child.Parent == arg do
								EmulateGunFire(child)
								local v62 = Wait
								n24 = bit32.bxor(n24, 3244425429)
								v62(v60 + 0.0095)
								n17 = Tick()
							end
						end)

						local v62 = child
						bit32.bor(v61, 1421888299)
						v62.Deactivated:Wait()
						flag4 = false
						State.IsShooting = false
					else
						local v61, n21

						if flag3 then
							local n22 = n20 * v59

							if fn().Modifications["Delay Changer"].Enabled then
								if Tick() - n17 < v60 + 0.0095 then
									return
								end
								n17 = Tick()
								local flag4 = true
								v61 = bit32.bxor(v59, n22)

								Spawn(function()
									local n23 = 3828182541
									local n24 = 682905173

									while true do
										local flag5 = child.Parent == arg
										n24 = bit32.bxor(n24, 3451248595)

										if flag5 then
											EmulateGunFire(child)
											n23 = bit32.bxor(n23, 1342429186)
											Wait(v60 + 0.0095)
											n17 = Tick()
										else
											break
										end
									end
								end)

								local v62 = table.pack(bit32.band(n22, 4294967295))
								local v63 = table.pack(bit32.band(v61, 4294967295))
								local v64 = table.pack(bit32.band(v62[1], 65535))
								local v65 = table.pack(bit32.rshift(v62[1], 16))
								local v66 = table.pack(bit32.band(v63[1], 65535))
								n21 = bit32.band(v64[1] * v66[1] + bit32.lshift(bit32.band(v64[1] * bit32.rshift(v63[1], 16) + v65[1] * v66[1], 65535), 16), 4294967295)
								child.Deactivated:Wait()
								flag4 = false
								State.IsShooting = false
							else
								local n23 = 0.3
								local n24 = 394050823

								Pcall(function()
									local n25 = 2684204889
									local n26 = 721405422
									local toleranceCooldown = child:FindFirstChild("ToleranceCooldown")

									if toleranceCooldown then
										n23 = toleranceCooldown.Value
										local v62 = table.pack(bit32.band(n26, 4294967295))
										local v63 = table.pack(bit32.band(n25, 4294967295))
										local v64 = table.pack(bit32.band(v62[1], 65535))
										local v65 = table.pack(bit32.rshift(v62[1], 16))
										local v66 = table.pack(bit32.band(v63[1], 65535))
										local n27 = bit32.band(v64[1] * v66[1] + bit32.lshift(bit32.band(v64[1] * bit32.rshift(v63[1], 16) + v65[1] * v66[1], 65535), 16), 4294967295) + 4083209264
									end
								end)

								local v62 = Tick
								v61 = bit32.bxor(v59, n22)
								if v62() - n17 < n23 then
									return
								end
								n17 = Tick()
								local v63 = bit32.bor(n22, 1764670159)
								local n25 = 3

								Xpcall(function()
									local n26 = 1985409575
									local n27 = 2654785629
									local n28 = 1144282494
									local n29 = 842791193
									local ammo = child:FindFirstChild("Ammo")

									if ammo then
										local v64 = MathMin
										local v65 = n25
										local value = ammo.Value
										local v66 = bit32.bor(n29, n28)
										bit32.bxor(n27, 298545611)
										local v67 = v64(v65, value)
										bit32.bxor(n26, 3272476738)
										n25 = v67
										local v68 = bit32.bxor(v66, 1141113958)
									end
								end, ErrHandler)

								Spawn(function()
									local n26 = 2363802437

									for i = 1, n25 do
										EmulateGunFire(child)
										local v64 = Wait
										local v65 = v60
										n26 = bit32.bxor(n26, 3617473744)
										v64(v65 + 0.0095)
									end
								end)

								n21 = v63 + 3854195961
							end
						else
							local n22 = n20 // v59
							if Tick() - n17 < v60 + 0.0095 then
								return
							end
							n17 = Tick()
							EmulateGunFire(child)
							State.IsShooting = false
							local v62 = bit32.bxor(v59, 2531790206)
							bit32.bxor(n19, 900524036)
							v61 = bit32.bxor(v62, 2039124783)
							n21 = bit32.bxor(n22, 3576241112)
						end

						bit32.bxor(n21, 3576241105)
					end
				end)

				child.Deactivated:Connect(function()
					State.IsShooting = false
				end)
			end)
		end

		fn9 = function(arg, arg2)
			local n11 = 3341667588
			local n12 = 3983680307
			local n13 = 4245890167
			local n14 = 4088722465
			local fov = fn().Main.FOV
			local flag2 = arg2 == "Silent Aim"

			if flag2 then
				n14 = bit32.bxor(n14 // 252, 4081280864)
				flag2 = "Silent"
			end

			fov = fov and fov[flag2 or arg2]
			local n3D = fov and fov["3D"]
			local flag3 = not fov
			local n15 = 4245890167
			local flag4

			if flag3 then
				flag4 = flag3
			else
				local v41 = string
				bit32.bxor(n12, 580764379)
				local v42 = n14
				local lower = v41.lower
				bit32.bxor(n11, 224695864)
				flag4 = lower(tostring(fov.Options or "2D")) ~= "3d"
				n13 = v42 - 4137799594
			end

			if flag4 or not n3D then
				bit32.band(n14, 2336886966)
				return true
			end
			local currentCamera2 = Workspace.CurrentCamera
			local v41 = bit32.band(n13, n14)
			local v42 = fn7()
			local v43 = currentCamera2:ViewportPointToRay(v42.X, v42.Y)
			local v44 = (arg - v43.Origin):Dot(v43.Direction)
			local v45 = MathMax
			local n16 = tonumber(n3D.Depth) or 10
			local v46 = bit32.bor(n14, v41)
			local v47 = v45(n16, 0)
			if v44 <= 0 or v44 > v47 then
				return false
			end
			local n17 = v41 // 200
			local v48 = currentCamera2.CFrame:VectorToObjectSpace(arg - v43.Origin + v43.Direction * v44)
			local v49 = MathMax(tonumber(n3D.Width) or 6, 0)
			local v50 = MathMax
			local n18 = v46 - 3701833065
			local v51 = v50(tonumber(n3D.Height) or 6, 0)
			return MathAbs(v48.X) <= v49 / 2 and MathAbs(v48.Y) <= v51 / 2
		end

		GetClosestPlayerToCursor = function(arg, arg2, arg3, arg4)
			local n11 = 2805113018
			local currentCamera2 = Workspace.CurrentCamera
			local v41 = fn7()
			local position = currentCamera2.CFrame.Position
			local lookVector = currentCamera2.CFrame.LookVector
			local n12 = 3815680586
			local v42 = MathHuge
			local v43 = next
			local players, v44 = Players:GetPlayers()
			local v45 = nil

			for _, v46 in v43, players, v44 do
				if v46 ~= localPlayer then
					if PassesConditions(v46, arg3) then
						local character = v46.Character

						if character then
							local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

							if humanoidRootPart then
								if not (arg4 and not fn9(humanoidRootPart.Position, arg4)) then
									if arg and arg < MathHuge then
										if (position - humanoidRootPart.Position).Magnitude > arg then
											continue
										end
									end

									local v47, flag2 = currentCamera2:WorldToViewportPoint(humanoidRootPart.Position)

									if arg2 then
										local v48 = lookVector:Dot((humanoidRootPart.Position - position).Unit)
										n11 = bit32.bxor(n11, 1828255696)

										if not (v48 <= 0) then
											flag2 = flag2 and v47.Z > 0
											local magnitude

											if flag2 then
												magnitude = (Vector2New(v47.X, v47.Y) - v41).Magnitude
											else
												magnitude = (1 - v48) * 10000
											end

											n12 = bit32.bxor(n12, 610376850)

											if magnitude < v42 then
												v42 = magnitude
												v45 = v46
											end
										end
									elseif flag2 then
										if not (v47.Z <= 0) then
											local magnitude = (Vector2New(v47.X, v47.Y) - v41).Magnitude

											if magnitude < v42 then
												v42 = magnitude
												v45 = v46
											end
										end
									end
								end
							end
						end
					end
				end
			end

			return v45
		end

		ActivateTool = function()
			local n11 = 1554810770
			local n12 = 900621544
			local n13 = 1291172932
			local character = localPlayer.Character
			if not character then
				return
			end
			local tool = character:FindFirstChildOfClass("Tool")
			local flag2 = tool and tool:IsDescendantOf(character)

			if flag2 then
				local name = tool.Name
				bit32.bxor(n11, 321405865)
				bit32.bxor(n12, 2977236110)
				flag2 = name ~= "[Knife]"
			end

			if flag2 then
				tool:Activate()
			end
		end

		fn11 = nil

		TriggerShot = function(arg, arg2, arg3, arg4, arg5, arg6, arg7)
			local n11 = 2098234723
			local n12 = 3861879352
			local unixTimestampMillis = DateTime.now().UnixTimestampMillis
			local n13 = 5880435885

			if arg * 1000 <= unixTimestampMillis - State.LastTriggerShot then
				State.LastTriggerShot = unixTimestampMillis
				local n14 = arg6 - arg5
				local v41 = bit32.bxor(n12, 478252057)
				local magnitude = n14.Magnitude
				if magnitude <= 0 then
					return
				end
				local n15 = n14 / magnitude
				local modifications = fn().Modifications
				bit32.bxor(n13, 1465738635)
				local spreadModifications = modifications["Spread Modifications"]
				bit32.bxor(n11, 1657112390)
				local enabled = spreadModifications.Enabled
				local v42 = bit32.bxor(v41, n13)
				spreadModifications = enabled and spreadModifications or nil

				for i = 1, GetDoubleTapCount(arg4) do
					fn11(arg2, arg3, arg4, arg5, n15, arg7, spreadModifications)
				end
			end
		end

		RunTriggerbot = function()
			local n11 = 152751427
			local n12 = 4094123231
			local n13 = 3408587480
			local n14 = 137895626
			local triggerbot = fn().Triggerbot
			local n15 = 4294625279
			if not triggerbot.Enabled then
				return
			end
			local triggerState = State.TriggerState
			local n16 = bit32.bor(n13, 423953181)
			if not triggerState then
				return
			end
			local triggerbot2 = State.Targets.Triggerbot
			local character = triggerbot2 and triggerbot2.Character
			if not character then
				return
			end
			local character2 = localPlayer.Character
			if not character2 then
				return
			end
			local tool = character2:FindFirstChildOfClass("Tool")
			local flag2 = not tool

			if not flag2 then
				flag2 = not tool:FindFirstChild("Ammo")
				n16 = bit32.bxor(n16 + bit32.bxor(n14, 0), 952623482)
			end

			if flag2 or tool.Name == "[Knife]" then
				return
			end
			local flag3 = not State.CanTriggerbotShoot
			local n17 = bit32.rshift(n15, 8)
			if flag3 then
				return
			end
			local humanoid = character2:FindFirstChild("Humanoid")
			local flag4 = not humanoid
			local v41

			if flag4 then
				v41 = flag4
			else
				local v42 = table.pack(bit32.band(n17, 4294967295))
				local v43 = table.pack(bit32.band(n16, 4294967295))
				local v44 = table.pack(bit32.band(v42[1], 65535))
				local v45 = table.pack(bit32.rshift(v42[1], 16))
				local v46 = table.pack(bit32.band(v43[1], 65535))
				local flag5 = humanoid.Health <= 0
				n17 = bit32.band(v44[1] * v46[1] + bit32.lshift(bit32.band(v44[1] * bit32.rshift(v43[1], 16) + v45[1] * v46[1], 65535), 16), 4294967295) + 797364220
				v41 = flag5
			end

			if v41 then
				return
			end
			local bodyEffects = character2:FindFirstChild("BodyEffects")
			if not bodyEffects then
				return
			end
			local ko = bodyEffects:FindFirstChild("K.O")

			if ko then
				ko = bodyEffects["K.O"].Value
				n14 = n14 + 178398923 - 178398923
				n16 = bit32.bxor(bit32.bxor(n16, n17), 16775879)
			end

			if ko then
				return
			end
			local reload = bodyEffects:FindFirstChild("Reload")

			if reload then
				local reload2 = bodyEffects.Reload
				local v42 = bit32.bxor(n14, 0)
				reload = reload2.Value
				n14 = n14 + 469380436 - 469380436
				n17 = bit32.bxor(bit32.band(n17, v42), 13099013)
			end

			if reload then
				return
			end
			local dead = bodyEffects:FindFirstChild("Dead")

			if dead then
				dead = bodyEffects.Dead.Value
				n16 = n16 // 162 - 636147702
			end

			if dead then
				return
			end

			if not PassesConditions(triggerbot2, "Triggerbot") then
				return
			end
			local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")
			local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart or not humanoidRootPart2 then
				return
			end
			local position = humanoidRootPart.Position
			local n18 = n17 // bit32.bxor(n14, 0)
			local magnitude = (position - humanoidRootPart2.Position).Magnitude
			local maxRange = triggerbot["Max Range"] or MathHuge
			local n19 = n16 // bit32.bxor(n14, 0)
			if magnitude > maxRange then
				return
			end
			local handle = tool:FindFirstChild("Handle")
			if not handle then
				return
			end
			local name = tool.Name
			local range = tool:FindFirstChild("Range")
			local v42 = bit32.band(n19, 567193302)
			range = range and range.Value or 200

			if triggerbot["Limit To Weapon Range"] then
				local position2 = GetMuzzlePosition(tool) or humanoidRootPart.Position
				n18 = bit32.band(n18, 1286735348)
				if (position2 - humanoidRootPart2.Position).Magnitude > range then
					return
				end
			end

			local currentCamera2 = Workspace.CurrentCamera
			local y = currentCamera2.ViewportSize.Y
			local v43 = bit32.band(v42, 769879648)
			local fieldOfView = currentCamera2.FieldOfView
			local position2 = humanoidRootPart2.Position
			local prediction = triggerbot.Prediction

			if prediction and prediction.Enabled == true then
				local v44 = GetDeltaVelocity(humanoidRootPart2)
				local v45 = Vector3New
				local x = v44.X
				local n20 = n18 * 41970
				local n21 = x * (prediction.X or 0.13)
				local n22 = v44.Y * (prediction.Y or 0.13)
				local v46 = bit32.bxor(n14, 0)
				local v47 = bit32.bxor(v43, v46)
				local z = v44.Z
				local v48 = bit32.bxor(n14, 0)
				local v49 = bit32.bxor(n20, v48)
				position2 += v45(n21, n22, z * (prediction.Z or 0.13))
				n18 = bit32.bxor(v49, 137895626)
				v43 = bit32.bxor(v47, 137895626)
			end

			local offscreenTargeting = triggerbot["Offscreen Targeting"]
			offscreenTargeting = offscreenTargeting and offscreenTargeting.Enabled
			local v44, v45 = currentCamera2:WorldToViewportPoint(position2)
			local flag5 = not v45

			if flag5 then
				flag5 = not offscreenTargeting
				n18 = bit32.band(n18, v43)
			end

			if flag5 then
				return
			end
			local v46 = n14
			local n20 = v46 + 479378560
			if not fn9(position2, "Triggerbot") then
				return
			end
			local triggerMode = triggerbot["Trigger Mode"] or "FOV"
			local n21 = n18
			local triggerbot3 = fn().Main.FOV.Triggerbot
			local flag6

			if string.lower(tostring(triggerbot3.Options or "2D")) == "3d" then
				flag6 = true
			elseif offscreenTargeting then
				n18 //= 13
				flag6 = true
			else
				local n22 = n20 - 49469869
				local n23 = bit32.bxor(n21, 4294967295)

				if triggerMode == "Player" then
					local mouse2 = localPlayer:GetMouse()
					bit32.bxor(n11, v46)
					flag6 = mouse2.Target
					flag6 = flag6 and flag6:IsDescendantOf(character)
				else
					local mouseLocation = UserInputService:GetMouseLocation()
					local n24 = n18 + n23
					local n25 = Vector2New(v44.X, v44.Y) - mouseLocation
					local z = v44.Z
					bit32.bxor(n12, 0)
					if z <= 1 then
						return
					end
					local n26 = humanoidRootPart2.Size.Y * y / z * 2 * 80 / fieldOfView
					local width = triggerbot3.Width

					if width then
						local n27 = n23 // n24
						width = triggerbot3.Width[1] or 9e9
						n23 = n27 - 2
					end

					local n27 = (width or 9e9) * n26
					local height = triggerbot3.Height

					if height then
						local height2 = triggerbot3.Height
						n23 = bit32.bor(n23, n24)
						height = height2[1] or 9e9
					end

					local n28 = (height or 9e9) * n26
					local enabled = triggerbot3.Visualize.Enabled
					n18 = bit32.bxor(n24, 4294967295)
					flag6 = not enabled

					if not flag6 then
						n23 += n18
						flag6 = MathAbs(n25.X) <= n27 / 2 and MathAbs(n25.Y) <= n28 / 2
					end
				end

				n20 = n22 + 49469869
				n21 = n23 + 1
			end

			if flag6 then
				local v47 = n21
				local n22 = n20 - 216271137
				local position3 = GetMuzzlePosition(tool) or humanoidRootPart.Position
				local delay = triggerbot.Delay or 0
				local v48 = fn5(tool)
				TriggerShot(MathMax(delay, v48), tool, handle, name, position3, position2, range)
			end
		end

		local v41 = bit32.bxor(n10, 3467615805)
		SilentTargetLocked = false
		UtilityUI = Instance.new("ScreenGui")
		local v42 = UtilityUI
		local v43 = bit32.band(n9 * 11, v41)
		v42.Name = "ciderui"
		UtilityUI.IgnoreGuiInset = true
		local n11 = v41 - 3605009950
		UtilityUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		local v44 = UtilityUI
		local v45 = bit32.bxor(v43, n11)
		v44.Parent = CoreGui

		CreateSquare = function()
			local tbl11 = {
				_Size = Vector2New(0, 0),
				_Position = Vector2New(0, 0),
				_Color = Color3.new(1, 1, 1),
				_Visible = false,
				_Filled = false,
				_Thickness = 1,
				_Transparency = 1,
			}

			local frame = Instance.new("Frame")
			frame.BorderSizePixel = 0
			frame.BackgroundTransparency = 1
			frame.BackgroundColor3 = tbl11._Color
			frame.Visible = tbl11._Visible
			frame.Parent = UtilityUI
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Thickness = tbl11._Thickness
			uiStroke.Enabled = true
			uiStroke.LineJoinMode = Enum.LineJoinMode.Miter
			uiStroke.Parent = frame
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0, 0)
			uiCorner.Parent = frame
			local v46

			return setmetatable({}, {
				__newindex = function(arg, arg2, size)
					local n12 = 3071418622
					local n13 = 2233861838
					local n14 = bit32.bxor(v46, 219669318) // n13

					if arg2 == "Size" then
						tbl11._Size = size
						frame.Size = UDim2.fromOffset(size.X, size.Y)
					elseif arg2 == "Round" then
						tbl11._Round = size
						local v47 = uiCorner
						size = size and UDim.new(1, 0)

						if not size then
							bit32.bxor(bit32.bxor(n14, 3389721322), 3389721322)
							size = UDim.new(0, 0)
						end

						v47.CornerRadius = size
					else
						local v47 = bit32.bor(n13, n14)

						if arg2 == "Position" then
							tbl11._Position = size
							local v48 = frame
							local udim2 = UDim2.fromOffset
							local x = size.X
							local y = size.Y
							bit32.band(n14, v47)
							v48.Position = udim2(x, y)
						else
							local n15 = v47 + 15706718

							if arg2 == "Color" then
								tbl11._Color = size
								frame.BackgroundColor3 = size
								local v48 = uiStroke
								n15 = bit32.bor(n15, n14)
								v48.Color = size
							elseif arg2 == "Visible" then
								tbl11._Visible = size
								frame.Visible = size
							elseif arg2 == "Filled" then
								local v48 = tbl11
								local n16 = bit32.lshift(n14, 11)
								v48._Filled = size
								local v49 = frame
								local v50

								if size then
									local v51 = MathClamp
									local n17 = 1 - tbl11._Transparency
									n16 = bit32.bor(n16, n15) + 2045398740
									v50 = v51(n17, 0, 1)
								else
									v50 = size
								end

								v49.BackgroundTransparency = v50 or 1
								uiStroke.Enabled = not size
								n15 = bit32.bxor(n15 * n16, 2249568556)
							elseif arg2 == "Thickness" then
								tbl11._Thickness = size
								local v48 = uiStroke
								bit32.bxor(n12, 3493847923)
								v48.Thickness = MathClamp(size, 0.6, 2147483647)
							else
								local v48 = bit32.bor(n14, n15)

								if arg2 == "Transparency" then
									tbl11._Transparency = size
									local v49 = MathClamp(1 - size, 0, 1)
									local v50 = frame
									local n16 = n15 // 59 - 3406898958
									v50.BackgroundTransparency = tbl11._Filled and v49 or 1
									uiStroke.Transparency = v49
									n15 = n16 - 2971595358
								end
							end

							bit32.bxor(n15, 53721058)
						end
					end
				end,
				__index = function(arg, arg2)
					local v47 = bit32.bxor(v46, 489825532)
					local n12 = 3615335445

					if arg2 == "Remove" or arg2 == "Destroy" then
						local n13 = 499704288

						return function()
							frame:Destroy()
						end
					end

					if arg2 == "Size" then
						return tbl11._Size
					end

					if arg2 == "Round" then
						return tbl11._Round
					end

					if arg2 == "Position" then
						return tbl11._Position
					end

					if arg2 == "Color" then
						local color = tbl11._Color
						local v48 = table.pack(bit32.band(n12, 4294967295))
						local v49 = table.pack(bit32.band(v47, 4294967295))
						local v50 = table.pack(bit32.band(v48[1], 65535))
						local v51 = table.pack(bit32.rshift(v48[1], 16))
						local v52 = table.pack(bit32.band(v49[1], 65535))
						bit32.band(v50[1] * v52[1] + bit32.lshift(bit32.band(v50[1] * bit32.rshift(v49[1], 16) + v51[1] * v52[1], 65535), 16), 4294967295)
						return color
					end

					if arg2 == "Visible" then
						return tbl11._Visible
					end

					if arg2 == "Filled" then
						return tbl11._Filled
					end

					if arg2 == "Thickness" then
						return tbl11._Thickness
					end

					if arg2 == "Transparency" then
						return tbl11._Transparency
					end
					return nil
				end,
			})
		end

		CreateLine = function()
			local tbl11 = {
				_From = Vector2New(0, 0),
				_To = Vector2New(0, 0),
				_Color = Color3.new(1, 1, 1),
				_Visible = false,
				_Thickness = 1,
				_Transparency = 1,
			}

			local frame = Instance.new("Frame")
			frame.AnchorPoint = Vector2New(0.5, 0.5)
			local n12 = 13208167998
			frame.BorderSizePixel = 0
			frame.BackgroundColor3 = tbl11._Color
			frame.Visible = tbl11._Visible
			frame.BackgroundTransparency = 0
			frame.Size = UDim2.new()
			frame.Parent = UtilityUI

			local function fn13()
				local n13 = tbl11._To - tbl11._From
				local n14 = (tbl11._To + tbl11._From) / 2
				local magnitude = n13.Magnitude
				local v46 = MathDeg(MathAtan2(n13.Y, n13.X))
				frame.Position = UDim2.fromOffset(n14.X, n14.Y)
				frame.Rotation = v46
				frame.Size = UDim2.fromOffset(magnitude, tbl11._Thickness)
			end

			return setmetatable({}, {
				__newindex = function(arg, arg2, from)
					local n13 = 509490558
					local n14 = 981420348
					local n15 = 2419291795

					if arg2 == "From" then
						tbl11._From = from
						fn13()
						bit32.bxor(n15 + n14, 1518455132)
					elseif arg2 == "To" then
						tbl11._To = from
						local v46 = fn13
						local v47 = bit32.bxor(n14, n15)
						v46()
					elseif arg2 == "Color" then
						tbl11._Color = from
						frame.BackgroundColor3 = from
					elseif arg2 == "Visible" then
						local v46 = tbl11
						local v47 = bit32.bor(n14, n15)
						v46._Visible = from
						frame.Visible = from
						bit32.bxor(v47, 2147497603)
					else
						bit32.bxor(n13, 2092905271)
						local n16 = bit32.bxor(n15, 4294967295)

						if arg2 == "Thickness" then
							tbl11._Thickness = from
							fn13()
						elseif arg2 == "Transparency" then
							local v46 = n16
							tbl11._Transparency = from
							frame.BackgroundTransparency = MathClamp(1 - from, 0, 1)
							n16 = n16 // v46 - 2419291797
						end
					end
				end,
				__index = function(arg, arg2)
					local n13 = 3897393218
					local v46 = bit32.bxor(nil, 3821869371)
					local n14 = 1301379904
					local flag2 = arg2 == "Remove"

					if not flag2 then
						bit32.bxor(n13, 3993059904)
						flag2 = arg2 == "Destroy"
						v46 = bit32.bxor(v46 // n14, 3808931069)
					end

					if flag2 then
						local flag3 = bit32.bxor(bit32.bxor(nil, 0), 253688716) ~= 265571912
						local n15 = 9114742925

						return function()
							frame:Destroy()
						end
					end

					if arg2 == "From" then
						return tbl11._From
					end

					if arg2 == "To" then
						bit32.bor(n14, 2692350170)
						return tbl11._To
					end

					if arg2 == "Color" then
						local color = tbl11._Color
						bit32.bor(n14, 2561541848)
						return color
					end

					if arg2 == "Visible" then
						return tbl11._Visible
					end

					if arg2 == "Thickness" then
						local thickness = tbl11._Thickness
						local v47 = table.pack(bit32.band(v46, 4294967295))
						local v48 = table.pack(bit32.band(n14, 4294967295))
						local v49 = table.pack(bit32.band(v47[1], 65535))
						local v50 = table.pack(bit32.rshift(v47[1], 16))
						local v51 = table.pack(bit32.band(v48[1], 65535))
						bit32.band(v49[1] * v51[1] + bit32.lshift(bit32.band(v49[1] * bit32.rshift(v48[1], 16) + v50[1] * v51[1], 65535), 16), 4294967295)
						return thickness
					end

					if arg2 == "Transparency" then
						return tbl11._Transparency
					end
					return nil
				end,
			})
		end

		SilentFOVBox = CreateSquare()
		SilentFOVBox.Visible = false
		local v46 = SilentFOVBox
		v34 = bit32.bxor(v32, 307003867)
		local n12 = n11 // 3
		local v47 = bit32.bxor(v34, 0)
		local v48 = bit32.band(v45, v47)
		v46.Filled = false
		SilentFOVBox.Thickness = 1
		SilentFOVBox.Transparency = 1
		local v49 = CreateSquare
		v35 = bit32.bor(v48, n12)
		TriggerFOVBox = v49()
		TriggerFOVBox.Visible = false
		local v50 = TriggerFOVBox
		local v51 = table.pack(bit32.band(n12, 4294967295))
		local v52 = table.pack(bit32.band(v51[1], 65535))
		local v53 = bit32.band(v52[1] * 59179 + bit32.lshift(bit32.band(v52[1] * 0 + bit32.rshift(v51[1], 16) * 59179, 65535), 16), 4294967295)
		v50.Filled = false
		TriggerFOVBox.Thickness = 1
		TriggerFOVBox.Transparency = 1
		local v54 = CreateSquare
		local v55 = bit32.bxor(v34, 0)
		local v56 = table.pack(bit32.band(v53, 4294967295))
		local v57 = table.pack(bit32.band(v55, 4294967295))
		local v58 = table.pack(bit32.band(v56[1], 65535))
		local v59 = table.pack(bit32.rshift(v56[1], 16))
		local v60 = table.pack(bit32.band(v57[1], 65535))
		local v61 = bit32.band(v58[1] * v60[1] + bit32.lshift(bit32.band(v58[1] * bit32.rshift(v57[1], 16) + v59[1] * v60[1], 65535), 16), 4294967295)
		AimbotFOVBox = v54()
		AimbotFOVBox.Visible = false
		AimbotFOVBox.Filled = false
		AimbotFOVBox.Thickness = 1
		local v62 = AimbotFOVBox
		local v63 = bit32.bxor(v35, 4294967295)
		v62.Transparency = 1

		local function fn13(arg)
			local v64 = bit32.bxor(arg, 0)
			local v65 = bit32.bxor(arg, 0)
			bit32.bxor(v64, 3123631908)
			local tbl11 = {}

			for i = 1, 12 do
				local v66 = CreateLine()
				v66.Visible = false
				v66.Thickness = 1
				v66.Transparency = 1
				tbl11[#tbl11 + 1] = v66
				v65 = bit32.bxor(v65, arg)
			end

			return tbl11
		end

		local function fn14(arg)
			local n13 = 574431325

			for _, v64 in next, arg, nil do
				n13 = bit32.bxor(n13, 1384492170)
				v64.Visible = false
			end
		end

		local v64 = table.pack(bit32.band(v61, 4294967295))
		local v65 = table.pack(bit32.band(v63, 4294967295))
		local v66 = table.pack(bit32.band(v64[1], 65535))
		local v67 = table.pack(bit32.rshift(v64[1], 16))
		local v68 = table.pack(bit32.band(v65[1], 65535))
		v36 = bit32.band(v66[1] * v68[1] + bit32.lshift(bit32.band(v66[1] * bit32.rshift(v65[1], 16) + v67[1] * v68[1], 65535), 16), 4294967295)

		fn12 = function(arg, arg2, color)
			local n13 = 1810375427
			local n14 = 205663179
			local n15 = 820088436
			local n3D = arg2 and arg2["3D"]
			local flag2 = not arg2
			local n16 = 205663179
			local flag3

			if flag2 then
				flag3 = flag2
			else
				flag3 = not arg2.Visualize.Enabled
				n14 = n14 // 194 - 4090364236
			end

			if not flag3 then
				flag3 = string.lower(tostring(arg2.Options or "2D")) ~= "3d"
				n15 = bit32.bxor(bit32.bor(n15, n14), 201466251)
			end

			if flag3 or not n3D then
				fn14(arg)
				return
			end
			local currentCamera2 = Workspace.CurrentCamera
			local n17 = n14 * 16
			local v69 = fn7()
			local v70 = currentCamera2:ViewportPointToRay(v69.X, v69.Y)
			local rightVector = currentCamera2.CFrame.RightVector
			local upVector = currentCamera2.CFrame.UpVector
			local v71 = MathMax
			local v72 = n15
			local v73 = v71(tonumber(n3D.Width) or 6, 0)
			local v74 = MathMax
			local n18 = n17 - 1648704606
			local v75 = v74(tonumber(n3D.Height) or 6, 0)
			local v76 = n18
			local v77 = MathMax(tonumber(n3D.Depth) or 10, 0)
			local v78 = MathMin
			bit32.bxor(v72, 2603780497)
			local v79 = MathMax(v73, v75, 1)
			local v80 = bit32.rshift(v76, 10)
			local n19 = n18 - 2755898581
			local n20 = v70.Origin + v70.Direction * v77
			local tbl11 = {}

			for _, v81 in ipairs({ v70.Origin + v70.Direction * v78(v79, v77), n20 }) do
				local n21 = rightVector * v73 / 2
				local n22 = upVector * v75 / 2
				tbl11[#tbl11 + 1] = v81 - n21 - n22
				tbl11[#tbl11 + 1] = v81 + n21 - n22
				tbl11[#tbl11 + 1] = v81 + n21 + n22
				tbl11[#tbl11 + 1] = v81 - n21 + n22
			end

			local tbl12 = {}
			local n21 = n19 - v80

			for i, v81 in ipairs(tbl11) do
				local v82, v83 = currentCamera2:WorldToViewportPoint(v81)
				if not v83 or v82.Z <= 0 then
					fn14(arg)
					return
				end
				tbl12[i] = Vector2New(v82.X, v82.Y)
			end

			local tbl13 = {}
			local tbl14 = {}
			local n22 = bit32.bxor(v80, 3187345353) - n21
			bit32.bxor(n13, 2557457098)
			tbl14[1] = 6
			tbl14[2] = 7
			local v81 = n22
			local tbl15 = {}
			bit32.bor(n22, v81)
			tbl15[1] = 3
			tbl15[2] = 7
			tbl13[1] = { 1, 2 }
			tbl13[2] = { 2, 3 }
			tbl13[3] = { 3, 4 }
			tbl13[4] = { 4, 1 }
			tbl13[5] = { 5, 6 }
			tbl13[6] = tbl14
			tbl13[7] = { 7, 8 }
			tbl13[8] = { 8, 5 }
			tbl13[9] = { 1, 5 }
			tbl13[10] = { 2, 6 }
			tbl13[11] = tbl15
			tbl13[12] = { 4, 8 }

			for i, v82 in ipairs(tbl13) do
				local v83 = arg[i]
				v83.From = tbl12[v82[1]]
				v83.To = tbl12[v82[2]]
				v83.Color = color
				v83.Visible = true
			end
		end

		Silent3DFOVBox = fn13(480011069, 246964350)
		Trigger3DFOVBox = fn13(480011069, 426037971)
		local v69 = fn13(480011069, 510821440)
		local v70 = bit32.lshift(v63, 8)
		Aimbot3DFOVBox = v69
		local color = Color3.fromRGB
		v37 = bit32.bxor(v34, 358765031)
		SilentFOVOutColor = color(255, 255, 255)
		local v71 = Color3
		local v72 = bit32.bxor(v37, 0)
		local v73 = bit32.bxor(v70, v72)
		SilentFOVInColor = v71.fromRGB(100, 180, 255)
		local color2 = Color3.fromRGB
		local v74 = bit32.lshift(v36, 4)
		TriggerFOVOutColor = color2(255, 255, 255)
		local color3 = Color3.fromRGB
		local v75 = bit32.bxor(v73, 3646733907)
		TriggerFOVInColor = color3(100, 180, 255)
		AimbotFOVOutColor = Color3.fromRGB(255, 255, 255)
		AimbotFOVInColor = Color3.fromRGB(100, 180, 255)
		SilentTargetLine = CreateLine()
		local v76 = SilentTargetLine
		v38 = bit32.band(v74 + v75, 715422876)
		v76.Visible = false
		SilentTargetLine.Thickness = 0.5
		SilentTargetLine.Transparency = 1
		SilentTargetLine.Parent = DrawingGui
		local v77 = CreateLine
		local v78 = bit32.bxor(v37, 0)
		local v79 = table.pack(bit32.band(v75 - v38, 4294967295))
		local v80 = table.pack(bit32.band(v78, 4294967295))
		local v81 = table.pack(bit32.band(v79[1], 65535))
		local v82 = table.pack(bit32.rshift(v79[1], 16))
		local v83 = table.pack(bit32.band(v80[1], 65535))
		local v84 = bit32.band(v81[1] * v83[1] + bit32.lshift(bit32.band(v81[1] * bit32.rshift(v80[1], 16) + v82[1] * v83[1], 65535), 16), 4294967295)
		OffscreenSilentLine = v77()
		OffscreenSilentLine.Visible = false
		local v85 = OffscreenSilentLine
		local v86 = bit32.bor(v38, 632933871)
		v85.Thickness = 0.5
		OffscreenSilentLine.Transparency = 1

		CreateTextLabel = function()
			local tbl11 = {
				_Text = "",
				_Size = 13,
				_Position = Vector2New(0, 0),
				_Color = Color3.new(1, 1, 1),
				_Visible = false,
				_Center = false,
				_Outline = true,
				_OutlineColor = Color3.new(0, 0, 0),
				_Transparency = 1,
				_FontFace = nil,
			}

			local textLabel = Instance.new("TextLabel")
			textLabel.AnchorPoint = Vector2New(0.5, 0.5)
			textLabel.BorderSizePixel = 0
			textLabel.BackgroundTransparency = 1
			textLabel.RichText = true
			textLabel.Font = Enum.Font.SourceSansBold
			textLabel.TextSize = tbl11._Size
			local n13 = 210353714
			textLabel.TextColor3 = tbl11._Color
			textLabel.Visible = tbl11._Visible
			textLabel.Text = ""
			textLabel.Parent = UtilityUI
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Thickness = 1
			uiStroke.Color = tbl11._OutlineColor
			uiStroke.Enabled = tbl11._Outline
			uiStroke.Parent = textLabel

			local function fn15()
				local n14 = 237239628
				local n15 = 1343989391
				local textBounds = textLabel.TextBounds
				local n16 = 4743588255
				local n17 = tbl11._Center and 0
				local n18 = 1343989391
				local n19

				if n17 then
					n19 = n17
				else
					n19 = textBounds.X / 2
					local v87 = bit32.bor(n15, n16)
					bit32.bxor(n14, 2120100706)
					n15 = bit32.bxor(v87, 178538768)
				end

				local v87 = textLabel
				local udim2 = UDim2.fromOffset
				local position = tbl11._Position
				local v88 = table.pack(bit32.band(n16, 4294967295))
				local v89 = table.pack(bit32.band(n15, 4294967295))
				local v90 = table.pack(bit32.band(v88[1], 65535))
				local v91 = table.pack(bit32.rshift(v88[1], 16))
				local v92 = table.pack(bit32.band(v89[1], 65535))
				bit32.band(v90[1] * v92[1] + bit32.lshift(bit32.band(v90[1] * bit32.rshift(v89[1], 16) + v91[1] * v92[1], 65535), 16), 4294967295)
				v87.Position = udim2(position.X + n19, tbl11._Position.Y + textBounds.Y / 2)
			end

			textLabel:GetPropertyChangedSignal("TextBounds"):Connect(fn15)
			local n14 = 2273054804

			local tbl12 = { __newindex = function(arg, arg2, text)
				local n15 = 1902858775
				local n16 = 2526780633
				local v87 = bit32.bxor(n14, 2119665058)
				local n17 = 3675985295

				if arg2 == "Text" then
					tbl11._Text = text
					local v88 = bit32.bxor(n17, 530871206)
					textLabel.Text = text
					bit32.bxor(v88, 530871206)
				elseif arg2 == "Size" then
					tbl11._Size = text
					textLabel.TextSize = text
				else
					local n18 = bit32.lshift(v87, 16)

					if arg2 == "Position" then
						tbl11._Position = text
						fn15()
					elseif arg2 == "Color" then
						tbl11._Color = text
						local v88 = textLabel
						local v89 = bit32.rshift(n18, 13)
						v88.TextColor3 = text
						n18 = v89 - 1779347376
					elseif arg2 == "Visible" then
						tbl11._Visible = text
						textLabel.Visible = text
					elseif arg2 == "Center" then
						tbl11._Center = text
						fn15()
						n18 = bit32.bxor(n18 - 3687409592, 802854984)
					elseif arg2 == "Outline" then
						tbl11._Outline = text
						uiStroke.Enabled = text
					elseif arg2 == "OutlineColor" then
						local v88 = tbl11
						local v89 = bit32.bor(n17, 2477495724)
						v88._OutlineColor = text
						local v90 = uiStroke
						bit32.bxor(n15, 1671250121)
						v90.Color = text
					elseif arg2 == "Transparency" then
						tbl11._Transparency = text
						local v88 = MathClamp(1 - text, 0, 1)
						local v89 = textLabel
						local v90 = bit32.lshift(n18, 29)
						v89.TextTransparency = v88
						uiStroke.Transparency = v88
						n18 = v90 - 1779040256
					elseif arg2 == "Font" then
						local v88 = textLabel
						local v89 = bit32.bor(n18, 21018665)
						v88.Font = text
						n18 = bit32.bxor(v89, 47145)
					elseif arg2 == "FontFace" then
						tbl11._FontFace = text
						local v88 = textLabel
						bit32.bxor(n16, 4094496918)
						local v89 = bit32.bxor(n17, 1268030283)
						v88.FontFace = text
						bit32.bxor(v89, 1268030283)
					elseif arg2 == "StrokeThickness" then
						uiStroke.Thickness = text
					elseif arg2 == "StrokeTransparency" then
						local v88 = uiStroke
						local v89 = bit32.band(n18, n17)
						v88.Transparency = text
						n18 = v89 - 4212916224
					end
				end
			end }

			local v87 = table.pack(4180)
			bit32.band(v87[1] * 19958 + bit32.lshift(bit32.band(v87[1] * 0 + 692223272, 65535), 16), 4294967295)

			tbl12.__index = function(arg, arg2)
				local n15 = 2161066942
				local n16 = 1958927254
				if arg2 == "TextBounds" then
					return textLabel.TextBounds
				end

				if arg2 == "Label" then
					return textLabel
				end

				if arg2 == "Stroke" then
					return uiStroke
				end
				local flag2 = arg2 == "Remove"

				if flag2 or arg2 == "Destroy" then
					local n17 = 9045209707

					return function()
						textLabel:Destroy()
					end
				end

				if arg2 == "Text" then
					return tbl11._Text
				end

				if arg2 == "Size" then
					return tbl11._Size
				end
				local v88 = n16
				if arg2 == "Position" then
					return tbl11._Position
				end

				if arg2 == "Color" then
					return tbl11._Color
				end

				if arg2 == "FontFace" then
					return tbl11._FontFace
				end
				local n17 = n16 // 69
				if arg2 == "Visible" then
					return tbl11._Visible
				end

				if arg2 == "Center" then
					return tbl11._Center
				end
				local n18 = v88 - n17
				if arg2 == "Outline" then
					return tbl11._Outline
				end

				if arg2 == "Transparency" then
					local transparency = tbl11._Transparency
					bit32.bxor(n18, 2254211992)
					return transparency
				end

				return nil
			end

			return setmetatable({}, tbl12)
		end

		NameESPDrawings = {}
		HealthBarDrawings = {}
		HealthBarValueCache = {}

		local function fn15(arg)
			local n13 = 3143793784
			local n14 = 3246066700
			local n15 = 535299587
			local n16 = 1792845354
			local character

			if arg then
				local v87 = table.pack(bit32.band(n16, 4294967295))
				local v88 = table.pack(bit32.band(v87[1], 65535))
				character = arg.Character
				n16 = bit32.bxor(bit32.band(v88[1] * 13517 + bit32.lshift(bit32.band(v88[1] * 0 + bit32.rshift(v87[1], 16) * 13517, 65535), 16), 4294967295), 246231432)
			else
				character = arg
			end

			character = character and character:FindFirstChild("BodyEffects")

			if character then
				local armor = character:FindFirstChild("Armor")

				if not armor then
					armor = character:FindFirstChild("Armour")
					bit32.bxor(n13, 38741635)
				end

				character = armor or character:FindFirstChild("Defense")
			end

			if character and tonumber(character.Value) then
				return tonumber(character.Value), true
			end
			arg = arg and arg:FindFirstChild("leaderstats")
			local armor = arg and (arg:FindFirstChild("Armor") or arg:FindFirstChild("Armour") or arg:FindFirstChild("Defense") or arg:FindFirstChild("Vest"))
			local v87

			if armor then
				local v88 = tonumber
				bit32.bxor(n15, 644165145)
				local v89 = n16
				v87 = v88(armor.Value)
			else
				v87 = armor
			end

			if v87 then
				local v88 = tonumber
				local value = armor.Value
				bit32.bxor(n14, 68045090)
				return v88(value), true
			end

			return 0, false
		end

		v39 = bit32.bxor(v84, 1913818931)
		GetHealthBarArmor = fn15

		GetStableHealthBarValues = function(arg, arg2)
			local n13 = 1319728744
			local n14 = 272668530
			local n15 = 204782473
			local v87 = Clock()
			local tbl11 = HealthBarValueCache[arg]
			local n16 = 1230615736
			local flag2 = not tbl11

			if not flag2 then
				flag2 = tbl11.Character ~= arg.Character
				bit32.bxor(n14, 3409848174)
			end

			if flag2 then
				local n17 = n15 + n16
				tbl11 = { Character = arg.Character, Health = tonumber(arg2.Health) or 0 }
				local v88 = bit32.bor(n17, n16)
				tbl11.MaxHealth = tonumber(arg2.MaxHealth) or 100
				tbl11.Armor = 0
				tbl11.ZeroSince = nil
				tbl11.ArmorMissingSince = nil
				HealthBarValueCache[arg] = tbl11
				n16 = bit32.bxor(n16 // v88, 1230615736)
				n15 = v88 + 2924791440
			end

			local v88 = tonumber
			local maxHealth = arg2.MaxHealth
			local v89 = bit32.band(n16, n15)
			local v90 = v88(maxHealth)

			if v90 and v90 > 0 and v90 == v90 then
				tbl11.MaxHealth = v90
			end

			local flag3 = tbl11.MaxHealth > 0

			if flag3 then
				bit32.bxor(n13, 3175830501)
				flag3 = tbl11.MaxHealth
			end

			flag3 = flag3 or 100
			local num = tonumber(arg2.Health)
			local v91 = EnumDead
			local flag4 = arg2:GetState() == v91 or not arg2.Parent

			if num and num == num and num > 0 then
				tbl11.Health = MathClamp(num, 0, flag3)
				tbl11.ZeroSince = nil
				n15 = n15 // v89 + 204782472
			elseif flag4 then
				local v92 = bit32.lshift(n15, 28)
				tbl11.Health = 0
				tbl11.ZeroSince = v87
				n15 = v92 - 2211136631
			else
				tbl11.ZeroSince = nil
			end

			local v92, v93 = GetHealthBarArmor(arg)

			if v93 then
				local v94 = MathMax
				local num2 = tonumber(v92)
				local n17

				if num2 then
					n17 = num2
				else
					v89 = bit32.bxor(bit32.bxor(v89, n15), 204782473)
					n17 = 0
				end

				tbl11.Armor = v94(n17, 0)
				tbl11.ArmorMissingSince = nil
			else
				tbl11.ArmorMissingSince = tbl11.ArmorMissingSince or v87

				if v87 - tbl11.ArmorMissingSince >= 0.3 then
					tbl11.Armor = 0
				end
			end

			local health = tbl11.Health
			local armor = tbl11.Armor
			bit32.band(v89, 264131729)
			return health, flag3, armor, flag4
		end

		RemoveHealthBarSet = function(arg)
			local n13 = 1574140702
			if not arg then
				return
			end

			for _, v87 in next, arg, nil do
				local n14 = 52136093

				pcall(function()
					v87:Remove()
				end)
			end
		end

		local v87 = bit32.bor(v86, 147034272)

		HideHealthBarSet = function(arg)
			local n13 = 3362053943
			local n14 = 163514073
			if not arg then
				return
			end
			local v88 = next
			bit32.bxor(n13, n14)

			for _, v89 in v88, arg, nil do
				v89.Visible = false
			end
		end

		Cleanup = function()
			local n13 = 1392775103
			local n14 = 4291476786
			fn3(State)
			local n15 = 3466199903 - n14

			for i = #_Conns, 1, -1 do
				local v88 = _Conns[i]
				_Conns[i] = nil

				if v88 and v88.Connected then
					local n16 = 8921891990

					pcall(function()
						v88:Disconnect()
					end)
				end
			end

			local v88 = pcall
			bit32.bxor(n13, 2878243172)

			local function fn16()
				RunService:UnbindFromRenderStep("ciderrage")
			end

			local v89 = bit32.bxor(n14, 1060352401)
			v88(fn16)

			if UtilityUI.Parent then
				pcall(function()
					UtilityUI:Destroy()
				end)
			end

			local v90 = n15

			for _, v91 in next, NameESPDrawings, nil do
				local n16 = 460523759

				pcall(function()
					v91:Remove()
				end)
			end

			for k in next, NameESPDrawings, nil do
				NameESPDrawings[k] = nil
			end

			for _, v91 in next, HealthBarDrawings, nil do
				RemoveHealthBarSet(v91)
			end

			for k in next, HealthBarDrawings, nil do
				HealthBarDrawings[k] = nil
			end

			for k in next, HealthBarValueCache, nil do
				HealthBarValueCache[k] = nil
			end
		end

		local v88 = Cleanup
		getgenv().cidercc_cleanup = v88

		CleanNameESP = function()
			local n13 = 3673480308
			local n14 = 1793852028
			local n15 = 1564645954

			for k, v89 in next, NameESPDrawings, nil do
				if not k.Parent then
					v89:Remove()
					NameESPDrawings[k] = nil
				end
			end

			local v89 = next
			bit32.band(n14, n15)

			for k, v90 in v89, HealthBarDrawings, nil do
				local flag2 = not k.Parent
				n13 = bit32.bxor(n13, 732408507)

				if flag2 then
					RemoveHealthBarSet(v90)
					HealthBarDrawings[k] = nil
					HealthBarValueCache[k] = nil
				end
			end
		end

		local v89 = TrackConn
		local playerRemoving = Players.PlayerRemoving
		v40 = bit32.bxor(v87, v39)

		v89(playerRemoving:Connect(function(arg)
			local n13 = 2396517750
			local n14 = 3402545231
			local n15 = 2278030277

			if State.Future.LastTarget == arg then
				local v90 = State
				local v91 = bit32.band(n15, 4093940698)
				v90.Future.LastTarget = nil
				State.Future.LastWeaponClass = nil
				local n16 = n14 // v91
				local future = State.Future
				bit32.bxor(n13, 3713207995)
				future.CurrentValues = nil
				n15 = v91 + 63137797
				n14 = n16 + 3402545230
			end

			local v90 = NameESPDrawings[arg]

			if v90 then
				v90:Remove()
				local v91 = bit32.rshift(n15, 8)
				NameESPDrawings[arg] = nil
				n15 = v91 - 2025835574
			end

			local v91 = HealthBarDrawings[arg]

			if v91 then
				RemoveHealthBarSet(v91)
				HealthBarDrawings[arg] = nil
			end

			HealthBarValueCache[arg] = nil
		end))
	end

	PanelTitle = CreateTextLabel()
	PanelTitle.Visible = false
	PanelTitle.Size = 18
	PanelTitle.Outline = true
	PanelTitle.Center = true
	local v41 = table.pack(bit32.band(v39 + 2560278498, 4294967295))
	local v42 = table.pack(bit32.band(v40, 4294967295))
	local v43 = table.pack(bit32.band(v41[1], 65535))
	local v44 = table.pack(bit32.rshift(v41[1], 16))
	local v45 = table.pack(bit32.band(v42[1], 65535))
	local v46, v47

	do
		local v48 = bit32.band(v43[1] * v45[1] + bit32.lshift(bit32.band(v43[1] * bit32.rshift(v42[1], 16) + v44[1] * v45[1], 65535), 16), 4294967295)
		PanelTitle.Font = Enum.Font.GothamMedium
		local v49 = PanelTitle
		local v50 = Font
		local v51 = bit32.bor(v40, v48)
		local new = v50.new
		local v52 = bit32.band(v48, 1378105778)
		local semiBold = Enum.FontWeight.SemiBold
		local fontStyle = Enum.FontStyle
		v46 = bit32.bxor(v37, 283953555)
		v49.FontFace = new("rbxasset://fonts/families/GothamSSm.json", semiBold, fontStyle.Normal)
		local v53 = v52
		PanelTitle.StrokeThickness = 0.7
		local v54 = PanelTitle
		v47 = bit32.lshift(v52, 8)
		v54.StrokeTransparency = 0
		PanelLabels = {}

		for i = 1, 14 do
			local v55 = CreateTextLabel()
			v55.Visible = false
			v55.Size = 12
			v55.Outline = true
			v55.Center = true
			v55.Font = Enum.Font.GothamMedium
			local font = Font.new
			local semiBold2 = Enum.FontWeight.SemiBold
			local fontStyle2 = Enum.FontStyle
			local v56 = bit32.bxor(v46, 488744508)
			v55.FontFace = font("rbxasset://fonts/families/GothamSSm.json", semiBold2, fontStyle2.Normal)
			v55.StrokeThickness = 0.7
			v55.StrokeTransparency = 0
			PanelLabels[i] = v55
			v46 = bit32.bxor(v56, 488744508)
		end

		BrandHealthBarObject = nil
		BrandHealthBarScanAt = 0

		GetBrandHealthBarAnchor = function(arg)
			local n10 = 2390547624
			local n11 = 60973539
			local n12 = 3588952263
			local v55 = BrandHealthBarObject

			if v55.Parent and v55.Visible then
				n11 = n10
				local absoluteSize = v55.AbsoluteSize
				local absolutePosition = v55.AbsolutePosition

				if absoluteSize.X > 40 and absoluteSize.Y > 0 then
					local x = absolutePosition.X
					local n13 = absoluteSize.X / 2
					local v56 = table.pack(bit32.band(bit32.bor(n12, n10), 4294967295))
					local v57 = table.pack(bit32.band(n10, 4294967295))
					local v58 = table.pack(bit32.band(v56[1], 65535))
					local v59 = table.pack(bit32.rshift(v56[1], 16))
					local v60 = table.pack(bit32.band(v57[1], 65535))
					bit32.band(v58[1] * v60[1] + bit32.lshift(bit32.band(v58[1] * bit32.rshift(v57[1], 16) + v59[1] * v60[1], 65535), 16), 4294967295)
					return x + n13, arg.Y - 100
				end
			end

			local v56 = Clock()
			local v57 = BrandHealthBarScanAt
			local v58 = bit32.rshift(n10, 11)
			if v56 - v57 < 0.75 then
				return arg.X * 0.625, arg.Y - 100
			end
			BrandHealthBarScanAt = v56
			local v59 = table.pack(bit32.band(v58, 4294967295))
			local v60 = table.pack(bit32.band(v59[1], 65535))
			local v61 = bit32.band(v60[1] * 58467 + bit32.lshift(bit32.band(v60[1] * 0 + bit32.rshift(v59[1], 16) * 58467, 65535), 16), 4294967295)
			local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
			local n13 = -MathHuge
			local v62 = nil

			if playerGui then
				local v63 = next
				local descendants, v64 = playerGui:GetDescendants()
				local n14 = n12 // v61
				v62 = nil

				for _, v65 in v63, descendants, v64 do
					if not (not v65:IsA("GuiObject") or not v65.Visible) then
						local v66 = string.lower(v65.Name)
						local isTextLabel = v65:IsA("TextLabel") or v65:IsA("TextButton")
						local str = ""

						if isTextLabel then
							str = string.lower(v65.Text or "")
						end

						if v66 == "hp" or string.find(v66, "health", 1, true) or str == "health" or str == "hp" then
							local absoluteSize = v65.AbsoluteSize
							local absolutePosition = v65.AbsolutePosition

							if not (absoluteSize.X < 40 or absoluteSize.Y <= 0 or absolutePosition.Y < arg.Y * 0.55) then
								local n15 = absolutePosition.Y + absoluteSize.X

								if v66 == "hp" or v66 == "health" then
									n15 += 500
								end

								if n13 < n15 then
									n13 = n15
									v62 = v65
								end
							end
						end
					end
				end

				n12 = n14 - 706015033
			end

			BrandHealthBarObject = v62

			if v62 then
				local n14 = v62.AbsolutePosition.X + v62.AbsoluteSize.X / 2
				local y = arg.Y
				bit32.rshift(n12, 19)
				return n14, y - 100
			end

			local n14 = arg.X * 0.625
			local v63 = bit32.bor(v61, n12)
			bit32.bxor(n11, 1155541068)
			return n14, arg.Y - 100
		end

		TriggerTargetLocked = false
		local v55 = bit32.band(v53, 3903533263)
		AimbotTargetLocked = false
		AntiFutureVisDot = CreateSquare()
		local v56 = table.pack(bit32.band(v55, 4294967295))
	end

	local v48 = table.pack(bit32.band(v47, 4294967295))
	local v49 = table.pack(bit32.band(t2766_10780_1[1], 65535))
	local v50 = table.pack(bit32.rshift(t2766_10780_1[1], 16))
	local v51 = table.pack(bit32.band(v48[1], 65535))
	local v52, v53, n10, v54, n11

	do
		local v55 = bit32.band(v49[1] * v51[1] + bit32.lshift(bit32.band(v49[1] * bit32.rshift(v48[1], 16) + v50[1] * v51[1], 65535), 16), 4294967295)
		AntiFutureVisDot.Visible = false
		AntiFutureVisDot.Color = Color3.fromRGB(255, 80, 80)
		local v56 = bit32.lshift(v47, 17)
		AntiFutureVisDot.Filled = true
		local v57 = bit32.lshift(v55, 30)
		AntiFutureVisDot.Size = Vector2New(8, 8)
		AntiFutureVisLabel = CreateTextLabel()
		AntiFutureVisLabel.Visible = false
		AntiFutureVisLabel.Size = 11
		local v58 = AntiFutureVisLabel
		local v59 = bit32.band(v56, v57)
		v58.Outline = true
		AntiFutureVisLabel.Center = true
		local n12 = v57 * 31165
		AntiFutureVisLabel.Font = Enum.Font.SourceSansBold
		local v60 = AntiFutureVisLabel
		local n13 = v59 - n12
		local font = Font.new("rbxasset://fonts/families/LegacyArial.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		v52 = bit32.bor(n12, 998410058)
		v60.FontFace = font

		TrackConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
			local n14 = 1934162428
			local n15 = 1021357510
			local n16 = 3696039369

			if not gameProcessed or input.UserInputType == Enum.UserInputType.MouseButton2 then
				local v61 = n15
				local userInputType = input.UserInputType
				local v62 = Enum
				bit32.bxor(v61, 1817251222)
				local n17 = 3696039369

				if userInputType == v62.UserInputType.MouseButton2 then
					local v63 = bit32.band(n16, 2083933617)
					bit32.bxor(n14, 1167713017)
					flag = true
					local n18 = v63 - 2142695352
				end
			end
		end))

		TrackConn(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				flag = false
			end
		end))

		local function fn13(arg, arg2)
			local n14 = 3127298214
			local n15 = 1676537280
			if type(arg2) ~= "table" then
				return false
			end
			local key = arg2.Key
			if key == nil then
				bit32.bxor(n15, n14)
				return false
			end
			local v61 = Tostring(key)
			local v62 = table.pack(bit32.band(n14, 4294967295))
			local v63 = table.pack(bit32.band(n15, 4294967295))
			local v64 = table.pack(bit32.band(v62[1], 65535))
			local v65 = table.pack(bit32.rshift(v62[1], 16))
			local v66 = table.pack(bit32.band(v63[1], 65535))
			local v67 = bit32.band(v64[1] * v66[1] + bit32.lshift(bit32.band(v64[1] * bit32.rshift(v63[1], 16) + v65[1] * v66[1], 65535), 16), 4294967295)
			local str = v61:lower()

			if Tostring(arg2.Mode or ""):lower() == "mouse" or str:sub(1, 5) == "mouse" or str:find("mousebutton", 1, true) ~= nil then
				local v68 = n15
				local v69 = n15
				local v70 = v68
				bit32.bxor(v69, 353036745)

				local v71 = ({
					mouse1 = "mousebutton1",
					mouse2 = "mousebutton2",
					mouse3 = "mousebutton3",
					leftmouse = "mousebutton1",
					rightmouse = "mousebutton2",
					middlemouse = "mousebutton3",
				})[str] or str

				local match = Tostring(arg.UserInputType):match("([^%.]+)$")
				bit32.band(v68, v70)
				return match ~= nil and match:lower() == v71
			end

			local match = Tostring(arg.KeyCode):match("([^%.]+)$")
			return match ~= nil and match:lower() == str
		end

		local v61 = TrackConn
		v53 = bit32.bxor(v46, 48879532)

		v61(UserInputService.InputBegan:Connect(function(input, gameProcessed)
			local n14 = 1325996394
			local n15 = 3100461996
			local n16 = 87176071
			local v62 = bit32.bxor(n16, 0)
			local n17 = bit32.band(2310608082, v62)
			local silentAim = fn()["Silent Aim"]
			local triggerbot = fn().Triggerbot
			local bind = triggerbot.Bind

			if fn13(input, bind) then
				local v63 = Tostring
				local n18 = bit32.bxor(n15, 4294967295)
				local v64 = v63(bind.Type or "Hold")
				local v65 = bit32.lshift(n17, 18)
				local str = v64:lower()

				if str == "toggle" then
					State.TriggerState = not State.TriggerState
				elseif str == "hold" then
					local v66 = State
					local v67 = bit32.bxor(n18, 3646886744)
					v66.TriggerState = true
					n18 = v67 - 1463481016
				end

				n15 = bit32.bxor(n18, 4294967295)
				n17 = v65 + 3207073922
			end

			if gameProcessed then
				return
			end
			local checks = fn().Main.Checks
			local n18 = bit32.bxor(n17, 4294967295)
			local typing = checks["Silent Aim"].Typing
			local v63 = table.pack(bit32.band(n16, 4294967295))
			local v64 = table.pack(bit32.band(v63[1], 65535))
			local n19 = bit32.band(39394 * v64[1] + bit32.lshift(bit32.band(39394 * bit32.rshift(v63[1], 16) + 41394 * v64[1], 65535), 16), 4294967295) + 2628785160
			local v65 = table.pack(bit32.band(bit32.bor(n16, 272710212), 4294967295))
			local v66 = table.pack(bit32.band(v65[1], 65535))
			local v67 = bit32.band(26143 * v66[1] + bit32.lshift(bit32.band(26143 * bit32.rshift(v65[1], 16) + 24141 * v66[1], 65535), 16), 4294967295)
			local bor = bit32.bor
			local v68 = bit32.bxor(n16, 0)
			local n20 = bor(n15, v68)
			local v69 = table.pack(bit32.band(bit32.band(n16, 272710212), 4294967295))
			local v70 = table.pack(bit32.band(v69[1], 65535))
			local n21 = n19 + v67 + bit32.band(26141 * v70[1] + bit32.lshift(bit32.band(26141 * bit32.rshift(v69[1], 16) + 24141 * v70[1], 65535), 16), 4294967295)
			local v71 = n18
			if typing and IsTyping() then
				return
			end
			local enabled = silentAim.Enabled

			if enabled then
				enabled = fn().Main["Silent Aim"].Selection == "Target"
				n20 = n20 + bit32.bxor(n21, 0) - 359860675
			end

			if enabled then
				local main = fn().Main
				local v72 = bit32.rshift(n18, 13)
				local binds = main.Binds
				local v73

				if binds then
					local target = fn().Main.Binds.Target
					local v74 = table.pack(bit32.band(n20, 4294967295))
					local v75 = table.pack(bit32.band(v72, 4294967295))
					local v76 = table.pack(bit32.band(v74[1], 65535))
					local v77 = table.pack(bit32.rshift(v74[1], 16))
					local v78 = table.pack(bit32.band(v75[1], 65535))
					n20 = bit32.bxor(bit32.band(v76[1] * v78[1] + bit32.lshift(bit32.band(v76[1] * bit32.rshift(v75[1], 16) + v77[1] * v78[1], 65535), 16), 4294967295), 2577333886)
					v73 = target
				else
					v73 = binds
				end

				if v73 then
					local flag2 = false

					Pcall(function()
						local n22 = 2431468041
						local n23 = 3881033161
						local v74 = input
						local v75 = bit32.bxor(3103354627, n23)

						if v74.KeyCode == Enum.KeyCode[v73:upper()] then
							local v76 = bit32.bxor(n23, v75)
							flag2 = true
							bit32.bxor(n22, 2440109326)
						end
					end)

					if not flag2 then
						Pcall(function()
							if input.UserInputType == Enum.UserInputType[v73] then
								flag2 = true
							end
						end)
					end

					if flag2 then
						local flag3 = not SilentTargetLocked
						local v74 = bit32.bxor(n21, 61628092)
						SilentTargetLocked = flag3
						local v75 = bit32.bxor(v74, 0)
						local n22 = v72 + 2293696323
						local offscreenTargeting = fn()["Silent Aim"]["Offscreen Targeting"]
						local targets = State.Targets
						local v76 = GetClosestPlayerToCursor
						local v77 = fn()
						local n23 = v75 - bit32.bxor(v74, 0)
						targets.Silent = v76(v77["Silent Aim"]["Max Range"], offscreenTargeting and offscreenTargeting.Enabled, "Targeting", "Silent Aim")
						n21 = bit32.bxor(v74, 61628092)
						n20 = n23 - 3911231617 - 1491065808
						v72 = bit32.bxor(n22, 2293828541)
					end
				end

				n18 = v72 + 4274518270
			end

			local n22 = bit32.band(n20, 1709747773)

			if triggerbot.Enabled and fn().Main.Triggerbot.Selection == "Target" then
				local n23 = n18 // n22
				local binds = fn().Main.Binds
				local target

				if binds then
					n22 = n22 + n23 + 4294967290
					target = fn().Main.Binds.Target
				else
					target = binds
				end

				if target then
					local flag2 = false

					Pcall(function()
						local n24 = 2722893584
						local n25 = 3271757561
						local n26 = 1926526200

						if input.KeyCode == Enum.KeyCode[target:upper()] then
							flag2 = true
							local v72 = table.pack(bit32.band(n25, 4294967295))
							local v73 = table.pack(bit32.band(n26, 4294967295))
							local v74 = table.pack(bit32.band(v72[1], 65535))
							local v75 = table.pack(bit32.rshift(v72[1], 16))
							local v76 = table.pack(bit32.band(v73[1], 65535))
							local v77 = bit32.band(v74[1] * v76[1] + bit32.lshift(bit32.band(v74[1] * bit32.rshift(v73[1], 16) + v75[1] * v76[1], 65535), 16), 4294967295)
							bit32.bxor(n24, 2011303286)
						end
					end)

					local n24 = n23 * 45623

					if not flag2 then
						local v72 = Pcall
						local v73 = table.pack(bit32.band(n21, 4294967295))
						local v74 = table.pack(bit32.band(v73[1], 65535))
						local v75 = bit32.band(57810 * v74[1] + bit32.lshift(bit32.band(57810 * bit32.rshift(v73[1], 16) + 51806 * v74[1], 65535), 16), 4294967295)
						local v76 = table.pack(bit32.band(bit32.bnot(n21), 4294967295))
						local v77 = table.pack(bit32.band(v76[1], 65535))
						local n25 = 3890142400 + v75 + bit32.band(57810 * v77[1] + bit32.lshift(bit32.band(57810 * bit32.rshift(v76[1], 16) + 51806 * v77[1], 65535), 16), 4294967295)

						local function fn14()
							local n26 = 1166033445
							local n27 = 1316867935

							if input.UserInputType == Enum.UserInputType[target] then
								bit32.bxor(n26, 1293080035)
								local v78 = bit32.rshift(n27, 17)
								flag2 = true
							end
						end

						v72(fn14)
					end

					if flag2 then
						TriggerTargetLocked = not TriggerTargetLocked
						local offscreenTargeting = fn().Triggerbot["Offscreen Targeting"]
						local v72 = bit32.bor(n24, 1958913393)
						local targets = State.Targets
						local v73 = GetClosestPlayerToCursor
						local n25 = n22 * 3
						local triggerbot2 = fn().Triggerbot
						local v74 = bit32.bxor(n21, 160448083)
						targets.Triggerbot = v73(triggerbot2["Max Range"], offscreenTargeting and offscreenTargeting.Enabled, "Targeting", "Triggerbot")
						local v75 = bit32.band(n25, v72)
						n21 = bit32.bxor(v74, 160448083)
						n22 = bit32.bxor(v75, 1432880686)
						n24 = v72 - 1958903857
					end

					n23 = bit32.bxor(n24, 273740)
				end

				n18 = n23 - 19927177
			end

			local v72 = fn()
			local v73 = bit32.bxor(n21, 0)
			local n23 = bit32.bxor(n18, v73)
			local binds = v72.Main.Binds
			local aimbot

			if binds then
				n22 = n22 + n23 - 3955025598
				aimbot = fn().Main.Binds.Aimbot
			else
				aimbot = binds
			end

			if aimbot then
				local flag2 = false

				Pcall(function()
					local n24 = 2815151604
					local n25 = 238051286

					if input.KeyCode == Enum.KeyCode[aimbot:upper()] then
						flag2 = true
					end
				end)

				local n24 = n23 // 6

				if not flag2 then
					Pcall(function()
						if input.UserInputType == Enum.UserInputType[aimbot] then
							flag2 = true
						end
					end)
				end

				if flag2 then
					local v74 = fn()
					local v75 = bit32.bxor(n21, 113277645)
					local mode = v74.Aimbot.Mode

					if not mode then
						n22 = n22 // bit32.bxor(v75, 0) - 3658995156
						mode = "Toggle"
					end

					if mode == "Hold" then
						AimbotTargetLocked = true
						local v76 = State
						local v77 = bit32.bor(n24, 909420176)
						v76.Targets.Aimbot = GetClosestPlayerToCursor(fn().Aimbot["Max Range"], nil, "Targeting", "Aimbot")
						v71 = v77
						n24 = v77 - 271876224
					else
						AimbotTargetLocked = not AimbotTargetLocked
						local targets = State.Targets
						local v76 = GetClosestPlayerToCursor
						local aimbot2 = fn().Aimbot
						local v77 = bit32.bxor(v75, 0)
						local v78 = bit32.bor(n22 // 7, v77)
						local maxRange = aimbot2["Max Range"]
						local v79 = bit32.bxor(v75, 414962306)
						targets.Aimbot = v76(maxRange, nil, "Targeting", "Aimbot")
						v75 = bit32.bxor(v79, 414962306)
						n22 = v78 + 233614078
					end

					n21 = bit32.bxor(v75, 113277645)
					n24 = bit32.band(n24, 2936407824) + 4726885
				end

				n23 = n24 - 999112631
			end

			local binds2 = fn().Main.Binds
			local walkSpeed

			if binds2 then
				n22 = n22 // n23 - 3658995155
				walkSpeed = fn().Main.Binds["Walk Speed"]
			else
				walkSpeed = binds2
			end

			if walkSpeed then
				local flag2 = false

				Pcall(function()
					if input.KeyCode == Enum.KeyCode[walkSpeed:upper()] then
						flag2 = true
					end
				end)

				if flag2 then
					local n24 = n22 + 1254571196
					State.SpeedModificationsActive = not State.SpeedModificationsActive
					local speedModificationsActive = State.SpeedModificationsActive
					local v74 = bit32.band(n23, 3464992867)

					if not speedModificationsActive then
						fn3(State)
					end

					n22 = n24 - 1254571196
					n23 = v74 - 3737622884
				end
			end

			local n24 = n23 // 122
			local jumpPower = fn().Main.Binds and fn().Main.Binds["Jump Power"]

			if jumpPower then
				local flag2 = false

				Pcall(function()
					if input.KeyCode == Enum.KeyCode[jumpPower:upper()] then
						flag2 = true
					end
				end)

				local v74 = table.pack(bit32.band(n21, 4294967295))
				local v75 = table.pack(bit32.band(v74[1], 65535))
				local v76 = bit32.band(59699 * v75[1] + bit32.lshift(bit32.band(59699 * bit32.rshift(v74[1], 16) + 20355 * v75[1], 65535), 16), 4294967295)
				local n25 = n22 // n24
				local n26 = n24 - bit32.bxor(n21, 0)
				local v77 = table.pack(bit32.band(bit32.bor(n21, 148962164), 4294967295))
				local v78 = table.pack(bit32.band(v77[1], 65535))
				local v79 = bit32.band(5838 * v78[1] + bit32.lshift(bit32.band(5838 * bit32.rshift(v77[1], 16) + 45180 * v78[1], 65535), 16), 4294967295)
				local v80 = table.pack(bit32.band(bit32.band(n21, 148962164), 4294967295))
				local v81 = table.pack(bit32.band(v80[1], 65535))
				local n27 = v76 + 34253852 + v79 + bit32.band(5836 * v81[1] + bit32.lshift(bit32.band(5836 * bit32.rshift(v80[1], 16) + 45180 * v81[1], 65535), 16), 4294967295)

				if flag2 then
					local v82 = State
					local v83 = State
					local v84 = bit32.bxor(n25, 4294967295)
					v82.JumpModificationsActive = not v83.JumpModificationsActive
					n25 = v84 + bit32.bxor(n27, 0) + 3798732144
				end

				n21 = bit32.bxor(n27, 148962164)
				n22 = n25 - 3658995174
				n24 = bit32.bxor(n26, 3985978941)
			end

			local doubleTap = fn().Modifications["Double Tap"]
			local v74 = fn()
			local v75 = bit32.bxor(n21, 0)
			local v76 = table.pack(bit32.band(n24, 4294967295))
			local v77 = table.pack(bit32.band(v75, 4294967295))
			local v78 = table.pack(bit32.band(v76[1], 65535))
			local v79 = table.pack(bit32.rshift(v76[1], 16))
			local v80 = table.pack(bit32.band(v77[1], 65535))
			local v81 = bit32.band(v78[1] * v80[1] + bit32.lshift(bit32.band(v78[1] * bit32.rshift(v77[1], 16) + v79[1] * v80[1], 65535), 16), 4294967295)
			local binds3 = v74.Main.Binds

			if binds3 then
				binds3 = fn().Main.Binds["Double Tap"]
				n22 = bit32.bor(n22, v81) - 134283458
			end

			local enabled2 = doubleTap.Enabled

			if enabled2 then
				n14 = v81
				enabled2 = doubleTap.Mode ~= "Always"
			end

			if enabled2 and binds3 then
				local flag2 = false

				Pcall(function()
					local n25 = 567928631

					if input.KeyCode == Enum.KeyCode[binds3:upper()] then
						bit32.bxor(n25, 3683446117)
						flag2 = true
					end
				end)

				if flag2 then
					State.DoubleTapActive = not State.DoubleTapActive
				end
			end

			local n25 = v81 - 1186043636
			local binds4 = fn().Main.Binds
			local esp

			if binds4 then
				local main = fn().Main
				local v82 = bit32.bor(n22, n25)
				local binds5 = main.Binds
				bit32.bxor(n14, 1582130719)
				esp = binds5.ESP
				n22 = v82 + 1038646830
			else
				esp = binds4
			end

			if esp then
				local flag2 = false

				Pcall(function()
					if input.KeyCode == Enum.KeyCode[esp:upper()] then
						flag2 = true
					end
				end)

				if flag2 then
					local nameEsp = fn()["Name ESP"]
					local v82 = fn()
					local v83 = bit32.band(n25, n22)
					local enabled3 = v82["Name ESP"].Enabled
					local v84 = bit32.lshift(n22, 30)
					nameEsp.Enabled = not enabled3
					n22 = v84 - 437769683
					n25 = v83 - 1038646830
				end
			end

			local v82 = fn()
			bit32.bxor(v71, v67)
			local binds5 = v82.Main.Binds
			local sorter

			if binds5 then
				n25 = n25 // 2 + 1629209833
				sorter = fn().Main.Binds.Sorter
			else
				sorter = binds5
			end

			local enabled3

			if sorter then
				enabled3 = fn().Utilities["Inventory Sorter"].Enabled
				n22 = bit32.bxor(n22, n25) + 1040746030
			else
				enabled3 = sorter
			end

			if enabled3 then
				local flag2 = false
				local v83 = Pcall
				local v84 = bit32.bxor(n21, 127296868)

				v83(function()
					if input.KeyCode == Enum.KeyCode[sorter:upper()] then
						flag2 = true
					end
				end)

				if flag2 then
					Spawn(function()
						local n26 = 1499803427
						local n27 = 626751938
						local n28 = 702531717
						local n29 = 824733457
						State.SorterActive = true

						if not localPlayer.Character then
							local v85 = State
							bit32.lshift(n29, 28)
							v85.SorterActive = false
							return
						end

						local backpack = localPlayer:FindFirstChildOfClass("Backpack")
						local v85 = bit32.band(n28, n29)
						if not backpack then
							State.SorterActive = false
							return
						end
						local v86 = fn()
						local v87 = bit32.bor(v85, n29)
						local order = v86.Utilities["Inventory Sorter"].Order
						local n30 = 10 - #order
						local folder = Instance.new("Folder")
						folder.Name = "SorterTemp"
						folder.Parent = Workspace
						bit32.bor(n29 - v87, 1143057620)
						local v88 = next
						local children, v89 = backpack:GetChildren()

						for _, v90 in v88, children, v89 do
							if v90:IsA("Tool") then
								v90.Parent = folder
							end
						end

						for _, v90 in next, order, nil do
							local v91 = folder:FindFirstChild(v90)

							if v91 then
								v91.Parent = backpack
								Wait(0.05)
								n26 = bit32.bxor(n26, 1679425899)
							else
								n30 += 1
							end
						end

						local v90 = next
						local children2, v91 = folder:GetChildren()

						for _, v92 in v90, children2, v91 do
							if v92:FindFirstChild("Drink") or v92:FindFirstChild("Eat") then
								v92.Parent = backpack
								n30 -= 1
							end
						end

						if n30 > 0 then
							for i = 1, n30 do
								local tool = Instance.new("Tool")
								tool.Name = ""
								tool.ToolTip = "PlaceHolder"
								tool.GripPos = Vector3New(0, 1, 0)
								tool.RequiresHandle = false
								tool.Parent = backpack
							end
						end

						local v92 = next
						local children3, v93 = folder:GetChildren()
						local v94 = bit32.bxor(v87, 4294967295)

						for _, v95 in v92, children3, v93 do
							if v95:IsA("Tool") then
								v95.Parent = backpack
							end
						end

						local v95 = next
						local children4, v96 = backpack:GetChildren()

						for _, v97 in v95, children4, v96 do
							if v97.Name == "" then
								v97:Destroy()
								n27 = bit32.bxor(n27, 3520512004)
							end
						end

						folder:Destroy()
						bit32.bxor(v94, 2693480654)
						Wait(0.5)
						State.SorterActive = false
					end)

					n22 = bit32.bxor(bit32.bxor(n22, n25), 3258419666)
				end

				n21 = bit32.bxor(v84, 127296868)
			end

			local keyCode = input.KeyCode
			local leftControl = Enum.KeyCode.LeftControl
			local v83 = bit32.bor(n25, 989885881)

			if keyCode == leftControl then
				local v84 = State
				local v85 = bit32.band(n22, v83)
				v84.CanTriggerbotShoot = false
				n22 = v85 + 80216580
			end

			local antiFuture = fn()["Anti Future"]
			local v84 = fn
			local v85 = bit32.bxor(n21, 163897027)
			local main = v84().Main
			local n26 = bit32.lshift(v83, 19)
			local antiFuture2 = main.Binds and fn().Main.Binds["Anti Future"]
			local v86

			if antiFuture2 then
				local enabled4 = antiFuture.Enabled
				local v87 = bit32.bxor(v85, 0)
				n26 = bit32.bxor(n26, v87) - 60282624
				v86 = enabled4
			else
				v86 = antiFuture2
			end

			if v86 then
				local flag2 = false
				local v87 = Pcall
				local n27 = 9096073556

				local function fn14()
					local n28 = 1800972854
					local n29 = 3052097376
					local n30 = -2296354651

					if input.KeyCode == Enum.KeyCode[antiFuture2:upper()] then
						bit32.bxor(n28, 2116221876)
						flag2 = true
					end
				end

				bit32.bxor(v85, 66666505)
				v87(fn14)

				if flag2 then
					RunAntiFutureToggle()
				end
			end

			local n27 = n22 - n26
			local panicGround = fn()["Panic Ground"]
			local binds6 = fn().Main.Binds
			binds6 = binds6 and fn().Main.Binds["Panic Ground"]
			local enabled4 = binds6 and panicGround

			if enabled4 then
				enabled4 = panicGround.Enabled
				local n28 = bit32.bxor(v85, 0) - 3869748435
			end

			if enabled4 then
				local flag2 = false

				Pcall(function()
					if input.KeyCode == Enum.KeyCode[binds6:upper()] then
						flag2 = true
					end
				end)

				if flag2 then
					RunPanicGround()
				end
			end
		end))

		TrackConn(UserInputService.InputEnded:Connect(function(input)
			local n14 = 2966994634
			local n15 = 1968831461
			local n16 = 646216313 // n15

			if fn().Aimbot.Mode == "Hold" then
				local main = fn().Main
				n15 = bit32.bor(n15, n16)
				local binds = main.Binds

				if binds then
					local aimbot = fn().Main.Binds.Aimbot
					n16 = bit32.bxor(bit32.bor(n16, n15), 1968831461)
					binds = aimbot
				end

				if binds then
					local flag2 = false
					local n17 = 72011384

					Pcall(function()
						local n18 = 2988633200
						local n19 = 2030041359

						if input.KeyCode == Enum.KeyCode[binds:upper()] then
							flag2 = true
							local v62 = bit32.lshift(n19, 26)
							bit32.bxor(n18, 4150486343)
							local n20 = v62 + 1023408399
						end
					end)

					if not flag2 then
						local n18 = 57956201

						Pcall(function()
							if input.UserInputType == Enum.UserInputType[binds] then
								flag2 = true
							end
						end)
					end

					if flag2 then
						AimbotTargetLocked = false
						local v62 = bit32.band(n15, 1744630166)
						State.Targets.Aimbot = nil
						n15 = bit32.bxor(v62, 268503649)
					end
				end
			end

			local bind = fn().Triggerbot.Bind
			local flag2

			if bind then
				local v62 = Tostring
				local v63 = bit32.bor(n15, 666953050)
				local str = v62(bind.Type or "Hold"):lower()
				bit32.bxor(n14, 3217871688)
				local v64 = bit32.bxor(n16, 2698093444)
				flag2 = str == "hold"
				n15 = bit32.bxor(v63, 41944090)
				n16 = v64 - 2698093444
			else
				flag2 = bind
			end

			if flag2 and fn13(input, bind) then
				State.TriggerState = false
			end

			local keyCode = input.KeyCode
			local keyCode2 = Enum.KeyCode
			bit32.bxor(n15, 4294967295)

			if keyCode == keyCode2.LeftControl then
				State.CanTriggerbotShoot = true
			end
		end))

		TrackConn(RunService.Heartbeat:Connect(function()
			local n14 = 584710948
			local n15 = 2469766567
			local n16 = 526024674
			local n17 = 1191900489
			cider = shared.Cider or cider
			local v62 = UpdatePositionCache
			bit32.bxor(n15, 2773005578)
			v62()
			local v63 = bit32.bor(n17, 4098775264)
			bit32.bxor(n14, 3120868396)
			CachedIgnored = Workspace:FindFirstChild("Ignored")
			CachedBush = Workspace:FindFirstChild("Bush")
		end))

		local v62 = bit32.bor(n13 // 152, 2323108537)

		TrackConn(RunService.Heartbeat:Connect(function()
			local n14 = 2157224271
			local n15 = 3510608493
			local panicGround = fn()["Panic Ground"]
			local auto = panicGround and panicGround.Auto
			if not panicGround or not panicGround.Enabled or not auto or not auto.Enabled then
				State.PanicGround.AutoTriggered = false
				return
			end
			local character = localPlayer.Character
			character = character and character:FindFirstChildOfClass("Humanoid")
			local flag2 = not character

			if not flag2 then
				flag2 = character.Health <= 0
				n15 = bit32.bor(n15, n14) - 8388866
			end

			if flag2 then
				State.PanicGround.AutoTriggered = false
				return
			end
			local healthAmount = auto["Health Amount"]

			if not healthAmount then
				n15 = bit32.bor(n15, 3370322015) + 4148164590
				healthAmount = 25
			end

			if character.Health <= healthAmount then
				if not State.PanicGround.AutoTriggered then
					State.PanicGround.AutoTriggered = true
					local v63 = RunPanicGround
					bit32.bxor(n14 + n15, 301557374)
					v63()
				end
			else
				State.PanicGround.AutoTriggered = false
			end
		end))

		TrackConn(RunService.PreRender:Connect(function()
			local silentAim = fn()["Silent Aim"]
			local triggerbot = fn().Triggerbot
			local aimbot = fn().Aimbot
			local currentCamera2 = Workspace.CurrentCamera
			local n14 = 2043566268
			local n15 = 134314783
			local y = currentCamera2.ViewportSize.Y
			local v63 = bit32.bxor(n15, 0)
			local v64 = bit32.bor(4373548618, v63)
			local fieldOfView = currentCamera2.FieldOfView
			local v65 = fn7()
			local offscreenTargeting = silentAim["Offscreen Targeting"]

			if offscreenTargeting then
				offscreenTargeting = silentAim["Offscreen Targeting"].Enabled
				n14 = bit32.bxor(n14, v64) + 74264793
			end

			local enabled = triggerbot["Offscreen Targeting"] and triggerbot["Offscreen Targeting"].Enabled
			local n16 = v64 + 168291230
			local v66 = GetClosestPlayerToCursor(nil, nil, "Automatic")

			if silentAim.Enabled and fn().Main["Silent Aim"].Selection == "Automatic" then
				State.Targets.Silent = GetClosestPlayerToCursor(silentAim["Max Range"], offscreenTargeting, "Automatic", "Silent Aim")
				n16 = n16 + 1552422531 - 1552422531
			end

			local enabled2 = triggerbot.Enabled

			if enabled2 then
				enabled2 = fn().Main.Triggerbot.Selection == "Automatic"
				n14 = bit32.bxor(n14 // bit32.bxor(n15, 0), 2043566259)
			end

			if enabled2 then
				local targets = State.Targets
				local v67 = bit32.bxor(n15, 0)
				local v68 = bit32.bor(n14, v67)
				local v69 = GetClosestPlayerToCursor
				local maxRange = triggerbot["Max Range"]
				local v70 = bit32.bxor(n15, 0)
				local v71 = bit32.band(n16, v70)
				targets.Triggerbot = v69(maxRange, enabled, "Automatic", "Triggerbot")
				n16 = bit32.bxor(v71, 381026528)
				n14 = v68 + 4294892797
			end

			local silent = State.Targets.Silent
			local silent2 = fn().Main.FOV.Silent
			local lower = string.lower
			local v67 = tostring
			local v68 = n14
			local options = silent2.Options

			if not options then
				n16 = bit32.bxor(n16 - 684980699, 4216593375)
				options = "2D"
			end

			local flag2 = lower(v67(options)) == "3d"
			local v69 = Silent3DFOVBox
			local visualize = silent2.Visualize
			local v70 = bit32.bxor(n15, 0)
			local n17 = bit32.band(n14, v70)
			fn12(v69, silent2, visualize.Color or SilentFOVOutColor)
			local flag3 = not silent

			if flag3 then
				flag3 = silent2.Visualize.Enabled
				n15 = bit32.bxor(bit32.bxor(n15, 328813655), 328813655)
				n16 = n16 // 147 - 3916440714
			end

			local v71

			if flag3 then
				v71 = v66
			else
				v71 = silent
			end

			local x = currentCamera2.ViewportSize.X
			local n18

			if not flag2 and silent2.Visualize.Enabled and v71 then
				n18 = bit32.band(n16, n17)
				local character = v71.Character
				character = character and character:FindFirstChild("HumanoidRootPart")
				local v72

				if character then
					local v73 = IsVisible
					local position = character.Position
					local v74 = bit32.bxor(n17, 1672675730)
					v72 = v73(position, v71)
					local v75 = table.pack(bit32.band(n15, 4294967295))
					local v76 = table.pack(bit32.band(v75[1], 65535))
					local n19 = bit32.band(30843 * v76[1] + bit32.lshift(bit32.band(30843 * bit32.rshift(v75[1], 16) + 34237 * v76[1], 65535), 16), 4294967295) + 661350164
					local v77 = table.pack(bit32.band(bit32.bor(n15, 173804284), 4294967295))
					local v78 = table.pack(bit32.band(v77[1], 65535))
					local v79 = bit32.band(3850 * v78[1] + bit32.lshift(bit32.band(3850 * bit32.rshift(v77[1], 16) + 62597 * v78[1], 65535), 16), 4294967295)
					local v80 = table.pack(bit32.band(bit32.bxor(n15, 173804284), 4294967295))
					local v81 = table.pack(bit32.band(v80[1], 65535))
					n15 = bit32.bxor(n19 + v79 + bit32.band(30844 * v81[1] + bit32.lshift(bit32.band(30844 * bit32.rshift(v80[1], 16) + 34237 * v81[1], 65535), 16), 4294967295), 173804284)
					n18 = n18 // v74 + 18460
					n17 = v74 - 1672675698
				else
					v72 = character
				end

				if v72 then
					local v73, v74 = currentCamera2:WorldToViewportPoint(character.Position)

					if v74 and v73.Z > 1 then
						v68 = n17
						local size = character.Size
						local v75 = bit32.bxor(n17, 4294967295)
						local n19 = size.Y * y / v73.Z * 2 * 80 / fieldOfView
						local width = silent2.Width

						if width then
							local width2 = silent2.Width
							local n20 = n18 + bit32.bxor(n15, 0)
							width = width2[1] or 150
							n18 = bit32.bxor(n20, 134318887)
						end

						width = width or 150
						local n20 = silent2.Height and (silent2.Height[1] or 150) or 150
						local v76 = MathMin
						local v77 = bit32.bxor(n15, 0)
						local v78 = bit32.bor(n18, v77)
						local v79 = v76(width * n19, x * 2)
						local v80 = MathMin(n20 * n19, y * 2)
						SilentFOVBox.Round = false
						local v81 = SilentFOVBox
						local v82 = Vector2New
						local v83 = MathFloor(v79 + 0.5)
						local v84 = MathFloor
						local v85 = bit32.bxor(n15, 0)
						local v86 = bit32.bxor(v75 - 4137389328, v85)
						v81.Size = v82(v83, v84(v80 + 0.5))
						local v87 = SilentFOVBox
						local v88 = bit32.bxor(v78, 336145288)
						local v89 = Vector2New
						local v90 = MathFloor
						local v91 = bit32.bxor(n15, 131709248)
						local x2 = v73.X
						local n21 = bit32.bor(v88, 212364373)
						v87.Position = v89(v90(x2 - v79 / 2 + 0.5), MathFloor(v73.Y - v80 / 2 + 0.5))
						local n22 = v86 + n21 - n21
						local n23 = Vector2New(v73.X, v73.Y) - v65
						local color = MathAbs(n23.X) <= v79 / 2

						if color then
							local v92 = MathAbs
							local v93 = bit32.bxor(n21, 3250984920)
							color = v92(n23.Y) <= v80 / 2
							n21 = v93 + 1060770248
						end

						local v92 = SilentFOVBox

						if color then
							color = SilentFOVInColor
							local v93 = bit32.bxor(v91, 0)
							n21 = bit32.bor(n21, v93) + 4239359480
						end

						v92.Color = color or SilentFOVOutColor
						local v93 = SilentFOVBox
						local visualize2 = silent2.Visualize
						local v94 = bit32.bxor(n22, n21)
						v93.Visible = visualize2.Enabled
						n15 = bit32.bxor(bit32.bxor(v91, 9348756), 123150292)
						n18 = bit32.bxor(n21, 480785611)
						n17 = v94 - 231523583
					else
						SilentFOVBox.Visible = false
					end
				else
					SilentFOVBox.Visible = false
				end
			else
				local v72 = SilentFOVBox
				local v73 = bit32.bor(n17, 3724242792)
				v72.Visible = false
				n18 = bit32.bxor(n16 - 3723126626, 952978311)
				n17 = bit32.bxor(v73, 3590006624)
			end

			local targetTracer = silentAim["Target Tracer"]
			local offscreenTargeting2 = silentAim["Offscreen Targeting"]
			offscreenTargeting2 = offscreenTargeting2 and offscreenTargeting2.Enabled

			if targetTracer and targetTracer.Enabled and silent then
				local n19 = bit32.bxor(n17, 2004515267)
				local character = silent.Character
				local head = character and character:FindFirstChild("Head")

				if head then
					local v72, flag4 = currentCamera2:WorldToViewportPoint(head.Position)
					local thickness = targetTracer.Thickness or 0.5

					if flag4 then
						flag4 = v72.Z > 0
						local v73 = bit32.bxor(n15, 0)
						n18 = bit32.bor(n18, v73) + 4160670973
					end

					local n20, n21

					if flag4 then
						SilentTargetLine.From = Vector2New(v65.X, v65.Y)
						local v73 = SilentTargetLine
						local v74 = Vector2New
						local v75 = bit32.lshift(n18, 1)
						v73.To = v74(v72.X, v72.Y)
						local v76 = SilentTargetLine
						local color = targetTracer.Color

						if not color then
							local color2 = Color3.fromRGB
							local v77 = bit32.bxor(n15, 0)
							local v78 = bit32.bxor(n19, v77)
							color = color2(255, 255, 255)
							n19 = v78 + 134137631
						end

						v76.Color = color
						SilentTargetLine.Thickness = thickness
						n20 = n19 // 222
						SilentTargetLine.Visible = true
						OffscreenSilentLine.Visible = false
						n21 = v75 // 5
						n15 = bit32.bxor(bit32.bxor(n15, 218640222), 218640222)
					else
						local n22, n23

						if offscreenTargeting2 then
							local position = (character:FindFirstChild("HumanoidRootPart") or head).Position
							local position2 = currentCamera2.CFrame.Position
							local v73 = bit32.rshift(n18, 12)
							local unit = (position - position2).Unit
							local rightVector = currentCamera2.CFrame.RightVector
							local cFrame = currentCamera2.CFrame
							local v74 = table.pack(bit32.band(n19, 4294967295))
							local v75 = table.pack(bit32.band(v74[1], 65535))
							local v76 = bit32.band(v75[1] * 58708 + bit32.lshift(bit32.band(v75[1] * 0 + bit32.rshift(v74[1], 16) * 58708, 65535), 16), 4294967295)
							local upVector = cFrame.UpVector
							local unit2 = Vector2New(unit:Dot(rightVector), -unit:Dot(upVector)).Unit
							local v77 = MathMin
							local v78 = MathAbs
							local n24 = unit2.X + 0.0001
							local v79 = bit32.bxor(n15, 0)
							local v80 = bit32.bor(v73, v79)
							local n25 = (x / 2 - 10) / v78(n24)
							local v81 = MathAbs
							local y2 = unit2.Y
							local v82 = bit32.bxor(n15, 0)
							local v83 = bit32.bor(v76 - 608297361, v82)
							local v84 = v77(n25, (y / 2 - 10) / v81(y2 + 0.0001))
							local to = Vector2New(x / 2, y / 2) + unit2 * v84
							local v85 = SilentTargetLine
							n22 = bit32.bxor(v80, 4294967295)
							v85.Visible = false
							local v86 = OffscreenSilentLine
							local v87 = bit32.bxor(n15, 0)
							local v88 = table.pack(bit32.band(v83, 4294967295))
							local v89 = table.pack(bit32.band(v87, 4294967295))
							local v90 = table.pack(bit32.band(v88[1], 65535))
							local v91 = table.pack(bit32.rshift(v88[1], 16))
							local v92 = table.pack(bit32.band(v89[1], 65535))
							local v93 = bit32.band(v90[1] * v92[1] + bit32.lshift(bit32.band(v90[1] * bit32.rshift(v89[1], 16) + v91[1] * v92[1], 65535), 16), 4294967295)
							v86.From = v65
							OffscreenSilentLine.To = to
							local v94 = OffscreenSilentLine
							local v95 = bit32.bxor(n15, 62870135)
							local color = targetTracer.Color

							if not color then
								color = Color3.fromRGB(255, 255, 255)
								n22 = n22 + 3761347523 + 533619773
							end

							v94.Color = color
							local v96 = OffscreenSilentLine
							n23 = bit32.lshift(v93, 27)
							v96.Thickness = thickness
							OffscreenSilentLine.Visible = true
							n15 = bit32.bxor(v95, 62870135)
						else
							SilentTargetLine.Visible = false
							OffscreenSilentLine.Visible = false
							local v73 = bit32.bxor(n15, 0)
							local v74 = table.pack(bit32.band(n19, 4294967295))
							local v75 = table.pack(bit32.band(v73, 4294967295))
							local v76 = table.pack(bit32.band(v74[1], 65535))
							local v77 = table.pack(bit32.rshift(v74[1], 16))
							local v78 = table.pack(bit32.band(v75[1], 65535))
							n22 = n18 // n19 - 134314784
							n23 = bit32.band(v76[1] * v78[1] + bit32.lshift(bit32.band(v76[1] * bit32.rshift(v75[1], 16) + v77[1] * v78[1], 65535), 16), 4294967295) - 804208385
						end

						n21 = n22 + 134322168
						n20 = n23 + 4170383399
					end

					n18 = n21 + 11076
					n19 = n20 - 2165890632
				else
					SilentTargetLine.Visible = false
					OffscreenSilentLine.Visible = false
				end

				n17 = bit32.bxor(n19, 2004515267)
			else
				SilentTargetLine.Visible = false
				OffscreenSilentLine.Visible = false
				n18 = n18 - 3716055326 + 3716055326
			end

			local triggerbot2 = State.Targets.Triggerbot
			local n19 = n17 * 5
			local triggerbot3 = fn().Main.FOV.Triggerbot
			local lower2 = string.lower
			local v72 = tostring
			local options2 = triggerbot3.Options or "2D"
			local v73 = table.pack(v72(options2))
			local v74 = bit32.bxor(n18, 3077170536)
			local flag4 = lower2(table.unpack(v73, 1, v73.n)) == "3d"
			local v75 = Trigger3DFOVBox
			local n20 = n19
			fn12(v75, triggerbot3, triggerbot3.Visualize.Color or TriggerFOVOutColor)
			local flag5 = not triggerbot2

			if flag5 then
				flag5 = triggerbot3.Visualize.Enabled
				n19 = bit32.bxor(bit32.band(n19, 3741322856), 536981636)
			end

			if flag5 then
				triggerbot2 = v66
			end

			if not flag4 and triggerbot3.Visualize.Enabled and triggerbot2 then
				local character = triggerbot2.Character
				character = character and character:FindFirstChild("HumanoidRootPart")
				local v76

				if character then
					local v77 = IsVisible
					local v78 = bit32.bxor(n20, n19)
					local v79 = bit32.bxor(n15, 135374830)
					v76 = v77(character.Position, triggerbot2)
					n15 = bit32.bxor(v79, 135374830)
					n20 = v78 - 3623765876
				else
					v76 = character
				end

				if v76 then
					local v77, v78 = currentCamera2:WorldToViewportPoint(character.Position)
					local n21 = bit32.bxor(n19, 4294967295)

					if v78 and v77.Z > 1 then
						local n22 = character.Size.Y * y / v77.Z * 2 * 80 / fieldOfView
						local width = triggerbot3.Width

						if width then
							local width2 = triggerbot3.Width
							local v79 = bit32.rshift(n20, 29)
							width = width2[1] or 9e9
							n20 = v79 + 671201419
						end

						width = width or 9e9
						local height = triggerbot3.Height
						local n23

						if height then
							n23 = triggerbot3.Height[1] or 9e9
						else
							n23 = height
						end

						n23 = n23 or 9e9
						local v79 = MathMin
						local v80 = bit32.bxor(n15, 0)
						local v81 = v79(width * n22, x * 2)
						local v82 = MathMin
						local v83 = table.pack(bit32.band(n20, 4294967295))
						local v84 = table.pack(bit32.band(v80, 4294967295))
						local v85 = table.pack(bit32.band(v83[1], 65535))
						local v86 = table.pack(bit32.rshift(v83[1], 16))
						local v87 = table.pack(bit32.band(v84[1], 65535))
						local v88 = bit32.band(v85[1] * v87[1] + bit32.lshift(bit32.band(v85[1] * bit32.rshift(v84[1], 16) + v86[1] * v87[1], 65535), 16), 4294967295)
						local v89 = v82(n23 * n22, y * 2)
						TriggerFOVBox.Round = false
						local v90 = MathFloor
						TriggerFOVBox.Size = Vector2New(MathFloor(v81 + 0.5), v90(v89 + 0.5))
						local v91 = TriggerFOVBox
						local v92 = Vector2New
						local v93 = MathFloor
						local v94 = bit32.bor(v88, 3831708432)
						local v95 = v93(v77.X - v81 / 2 + 0.5)
						local v96 = MathFloor
						local y2 = v77.Y
						local v97 = bit32.bxor(n15, 270799091)
						local v98 = table.pack(v96(y2 - v89 / 2 + 0.5))
						local v99 = bit32.rshift(v94, 14)
						v91.Position = v92(v95, table.unpack(v98, 1, v98.n))
						local n24 = v99 * 7956
						local n25 = Vector2New(v77.X, v77.Y) - v65
						local v100 = MathAbs(n25.X)
						local v101 = bit32.bxor(v97, 0)
						local flag6 = v100 <= v81 / 2
						local v102 = bit32.bxor(v97, 519067290)
						TriggerFOVBox.Color = flag6 and MathAbs(n25.Y) <= v89 / 2 and TriggerFOVInColor or TriggerFOVOutColor
						v68 = n24
						local n26 = v101 - n24
						TriggerFOVBox.Visible = triggerbot3.Visualize.Enabled
						n15 = bit32.bxor(v102, 248792681)
						n20 = n24 + 3105117108
						n21 = n26 + 784744543
					else
						TriggerFOVBox.Visible = false
					end

					n19 = bit32.bxor(n21, 4294967295)
				else
					TriggerFOVBox.Visible = false
				end
			else
				TriggerFOVBox.Visible = false
				n19 = n19 // 10 - 3690886018
			end

			local aimbot2 = State.Targets.Aimbot
			local n21 = n20 - n19
			local main = fn().Main
			local v76 = table.pack(bit32.band(n19, 4294967295))
			local v77 = table.pack(bit32.band(v76[1], 65535))
			local n22 = bit32.band(v77[1] * 36551 + bit32.lshift(bit32.band(v77[1] * 0 + bit32.rshift(v76[1], 16) * 36551, 65535), 16), 4294967295)
			local aimbot3 = main.FOV.Aimbot
			local v78 = string.lower(tostring(aimbot3.Options or "2D"))
			local n23 = n22
			local flag6 = v78 == "3d"
			fn12(Aimbot3DFOVBox, aimbot3, aimbot3.Visualize.Color or AimbotFOVOutColor)
			local flag7 = not aimbot2
			local enabled3

			if flag7 then
				n22 = n22 - n23 - 4065059628
				enabled3 = aimbot3.Visualize.Enabled
			else
				enabled3 = flag7
			end

			if not enabled3 then
				v66 = aimbot2
			end

			if not flag6 and aimbot3.Visualize.Enabled and v66 then
				local character = v66.Character
				character = character and character:FindFirstChild("HumanoidRootPart")
				local v79

				if character then
					local v80 = IsVisible
					local position = character.Position
					local n24 = n23 + bit32.bxor(n15, 0)
					local v81 = v80(position, v66)
					n23 = bit32.bxor(n24, 402754343)
					v79 = v81
				else
					v79 = character
				end

				if v79 then
					local v80, v81 = currentCamera2:WorldToViewportPoint(character.Position)
					local flag8

					if v81 then
						local z = v80.Z
						local n24 = n23 + bit32.bxor(n15, 0)
						n15 = bit32.bxor(bit32.bxor(n15, 78020801), 78020801)
						n23 = bit32.bxor(n24, 402754343)
						flag8 = z > 1
					else
						flag8 = v81
					end

					local n24

					if flag8 then
						local n25 = character.Size.Y * y
						local z = v80.Z
						local n26 = bit32.bxor(n15, 0)
						local v82 = table.pack(bit32.band(n23, 4294967295))
						local v83 = table.pack(bit32.band(n26, 4294967295))
						local v84 = table.pack(bit32.band(v82[1], 65535))
						local v85 = table.pack(bit32.rshift(v82[1], 16))
						local v86 = table.pack(bit32.band(v83[1], 65535))
						local n27 = bit32.band(v84[1] * v86[1] + bit32.lshift(bit32.band(v84[1] * bit32.rshift(v83[1], 16) + v85[1] * v86[1], 65535), 16), 4294967295)
						local n28 = n25 / z * 2 * 80 / fieldOfView
						local width = aimbot3.Width
						local n29

						if width then
							n29 = aimbot3.Width[1] or 9e9
						else
							n29 = width
						end

						if not n29 then
							n26 = n26 - n27 + 4017969580
							n29 = 9e9
						end

						local height = aimbot3.Height
						local v87

						if height then
							local n30 = aimbot3.Height[1]
							local v88 = n26
							n30 = n30 or 9e9
							n27 = v88 - 411312499
							v87 = n30
						else
							v87 = height
						end

						local n30 = v87 or 9e9
						local v88 = MathMin(n29 * n28, x * 2)
						local v89 = MathMin(n30 * n28, y * 2)
						AimbotFOVBox.Round = false
						local v90 = AimbotFOVBox
						local v91 = Vector2New
						local v92 = MathFloor
						local v93 = bit32.bxor(n26, 4294967295)
						local v94 = MathFloor
						v90.Size = v91(v92(v88 + 0.5), v94(v89 + 0.5))
						local v95 = AimbotFOVBox
						local v96 = Vector2New
						local v97 = MathFloor
						local n31 = v80.X - v88 / 2
						local v98 = bit32.bxor(n27, 4294967295)
						local v99 = table.pack(bit32.band(n15, 4294967295))
						local v100 = table.pack(bit32.band(v99[1], 65535))
						local n32 = bit32.band(39616 * v100[1] + bit32.lshift(bit32.band(39616 * bit32.rshift(v99[1], 16) + 6689 * v100[1], 65535), 16), 4294967295) + 3119841600
						local v101 = bit32.bor(v98, 2479600068)
						local v102 = table.pack(bit32.band(bit32.bor(n15, 353323855), 4294967295))
						local v103 = table.pack(bit32.band(v102[1], 65535))
						local v104 = bit32.band(25921 * v103[1] + bit32.lshift(bit32.band(25921 * bit32.rshift(v102[1], 16) + 58846 * v103[1], 65535), 16), 4294967295)
						local v105 = bit32.band(n15, 353323855)
						local v106 = bit32.band(v93 - 3284079591, v101)
						local v107 = table.pack(bit32.band(v105, 4294967295))
						local v108 = table.pack(bit32.band(v107[1], 65535))
						local n33 = n32 + v104 + bit32.band(25919 * v108[1] + bit32.lshift(bit32.band(25919 * bit32.rshift(v107[1], 16) + 58846 * v108[1], 65535), 16), 4294967295)
						local v109 = MathFloor
						local n34 = v106 // 235
						local n35 = v80.Y - v89 / 2 + 0.5
						v95.Position = v96(v97(n31 + 0.5), v109(n35))
						local v110 = Vector2New(v80.X, v80.Y)
						local v111 = bit32.band(v101, 2486611893)
						local n36 = v110 - v65
						local v112 = MathAbs(n36.X)
						local v113 = bit32.bxor(n33, 0)
						n24 = bit32.band(v111, v113)
						bit32.bxor(v68, 687260319)
						local flag9 = v112 <= v88 / 2
						local v114

						if flag9 then
							local flag10 = MathAbs(n36.Y) <= v89 / 2
							n34 = n34 // bit32.bxor(n33, 0) + 1145399
							v114 = flag10
						else
							v114 = flag9
						end

						AimbotFOVBox.Color = v114 and AimbotFOVInColor or AimbotFOVOutColor
						AimbotFOVBox.Visible = aimbot3.Visualize.Enabled
						n15 = bit32.bxor(n33, 353323855)
						n22 = n34 - 4066205027
					else
						local v82 = AimbotFOVBox
						local v83 = bit32.rshift(n23, 27)
						v82.Visible = false
						n24 = v83 + 268574735
					end

					n23 = n24 + 4256300228
				else
					AimbotFOVBox.Visible = false
					n22 = n22 + n23 + 4065059628
				end
			else
				AimbotFOVBox.Visible = false
			end

			local nameEsp = fn()["Name ESP"]

			if nameEsp.Enabled then
				local color = nameEsp.Color

				if not color then
					color = Color3.fromRGB(180, 180, 180)
					n23 = bit32.bxor(n23 // n22, 229907669)
				end

				local targetColor = nameEsp["Target Color"]

				if not targetColor then
					local color2 = Color3.fromRGB
					local v79 = table.pack(bit32.band(n15, 4294967295))
					local v80 = table.pack(bit32.band(v79[1], 65535))
					local v81 = bit32.band(377 * v80[1] + bit32.lshift(bit32.band(377 * bit32.rshift(v79[1], 16) + 5009 * v80[1], 65535), 16), 4294967295)
					n22 = bit32.bor(n22, n23)
					local v82 = table.pack(bit32.band(bit32.bor(n15, 57233876), 4294967295))
					local v83 = table.pack(bit32.band(v82[1], 65535))
					local v84 = bit32.band(65160 * v83[1] + bit32.lshift(bit32.band(65160 * bit32.rshift(v82[1], 16) + 60526 * v83[1], 65535), 16), 4294967295)
					local v85 = table.pack(bit32.band(bit32.band(n15, 57233876), 4294967295))
					local v86 = table.pack(bit32.band(v85[1], 65535))
					local n24 = v81 + 455967028 + v84 + bit32.band(65158 * v86[1] + bit32.lshift(bit32.band(65158 * bit32.rshift(v85[1], 16) + 60526 * v86[1], 65535), 16), 4294967295)
					targetColor = color2(100, 180, 255)
					local v87 = bit32.band(n23 * 5, 3017393609)
					n15 = bit32.bxor(n24, 57233876)
					n23 = v87 + 221486292
				end

				local textSize = nameEsp["Text Size"] or 13
				local enabled4 = silentAim.Enabled

				if enabled4 then
					enabled4 = fn().Main["Silent Aim"].Selection == "Target"
					n22 = bit32.rshift(n22, 28) - 4065059628
				end

				local v79 = next
				local n24 = n23 - 104603642
				local players, v80 = Players:GetPlayers()

				for _, v81 in v79, players, v80 do
					if v81 ~= localPlayer then
						local character = v81.Character

						if not character then
							if NameESPDrawings[v81] then
								local v82 = NameESPDrawings[v81]
								local v83 = bit32.bxor(n15, 403873612)
								v82.Visible = false
								n15 = bit32.bxor(v83, 403873612)
							end
						else
							local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

							if not humanoidRootPart then
								if NameESPDrawings[v81] then
									NameESPDrawings[v81].Visible = false
								end
							else
								local v82, v83 = currentCamera2:WorldToViewportPoint(humanoidRootPart.Position - Vector3New(0, 3, 0))

								if not v83 then
									if NameESPDrawings[v81] then
										NameESPDrawings[v81].Visible = false
									end
								else
									if not NameESPDrawings[v81] then
										local v84 = CreateTextLabel()
										v84.Outline = true
										v84.Center = true
										NameESPDrawings[v81] = v84
									end

									local v84 = NameESPDrawings[v81]
									local flag8 = v81 == State.Targets.Silent or v81 == State.Targets.Aimbot

									if not flag8 then
										flag8 = not enabled4

										if flag8 then
											flag8 = v81 == State.Targets.Triggerbot
											n15 = bit32.bxor(bit32.bxor(n15, 322445269), 322445269)
										end
									end

									v84.Text = v81.DisplayName
									v84.Size = textSize
									v84.Color = flag8 and targetColor or color
									local v85 = MathFloor
									local n25 = v82.Y + 0.5
									v84.Position = Vector2New(MathFloor(v82.X + 0.5), v85(n25))
									v84.Visible = true
								end
							end
						end
					end
				end

				n23 = n24 - 4190363654
			else
				for _, v79 in next, NameESPDrawings, nil do
					v79.Visible = false
				end
			end

			local healthBar = fn()["Health Bar"]

			if healthBar and healthBar.Enabled then
				local position = healthBar.Position or "Bottom"
				local v79 = bit32.rshift(n22, 27)
				local showArmor = healthBar["Show Armor"]
				local healthColor = healthBar["Health Color"]

				if not healthColor then
					healthColor = Color3.fromRGB(85, 255, 255)
					n23 = n23
				end

				local armorColor = healthBar["Armor Color"] or Color3.fromRGB(120, 185, 255)
				local n24 = v79 * 100
				local silent3 = State.Targets.Silent or State.Targets.Aimbot

				if not silent3 then
					local targets = State.Targets
					local v80 = bit32.bor(n24, 3523930381)
					silent3 = targets.Triggerbot
					n15 = bit32.bxor(bit32.bxor(n15, 47364863), 47364863)
					n24 = bit32.bxor(v80, 3523930377)
				end

				local n25 = n24

				for k, v80 in next, HealthBarDrawings, nil do
					if k ~= silent3 then
						HideHealthBarSet(v80)
					end
				end

				local character = silent3 and silent3.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				character = character and character:FindFirstChildOfClass("Humanoid")

				if silent3 and humanoidRootPart and character then
					local v80, v81 = currentCamera2:WorldToViewportPoint(humanoidRootPart.Position + Vector3New(0, 3, 0))
					local n26 = n24 // n25
					local v82, v83 = currentCamera2:WorldToViewportPoint(humanoidRootPart.Position - Vector3New(0, 3.5, 0))

					if v81 or v83 then
						if not HealthBarDrawings[silent3] then
							local tbl11 = {}

							for _, v84 in next, { "HealthBack", "HealthFill", "ArmorBack", "ArmorFill" }, nil do
								local v85 = CreateSquare()
								v85.Filled = true
								v85.Visible = false
								tbl11[v84] = v85
							end

							HealthBarDrawings[silent3] = tbl11
							n25 = n25 - n26 + 1
						end

						local v84 = HealthBarDrawings[silent3]
						local v85 = GetStableHealthBarValues
						local v86 = bit32.bxor(n15, 0)
						local v87 = bit32.bxor(n25, v86)
						local v88, v89, v90, v91 = v85(silent3, character)
						local v92 = MathClamp(v88 / v89, 0, 1)
						local n27 = n26 * 58815
						local v93 = MathClamp(v90 / 100, 0, 1)
						showArmor = showArmor and v90 > 0
						v84.HealthBack.Color = Color3.fromRGB(8, 8, 12)
						local healthFill = v84.HealthFill
						local v94 = table.pack(bit32.band(n27, 4294967295))
						local v95 = table.pack(bit32.band(v87, 4294967295))
						local v96 = table.pack(bit32.band(v94[1], 65535))
						local v97 = table.pack(bit32.rshift(v94[1], 16))
						local v98 = table.pack(bit32.band(v95[1], 65535))
						local v99 = bit32.band(v96[1] * v98[1] + bit32.lshift(bit32.band(v96[1] * bit32.rshift(v95[1], 16) + v97[1] * v98[1], 65535), 16), 4294967295)
						healthFill.Color = healthColor
						local n28 = v99 // 3
						v84.ArmorBack.Color = Color3.fromRGB(8, 8, 12)
						v84.ArmorFill.Color = armorColor
						local v100 = bit32.bxor(n15, 448604385)
						local n29 = v87 * 14 // 14
						local n30 = (v80.X + v82.X) / 2
						local nameEsp2 = fn()["Name ESP"]
						local textSize = nameEsp2["Text Size"] or 13
						local n31 = n28 - bit32.bxor(v100, 0)
						local v101 = MathFloor(n30 - 34 + 0.5)
						local v102 = MathMax
						local y2 = v80.Y
						local y3 = v82.Y
						local v103 = bit32.bxor(v100, 0)
						local v104 = table.pack(bit32.band(n29, 4294967295))
						local v105 = table.pack(bit32.band(v103, 4294967295))
						local v106 = table.pack(bit32.band(v104[1], 65535))
						local v107 = table.pack(bit32.rshift(v104[1], 16))
						local v108 = table.pack(bit32.band(v105[1], 65535))
						local v109 = bit32.band(v106[1] * v108[1] + bit32.lshift(bit32.band(v106[1] * bit32.rshift(v105[1], 16) + v107[1] * v108[1], 65535), 16), 4294967295)
						local v110 = v102(y2, y3)
						local v111 = v109
						local v112

						if position == "Top" then
							local v113 = MathFloor
							local v114 = MathMin
							local y4 = v80.Y
							local v115 = bit32.bxor(v100, 98825348)
							v112 = v113(v114(y4, v82.Y) - 4 - 4 + 0.5)
							v100 = bit32.bxor(v115, 98825348)
							v109 = bit32.bxor(v109 // 241, 3222909159)
						else
							v111 = v109

							if nameEsp2.Enabled then
								local v113 = NameESPDrawings[silent3]
								local y4 = v113 and v113.Position.Y or v110
								local y5 = v113 and v113.TextBounds.Y or textSize
								local v114 = MathFloor
								local n32 = y4 + MathMax(y5, textSize)
								local v115 = bit32.bxor(v109, 4294967295)
								v112 = v114(n32 + 2 + 0.5)
								v109 = bit32.bxor(v115, 4294967295)
							else
								local v113 = MathFloor
								local n32 = v111 // bit32.bxor(v100, 0)
								v112 = v113(v110 + 3 + 0.5)
								v111 = bit32.bxor(n32, 3235210496)
							end
						end

						local n32 = v112 + 2 + 2 + 1
						local n33 = n32 + 1
						local healthBack = v84.HealthBack
						local v113 = bit32.bxor(v100, 0)
						local v114 = bit32.bxor(v109, v113)
						healthBack.Size = Vector2New(68, 4)
						local healthBack2 = v84.HealthBack
						local v115 = Vector2New
						local v116 = bit32.band(v114, v111)
						healthBack2.Position = v115(v101, v112)
						local healthFill2 = v84.HealthFill
						local v117 = bit32.band(v111, v116)
						healthFill2.Size = Vector2New(MathFloor(66 * v92 + 0.5), 2)
						local healthFill3 = v84.HealthFill
						local v118 = Vector2New
						local v119 = bit32.bxor(v100, 160868591)
						healthFill3.Position = v118(v101 + 1, v112 + 1)
						v84.ArmorBack.Size = Vector2New(68, 4)
						v84.ArmorBack.Position = Vector2New(v101, n32)
						local armorFill = v84.ArmorFill
						local v120 = Vector2New
						local v121 = MathFloor
						local v122 = table.pack(bit32.band(v117 - 1979434434, 4294967295))
						local v123 = table.pack(bit32.band(v116, 4294967295))
						local v124 = table.pack(bit32.band(v122[1], 65535))
						local v125 = table.pack(bit32.rshift(v122[1], 16))
						local v126 = table.pack(bit32.band(v123[1], 65535))
						local v127 = bit32.band(v124[1] * v126[1] + bit32.lshift(bit32.band(v124[1] * bit32.rshift(v123[1], 16) + v125[1] * v126[1], 65535), 16), 4294967295)
						armorFill.Size = v120(v121(66 * v93 + 0.5), 2)
						local armorFill2 = v84.ArmorFill
						local v128 = Vector2New
						local n34 = v116 // bit32.bxor(v119, 0)
						armorFill2.Position = v128(v101 + 1, n33)
						local visible = v92 > 0 and not v91
						v84.HealthBack.Visible = visible
						local v129 = bit32.bxor(v119, 0)
						local v130 = bit32.band(n34, v129)
						v84.HealthFill.Visible = visible
						local armorBack = v84.ArmorBack
						local v131 = bit32.lshift(v127, 4)
						armorBack.Visible = showArmor and not v91
						local armorFill3 = v84.ArmorFill

						if showArmor then
							showArmor = v93 > 0
							v119 = bit32.bxor(bit32.bxor(v119, 381697553), 381697553)
							v130 = bit32.bxor(v130 + 1504959477, 1504959479)
						end

						armorFill3.Visible = showArmor and not v91
						n15 = bit32.bxor(v119, 321617934)
						n25 = bit32.bxor(v130, 101)
						n26 = bit32.bxor(v131, 4025188353)
					else
						HideHealthBarSet(HealthBarDrawings[silent3])
					end

					n24 = n26 - 4294967197
				end

				n23 = n25 + 229907568
				n22 = n24 + 229907568
			else
				for _, v79 in next, HealthBarDrawings, nil do
					HideHealthBarSet(v79)
				end
			end

			local n24 = n23 // 233
			local brand = fn().Main.Brand
			local n25

			if brand.Enabled then
				local accent = brand.Accent

				if not accent then
					local color = Color3.fromRGB
					local v79 = bit32.rshift(n22, 28)
					accent = color(100, 180, 255)
					n22 = bit32.bxor(v79, 229907668)
				end

				local viewportSize = currentCamera2.ViewportSize
				local x2 = viewportSize.X
				local n26 = n22 // bit32.bxor(n15, 0)
				local y2 = viewportSize.Y
				local v79 = MathClamp
				local v80 = MathMin(x2 / 1920, y2 / 1080)
				local v81 = bit32.band(n24, 1187952071)
				local v82 = v79(v80, 0.55, 1.35)
				local v83 = MathFloor(15 * v82 + 0.5)
				local v84 = MathFloor(12 * v82 + 0.5)
				local v85 = MathFloor(14 * v82 + 0.5)
				local n27 = v81 * n26
				local v86 = MathFloor(18 * v82 + 0.5)
				local enabled4 = silentAim.Enabled
				enabled4 = enabled4 and State.Toggles.SilentAim and State.Targets.Silent
				local n28 = 0

				if enabled4 then
					local n29 = n27 * 243
					local character = State.Targets.Silent and State.Targets.Silent.Character
					n28 = 1

					if character then
						n28 = 2
					end

					n27 = n29 - 222299264
				end

				if aimbot.Enabled and AimbotTargetLocked then
					n28 += 1
					n15 = bit32.bxor(bit32.bxor(n15, 79028879), 79028879)
					n26 = bit32.bxor(n26 + n27, 918592)
				end

				if triggerbot.Enabled and State.TriggerState and State.Targets.Triggerbot then
					n28 += 1
					n27 = bit32.band(n27, 4193107482) + 131136
				end

				local enabled5 = silentAim.Enabled

				if enabled5 then
					enabled5 = State.Targets.Silent
					n26 = n26 * 251 + 4294967046
				end

				enabled5 = enabled5 and silentAim["Auto Shoot"]
				local v87

				if enabled5 then
					local enabled6 = silentAim["Auto Shoot"].Enabled
					n26 = bit32.bor(n26, n27) + 4294048704
					v87 = enabled6
				else
					v87 = enabled5
				end

				if v87 then
					n28 += 1
				end

				if fn().Movement["Speed Modifications"].Enabled and State.SpeedModificationsActive then
					n28 += 1
				end

				local sorterActive = State.SorterActive
				local v88 = bit32.bxor(n15, 65518243)
				local n29 = n26 + bit32.bxor(n15, 0)
				local v89 = v88

				if sorterActive then
					n28 += 1
				end

				local enabled6 = fn().Modifications["Double Tap"].Enabled

				if enabled6 then
					enabled6 = fn().Modifications["Double Tap"].Mode == "Always"

					if not enabled6 then
						enabled6 = State.DoubleTapActive
						n29 = n29 - 2014134126 + 2014134126
					end
				end

				if enabled6 then
					n28 += 1
				end

				local enabled7 = fn()["Anti Future"].Enabled

				if enabled7 then
					enabled7 = State.AntiFuture.Active
					n27 = bit32.bxor(n27 // bit32.bxor(v89, 0), 918592)
				end

				if enabled7 then
					local v90 = bit32.bxor(v89, 0)
					n28 += 1
					n29 = bit32.bor(n29, v90) + 4229529444
				end

				local enabled8 = fn().Movement["Jump Modifications"].Enabled

				if enabled8 then
					enabled8 = State.JumpModificationsActive
					n27 = bit32.bxor(n27, n29) + 4160652512
				end

				if enabled8 then
					n28 += 1
				end

				local n30 = v86 + n28 * v85
				local v90, v91 = GetBrandHealthBarAnchor(viewportSize)
				local v92 = MathFloor
				local v93 = bit32.band(n27, n29)
				local n31 = v91 - n30 - v92(7 * v82 + 0.5)
				local v94 = MathFloor
				local v95 = PanelTitle
				local v96 = bit32.bxor(v89, 0)
				local v97 = table.pack(bit32.band(n29, 4294967295))
				local v98 = table.pack(bit32.band(v96, 4294967295))
				local v99 = table.pack(bit32.band(v97[1], 65535))
				local v100 = table.pack(bit32.rshift(v97[1], 16))
				local v101 = table.pack(bit32.band(v98[1], 65535))
				local v102 = bit32.band(v99[1] * v101[1] + bit32.lshift(bit32.band(v99[1] * bit32.rshift(v98[1], 16) + v100[1] * v101[1], 65535), 16), 4294967295)
				local v103 = v94(v95.TextBounds.X / 2 + 0.5)
				local v104 = bit32.bxor(v102, 4294967295)
				local v105 = MathClamp(MathFloor(v90 + 0.5), v103 + 4, x2 - v103 - 4)
				local v106 = MathClamp
				local v107 = MathFloor(n31 + 0.5)
				local v108 = bit32.band(v93, v104)
				local v109 = bit32.bxor(v89, 30609071)
				local v110 = v106(v107, 6, y2 - n30 - 6)
				PanelTitle.Size = v83
				local n32 = v108 * bit32.bxor(v109, 0)

				for i = 1, #PanelLabels do
					PanelLabels[i].Size = v84
				end

				local v111 = PanelTitle
				local format = string.format
				local v112 = MathFloor(accent.R * 255 + 0.5)
				local v113 = MathFloor
				local v114 = bit32.band(n32, 3844873276)
				local n33 = v104 - 427099839 - 2049004684
				v111.Text = format("<font color=\"rgb(255, 255, 255)\">cider</font><font color=\"rgb(%d, %d, %d)\">.wtf</font>", v112, v113(accent.G * 255 + 0.5), MathFloor(accent.B * 255 + 0.5))
				local v115 = table.pack(bit32.band(v109, 4294967295))
				local v116 = table.pack(bit32.band(v115[1], 65535))
				local n34 = bit32.band(38175 * v116[1] + bit32.lshift(bit32.band(38175 * bit32.rshift(v115[1], 16) + 33620 * v116[1], 65535), 16), 4294967295) + 4053079584
				local v117 = table.pack(bit32.band(bit32.bor(241887712, v109), 4294967295))
				local v118 = table.pack(bit32.band(v117[1], 65535))
				local v119 = bit32.band(2 * v118[1] + bit32.lshift(bit32.band(2 * bit32.rshift(v117[1], 16) + 0 * v118[1], 65535), 16), 4294967295)
				local n35 = v114 + bit32.bxor(v109, 0)
				local v120 = table.pack(bit32.band(bit32.bnot(v109), 4294967295))
				local v121 = table.pack(bit32.band(v120[1], 65535))
				local n36 = n34 + v119 + 2203358496 + bit32.band(38176 * v121[1] + bit32.lshift(bit32.band(38176 * bit32.rshift(v120[1], 16) + 33620 * v121[1], 65535), 16), 4294967295)
				local v122 = PanelTitle
				local v123 = bit32.bxor(n36, 0)
				local n37 = bit32.bor(n33, v123)
				v122.Position = Vector2New(v105, v110)
				PanelTitle.Visible = true
				local n38 = v110 + v86
				local enabled9 = silentAim.Enabled

				if enabled9 then
					enabled9 = State.Toggles.SilentAim
					n35 = n35 + bit32.bxor(n36, 0) + 4221622541
				end

				if enabled9 then
					enabled9 = State.Targets.Silent
					n37 = n37 + bit32.bxor(n36, 0) - 73344755
				end

				local n39 = 0

				if enabled9 then
					local silent3 = State.Targets.Silent
					local feature = brand.Feature
					local n40 = n35 - 3972927439
					local n41 = n40
					local v124 = PanelLabels[1]

					if v124 then
						local displayName = silent3 and silent3.DisplayName or "none"
						local feature2 = silent3 and accent or brand.Feature
						local v125 = string
						local v126 = bit32.bxor(n37, 4294967295)
						local format2 = v125.format
						local v127 = MathFloor(feature.R * 255 + 0.5)
						local v128 = MathFloor
						local n42 = feature.G * 255
						local v129 = bit32.lshift(n41, 9)
						local v130 = v128(n42 + 0.5)
						local n43 = v129 // v126
						local v131 = MathFloor(feature.B * 255 + 0.5)
						local v132 = MathFloor
						local r = feature2.R
						local v133 = bit32.lshift(v126, 28)
						local v134 = bit32.bxor(n36, 126479552)
						local v135 = v132(r * 255 + 0.5)
						local v136 = MathFloor
						local n44 = feature2.G * 255 + 0.5
						local v137 = table.pack(bit32.band(v133, 4294967295))
						local v138 = table.pack(bit32.band(v137[1], 65535))
						local v139 = bit32.band(v138[1] * 15242 + bit32.lshift(bit32.band(v138[1] * 0 + bit32.rshift(v137[1], 16) * 15242, 65535), 16), 4294967295)
						v124.Text = format2("<font color=\"rgb(%d, %d, %d)\">silent aim</font> <font color=\"rgb(%d, %d, %d)\">&gt; %s</font>", v127, v130, v131, v135, v136(n44), MathFloor(feature2.B * 255 + 0.5), displayName)
						local v140 = bit32.bxor(v134, 243962438)
						local v141 = bit32.bxor(v140, 0)
						local v142 = bit32.band(n43, v141)
						v124.Color = Color3.new(1, 1, 1)
						v124.Position = Vector2New(v105, n38)
						v124.Visible = true
						n38 += v85
						n36 = bit32.bxor(v140, 151223942)
						n40 = bit32.bxor(v142, 493338437)
						n41 = n40
						n37 = v139 + 1736614388 + 123510275
					end

					local character

					if silent3 then
						character = silent3.Character
						n37 = n37 - bit32.bxor(n36, 0) - 4221622541
					else
						character = silent3
					end

					n39 = 1

					if character then
						local v125 = PanelLabels[2]

						if v125 then
							local humanoid = silent3.Character:FindFirstChildOfClass("Humanoid")
							local n42 = 0

							if humanoid then
								local v126 = MathFloor
								local n43 = humanoid.Health + 0.5
								local v127 = bit32.rshift(n41, 28)
								n42 = v126(n43)
								n41 = v127 + 493338435
							end

							local bodyEffects = silent3.Character:FindFirstChild("BodyEffects")
							local n43 = 0

							if bodyEffects then
								local armor = bodyEffects:FindFirstChild("Armor") or bodyEffects:FindFirstChild("Armour") or bodyEffects:FindFirstChild("Defense")
								local flag8 = armor and armor.Value and armor.Value > 0
								local n44 = 0

								if flag8 then
									local v126 = MathFloor(armor.Value + 0.5)
									n41 = n41 // 192 - 3804198331
									n43 = v126
								else
									n43 = n44
								end
							end

							if n43 == 0 and silent3 then
								local leaderstats = silent3:FindFirstChild("leaderstats")

								if leaderstats then
									local armor = leaderstats:FindFirstChild("Armor")

									if not armor then
										armor = leaderstats:FindFirstChild("Armour")
										local v126 = bit32.bxor(n36, 0)
										local v127 = table.pack(bit32.band(n37, 4294967295))
										local v128 = table.pack(bit32.band(v126, 4294967295))
										local v129 = table.pack(bit32.band(v127[1], 65535))
										local v130 = table.pack(bit32.rshift(v127[1], 16))
										local v131 = table.pack(bit32.band(v128[1], 65535))
										n37 = bit32.band(v129[1] * v131[1] + bit32.lshift(bit32.band(v129[1] * bit32.rshift(v128[1], 16) + v130[1] * v131[1], 65535), 16), 4294967295) - 2335318398
									end

									armor = armor or leaderstats:FindFirstChild("Defense") or leaderstats:FindFirstChild("Vest")

									if armor and armor.Value then
										n43 = MathFloor(armor.Value + 0.5)
										n37 = bit32.bxor(n41, 1941471411)
									end
								end
							end

							local v126 = string
							local v127 = bit32.bxor(n41, 3125976901)
							local v128 = bit32.bxor(n36, 254616257)
							local format2 = v126.format
							local v129 = MathFloor
							local r = feature.R
							local v130 = table.pack(bit32.band(v127, 4294967295))
							local v131 = table.pack(bit32.band(v130[1], 65535))
							local v132 = bit32.band(v131[1] * 6903 + bit32.lshift(bit32.band(v131[1] * 0 + bit32.rshift(v130[1], 16) * 6903, 65535), 16), 4294967295)
							local v133 = format2("<font color=\"rgb(%d, %d, %d)\">health</font> <font color=\"rgb(85, 255, 85)\">&gt; %d</font>", v129(r * 255 + 0.5), MathFloor(feature.G * 255 + 0.5), MathFloor(feature.B * 255 + 0.5), n42)
							local v134

							if n43 > 0 then
								local str = v133 .. string.format(" / <font color=\"rgb(85, 170, 255)\">%d</font>", n43)
								n37 = bit32.lshift(n37, 12) + 2061488119
								v134 = str
							else
								v134 = v133
							end

							v125.Text = v134
							local v135 = bit32.bxor(v132, 4294967295)
							v125.Color = Color3.new(1, 1, 1)
							local v136 = Vector2New(v105, n38)
							local v137 = bit32.bxor(v128, 0)
							local v138 = table.pack(bit32.band(n37, 4294967295))
							local v139 = table.pack(bit32.band(v137, 4294967295))
							local v140 = table.pack(bit32.band(v138[1], 65535))
							local v141 = table.pack(bit32.rshift(v138[1], 16))
							local v142 = table.pack(bit32.band(v139[1], 65535))
							local v143 = bit32.band(v140[1] * v142[1] + bit32.lshift(bit32.band(v140[1] * bit32.rshift(v139[1], 16) + v141[1] * v142[1], 65535), 16), 4294967295)
							v125.Position = v136
							v125.Visible = true
							n38 += v85
							n36 = bit32.bxor(v128, 254616257)
							n41 = bit32.bxor(v135, 1528412748)
							n37 = bit32.bxor(v143, 1397188041)
						end

						n39 = 2
					end

					n35 = bit32.bxor(n41, 391278679)
				end

				if aimbot.Enabled and AimbotTargetLocked then
					n39 += 1
					local v124 = PanelLabels[n39]

					if v124 then
						local v125 = State
						local v126 = bit32.band(n35, 3313618198)
						local aimbot4 = v125.Targets.Aimbot
						local displayName = aimbot4 and aimbot4.DisplayName or "none"
						local feature = brand.Feature
						local feature2 = aimbot4 and accent or brand.Feature
						local v127 = string
						local v128 = bit32.band(n37, 3215200841)
						local format2 = v127.format
						local v129 = bit32.bor(v126, 430984308)
						local v130 = MathFloor(feature.R * 255 + 0.5)
						local v131 = bit32.bxor(n36, 0)
						local v132 = bit32.bxor(v129, v131)
						local v133 = MathFloor(feature.G * 255 + 0.5)
						local n40 = v128 - v132
						local v134 = MathFloor(feature.B * 255 + 0.5)
						local v135 = MathFloor
						local n41 = feature2.R * 255
						local n42 = bit32.bxor(n36, 373157225) + 1142592543 + 3152374753
						local bor = bit32.bor
						local v136 = bit32.bxor(n36, 0)
						local v137 = bor(n40, v136)
						local n43 = (v132 - n40) // 7
						v124.Text = format2("<font color=\"rgb(%d, %d, %d)\">aimbot</font> <font color=\"rgb(%d, %d, %d)\">&gt; %s</font>", v130, v133, v134, v135(n41 + 0.5), MathFloor(feature2.G * 255 + 0.5), MathFloor(feature2.B * 255 + 0.5), displayName)
						local v138 = Color3
						local n44 = v137 // n43 // bit32.bxor(n42, 0)
						v124.Color = Color3.new(1, 1, 1)
						v124.Position = Vector2New(v105, n38)
						v124.Visible = true
						n38 += v85
						n36 = bit32.bxor(n42, 373157225)
						n35 = n43 // 91 - 4124020344
						n37 = n44 + 1860124663
					end
				end

				if triggerbot.Enabled and State.TriggerState and State.Targets.Triggerbot then
					n39 += 1
					local v124 = PanelLabels
					local n40 = bit32.bxor(n36, 0)
					local v125 = v124[n39]

					if v125 then
						local triggerbot4 = State.Targets.Triggerbot
						local n41 = n37 + n40
						local v126 = bit32.bxor(n36, 469506943)
						local displayName = triggerbot4 and triggerbot4.DisplayName or "none"
						local feature = brand.Feature
						local v127 = bit32.bxor(v126, 0)
						local v128 = bit32.band(n41, v127)
						local feature2 = triggerbot4 and accent or brand.Feature
						local format2 = string.format
						local v129 = MathFloor
						local n42 = feature.R * 255
						local v130 = bit32.bxor(v126, 0)
						local v131 = v129(n42 + 0.5)
						local v132 = MathFloor
						local n43 = feature.G * 255
						local v133 = bit32.rshift(v130, 7)
						local v134 = v132(n43 + 0.5)
						local v135 = MathFloor(feature.B * 255 + 0.5)
						local v136 = MathFloor
						local n44 = feature2.R * 255 + 0.5
						local n45 = v128 // 53 - bit32.bxor(v126, 0)
						local v137 = bit32.bxor(v126, 525847107)
						local v138 = v136(n44)
						local v139 = MathFloor
						local n46 = feature2.G * 255
						local v140 = bit32.bxor(v133, 4294967295)
						local v141 = format2("<font color=\"rgb(%d, %d, %d)\">triggerbot</font> <font color=\"rgb(%d, %d, %d)\">&gt; %s</font>", v131, v134, v135, v138, v139(n46 + 0.5), MathFloor(feature2.B * 255 + 0.5), displayName)
						local n47 = v140 + bit32.bxor(v137, 0)
						v125.Text = v141
						v125.Color = Color3.new(1, 1, 1)
						v125.Position = Vector2New(v105, n38)
						v125.Visible = true
						n38 += v85
						n36 = bit32.bxor(v137, 78369084)
						n40 = n47 - 4233529952
						n37 = n45 - 1910107505
					end

					n35 = n40 - 4197013472
				end

				local enabled10 = silentAim.Enabled
				local v124

				if enabled10 then
					local silent3 = State.Targets.Silent
					n37 = bit32.bxor(n36, 0) + 1786779908
					v124 = silent3
				else
					v124 = enabled10
				end

				if v124 and silentAim["Auto Shoot"] and silentAim["Auto Shoot"].Enabled then
					n39 += 1
					local v125 = PanelLabels[n39]

					if v125 then
						local feature = brand.Feature
						local v126 = string.lower(State.AutoShootStatus or "idle")
						local v127 = bit32.bxor(n36, 265504393)
						local format2 = string.format
						local v128 = MathFloor
						local r = feature.R
						local v129 = bit32.bxor(bit32.bxor(v127, 0), 4294967295)
						local v130 = v128(r * 255 + 0.5)
						local v131 = MathFloor(feature.G * 255 + 0.5)
						local v132 = MathFloor
						local v133 = bit32.band(n37, v129)
						local v134 = v132(feature.B * 255 + 0.5)
						local v135 = v133
						local v136 = MathFloor(accent.R * 255 + 0.5)
						local v137 = MathFloor(accent.G * 255 + 0.5)
						local v138 = MathFloor
						local b = accent.B
						local n40 = bit32.bor(v133, v135) + bit32.bxor(v127, 0)
						local v139 = v138(b * 255 + 0.5)
						local v140 = table.pack(bit32.band(v127, 4294967295))
						local v141 = table.pack(bit32.band(v140[1], 65535))
						local n41 = 3078252685 + bit32.band(0 * v141[1] + bit32.lshift(bit32.band(0 * bit32.rshift(v140[1], 16) + 32768 * v141[1], 65535), 16), 4294967295)
						local v142 = bit32.bxor(v127, 84952828)
						local n42 = v135 + bit32.bxor(v127, 0)
						local v143 = table.pack(bit32.band(bit32.bnot(v142), 4294967295))
						local v144 = table.pack(bit32.band(v143[1], 65535))
						local v145 = bit32.band(65535 * v144[1] + bit32.lshift(bit32.band(65535 * bit32.rshift(v143[1], 16) + 32767 * v144[1], 65535), 16), 4294967295)
						local v146 = bit32.bxor(v127, 0)
						local v147 = table.pack(bit32.band(n42, 4294967295))
						local v148 = table.pack(bit32.band(v146, 4294967295))
						local v149 = table.pack(bit32.band(v147[1], 65535))
						local v150 = table.pack(bit32.rshift(v147[1], 16))
						local v151 = table.pack(bit32.band(v148[1], 65535))
						local v152 = bit32.band(v149[1] * v151[1] + bit32.lshift(bit32.band(v149[1] * bit32.rshift(v148[1], 16) + v150[1] * v151[1], 65535), 16), 4294967295)
						v125.Text = format2("<font color=\"rgb(%d, %d, %d)\">auto shoot</font> <font color=\"rgb(%d, %d, %d)\">&gt; %s</font>", v130, v131, v134, v136, v137, v139, v126)
						v125.Color = Color3.new(1, 1, 1)
						v125.Position = Vector2New(v105, n38)
						v125.Visible = true
						n38 += v85
						n36 = bit32.bxor(n41 + 1677049800 + v145 + 1687148458, 180551797)
						n35 = v152 - 2148722729 - 2326653002
						n37 = n40 // 232 - 2442932797
					end
				end

				if fn().Movement["Speed Modifications"].Enabled and State.SpeedModificationsActive then
					local v125 = bit32.bxor(n36, 0)
					local n40 = bit32.band(n37, v125)
					n39 += 1
					local v126 = PanelLabels[n39]

					if v126 then
						local v127 = bit32.bor(n35, 1335607273)
						local feature = brand.Feature
						local format2 = string.format
						local v128 = MathFloor
						local r = feature.R
						local v129 = bit32.bxor(n40, 4294967295)
						local v130 = v128(r * 255 + 0.5)
						local v131 = MathFloor(feature.G * 255 + 0.5)
						local v132 = MathFloor
						local n41 = v127 - bit32.bxor(n36, 0)
						v126.Text = format2("<font color=\"rgb(%d, %d, %d)\">speed</font>", v130, v131, v132(feature.B * 255 + 0.5))
						local v133 = bit32.bor(v129, n41)
						v126.Color = Color3.new(1, 1, 1)
						local v134 = Vector2New
						local v135 = v133
						local v136 = bit32.bxor(n36, 0)
						local v137 = table.pack(bit32.band(v135, 4294967295))
						local v138 = table.pack(bit32.band(v136, 4294967295))
						local v139 = table.pack(bit32.band(v137[1], 65535))
						local v140 = table.pack(bit32.rshift(v137[1], 16))
						local v141 = table.pack(bit32.band(v138[1], 65535))
						local v142 = bit32.band(v139[1] * v141[1] + bit32.lshift(bit32.band(v139[1] * bit32.rshift(v138[1], 16) + v140[1] * v141[1], 65535), 16), 4294967295)
						v126.Position = v134(v105, n38)
						v126.Visible = true
						n38 += v85
						n35 = n41 + 3201627659
						n40 = v142 + 3527760015
					end

					n37 = n40 - 2508187388
				end

				local v125 = State
				local n40 = n35 + bit32.bxor(n36, 0)

				if v125.SorterActive then
					n39 += 1
					local v126 = PanelLabels[n39]

					if v126 then
						local feature = brand.Feature
						local format2 = string.format
						local n41 = n40 + n37
						local v127 = MathFloor(feature.R * 255 + 0.5)
						local v128 = MathFloor
						local v129 = bit32.bxor(n37, n41)
						local g = feature.G
						local v130 = bit32.bxor(n36, 152755035)
						local v131 = v128(g * 255 + 0.5)
						local v132 = MathFloor
						local b = feature.B
						local v133 = bit32.bor(n41, 2560329988)
						local v134 = v132(b * 255 + 0.5)
						local v135 = MathFloor
						local n42 = accent.R * 255 + 0.5
						local n43 = v129 + bit32.bxor(v130, 0)
						local v136 = v135(n42)
						local v137 = MathFloor
						local n44 = accent.G * 255 + 0.5
						local v138 = bit32.band(v133, n43)
						local v139 = v137(n44)
						local v140 = MathFloor
						local b2 = accent.B
						local v141 = bit32.rshift(n43, 21)
						local v142 = bit32.bxor(v130, 171124783)
						v126.Text = format2("<font color=\"rgb(%d, %d, %d)\">sorter</font> <font color=\"rgb(%d, %d, %d)\">&gt; active</font>", v127, v131, v134, v136, v139, v140(b2 * 255 + 0.5))
						local v143 = bit32.lshift(v141, 22)
						v126.Color = Color3.new(1, 1, 1)
						v126.Position = Vector2New(v105, n38)
						v126.Visible = true
						n38 += v85
						local v144 = bit32.bxor(v138, v143)
						n36 = bit32.bxor(v142, 53080948)
						n40 = v144 - 1385959338
						n37 = v143 + 757022711
					end
				end

				local modifications = fn().Modifications
				local v126 = table.pack(bit32.band(n40, 4294967295))
				local v127 = table.pack(bit32.band(v126[1], 65535))
				local n41 = bit32.band(v127[1] * 31522 + bit32.lshift(bit32.band(v127[1] * 0 + bit32.rshift(v126[1], 16) * 31522, 65535), 16), 4294967295)
				local enabled11 = modifications["Double Tap"].Enabled

				if enabled11 then
					local modifications2 = fn().Modifications
					local v128 = bit32.band(n37, 837533858)
					enabled11 = modifications2["Double Tap"].Mode == "Always" or State.DoubleTapActive
					n37 = v128 + 1309949781
				end

				if enabled11 then
					n39 += 1
					local v128 = PanelLabels[n39]

					if v128 then
						local feature = brand.Feature
						local format2 = string.format
						local v129 = MathFloor
						local n42 = feature.R * 255 + 0.5
						local n43 = n37 + bit32.bxor(n36, 0)
						local v130 = v129(n42)
						local v131 = MathFloor(feature.G * 255 + 0.5)
						local v132 = MathFloor
						local v133 = bit32.bxor(n43, 4294967295)
						local v134 = v132(feature.B * 255 + 0.5)
						local v135 = MathFloor(accent.R * 255 + 0.5)
						local v136 = MathFloor
						local v137 = bit32.bxor(n36, 0)
						local v138 = bit32.bor(v133, v137)
						v128.Text = format2("<font color=\"rgb(%d, %d, %d)\">double tap</font> <font color=\"rgb(%d, %d, %d)\">&gt; active</font>", v130, v131, v134, v135, v136(accent.G * 255 + 0.5), MathFloor(accent.B * 255 + 0.5))
						v128.Color = Color3.new(1, 1, 1)
						local n44 = (n41 + 2638707411) // v133 * 12 // 14
						local v139 = bit32.bxor(n36, 11800817)
						v128.Position = Vector2New(v105, n38)
						v128.Visible = true
						n38 += v85
						local v140 = bit32.bor(v138, n44)
						n36 = bit32.bxor(v139, 11800817)
						n41 = n44 - 2114089268
						n37 = bit32.bxor(v140, 3791683584)
					end
				end

				local enabled12 = fn()["Anti Future"].Enabled

				if enabled12 then
					local v128 = State
					local v129 = table.pack(bit32.band(n37, 4294967295))
					local v130 = table.pack(bit32.band(n41, 4294967295))
					local v131 = table.pack(bit32.band(v129[1], 65535))
					local v132 = table.pack(bit32.rshift(v129[1], 16))
					local v133 = table.pack(bit32.band(v130[1], 65535))
					enabled12 = v128.AntiFuture.Active
					n37 = bit32.band(v131[1] * v133[1] + bit32.lshift(bit32.band(v131[1] * bit32.rshift(v130[1], 16) + v132[1] * v133[1], 65535), 16), 4294967295) + 2439136547
				end

				if enabled12 then
					n39 += 1
					local v128 = PanelLabels[n39]

					if v128 then
						local feature = brand.Feature
						local v129 = fn
						local v130 = bit32.bxor(n41, 4294967295)
						local v131 = bit32.bxor(n36, 111442524)
						local antiFuture = v129()["Anti Future"]
						local v132 = bit32.band(v130, 1016920464)
						local options3 = antiFuture.Options or {}
						local strength = options3.Strength or 400
						local str = options3["Air Only"] and " (air)"

						if not str then
							n37 = n37 // 154 + 1848045932
							str = ""
						end

						local format2 = string.format
						local v133 = MathFloor
						local n42 = feature.R * 255 + 0.5
						local v134 = bit32.band(n37, 3148466608)
						local v135 = v133(n42)
						local n43 = v132 * 3
						local v136 = MathFloor(feature.G * 255 + 0.5)
						local v137 = MathFloor(feature.B * 255 + 0.5)
						local v138 = table.pack(bit32.band(v134, 4294967295))
						local v139 = table.pack(bit32.band(n43, 4294967295))
						local v140 = table.pack(bit32.band(v138[1], 65535))
						local v141 = table.pack(bit32.rshift(v138[1], 16))
						local v142 = table.pack(bit32.band(v139[1], 65535))
						local v143 = bit32.band(v140[1] * v142[1] + bit32.lshift(bit32.band(v140[1] * bit32.rshift(v139[1], 16) + v141[1] * v142[1], 65535), 16), 4294967295)
						local v144 = MathFloor(accent.R * 255 + 0.5)
						local n44 = n43 + v143
						local v145 = MathFloor(accent.G * 255 + 0.5)
						local v146 = MathFloor
						local v147 = bit32.bor(v143, n44)
						v128.Text = format2("<font color=\"rgb(%d, %d, %d)\">anti future</font> <font color=\"rgb(%d, %d, %d)\">&gt; %d%s</font>", v135, v136, v137, v144, v145, v146(accent.B * 255 + 0.5), strength, str)
						v128.Color = Color3.new(1, 1, 1)
						local v148 = bit32.bxor(n44, v147)
						v128.Position = Vector2New(v105, n38)
						local v149 = bit32.bxor(v131, 0)
						local v150 = bit32.band(v147, v149)
						v128.Visible = true
						n38 += v85
						n36 = bit32.bxor(v131, 111442524)
						n41 = v148 + 1912393164
						n37 = bit32.bxor(v150, 1851550679)
					end
				end

				local movement = fn().Movement
				n25 = bit32.rshift(n41, 30)

				if movement["Jump Modifications"].Enabled and State.JumpModificationsActive then
					n39 += 1
					local v128 = PanelLabels[n39]

					if v128 then
						local v129 = bit32.bxor(n36, 129513969)
						local v130 = bit32.bxor(n37, 4294967295)
						local feature = brand.Feature
						local format2 = string.format
						local v131 = MathFloor(feature.R * 255 + 0.5)
						local v132 = MathFloor
						local g = feature.G
						local v133 = bit32.bor(n25 * 41965, v130)
						local v134 = v132(g * 255 + 0.5)
						local v135 = MathFloor
						local b = feature.B
						local v136 = bit32.band(v130, 2639017387)
						v128.Text = format2("<font color=\"rgb(%d, %d, %d)\">jump</font>", v131, v134, v135(b * 255 + 0.5))
						v128.Color = Color3.new(1, 1, 1)
						v128.Position = Vector2New(v105, n38)
						local v137 = bit32.bxor(v129, 99716570)
						local v138 = table.pack(bit32.band(v136, 4294967295))
						local v139 = table.pack(bit32.band(v138[1], 65535))
						local v140 = bit32.band(v139[1] * 62137 + bit32.lshift(bit32.band(v139[1] * 0 + bit32.rshift(v138[1], 16) * 62137, 65535), 16), 4294967295)
						v128.Visible = true
						n36 = bit32.bxor(v137, 38384683)
						n25 = bit32.bxor(v133 // 106, 22970848)
						n37 = v140 + 2782374447
					end
				end

				for i = n39 + 1, #PanelLabels do
					PanelLabels[i].Visible = false
				end

				local v128 = bit32.bxor(n37, 4294967295)
				n15 = bit32.bxor(n36, 207511020)
				n22 = v128 - 2204934964
			else
				local v79 = PanelTitle
				local v80 = bit32.rshift(n24, 1)
				v79.Visible = false

				for _, v81 in next, PanelLabels, nil do
					v81.Visible = false
				end

				n25 = v80 - 493362
			end

			local active = State.AntiFuture.Active
			local visualizeServer = fn()["Anti Future"]["Visualize Server"]
			local v79 = State
			local v80 = bit32.bxor(n15, 0)
			local n26 = bit32.bxor(n22, v80)
			local lastServerPosition = v79.AntiFuture.LastServerPosition
			local n27 = n25 // n26
			local lastSpoofedVelocity = State.AntiFuture.LastSpoofedVelocity
			local lastSpoofTime = State.AntiFuture.LastSpoofTime
			local flag8 = active and visualizeServer

			if flag8 then
				flag8 = lastServerPosition ~= nil
				n27 *= n26
			end

			if flag8 then
				local character = localPlayer.Character

				if character then
					character = localPlayer.Character:FindFirstChild("HumanoidRootPart")
					n26 = n26 // 104 + 94853757
				end

				local flag9 = lastSpoofedVelocity ~= nil

				if flag9 then
					flag9 = lastSpoofTime ~= nil
					n15 = bit32.bxor(bit32.bxor(n15, 159557589), 159557589)
				end

				if flag9 then
					lastServerPosition += lastSpoofedVelocity * MathClamp(Clock() - lastSpoofTime, 0, 0.05)
				end

				local v81, v82 = currentCamera2:WorldToViewportPoint(lastServerPosition)
				local v83, n28

				if v82 and v81.Z > 0.5 then
					local x2 = v81.X
					local v84 = n26
					local y2 = v81.Y

					if character then
						character = MathFloor((lastServerPosition - character.Position).Magnitude + 0.5)
						v84 = bit32.bxor(v84 // 3, 72500562)
					end

					character = character or 0
					local v85 = AntiFutureVisDot
					local n29 = n26 // bit32.bxor(n15, 0)
					v85.Size = Vector2New(8, 8)
					AntiFutureVisDot.Position = Vector2New(x2 - 4, y2 - 4)
					local n30 = n29 + bit32.bxor(n15, 0)
					AntiFutureVisDot.Color = Color3.fromRGB(255, 80, 80)
					AntiFutureVisDot.Visible = true
					local v86 = AntiFutureVisLabel
					local v87 = string
					local v88 = bit32.bxor(n15, 0)
					v83 = bit32.bor(v84 + 1277009946, v88)
					v86.Text = v87.format("<font color=\"rgb(255,80,80)\">server</font> <font color=\"rgb(150,150,150)\">%d studs</font>", character)
					AntiFutureVisLabel.Position = Vector2New(x2, y2 + 8 + 6)
					n28 = n30 + 1579361177
					AntiFutureVisLabel.Visible = true
				else
					local n29 = n27 - n26
					AntiFutureVisDot.Visible = false
					AntiFutureVisLabel.Visible = false
					local v84 = bit32.bxor(bit32.bxor(n15, 63220771), 63220771)
					local v85 = bit32.band(n26, n29)
					n15 = v84
					v83 = bit32.bxor(n29, 2744772554)
					n28 = bit32.bxor(v85, 1713675961)
				end

				n27 = v83 + 2787934209
				n26 = n28 - 1617901293
			else
				AntiFutureVisDot.Visible = false
				AntiFutureVisLabel.Visible = false
			end

			RunTriggerbot()
			local enabled4 = aimbot.Enabled
			local n28 = n27 + 3257049093

			if enabled4 and aimbot2 and PassesConditions(aimbot2, "Aimbot") then
				local character = aimbot2.Character

				if character then
					local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart then
						local n29 = bit32.rshift(n26, 20)
						local flag9 = (humanoidRootPart.Position - currentCamera2.CFrame.Position).Magnitude <= (aimbot["Max Range"] or 750)

						if flag9 then
							local v81 = fn9
							local position = humanoidRootPart.Position
							local v82 = table.pack(bit32.band(n28, 4294967295))
							local v83 = table.pack(bit32.band(v82[1], 65535))
							local v84 = bit32.band(v83[1] * 52413 + bit32.lshift(bit32.band(v83[1] * 0 + bit32.rshift(v82[1], 16) * 52413, 65535), 16), 4294967295)
							local v85 = table.pack(bit32.band(n15, 4294967295))
							local v86 = table.pack(bit32.band(v85[1], 65535))
							local v87 = bit32.band(4620 * v86[1] + bit32.lshift(bit32.band(4620 * bit32.rshift(v85[1], 16) + 253 * v86[1], 65535), 16), 4294967295)
							local v88 = bit32.bxor(n29, v84)
							local v89 = table.pack(bit32.band(bit32.bor(n15, 90825428), 4294967295))
							local v90 = table.pack(bit32.band(v89[1], 65535))
							local v91 = bit32.band(56296 * v90[1] + bit32.lshift(bit32.band(56296 * bit32.rshift(v89[1], 16) + 65029 * v90[1], 65535), 16), 4294967295)
							local v92 = table.pack(bit32.band(bit32.bxor(n15, 90825428), 4294967295))
							local v93 = table.pack(bit32.band(v92[1], 65535))
							local n30 = v87 + 3731720688 + v91 + bit32.band(4621 * v93[1] + bit32.lshift(bit32.band(4621 * bit32.rshift(v92[1], 16) + 253 * v93[1], 65535), 16), 4294967295)
							flag9 = v81(position, "Aimbot")
							local v94 = bit32.bxor(v88, 4294967295)
							n15 = bit32.bxor(n30, 90825428)
							n28 = bit32.bxor(v84, 691453876)
							n29 = v94 - 351002554
						end

						if flag9 then
							local v81 = fn8(character, aimbot)
							local n30 = bit32.lshift(n28, 3)
							local v82 = ApplyPrediction(v81 or humanoidRootPart.Position, aimbot2, aimbot)
							local position = currentCamera2.CFrame.Position
							local v83 = CFrameNew(position, v82)
							local smoothing = aimbot.Smoothing
							local enabled5

							if smoothing then
								enabled5 = smoothing.Enabled
								n29 = n29 - 4177813269 - 117154027
							else
								enabled5 = smoothing
							end

							if enabled5 then
								local x2 = smoothing.X or 0.09
								local y2 = smoothing.Y

								if not y2 then
									n30 = bit32.bxor(bit32.rshift(n30, 22), 286589036)
									y2 = 0.09
								end

								local z = smoothing.Z or 0.09
								local easing = smoothing.Easing
								local linear

								if easing then
									linear = Enum.EasingStyle[easing.In or "Linear"]
								else
									linear = easing
								end

								if not linear then
									local v84 = Enum
									local v85 = bit32.bxor(n15, 0)
									local v86 = table.pack(bit32.band(n29, 4294967295))
									local v87 = table.pack(bit32.band(v85, 4294967295))
									local v88 = table.pack(bit32.band(v86[1], 65535))
									local v89 = table.pack(bit32.rshift(v86[1], 16))
									local v90 = table.pack(bit32.band(v87[1], 65535))
									linear = v84.EasingStyle.Linear
									n29 = bit32.band(v88[1] * v90[1] + bit32.lshift(bit32.band(v88[1] * bit32.rshift(v87[1], 16) + v89[1] * v90[1], 65535), 16), 4294967295) + 662256726
								end

								local v84

								if easing then
									local easingDirection = Enum.EasingDirection
									local out = easing.Out

									if not out then
										n30 = bit32.bxor(bit32.bxor(n30, 4294967295), 4294967295)
										out = "InOut"
									end

									v84 = easingDirection[out]
								else
									v84 = easing
								end

								local v85

								if v84 then
									v85 = v84
								else
									local inOut = Enum.EasingDirection.InOut
									n30 = bit32.bxor(n30 + bit32.bxor(n15, 0), 134445935)
									v85 = inOut
								end

								local lookVector = currentCamera2.CFrame.LookVector
								local lookVector2 = v83.LookVector
								local v86 = Vector3New
								local v87 = bit32.bxor(n15, 528007748)
								local x3 = lookVector.X
								local v88 = bit32.bxor(v87, 0)
								local v89 = bit32.bor(n29, v88)
								local n31 = x3 + (lookVector2.X - lookVector.X) * TweenService:GetValue(x2, linear, v85)
								local n32 = lookVector.Y + (lookVector2.Y - lookVector.Y) * TweenService:GetValue(y2, linear, v85)
								local z2 = lookVector.Z
								local z3 = lookVector2.Z
								local z4 = lookVector.Z
								local bxor = bit32.bxor
								local v90 = bit32.bxor(v87, 0)
								local v91 = bxor(n30 // v89, v90)
								currentCamera2.CFrame = CFrameNew(position, position + v86(n31, n32, z2 + (z3 - z4) * TweenService:GetValue(z, linear, v85)))
								bit32.bxor(v87, 528007748)
								n30 = v91 + 4187702989
								n29 = v89 - 2896041596 - 1792778884
							else
								currentCamera2.CFrame = v83
							end

							bit32.bxor(n30, 3543638061)
						end

						bit32.bxor(n29, 95774608)
					end
				end
			end
		end))

		fn11 = function(arg, arg2, arg3, arg4, arg5, arg6, arg7)
			local n14 = 3147844733
			local n15 = 2080214777
			local n16 = 658019661
			local n17 = 448872598

			if ShotgunWeapons[arg3] then
				local serverTimeNow = Workspace:GetServerTimeNow()
				local n18 = 1

				if arg7 then
					local v63 = bit32.band(n16, 2080103922)
					n18 = arg7.Value or 1
					local randomizer = arg7.Randomizer

					if randomizer and randomizer.Enabled then
						local min = randomizer.Min or 1
						local n19 = n17 // v63
						n18 *= min + ((randomizer.Max or 1) - min) * MathRandom()
						n17 = bit32.bxor(n19, 448872598)
					end
				end

				local n19 = n17 // 238
				bit32.bxor(n14, 876261922)

				for i = 1, 5 do
					local n20 = (MathRandom() > 0.5 and MathRandom() * 0.05 or -MathRandom() * 0.05) * n18
					local n21 = (MathRandom() > 0.5 and MathRandom() * 0.1 or -MathRandom() * 0.1) * n18
					local flag2 = MathRandom() > 0.5

					if flag2 then
						local v63 = MathRandom()
						n15 = bit32.bxor(n15, 1839945535)
						flag2 = v63 * 0.05
					end

					local v63, v64, v65 = ShowPellet(localPlayer.Character, arg2, arg4, arg4 + (arg5 + Vector3New(n20, n21, (flag2 or -MathRandom() * 0.05) * n18)) * arg6, arg6)
					local v66, v67, v68 = ApplyDamageModifierHit(arg3, v63, v64, v65)
					CachedMainEvent:FireServer("ShootGun", arg2, arg4, v66, v67, v68, serverTimeNow)
				end

				bit32.bxor(n19, 450725845)
			else
				local v63, v64, v65 = ShowPellet(localPlayer.Character, arg2, arg4, arg4 + arg5 * arg6, arg6)
				local v66 = bit32.bxor(n16, 4294967295)
				local v67, v68, v69 = ApplyDamageModifierHit(arg3, v63, v64, v65)
				CachedMainEvent:FireServer("ShootGun", arg2, arg4, v67, v68, v69)
			end
		end

		local function fn14()
			local n14 = 307835184
			local n15 = 3657189023
			local n16 = 3024524735
			local n17 = 2336849620
			local silentAim = fn()["Silent Aim"]
			local autoShoot = silentAim["Auto Shoot"]
			local flag2 = not autoShoot

			if not flag2 then
				local enabled = autoShoot.Enabled
				bit32.bxor(n15, 392588019)
				local v63 = table.pack(bit32.band(n17, 4294967295))
				local v64 = table.pack(bit32.band(n16, 4294967295))
				local v65 = table.pack(bit32.band(v63[1], 65535))
				local v66 = table.pack(bit32.rshift(v63[1], 16))
				local v67 = table.pack(bit32.band(v64[1], 65535))
				flag2 = not enabled
				n17 = bit32.band(v65[1] * v67[1] + bit32.lshift(bit32.band(v65[1] * bit32.rshift(v64[1], 16) + v66[1] * v67[1], 65535), 16), 4294967295) + 447380136
			end

			if flag2 or not silentAim.Enabled then
				State.AutoShootStatus = "Disabled"
				return
			end
			local silent = State.Targets.Silent
			if not silent then
				State.AutoShootStatus = "No Target"
				return
			end
			local character = localPlayer.Character
			local v63 = bit32.bxor(n16, n17)

			if not character then
				local v64 = State
				bit32.rshift(n17, 8)
				v64.AutoShootStatus = "No Character"
				return
			end

			local tool = character:FindFirstChildOfClass("Tool")

			if not tool or not tool:FindFirstChild("Ammo") or tool.Name == "[Knife]" then
				local v64 = State
				local v65 = table.pack(bit32.band(n17, 4294967295))
				local v66 = table.pack(bit32.band(v63, 4294967295))
				local v67 = table.pack(bit32.band(v65[1], 65535))
				local v68 = table.pack(bit32.rshift(v65[1], 16))
				local v69 = table.pack(bit32.band(v66[1], 65535))
				bit32.band(v67[1] * v69[1] + bit32.lshift(bit32.band(v67[1] * bit32.rshift(v66[1], 16) + v68[1] * v69[1], 65535), 16), 4294967295)
				v64.AutoShootStatus = "No Gun"
				return
			end

			if not PassesConditions(silent, "Silent Aim") then
				local v64 = State
				bit32.bor(v63, n17)
				v64.AutoShootStatus = "Conditions"
				return
			end

			local character2 = silent.Character
			character2 = character2 and character2:FindFirstChild("HumanoidRootPart")
			if not character2 then
				State.AutoShootStatus = "No Target"
				return
			end
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then
				return
			end
			local range = tool:FindFirstChild("Range")
			range = range and range.Value or 200
			local position = GetMuzzlePosition(tool) or humanoidRootPart.Position
			local n18 = n17 + v63
			if range < (position - character2.Position).Magnitude then
				State.AutoShootStatus = "Out of Range"
				return
			end
			local n19 = bit32.band(n18, v63)
			local wallCheck = autoShoot["Wall Check"]
			local v64

			if wallCheck then
				local flag3 = not IsVisible(character2.Position, silent)
				local v65 = table.pack(bit32.band(v63, 4294967295))
				local v66 = table.pack(bit32.band(n19, 4294967295))
				local v67 = table.pack(bit32.band(v65[1], 65535))
				local v68 = table.pack(bit32.rshift(v65[1], 16))
				local v69 = table.pack(bit32.band(v66[1], 65535))
				v63 = bit32.bxor(bit32.band(v67[1] * v69[1] + bit32.lshift(bit32.band(v67[1] * bit32.rshift(v66[1], 16) + v68[1] * v69[1], 65535), 16), 4294967295), 2632332178)
				v64 = flag3
			else
				v64 = wallCheck
			end

			if v64 then
				State.AutoShootStatus = "Blocked"
				return
			end
			local offscreenTargeting = silentAim["Offscreen Targeting"]
			offscreenTargeting = offscreenTargeting and offscreenTargeting.Enabled
			local n20 = v63 - n19
			local currentCamera2 = Workspace.CurrentCamera
			local v65, v66 = currentCamera2:WorldToViewportPoint(character2.Position)

			if not offscreenTargeting then
				if not (v66 and v65.Z > 1) then
					State.AutoShootStatus = "Blocked"
					return
				end
				local fov = fn().Main.FOV

				if fov then
					fov = fn().Main.FOV.Silent
					n19 = bit32.band(n19 // 64, n20) + 168388907
				end

				if fov and (fov.Width or fov.Height) then
					local mouseLocation = UserInputService:GetMouseLocation()
					local y = currentCamera2.ViewportSize.Y
					local fieldOfView = currentCamera2.FieldOfView
					local n21 = character2.Size.Y * y
					local z = v65.Z
					local v67 = bit32.bxor(n20 // 235, n19)
					local n22 = n21 / z * 2 * 80 / fieldOfView
					local width = fov.Width
					local v68 = v67
					local n23 = (width and fov.Width[2] or 9e9) * n22
					local height = fov.Height
					local v69 = bit32.band(v68, v67)
					height = height and fov.Height[2]

					if not height then
						bit32.bxor(n14, 2262558506)
						height = 9e9
					end

					local n24 = height * n22
					local v70 = Vector2New
					local x = v65.X
					local v71 = table.pack(bit32.band(v67, 4294967295))
					local v72 = table.pack(bit32.band(v69, 4294967295))
					local v73 = table.pack(bit32.band(v71[1], 65535))
					local v74 = table.pack(bit32.rshift(v71[1], 16))
					local v75 = table.pack(bit32.band(v72[1], 65535))
					local v76 = bit32.band(v73[1] * v75[1] + bit32.lshift(bit32.band(v73[1] * bit32.rshift(v72[1], 16) + v74[1] * v75[1], 65535), 16), 4294967295)
					local n25 = v70(x, v65.Y) - mouseLocation
					local flag3 = MathAbs(n25.X) <= n23 / 2

					if flag3 then
						flag3 = MathAbs(n25.Y) <= n24 / 2
						v69 = bit32.bxor(v69 // 12, 183093976)
					end

					local v77 = bit32.bxor(v76, v69)
					if not flag3 then
						State.AutoShootStatus = "Blocked"
						return
					end
					bit32.bxor(v77, 3008531680)
				end
			end

			State.AutoShootStatus = "Shooting"
			tool:Activate()
		end

		RunService:BindToRenderStep("ciderrage", 1, fn14)
		n10 = v52 // 2 * 7
		TrackConn(RunService.RenderStepped:Connect(fn14))
		TrackConn(RunService.Stepped:Connect(fn14))
		TrackConn(RunService.Heartbeat:Connect(fn14))
		local v63 = v62

		if CurrentGame.Name == "Da Hood" then
			if localPlayer.Character then
				local v64 = HookGunActivation
				local character = localPlayer.Character
				local v65 = bit32.bxor(n10, 3560697505)
				v64(character)
				n10 = v65 - 875191711
			end

			TrackConn(localPlayer.CharacterAdded:Connect(HookGunActivation))
		end

		local modifications = fn().Modifications
		local v64 = table.pack(bit32.band(v63, 4294967295))
		local v65 = table.pack(bit32.band(n10, 4294967295))
		local v66 = table.pack(bit32.band(v64[1], 65535))
		local v67 = table.pack(bit32.rshift(v64[1], 16))
		local v68 = table.pack(bit32.band(v65[1], 65535))
		v54 = bit32.band(v66[1] * v68[1] + bit32.lshift(bit32.band(v66[1] * bit32.rshift(v65[1], 16) + v67[1] * v68[1], 65535), 16), 4294967295)
		local dasHood = modifications["Das Hood"]
		local infRange = dasHood["Inf Range"]
		local wallbang = dasHood.Wallbang

		if infRange.Enabled then
			task.spawn(function()
				local n14 = 2882095737
				local n15 = 577944085
				local n16 = 2313823964
				local v69 = bit32.band(1151939924, n16)
				local mainEvent = ReplicatedStorage:FindFirstChild("MainEvent") or ReplicatedStorage:WaitForChild("MainEvent", 10)

				if mainEvent then
					local n17 = 296746291

					TrackConn(RunService.Heartbeat:Connect(function()
						local n18 = 2319082771
						local n19 = 133820323
						local character = localPlayer.Character

						if character then
							local v70 = next
							local children, v71 = character:GetChildren()

							for _, v72 in v70, children, v71 do
								if v72:IsA("Tool") then
									local range = v72:FindFirstChild("Range")

									if range then
										range.Value = 999999
									end
								end
							end
						end

						local backpack = localPlayer:FindFirstChild("Backpack")

						if backpack then
							local v70 = next
							local v71 = bit32.bor(n19, 1349454898)
							local children, v72 = backpack:GetChildren()

							for _, v73 in v70, children, v72 do
								if v73:IsA("Tool") then
									local range = v73:FindFirstChild("Range")

									if range then
										range.Value = 999999
										n18 = bit32.bxor(n18, 3537123007)
									end
								end
							end

							local v73 = bit32.bxor(v71, 1342570512)
						end
					end))

					local v70 = hookmetamethod
					local v71 = nil
					local v72 = game
					bit32.band(n16, 1373800309)
					bit32.bxor(n14, 4077478346)
					local n18 = 334202625

					v71 = v70(v72, "__namecall", function(arg, ...)
						local n19 = 3971767875
						local n20 = 3593678592
						local v73 = getnamecallmethod()
						local n21 = 4970714
						local tbl11 = { ... }

						if arg == mainEvent and v73 == "FireServer" and tbl11[1] == "ShootGun" then
							local flag2 = tbl11[6]
							local n22 = n20 + 3559800142

							if flag2 then
								local v74 = type
								bit32.bxor(n19, 3351587550)
								flag2 = v74(tbl11[6]) == "number"
								n22 = bit32.bxor(n22, n21) - 4291381318
							end

							if flag2 then
								tbl11[6] = 10
							end

							if tbl11[3] and tbl11[5] then
								local n23 = n21 // n22
								local n24 = tbl11[5] + (tbl11[3] - tbl11[5]).Unit * 10
								local v74 = bit32.band(n22, n23)
								tbl11[3] = n24
								n21 = bit32.bxor(n23, 4970714)
								n22 = v74 - 1436455858
							end

							if tbl11[2] and tbl11[4] and tbl11[5] then
								local parent = tbl11[2].Parent

								if parent then
									local v74 = ApplyDamageModifierHit
									local name = parent.Name
									local n23 = bit32.bxor(n21, 3151493048) // n22
									local v75, v76, v77 = v74(name, tbl11[4], tbl11[5], tbl11[6])
									tbl11[4] = v75
									tbl11[5] = v76
									tbl11[6] = v77
								end
							end

							n20 = bit32.bxor(n22, 2085765966)
						end

						if tbl11[1] == "CHECKER_4" then
							return nil
						end
						return v71(arg, Unpack(tbl11))
					end)

					local v73 = bit32.bxor(v69 + 20570624, 2282233992)
					bit32.bxor(n15, 1749841286)
				end
			end)
		end

		n11 = n10 + 2173878544

		if wallbang.Enabled then
			local function fn15()
				local n14 = 795181500
				local n15 = 2387089921
				local n16 = 2556823397
				local ignored = Workspace:FindFirstChild("Ignored")
				local n17 = -2786980555

				if not ignored then
					local v69 = Instance
					bit32.bxor(n15, 3275634709)
					ignored = v69.new("Folder")
					ignored.Name = "Ignored"
					ignored.Parent = Workspace
					n16 = n16 - 4206595 + 4206595
				end

				local map = Workspace:FindFirstChild("MAP") or Workspace:FindFirstChild("Map")
				local flag2

				if map then
					bit32.bxor(n14, 3507805377)
					flag2 = map.Parent ~= ignored
				else
					flag2 = map
				end

				if flag2 then
					map.Parent = ignored
				end
			end

			fn15()
			local v69 = TrackConn
			local v70 = bit32.bor(v54, 2523610483)

			v69(RunService.Heartbeat:Connect(function()
				local n14 = 560018296
				local n15 = 3413714144

				if fn().Modifications["Das Hood"].Wallbang.Enabled then
					fn15()
				end
			end))

			v54 = bit32.bxor(v70, 2517112912)
		end
	end

	local n12, n13, v55, n14, n15

	do
		local v56 = CurrentGame
		local v57 = table.pack(bit32.band(v53, 4294967295))
		local v58 = table.pack(bit32.band(v57[1], 65535))
		v = bit32.band(22752 * v58[1] + bit32.lshift(bit32.band(22752 * bit32.rshift(v57[1], 16) + 199 * v58[1], 65535), 16), 4294967295)
		local v59 = table.pack(bit32.band(bit32.bor(v53, 48996023), 4294967295))
		local v60 = table.pack(bit32.band(v59[1], 65535))
		local v61 = bit32.band(42785 * v60[1] + bit32.lshift(bit32.band(42785 * bit32.rshift(v59[1], 16) + 65336 * v60[1], 65535), 16), 4294967295)
		n12 = v54 + bit32.bxor(v53, 0)
		local v62 = table.pack(bit32.band(bit32.band(v53, 48996023), 4294967295))
		local v63 = table.pack(bit32.band(v62[1], 65535))
		n13 = v + 3975858208 + v61 + bit32.band(42783 * v63[1] + bit32.lshift(bit32.band(42783 * bit32.rshift(v62[1], 16) + 65336 * v63[1], 65535), 16), 4294967295)
		local name = v56.Name
		local v64 = bit32.lshift(n11, 30)
		local n16 = v64

		if name ~= "Da Hood" and type(hookfunction) == "function" then
			local spreadModifications = fn().Modifications["Spread Modifications"]
			local n17 = n12 - n16

			if spreadModifications.Enabled then
				local spreadAngles = spreadModifications["Spread Angles"]
				local v65 = nil
				local v66 = hookfunction
				local v67 = bit32.bor(n16, 2169429464)

				v65 = v66(math.random, function(...)
					local v68 = table.pack(...)
					local n18 = 621879023
					local n19 = 1476175254
					local n20 = 1864037418
					local n21 = 1523748701
					local tbl11 = { ... }
					if checkcaller() then
						return v65(table.unpack(v68, 1, v68.n))
					end
					local flag2 = #tbl11 == 0

					if not flag2 then
						flag2 = tbl11[1] == -0.05

						if flag2 then
							flag2 = tbl11[2] == 0.05
							n20 = bit32.bxor(bit32.bor(n20, 4225221190), 2428830276)
							bit32.bxor(n19, 3565143525)
						end
					end

					flag2 = flag2 or tbl11[1] == -0.1 and tbl11[2] == 0.1

					if not flag2 then
						flag2 = tbl11[1] == -0.05
						n20 = n20 // 212 + 1855244789
					end

					if not flag2 then
						local v69 = tbl11[1]
						local v70 = table.pack(bit32.band(n21, 4294967295))
						local v71 = table.pack(bit32.band(v70[1], 65535))
						flag2 = v69 == -0.1
						n21 = bit32.band(v71[1] * 52857 + bit32.lshift(bit32.band(v71[1] * 0 + bit32.rshift(v70[1], 16) * 52857, 65535), 16), 4294967295) + 4260361832
					end

					if flag2 then
						local spreadModifications2 = fn().Modifications["Spread Modifications"]
						local flag3 = not spreadModifications2.Enabled

						if not flag3 then
							flag3 = spreadAngles

							if spreadAngles then
								flag3 = spreadAngles.Enabled
								n20 = bit32.bxor(bit32.band(n20, n21), 621309986)
							end
						end

						if flag3 then
							return v65(table.unpack(v68, 1, v68.n))
						end
						local v69 = MathClamp((spreadModifications2.Value or 0) / 100, 0, 1)
						local v70 = bit32.bxor(n21, n20)
						local n22 = #tbl11

						if v69 == 0 then
							if n22 == 0 then
								return 0
							end

							if n22 == 1 then
								return 0
							end
							return (tbl11[1] + tbl11[2]) / 2
						end

						local v71 = v65(table.unpack(v68, 1, v68.n))
						local v72 = bit32.bxor(v70, 131156693)
						bit32.bxor(n18, 3030508654)
						if n22 == 0 then
							bit32.rshift(v72, 12)
							return (v71 - 0.5) * v69 + 0.5
						end

						if n22 == 1 then
							return v71 * v69
						end
						local n23 = (tbl11[1] + tbl11[2]) / 2
						return n23 + (v71 - n23) * v69
					end

					return v65(table.unpack(v68, 1, v68.n))
				end)

				n16 = v67 + 4273021480
			end

			n12 = n17 + 3221225472
		end

		local n17 = bit32.band(n16, 2640350966)
		local rangeEnhancer = fn().Modifications["Misc Gun Modifications"]["Range Enhancer"]

		if rangeEnhancer and rangeEnhancer.Enabled then
			local function fn13(arg)
				local n18 = 290557702
				local n19 = 2709701607
				local n20 = 4042389284
				local v65 = fn6()
				local n21 = 1096888411 // n20
				if v65 and type(v65.shoot) == "function" and type(v65.getAim) == "function" then
					return v65, "emulated"
				end

				if arg then
					local v66 = pcall
					bit32.bxor(n18, 1430703155)
					local n22 = n20 + 3883175895
					local flag2, v67 = v66(require, arg)

					if flag2 then
						local kind = type(v67)
						bit32.band(n21, 2221306361)
						flag2 = kind == "table"
					end

					flag2 = flag2 and type(v67.shoot) == "function"

					if flag2 then
						local v68 = type
						local getAim = v67.getAim
						bit32.bxor(n19, 3961027542)
						flag2 = v68(getAim) == "function"
					end

					if flag2 then
						return v67, "require"
					end
					bit32.bxor(n22, 681013727)
				end

				return nil, "missing"
			end

			local v65 = bit32.lshift(n12, 10)

			local function fn14(arg)
				local n18 = 1976848198
				local n19 = 4065217255
				local n20 = 3587582866
				if not arg or not arg:IsA("Tool") then
					return
				end
				local range = arg:FindFirstChild("Range")
				if not range then
					return
				end
				local attribute = arg:GetAttribute("__CiderBaseRange")
				local n21 = n19 + 623493067

				if type(attribute) ~= "number" then
					attribute = range.Value
					arg:SetAttribute("__CiderBaseRange", attribute)
				end

				local n22 = n20 + n21
				local rangeEnhancer2 = fn().Modifications["Misc Gun Modifications"]["Range Enhancer"]
				local n23 = rangeEnhancer2 and rangeEnhancer2.Enabled and rangeEnhancer2.Value or 0
				bit32.bxor(n18, 2185643317)
				range.Value = attribute + n23
			end

			local function fn15()
				local n18 = 4059047201
				local n19 = 2810558887
				local n20 = 1262320216
				local character = localPlayer.Character

				if character then
					local v66 = next
					local children, v67 = character:GetChildren()
					bit32.bxor(n18, 1197968498)
					bit32.bxor(n19, 1211957669)
					local n21 = n20 // 8

					for _, v68 in v66, children, v67 do
						fn14(v68)
					end
				end

				local backpack = localPlayer:FindFirstChild("Backpack")

				if backpack then
					local v66 = next
					local children, v67 = backpack:GetChildren()

					for _, v68 in v66, children, v67 do
						fn14(v68)
					end
				end
			end

			task.spawn(function()
				local n18 = 3408369266
				local n19 = 1216154505
				local n20 = 2477019540
				local n21 = 8617041203
				local modules = ReplicatedStorage:FindFirstChild("Modules") or ReplicatedStorage:WaitForChild("Modules", 5)

				local function fn16()
					local n22 = 3733210316
					local n23 = 187922451
					local n24 = 3268996405
					local gunHandler = modules

					if modules then
						local v66 = table.pack(bit32.band(n24, 4294967295))
						local v67 = table.pack(bit32.band(n23, 4294967295))
						local v68 = table.pack(bit32.band(v66[1], 65535))
						local v69 = table.pack(bit32.rshift(v66[1], 16))
						local v70 = table.pack(bit32.band(v67[1], 65535))
						local v71 = bit32.band(v68[1] * v70[1] + bit32.lshift(bit32.band(v68[1] * bit32.rshift(v67[1], 16) + v69[1] * v70[1], 65535), 16), 4294967295)
						bit32.bxor(n22, 2402935532)
						local n25 = v71 + 352287302
						gunHandler = modules:WaitForChild("GunHandler", 5)
					end

					return gunHandler
				end

				local n22 = n19
				local ok, result = pcall(fn16)

				if ok and result then
					local v66, v67 = fn13(result)
					shared.__cider_range_gunhandler_source = v67

					if v66 then
						local v68 = bit32.bxor(n19, n22)

						if v66.shoot and type(v66.shoot) == "function" and not v66.__CiderRangeWrapped then
							local shoot = v66.shoot

							v66.shoot = function(arg)
								local n23 = 2968087912
								local modifications = fn().Modifications
								local v69 = bit32.bxor(162339842, n23)
								local rangeEnhancer2 = modifications["Misc Gun Modifications"]["Range Enhancer"]
								local enabled

								if rangeEnhancer2 then
									enabled = rangeEnhancer2.Enabled
									n23 = bit32.bxor(v69, 162339842)
								else
									enabled = rangeEnhancer2
								end

								enabled = enabled and rangeEnhancer2.Value or 0

								if arg and arg.Range then
									arg.Range = arg.Range + enabled
								end

								return shoot(arg)
							end

							bit32.bxor(n18, 745669202)
							v68 *= 10555
							v66.__CiderRangeWrapped = true
							n22 = n22 + 234579267 - 234579267
						end

						if v66.getAim and type(v66.getAim) == "function" and not v66.__CiderRangeAimWrapped then
							v68 *= n22
							local getAim = v66.getAim
							local n23 = 188502333

							v66.getAim = function(arg, arg2)
								local n24 = 340806150
								local n25 = 3109581469
								local modifications = fn().Modifications
								bit32.bxor(3913475186, n25)
								local rangeEnhancer2 = modifications["Misc Gun Modifications"]["Range Enhancer"]
								local value = rangeEnhancer2 and rangeEnhancer2.Enabled and rangeEnhancer2.Value

								if not value then
									bit32.bxor(n25 - 2570619380, 2571606580)
									value = 0
								end

								bit32.bxor(n24, 4144397524)
								return getAim(arg, arg2 + value)
							end

							v66.__CiderRangeAimWrapped = true
						end
					end
				end
			end)

			local spawn = task.spawn

			local function fn16()
				local flag2 = type(107990103) ~= "number"
				fn15()
				local n18 = 555662976

				TrackConn(RunService.Heartbeat:Connect(function()
					fn15()
				end))

				TrackConn(localPlayer.CharacterAdded:Connect(function()
					task.wait(1)
					fn15()
				end))
			end

			local n18 = v65 + bit32.bxor(n13, 0)
			spawn(fn16)

			if rangeEnhancer["Use Hooks"] and getgc and islclosure and getfunctionhash and debug then
				local spawn2 = task.spawn

				local function fn17()
					local n19 = 2308355491
					local value = fn().Modifications["Misc Gun Modifications"]["Range Enhancer"].Value or 12

					for _, v66 in getgc() do
						local v67 = type
						n19 = bit32.bxor(n19, 1171855863)

						if v67(v66) == "function" and islclosure(v66) then
							if getfunctionhash(v66) == "f01a12bbf0fe1944cdca10883eb444581d9a6bbd8f40472dbf23b6b39fd412f21769d9bfccef6b899f802bae846d2bb3" then
								local v68 = debug.getupvalue(v66, 10)

								if v68 then
									v68.Value = value
								end

								debug.setupvalue(v66, 2, 0)
								debug.setconstant(v66, 26, 0)
								debug.setconstant(v66, 27, 0)
							end
						end
					end
				end

				local v66 = bit32.rshift(n17, 23)
				spawn2(fn17)
				n17 = v66 - 2147483904
			end

			n12 = bit32.bxor(n18, 1938086210)
		end

		if CurrentGame.Hooks == "Raycast" then
			local v65 = hookmetamethod
			local v66 = nil
			local v67 = game

			local function fn13(arg, ...)
				local n18 = 294913257
				local n19 = 3587764566
				local n20 = 203309502
				local tbl11 = { ... }
				local v68 = getnamecallmethod()
				local flag2 = not checkcaller()
				local v69 = table.pack(bit32.band(n19, 4294967295))
				local v70 = table.pack(bit32.band(v69[1], 65535))
				local v71 = bit32.band(44892 * v70[1] + bit32.lshift(bit32.band(44892 * bit32.rshift(v69[1], 16) + 46463 * v70[1], 65535), 16), 4294967295)
				local n21 = v71

				if flag2 and v68 == "Raycast" and arg == Workspace then
					local n22 = n19 - 315708881
					local silent = fn()["Silent Aim"].Enabled and State.Targets.Silent

					if silent then
						silent = PassesConditions(State.Targets.Silent, "Silent Aim")
						n21 = n21 // n22 - 1365605144
					end

					if silent then
						local v72 = tbl11[1]
						local v73 = bit32.bor(n22, n21)
						local v74 = tbl11[2]
						bit32.bxor(n20, 2341835347)
						local magnitude = v74.Magnitude
						local v75 = fn10(v72, magnitude)
						local hit = mouse.Hit
						v71 = bit32.band(n21, v73)

						if v75 ~= hit.Position then
							local unit = (v75 - v72).Unit
							bit32.bxor(n18, 4230269150)
							tbl11[2] = unit * magnitude
							return v66(arg, Unpack(tbl11))
						end

						n22 = v73 - 748160104
					end

					local n23 = n22 + 315708881
				end

				return v66(arg, Unpack(tbl11))
			end

			local v68 = bit32.band(n12, n17)
			v66 = v65(v67, "__namecall", fn13)
			n12 = v68 - 4025129256
		end

		local function fn13(character)
			local n18 = 235322299
			type(0)
			local n19 = 2630865608
			if not character then
				return
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
			if not humanoid then
				return
			end
			local n20 = n18 + 290303911 - 217498152

			TrackConn(humanoid.StateChanged:Connect(function(old, new)
				local n21 = 1610268707
				local n22 = 351991538
				local v65 = fn()
				local v66 = bit32.bxor(4157900349, n22)
				if not v65.Movement["Anti Trip"] then
					return
				end
				local flag2 = new == EnumFallingDown

				if not flag2 then
					local v67 = EnumRagdoll
					bit32.bxor(n21, 3836941638)
					flag2 = new == v67
				end

				if flag2 then
					local v67 = bit32.bor(n22, v66)
					humanoid:ChangeState(EnumGettingUp)
					bit32.bxor(v67, 3808690189)
				end
			end))
		end

		if localPlayer.Character then
			local character = localPlayer.Character
			local v65 = bit32.bxor(n13, 112910038)
			fn13(character)
			n13 = bit32.bxor(v65, 112910038)
			local v66 = bit32.bxor(n13, 0)
			n12 = bit32.bor(n12, v66) - 232921346
		end

		TrackConn(localPlayer.CharacterAdded:Connect(fn13))

		local function fn14(character)
			type(0)
			local n18 = 3586005651
			local n19 = 314634251
			local n20 = 248802072
			if not character then
				return
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
			bit32.bxor(n18, 3720245312)
			if not humanoid then
				return
			end
			local health = humanoid.Health

			TrackConn(humanoid.HealthChanged:Connect(function(health2)
				local n21 = 2075813491
				local n22 = 3235385034

				if health2 < health then
					TriggerAntiFutureBoost()
				end

				health = health2
				bit32.bxor(n21, 814869015)
				local v65 = table.pack(bit32.band(n22, 4294967295))
				local v66 = table.pack(bit32.band(v65[1], 65535))
				bit32.band(v66[1] * 15381 + bit32.lshift(bit32.band(v66[1] * 0 + bit32.rshift(v65[1], 16) * 15381, 65535), 16), 4294967295)
			end))
		end

		if localPlayer.Character then
			local character = localPlayer.Character
			local n18 = n17 + bit32.bxor(n13, 0)
			fn14(character)
			n17 = n18 + 4060717158
		end

		TrackConn(localPlayer.CharacterAdded:Connect(fn14))
		tbl = {}
		local ninja = { Idle = "rbxassetid://656118341" }
		local v65 = bit32.bxor(n13, 0)
		local v66 = bit32.bor(n17, v65)
		ninja.Run = "rbxassetid://656118852"
		ninja.Walk = "rbxassetid://656121766"
		ninja.Jump = "rbxassetid://656117878"
		ninja.Fall = "rbxassetid://10921159222"
		local n18 = (n12 + 7467342) * 12
		ninja.Climb = "rbxassetid://656114359"
		ninja.Swim = "rbxassetid://10921161002"
		ninja.SwimIdle = "rbxassetid://10922757002"
		tbl.Ninja = ninja

		local robot = {
			Idle = "rbxassetid://616089559",
			Run = "rbxassetid://616091570",
			Walk = "rbxassetid://616095330",
		}

		v55 = bit32.bor(n18, 3215602656)
		robot.Jump = "rbxassetid://616090535"
		robot.Fall = "rbxassetid://616092998"
		robot.Climb = "rbxassetid://616086039"
		local v67 = bit32.bor(n18, 3809469876)
		robot.Swim = "rbxassetid://10921253142"
		robot.SwimIdle = "rbxassetid://10921253767"
		tbl.Robot = robot
		local v68 = table.pack(bit32.band(n13, 4294967295))
		local v69 = table.pack(bit32.band(v68[1], 65535))
		local n19 = bit32.band(45853 * v69[1] + bit32.lshift(bit32.band(45853 * bit32.rshift(v68[1], 16) + 49455 * v69[1], 65535), 16), 4294967295) + 3024728070
		n14 = v67 - 3715191852
		local v70 = table.pack(bit32.band(bit32.bor(n13, 142957374), 4294967295))
		local v71 = table.pack(bit32.band(v70[1], 65535))
		local v72 = bit32.band(39366 * v71[1] + bit32.lshift(bit32.band(39366 * bit32.rshift(v70[1], 16) + 32160 * v71[1], 65535), 16), 4294967295)
		local v73 = table.pack(bit32.band(bit32.bxor(n13, 142957374), 4294967295))
		local v74 = table.pack(bit32.band(v73[1], 65535))
		n15 = n19 + v72 + bit32.band(45854 * v74[1] + bit32.lshift(bit32.band(45854 * bit32.rshift(v73[1], 16) + 49455 * v74[1], 65535), 16), 4294967295)
	end

	do
		local default = { Idle = "rbxassetid://507766666", Run = "rbxassetid://10921261968" }
		local v56 = bit32.bor(bit32.bxor(v55, n14), n14)
		default.Walk = "rbxassetid://10921269718"
		default.Jump = "rbxassetid://10921263860"
		default.Fall = "rbxassetid://10921262864"
		default.Climb = "rbxassetid://10921257536"
		default.Swim = "rbxassetid://10921264784"
		default.SwimIdle = "rbxassetid://10921265698"
		tbl.Default = default
	end

	local v56

	do
		local custom = {}
		v56 = bit32.bxor(n15, 0)
		custom.Idle = "rbxassetid://92080889861410"
		custom.Run = "rbxassetid://16738337225"
		local v57 = bit32.band(n14 - 2445976581, v56)
		custom.Walk = "rbxassetid://16738340646"
		custom.Jump = "rbxassetid://104325245285198"
		custom.Fall = "rbxassetid://616003713"
		custom.Climb = "rbxassetid://18537363391"
		custom.Swim = "rbxassetid://133308483266208"
		custom.SwimIdle = "rbxassetid://109346520324160"
		tbl.Custom = custom

		local levitate = {
			Idle = "rbxassetid://616008087",
			Run = "rbxassetid://616010382",
			Walk = "rbxassetid://616013216",
			Jump = "rbxassetid://616008936",
		}

		local v58 = v57
		local v59 = bit32.bxor(n15, 0)
		local v60 = table.pack(bit32.band(v58, 4294967295))
		local v61 = table.pack(bit32.band(v59, 4294967295))
		local v62 = table.pack(bit32.band(v60[1], 65535))
		local v63 = table.pack(bit32.rshift(v60[1], 16))
		local v64 = table.pack(bit32.band(v61[1], 65535))
		local v65 = bit32.band(v62[1] * v64[1] + bit32.lshift(bit32.band(v62[1] * bit32.rshift(v61[1], 16) + v63[1] * v64[1], 65535), 16), 4294967295)
		levitate.Fall = "rbxassetid://616005863"
		levitate.Climb = "rbxassetid://616003713"
		levitate.Swim = "rbxassetid://10921139478"
		local n16 = v56 // bit32.bxor(n15, 0)
		levitate.SwimIdle = "rbxassetid://10921138209"
		tbl.Levitate = levitate
		local v66 = n16

		local mage = {
			Idle = "rbxassetid://707855907",
			Run = "rbxassetid://707861613",
			Walk = "rbxassetid://707897309",
			Jump = "rbxassetid://707853694",
			Fall = "rbxassetid://707829716",
			Climb = "rbxassetid://707826056",
		}

		local v67 = bit32.bxor(v65, 2361469673)
		mage.Swim = "rbxassetid://10921150788"
		n = v67 + 403302958
		mage.SwimIdle = "rbxassetid://10921151661"
		tbl.Mage = mage
		local stylish = { Idle = "rbxassetid://616138447" }
		local v68 = bit32.bxor(n15, 43165183)
		local n17 = v66 - bit32.bxor(n15, 0)
		v2 = v68
		stylish.Run = "rbxassetid://616140816"
		stylish.Walk = "rbxassetid://616146177"
		stylish.Jump = "rbxassetid://616139451"
		v3 = bit32.bor(n17, 2868343213)
		stylish.Fall = "rbxassetid://616134815"
		stylish.Climb = "rbxassetid://616133594"
		stylish.Swim = "rbxassetid://10921281000"
		stylish.SwimIdle = "rbxassetid://10921281964"
		tbl.Stylish = stylish
	end
end

local tbl2, tbl3, Players2, RunService2, InsertService, localPlayer2, v4, connection, tbl4, connection2
local connection3, n2, tbl5, tbl6, tbl7, tbl8, tbl9, tbl10, tbl11, tbl12
local ok, result, str, tbl13, v5, tbl14, v6, tbl15, tbl16, v7

do
	local n3
	local hero = {}
	n3 = n // bit32.bxor(v2, 0)
	hero.Idle = "rbxassetid://616113536"
	hero.Run = "rbxassetid://616117076"
	hero.Walk = "rbxassetid://616122287"
	hero.Jump = "rbxassetid://616115533"
	hero.Fall = "rbxassetid://616108001"
	hero.Climb = "rbxassetid://616104706"
	hero.Swim = "rbxassetid://10921295495"
	hero.SwimIdle = "rbxassetid://10921297391"
	tbl.Hero = hero
	local v8, v9, v10

	do
		local toy = {}
		v8 = bit32.lshift(v3 // n3, 2)
		toy.Idle = "rbxassetid://782845736"
		toy.Run = "rbxassetid://782842708"
		toy.Walk = "rbxassetid://782843345"
		toy.Jump = "rbxassetid://782847020"
		local v11 = bit32.band(n3 + 3432918893, 1922039369)
		toy.Fall = "rbxassetid://782846423"
		toy.Climb = "rbxassetid://782843869"
		toy.Swim = "rbxassetid://10921309319"
		toy.SwimIdle = "rbxassetid://10921310341"
		tbl.Toy = toy
		local astronaut = { Idle = "rbxassetid://891633237" }
		local n4 = v11 + bit32.bxor(v2, 0)
		astronaut.Run = "rbxassetid://891636393"
		v9 = bit32.bxor(v2, 201289664)
		v10 = bit32.lshift(n4, 24)
		astronaut.Walk = "rbxassetid://891667138"
		astronaut.Jump = "rbxassetid://891627522"
		astronaut.Fall = "rbxassetid://891617961"
		astronaut.Climb = "rbxassetid://891609353"
		astronaut.Swim = "rbxassetid://10921044000"
		astronaut.SwimIdle = "rbxassetid://10921045006"
		tbl.Astronaut = astronaut
	end

	local n4, v11, v12, v13, n5, v14, n6, v15

	do
		local bubbly = { Idle = "rbxassetid://910009958" }
		local v16 = bit32.bxor(v9, 0)
		local v17 = bit32.band(v8 // 116, v16)
		bubbly.Run = "rbxassetid://910025107"
		bubbly.Walk = "rbxassetid://910034870"
		bubbly.Jump = "rbxassetid://910016857"
		bubbly.Fall = "rbxassetid://910001910"
		bubbly.Climb = "rbxassetid://742636889"
		bubbly.Swim = "rbxassetid://10921063569"
		bubbly.SwimIdle = "rbxassetid://10922582160"
		tbl.Bubbly = bubbly
		local n7 = v10 // 73
		local cartoony = { Idle = "rbxassetid://742638445" }
		local v18 = bit32.rshift(v17, 4)
		cartoony.Run = "rbxassetid://742638842"
		cartoony.Walk = "rbxassetid://742640026"
		cartoony.Jump = "rbxassetid://742637942"
		cartoony.Fall = "rbxassetid://742637151"
		n4 = v18 * 62118
		cartoony.Climb = "rbxassetid://742636889"
		cartoony.Swim = "rbxassetid://10921079380"
		cartoony.SwimIdle = "rbxassetid://10921081059"
		tbl.Cartoony = cartoony
		local elder = { Idle = "rbxassetid://845400520" }
		local v19 = bit32.lshift(n7, 16)
		elder.Run = "rbxassetid://845386501"
		elder.Walk = "rbxassetid://845403856"
		elder.Jump = "rbxassetid://845398858"
		elder.Fall = "rbxassetid://845396048"
		local v20 = bit32.bxor(n4, 4294967295)
		elder.Climb = "rbxassetid://845392038"
		v11 = bit32.bxor(v9, 462918883)
		elder.Swim = "rbxassetid://10921108971"
		elder.SwimIdle = "rbxassetid://10921110146"
		tbl.Elder = elder
		local v21 = bit32.bxor(v11, 0)
		local v22 = bit32.band(n4, v21)

		local ghost = {
			Idle = "rbxassetid://616008087",
			Run = "rbxassetid://616013216",
			Walk = "rbxassetid://616013216",
			Jump = "rbxassetid://616008936",
			Fall = "rbxassetid://616005863",
			Climb = "rbxassetid://616156119",
		}

		local v23 = bit32.bxor(v11, 0)
		local v24 = table.pack(bit32.band(v20, 4294967295))
		local v25 = table.pack(bit32.band(v23, 4294967295))
		local v26 = table.pack(bit32.band(v24[1], 65535))
		local v27 = table.pack(bit32.rshift(v24[1], 16))
		local v28 = table.pack(bit32.band(v25[1], 65535))
		v12 = bit32.band(v26[1] * v28[1] + bit32.lshift(bit32.band(v26[1] * bit32.rshift(v25[1], 16) + v27[1] * v28[1], 65535), 16), 4294967295)
		ghost.Swim = "rbxassetid://133308483266208"
		ghost.SwimIdle = "rbxassetid://109346520324160"
		tbl.Ghost = ghost
		local knight = { Idle = "rbxassetid://657568135" }
		local v29 = table.pack(bit32.band(v22, 4294967295))
		local v30 = table.pack(bit32.band(v29[1], 65535))
		local v31 = bit32.band(v30[1] * 30157 + bit32.lshift(bit32.band(v30[1] * 0 + bit32.rshift(v29[1], 16) * 30157, 65535), 16), 4294967295)
		knight.Run = "rbxassetid://657564596"
		knight.Walk = "rbxassetid://657552124"
		knight.Jump = "rbxassetid://658409194"
		local v32 = bit32.band(v31, 1711634900)
		knight.Fall = "rbxassetid://657600338"
		knight.Climb = "rbxassetid://658360781"
		knight.Swim = "rbxassetid://10921125160"
		knight.SwimIdle = "rbxassetid://10921125935"
		tbl.Knight = knight
		local vampire = { Idle = "rbxassetid://1083450166", Run = "rbxassetid://1083462077" }
		local v33 = bit32.bor(v12 // v32, 1416746506)
		vampire.Walk = "rbxassetid://1083473930"
		vampire.Jump = "rbxassetid://1083455352"
		vampire.Fall = "rbxassetid://1083443587"
		local v34 = table.pack(bit32.band(v32, 4294967295))
		local v35 = table.pack(bit32.band(v33, 4294967295))
		local v36 = table.pack(bit32.band(v34[1], 65535))
		local v37 = table.pack(bit32.rshift(v34[1], 16))
		local v38 = table.pack(bit32.band(v35[1], 65535))
		v13 = bit32.band(v36[1] * v38[1] + bit32.lshift(bit32.band(v36[1] * bit32.rshift(v35[1], 16) + v37[1] * v38[1], 65535), 16), 4294967295)
		vampire.Climb = "rbxassetid://1083439238"
		vampire.Swim = "rbxassetid://10921324408"
		vampire.SwimIdle = "rbxassetid://10921325443"
		tbl.Vampire = vampire
		local v39 = bit32.rshift(v33, 11)
		local werewolf = {}
		local v40 = bit32.bxor(v11, 414258545)
		werewolf.Idle = "rbxassetid://1083214717"
		werewolf.Run = "rbxassetid://1083216690"
		werewolf.Walk = "rbxassetid://1083178339"
		n5 = v39 - 2800219689
		werewolf.Jump = "rbxassetid://1083218792"
		werewolf.Fall = "rbxassetid://1083189019"
		werewolf.Climb = "rbxassetid://1083182000"
		werewolf.Swim = "rbxassetid://10921340419"
		werewolf.SwimIdle = "rbxassetid://10921341319"
		tbl.Werewolf = werewolf
		local v41 = bit32.bor(v13 - 3338833044, 870626138)
		local zombie = {}
		v14 = bit32.bxor(v40, 422955537)
		zombie.Idle = "rbxassetid://616160636"
		zombie.Run = "rbxassetid://616163682"
		zombie.Walk = "rbxassetid://616168032"
		zombie.Jump = "rbxassetid://616161997"
		zombie.Fall = "rbxassetid://616157476"
		zombie.Climb = "rbxassetid://616156119"
		zombie.Swim = "rbxassetid://10921352344"
		zombie.SwimIdle = "rbxassetid://10921353442"
		local v42 = bit32.rshift(v41 // 119, 30)
		tbl.Zombie = zombie

		local bold = {
			Idle = "rbxassetid://16738334710",
			Run = "rbxassetid://16738337225",
			Walk = "rbxassetid://16738340646",
		}

		local v43 = bit32.bxor(v14, 0)
		local v44 = bit32.bxor(n5, v43)
		bold.Jump = "rbxassetid://16738336650"
		bold.Fall = "rbxassetid://16738333171"
		bold.Climb = "rbxassetid://16738332169"
		n6 = v42 + 913339668
		bold.Swim = "rbxassetid://16738339158"
		bold.SwimIdle = "rbxassetid://16738339817"
		tbl.Bold = bold
		local adidas = {}
		local v45 = bit32.bxor(v44, n6)
		adidas.Idle = "rbxassetid://18537371272"
		adidas.Run = "rbxassetid://18537384940"
		adidas.Walk = "rbxassetid://18537392113"
		v15 = bit32.bxor(v14, 0)
		adidas.Jump = "rbxassetid://18537380791"
		adidas.Fall = "rbxassetid://18537367238"
		adidas.Climb = "rbxassetid://18537363391"
		adidas.Swim = "rbxassetid://18537389531"
		adidas.SwimIdle = "rbxassetid://18537387180"
		tbl.Adidas = adidas
	end

	local v16, n7, v17, v18, aura

	do
		local catwalk = {}
		local v19 = bit32.bxor(v14, 0)
		local v20 = bit32.bor(v15, v19)
		catwalk.Idle = "rbxassetid://94970088341563"
		catwalk.Run = "rbxassetid://81024476153754"
		catwalk.Walk = "rbxassetid://109168724482748"
		catwalk.Jump = "rbxassetid://116936326516985"
		catwalk.Fall = "rbxassetid://119377220967554"
		local v21 = bit32.rshift(n6 - v15, 11)
		catwalk.Climb = "rbxassetid://92294537340807"
		catwalk.Swim = "rbxassetid://134591743181628"
		local v22 = bit32.bxor(v14, 0)
		catwalk.SwimIdle = "rbxassetid://98854111361360"
		tbl.Catwalk = catwalk

		local walmart = {
			Idle = "rbxassetid://18747063918",
			Run = "rbxassetid://18747070484",
			Walk = "rbxassetid://18747074203",
			Jump = "rbxassetid://18747069148",
			Fall = "rbxassetid://18747062535",
			Climb = "rbxassetid://18747060903",
		}

		local n8 = v22 // bit32.bxor(v14, 0)
		walmart.Swim = "rbxassetid://18747073181"
		walmart.SwimIdle = "rbxassetid://18747071682"
		tbl.Walmart = walmart
		local wicked = { Idle = "rbxassetid://76049494037641" }
		local v23 = bit32.lshift(v21 + v22, 30)
		v16 = bit32.bxor(v14, 246249421)
		n7 = n8 + v23
		wicked.Run = "rbxassetid://72301599441680"
		wicked.Walk = "rbxassetid://92072849924640"
		wicked.Jump = "rbxassetid://104325245285198"
		wicked.Fall = "rbxassetid://121152442762481"
		wicked.Climb = "rbxassetid://131326830509784"
		local v24 = bit32.bor(v23, n7)
		wicked.Swim = "rbxassetid://99384245425157"
		wicked.SwimIdle = "rbxassetid://113199415118199"
		tbl.Wicked = wicked
		local v25 = bit32.bxor(v24, 4294967295)

		tbl.NFL = {
			Idle = "rbxassetid://74451233229259",
			Run = "rbxassetid://117333533048078",
			Walk = "rbxassetid://110358958299415",
			Jump = "rbxassetid://119846112151352",
			Fall = "rbxassetid://129773241321032",
			Climb = "rbxassetid://134630013742019",
			Swim = "rbxassetid://132697394189921",
			SwimIdle = "rbxassetid://79090109939093",
		}

		local pirate = { Idle = "rbxassetid://750782770", Run = "rbxassetid://750783738" }
		local v26 = bit32.bxor(v25, n7)
		pirate.Walk = "rbxassetid://750785693"
		pirate.Jump = "rbxassetid://750782230"
		pirate.Fall = "rbxassetid://750780242"
		pirate.Climb = "rbxassetid://750779899"
		local v27 = bit32.bxor(v16, 0)
		local v28 = bit32.bxor(n7, v27)
		pirate.Swim = "rbxassetid://750784579"
		pirate.SwimIdle = "rbxassetid://750785176"
		tbl.Pirate = pirate
		local n9 = v26 - v28
		local n10 = v28 - n9

		tbl.Adidas2 = {
			Idle = "rbxassetid://102357151005774",
			Run = "rbxassetid://82598234841035",
			Walk = "rbxassetid://122150855457006",
			Jump = "rbxassetid://75290611992385",
			Fall = "rbxassetid://98600215928904",
			Climb = "rbxassetid://88763136693023",
			Swim = "rbxassetid://133308483266208",
			SwimIdle = "rbxassetid://109346520324160",
		}

		local n11 = n9 - n10
		local animals = { Idle = "rbxassetid://102357151005774", Run = "rbxassetid://87721497492370" }
		v17 = bit32.bxor(v16, 373586981)
		local v29 = bit32.band(n10, 116591721)
		animals.Walk = "rbxassetid://122150855457006"
		animals.Jump = "rbxassetid://75290611992385"
		animals.Fall = "rbxassetid://98600215928904"
		v18 = bit32.bxor(v17, 0)
		animals.Climb = "rbxassetid://88763136693023"
		animals.Swim = "rbxassetid://133308483266208"
		animals.SwimIdle = "rbxassetid://109346520324160"
		tbl.Animals = animals
		aura = {}
		local v30 = bit32.lshift(v29, 7)
		aura.Idle = "rbxassetid://114191137265065"
		aura.Run = "rbxassetid://118320322718866"
		aura.Walk = "rbxassetid://83842218823011"
		local v31 = table.pack(bit32.band(v30, 4294967295))
	end

	local v19 = table.pack(bit32.band(v18, 4294967295))
	local v20 = table.pack(bit32.band(t5497_14608_1[1], 65535))
	local v21 = table.pack(bit32.rshift(t5497_14608_1[1], 16))
	local v22 = table.pack(bit32.band(v19[1], 65535))
	local v23, v24, n8, n9, v25, v26, n10, tbl17, v27, v28

	do
		local v29 = bit32.band(v20[1] * v22[1] + bit32.lshift(bit32.band(v20[1] * bit32.rshift(v19[1], 16) + v21[1] * v22[1], 65535), 16), 4294967295)
		aura.Jump = "rbxassetid://109996626521204"
		aura.Fall = "rbxassetid://95603166884636"
		aura.Climb = "rbxassetid://97824616490448"
		local n11 = v18 + bit32.bxor(v17, 0)
		aura.Swim = "rbxassetid://134530128383903"
		aura.SwimIdle = "rbxassetid://94922130551805"
		local n12 = v29 - bit32.bxor(v17, 0)
		tbl.Aura = aura

		local wicked2 = {
			Idle = "rbxassetid://132238900951109",
			Run = "rbxassetid://135515454877967",
			Walk = "rbxassetid://73718308412641",
			Jump = "rbxassetid://78508480717326",
			Fall = "rbxassetid://78147885297412",
			Climb = "rbxassetid://129447497744818",
		}

		local v30 = table.pack(bit32.band(n11, 4294967295))
		local v31 = table.pack(bit32.band(v30[1], 65535))
		v23 = bit32.band(v31[1] * 31835 + bit32.lshift(bit32.band(v31[1] * 0 + bit32.rshift(v30[1], 16) * 31835, 65535), 16), 4294967295)
		wicked2.Swim = "rbxassetid://110657013921774"
		wicked2.SwimIdle = "rbxassetid://129183123083281"
		tbl.Wicked2 = wicked2
		local unboxed = { Idle = "rbxassetid://138183121662404", Run = "rbxassetid://134824450619865" }
		local n13 = n12 + bit32.bxor(v17, 0)
		unboxed.Walk = "rbxassetid://90478085024465"
		unboxed.Jump = "rbxassetid://121454505477205"
		unboxed.Fall = "rbxassetid://94788218468396"
		local v32 = bit32.bxor(n13, v23)
		unboxed.Climb = "rbxassetid://121145883950231"
		unboxed.Swim = "rbxassetid://105962919001086"
		unboxed.SwimIdle = "rbxassetid://129126268464847"
		tbl.Unboxed = unboxed
		local ud = {}
		local v33 = bit32.bor(v23, 136352232)
		ud.Idle = "rbxassetid://3303162549"
		v24 = bit32.bxor(v17, 11694797)
		ud.Run = "rbxassetid://3236836670"
		n8 = v32 - 1704306171
		ud.Walk = "rbxassetid://3303162967"
		ud.Jump = "rbxassetid://10921263860"
		local n14 = v33 // bit32.bxor(v24, 0)
		ud.Fall = "rbxassetid://10921262864"
		ud.Climb = "rbxassetid://10921257536"
		ud.Swim = "rbxassetid://10921264784"
		ud.SwimIdle = "rbxassetid://10921265698"
		tbl.Ud = ud

		local toilet = {
			Idle = "rbxassetid://4417978624",
			Run = "rbxassetid://4417979645",
			Walk = "rbxassetid://10921269718",
		}

		local v34 = bit32.bxor(v24, 0)
		local v35 = bit32.band(n8, v34)
		toilet.Jump = "rbxassetid://10921263860"
		toilet.Fall = "rbxassetid://10921262864"
		toilet.Climb = "rbxassetid://10921257536"
		n9 = n14 // n8 + v35
		toilet.Swim = "rbxassetid://10921264784"
		toilet.SwimIdle = "rbxassetid://10921265698"
		tbl.Toilet = toilet
		local gm = {}
		local v36 = table.pack(bit32.band(v35, 4294967295))
		local v37 = table.pack(bit32.band(v36[1], 65535))
		local v38 = bit32.band(v37[1] * 12885 + bit32.lshift(bit32.band(v37[1] * 0 + bit32.rshift(v36[1], 16) * 12885, 65535), 16), 4294967295)
		gm.Idle = "rbxassetid://96439737641086"
		gm.Run = "rbxassetid://101925097435036"
		gm.Walk = "rbxassetid://85809016093530"
		gm.Jump = "rbxassetid://74159004634379"
		gm.Fall = "rbxassetid://98070939608691"
		gm.Climb = "rbxassetid://108236155509584"
		local n15 = v38 - n9
		gm.Swim = "rbxassetid://83003487432457"
		gm.SwimIdle = "rbxassetid://112946194103503"
		tbl.Gm = gm
		local n16 = n9 - n15
		local kat = { Idle = "rbxassetid://72329200359275", Run = "rbxassetid://73117360545482" }
		v25 = bit32.bxor(v24, 57441186)
		local v39 = bit32.bor(n15, 3192539103)
		kat.Walk = "rbxassetid://99182913548783"
		kat.Jump = "rbxassetid://103632305262747"
		kat.Fall = "rbxassetid://127802717128367"
		kat.Climb = "rbxassetid://106213237973858"
		kat.Swim = "rbxassetid://134148268480210"
		local n17 = n16 // bit32.bxor(v25, 0)
		kat.SwimIdle = "rbxassetid://138619485942849"
		tbl.Kat = kat
		local oldschool = { Idle = "rbxassetid://10921232093", Run = "rbxassetid://10921240218" }
		local v40 = bit32.bor(v39, 1243455752)
		oldschool.Walk = "rbxassetid://10921244891"
		oldschool.Jump = "rbxassetid://10921242013"
		v26 = n17
		oldschool.Fall = "rbxassetid://10921241244"
		oldschool.Climb = "rbxassetid://10921229866"
		local v41 = bit32.bxor(v25, 0)
		local v42 = bit32.band(v40, v41)
		oldschool.Swim = "rbxassetid://10921243048"
		oldschool.SwimIdle = "rbxassetid://10921244018"
		tbl.Oldschool = oldschool
		local v43 = table.pack(bit32.band(v25, 4294967295))
		local v44 = table.pack(bit32.band(v43[1], 65535))
		local n18 = bit32.band(5193 * v44[1] + bit32.lshift(bit32.band(5193 * bit32.rshift(v43[1], 16) + 3228 * v44[1], 65535), 16), 4294967295) + 1814591852
		local v45 = table.pack(bit32.band(bit32.bor(v25, 131028492), 4294967295))
		local v46 = table.pack(bit32.band(v45[1], 65535))
		local v47 = bit32.band(60344 * v46[1] + bit32.lshift(bit32.band(60344 * bit32.rshift(v45[1], 16) + 62307 * v46[1], 65535), 16), 4294967295)
		local v48 = bit32.bxor(v42, 4294967295)
		local v49 = table.pack(bit32.band(bit32.band(v25, 131028492), 4294967295))
		local v50 = table.pack(bit32.band(v49[1], 65535))
		n10 = n18 + v47 + bit32.band(60342 * v50[1] + bit32.lshift(bit32.band(60342 * bit32.rshift(v49[1], 16) + 62307 * v50[1], 65535), 16), 4294967295)
		tbl17 = {}
		local idle = { Folder = "idle" }
		local v51 = bit32.lshift(v48, 12)
		idle.Children = { "Animation1", "Animation2" }
		tbl17.Idle = idle
		local run = { Folder = "run" }
		local children = {}
		local v52 = bit32.bxor(v26 - 635018762, 4294967295)
		children[1] = "RunAnim"
		run.Children = children
		tbl17.Run = run
		tbl17.Walk = { Folder = "walk", Children = { "WalkAnim" } }
		local n19 = v51 + bit32.bxor(n10, 0)
		tbl17.Jump = { Folder = "jump", Children = { "JumpAnim" } }
		tbl17.Fall = { Folder = "fall", Children = { "FallAnim" } }
		local climb = { Folder = "climb" }
		local v53 = bit32.bor(n19, 2313893427)
		climb.Children = { "ClimbAnim" }
		tbl17.Climb = climb
		local swim = {}
		local v54 = table.pack(bit32.band(n19, 4294967295))
		local v55 = table.pack(bit32.band(v53, 4294967295))
		local v56 = table.pack(bit32.band(v54[1], 65535))
		local v57 = table.pack(bit32.rshift(v54[1], 16))
		local v58 = table.pack(bit32.band(v55[1], 65535))
		local v59 = bit32.band(v56[1] * v58[1] + bit32.lshift(bit32.band(v56[1] * bit32.rshift(v55[1], 16) + v57[1] * v58[1], 65535), 16), 4294967295)
		swim.Folder = "swim"
		swim.Children = { "Swim" }
		tbl17.Swim = swim
		v27 = bit32.rshift(v53, 26)
		local swimIdle = { Folder = "swimidle" }
		v28 = bit32.bxor(n10, 347834434)
		swimIdle.Children = { "SwimIdleAnim" }
		tbl17.SwimIdle = swimIdle
		local v60 = bit32.bxor(v28, 0)
		local v61 = table.pack(bit32.band(v59, 4294967295))
		local v62 = table.pack(bit32.band(v60, 4294967295))
	end

	local v29 = table.pack(bit32.band(t3431_15604_1[1], 65535))
	local v30 = table.pack(bit32.rshift(t3431_15604_1[1], 16))
	local v31 = table.pack(bit32.band(t3431_15604_2[1], 65535))
	local n11
	n11 = bit32.band(v29[1] * v31[1] + bit32.lshift(bit32.band(v29[1] * bit32.rshift(t3431_15604_2[1], 16) + v30[1] * v31[1], 65535), 16), 4294967295)
	local n12, fn4, scAppliedSkins, scKnifeData, tbl18, tbl19, tbl20, v32, skinModules, v33
	local v34, fn5, fn6, fn7, fn8

	do
		local function fn9(arg, arg2)
			local n13 = 1257448361
			local n14 = 3541689466
			if not arg then
				return nil
			end
			local v35 = n13
			if arg:sub(1, 13) == "rbxassetid://" or arg:match("^%d+$") then
				return "rbxassetid://" .. arg:match("%d+")
			end
			local v36 = tbl[arg]
			if not v36 then
				return nil
			end
			local v37 = v36[arg2]
			bit32.bxor(v35, 3853097755)
			if not v37 then
				return nil
			end
			local str2 = v37:sub(1, 13)
			bit32.bor(n14, n13)
			if str2 == "rbxassetid://" then
				return v37
			end
			return "rbxassetid://" .. v37
		end

		local function ciderApplyAnimationChanger(arg, arg2)
			local n13 = 2205059589
			local n14 = 9056373713
			local n15 = 2559550478
			local n16 = 1794114275
			local animationChanger = fn().Utilities["Animation Changer"]
			if not arg2 and not animationChanger.Enabled then
				return
			end
			local animate = arg:FindFirstChild("Animate")
			if not animate then
				return
			end
			local humanoid = arg:FindFirstChildOfClass("Humanoid")
			local n17 = n15 // 214
			if not humanoid then
				return
			end
			local v35 = bit32.bxor(n14, 524909244)
			local animations = animationChanger.Animations or {}

			for k, v36 in next, tbl17, nil do
				local v37 = animations[k]

				if v37 then
					local v38 = fn9(v37, k)

					if v38 then
						local v39 = animate:FindFirstChild(v36.Folder)

						if v39 then
							for _, v40 in next, v36.Children, nil do
								local v41 = v39:FindFirstChild(v40)

								if v41 and v41:IsA("Animation") then
									v41.AnimationId = v38
								end
							end
						end
					end
				end
			end

			local v36 = next
			local playingAnimationTracks, v37 = humanoid:GetPlayingAnimationTracks()

			for _, v38 in v36, playingAnimationTracks, v37 do
				local v39 = pcall
				local n18 = 234301948

				local function fn10()
					v38:Stop(0)
				end

				n13 = bit32.bxor(n13, 1163809293)
				v39(fn10)
			end

			local v38 = pcall

			local function fn10()
				local n18 = 427634402
				local animate2 = arg:FindFirstChild("Animate")

				if animate2 then
					animate2.Disabled = true
					animate2.Disabled = false
					bit32.bxor(n18, 1210410587)
				end
			end

			bit32.bxor(n17, n16)
			v38(fn10)
		end

		local n13 = v27 + bit32.bxor(v28, 0)
		shared.__CiderApplyAnimationChanger = ciderApplyAnimationChanger

		if fn().Utilities["Animation Changer"].Enabled then
			if localPlayer.Character then
				task.delay(0.5, function()
					ciderApplyAnimationChanger(localPlayer.Character)
				end)

				n11 = n11 + 3944435873 + 350531423
			end

			TrackConn(localPlayer.CharacterAdded:Connect(function(character)
				local flag = type(462096289) == "table"
				local n14 = 752693351

				task.delay(1, function()
					ciderApplyAnimationChanger(character)
				end)
			end))
		end

		local v35 = fn()
		local v36 = bit32.bxor(v28, 0)
		local v37 = bit32.band(n13, v36)

		if v35.Utilities["Hitbox Expander"].Enabled then
			local function fn10(arg)
				local n14 = 1812836417
				local n15 = 4048428628
				local n16 = 2406482610
				if not arg then
					return
				end
				arg.Size = Vector3New(2, 2, 1)
				local n17 = n16 // 3
				bit32.bxor(n14, 872832391)
				arg.Transparency = 1
				local material = Enum.Material
				local v38 = bit32.band(n15, n17)
				arg.Material = material.Plastic
				local v39 = table.pack(bit32.band(n17, 4294967295))
				local v40 = table.pack(bit32.band(v38, 4294967295))
				local v41 = table.pack(bit32.band(v39[1], 65535))
				local v42 = table.pack(bit32.rshift(v39[1], 16))
				local v43 = table.pack(bit32.band(v40[1], 65535))
				bit32.band(v41[1] * v43[1] + bit32.lshift(bit32.band(v41[1] * bit32.rshift(v40[1], 16) + v42[1] * v43[1], 65535), 16), 4294967295)
				arg.BrickColor = BrickColor.new("Medium stone grey")
			end

			local v38 = bit32.lshift(n11, 24)

			TrackConn(RunService.Heartbeat:Connect(function()
				local n14 = 1255789274
				local n15 = 30467065
				local n16 = 4255378326
				local hitboxExpander = fn().Utilities["Hitbox Expander"]
				local flag = not hitboxExpander.Enabled
				local v39 = table.pack(bit32.band(n16, 4294967295))
				local v40 = table.pack(bit32.band(v39[1], 65535))
				local v41 = bit32.band(14808 * v40[1] + bit32.lshift(bit32.band(14808 * bit32.rshift(v39[1], 16) + 20198 * v40[1], 65535), 16), 4294967295)

				if flag then
					local v42 = next
					local players, v43 = Players:GetPlayers()

					for _, v44 in v42, players, v43 do
						if v44 ~= localPlayer then
							local character = v44.Character
							character = character and character:FindFirstChild("HumanoidRootPart")

							if character then
								local v45 = fn10
								n15 = bit32.bxor(n15, 3203528219)
								v45(character)
							end
						end
					end

					return
				end

				local size = hitboxExpander.Size
				bit32.bxor(n14, 1063589119)
				local n17 = n16 - 3399502023
				size = size or 8
				local targetOnly = hitboxExpander["Target Only"]
				local visualize = hitboxExpander.Visualize
				local silent

				if targetOnly then
					silent = State.Targets.Silent or State.Targets.Triggerbot

					if not silent then
						silent = State.Targets.Aimbot
						bit32.bxor(bit32.lshift(n17, 31), 3003359951)
					end
				else
					silent = targetOnly
				end

				local v42 = next
				local players, v43 = Players:GetPlayers()

				for _, v44 in v42, players, v43 do
					if v44 ~= localPlayer then
						local character = v44.Character

						if character then
							local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

							if humanoidRootPart then
								if targetOnly and silent ~= v44 then
									fn10(humanoidRootPart)
								else
									humanoidRootPart.Size = Vector3New(size, size, size)
									humanoidRootPart.CanCollide = false

									if visualize then
										humanoidRootPart.Transparency = 0.5
										humanoidRootPart.BrickColor = BrickColor.new("Really black")
										humanoidRootPart.Material = Enum.Material.SmoothPlastic
									else
										humanoidRootPart.Transparency = 1
										humanoidRootPart.Material = Enum.Material.Plastic
										humanoidRootPart.BrickColor = BrickColor.new("Medium stone grey")
									end
								end
							end
						end
					end
				end
			end))

			n11 = bit32.bxor(v38, 666387225)
		end

		local function fn10(arg, arg2, arg3)
			local n14 = 2763402661
			local n15 = 281003818
			local n16 = 2851433924
			local n17 = 1436767673
			local tool = arg and arg:FindFirstChildOfClass("Tool")
			local flag = false
			local flag2 = false

			if tool then
				local name = tool.Name
				local v38 = string.lower(name)
				local v39 = bit32.lshift(n16, 15)
				flag = name == "[Knife]"
				bit32.bxor(n15, 3879439943)

				if not flag then
					flag = v38:find("knife") ~= nil
					n17 = n17 // 11 + 1306152430
				end

				local ammo = tool:FindFirstChild("Ammo")

				if ammo and ammo.Value == 0 then
					flag2 = true
				else
					local reloading = tool:FindFirstChild("Reloading")

					if reloading then
						reloading = reloading.Value
						n17 = v39 - 1631496775
					end

					if reloading then
						flag2 = true
					end
				end

				n16 = bit32.bxor(v39, 521629124)
			end

			arg = arg and arg:FindFirstChild("BodyEffects")

			if arg then
				local reload = arg:FindFirstChild("Reload")

				if reload and reload.Value == true then
					flag2 = true
				end
			end

			local flag3

			if arg2 then
				flag3 = arg2.Health > 0
				n16 = bit32.bxor(n16 - 3696745479, 1684601977)
			else
				flag3 = arg2
			end

			flag3 = flag3 and arg2.Health <= 25
			local str2

			if flag then
				str2 = "Knife"
			elseif flag3 then
				str2 = "Low Health"
			elseif flag2 then
				n16 = bit32.band(n16, n17) - 1470879676
				str2 = "Reload"
			else
				local isShooting = State.IsShooting
				bit32.bxor(n14, 943821660)
				str2 = "Normal"

				if isShooting then
					str2 = "Shooting"
				end
			end

			if arg3 then
				arg3 = arg3.Conditions
				bit32.bxor(bit32.bxor(n17, n16), 2851433924)
			end

			local v38 = (arg3 or {})[str2]
			if v38 and v38.Enabled == false then
				return "Normal"
			end
			return str2
		end

		n12 = bit32.rshift(v37, 2)

		local function fn11(character)
			local n14 = 4128985379
			local n15 = 3055220082
			if not character then
				return
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not humanoid then
				return
			end
			local jumpPower = humanoid.JumpPower
			local v38 = TrackConn
			local v39 = bit32.bor(n15, 1805127904)
			bit32.bxor(n14, 154232109)
			local v40 = v39

			v38(humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
				local n16 = 3180258183
				local n17 = 345847999
				local v41 = bit32.bxor(v40, 1750306360)
				if not fn().Movement["No Jump Cooldown"] then
					return
				end
				local n18 = n17 - v41

				if humanoid.JumpPower == 0 then
					local n19 = v41 + n18
					local jumpModifications = fn().Movement["Jump Modifications"]
					local jumpModificationsActive = jumpModifications.Enabled and State.JumpModificationsActive

					if jumpModificationsActive then
						jumpModificationsActive = not jumpModifications["Spiderman Mode"]
						n19 = n18 - 1748403254
					end

					local n20

					if jumpModificationsActive then
						local v42 = fn10(character, humanoid, jumpModifications)
						n20 = n18 // 239
						local v43 = (jumpModifications.Conditions or {})[v42]
						bit32.bxor(n16, 370871211)
						local multiplier = v43 and v43.Enabled ~= false and v43.Multiplier or 1
						local values = jumpModifications.Values or jumpModifications
						local flag = jumpModifications.Mode == "Multiplier"

						if flag then
							local multiplier2 = values.Multiplier
							local n21

							if multiplier2 then
								n21 = multiplier2
							else
								local v44 = table.pack(bit32.band(n20, 4294967295))
								local v45 = table.pack(bit32.band(n19, 4294967295))
								local v46 = table.pack(bit32.band(v44[1], 65535))
								local v47 = table.pack(bit32.rshift(v44[1], 16))
								local v48 = table.pack(bit32.band(v45[1], 65535))
								n20 = bit32.bxor(bit32.band(v46[1] * v48[1] + bit32.lshift(bit32.band(v46[1] * bit32.rshift(v45[1], 16) + v47[1] * v48[1], 65535), 16), 4294967295), 1068598718)
								n21 = 1
							end

							flag = n21 * 100
						end

						humanoid.JumpPower = (flag or values.Number or 50) * multiplier
					else
						humanoid.JumpPower = jumpPower
						n20 = bit32.bxor(n18, 1936661390) + 4039707970
					end

					bit32.bxor(n19, 2203337589)
				end
			end))
		end

		if localPlayer.Character then
			fn11(localPlayer.Character)
		end

		TrackConn(localPlayer.CharacterAdded:Connect(fn11))

		local function fn12()
			local n14 = 3325794970
			local n15 = 276157675
			local n16 = 3717303338
			local character = localPlayer.Character
			local humanoid

			if character then
				humanoid = character:FindFirstChildOfClass("Humanoid")
				local v38 = table.pack(bit32.band(n16, 4294967295))
				local v39 = table.pack(bit32.band(n14, 4294967295))
				local v40 = table.pack(bit32.band(v38[1], 65535))
				local v41 = table.pack(bit32.rshift(v38[1], 16))
				local v42 = table.pack(bit32.band(v39[1], 65535))
				n16 = bit32.band(v40[1] * v42[1] + bit32.lshift(bit32.band(v40[1] * bit32.rshift(v39[1], 16) + v41[1] * v42[1], 65535), 16), 4294967295) + 1006892774
			else
				humanoid = character
			end

			if not humanoid then
				return
			end
			local speedModifications = fn().Movement["Speed Modifications"]

			if State.SpeedModificationHumanoid ~= humanoid then
				local v38 = fn3
				local v39 = State
				local v40 = table.pack(bit32.band(n14, 4294967295))
				local v41 = table.pack(bit32.band(n16, 4294967295))
				local v42 = table.pack(bit32.band(v40[1], 65535))
				local v43 = table.pack(bit32.rshift(v40[1], 16))
				local v44 = table.pack(bit32.band(v41[1], 65535))
				local v45 = bit32.band(v42[1] * v44[1] + bit32.lshift(bit32.band(v42[1] * bit32.rshift(v41[1], 16) + v43[1] * v44[1], 65535), 16), 4294967295)
				v38(v39)
				n14 = v45 - 3679582890
			end

			if not speedModifications.Enabled or not State.SpeedModificationsActive then
				fn3(State)
				return
			end

			if not State.SpeedModificationHumanoid then
				State.SpeedModificationHumanoid = humanoid
				local v38 = State
				local v39 = bit32.lshift(n16, 21)
				v38.OriginalWalkSpeed = humanoid.WalkSpeed
				n16 = v39 - 226427660 - 2586800330
			end

			local v38 = (speedModifications.Conditions or {})[fn10(character, humanoid, speedModifications)]
			local flag

			if v38 then
				flag = v38.Enabled ~= false
				n14 = bit32.band(n14, 3447690378) + 33557008
			else
				flag = v38
			end

			flag = flag and v38.Multiplier or 1
			local values = speedModifications.Values
			bit32.bxor(n15, 2961858235)
			values = values or speedModifications

			if speedModifications.Mode == "Multiplier" then
				humanoid.WalkSpeed = (values.Multiplier or 1) * 100 * flag
			else
				local number = values.Number
				local n17 = n14 + n16
				humanoid.WalkSpeed = (number or 16) * flag
			end
		end

		local n14 = n11 + n12
		TrackConn(RunService.RenderStepped:Connect(fn12))

		local function fn13(character)
			local n15 = 839905412
			local n16 = 1314750201
			local n17 = 2022911407
			local n18 = 357492992
			if not character then
				return
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
			if not humanoid then
				return
			end
			local n19 = n15 + 102301745
			local jumpPower = humanoid.JumpPower
			local v38 = RaycastParamsNew()
			v38.FilterType = EnumExclude
			v38.FilterDescendantsInstances = { character }

			local function fn14(arg)
				local position = arg.Position
				local n20 = bit32.bxor(n19, 1926846770) // 383517602
				local cFrame = arg.CFrame
				local tbl21 = {}
				local lookVector = cFrame.LookVector
				local n21 = -cFrame.LookVector
				local n22 = 383517602 // n20
				local rightVector = cFrame.RightVector
				local n23 = -cFrame.RightVector
				local unit = (cFrame.LookVector + cFrame.RightVector).Unit
				local unit2 = (cFrame.LookVector - cFrame.RightVector).Unit
				local unit3 = (-cFrame.LookVector + cFrame.RightVector).Unit
				local n24 = -cFrame.LookVector
				local v39 = table.pack(bit32.band(n22 // 171, 4294967295))
				local v40 = table.pack(bit32.band(v39[1], 65535))
				bit32.band(v40[1] * 7308 + bit32.lshift(bit32.band(v40[1] * 0 + bit32.rshift(v39[1], 16) * 7308, 65535), 16), 4294967295)
				local unit4 = (n24 - cFrame.RightVector).Unit
				tbl21[1] = lookVector
				tbl21[2] = n21
				tbl21[3] = rightVector
				tbl21[4] = n23
				tbl21[5] = unit
				tbl21[6] = unit2
				tbl21[7] = unit3
				tbl21[8] = unit4

				for _, v41 in next, tbl21, nil do
					if Workspace:Raycast(position, v41 * 5, v38) then
						return true
					end
				end

				return false
			end

			bit32.bxor(n16, 4154458014)

			local function fn15()
				local n20 = 1509559349
				local n21 = bit32.bxor(n19, 2415405807)
				local n22 = 3653813591
				local jumpModifications = fn().Movement["Jump Modifications"]
				local v39 = (jumpModifications.Conditions or {})[fn10(character, humanoid, jumpModifications)]
				local flag

				if v39 then
					flag = v39.Enabled ~= false
					bit32.bxor(n20, 2074877092)
					n21 = n22 + 3725071619
				else
					flag = v39
				end

				flag = flag and v39.Multiplier or 1
				local values = jumpModifications.Values or jumpModifications
				if jumpModifications.Mode == "Multiplier" then
					bit32.lshift(n21, 1)
					return (values.Multiplier or 1) * 100 * flag
				end
				return (values.Number or 50) * flag
			end

			local v39 = nil
			local flag = false
			local v40 = TrackConn
			bit32.lshift(n17 // n18, 14)

			v39 = v40(RunService.RenderStepped:Connect(function()
				local n20 = 3020531721
				local n21 = 4168027241
				local n22 = 4258785217
				if not character.Parent then
					v39:Disconnect()
					return
				end
				local movement = fn().Movement
				local n23 = bit32.bor(n22, 524320802)
				local jumpModifications = movement["Jump Modifications"]
				bit32.bxor(n20, 2095843230)
				local enabled = jumpModifications.Enabled
				local v41 = bit32.lshift(n21, 21)
				local flag2 = not enabled or not State.JumpModificationsActive
				local spidermanMode

				if flag2 then
					spidermanMode = flag2
				else
					spidermanMode = jumpModifications["Spiderman Mode"]
					n23 = bit32.lshift(n23, 27) + 3889686499
				end

				if spidermanMode then
					if flag then
						humanoid.JumpPower = jumpPower
						flag = false
					end

					return
				end

				humanoid.UseJumpPower = true
				humanoid.JumpPower = fn15()
				flag = true
				bit32.bor(v41, n23)
			end))

			local v41 = nil
			bit32.bor(n18, 3678089938)
			local n20 = 0

			v41 = TrackConn(UserInputService.JumpRequest:Connect(function()
				bit32.bxor(bit32.bxor(n19, 0), 51750907)
				local n21 = 62138331
				local n22 = 450370081
				local n23 = 2382750588
				local n24 = 3050157939
				if not character.Parent then
					v41:Disconnect()
					return
				end
				local v42 = fn()
				local v43 = bit32.band(n24, 1573607451)
				local jumpModifications = v42.Movement["Jump Modifications"]
				local n25 = n22 + 414777425
				local flag2 = not jumpModifications.Enabled

				if not flag2 then
					flag2 = not State.JumpModificationsActive
					n23 = v43 - 2277715095
				end

				if flag2 or not jumpModifications["Spiderman Mode"] then
					return
				end
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				if not humanoidRootPart then
					return
				end
				local v44 = bit32.bor(n23, 2005757142)
				if humanoid.FloorMaterial ~= EnumAir then
					return
				end
				local n26 = v43 + 2846416034
				if Tick() - n20 < 0.3 then
					return
				end

				if not fn14(humanoidRootPart) then
					return
				end
				n20 = Tick()
				local v45 = humanoid
				bit32.bxor(n21, 310369919)
				v45.UseJumpPower = true
				local v46 = humanoid
				local v47 = table.pack(bit32.band(v44, 4294967295))
				local v48 = table.pack(bit32.band(n26, 4294967295))
				local v49 = table.pack(bit32.band(v47[1], 65535))
				local v50 = table.pack(bit32.rshift(v47[1], 16))
				local v51 = table.pack(bit32.band(v48[1], 65535))
				local v52 = bit32.band(v49[1] * v51[1] + bit32.lshift(bit32.band(v49[1] * bit32.rshift(v48[1], 16) + v50[1] * v51[1], 65535), 16), 4294967295)
				v46.JumpPower = fn15()
				humanoid:ChangeState(EnumJumping)
				local v53 = nil
				local v54 = TrackConn
				local v55 = humanoid
				bit32.bxor(n26, v52)

				v53 = v54(v55.StateChanged:Connect(function(old, new)
					local n27 = 416159465

					if new == EnumFreefall or new == EnumLanded then
						v53:Disconnect()
						humanoid.JumpPower = jumpPower
						local n28 = n27 * 3 - 832318930
					end
				end))
			end))
		end

		if localPlayer.Character then
			fn13(localPlayer.Character)
			n12 = n12 // n14 + 127112704
		end

		TrackConn(localPlayer.CharacterAdded:Connect(fn13))

		fn4 = function()
			return fn().Utilities["Skin Changer"]
		end

		local n15 = n14 - n12

		if type(getgenv) == "function" then
			local scAppliedSkins2 = getgenv().__scAppliedSkins

			if scAppliedSkins2 then
				for _, v38 in next, scAppliedSkins2, nil do
					if v38 and v38.Connections then
						for _, v39 in next, v38.Connections, nil do
							pcall(function()
								local n16 = 1763351228
								local n17 = 13681026
								local n18 = 519106660

								if v39.Connected then
									v39:Disconnect()
									bit32.bxor(n16, 1077828257)
									local n19 = bit32.band(n18, n17) - 3789541276
								end
							end)
						end
					end
				end
			end

			local v38 = getgenv
			local v39 = bit32.band(n12, n15)
			local scKnifeData2 = v38().__scKnifeData

			if scKnifeData2 then
				for _, v40 in next, scKnifeData2, nil do
					if v40 and v40.conns then
						for _, v41 in next, v40.conns, nil do
							pcall(function()
								local n16 = 3943882137
								local n17 = 748882370

								if v41.Connected then
									v41:Disconnect()
									bit32.bxor(n16, 265733181)
								end
							end)
						end
					end
				end
			end

			n12 = bit32.bxor(v39, 17011712)
		end

		scAppliedSkins = {}
		scKnifeData = {}
		tbl18 = {}
		tbl19 = {}

		if type(getgenv) == "function" then
			getgenv().__scAppliedSkins = scAppliedSkins
			getgenv().__scKnifeData = scKnifeData
		end

		tbl20 = {}
		local v38 = bit32.rshift(n12, 24)
		v32 = CachedSkinAssets
		skinModules = ReplicatedStorage:FindFirstChild("SkinModules")
		local skinModules2 = nil
		v33 = bit32.bxor(v28, 504313770)
		v34 = bit32.bxor(n15, 4294967295)

		task.spawn(function()
			local n16 = 3812968898
			local flag = typeof(skinModules) == "Instance"
			local n17 = n16
			local n18 = 1177551392
			local v39 = n18
			local n19 = n18

			local fn14 = type(game.HttpGet) == "function" and function(arg)
				return game:HttpGet(arg)
			end

			local flag2

			if fn14 then
				flag2 = fn14
			else
				flag2 = type(getgenv) == "function"

				if flag2 then
					n16 = n17
					v39 = n16
					n17 = n16
					flag2 = getgenv().http_request
				end

				if flag2 then
					flag2 = function(arg)
						local n20 = 813406263
						local n21 = 1504686104
						local n22 = 1504686104
						local body = getgenv().http_request({ Url = arg, Method = "GET" })

						if body then
							body = body.Body
							bit32.bxor(n21, 1490013746)
						end

						return body
					end

					n19 = n19 - n17 + 3812968898
				end
			end

			if not flag2 then
				flag2 = type(getgenv) == "function" and getgenv().request

				if flag2 then
					flag2 = function(arg)
						local v40 = getgenv().request({ Url = arg, Method = "GET" })
						return v40 and v40.Body
					end

					n16 = n17
					v39 = n16
					n17 = n16
				end
			end

			if flag2 then
				local ok2, result2 = pcall(flag2, "https://pastebin.com/raw/0uZ107WE")

				if ok2 and result2 then
					local chunk = loadstring(result2)

					if chunk then
						local ok3, result3 = pcall(chunk)
						local flag3

						if ok3 then
							flag3 = type(result3) == "table"
							n17 = bit32.band(n17, n19) + 2705672642
						else
							flag3 = ok3
						end

						if flag3 then
							skinModules2 = result3
						elseif ok3 and shared.skin_modules and next(shared.skin_modules) then
							skinModules2 = shared.skin_modules
						end
					end
				end
			end

			local v40 = task
			local v41 = bit32.bor(n19, n17)
			local wait = v40.wait
			bit32.bxor(v39, 929733103)
			local v42 = bit32.bor(n17, 2825377523)
			wait(0.5)
			local v43 = fn4()

			if v43 and v43.Enabled then
				local skins = v43.Skins
				local v44 = bit32.lshift(v41, 20)
				local n20 = 104620736
				local v45 = v42

				local function fn15(arg)
					local n21 = 3300318426
					local n22 = 3596140215
					local n23 = 573418723
					local n24 = bit32.bxor(v45, 647840592) // 13
					if not arg then
						return
					end
					local v46 = next
					local children, v47 = arg:GetChildren()
					bit32.bxor(n21, 2738191649)

					for _, v48 in v46, children, v47 do
						if v48:IsA("Tool") then
							local v49 = skins[v48.Name]

							if not v49 then
								local str2 = v48.Name:gsub("%[", ""):gsub("%]", "")
								local v50 = skins
								n22 = bit32.bxor(n22, 2084426547)
								v49 = v50["[" .. str2 .. "]"]
							end

							if v49 and v49 ~= "" and v49 ~= "None" then
								local n25 = 9093700107

								pcall(function()
									(nil)(v48)
								end)

								tbl20[v48] = nil

								pcall(function()
									ProcessTool(v48)
								end)
							end
						end
					end
				end

				pcall(function()
					fn15(localPlayer.Character)
				end)

				pcall(function()
					fn15(localPlayer:FindFirstChild("Backpack"))
				end)
			end
		end)

		fn5 = function(arg)
			local n16 = 806263724
			local n17 = 304813670
			local n18 = 757052471
			local n19 = 576497314
			local str2 = arg:gsub(" ", "")
			local flag = str2 == "GoldenAgeTanto" or str2 == "GPO-Knife"
			local n20 = 757052471
			local flag2 = flag or str2 == "GPO-KnifePrestige" or str2 == "Heaven" or str2 == "LoveKukri"

			if not flag2 then
				bit32.bxor(n16, 2799334840)
				flag2 = str2 == "PurpleDagger"
			end

			flag2 = flag2 or str2 == "BlueDagger" or str2 == "GreenDagger"

			if not flag2 then
				flag2 = str2 == "RedDagger"
				local n21 = bit32.lshift(n19, 4) + 4237442178
				bit32.bxor(n17, 3265854257)
			end

			return flag2
		end

		fn6 = function(arg)
			local n16 = 3425028236
			local n17 = 3742560716
			local n18 = 4055263628
			local v39 = scKnifeData[arg]

			if v39 then
				if v39.conns then
					for _, v40 in next, v39.conns, nil do
						if v40 then
							v40:Disconnect()
						end
					end

					local v40 = bit32.bxor(n17, 4294967295)
					v39.conns = nil
					n17 = bit32.bxor(v40, 4294967295)
				end

				if v39.track then
					v39.track:Stop()
					local v40 = table.pack(bit32.band(n18, 4294967295))
					local v41 = table.pack(bit32.band(v40[1], 65535))
					local v42 = bit32.band(v41[1] * 65416 + bit32.lshift(bit32.band(v41[1] * 0 + bit32.rshift(v40[1], 16) * 65416, 65535), 16), 4294967295)
					bit32.bxor(n16, 2627543250)
					v39.track:Destroy()
					v39.track = nil
					n18 = v42 + 713138969 + 2871672851
				end

				if v39.welds then
					for _, v40 in next, v39.welds, nil do
						if v40 then
							v40:Destroy()
						end
					end
				end

				if v39.sounds then
					for _, v40 in next, v39.sounds, nil do
						if v40 and v40.Parent then
							v40:Destroy()
						end
					end
				end
			end

			local default = arg:FindFirstChild("Default")
			bit32.rshift(n17, 28)

			if default then
				local v40 = next
				local children, v41 = default:GetChildren()

				for _, v42 in v40, children, v41 do
					if v42.Name == "Handle.R" or v42:IsA("Model") or v42:IsA("BasePart") and v42.Name ~= "Default" then
						v42:Destroy()
					end
				end

				default.Transparency = 0
				local n19 = bit32.band(n18, 1073210230) - 1073739640
			end

			local v40 = next
			local children, v41 = arg:GetChildren()

			for _, v42 in v40, children, v41 do
				if (v42:IsA("Model") or v42:IsA("MeshPart")) and v42 ~= default and v42.Name ~= "Handle" then
					v42:Destroy()
				end
			end

			scKnifeData[arg] = nil
		end

		fn7 = function(arg, arg2, name)
			local n16 = 3368072271
			local n17 = 3059674988
			local n18 = 1325570048
			local n19 = 2173772986
			local n20 = 2214854946
			local n21 = n19 + 2214389395
			if not fn5(name) then
				return
			end
			local flag = arg2.Parent ~= arg
			local n22 = bit32.rshift(n18, 14)
			if flag then
				return
			end
			local humanoid = arg:FindFirstChild("Humanoid")
			local rightHand = arg:FindFirstChild("RightHand")
			if not humanoid or not rightHand then
				return
			end
			local v39 = scKnifeData[arg2]
			local welds

			if v39 then
				welds = v39.welds
				n20 = n20 - 1176148985 + 1176148985
			else
				welds = v39
			end

			if welds and #v39.welds > 0 then
				local default = arg2:FindFirstChild("Default")

				if default then
					local default2 = arg2:FindFirstChild("Default")
					local v40 = table.pack(bit32.band(n22, 4294967295))
					local v41 = table.pack(bit32.band(n20, 4294967295))
					local v42 = table.pack(bit32.band(v40[1], 65535))
					local v43 = table.pack(bit32.rshift(v40[1], 16))
					local v44 = table.pack(bit32.band(v41[1], 65535))
					local v45 = bit32.band(v42[1] * v44[1] + bit32.lshift(bit32.band(v42[1] * bit32.rshift(v41[1], 16) + v43[1] * v44[1], 65535), 16), 4294967295)
					default = default2:FindFirstChild("Handle.R")
					n22 = v45 - 428656458
				end

				if default and default.Parent then
					local motor6D = default:FindFirstChildOfClass("Motor6D")

					if motor6D then
						motor6D.Part0 = rightHand
					end

					local default2 = arg2:FindFirstChild("Default")

					if default2 then
						default2.Transparency = 1
						local v40 = next
						local children, v41 = default2:GetChildren()

						for _, v42 in v40, children, v41 do
							if (v42:IsA("Model") or v42:IsA("MeshPart")) and v42.Name ~= name then
								v42:Destroy()
							end
						end
					end

					local v40 = next
					local children, v41 = arg2:GetChildren()
					local n23 = n20 // n22

					for _, v42 in v40, children, v41 do
						if (v42:IsA("Model") or v42:IsA("MeshPart")) and v42 ~= default2 and v42.Name ~= "Handle" and v42.Name ~= name then
							v42:Destroy()
						end
					end

					local animator = humanoid:FindFirstChildOfClass("Animator")

					if animator then
						local str2 = name:gsub(" ", "")
						bit32.bxor(n17, n19)
						local animationId, soundId

						if str2 == "GoldenAgeTanto" then
							n23 = bit32.bxor(bit32.rshift(n23, 27), 27375)
							animationId = "rbxassetid://13473404819"
							soundId = "rbxassetid://5917819099"
						elseif str2 == "GPO-Knife" or str2 == "GPO-KnifePrestige" then
							animationId = "rbxassetid://14014278925"
							soundId = "rbxassetid://4604390759"
						elseif str2 == "Heaven" then
							n22 = bit32.lshift(n22, 5) + 4292459210
							animationId = "rbxassetid://14500266726"
							soundId = "rbxassetid://14489860007"
						elseif str2 == "PurpleDagger" then
							animationId = "rbxassetid://17824999722"
							soundId = "rbxassetid://17822743153"
						elseif str2 == "BlueDagger" then
							animationId = "rbxassetid://17824995184"
							soundId = "rbxassetid://17822737046"
						else
							local n24 = n22 + 2861004426

							if str2 == "GreenDagger" then
								animationId = "rbxassetid://17825004320"
								soundId = "rbxassetid://17822741762"
							else
								animationId = nil
								soundId = nil

								if str2 == "RedDagger" then
									animationId = "rbxassetid://17825008844"
									soundId = "rbxassetid://17822952417"
								end
							end

							n22 = n24 + 1433962870
						end

						if animationId then
							local track = v39.track
							local v42 = bit32.band(n23, 235974836)

							if track then
								v39.track:Stop()
								v39.track:Destroy()
								local v43 = bit32.bxor(n21, 28526870)
								v39.track = nil
								n21 = bit32.bxor(v43, 28526870)
								n22 = n22 // 14 + 75127
							end

							local animation = Instance.new("Animation")
							animation.AnimationId = animationId
							local v43 = animator:LoadAnimation(animation)
							v43.Looped = false
							v43:Play()
							v39.track = v43
							animation:Destroy()

							v43.Ended:Once(function()
								local n24 = 852594289
								local n25 = 810620926

								if v39.track == v43 then
									local v44 = v39
									bit32.bxor(n24, 2152559947)
									v44.track = nil
								end

								v43:Destroy()
							end)

							n23 = v42 + 19019
						end

						if soundId then
							local new = Instance.new
							local v42 = bit32.bxor(n21, 0)
							local v43 = table.pack(bit32.band(n23, 4294967295))
							local v44 = table.pack(bit32.band(v42, 4294967295))
							local v45 = table.pack(bit32.band(v43[1], 65535))
							local v46 = table.pack(bit32.rshift(v43[1], 16))
							local v47 = table.pack(bit32.band(v44[1], 65535))
							local v48 = bit32.band(v45[1] * v47[1] + bit32.lshift(bit32.band(v45[1] * bit32.rshift(v44[1], 16) + v46[1] * v47[1], 65535), 16), 4294967295)
							local Sound = new("Sound")
							Sound.SoundId = soundId
							Sound.Parent = Workspace
							Sound:Play()
							local insert = table.insert
							local sounds = v39.sounds
							local n24 = n22 + bit32.bxor(n21, 0) + bit32.bxor(n21, 0)
							insert(sounds, Sound)

							Sound.Ended:Connect(function()
								Sound:Destroy()
							end)

							bit32.bxor(v48, 4850700)
						end
					end

					return
				end
			end

			fn6(arg2)
			local v40 = scKnifeData
			local tbl21 = {}
			local v41 = bit32.bor(n20, n22)
			tbl21.track = nil
			local v42 = bit32.bxor(n21, 503066263)
			tbl21.welds = {}
			tbl21.sounds = {}
			v40[arg2] = tbl21
			local v43 = table.pack(bit32.band(v41, 4294967295))
			local v44 = table.pack(bit32.band(v43[1], 65535))
			local v45 = bit32.band(v44[1] * 41473 + bit32.lshift(bit32.band(v44[1] * 0 + bit32.rshift(v43[1], 16) * 41473, 65535), 16), 4294967295)
			local v46 = scKnifeData[arg2]
			local default = arg2:FindFirstChild("Default")
			if not default then
				return
			end
			default.Transparency = 1
			local knives = skinModules:FindFirstChild("Knives")
			if not knives then
				return
			end
			local v47 = knives:FindFirstChild(name)
			if not v47 then
				return
			end
			local clone = v47:Clone()
			local v48 = bit32.bxor(v42, 0)
			local v49 = bit32.bor(n22, v48)
			clone.Name = name
			local n23 = v49 // v45
			local part = Instance.new("Part")
			part.Name = "Handle.R"
			part.Transparency = 1
			part.CanCollide = false
			part.Anchored = false
			local n24 = v45 + n23
			part.Size = Vector3New(0.001, 0.001, 0.001)
			local n25 = bit32.bor(n23, 2389187360)
			part.Massless = true
			part.Parent = default
			local v50 = Instance
			local v51 = bit32.bxor(v42, 0)
			local v52 = bit32.band(n24, v51)
			local Motor6D = v50.new("Motor6D")
			Motor6D.Name = "Handle.R"
			Motor6D.Part0 = rightHand
			local v53 = n25
			Motor6D.Part1 = part
			Motor6D.Parent = part
			local str2 = name:gsub(" ", "")
			local c0, n26, animationId, soundId

			if str2 == "GoldenAgeTanto" then
				local v54 = CFrameNew
				local v55 = bit32.lshift(n25, 21)
				local v56 = v54(0, -0.2, -1.2)
				local cframe = CFrame.Angles
				local v57 = MathRad(90)
				local v58 = table.pack(bit32.band(v53, 4294967295))
				local v59 = table.pack(bit32.band(v58[1], 65535))
				local v60 = bit32.band(v59[1] * 14158 + bit32.lshift(bit32.band(v59[1] * 0 + bit32.rshift(v58[1], 16) * 14158, 65535), 16), 4294967295)
				local v61 = MathRad(263.7)
				local v62 = MathRad
				local v63 = bit32.bxor(v42, 262110481)
				c0 = v56 * cframe(v57, v61, v62(180))
				local v64 = bit32.band(v55, v60)
				v42 = bit32.bxor(v63, 262110481)
				n25 = v64 + 1315445536
				n26 = v60 + 3436967776
				animationId = "rbxassetid://13473404819"
				soundId = "rbxassetid://5917819099"
			elseif str2 == "GPO-Knife" or str2 == "GPO-KnifePrestige" then
				local v54 = CFrameNew(0, -0.32, -1.07)
				local v55 = CFrame
				local v56 = bit32.band(n25, 4079118730)
				local angles = v55.Angles
				local v57 = MathRad(90)
				local v58 = bit32.bxor(v42, 422132448)
				local v59 = MathRad
				local n27 = v53 - bit32.bxor(v58, 0)
				c0 = v54 * angles(v57, v59(-97.4), MathRad(90))
				v42 = bit32.bxor(v58, 422132448)
				n25 = bit32.bxor(v56 - n27, 2071664186)
				n26 = n27 - 4272218310
				animationId = "rbxassetid://14014278925"
				soundId = "rbxassetid://4604390759"
			elseif str2 == "Heaven" then
				local cframe = CFrame.Angles
				local v54 = MathRad
				local n27 = v53 - n25
				c0 = CFrameNew(-0.02, -0.82, 0.2) * cframe(MathRad(64.42), MathRad(3.79), v54(0))
				n25 = bit32.bxor(n25 // bit32.bxor(v42, 0), 2389187365)
				n26 = bit32.bxor(n27, 2389187360)
				animationId = "rbxassetid://14500266726"
				soundId = "rbxassetid://14489860007"
			elseif str2 == "LoveKukri" then
				local cframe = CFrame.Angles
				n26 = n25
				local v54 = MathRad
				c0 = CFrameNew(-0.14, 0.14, -1.62) * cframe(MathRad(-90), MathRad(180), v54(-4.97))
				animationId = nil
				soundId = nil
			else
				local n27

				if str2 == "PurpleDagger" then
					local v54 = CFrameNew
					local v55 = table.pack(bit32.band(n25, 4294967295))
					local v56 = table.pack(bit32.band(v55[1], 65535))
					local v57 = bit32.band(v56[1] * 64167 + bit32.lshift(bit32.band(v56[1] * 0 + bit32.rshift(v55[1], 16) * 64167, 65535), 16), 4294967295)
					local v58 = v54(-0.13, -0.24, -1.8)
					local cframe = CFrame.Angles
					local v59 = MathRad(89.05)
					local v60 = MathRad
					local v61 = table.pack(bit32.band(v42, 4294967295))
					local v62 = table.pack(bit32.band(v61[1], 65535))
					local n28 = bit32.band(18392 * v62[1] + bit32.lshift(bit32.band(18392 * bit32.rshift(v61[1], 16) + 15990 * v62[1], 65535), 16), 4294967295) + 1910944016
					local v63 = bit32.bxor(v42, 0)
					local v64 = bit32.bxor(v53, v63)
					local v65 = table.pack(bit32.band(bit32.bor(v42, 104000710), 4294967295))
					local v66 = table.pack(bit32.band(v65[1], 65535))
					local v67 = bit32.band(28752 * v66[1] + bit32.lshift(bit32.band(28752 * bit32.rshift(v65[1], 16) + 33555 * v66[1], 65535), 16), 4294967295)
					local v68 = table.pack(bit32.band(bit32.bxor(v42, 104000710), 4294967295))
					local v69 = table.pack(bit32.band(v68[1], 65535))
					local n29 = n28 + v67 + bit32.band(18393 * v69[1] + bit32.lshift(bit32.band(18393 * bit32.rshift(v68[1], 16) + 15990 * v69[1], 65535), 16), 4294967295)
					bit32.bxor(n16, v67)
					local v70 = n29
					local v71 = v60(96.63)
					local v72 = MathRad
					n27 = bit32.bor(v64, 573998547)
					c0 = v58 * cframe(v59, v71, v72(180))
					v42 = bit32.bxor(v70, 104000710)
					n25 = bit32.rshift(v57 + 885459297, 24) + 2389187163
					animationId = "rbxassetid://17824999722"
					soundId = "rbxassetid://17822743153"
				else
					local n28

					if str2 == "BlueDagger" then
						local v54 = CFrameNew
						local n29 = n25 + bit32.bxor(v42, 0)
						local v55 = v54(-0.13, -0.24, -1.8)
						local v56 = MathRad
						local cframe = CFrame.Angles(MathRad(89.05), MathRad(96.63), v56(180))
						n28 = v53 + bit32.bxor(v42, 0)
						c0 = v55 * cframe
						n25 = bit32.bxor(n29, 682777562)
						animationId = "rbxassetid://17824995184"
						soundId = "rbxassetid://17822737046"
					else
						local n29 = v53 - 1788703313

						if str2 == "GreenDagger" then
							local v54 = CFrameNew(-0.13, -0.24, -1.07)
							local cframe = CFrame.Angles
							local v55 = MathRad
							local v56 = table.pack(bit32.band(n25, 4294967295))
							local v57 = table.pack(bit32.band(v56[1], 65535))
							local v58 = bit32.band(v57[1] * 5270 + bit32.lshift(bit32.band(v57[1] * 0 + bit32.rshift(v56[1], 16) * 5270, 65535), 16), 4294967295)
							local v59 = v55(89.05)
							local v60 = MathRad
							c0 = v54 * cframe(v59, MathRad(96.63), v60(180))
							local v61 = bit32.bxor(v42, 0)
							local v62 = table.pack(bit32.band(v58, 4294967295))
							local v63 = table.pack(bit32.band(v61, 4294967295))
							local v64 = table.pack(bit32.band(v62[1], 65535))
							local v65 = table.pack(bit32.rshift(v62[1], 16))
							local v66 = table.pack(bit32.band(v63[1], 65535))
							n25 = bit32.band(v64[1] * v66[1] + bit32.lshift(bit32.band(v64[1] * bit32.rshift(v63[1], 16) + v65[1] * v66[1], 65535), 16), 4294967295) - 4220088416
							animationId = "rbxassetid://17825004320"
							soundId = "rbxassetid://17822741762"
						else
							c0 = nil
							animationId = nil
							soundId = nil

							if str2 == "RedDagger" then
								local v54 = CFrameNew(-0.13, -0.24, -1.07)
								local cframe = CFrame.Angles
								local v55 = MathRad
								local v56 = bit32.bxor(v42, 0)
								local v57 = table.pack(bit32.band(n29, 4294967295))
								local v58 = table.pack(bit32.band(v56, 4294967295))
								local v59 = table.pack(bit32.band(v57[1], 65535))
								local v60 = table.pack(bit32.rshift(v57[1], 16))
								local v61 = table.pack(bit32.band(v58[1], 65535))
								local v62 = bit32.band(v59[1] * v61[1] + bit32.lshift(bit32.band(v59[1] * bit32.rshift(v58[1], 16) + v60[1] * v61[1], 65535), 16), 4294967295)
								local v63 = v55(89.05)
								local v64 = MathRad
								c0 = v54 * cframe(v63, MathRad(96.63), v64(180))
								n29 = v62 + 4137040024 + 3557606641
								animationId = "rbxassetid://17825008844"
								soundId = "rbxassetid://17822952417"
							end
						end

						n28 = n29 + 2198837291
					end

					n27 = n28 - 4036722943
				end

				n26 = bit32.bxor(n27, 945202395)
			end

			if not c0 then
				return
			end

			if clone:IsA("Model") then
				if not clone.PrimaryPart then
					local v54 = next
					local children, v55 = clone:GetChildren()

					for _, v56 in v54, children, v55 do
						if v56:IsA("BasePart") then
							clone.PrimaryPart = v56
							break
						end
					end
				end

				if clone.PrimaryPart then
					local v54 = next
					local n27 = n25 // 84
					local descendants, v55 = clone:GetDescendants()

					for _, v56 in v54, descendants, v55 do
						if v56:IsA("BasePart") then
							local v57 = bit32.bxor(v42, 360748344)
							v56.CanCollide = false
							v56.Massless = true
							v56.Anchored = false
							local weld = Instance.new("Weld")
							weld.Part0 = part
							weld.Part1 = v56
							weld.C0 = c0
							weld.C1 = v56.CFrame:ToObjectSpace(clone.PrimaryPart.CFrame)
							weld.Parent = v56
							table.insert(v46.welds, weld)
							v42 = bit32.bxor(v57, 360748344)
						end
					end

					n25 = n27 - 1934222642
				end

				clone.Parent = default
			elseif clone:IsA("BasePart") then
				clone.CanCollide = false
				local v54 = table.pack(bit32.band(n26, 4294967295))
				local v55 = table.pack(bit32.band(n25, 4294967295))
				local v56 = table.pack(bit32.band(v54[1], 65535))
				local v57 = table.pack(bit32.rshift(v54[1], 16))
				local v58 = table.pack(bit32.band(v55[1], 65535))
				bit32.band(v56[1] * v58[1] + bit32.lshift(bit32.band(v56[1] * bit32.rshift(v55[1], 16) + v57[1] * v58[1], 65535), 16), 4294967295)
				clone.Massless = true
				clone.Anchored = false
				clone.Parent = default
				local weld = Instance.new("Weld")
				weld.Part0 = part
				weld.Part1 = clone
				weld.C0 = c0
				weld.Parent = clone
				local insert = table.insert
				local v59 = bit32.bxor(v42, 0)
				local v60 = bit32.bxor(v42, 352714051)
				insert(v46.welds, weld)
				v42 = bit32.bxor(v60, 352714051)
				n25 = n25 // 14 - 2076436176
				n26 = v59 + 1979053382
			end

			local animator = humanoid:FindFirstChildOfClass("Animator")

			if not animator then
				n25 = n26
				animator = Instance.new("Animator")
				animator.Parent = humanoid
			end

			if animationId then
				local animation = Instance.new("Animation")
				animation.AnimationId = animationId
				local v54 = animator:LoadAnimation(animation)
				v54.Looped = false
				local v55 = table.pack(bit32.band(v42, 4294967295))
				local v56 = table.pack(bit32.band(v55[1], 65535))
				local v57 = bit32.band(54151 * v56[1] + bit32.lshift(bit32.band(54151 * bit32.rshift(v55[1], 16) + 64464 * v56[1], 65535), 16), 4294967295)
				local v58 = table.pack(bit32.band(bit32.bnot(v42), 4294967295))
				local v59 = table.pack(bit32.band(v58[1], 65535))
				local n27 = 5143598271 + v57 + bit32.band(54151 * v59[1] + bit32.lshift(bit32.band(54151 * bit32.rshift(v58[1], 16) + 64464 * v59[1], 65535), 16), 4294967295) + 81768567
				local n28 = n26 + bit32.bxor(v42, 0)
				v54:Play()
				v46.track = v54
				animation:Destroy()
				local n29 = n27 - 172779888 - 280968957 - 6025317 + 361435651 + 5760880 - 355277729
				local ended = v54.Ended
				local once = ended.Once

				local function fn14()
					if v46.track == v54 then
						v46.track = nil
					end

					v54:Destroy()
				end

				bit32.bxor(n28, 255829496)
				once(ended, fn14)
				n25 = n25 // 146 + 2372823064
				n26 = bit32.bxor(n28, 682777562)
			end

			if soundId then
				local v54 = Instance
				local v55 = bit32.bor(n26, 3152409992)
				local v56 = bit32.bxor(v42, 381645323)
				local Sound = v54.new("Sound")
				Sound.SoundId = soundId
				Sound.Parent = Workspace
				Sound:Play()
				local insert = table.insert
				local sounds = v46.sounds
				local v57 = bit32.lshift(n25, 31)
				insert(sounds, Sound)

				Sound.Ended:Connect(function()
					Sound:Destroy()
				end)

				local n27 = v55 // bit32.bxor(v56, 0)
				v42 = bit32.bxor(v56, 381645323)
				n25 = bit32.bxor(v57, 2389187360)
				n26 = n27 - 1905779948
			end

			v46.conns = v46.conns or {}

			local function fn14()
				local n27 = 1263619027
				local n28 = 1613644732
				local n29 = 3940847801
				if scKnifeData[arg2] ~= v46 then
					return
				end

				if default and default.Parent then
					default.Transparency = 1
					local v54 = next
					local children, v55 = default:GetChildren()

					for _, v56 in v54, children, v55 do
						local isModel = v56:IsA("Model") or v56:IsA("MeshPart")

						if isModel then
							local name2 = v56.Name
							local v57 = name
							n27 = bit32.bxor(n27, 4278923576)
							isModel = name2 ~= v57
						end

						if isModel then
							v56:Destroy()
						end
					end
				end

				local v54 = next
				local children, v55 = arg2:GetChildren()
				bit32.bxor(n28, 1928472954)

				for _, v56 in v54, children, v55 do
					if (v56:IsA("Model") or v56:IsA("MeshPart")) and v56 ~= default and v56.Name ~= "Handle" and v56.Name ~= name then
						v56:Destroy()
					end
				end
			end

			local connection4 = arg2.ChildAdded:Connect(function(child)
				local n27 = 827198797
				local n28 = 3876501627
				local n29 = 137921825
				local n30 = 985443850
				local flag2 = (child:IsA("Model") or child:IsA("MeshPart")) and child ~= default

				if flag2 then
					local name2 = child.Name
					local v54 = table.pack(bit32.band(n30, 4294967295))
					local v55 = table.pack(bit32.band(n28, 4294967295))
					local v56 = table.pack(bit32.band(v54[1], 65535))
					local v57 = table.pack(bit32.rshift(v54[1], 16))
					local v58 = table.pack(bit32.band(v55[1], 65535))
					flag2 = name2 ~= "Handle"
					n30 = bit32.band(v56[1] * v58[1] + bit32.lshift(bit32.band(v56[1] * bit32.rshift(v55[1], 16) + v57[1] * v58[1], 65535), 16), 4294967295) - 630071492
				end

				if flag2 then
					local name2 = child.Name
					local v54 = name
					bit32.bxor(n29, 455748556)
					flag2 = name2 ~= v54
				end

				if flag2 then
					task.defer(fn14)
					bit32.bxor(n27, 1940804983)
					local n31 = bit32.band(n28, n30) + 3305246833
				end
			end)

			table.insert(v46.conns, connection4)

			if default then
				local v54 = table.pack(bit32.band(v51, 4294967295))
				local v55 = table.pack(bit32.band(v54[1], 65535))
				local v56 = bit32.band(37479 * v55[1] + bit32.lshift(bit32.band(37479 * bit32.rshift(v54[1], 16) + 2703 * v55[1], 65535), 16), 4294967295)
				local v57 = table.pack(bit32.band(bit32.bnot(v51), 4294967295))
				local v58 = table.pack(bit32.band(v57[1], 65535))
				local n27 = 986166409 + v56 + bit32.band(37479 * v58[1] + bit32.lshift(bit32.band(37479 * bit32.rshift(v57[1], 16) + 2703 * v58[1], 65535), 16), 4294967295)
				local childAdded = default.ChildAdded
				local v59 = table.pack(bit32.band(n27, 4294967295))
				local v60 = table.pack(bit32.band(v59[1], 65535))
				local n28 = 4150563413 + bit32.band(43150 * v60[1] + bit32.lshift(bit32.band(43150 * bit32.rshift(v59[1], 16) + 53331 * v60[1], 65535), 16), 4294967295)
				local v61 = table.pack(bit32.band(v51, 4294967295))
				local v62 = table.pack(bit32.band(v61[1], 65535))
				local v63 = bit32.band(43149 * v62[1] + bit32.lshift(bit32.band(43149 * bit32.rshift(v61[1], 16) + 53331 * v62[1], 65535), 16), 4294967295)
				local v64 = table.pack(bit32.band(bit32.bor(v51, n27), 4294967295))
				local v65 = table.pack(bit32.band(v64[1], 65535))
				local v66 = bit32.band(22387 * v65[1] + bit32.lshift(bit32.band(22387 * bit32.rshift(v64[1], 16) + 12204 * v65[1], 65535), 16), 4294967295)
				local v67 = table.pack(bit32.band(bit32.band(v51, n27), 4294967295))
				local v68 = table.pack(bit32.band(v67[1], 65535))
				local n29 = n28 + v63 + v66 + bit32.band(22387 * v68[1] + bit32.lshift(bit32.band(22387 * bit32.rshift(v67[1], 16) + 12204 * v68[1], 65535), 16), 4294967295)

				local connection5 = childAdded:Connect(function(arg3)
					local n30 = 761019704
					local n31 = 2242985225
					local n32 = 2202372745
					local isModel = arg3:IsA("Model") or arg3:IsA("MeshPart")

					if isModel then
						bit32.bxor(n30, 740644117)
						isModel = arg3.Name ~= name
					end

					if isModel then
						task.defer(fn14)
						local v69 = n32
					end
				end)

				table.insert(v46.conns, connection5)

				local function fn15()
					local n30 = 1936589042
					local flag2 = scKnifeData[arg2] == v46

					if flag2 and default.Transparency ~= 1 then
						default.Transparency = 1
					end
				end

				local connection6 = default:GetPropertyChangedSignal("Transparency"):Connect(fn15)
				table.insert(v46.conns, connection6)
				local n30 = bit32.lshift(n26, 16) + 1934105376
			end
		end

		fn8 = function()
			return skinModules2
		end
	end

	local fn9

	fn9 = function(arg, arg2)
		local n13 = 1375029431
		local n14 = 3276316213
		local v35 = fn8()
		if not v35 then
			return nil
		end
		local v36 = v35[arg]

		if not v36 then
			v36 = v35["[" .. arg:gsub("%[", ""):gsub("%]", "") .. "]"]
			n14 = bit32.bxor(bit32.bxor(n14, 4294967295), 4294967295)
		end

		if not v36 then
			return nil
		end
		local v37 = v36[arg2]
		bit32.rshift(n14, 27)
		v37 = v37 or v36[arg2:gsub("-", " ")]

		if not v37 then
			local str2 = arg2:gsub("-", "")
			bit32.bxor(n13, 2973750048)
			v37 = v36[str2]
		end

		return v37
	end

	local v35
	v35 = bit32.bxor(v33, 0)
	local v36, fn10

	do
		local function fn11(arg, arg2)
			local n13 = 1605597739
			local n14 = 665323071
			local n15 = 2259560914
			local n16 = 1846756272
			if not v32 then
				bit32.bxor(n14, 193075258)
				return nil
			end
			local gunShootSounds = v32:FindFirstChild("GunShootSounds")
			if not gunShootSounds then
				return nil
			end
			local v37 = gunShootSounds:FindFirstChild(arg)
			bit32.bxor(n13, 3834638342)
			bit32.band(n15, n16)
			if not v37 then
				return nil
			end
			local v38 = v37:FindFirstChild(arg2)
			if v38 and v38:IsA("StringValue") then
				return v38.Value
			end
			return nil
		end

		local fn12 = nil
		v36 = bit32.band(v34, 1112456898)

		local function fn13(arg)
			local n13 = 2429292989
			local n14 = 1926077711
			local n15 = 505495196
			if not arg then
				return nil
			end
			local v37 = next
			local descendants, v38 = arg:GetDescendants()
			local v39 = table.pack(bit32.band(n15, 4294967295))
			local v40 = table.pack(bit32.band(n14, 4294967295))
			local v41 = table.pack(bit32.band(v39[1], 65535))
			local v42 = table.pack(bit32.rshift(v39[1], 16))
			local v43 = table.pack(bit32.band(v40[1], 65535))
			bit32.band(v41[1] * v43[1] + bit32.lshift(bit32.band(v41[1] * bit32.rshift(v40[1], 16) + v42[1] * v43[1], 65535), 16), 4294967295)

			for _, v44 in v37, descendants, v38 do
				if v44:IsA("Sound") and (v44.Name == "Shoot" or v44.Name == "ShootSound") then
					return v44
				end
			end

			bit32.bxor(n13, 3008221759)
			return nil
		end

		local function fn14(arg)
			local n13 = 2072050373
			local n14 = 787307706
			local n15 = 852165794
			local n16 = 2072935019
			local v37 = scAppliedSkins[arg]
			if not v37 then
				return
			end
			local v38 = fn13(arg)
			if not v38 then
				return
			end
			local n17 = n16 * 2

			if not v37.ShootSoundOriginals then
				v37.ShootSoundOriginals = {}
			end

			local v39 = bit32.bor(n15, n17)

			if v37.ShootSoundOriginals[v38] == nil then
				v37.ShootSoundOriginals[v38] = v38.SoundId
			end

			v37.ShootSound = v38
			local v40 = fn11
			local v41 = bit32.bor(v39, n17)
			local v42 = v40(arg.Name, v37.SkinName)

			if v42 and v42 ~= "" then
				bit32.bxor(n13, 3349023371)
				v38.SoundId = v42
				local n18 = v41 - 12779552
				bit32.bxor(n14, 3017331053)
			end
		end

		local function fn15(arg, arg2, arg3)
			local flag = type(0) ~= "number"
			local n13 = 2389837793
			local n14 = 1653501137
			local n15 = 2922162562
			local n16 = 420367620
			if not arg or not arg2 then
				return
			end

			local function fn16(arg4, arg5)
				local v37 = bit32.bxor(arg5, 0)
				local v38 = bit32.bxor(arg5, 0)
				bit32.bxor(v37, 3299967074)
				bit32.bxor(v38, 4057365181)
				local bxor = bit32.bxor
				local v39 = bit32.bxor(arg5, 0)
				bxor(2439487574, v39)
				return #arg4 == 0 or arg4 == "\0"
			end

			bit32.bxor(n13, 2046973015)
			bit32.band(n15, 208439956)
			local v37 = next
			local children, v38 = arg:GetChildren()

			for _, v39 in v37, children, v38 do
				if v39:IsA("MeshPart") and v39 ~= arg2 and v39 ~= arg3 and not fn16(v39.Name, 237367316, 229648844) then
					v39:Destroy()
				end
			end

			local v39 = next
			local children2, v40 = arg2:GetChildren()

			for _, v41 in v39, children2, v40 do
				local isMeshPart = v41:IsA("MeshPart")

				if isMeshPart then
					local name = v41.Name
					n14 = bit32.bxor(n14, 4128651700)
					isMeshPart = not fn16(name, 237367316, 41139669)
				end

				if isMeshPart then
					v41:Destroy()
				end
			end
		end

		local function fn16(arg)
			local n13 = 3032915031
			local n14 = 4233298401
			local n15 = 180370686
			local n16 = 3384447802
			local v37 = scAppliedSkins[arg]
			if not v37 then
				return
			end
			local default = v37.Default
			local flag = not default

			if not flag then
				flag = not default.Parent
				n16 = n16 // 2 - 2602743395
			end

			if flag then
				return
			end
			local handle

			if arg then
				handle = arg:FindFirstChild("Handle")
				bit32.bxor(n13, 2729702205)
			else
				handle = arg
			end

			fn15(arg, default, handle)

			if v37.HideDefault then
				local transparency = default.Transparency
				bit32.bxor(n14, 2048092284)

				if transparency ~= 1 then
					default.Transparency = 1
				end
			else
				local n17 = n15 + 1232233256

				if v37.DesiredTransparency ~= nil and default.Transparency ~= v37.DesiredTransparency then
					default.Transparency = v37.DesiredTransparency
				end

				local flag2 = v37.DesiredTextureID ~= nil
				local v38 = table.pack(bit32.band(n16, 4294967295))
				local v39 = table.pack(bit32.band(n17, 4294967295))
				local v40 = table.pack(bit32.band(v38[1], 65535))
				local v41 = table.pack(bit32.rshift(v38[1], 16))
				local v42 = table.pack(bit32.band(v39[1], 65535))
				local n18 = bit32.band(v40[1] * v42[1] + bit32.lshift(bit32.band(v40[1] * bit32.rshift(v39[1], 16) + v41[1] * v42[1], 65535), 16), 4294967295)

				if flag2 then
					flag2 = default.TextureID ~= v37.DesiredTextureID
					n18 = bit32.bxor(n18, 4294967295) - 1374407367
				end

				if flag2 then
					default.TextureID = v37.DesiredTextureID
				end
			end
		end

		fn10 = function(arg)
			local n13 = 3389426396
			local n14 = 1080628632
			local n15 = 1491402306
			if not arg or not scAppliedSkins[arg] then
				return
			end
			fn6(arg)
			local v37 = scAppliedSkins[arg]
			local v38 = table.pack(bit32.band(n14, 4294967295))
			local v39 = table.pack(bit32.band(n15, 4294967295))
			local v40 = table.pack(bit32.band(v38[1], 65535))
			local v41 = table.pack(bit32.rshift(v38[1], 16))
			local v42 = table.pack(bit32.band(v39[1], 65535))
			local n16 = bit32.band(v40[1] * v42[1] + bit32.lshift(bit32.band(v40[1] * bit32.rshift(v39[1], 16) + v41[1] * v42[1], 65535), 16), 4294967295)

			if v37.Connections then
				for _, v43 in next, v37.Connections, nil do
					if v43 and v43.Connected then
						v43:Disconnect()
					end
				end
			end

			local v43 = next
			local n17 = bit32.rshift(n15, 13)
			local clonedChildren = v37.ClonedChildren or {}

			for _, v44 in v43, clonedChildren, nil do
				if v44 and v44.Parent then
					v44:Destroy()
				end
			end

			if v37.Default and v37.Default.Parent then
				local v44 = next
				local default = v37.Default
				bit32.bxor(n13, 3598276763)
				local n18 = n17 - n16
				local children, v45 = default:GetChildren()

				for _, v46 in v44, children, v45 do
					if v46.Name == "\0" then
						v46:Destroy()
					end
				end

				local default2 = v37.Default
				local originalTransparency = v37.OriginalTransparency

				if not originalTransparency then
					n16 = bit32.bxor(n16 + 2120809391, 2175352303)
					originalTransparency = 0
				end

				default2.Transparency = originalTransparency
				local default3 = v37.Default
				local originalTextureID = v37.OriginalTextureID
				local v46 = bit32.bor(n16, 2798924739)
				default3.TextureID = originalTextureID or ""
				n17 = bit32.bxor(n18, 2786894544)
				n16 = v46 + 1508896061
			end

			if v37.ShootSoundOriginals then
				for k, v44 in next, v37.ShootSoundOriginals, nil do
					if k and k.Parent and v44 then
						k.SoundId = v44
					end
				end
			elseif v37.ShootSound and v37.OriginalShootSoundId then
				v37.ShootSound.SoundId = v37.OriginalShootSoundId
				n17 = n16 + 2787010039
			end

			local handle = arg:FindFirstChild("Handle")

			if handle then
				handle:SetAttribute("SkinName", v37.OriginalSkinName or "")
			end

			local v44 = scAppliedSkins
			bit32.band(n17, n16)
			v44[arg] = nil
		end

		local function fn17(arg, arg2)
			local flag = type(19664087) == "table"
			local n13 = 2757448345
			local n14 = 1958786940
			local n15 = 496502901
			if not arg or tbl18[arg] then
				return
			end
			local v37 = tbl18
			bit32.bxor(n13, 457813722)
			v37[arg] = true
			local delay = task.delay
			local n16 = n15 - 418265194
			bit32.bxor(n14, 1028844864)

			delay(0.35, function()
				local n17 = 1518956383
				local n18 = 3753218897
				local v38 = scAppliedSkins[arg]
				local n19 = 3829417810 - n18
				if not v38 or v38.SkinName ~= arg2 then
					return
				end
				fn10(arg)
				local v39 = fn12
				bit32.bxor(n17, 1120530713)
				bit32.band(n18, n19)
				v39(arg, arg2)
			end)
		end

		fn12 = function(parent, arg)
			local n13 = 1980512499
			local n14 = 2396999109
			local n15 = 274501892
			local n16 = 3222274048
			if not parent then
				return
			end

			if scAppliedSkins[parent] and scAppliedSkins[parent].SkinName == arg then
				return
			end
			local handle = parent:FindFirstChild("Handle")
			if not handle then
				return
			end
			local default = parent:FindFirstChild("Default")

			if not default or not default:IsA("MeshPart") then
				default = handle:FindFirstChildOfClass("MeshPart")

				if not default then
					local v37 = next
					local descendants, v38 = parent:GetDescendants()

					for _, v39 in v37, descendants, v38 do
						if v39:IsA("MeshPart") then
							default = v39
							break
						end
					end
				end
			end

			local v37 = bit32.bor(n14, 680984367)
			if not default then
				return
			end
			local v38 = fn13(parent)

			if scAppliedSkins[parent] then
				fn10(parent)
			end

			local v39 = scAppliedSkins
			local n17 = v37 + n16
			local tbl21 = { SkinName = arg }
			local n18 = n16 + bit32.bxor(n15, 0)
			tbl21.OriginalTextureID = default.TextureID
			tbl21.OriginalTransparency = default.Transparency
			local attribute = handle:GetAttribute("SkinName")

			if not attribute then
				n17 = n18 + 2659413739
				attribute = ""
			end

			tbl21.OriginalSkinName = attribute
			tbl21.Default = default
			tbl21.ShootSound = v38
			local n19 = n15 + 433429836
			tbl21.OriginalShootSoundId = v38 and v38.SoundId or nil
			local shootSoundOriginals

			if v38 then
				shootSoundOriginals = {}
				local soundId = v38.SoundId
				local v40 = bit32.bxor(n18, 4294967295)
				shootSoundOriginals[v38] = soundId
				n18 = bit32.bxor(v40, 4294967295)
			else
				shootSoundOriginals = v38
			end

			if not shootSoundOriginals then
				shootSoundOriginals = {}
				local v40 = bit32.bxor(n19, 0)
				n18 = bit32.bor(n18, v40) - 705834576
			end

			tbl21.ShootSoundOriginals = shootSoundOriginals
			tbl21.ClonedChildren = {}
			tbl21.Connections = {}
			tbl21.DesiredTextureID = default.TextureID
			local transparency = default.Transparency
			local v40 = bit32.bxor(n19, 0)
			local v41 = bit32.bor(n17, v40)
			tbl21.DesiredTransparency = transparency
			tbl21.HideDefault = false
			local v42 = bit32.band(v41, 3297692325)
			v39[parent] = tbl21
			handle:SetAttribute("SkinName", arg)

			local connection4 = handle:GetAttributeChangedSignal("SkinName"):Connect(function()
				local n20 = 3031778009
				local n21 = 43245177

				if handle:GetAttribute("SkinName") ~= arg then
					local v43 = bit32.bor(n21, 2593883636)
					bit32.bxor(n20, 3120052712)
					handle:SetAttribute("SkinName", arg)
					local v44 = bit32.bxor(v43, 2550661508)
				end
			end)

			local insert = table.insert
			local connections = scAppliedSkins[parent].Connections
			local v43 = bit32.bxor(n19, 0)
			local v44 = table.pack(bit32.band(n18, 4294967295))
			local v45 = table.pack(bit32.band(v43, 4294967295))
			local v46 = table.pack(bit32.band(v44[1], 65535))
			local v47 = table.pack(bit32.rshift(v44[1], 16))
			local v48 = table.pack(bit32.band(v45[1], 65535))
			local v49 = bit32.band(v46[1] * v48[1] + bit32.lshift(bit32.band(v46[1] * bit32.rshift(v45[1], 16) + v47[1] * v48[1], 65535), 16), 4294967295)
			insert(connections, connection4)
			local flag = parent.Name:lower():find("knife") ~= nil or parent.Name == "[Knife]"
			local v50 = bit32.bxor(n19, 0)
			local n20 = bit32.bxor(v49, v50)
			local str2 = parent.Name:lower():sub(2, -2)
			local n21 = n19 - 427086365
			local n22 = n21
			local v51 = fn9
			local name = parent.Name
			local v52 = bit32.bxor(n22, 0)
			local n23 = bit32.bor(v42, v52)
			local v53 = v51(name, arg)
			local flag2 = not flag
			local flag3 = flag2 and v53

			if flag3 then
				flag3 = type(v53.TextureID) == "string"
				local v54 = table.pack(bit32.band(n20, 4294967295))
				local v55 = table.pack(bit32.band(v54[1], 65535))
				n20 = bit32.bxor(bit32.band(v55[1] * 59394 + bit32.lshift(bit32.band(v55[1] * 0 + bit32.rshift(v54[1], 16) * 59394, 65535), 16), 4294967295), 3383028016)
			end

			flag3 = flag3 and v53.TextureID ~= ""

			if flag2 and not v53 then
				tbl19[parent] = arg
				task.defer(fn8)
				fn14(parent)
				return
			end

			if flag2 then
				local v54 = next
				local children, v55 = parent:GetChildren()

				for _, v56 in v54, children, v55 do
					if v56:IsA("MeshPart") and v56 ~= default and v56 ~= handle then
						v56:Destroy()
					end
				end

				local v56 = next
				local v57 = table.pack(bit32.band(n23, 4294967295))
				local v58 = table.pack(bit32.band(v57[1], 65535))
				local v59 = bit32.band(v58[1] * 45836 + bit32.lshift(bit32.band(v58[1] * 0 + bit32.rshift(v57[1], 16) * 45836, 65535), 16), 4294967295)
				local children2, v60 = default:GetChildren()

				for _, v61 in v56, children2, v60 do
					if v61:IsA("MeshPart") then
						v61:Destroy()
						n22 = n22 + 179157774 - 179157774
					end
				end

				default.Transparency = scAppliedSkins[parent].OriginalTransparency or 0
				local originalTextureID = scAppliedSkins[parent].OriginalTextureID
				local v61 = bit32.bxor(n20, 2630617565)
				default.TextureID = originalTextureID or ""
				n23 = bit32.bxor(v59, 1963440931)
				n20 = v61 + 2361129027
			end

			local flag4 = flag2 and v53 and v53.TextureID and not flag3
			local children = nil

			if flag4 then
				local textureID = v53.TextureID
				local kind = typeof(textureID)
				local v54 = bit32.lshift(n23, 9)
				children = nil

				if kind == "Instance" then
					if textureID:IsA("MeshPart") then
						children = textureID
					else
						local isModel = textureID:IsA("Model") or textureID:IsA("Folder")
						children = nil

						if isModel then
							children = textureID:GetChildren()
						end
					end
				end

				n23 = bit32.bxor(v54, 721596599)
			end

			local flag5 = flag2 and not children

			if flag5 then
				flag5 = not flag3
				n13 = n23
			end

			if flag5 and skinModules then
				local flag6 = typeof(skinModules) == "Instance"
			end

			local flag6 = children and not flag
			local v54 = nil

			if flag6 then
				local v55 = typeof
				local v56 = bit32.bxor(n22, 0)

				if v55(children) == "Instance" and children:IsA("MeshPart") then
					v54 = children
				else
					n13 = n23
					v54 = nil

					if type(children) == "table" then
						v54 = nil

						for _, v57 in next, children, nil do
							if typeof(v57) == "Instance" and v57:IsA("MeshPart") then
								local str3 = v57.Name:lower()

								if str3:find("rpg") and str2 == "rpg" then
									v54 = v57
									break
								elseif str3:find("aug") and str2 == "aug" then
									v54 = v57
									break
								elseif str3:find("tac") and str2 == "tacticalshotgun" then
									v54 = v57
									break
								elseif str3:find("rev") and str2 == "revolver" then
									v54 = v57
									break
								else
									local pos = str3:find("db") or str3:find("double")

									if pos then
										pos = str2 == "double-barrel sg"

										if not pos then
											pos = str2 == "double-barrelsg"
											n22 = n22 + 379825296 - 379825296
										end
									end

									if pos then
										v54 = v57
										break
									elseif str3:find("rifle") and str2 == "rifle" then
										v54 = v57
										break
									elseif str3:find("flame") and str2 == "flamethrower" then
										v54 = v57
										break
									else
										v54 = nil
									end
								end
							else
								v54 = nil
							end
						end

						if not v54 then
							for _, v57 in next, children, nil do
								if typeof(v57) == "Instance" and v57:IsA("MeshPart") then
									v54 = v57
									break
								end
							end
						end
					end
				end

				n20 = v56 - 1539781923
			end

			local flag7

			if v54 and not flag then
				local clone = v54:Clone()
				local n24 = n20 - 3972323875
				clone.Anchored = false
				clone.CanCollide = false
				clone.CFrame = default.CFrame
				local cFrame = v53 and v53.CFrame

				if cFrame then
					local v55 = typeof
					local cFrame2 = v53.CFrame
					local n25 = n24 // bit32.bxor(n22, 0)
					cFrame = v55(cFrame2) == "CFrame"
					n24 = n25 - 936293150
				end

				local cFrame2 = cFrame and v53.CFrame
				local cframe

				if cFrame2 then
					cframe = cFrame2
				else
					n23 = n24 - 1936813622
					cframe = CFrame.new()
				end

				local weld = Instance.new("Weld")
				weld.Part0 = clone
				local v55 = bit32.bxor(n22, 0)
				local n25 = bit32.band(n23, v55)
				weld.Part1 = default
				weld.C0 = cframe:Inverse()
				weld.Name = "\0"
				weld.Parent = clone
				local n26 = n22 + 225479538
				local n27 = bit32.rshift(n24, 6)
				clone.Name = "\0"
				clone.Parent = parent
				default.Transparency = 1

				if scAppliedSkins[parent] then
					local v56 = scAppliedSkins[parent]
					local n28 = n25 // bit32.bxor(n26, 0)
					v56.HideDefault = true
					local v57 = scAppliedSkins[parent]
					local v58 = bit32.bxor(n26, 0)
					local v59 = bit32.bor(n27, v58)
					v57.DesiredTransparency = 1
					scAppliedSkins[parent].DesiredTextureID = scAppliedSkins[parent].OriginalTextureID or ""
					local insert2 = table.insert
					local v60 = scAppliedSkins[parent]
					local v61 = bit32.bxor(n26, 0)
					local v62 = bit32.band(n28, v61)
					insert2(v60.ClonedChildren, clone)
					n25 = v62 + 280845363
					n27 = v59 - 470622852
				end

				local v56 = bit32.bxor(n26, 0)
				n22 = n26 - 225479538
				n23 = n25 - 3153952124
				n20 = v56 - 1765261461
				flag7 = true
			else
				local flag8 = not flag and v53
				flag7 = false

				if flag8 then
					local textureID = v53.TextureID

					if textureID then
						local flag9 = typeof(textureID) == "Instance"
						local n24 = n22 + 200695298
						local n25

						if flag9 and textureID:IsA("MeshPart") then
							local clone = textureID:Clone()
							local n26 = n20 // 33
							clone.Anchored = false
							clone.CanCollide = false
							clone.CFrame = default.CFrame
							clone.Name = "\0"
							clone.Parent = parent
							local cFrame = v53.CFrame
							local n27 = n23 - 3095311837
							local cFrame2 = cFrame and typeof(v53.CFrame) == "CFrame" and v53.CFrame
							local v55

							if cFrame2 then
								v55 = cFrame2
							else
								local cframe = CFrame.new
								local v56 = bit32.bxor(n26, 4294967295)
								v55 = cframe()
								n26 = bit32.bxor(v56, 4294967295)
							end

							local weld = Instance.new("Weld")
							weld.Part0 = clone
							local n28 = bit32.bxor(n26, 2689577794)
							weld.Part1 = default
							weld.C0 = v55:Inverse()
							weld.Name = "\0"
							local v56 = bit32.bxor(n24, 0)
							n25 = bit32.bxor(n27, v56)
							weld.Parent = clone
							default.Transparency = 1

							if scAppliedSkins[parent] then
								scAppliedSkins[parent].HideDefault = true
								scAppliedSkins[parent].DesiredTransparency = 1
								local v57 = n25
								scAppliedSkins[parent].DesiredTextureID = scAppliedSkins[parent].OriginalTextureID or ""
								table.insert(scAppliedSkins[parent].ClonedChildren, clone)
								n28 = v57 + 608292594
							end

							n20 = n28 - 4030610129
							flag7 = true
						else
							local v55 = type
							local n26 = bit32.band(n23, 2791106601)

							if v55(textureID) == "string" then
								default.TextureID = textureID
								bit32.bxor(n13, n21)
								local n27 = n26 // bit32.bxor(n24, 0)
								default.Transparency = 0

								if scAppliedSkins[parent] then
									scAppliedSkins[parent].HideDefault = false
									scAppliedSkins[parent].DesiredTransparency = 0
									local v56 = bit32.bxor(n24, 0)
									local v57 = bit32.bxor(n20, v56)
									scAppliedSkins[parent].DesiredTextureID = textureID
									n20 = v57 - 4082071061
								end

								n26 = n27 + 68995105
							end

							n25 = n26 - 2200581426
						end

						n22 = n24 - 200695298
						n23 = n25 - 741520440
					end
				end
			end

			if flag2 and scAppliedSkins[parent] then
				bit32.bxor(n22, 188638420)

				local function fn18()
					if not scAppliedSkins[parent] then
						return
					end
					fn16(parent)
				end

				local n24 = 472790143

				local function fn19(arg2)
					local n25 = 3790268992
					local n26 = 2461571303
					local n27 = 4012843119
					local n28 = 4119593727
					local flag8 = #arg2 == 0
					local n29 = 4119593727
					local flag9

					if flag8 then
						flag9 = flag8
					else
						bit32.bxor(n26, 3274831178)
						flag9 = arg2 == "\0"
						local v55 = bit32.band(n28, n27)
						bit32.bxor(n25, 1129605551)
					end

					return flag9
				end

				local connection5 = parent.ChildAdded:Connect(function(child)
					local n25 = 1968681508
					local n26 = 946612160
					local n27 = 793240028
					local n28 = 2998249759
					local isMeshPart = child:IsA("MeshPart")

					if isMeshPart then
						local v55 = fn19
						local name2 = child.Name
						local v56 = bit32.lshift(n27, 13)
						bit32.bxor(n26, 3467186399)
						isMeshPart = not v55(name2)
						bit32.bxor(v56, 3548144092)
					end

					local flag8 = isMeshPart and child ~= default

					if flag8 then
						local v55 = handle
						bit32.bxor(n25, 447352836)
						flag8 = child ~= v55
					end

					if flag8 then
						local defer = task.defer
						local v55 = bit32.band(n28, 1756618183)
						defer(fn18)
					end
				end)

				local insert2 = table.insert
				local v55 = table.pack(bit32.band(n23, 4294967295))
				local v56 = table.pack(bit32.band(v55[1], 65535))
				local v57 = bit32.band(v56[1] * 18068 + bit32.lshift(bit32.band(v56[1] * 0 + bit32.rshift(v55[1], 16) * 18068, 65535), 16), 4294967295)
				insert2(scAppliedSkins[parent].Connections, connection5)

				local connection6 = default.ChildAdded:Connect(function(child)
					local n25 = 2151080304
					local n26 = 16293960
					local n27 = 3574992752
					local isMeshPart = child:IsA("MeshPart")
					local flag8

					if isMeshPart then
						local n28 = n25 - 2871054848
						flag8 = not fn19(child.Name)
					else
						flag8 = isMeshPart
					end

					if flag8 then
						local v58 = task
						local v59 = table.pack(bit32.band(n25, 4294967295))
						local v60 = table.pack(bit32.band(v59[1], 65535))
						local v61 = bit32.band(v60[1] * 30395 + bit32.lshift(bit32.band(v60[1] * 0 + bit32.rshift(v59[1], 16) * 30395, 65535), 16), 4294967295)
						bit32.bxor(n26, 3545243215)
						v58.defer(fn18)
						bit32.bxor(v61, 1949740448)
					end
				end)

				local v58 = table
				local v59 = bit32.bxor(n22, 0)
				local n25 = bit32.band(v57, v59)
				local n26 = n22 + 347970074
				local n27 = n26
				v58.insert(scAppliedSkins[parent].Connections, connection6)
				local n28

				if flag7 then
					local connection7 = default:GetPropertyChangedSignal("Transparency"):Connect(function()
						local n29 = 87905647
						local v60 = scAppliedSkins[parent]

						if v60 and default.Transparency ~= 1 then
							local v61 = default
							local v62 = bit32.bor(n29, 3072917888)
							v61.Transparency = 1
							local n30 = v62 - 2986344576
						end
					end)

					n28 = n20 + 3654420070
					table.insert(scAppliedSkins[parent].Connections, connection7)
				else
					local signal = default:GetPropertyChangedSignal("Transparency")
					local v60 = table.pack(bit32.band(n26, 4294967295))
					local v61 = table.pack(bit32.band(v60[1], 65535))
					local v62 = bit32.band(58035 * v61[1] + bit32.lshift(bit32.band(58035 * bit32.rshift(v60[1], 16) + 25082 * v61[1], 65535), 16), 4294967295)
					local v63 = table.pack(bit32.band(bit32.band(376844998, n26), 4294967295))
					local v64 = table.pack(bit32.band(v63[1], 65535))
					local v65 = bit32.band(7501 * v64[1] + bit32.lshift(bit32.band(7501 * bit32.rshift(v63[1], 16) + 40453 * v64[1], 65535), 16), 4294967295)
					local v66 = table.pack(bit32.band(bit32.bor(376844998, n26), 4294967295))
					local v67 = table.pack(bit32.band(v66[1], 65535))
					local n29 = 3528897566 + v62 + v65 + bit32.band(7501 * v67[1] + bit32.lshift(bit32.band(7501 * bit32.rshift(v66[1], 16) + 40453 * v67[1], 65535), 16), 4294967295)
					local v68 = table.pack(bit32.band(n27, 4294967295))
					local v69 = table.pack(bit32.band(v68[1], 65535))
					local v70 = bit32.band(41981 * v69[1] + bit32.lshift(bit32.band(41981 * bit32.rshift(v68[1], 16) + 10711 * v69[1], 65535), 16), 4294967295)
					local v71 = table.pack(bit32.band(bit32.bnot(n27), 4294967295))
					local v72 = table.pack(bit32.band(v71[1], 65535))
					local n30 = 539949181 + n29 + v70 + bit32.band(41981 * v72[1] + bit32.lshift(bit32.band(41981 * bit32.rshift(v71[1], 16) + 10711 * v72[1], 65535), 16), 4294967295)
					local v73 = table.pack(bit32.band(n26, 4294967295))
					local v74 = table.pack(bit32.band(v73[1], 65535))
					local v75 = bit32.band(48614 * v74[1] + bit32.lshift(bit32.band(48614 * bit32.rshift(v73[1], 16) + 50366 * v74[1], 65535), 16), 4294967295)
					local v76 = table.pack(bit32.band(bit32.bnot(n26), 4294967295))
					local v77 = table.pack(bit32.band(v76[1], 65535))
					local n31 = 3580528602 + n30 + v75 + bit32.band(48614 * v77[1] + bit32.lshift(bit32.band(48614 * bit32.rshift(v76[1], 16) + 50366 * v77[1], 65535), 16), 4294967295)
					local v78 = bit32.bxor(n25, n20)
					local v79 = n26
					local v80 = table.pack(bit32.band(v79, 4294967295))
					local v81 = table.pack(bit32.band(v80[1], 65535))
					local v82 = bit32.band(1433 * v81[1] + bit32.lshift(bit32.band(1433 * bit32.rshift(v80[1], 16) + 33606 * v81[1], 65535), 16), 4294967295)
					local v83 = table.pack(bit32.band(bit32.bnot(v79), 4294967295))
					local v84 = table.pack(bit32.band(v83[1], 65535))
					local v85 = v78
					local n32 = n27 - 11990490
					local n33 = 2298236745 + n31 + v82 + bit32.band(1433 * v84[1] + bit32.lshift(bit32.band(1433 * bit32.rshift(v83[1], 16) + 33606 * v84[1], 65535), 16), 4294967295) - 139605603 + 138535561 - 249160610
					local v86 = signal
					local connect = v86.Connect

					local function fn20()
						local n34 = 3222101871
						local n35 = 999297592
						local n36 = 491891063
						local v87 = scAppliedSkins[parent]
						local flag8

						if v87 then
							flag8 = v87.DesiredTransparency ~= nil
							bit32.bxor(bit32.band(n36, 1539214074), 71377157)
						else
							flag8 = v87
						end

						if flag8 then
							local transparency2 = default.Transparency
							bit32.bxor(n34, 99746892)
							flag8 = transparency2 ~= v87.DesiredTransparency
							local n37 = bit32.bxor(n35, 4294967295) - 2296372111
						end

						if flag8 then
							default.Transparency = v87.DesiredTransparency
						end
					end

					local flag8 = type(3580528602) == "table"
					local v87 = connect(v86, fn20)
					local insert3 = table.insert
					local v88 = scAppliedSkins[parent]
					local v89 = bit32.bxor(n32, 0)
					insert3(v88.Connections, v87)
					n27 = n32 + 11990490
					n25 = v85 - 2480285456
					n28 = v89 + 1778658563
				end

				local connection7 = default:GetPropertyChangedSignal("TextureID"):Connect(function()
					local n29 = 804978331
					local n30 = 2400292627
					local n31 = 3342876752
					local v60 = scAppliedSkins[parent]
					local flag8

					if v60 then
						local v61 = default
						bit32.bxor(n29, 3412348493)
						n30 = n30 + n31 - 3342876752
						flag8 = v61.TextureID ~= scAppliedSkins[parent].DesiredTextureID
					else
						flag8 = v60
					end

					if flag8 then
						local v61 = default
						local v62 = scAppliedSkins
						local v63 = bit32.bor(n30, n31)
						v61.TextureID = v62[parent].DesiredTextureID or ""
					end
				end)

				table.insert(scAppliedSkins[parent].Connections, connection7)
				local n29 = n25 - n28
				task.defer(fn18)

				task.delay(0.1, function()
					if scAppliedSkins[parent] then
						fn16(parent)
					end
				end)

				local v60 = n29
				local delay = task.delay

				local function fn20()
					local n30 = 606387296
					local n31 = 1939647462

					if scAppliedSkins[parent] then
						local v61 = fn16
						bit32.bxor(n30, 4270588105)
						v61(parent)
						local n32 = n31 - 2392818069 + 2392818069
					end
				end

				bit32.bxor(v60, 115406316)
				delay(0.35, fn20)
				n22 = n27 - 347970074
				n23 = n29 + 3539452973
				n20 = bit32.bxor(v60, 893271450)
			end

			local v55 = next
			local children2, v56 = handle:GetChildren()
			local n24 = bit32.bxor(n20, 2168750804)

			for _, v57 in v55, children2, v56 do
				if #v57.Name == 0 then
					v57:Destroy()
				end
			end

			if v32 then
				local gunHandleParticle = v32:FindFirstChild("GunHandleParticle")

				if gunHandleParticle then
					local v57 = gunHandleParticle:FindFirstChild(arg) or gunHandleParticle:FindFirstChild(arg:gsub("-", " ")) or gunHandleParticle:FindFirstChild(arg:gsub("-", ""))

					if v57 then
						local particleEmitter = v57:FindFirstChildOfClass("ParticleEmitter")
						local n25 = n23 - n24

						if particleEmitter then
							local clone = particleEmitter:Clone()
							clone.Parent = handle
							clone.Name = "\0"
							local v58 = table
							local v59 = bit32.bxor(n24, n25)
							v58.insert(scAppliedSkins[parent].ClonedChildren, clone)
							n24 = v59 - 4111267699
						end

						n23 = bit32.bxor(n25, 1270015556)
					end
				end
			end

			if flag and v32 then
				local n25 = n23 + 4193881945
				local skinScripts = v32:FindFirstChild("SkinScripts")

				if skinScripts then
					local v57 = next
					local children3, v58 = skinScripts:GetChildren()
					local exitTo = nil

					for _, v59 in v57, children3, v58 do
						if v59.Name:lower():gsub(" ", "") == arg:lower():gsub(" ", "") then
							exitTo = 1
							break
						end
					end

					if exitTo == 1 then
						local sound = s24_1:FindFirstChildOfClass("Sound")

						if sound then
							local clone = sound:Clone()
							clone.Name = "\0"
							clone.Parent = handle
							clone:Play()
							game.Debris:AddItem(clone, 3)
						end

						local v59 = next
						local descendants, v60 = s24_1:GetDescendants()

						for _, v61 in v59, descendants, v60 do
							if v61:IsA("Sound") or v61:IsA("StringValue") then
								local str3 = v61.Name:lower():gsub(" ", "")

								if str3 == "equipsfx" or str3 == "sfx" or str3 == "equip" or str3 == "tantoequip" then
									scAppliedSkins[parent].KnifeEquipSound = v61:IsA("Sound") and v61.SoundId or v61.Value
								elseif str3 == "attacksfx" or str3 == "attack" then
									scAppliedSkins[parent].KnifeAttackSound = v61:IsA("Sound") and v61.SoundId or v61.Value
								end
							end
						end
					end
				end

				local skinScriptsStorage = v32:FindFirstChild("SkinScriptsStorage")

				if skinScriptsStorage then
					local v57 = next
					local n26 = n25 // 22
					local n27 = n22 + 472061855
					local children3, v58 = skinScriptsStorage:GetChildren()
					local exitTo2 = nil

					for _, v59 in v57, children3, v58 do
						if v59.Name:lower():gsub(" ", "") == arg:lower():gsub(" ", "") then
							exitTo2 = 1
							break
						end
					end

					if exitTo2 == 1 then
						local v59 = next
						local descendants, v60 = s28_1:GetDescendants()

						for _, v61 in v59, descendants, v60 do
							if v61:IsA("Animation") then
								local str3 = v61.Name:lower():gsub(" ", "")
								if str3 == "knife" or str3 == "equipknife" or str3 == "knifeequip" or str3 == "tantoequip" then
									scAppliedSkins[parent].KnifeEquipAnim = v61
									break
								end
							end
						end
					end

					n22 = n27 - 472061855
					n25 = n26 - 3034227347
				end

				local knifeSkinAnimation = v32:FindFirstChild("KnifeSkinAnimation")

				if knifeSkinAnimation then
					local v57 = next
					local children3, v58 = knifeSkinAnimation:GetChildren()
					local exitTo3 = nil

					for _, v59 in v57, children3, v58 do
						if v59.Name:lower():gsub(" ", "") == arg:lower():gsub(" ", "") then
							exitTo3 = 1
							break
						end
					end

					if exitTo3 == 1 then
						local v59 = next
						local descendants, v60 = s33_4:GetDescendants()

						for _, v61 in v59, descendants, v60 do
							if v61:IsA("Animation") then
								scAppliedSkins[parent].KnifeAttackAnim = v61
								break
							end
						end
					end
				end

				n23 = n25 + 101085351
			end

			if flag and arg:lower():gsub(" ", "") == "goldenagetanto" then
				if not scAppliedSkins[parent].KnifeEquipAnim then
					local animation = Instance.new("Animation")
					animation.AnimationId = "rbxassetid://13473404819"
					scAppliedSkins[parent].KnifeEquipAnim = animation
				else
					scAppliedSkins[parent].KnifeEquipAnim.AnimationId = "rbxassetid://13473404819"
				end
			end

			if flag then
				local str3 = arg:lower()
				local v57 = bit32.bxor(n24, 4233191631)
				flag = str3:gsub(" ", "") == "gpoknife"

				if not flag then
					local str4 = arg:lower():gsub(" ", "")
					local v58 = bit32.bxor(n22, 0)
					n23 = bit32.bor(n23, v58)
					flag = str4 == "gpoknifeprestige"
				end

				n24 = bit32.bxor(v57, 4233191631)
			end

			if flag then
				local n25 = n22 + 230830194

				if not scAppliedSkins[parent].KnifeEquipAnim then
					local animation = Instance.new("Animation")
					animation.AnimationId = "rbxassetid://102007904524177"
					local v57 = scAppliedSkins[parent]
					local v58 = bit32.bxor(n25, 0)
					local v59 = bit32.band(n24 // 63, v58)
					v57.KnifeEquipAnim = animation
				else
					scAppliedSkins[parent].KnifeEquipAnim.AnimationId = "rbxassetid://102007904524177"
				end

				n22 = n25 - 230830194
				n23 = bit32.bxor(n23, 4294967295) - 1451246225
			end

			fn14(parent)

			local connection5 = parent.DescendantAdded:Connect(function(descendant)
				local n25 = 1770929336
				local n26 = 2245378042
				local n27 = 1073855839
				local isSound = descendant:IsA("Sound")

				if isSound then
					local n28 = n27 // 7
					isSound = descendant.Name == "Shoot" or descendant.Name == "ShootSound"
					n27 = n28 + 920447862
				end

				if isSound then
					local defer = task.defer
					local n28 = 8944826155

					local function fn18()
						local n29 = 2620706578
						local v57 = scAppliedSkins[parent]

						if v57 and scAppliedSkins[parent].SkinName == arg then
							fn14(parent)
						end
					end

					bit32.bxor(n25, 3910363551)
					defer(fn18)
					bit32.bxor(n26 - n27, 3221339489)
				end
			end)

			local insert2 = table.insert
			local v57 = scAppliedSkins[parent]
			bit32.bxor(n22, 0)
			insert2(v57.Connections, connection5)

			if flag2 then
				fn17(parent, arg)
			end
		end

		ProcessTool = function(arg)
			local n13 = 188357761
			local n14 = 3614532681
			local n15 = 2447763462
			local n16 = 3131657136
			if tbl20[arg] then
				return
			end
			tbl20[arg] = true
			local v37 = fn4()
			local n17 = n16 // 151
			bit32.bxor(n14, 2025864205)
			if not v37.Enabled then
				return
			end
			local skins = v37.Skins
			local n18 = bit32.bor(n15, n17)
			local v38 = skins[arg.Name] or skins["[" .. arg.Name:gsub("%[", ""):gsub("%]", "") .. "]"]
			local flag = not v38
			local v39 = bit32.bor(n17, n18)
			if flag or v38 == "" or v38 == "None" then
				return
			end
			local flag2 = arg.Name:lower():find("knife") ~= nil

			if not flag2 then
				local name = arg.Name
				local v40 = table.pack(bit32.band(n18, 4294967295))
				local v41 = table.pack(bit32.band(v39, 4294967295))
				local v42 = table.pack(bit32.band(v40[1], 65535))
				local v43 = table.pack(bit32.rshift(v40[1], 16))
				local v44 = table.pack(bit32.band(v41[1], 65535))
				flag2 = name == "[Knife]"
				n18 = bit32.band(v42[1] * v44[1] + bit32.lshift(bit32.band(v42[1] * bit32.rshift(v41[1], 16) + v43[1] * v44[1], 65535), 16), 4294967295) - 1410090882
			end

			if flag2 and fn5(v38) then
				fn12(arg, v38)
				local connection4 = nil
				local v40 = bit32.band(n18, v39)
				local n19 = 624148178

				connection4 = arg.Equipped:Connect(function()
					local n20 = 4089118448
					local n21 = 740935779
					local n22 = 1431683872

					if not scAppliedSkins[arg] then
						if connection4 then
							connection4:Disconnect()
						end

						return
					end

					local v41 = arg
					local v42 = bit32.bor(n21, n22)
					local parent = v41.Parent
					bit32.bxor(n20, 1861973079)
					if parent ~= localPlayer.Character then
						return
					end
					fn7(parent, arg, v38)
				end)

				local flag3 = not scAppliedSkins[arg].Connections
				local n20 = bit32.bor(v39, v40)

				if flag3 then
					scAppliedSkins[arg].Connections = {}
				end

				local n21 = v40 - n20
				table.insert(scAppliedSkins[arg].Connections, connection4)
				local character = localPlayer.Character

				if character then
					character = arg.Parent == localPlayer.Character
					n20 = bit32.bor(n20, 1707867493) - 1677852672
				end

				if character then
					fn7(localPlayer.Character, arg, v38)
					n21 = n21 - n20 + 2449341823
				end

				if scAppliedSkins[arg] and (scAppliedSkins[arg].KnifeAttackAnim or scAppliedSkins[arg].KnifeAttackSound) then
					local connection5 = nil
					local n22 = 532278119

					connection5 = arg.Activated:Connect(function()
						local n23 = 3649391303
						local v41 = scAppliedSkins[arg]
						local n24 = 1138
						if not v41 then
							connection5:Disconnect()
							return
						end

						if v41.KnifeAttackSound then
							local sound = Instance.new("Sound")
							local knifeAttackSound = v41.KnifeAttackSound
							local v42 = table.pack(bit32.band(n23, 4294967295))
							local v43 = table.pack(bit32.band(n24, 4294967295))
							local v44 = table.pack(bit32.band(v42[1], 65535))
							local v45 = table.pack(bit32.rshift(v42[1], 16))
							local v46 = table.pack(bit32.band(v43[1], 65535))
							local v47 = bit32.band(v44[1] * v46[1] + bit32.lshift(bit32.band(v44[1] * bit32.rshift(v43[1], 16) + v45[1] * v46[1], 65535), 16), 4294967295)
							sound.SoundId = knifeAttackSound
							sound.Volume = 1
							sound.Parent = arg:FindFirstChild("Handle") or arg
							sound:Play()
							local v48 = bit32.bxor(v47, 4294967295)
							game.Debris:AddItem(sound, 3)
							n23 = v48 - 871648410
						end

						if v41.KnifeAttackAnim then
							local character2 = localPlayer.Character

							if character2 then
								local humanoid = character2:FindFirstChildOfClass("Humanoid")
								local n25 = n24 // n23

								if humanoid then
									local animator = humanoid:FindFirstChildOfClass("Animator")

									if not animator then
										animator = Instance.new("Animator")
										animator.Parent = humanoid
										n25 = n23 + 645575993
									end

									local animation = Instance.new("Animation")
									animation.AnimationId = v41.KnifeAttackAnim.AnimationId
									local v42 = animator:LoadAnimation(animation)
									v42.Priority = Enum.AnimationPriority.Action
									v42:Play()
									animation:Destroy()
								end
							end
						end
					end)

					local v41 = bit32.band(n20, n21)
					table.insert(scAppliedSkins[arg].Connections, connection5)
					bit32.bxor(v41, 2449341823)
				end
			else
				local v40 = fn12
				local v41 = bit32.bor(n18, v39)
				v40(arg, v38)
				local equipped = arg.Equipped
				bit32.bxor(n13, 2990282359)

				equipped:Connect(function()
					if arg.Parent ~= localPlayer.Character then
						return
					end
					fn12(arg, v38)
				end)

				if localPlayer.Character and arg.Parent == localPlayer.Character then
					local v42 = fn12
					local v43 = bit32.band(v41, 3833377051)
					v42(arg, v38)
					bit32.bxor(v43, 293686372)
				end
			end
		end
	end

	ProcessCharacter = function(arg)
		local flag = type(0) == "userdata"
		local n13 = 1325065876
		local n14 = 221372904
		local n15 = 634775824
		local n16 = 2383883469
		if not arg then
			return
		end
		local v37 = next
		bit32.rshift(n16, 18)
		local children, v38 = arg:GetChildren()

		for _, v39 in v37, children, v38 do
			if v39:IsA("Tool") then
				ProcessTool(v39)
			end
		end

		local n17 = n15 - 49081317
		bit32.bxor(n13, 642897520)
		local childAdded = arg.ChildAdded
		bit32.bxor(n14, 1028392544)

		childAdded:Connect(function(arg2)
			local n18 = 1194255389
			local n19 = 3659532476

			if arg2:IsA("Tool") then
				Wait(0.1)
				ProcessTool(arg2)
				bit32.bxor(n18, 3983036128)
				local n20 = n19 // 2 + 1829766238
			end
		end)
	end

	ProcessBackpack = function(arg)
		local n13 = 155468495
		type(0)
		local n14 = 926182893
		local n15 = 1657737418
		local n16 = 2224959708
		if not arg then
			return
		end
		local v37 = next
		local children, v38 = arg:GetChildren()
		local v39 = bit32.bxor(n13, 28896514)
		bit32.bxor(n15, 4153129808)
		local v40 = table.pack(bit32.band(v39, 4294967295))
		local v41 = table.pack(bit32.band(v40[1], 65535))
		local n17 = bit32.band(65348 * v41[1] + bit32.lshift(bit32.band(65348 * bit32.rshift(v40[1], 16) + 6203 * v41[1], 65535), 16), 4294967295) + 2654340668
		local v42 = table.pack(bit32.band(bit32.bor(v39, 378741599), 4294967295))
		local v43 = table.pack(bit32.band(v42[1], 65535))
		local v44 = bit32.band(189 * v43[1] + bit32.lshift(bit32.band(189 * bit32.rshift(v42[1], 16) + 59332 * v43[1], 65535), 16), 4294967295)
		local v45 = table.pack(bit32.band(bit32.band(v39, 378741599), 4294967295))
		local v46 = table.pack(bit32.band(v45[1], 65535))
		local n18 = n17 + v44 + bit32.band(187 * v46[1] + bit32.lshift(bit32.band(187 * bit32.rshift(v45[1], 16) + 59332 * v46[1], 65535), 16), 4294967295)

		for _, v47 in v37, children, v38 do
			if v47:IsA("Tool") then
				ProcessTool(v47)
				n14 = bit32.bxor(n14, 2161872572)
			end
		end

		arg.ChildAdded:Connect(function(child)
			local n19 = 1442737246
			local n20 = 3979044152
			local n21 = 1350682291

			if child:IsA("Tool") then
				Wait(0.1)
				ProcessTool(child)
				bit32.bxor(n19, 2629714465)
				local n22 = n21 + n20 - 3979044152
			end
		end)
	end

	task.spawn(fn8)
	local n13, n14, v37

	do
		local v38 = bit32.bxor(v33, 0)
		local v39 = bit32.band(v35, v38)
		local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
		local backpack = localPlayer:FindFirstChild("Backpack") or localPlayer:WaitForChild("Backpack", 5)
		local v40 = ProcessCharacter
		n13 = v36 - bit32.bxor(v33, 0)
		v40(character)

		if backpack then
			ProcessBackpack(backpack)
		end

		localPlayer.CharacterAdded:Connect(function(character2)
			Wait(0.5)
			ProcessCharacter(character2)
			local backpack2 = localPlayer:FindFirstChild("Backpack")
			backpack2 = backpack2 or localPlayer:WaitForChild("Backpack", 5)

			if backpack2 then
				ProcessBackpack(backpack2)
			end
		end)

		local function fn11(arg)
			local n15 = 2998570907
			local n16 = 1841452134
			local v41 = fn4()
			if not v41 or not v41.Enabled then
				return nil
			end
			local v42 = n16
			local skins = v41.Skins
			local v43 = skins[arg.Name]

			if not v43 then
				local str2 = arg.Name:gsub("%[", ""):gsub("%]", "") .. "]"
				local v44 = table.pack(bit32.band(n16, 4294967295))
				local v45 = table.pack(bit32.band(v44[1], 65535))
				local v46 = bit32.band(v45[1] * 29832 + bit32.lshift(bit32.band(v45[1] * 0 + bit32.rshift(v44[1], 16) * 29832, 65535), 16), 4294967295)
				v43 = skins["[" .. str2]
				bit32.bxor(v42, 488603940)
				bit32.bxor(n15 // 71, 2956911018)
			end

			if not v43 or v43 == "" or v43 == "None" then
				return nil
			end
			return v43
		end

		local v41 = bit32.bxor(v33, 339129060)
		n14 = v39 + bit32.bxor(v33, 0)
		v37 = v41

		local function fn12()
			local flag = type(0) == "buffer"
			local n15 = 337769658

			local function fn13(arg, arg2, arg3)
				local n16 = 3388513282
				bit32.bxor(bit32.bxor(arg2, 0), 1198497949)
				if not arg3 then
					return
				end
				local v42 = next
				bit32.bxor(n16, 4294967295)
				local children, v43 = arg3:GetChildren()

				for _, v44 in v42, children, v43 do
					if v44:IsA("Tool") then
						if fn11(v44) ~= (scAppliedSkins[v44] and scAppliedSkins[v44].SkinName or nil) then
							tbl20[v44] = nil
							local v45 = tbl18
							local v46 = table.pack(bit32.band(arg, 4294967295))
							local v47 = table.pack(bit32.band(v46[1], 65535))
							local v48 = bit32.band(53359 * v47[1] + bit32.lshift(bit32.band(53359 * bit32.rshift(v46[1], 16) + 55355 * v47[1], 65535), 16), 4294967295)
							local v49 = table.pack(bit32.band(bit32.bnot(arg), 4294967295))
							local v50 = table.pack(bit32.band(v49[1], 65535))
							local n17 = 3816426529 + v48 + bit32.band(53359 * v50[1] + bit32.lshift(bit32.band(53359 * bit32.rshift(v49[1], 16) + 55355 * v50[1], 65535), 16), 4294967295)
							v45[v44] = nil

							pcall(function()
								fn10(v44)
							end)

							pcall(function()
								ProcessTool(v44)
							end)
						end
					end
				end
			end

			fn13(533300698, 222049900, localPlayer.Character)
			fn13(53703083, 222049900, localPlayer:FindFirstChild("Backpack"))
		end

		local v42 = fn2

		fn2 = function()
			local n15 = 2640786531

			if v42 then
				v42()
			end

			local v43 = fn12
			bit32.lshift(n15, 10)
			v43()
		end
	end

	KOConnection = nil
	local n15, v38

	do
		local v39 = bit32.bxor(v37, 0)
		local v40 = bit32.bxor(n13, v39)

		SetupAntiStomp = function(arg)
			local n16 = 2641162151
			local n17 = 928309212
			KOConnection:Disconnect()
			local v41 = bit32.bor(978016850, n17)
			KOConnection = nil
			local n18 = v41 - 85230988
			local bodyEffects = arg:WaitForChild("BodyEffects", 5)
			if not bodyEffects then
				return
			end
			local ko = bodyEffects:WaitForChild("K.O", 5)
			if not ko then
				return
			end
			local changed = ko.Changed
			bit32.bxor(n16, 3753534286)
			local v42 = n18

			KOConnection = changed:Connect(function(arg2)
				local n19 = 3049724296
				local n20 = 1443712344
				local v43 = bit32.bxor(v42, 879598545)
				local antiStomp = fn()["Anti Stomp"]
				local flag = not antiStomp
				local v44

				if flag then
					v44 = flag
				else
					local flag2 = not antiStomp.Enabled
					bit32.bxor(n19, 84360695)
					n20 = n20 - v43 - 4057546365
					v44 = flag2
				end

				if v44 then
					return
				end

				if not arg2 then
					return
				end
				local humanoidRootPart = arg:FindFirstChild("HumanoidRootPart")
				if not humanoidRootPart then
					return
				end
				local v45 = bit32.band(v43, n20)
				humanoidRootPart.CFrame = CFrameNew(0, -2147483647, 0)
				humanoidRootPart.Velocity = Vector3New(65536, 65534, 65536)
				local humanoid = arg:FindFirstChildOfClass("Humanoid")

				if humanoid then
					for i = 1, 10 do
						humanoid.Health = 0
						Wait()
					end
				end
			end)
		end

		if localPlayer.Character then
			Spawn(SetupAntiStomp, localPlayer.Character)
		end

		local n16 = n14 + 2838369704
		localPlayer.CharacterAdded:Connect(SetupAntiStomp)

		GetMiscGunCfg = function()
			return fn().Modifications["Misc Gun Modifications"]
		end

		CurrentCamera = Workspace.CurrentCamera
		SavedCFrame = CurrentCamera.CFrame
		RestorePending = false

		QueueRestore = function()
			type(303997018)
		end

		n15 = v40 // 4

		RunService.RenderStepped:Connect(function()
			CurrentCamera = Workspace.CurrentCamera
		end)

		local mainEvent = ReplicatedStorage:FindFirstChild("MainEvent")

		if mainEvent and mainEvent:IsA("RemoteEvent") then
			mainEvent.OnClientEvent:Connect(function(arg)
				local n17 = 233144975
				local n18 = 896850442
				local flag = arg == "ShootingRecoil"

				if flag then
					local v41 = GetMiscGunCfg()
					bit32.bxor(n17, 224567924)
					flag = v41["No Recoil"]
				end

				if flag then
					QueueRestore()
				end
			end)
		end

		v38 = bit32.lshift(n16, 10)
	end

	local function fn11(arg)
		type(481878980)
		local n16 = 2730697202
		local n17 = 931502622
		local n18 = 3338233193
		local bodyEffects = arg:WaitForChild("BodyEffects", 5)
		if not bodyEffects then
			return
		end
		local gunShotChanges = bodyEffects:FindFirstChild("GunShotChanges")
		local n19 = n17 + 69681320
		bit32.bxor(n16, 408533566)
		if not gunShotChanges then
			return
		end

		gunShotChanges.Changed:Connect(function()
			local n20 = 3663433739

			if GetMiscGunCfg()["No Recoil"] then
				QueueRestore()
				bit32.bxor(n20, 2255924379)
			end
		end)
	end

	if localPlayer.Character then
		Spawn(fn11, localPlayer.Character)
		n15 = n15 - v38 + 3284826112
	end

	localPlayer.CharacterAdded:Connect(function(character)
		Spawn(fn11, character)
	end)

	local bodySize, tbl21, skinny, v39, n16

	do
		local n17 = 388234126
		type("Enabled")
		local char = fn().Char

		if char then
			tbl2 = char
		else
			n15 = bit32.bxor(n15 // bit32.bxor(v37, 0), 354198711)
			tbl2 = {}
		end

		local v40 = table.pack(bit32.band(n17, 4294967295))
		local v41 = table.pack(bit32.band(v40[1], 65535))
		local n18 = 2147483647 + bit32.band(0 * v41[1] + bit32.lshift(bit32.band(0 * bit32.rshift(v40[1], 16) + 32768 * v41[1], 65535), 16), 4294967295)
		local v42 = bit32.bxor(n17, 307509231)
		local v43 = table.pack(bit32.band(bit32.bnot(v42), 4294967295))
		local v44 = table.pack(bit32.band(v43[1], 65535))
		local n19 = n18 + 2147483648 + bit32.band(65535 * v44[1] + bit32.lshift(bit32.band(65535 * bit32.rshift(v43[1], 16) + 32767 * v44[1], 65535), 16), 4294967295)
		bodySize = tbl2["Body Size"] or {}
		tbl21 = {}
		skinny = { width = 0.52, depth = 0.52 }
		v39 = bit32.bxor(v38, 1109837058)
		skinny.height = 1
		skinny.head = 1
		local n20 = bit32.bxor(n19, 68041012) + 3313080585
		local v45 = table.pack(bit32.band(n19, 4294967295))
		local v46 = table.pack(bit32.band(v45[1], 65535))
		local v47 = bit32.band(39177 * v46[1] + bit32.lshift(bit32.band(39177 * bit32.rshift(v45[1], 16) + 50553 * v46[1], 65535), 16), 4294967295)
		local v48 = table.pack(bit32.band(bit32.bnot(n19), 4294967295))
		local v49 = table.pack(bit32.band(v48[1], 65535))
		n16 = n20 + v47 + bit32.band(39177 * v49[1] + bit32.lshift(bit32.band(39177 * bit32.rshift(v48[1], 16) + 50553 * v49[1], 65535), 16), 4294967295)
	end

	skinny.proportion = 1
	skinny.bodyType = 0
	local v40 = table.pack(bit32.band(v39, 4294967295))
	local v41 = table.pack(bit32.band(n15, 4294967295))
	local v42 = table.pack(bit32.band(v40[1], 65535))
	local v43 = table.pack(bit32.rshift(v40[1], 16))
	local v44 = table.pack(bit32.band(v41[1], 65535))
	local normal, n17

	do
		local v45 = bit32.band(v42[1] * v44[1] + bit32.lshift(bit32.band(v42[1] * bit32.rshift(v41[1], 16) + v43[1] * v44[1], 65535), 16), 4294967295)
		tbl21.Skinny = skinny
		normal = { width = 1, depth = 1, height = 1 }
		local v46 = bit32.band(n15, 397001235)
		normal.head = 1
		n17 = v46 + v45
	end

	normal.proportion = 1
	local v45 = table.pack(bit32.band(n16, 4294967295))
	local v46 = table.pack(bit32.band(v45[1], 65535))
	local v47, fat, charchanger, v48, n18, v49

	do
		local n19 = bit32.band(2906 * v46[1] + bit32.lshift(bit32.band(2906 * bit32.rshift(v45[1], 16) + 8624 * v46[1], 65535), 16), 4294967295) + 3224986510
		local v50 = table.pack(bit32.band(bit32.bor(209173443, n16), 4294967295))
		local v51 = table.pack(bit32.band(v50[1], 65535))
		local v52 = bit32.band(59724 * v51[1] + bit32.lshift(bit32.band(59724 * bit32.rshift(v50[1], 16) + 48287 * v51[1], 65535), 16), 4294967295)
		local v53 = bit32.bxor(n16, 209173443)
		local v54 = table.pack(bit32.band(bit32.bnot(v53), 4294967295))
		local v55 = table.pack(bit32.band(v54[1], 65535))
		local n20 = n19 + v52 + 3729781925 + bit32.band(62629 * v55[1] + bit32.lshift(bit32.band(62629 * bit32.rshift(v54[1], 16) + 56911 * v55[1], 65535), 16), 4294967295)
		v47 = bit32.bxor(v37, 118885818)
		normal.bodyType = 0
		tbl21.Normal = normal
		fat = {}
		local n21 = bit32.bxor(n20, 325792956) + 3655015620
		local v56 = table.pack(bit32.band(v47, 4294967295))
		local v57 = table.pack(bit32.band(v56[1], 65535))
		local v58 = bit32.band(7364 * v57[1] + bit32.lshift(bit32.band(7364 * bit32.rshift(v56[1], 16) + 55771 * v57[1], 65535), 16), 4294967295)
		local v59 = table.pack(bit32.band(bit32.bnot(v47), 4294967295))
		local v60 = table.pack(bit32.band(v59[1], 65535))
		local n22 = n21 + v58 + bit32.band(7364 * v60[1] + bit32.lshift(bit32.band(7364 * bit32.rshift(v59[1], 16) + 55771 * v60[1], 65535), 16), 4294967295)
		fat.width = 1.5
		local v61 = bit32.bxor(v47, 0)
		local v62 = bit32.bxor(n22, 394692057)
		fat.depth = 1.5
		local n23 = v61 // n17
		fat.height = 1
		fat.head = 1
		fat.proportion = 1
		local v63 = bit32.bxor(v47, 0)
		local n24 = bit32.bxor(n17, v63)
		fat.bodyType = 0
		tbl21.Fat = fat
		local skinny2 = tbl21[bodySize.Mode] or tbl21.Skinny
		tbl3 = { target = tbl2.Target or "" }
		charchanger = {}
		local n25 = n23 * bit32.bxor(v47, 0)
		local enabled = tbl2.Enabled == true
		v48 = bit32.bxor(v62, 231930705)

		if enabled then
			enabled = bodySize.Enabled ~= false
			n24 = n25 + 3787847259
		end

		charchanger.enabled = enabled
		charchanger.width = skinny2.width
		charchanger.depth = skinny2.depth
		n18 = n24 // bit32.bxor(v47, 0)
		charchanger.height = skinny2.height
		charchanger.head = skinny2.head
		local v64 = bit32.band(n25, 1391022973)
		charchanger.proportion = skinny2.proportion
		charchanger.bodyType = skinny2.bodyType
		charchanger.targetScales = nil
		v49 = bit32.bxor(v64, n18)
	end

	charchanger.enforceIntervalSeconds = 0.8
	tbl3.charchanger = charchanger
	Players2 = game:GetService("Players")
	RunService2 = game:GetService("RunService")
	InsertService = game:GetService("InsertService")
	localPlayer2 = Players2.LocalPlayer
	v4 = nil
	connection = nil
	tbl4 = {}
	connection2 = nil
	connection3 = nil
	local n19, v50, v51

	do
		local n20 = n18 + bit32.bxor(v47, 0)
		local v52 = table.pack(bit32.band(v47, 4294967295))
		local v53 = table.pack(bit32.band(v52[1], 65535))
		local n21 = bit32.band(27253 * v53[1] + bit32.lshift(bit32.band(27253 * bit32.rshift(v52[1], 16) + 34107 * v53[1], 65535), 16), 4294967295) + 2159573336
		n19 = v49 * 224
		local v54 = table.pack(bit32.band(bit32.bor(v47, 250149112), 4294967295))
		local v55 = table.pack(bit32.band(v54[1], 65535))
		local v56 = bit32.band(38284 * v55[1] + bit32.lshift(bit32.band(38284 * bit32.rshift(v54[1], 16) + 31428 * v55[1], 65535), 16), 4294967295)
		local v57 = table.pack(bit32.band(bit32.band(v47, 250149112), 4294967295))
		local v58 = table.pack(bit32.band(v57[1], 65535))
		local n22 = n21 + v56 + bit32.band(38282 * v58[1] + bit32.lshift(bit32.band(38282 * bit32.rshift(v57[1], 16) + 31428 * v58[1], 65535), 16), 4294967295)
		v50 = bit32.bxor(n20, n19)
		v51 = n22
	end

	n2 = 0
	tbl5 = {}
	tbl6 = {}
	local v52 = table.pack(bit32.band(v48, 4294967295))
	local v53 = table.pack(bit32.band(v52[1], 65535))
	local n20, v54

	do
		local n21 = bit32.band(39595 * v53[1] + bit32.lshift(bit32.band(39595 * bit32.rshift(v52[1], 16) + 1144 * v53[1], 65535), 16), 4294967295) + 3267533734
		local v55 = table.pack(bit32.band(bit32.band(v48, 530658034), 4294967295))
		local v56 = table.pack(bit32.band(v55[1], 65535))
		local v57 = bit32.band(51882 * v56[1] + bit32.lshift(bit32.band(51882 * bit32.rshift(v55[1], 16) + 63246 * v56[1], 65535), 16), 4294967295)
		local v58 = table.pack(bit32.band(bit32.bxor(v48, 530658034), 4294967295))
		local v59 = table.pack(bit32.band(v58[1], 65535))
		local n22 = n21 + v57 + bit32.band(25942 * v59[1] + bit32.lshift(bit32.band(25942 * bit32.rshift(v58[1], 16) + 64391 * v59[1], 65535), 16), 4294967295)
		tbl7 = {}
		local v60 = table.pack(bit32.band(n22, 4294967295))
		local v61 = table.pack(bit32.band(v60[1], 65535))
		local n23 = bit32.band(25768 * v61[1] + bit32.lshift(bit32.band(25768 * bit32.rshift(v60[1], 16) + 5649 * v61[1], 65535), 16), 4294967295) + 964599528
		local v62 = table.pack(bit32.band(bit32.band(n22, 492826665), 4294967295))
		local v63 = table.pack(bit32.band(v62[1], 65535))
		local v64 = bit32.band(14000 * v63[1] + bit32.lshift(bit32.band(14000 * bit32.rshift(v62[1], 16) + 54237 * v63[1], 65535), 16), 4294967295)
		local v65 = table.pack(bit32.band(bit32.bxor(n22, 492826665), 4294967295))
		local v66 = table.pack(bit32.band(v65[1], 65535))
		local n24 = n23 + v64 + bit32.band(39769 * v66[1] + bit32.lshift(bit32.band(39769 * bit32.rshift(v65[1], 16) + 59886 * v66[1], 65535), 16), 4294967295)
		tbl8 = {}
		tbl9 = {}
		tbl10 = {}
		tbl11 = {}

		tbl12 = {
			faceTexture = 80,
			description = 40,
			appearanceModel = 24,
			appearanceInfo = 60,
			resolvedUserId = 120,
			animationSet = 64,
		}

		n20 = v50 * 6 // bit32.bxor(v51, 0)
		tbl12.emoteData = 80

		ok, result = pcall(function()
			return getgenv()
		end)

		str = "__CopyOutfitState"
		v54 = bit32.bxor(n24, 91996838)
	end

	if ok and result then
		local v55 = result[str]
		local flag

		if v55 then
			local v56 = type
			local v57 = bit32.bxor(v54, 10612118)
			flag = v56(v55.teardown) == "function"
			n19 = bit32.bxor(n19 - 3552773521, 742198703)
			v54 = bit32.bxor(v57, 10612118)
		else
			flag = v55
		end

		if flag then
			pcall(v55.teardown)
		end
	end

	tbl13 = { currentUserId = nil }
	local v55 = table.pack(bit32.band(v54, 4294967295))
	local v56 = table.pack(bit32.band(v55[1], 65535))
	local n21, v57

	do
		local n22 = 3581763275 + bit32.band(0 * v56[1] + bit32.lshift(bit32.band(0 * bit32.rshift(v55[1], 16) + 32768 * v56[1], 65535), 16), 4294967295)
		local v58 = bit32.bxor(v54, 44492022)
		local v59 = table.pack(bit32.band(bit32.bnot(v58), 4294967295))
		local v60 = table.pack(bit32.band(v59[1], 65535))
		local v61 = bit32.band(24267 * v60[1] + bit32.lshift(bit32.band(24267 * bit32.rshift(v59[1], 16) + 54653 * v60[1], 65535), 16), 4294967295)
		local v62 = table.pack(bit32.band(bit32.bxor(v54, 44492022), 4294967295))
		local v63 = table.pack(bit32.band(v62[1], 65535))
		local n23 = n22 + 0 + v61 + bit32.band(24268 * v63[1] + bit32.lshift(bit32.band(24268 * bit32.rshift(v62[1], 16) + 21885 * v63[1], 65535), 16), 4294967295)
		n21 = n19 - 4016908171
		local active = tbl2.Enabled == true
		local v64 = bit32.bxor(v51, 0)
		local v65 = bit32.bxor(n20, v64)
		tbl13.active = active
		tbl13.teardown = nil
		v5 = bit32.bxor(v51, 45674936)
		tbl13.colorSnapshot = nil
		local v66 = bit32.bxor(n23, 245960936)
		local v67 = bit32.bxor(v5, 0)
		local v68 = bit32.bxor(v66, 475088053)
		local v69 = bit32.band(v65, v67)
		tbl13.guiIdentity = nil

		if ok and result then
			result[str] = tbl13
		end

		local tbl22 = {}
		local n24 = n21 - v69
		v57 = bit32.bxor(v68, 217967252)
		tbl22[1] = "Shirt"
		tbl22[2] = "Pants"
		tbl22[3] = "ShirtGraphic"
		tbl22[4] = "Accessory"
		tbl22[5] = "Hat"
		tbl22[6] = "BodyColors"
		tbl22[7] = "CharacterMesh"
		tbl14 = {}

		for _, v70 in ipairs(tbl22) do
			tbl14[v70] = true
		end

		local v70 = table.pack(bit32.band(n24, 4294967295))
	end

	local v58 = table.pack(bit32.band(t1883_18729_1[1], 65535))
	v6 = bit32.band(v58[1] * 4575 + bit32.lshift(bit32.band(v58[1] * 0 + bit32.rshift(t1883_18729_1[1], 16) * 4575, 65535), 16), 4294967295)
	tbl15 = {}
	local v59, v60, v61

	v59, v60, v61 = ipairs({
		"BodyHeightScale",
		"BodyWidthScale",
		"BodyDepthScale",
		"HeadScale",
		"BodyTypeScale",
		"BodyProportionScale",
	})

	local v62 = table.pack(bit32.band(v57, 4294967295))
	local v63 = table.pack(bit32.band(v62[1], 65535))

	do
		local n22 = bit32.band(31880 * v63[1] + bit32.lshift(bit32.band(31880 * bit32.rshift(v62[1], 16) + 9085 * v63[1], 65535), 16), 4294967295) + 1477618040
		local v64 = table.pack(bit32.band(bit32.bor(416078015, v57), 4294967295))
		local v65 = table.pack(bit32.band(v64[1], 65535))
		local v66 = bit32.band(1776 * v65[1] + bit32.lshift(bit32.band(1776 * bit32.rshift(v64[1], 16) + 47365 * v65[1], 65535), 16), 4294967295)
		local v67 = table.pack(bit32.band(bit32.bxor(v57, 416078015), 4294967295))
		local v68 = table.pack(bit32.band(v67[1], 65535))
		local n23 = n22 + v66 + bit32.band(31881 * v68[1] + bit32.lshift(bit32.band(31881 * bit32.rshift(v67[1], 16) + 9085 * v68[1], 65535), 16), 4294967295)

		for _, v69 in v59, v60, v61 do
			tbl15[v69] = true
		end

		tbl16 = {
			"ClimbAnimation",
			"FallAnimation",
			"IdleAnimation",
			"JumpAnimation",
			"RunAnimation",
			"SwimAnimation",
			"WalkAnimation",
		}

		v7 = bit32.bxor(n23, 84360389)
	end
end

local tbl17, fn4, fn5, fn6, fn7, fn8, fn9, fn10, fn11, fn12
local fn13, fn14, fn15, fn16, fn17, fn18, v8, fn19, fn20, fn21
local fn22, v9, v10, fn23, fn24, v11

do
	tbl17 = {}
	local n3
	n3 = v6 // bit32.bxor(v5, 0)
	tbl17[1] = "Head"
	tbl17[2] = "Torso"
	tbl17[3] = "UpperTorso"
	tbl17[4] = "LowerTorso"
	tbl17[5] = "LeftArm"
	tbl17[6] = "RightArm"
	tbl17[7] = "LeftLeg"
	tbl17[8] = "RightLeg"
	tbl17[9] = "LeftUpperArm"
	tbl17[10] = "LeftLowerArm"
	tbl17[11] = "LeftHand"
	tbl17[12] = "RightUpperArm"
	tbl17[13] = "RightLowerArm"
	tbl17[14] = "RightHand"
	tbl17[15] = "LeftUpperLeg"
	tbl17[16] = "LeftLowerLeg"
	tbl17[17] = "LeftFoot"
	tbl17[18] = "RightUpperLeg"
	tbl17[19] = "RightLowerLeg"
	tbl17[20] = "RightFoot"
	local head
	head = 134082579
	local tbl18, v12, n4, n5

	do
		local rightLeg = 139607718
		tbl18 = { RightLowerLeg = { mesh = 902942093, hidden = true } }
		v12 = bit32.bxor(v7, 427649535)
		local rightUpperLeg = {}
		local v13 = table.pack(bit32.band(v5, 4294967295))
		local v14 = table.pack(bit32.band(v13[1], 65535))
		local n6 = bit32.band(56715 * v14[1] + bit32.lshift(bit32.band(56715 * bit32.rshift(v13[1], 16) + 14942 * v14[1], 65535), 16), 4294967295) + 3149166831
		local v15 = table.pack(bit32.band(bit32.bor(v5, 489064109), 4294967295))
		local v16 = table.pack(bit32.band(v15[1], 65535))
		local v17 = bit32.band(8822 * v16[1] + bit32.lshift(bit32.band(8822 * bit32.rshift(v15[1], 16) + 50593 * v16[1], 65535), 16), 4294967295)
		local v18 = table.pack(bit32.band(bit32.band(v5, 489064109), 4294967295))
		local v19 = table.pack(bit32.band(v18[1], 65535))
		n4 = n6 + v17 + bit32.band(8820 * v19[1] + bit32.lshift(bit32.band(8820 * bit32.rshift(v18[1], 16) + 50593 * v19[1], 65535), 16), 4294967295)
		rightUpperLeg.mesh = 902942096
		rightUpperLeg.texture = 902843398
		tbl18.RightUpperLeg = rightUpperLeg
		tbl18.RightFoot = { mesh = 902942089, hidden = true }
		n5 = n3 + 1794562348

		local function fn25()
			return fn().Char or tbl2 or {}
		end

		fn4 = function(arg)
			local n7 = 2617598784
			local n8 = 2566230740
			local n9 = 921255085
			local v20 = fn25()
			local accessories = v20.Accessories
			local n10 = 37814280
			if type(accessories) == "table" then
				local flag = accessories.Enabled == true
				return flag and accessories[arg] == true
			end
			local v21 = v20[arg]
			bit32.bxor(n8, 3746181672)
			bit32.bxor(n7, 3200121992)
			return v21 == true
		end

		fn5 = function(arg)
			local n7 = 1519417115
			local n8 = 3144811809
			if not arg then
				return nil
			end

			if fn4("Headless") then
				local v20 = pcall
				local n9 = 224629618
				bit32.bxor(n7, 4111299950)

				v20(function()
					arg.Head = head
				end)

				pcall(function()
					arg.Face = 0
				end)

				local n10 = bit32.bxor(n8, 1823000520) + 3818340920
			end

			if fn4("Korblox") then
				local n9 = 666712053

				pcall(function()
					arg.RightLeg = rightLeg
				end)
			end

			return arg
		end

		fn6 = function(arg)
			local n7 = 842250984
			local n8 = 2170245925
			local n9 = 4158007011
			if not arg then
				return
			end
			local v20, v21, v22 = ipairs(arg:GetChildren())
			bit32.bxor(n7, 840162100)
			local v23 = table.pack(bit32.band(n9, 4294967295))
			local v24 = table.pack(bit32.band(n8, 4294967295))
			local v25 = table.pack(bit32.band(v23[1], 65535))
			local v26 = table.pack(bit32.rshift(v23[1], 16))
			local v27 = table.pack(bit32.band(v24[1], 65535))
			bit32.band(v25[1] * v27[1] + bit32.lshift(bit32.band(v25[1] * bit32.rshift(v24[1], 16) + v26[1] * v27[1], 65535), 16), 4294967295)

			for _, v28 in v20, v21, v22 do
				if v28:IsA("Decal") then
					v28.Transparency = 1
				end
			end
		end

		local function fn26(arg)
			if not fn4("Headless") then
				return
			end
			arg = arg and arg:FindFirstChild("Head")
			if not arg then
				return
			end
			arg.Transparency = 1
			fn6(arg)
		end

		local function fn27(parent)
			local n7 = 83137537
			local n8 = 4164085903
			local n9 = 833243911
			local n10 = 2201259935
			if not parent then
				return
			end
			local phantomShell = parent:FindFirstChild("PhantomShell")
			bit32.bxor(n7, 581376269)
			local v20 = bit32.bor(n9, n10)

			if not fn4("Korblox") then
				if phantomShell then
					phantomShell:Destroy()
				end

				return
			end

			local humanoid = parent:FindFirstChildOfClass("Humanoid")
			if not humanoid then
				return
			end
			local v21 = v20

			if humanoid.RigType == Enum.HumanoidRigType.R15 then
				if phantomShell then
					phantomShell:Destroy()
				end

				for k, v22 in pairs(tbl18) do
					local v23 = parent:FindFirstChild(k)

					if v23 then
						local n11 = 4311902750

						pcall(function()
							v23.MeshId = "rbxassetid://" .. v22.mesh
						end)

						if v22.texture then
							local n12 = 226401581

							pcall(function()
								v23.TextureID = "rbxassetid://" .. v22.texture
							end)
						end

						if v22.hidden then
							v23.Transparency = 1
						end
					end
				end

				return
			end

			local rightLeg2 = parent:FindFirstChild("Right Leg")
			local n11 = v20 // 240
			if not rightLeg2 then
				return
			end
			rightLeg2.Transparency = 1

			if phantomShell then
				phantomShell:Destroy()
			end

			local part = Instance.new("Part")
			part.Name = "PhantomShell"
			local v22 = bit32.band(v21, n11)
			local v23 = Vector3
			bit32.bxor(n8, 279290607)
			part.Size = Vector3.new(1, 2, 1)
			part.CanCollide = false
			part.CanTouch = false
			part.Massless = true
			part.CFrame = rightLeg2.CFrame * CFrame.new(0, 0.75, 0)
			local n12 = n11 - 252584582 - v22
			part.Parent = parent
			local weldConstraint = Instance.new("WeldConstraint")
			local v24 = bit32.band(v22, n12)
			weldConstraint.Part0 = part
			weldConstraint.Part1 = rightLeg2
			weldConstraint.Parent = part
			local specialMesh = Instance.new("SpecialMesh")
			local n13 = n12 // 3
			specialMesh.MeshType = Enum.MeshType.FileMesh
			specialMesh.MeshId = "rbxassetid://902942093"
			specialMesh.TextureId = "rbxassetid://902843398"
			specialMesh.Scale = Vector3.new(0.85, 1.25, 0.85)
			specialMesh.Parent = part
		end

		fn7 = function(arg)
			fn26(arg)
			fn27(arg)
		end

		fn8 = function(arg, arg2)
			local n7 = 3174133771
			local n8 = 4169171257

			if fn25()["Override Animation"] == true then
				local v20 = shared
				local v21 = bit32.bxor(n8, 4261258056)
				local ciderApplyAnimationChanger = v20.__CiderApplyAnimationChanger

				if type(ciderApplyAnimationChanger) == "function" then
					ciderApplyAnimationChanger(arg, true)
					bit32.bxor(bit32.bor(n7, v21), 4981360)
				end

				return
			end

			local v20 = typeof
			local v21 = mimicAnimationsFromUserId
			bit32.bxor(n7, 1170820152)

			if v20(v21) == "function" then
				mimicAnimationsFromUserId(arg2, true)
			end
		end
	end

	local v13, n6

	local function fn25(arg)
		local n7 = 499377226
		local n8 = 851980482
		local n9 = 1401150361
		local n10 = 1269033697

		if connection3 then
			connection3:Disconnect()
			connection3 = nil
		end

		local v14 = bit32.bxor(n7, 423803379)
		local v15 = bit32.bxor(n8, 3602117444)
		local v16 = table.pack(bit32.band(v14, 4294967295))
		local v17 = table.pack(bit32.band(v16[1], 65535))
		local n11 = bit32.band(12638 * v17[1] + bit32.lshift(bit32.band(12638 * bit32.rshift(v16[1], 16) + 8337 * v17[1], 65535), 16), 4294967295) + 3268659038
		local v18 = table.pack(bit32.band(bit32.bor(v14, 32515329), 4294967295))
		local v19 = table.pack(bit32.band(v18[1], 65535))
		local v20 = bit32.band(40260 * v19[1] + bit32.lshift(bit32.band(40260 * bit32.rshift(v18[1], 16) + 48861 * v19[1], 65535), 16), 4294967295)
		local v21 = table.pack(bit32.band(bit32.bxor(v14, 32515329), 4294967295))
		local v22 = table.pack(bit32.band(v21[1], 65535))
		local n12 = n11 + v20 + bit32.band(12639 * v22[1] + bit32.lshift(bit32.band(12639 * bit32.rshift(v21[1], 16) + 8337 * v22[1], 65535), 16), 4294967295)
		if not arg then
			return
		end
		local v23 = fn7
		local v24 = bit32.bxor(n9, 1444457736)
		v23(arg)

		connection3 = arg.DescendantAdded:Connect(function(descendant)
			local n13 = 1787002913
			local n14 = bit32.bxor(n12, 3561764778)
			local n15 = 2844405494
			local parent = descendant:IsA("Decal") and descendant.Parent

			if parent then
				local name = descendant.Parent.Name
				bit32.bxor(n13, 3139831495)
				parent = name == "Head"
				n14 = n14 // 14 - 1035258077
			end

			if parent then
				if fn4("Headless") then
					descendant.Transparency = 1
					local n16 = bit32.bor(n15, n14) - 1345667328
				end

				return
			end

			local name = descendant.Name
			local flag = name == "Head"
			local n16 = 2844405494
			local flag2

			if flag then
				flag2 = flag
			else
				flag2 = name == "Humanoid"
				local n17 = bit32.rshift(n15, 15) - 1450648606
			end

			if flag2 or name == "Right Leg" or tbl18[name] then
				local n17 = bit32.bxor(n12, 0) + 527793176
				local n18 = 1054236373

				task.defer(function()
					local n19 = 3919538432
					local n20 = 2757093462
					local n21 = 1612601900

					if arg.Parent then
						local v25 = fn7
						bit32.bxor(n19, 3066834827)
						local v26 = table.pack(bit32.band(n21, 4294967295))
						local v27 = table.pack(bit32.band(n20, 4294967295))
						local v28 = table.pack(bit32.band(v26[1], 65535))
						local v29 = table.pack(bit32.rshift(v26[1], 16))
						local v30 = table.pack(bit32.band(v27[1], 65535))
						local v31 = bit32.band(v28[1] * v30[1] + bit32.lshift(bit32.band(v28[1] * bit32.rshift(v27[1], 16) + v29[1] * v30[1], 65535), 16), 4294967295)
						v25(arg)
						local n22 = v31 - 2355613852
					end
				end)
			end
		end)
	end

	v13 = bit32.bxor(n4, 0)
	n6 = n3 // 7 + v13

	fn9 = function(arg)
		fn25(arg)

		for _, v14 in ipairs({ 0.1, 0.35, 0.75, 1.5 }) do
			local n7 = 270087590

			task.delay(v14, function()
				local n8 = 3879252170
				local n9 = 2449464986
				local n10 = 3543280622

				if arg.Parent then
					local v15 = fn7
					bit32.bxor(n8, 2454663689)
					local v16 = bit32.band(n9, n10)
					v15(arg)
				end
			end)
		end
	end

	fn10 = function(arg)
		type(0)
		local n7 = 2852871013
		local n8 = 3816978632
		local n9 = 501693614
		local n10 = 387329843
		local flag = not arg
		local flag2

		if flag then
			flag2 = flag
		else
			local Headless = fn4("Headless")
			n8 = bit32.bxor(bit32.rshift(n8, 10), 3820656726)
			flag2 = not Headless
		end

		if flag2 then
			return
		end

		tbl4[#tbl4 + 1] = arg.ChildAdded:Connect(function(child)
			local n11 = 1966627881

			if child:IsA("Decal") then
				child.Transparency = 1
				bit32.bxor(n11, 3194726028)
			end
		end)

		bit32.bxor(n7, 2776811473)
		bit32.band(n10, n8)
	end

	fn11 = function()
		local n7 = 107507824
		local n8 = 2115046664

		if connection then
			connection:Disconnect()
			connection = nil
			local v14 = table.pack(bit32.band(n8, 4294967295))
			local v15 = table.pack(bit32.band(n7, 4294967295))
			local v16 = table.pack(bit32.band(v14[1], 65535))
			local v17 = table.pack(bit32.rshift(v14[1], 16))
			local v18 = table.pack(bit32.band(v15[1], 65535))
			bit32.bxor(bit32.band(v16[1] * v18[1] + bit32.lshift(bit32.band(v16[1] * bit32.rshift(v15[1], 16) + v17[1] * v18[1], 65535), 16), 4294967295), 1719156360)
		end

		for i = #tbl4, 1, -1 do
			local v14 = tbl4[i]

			if v14 and v14.Connected then
				v14:Disconnect()
			end

			tbl4[i] = nil
		end
	end

	local fn26, v14, n7

	do
		local v15 = bit32.bxor(v12, 310269706)

		fn26 = function(arg)
			return tbl14[arg] == true
		end

		local v16 = table.pack(bit32.band(v15, 4294967295))
		local v17 = table.pack(bit32.band(v16[1], 65535))
		local n8 = bit32.band(30390 * v17[1] + bit32.lshift(bit32.band(30390 * bit32.rshift(v16[1], 16) + 12058 * v17[1], 65535), 16), 4294967295) + 3691432960
		local v18 = table.pack(bit32.band(bit32.bor(v15, 37032448), 4294967295))
		local v19 = table.pack(bit32.band(v18[1], 65535))
		local v20 = bit32.band(4756 * v19[1] + bit32.lshift(bit32.band(4756 * bit32.rshift(v18[1], 16) + 41419 * v19[1], 65535), 16), 4294967295)
		local v21 = table.pack(bit32.band(bit32.bxor(v15, 37032448), 4294967295))
		local v22 = table.pack(bit32.band(v21[1], 65535))
		local n9 = n8 + v20 + bit32.band(30391 * v22[1] + bit32.lshift(bit32.band(30391 * bit32.rshift(v21[1], 16) + 12058 * v22[1], 65535), 16), 4294967295)

		fn12 = function(arg)
			local n10 = 3886739102
			local n11 = 3277025874
			local n12 = 1441735333
			local v23 = fn26(arg)
			local flag

			if v23 then
				bit32.bxor(n10, 1578954642)
				local v24 = bit32.bxor(n12 - n11, 3346305782)
				flag = arg ~= "BodyColors"
			else
				flag = v23
			end

			return flag
		end

		fn13 = function(arg)
			local n10 = 2759507381
			local n11 = 3715398111
			local flag = arg == "Accessory"
			local n12 = 3715398111
			local flag2

			if flag then
				flag2 = flag
			else
				flag2 = arg == "Hat"
				bit32.bxor(n10, 88521274)
				bit32.bxor(n11 - 1360765171, 1361879347)
			end

			return flag2
		end

		fn14 = function(arg)
			local tbl19 = {}
			if not arg then
				return tbl19
			end

			for _, child in ipairs(arg:GetChildren()) do
				if child:IsA("BasePart") then
					tbl19[child.Name] = child
				end
			end

			return tbl19
		end

		v14 = bit32.bxor(n5, n6)
		local n10 = bit32.bxor(n9, 504828279) + 2140657789
		local v23 = table.pack(bit32.band(v13, 4294967295))
		local v24 = table.pack(bit32.band(v23[1], 65535))
		local v25 = bit32.band(55421 * v24[1] + bit32.lshift(bit32.band(55421 * bit32.rshift(v23[1], 16) + 32663 * v24[1], 65535), 16), 4294967295)
		local v26 = table.pack(bit32.band(bit32.bnot(v13), 4294967295))
		local v27 = table.pack(bit32.band(v26[1], 65535))
		n7 = n10 + v25 + bit32.band(55421 * v27[1] + bit32.lshift(bit32.band(55421 * bit32.rshift(v26[1], 16) + 32663 * v27[1], 65535), 16), 4294967295)
	end

	local v15
	v15 = n6

	fn15 = function(arg)
		local n8 = 220961167
		local n9 = 407139671
		local tbl19 = {}
		local v16 = pairs
		arg = arg or {}

		for k, v17 in v16(arg) do
			for _, child in ipairs(v17:GetChildren()) do
				if child:IsA("Attachment") then
					local v18 = tbl19[child.Name]
					n8 = bit32.bxor(n8, 3595026774)

					if v18 == nil then
						tbl19[child.Name] = k
					elseif v18 ~= k then
						tbl19[child.Name] = false
						n9 = bit32.bxor(n9, 3693280797)
					end
				end
			end
		end

		return tbl19
	end

	countMapEntries = nil
	pruneTimestampedCache = nil
	prunePairedTimestampCache = nil
	cacheGetTimed = nil
	cacheSetTimed = nil
	cacheGetEntry = nil
	cacheSetEntry = nil

	fn16 = function(arg)
		local n8 = 418822694
		local n9 = 2580485868
		if not arg then
			return nil
		end
		local v16 = ipairs
		bit32.rshift(n9, 22)

		for _, child in v16(arg:GetChildren()) do
			if child:IsA("Decal") and child.Face == Enum.NormalId.Front and child.Texture ~= "" then
				return child.Texture
			end
		end

		for _, child in ipairs(arg:GetChildren()) do
			if child:IsA("Decal") and child.Texture ~= "" then
				return child.Texture
			end
		end

		bit32.bxor(n8, 484803250)
		return nil
	end

	fn17 = function(arg, arg2)
		local n8 = 2787309746
		local n9 = 3430342006
		local n10 = 3378726356

		if arg2 and arg2 ~= "" then
			local v16 = cacheSetTimed
			bit32.bxor(n8, 3926738322)
			v16(tbl5, tbl6, arg, arg2, tbl12.faceTexture)
		end

		return arg2
	end

	fn18 = function(arg, arg2)
		type(0)
		local n8 = 3606505402
		local n9 = 8660997609
		local n10 = 1204803561
		local n11 = 3759252470

		local ok2, result2 = pcall(function()
			return InsertService:LoadAsset(arg)
		end)

		if ok2 and result2 then
			local v16, v17, v18 = ipairs(result2:GetDescendants())
			bit32.bxor(n8, 1864652730)
			local n12 = n11 // n10
			local texture = nil

			for _, v19 in v16, v17, v18 do
				if v19:IsA("Decal") and v19.Texture ~= "" then
					texture = v19.Texture
					break
				else
					texture = nil
				end
			end

			result2:Destroy()
			if texture then
				return fn17(arg2, texture)
			end
			bit32.bxor(n12, 3759252469)
		end

		return fn17(arg2, "rbxassetid://" .. tostring(arg))
	end

	countMapEntries = function(arg)
		local n8 = 4205080280
		local n9 = 0

		for k in pairs(arg) do
			n9 += 1
			n8 = bit32.bxor(n8, 2387723691)
		end

		return n9
	end

	pruneTimestampedCache = function(arg, arg2, arg3)
		local v16 = countMapEntries(arg)

		while v16 > arg2 do
			local huge = math.huge
			local v17 = nil

			for k, v18 in pairs(arg) do
				v18 = v18 and v18.timestamp or 0

				if v18 < huge then
					huge = v18
					v17 = k
				end
			end

			if v17 ~= nil then
				local v18 = arg[v17]
				arg[v17] = nil

				if arg3 then
					arg3(v17, v18)
				end

				v16 -= 1
				continue
			end

			break
		end
	end

	prunePairedTimestampCache = function(arg, arg2, arg3)
		local n8 = 1099489917
		local v16 = countMapEntries(arg)

		while arg3 < v16 do
			local v17 = pairs
			n8 = bit32.bxor(n8, 240100918)
			local v18, v19, v20 = v17(arg)
			local huge = math.huge
			local v21 = nil

			for k in v18, v19, v20 do
				local n9 = arg2[k] or 0

				if n9 < huge then
					huge = n9
					v21 = k
				end
			end

			if v21 ~= nil then
				arg[v21] = nil
				arg2[v21] = nil
				v16 -= 1
				continue
			end

			break
		end
	end

	do
		local function fn27(arg, arg2, arg3, arg4)
			local n8 = 1375418033
			local v16 = arg[arg3]
			local v17 = arg2[arg3]
			if v16 ~= nil and v17 and os.clock() - v17 <= arg4 then
				return v16
			end

			if v16 ~= nil then
				arg[arg3] = nil
				local n9 = bit32.bxor(n8, 4294967295) - 1544131229
			end

			if v17 ~= nil then
				arg2[arg3] = nil
			end

			return nil
		end

		local n8 = v14 - n6 + bit32.bxor(n4, 0)
		cacheGetTimedNow = fn27
	end

	cacheSetTimedNow = function(arg, arg2, arg3, arg4, arg5)
		arg[arg3] = arg4
		arg2[arg3] = os.clock()
		prunePairedTimestampCache(arg, arg2, arg5)
		return arg4
	end

	local tbl19, v16, n8, fn27, v17, fn28, fn29, fn30, fn31, fn32
	local fn33, fn34, tbl20, tbl21, v18, tbl22, tbl23, tbl24, tbl25, tbl26
	local n9, v19, v20

	do
		local function fn35(arg, arg2, arg3, arg4)
			local n10 = 3599619277
			local n11 = 1877668290
			local n12 = 3527252046
			local n13 = 671784783
			local v21 = arg[arg2]
			if not v21 then
				return nil
			end
			local n14 = n13 // 4
			local now = os.clock()
			bit32.bxor(n11, 2492303864)
			if now - (v21.timestamp or 0) <= arg3 then
				return v21
			end

			if arg4 then
				arg4(v21)
				bit32.bxor(n10, 3832935065)
			end

			bit32.bxor(n12, n14)
			arg[arg2] = nil
			return nil
		end

		local v21 = bit32.bxor(n4, 0)
		local v22 = bit32.bxor(n6, v21)
		cacheGetEntryNow = fn35

		cacheSetEntryNow = function(arg, arg2, arg3, arg4, arg5)
			arg[arg2] = arg3
			pruneTimestampedCache(arg, arg4, arg5)
			return arg3
		end

		cacheGetTimed = cacheGetTimedNow
		cacheSetTimed = cacheSetTimedNow
		cacheGetEntry = cacheGetEntryNow
		cacheSetEntry = cacheSetEntryNow

		local function fn36(arg)
			local n10 = 3405212973
			local n11 = 1819134449
			local n12 = 3103039650
			local v23 = cacheGetEntry
			local n13 = 726350672
			local v24 = bit32.bor(2122844141, n11)

			local v25 = v23(tbl8, arg, 20, function(arg2)
				local n14 = 3582821233
				local n15 = 2632274895

				if arg2 and arg2.model then
					local flag = bit32.bxor(n15, 312138106) == 204426945
					local v25 = pcall
					local n16 = 446239845

					local function fn37()
						arg2.model:Destroy()
					end

					bit32.bxor(n14, 347420883)
					local v26 = bit32.bxor(n15, 4294967295)
					v25(fn37)
				end
			end)

			if v25 and v25.model then
				local n14 = 259976073

				local ok2, result2 = pcall(function()
					return v25.model:Clone()
				end)

				n11 = bit32.band(n11, v24)
				if ok2 and result2 then
					return result2
				end
			end

			local v26 = nil
			local flag = false

			for i = 1, 2 do
				local ok2, result2 = pcall(function()
					return Players2:GetCharacterAppearanceAsync(arg)
				end)

				if ok2 and result2 then
					v26 = result2
					flag = true
					break
				elseif i == 1 then
					task.wait(0.15)
				end
			end

			if not (flag and v26) then
				return nil
			end

			local function fn37()
				return v26:Clone()
			end

			local n14 = n11 // 177
			local ok2, result2 = pcall(fn37)

			if ok2 and result2 then
				local v27 = tbl8[arg]

				if v27 and v27.model then
					pcall(function()
						v27.model:Destroy()
					end)
				end

				local v28 = cacheSetEntry
				local tbl27 = { model = result2 }
				local v29 = os
				local n15 = v24 - n14
				bit32.bxor(n12, 2925399478)
				local clock = v29.clock
				local v30 = bit32.bxor(n14, n15)
				bit32.bxor(n10, 419247945)
				tbl27.timestamp = clock()

				v28(tbl8, arg, tbl27, tbl12.appearanceModel, function(arg2, arg3)
					local n16 = 1905818758
					local n17 = 4119614899
					local n18 = 179643084
					local n19 = 3122183884
					local model

					if arg3 then
						model = arg3.model
						bit32.bxor(n17, 3840045849)
						local v31 = bit32.lshift(n18, 28)
						bit32.bxor(n16, 2787814973)
						bit32.bxor(v31, 3400868556)
					else
						model = arg3
					end

					if model then
						local n20 = 589755913

						pcall(function()
							arg3.model:Destroy()
						end)
					end
				end)

				bit32.bxor(n15, 12399327)
				bit32.bxor(v30, 2119236898)
			end

			return v26
		end

		local n10 = v22 * 21566
		getCharacterAppearanceModel = fn36
		v8 = bit32.bxor(n7, 119515763)

		getTargetDescriptionCached = function(arg)
			local n11 = 4028161913
			local n12 = 4062189674
			local n13 = 3015755919
			local v23 = cacheGetEntry
			local v24 = table.pack(bit32.band(n13, 4294967295))
			local v25 = table.pack(bit32.band(v24[1], 65535))
			local v26 = bit32.band(14338 * v25[1] + bit32.lshift(bit32.band(14338 * bit32.rshift(v24[1], 16) + 8891 * v25[1], 65535), 16), 4294967295)
			local n14 = 9577339388

			local v27 = v23(tbl7, arg, 20, function(arg2)
				local n15 = 4286124862
				local n16 = 1821130490
				local n17 = 890953928
				local desc

				if arg2 then
					desc = arg2.desc
					bit32.bxor(n15, 2873939307)
					bit32.bxor(n16, 1503059506)
				else
					desc = arg2
				end

				if desc then
					local flag = bit32.bxor(n14, 0) == 441524647
					local n18 = 834399531

					pcall(function()
						arg2.desc:Destroy()
					end)
				end
			end)

			if v27 and v27.desc then
				local ok2, result2 = pcall(function()
					return v27.desc:Clone()
				end)

				if ok2 and result2 then
					return result2
				end
			end

			local ok2, result2 = pcall(function()
				return Players2:GetHumanoidDescriptionFromUserId(arg)
			end)

			local v28 = table.pack(bit32.band(n13, 4294967295))
			local v29 = table.pack(bit32.band(v26, 4294967295))
			local v30 = table.pack(bit32.band(v28[1], 65535))
			local v31 = table.pack(bit32.rshift(v28[1], 16))
			local v32 = table.pack(bit32.band(v29[1], 65535))
			local v33 = bit32.band(v30[1] * v32[1] + bit32.lshift(bit32.band(v30[1] * bit32.rshift(v29[1], 16) + v31[1] * v32[1], 65535), 16), 4294967295)
			if not ok2 or not result2 then
				bit32.bxor(n12, 3082738862)
				return nil
			end

			local ok3, result3 = pcall(function()
				return result2:Clone()
			end)

			if ok3 and result3 then
				local v34 = tbl7[arg]
				local n15 = 364389494
				local v35 = bit32.bor(v33, 318006507)

				if v34 and v34.desc then
					pcall(function()
						v34.desc:Destroy()
					end)
				end

				local v36 = cacheSetEntry
				local tbl27 = { desc = result3 }
				bit32.bxor(n11, 1021993753)
				local n16 = n15 - 174690610
				tbl27.timestamp = os.clock()
				local v37 = tbl12
				local v38 = bit32.bxor(v35, v26)

				v36(tbl7, arg, tbl27, v37.description, function(arg2, arg3)
					local n17 = 1335960534
					local n18 = 1382335433
					local n19 = 287169673
					local desc

					if arg3 then
						desc = arg3.desc
						local n20 = bit32.bxor(n18, 4294967295) - 1530296429
						bit32.bxor(n17, 3302163326)
					else
						desc = arg3
					end

					if desc then
						bit32.bxor(n19, 6962006)
						local n20 = 13152841907

						pcall(function()
							arg3.desc:Destroy()
						end)
					end
				end)
			end

			local ok4, result4 = pcall(function()
				return result2:Clone()
			end)

			return ok4 and result4 or result2
		end

		getCharacterAppearanceInfoCached = function(arg)
			type(449290514)
			local n11 = 777231711
			local n12 = 2203700224
			local n13 = 2405306072
			local v23 = cacheGetEntry
			local n14 = 689644640
			local v24 = bit32.bor(211565974, n13)
			local v25 = v23(tbl9, arg, 20)
			if v25 and v25.info then
				return v25.info
			end
			local v26 = pcall
			local n15 = 1574632710 + n14 + 2676104757
			bit32.bxor(n12, 1259778753)

			local v27, v28 = v26(function()
				return Players2:GetCharacterAppearanceInfoAsync(arg)
			end)

			if v27 and v28 then
				local v29 = cacheSetEntry
				local tbl27 = { info = v28 }
				bit32.bxor(n11, 3568349411)
				tbl27.timestamp = os.clock()
				v29(tbl9, arg, tbl27, tbl12.appearanceInfo)
				return v28
			end

			bit32.bor(v24, n13)
			return nil
		end

		clearAvatarCaches = function()
			local n11 = 3749787906
			local n12 = 2001665910
			local n13 = 1756638819

			for k, v23 in pairs(tbl7) do
				if v23 and v23.desc then
					bit32.bxor(n13, 464578602)
					local n14 = 13184334837

					pcall(function()
						v23.desc:Destroy()
					end)
				end

				tbl7[k] = nil
			end

			for k, v23 in pairs(tbl8) do
				if v23 and v23.model then
					local n14 = 784117718

					pcall(function()
						v23.model:Destroy()
					end)
				end

				tbl8[k] = nil
			end

			local v23 = pairs
			local v24 = bit32.bxor(n13, n12)
			bit32.bxor(n11, 1201260629)

			for k in v23(tbl9) do
				tbl9[k] = nil
			end

			for k in pairs(tbl5) do
				tbl5[k] = nil
				tbl6[k] = nil
			end

			local v25 = pairs
			bit32.bxor(n12, v24)

			for k in v25(tbl11) do
				tbl10[k] = nil
				tbl11[k] = nil
			end
		end

		clearCopyChildren = function(arg)
			local n11 = 3246314333

			for _, child in ipairs(arg:GetChildren()) do
				if fn26(child.ClassName) then
					local n12 = 379731069

					pcall(function()
						child:Destroy()
					end)
				end
			end
		end

		hasAnySourceBodyPart = function(arg)
			local n11 = 612129493
			local n12 = 2849373727

			for _, v23 in ipairs(tbl17) do
				if arg:FindFirstChild(v23) then
					return true
				end
			end

			bit32.band(n12, 3478910888)
			bit32.bxor(n11, 1795619952)
			return false
		end

		normalizeForLookup = function(arg)
			local n11 = 639137888
			local n12 = 3869011053
			local n13 = 1098013023
			local lower = string.lower
			local v23 = tostring
			local str2 = arg or ""
			local v24 = table.pack(v23(str2))
			bit32.rshift(n13, 3)
			local v25 = lower(table.unpack(v24, 1, v24.n))
			local v26 = string
			local v27 = bit32.band(n12, 3066932616)
			local v28 = string.gsub(v26.gsub(v25, "^@", ""), "%s+", "")
			local gsub = string.gsub
			bit32.bxor(n11, 2780028168)
			bit32.band(v27, 1363924467)
			return (gsub(v28, "_+", ""))
		end

		findUserIdInServerByNameOrDisplay = function(arg)
			local n11 = 2556859471
			local v23 = tostring
			local n12 = 609396727
			local n13 = 609396727
			local str2 = v23(arg or ""):gsub("^%s+", ""):gsub("%s+$", "")
			local v24 = string.lower(str2)
			local v25 = normalizeForLookup(str2)
			if v25 == "" then
				return nil
			end
			local tbl27 = {}
			local userId = nil
			local n14 = 0
			local userId2 = nil

			for _, player in ipairs(Players2:GetPlayers()) do
				local v26 = string.lower(player.Name)
				local v27 = string.lower(player.DisplayName)
				local v28 = normalizeForLookup(player.Name)
				local v29 = normalizeForLookup(player.DisplayName)

				if v26 == v24 or v28 == v25 then
					userId2 = player.UserId
					break
				else
					if v27 == v24 or v29 == v25 then
						userId = player.UserId
						n14 += 1
					end

					local flag = v24 ~= "" and string.sub(v26, 1, #v24) == v24 or string.sub(v28, 1, #v25) == v25
					n12 = bit32.bxor(n12, 3796115646)
					local flag2 = v24 ~= "" and string.sub(v27, 1, #v24) == v24 or string.sub(v29, 1, #v25) == v25

					if flag or flag2 then
						tbl27[#tbl27 + 1] = player.UserId
						userId2 = nil
					else
						userId2 = nil
					end
				end
			end

			if userId2 then
				return userId2
			end

			if n14 == 1 then
				return userId
			end

			if #tbl27 > 0 then
				return tbl27[1]
			end

			if userId then
				return userId
			end
			return nil
		end

		resolveUserToId = function(arg)
			local n11 = 356867471
			type(356867471)
			local n12 = 415659053
			local n13 = 906507216
			local n14 = 2842506724
			local n15 = 2640549377
			if arg == nil then
				return nil
			end
			local kind = type(arg)
			local v23 = bit32.bxor(n11, 139559466)

			if kind == "number" then
				local v24 = math
				bit32.bxor(n13, 1751266094)
				local v25 = table.pack(bit32.band(n14, 4294967295))
				local v26 = table.pack(bit32.band(n15, 4294967295))
				local v27 = table.pack(bit32.band(v25[1], 65535))
				local v28 = table.pack(bit32.rshift(v25[1], 16))
				local v29 = table.pack(bit32.band(v26[1], 65535))
				bit32.band(v27[1] * v29[1] + bit32.lshift(bit32.band(v27[1] * bit32.rshift(v26[1], 16) + v28[1] * v29[1], 65535), 16), 4294967295)
				return v24.floor(arg)
			end

			if type(arg) ~= "string" then
				return nil
			end
			local str2 = arg:gsub("^%s+", ""):gsub("%s+$", "")
			local n16 = n15 // n14
			if str2 == "" then
				return nil
			end
			local num = tonumber(str2)
			if num then
				return math.floor(num)
			end
			local str3 = str2:gsub("^@", "")
			local v24 = table.pack(bit32.band(v23, 4294967295))
			local v25 = table.pack(bit32.band(v24[1], 65535))
			local n17 = bit32.band(54525 * v25[1] + bit32.lshift(bit32.band(54525 * bit32.rshift(v24[1], 16) + 2497 * v25[1], 65535), 16), 4294967295) + 728969947
			local v26 = table.pack(bit32.band(bit32.bor(v23, 167729847), 4294967295))
			local v27 = table.pack(bit32.band(v26[1], 65535))
			local v28 = bit32.band(11012 * v27[1] + bit32.lshift(bit32.band(11012 * bit32.rshift(v26[1], 16) + 63038 * v27[1], 65535), 16), 4294967295)
			local v29 = table.pack(bit32.band(bit32.band(v23, 167729847), 4294967295))
			local v30 = table.pack(bit32.band(v29[1], 65535))
			local n18 = n17 + v28 + bit32.band(11010 * v30[1] + bit32.lshift(bit32.band(11010 * bit32.rshift(v29[1], 16) + 63038 * v30[1], 65535), 16), 4294967295)
			if str3 == "" then
				return nil
			end
			local v31 = normalizeForLookup(str3)
			if v31 == "" then
				return nil
			end
			local n19 = n16 // n14
			local v32 = cacheGetTimed(tbl10, tbl11, v31, 600)
			if v32 then
				return v32
			end
			local v33 = findUserIdInServerByNameOrDisplay(str3)

			if v33 then
				local v34 = cacheSetTimed
				bit32.band(n19, n14)
				return v34(tbl10, tbl11, v31, v33, tbl12.resolvedUserId)
			end

			local ok2, result2 = pcall(function()
				return Players2:GetUserIdFromNameAsync(str3)
			end)

			if ok2 and result2 then
				local v34 = cacheSetTimed
				bit32.bxor(n12, 1041983751)
				return v34(tbl10, tbl11, v31, result2, tbl12.resolvedUserId)
			end

			return nil
		end

		if ok and result then
			result.__ResolveUserToIdShared = resolveUserToId
			n10 = n10 * 55264 - 1191801858
		end

		fn19 = function()
			return resolveUserToId(tbl3.target)
		end

		tbl19 = { active = false, serial = 0, identity = nil }
		local v23 = setmetatable
		local tbl27 = {}
		local v24 = bit32.rshift(bit32.bxor(n4, 0), 11)
		tbl27.__mode = "k"
		tbl19.originals = v23({}, tbl27)
		tbl19.identityCache = {}
		v16 = bit32.bxor(n4, 229394121)
		tbl19.connections = {}
		local v25 = setmetatable
		local tbl28 = {}
		local n11 = bit32.bor(n10, v24)
		tbl28.__mode = "k"
		n8 = bit32.lshift(v24, 1)
		tbl19.boundObjects = v25({}, tbl28)
		tbl19.boundRoots = setmetatable({}, { __mode = "k" })
		local str2 = "__CiderInspectTargetState"
		local v26 = ok and result and result[str2]
		local tbl29

		if v26 then
			tbl29 = v26
		else
			n11 = bit32.bor(n11, 4283499944) - 4283498752
			tbl29 = nil
		end

		if type(tbl29) ~= "table" then
			tbl29 = { active = false, targetUserId = nil }
			local v27 = bit32.lshift(n11, 21)
			tbl29.targetName = nil
			tbl29.targetDescription = nil
			local v28 = bit32.bxor(v16, 44102898)
			tbl29.hookInstalled = false
			local v29 = bit32.bxor(v28, 0)
			local v30 = bit32.bxor(n8, v29)
			v15 = v30
			local v31 = v30
			tbl29.hookVersion = 0

			if ok and result then
				result[str2] = tbl29
			end

			v16 = bit32.bxor(v28, 44102898)
			n8 = v31 + 4075101361
			n11 = bit32.bxor(v27, 3756021503)
		end

		tbl29.refreshing = false
		tbl29.lastRefresh = tonumber(tbl29.lastRefresh) or 0
		fn27 = nil
		v17 = n11

		local function fn37()
			local targetDescription = tbl29.targetDescription
			tbl29.targetDescription = nil
			tbl29.preferDescription = false

			if targetDescription then
				local n12 = 490535265

				pcall(function()
					targetDescription:Destroy()
				end)
			end
		end

		fn20 = function()
			tbl29.active = false
			tbl29.targetUserId = nil
			tbl29.targetName = nil
			tbl29.refreshing = false
			tbl29.lastRefresh = 0
			fn37()
		end

		fn28 = function(arg, arg2, targetDescription)
			local n12 = 3387003908
			local n13 = 4126156049
			local n14 = 3441897896
			local targetUserId = tonumber(arg)
			if not targetUserId then
				return
			end
			local flag = tbl29.targetUserId ~= targetUserId
			local n15 = bit32.bor(n14, 3792992055)

			if flag then
				local n16 = 8991748301

				pcall(function()
					GuiService:CloseInspectMenu()
				end)

				fn37()
				tbl29.refreshing = false
				local v27 = tbl29
				bit32.bxor(n12, 1207641644)
				v27.lastRefresh = 0
				n13 = n13 // 20 - 375119049
			end

			tbl29.active = true
			tbl29.targetUserId = targetUserId

			if arg2 ~= nil then
				tbl29.targetName = tostring(arg2)
				n15 = n15 // n13 + 4013389759
			end

			if targetDescription then
				fn5(targetDescription)
				fn37()
				tbl29.targetDescription = targetDescription
				tbl29.preferDescription = true
				bit32.bxor(n15, 449270446)
			end
		end

		local function fn38(arg)
			local flag = type(0) == "thread"
			local n12 = 978126163
			local n13 = 605935292
			local num = tonumber(arg)
			if num then
				return num
			end

			local function fn39()
				return arg.Id or arg.UserId
			end

			local ok2, result2 = pcall(fn39)
			if ok2 then
				return tonumber(result2)
			end
			return nil
		end

		local v27 = bit32.bxor(n11, 3452242598)

		if tbl29.hookVersion ~= 2 then
			local v28 = hookmetamethod
			local v29 = getnamecallmethod
			local kind = type(v28)
			local n12 = v27 - bit32.bxor(v16, 0)

			if kind == "function" and type(v29) == "function" then
				local v30 = nil

				local function fn39(arg, ...)
					local n13 = 1275050851
					local n14 = 195503847
					local n15 = 1136975390
					local n16 = 3788849482
					local v31 = v29()
					local v32 = ok and result
					local n17 = 3788849482

					if v32 then
						v32 = result[str2]
						n16 = bit32.bxor(bit32.band(n16, n15), 2685468992)
					end

					v32 = v32 or tbl29
					local active = v32 and v32.active

					if active then
						active = arg == GuiService
						n15 = n15 // 55 - 3178664185
					end

					if active then
						local tbl30 = { ... }

						if v31 == "InspectPlayerFromUserId" then
							local userId = localPlayer2.UserId
							local flag = fn38(tbl30[1]) == userId
							local v33 = bit32.lshift(n15, 20)

							if flag and v32.targetUserId then
								if v32.preferDescription and v32.targetDescription then
									type("preferDescription")
									local targetDescription = v32.targetDescription
									local v34 = bit32.bxor(n16, 4294967295)
									local targetName = v32.targetName
									local n18 = 266567580
									targetName = targetName or tostring(v32.targetUserId)
									local defer = task.defer
									bit32.bxor(n13, 2065816940)

									defer(function()
										local flag2 = bit32.bxor(n18, 0) + 60962124 == 392619610
										local n19 = 8779539789

										pcall(function()
											GuiService:CloseInspectMenu()
										end)

										pcall(function()
											GuiService:InspectPlayerFromHumanoidDescription(targetDescription, targetName)
										end)
									end)

									bit32.rshift(v34, 5)
									return nil
								end

								tbl30[1] = v32.targetUserId
							end
						else
							local n18 = bit32.bxor(n15, 4294967295)

							if v31 == "InspectPlayerFromHumanoidDescription" then
								local str3 = tostring(tbl30[2] or "")
								local n19 = n16 + n18
								local flag = str3 == localPlayer2.Name or str3 == localPlayer2.DisplayName

								if flag then
									flag = v32.targetDescription
									n18 = n18 + 338272828 + 3956694468
								end

								if flag then
									tbl30[1] = v32.targetDescription
									bit32.bxor(n14, 3041088324)
									tbl30[2] = v32.targetName or str3
								end

								n16 = n19 + 1136975391
							end

							bit32.bxor(n18, 1574642145)
						end

						local v33 = table
						bit32.bor(n16, 442846822)
						return v30(arg, v33.unpack(tbl30))
					end

					return v30(arg, ...)
				end

				local flag = type(newcclosure) == "function" and newcclosure(fn39) or fn39
				local v31 = pcall
				local v32 = table.pack(bit32.band(n8, 4294967295))
				local v33 = table.pack(bit32.band(n12, 4294967295))
				local v34 = table.pack(bit32.band(v32[1], 65535))
				local v35 = table.pack(bit32.rshift(v32[1], 16))
				local v36 = table.pack(bit32.band(v33[1], 65535))
				local n13 = bit32.band(v34[1] * v36[1] + bit32.lshift(bit32.band(v34[1] * bit32.rshift(v33[1], 16) + v35[1] * v36[1], 65535), 16), 4294967295)

				local v37, v38 = v31(function()
					return v28(game, "__namecall", flag)
				end)

				if v37 and type(v38) == "function" then
					v30 = v38
					tbl29.hookInstalled = true
					local v39 = bit32.lshift(n13, 15)
					tbl29.hookVersion = 2
					n13 = v39 + 3310279056
				end

				n8 = n13 + 3454643270
			end

			v27 = bit32.bxor(n12, 1942951937)
		end

		fn29 = function(arg)
			local n12 = 1607046521
			local flag = type(arg) ~= "string"
			local v28 = bit32.bxor(3541439263, n12)
			if flag then
				return false
			end
			local v29 = string.lower(arg)

			for _, v30 in ipairs({ localPlayer2.Name, localPlayer2.DisplayName }) do
				local v31 = string.lower(tostring(v30 or ""))
				if v31 == "" then
					continue
				end

				if v29 == v31 .. "'s avatar" or v29 == v31 .. "’s avatar" then
					return true
				end
			end

			return false
		end

		fn30 = function()
			local n12 = 4215414366
			local n13 = 2539990726
			local active = tbl29.active
			local v28 = table.pack(bit32.band(n13, 4294967295))
			local v29 = table.pack(bit32.band(v28[1], 65535))
			local v30 = bit32.band(57503 * v29[1] + bit32.lshift(bit32.band(57503 * bit32.rshift(v28[1], 16) + 34657 * v29[1], 65535), 16), 4294967295)
			if not active or not tbl29.targetUserId then
				return
			end
			local now = os.clock()
			local n14 = n13 - v30
			local refreshing = tbl29.refreshing

			if not refreshing then
				refreshing = now - tbl29.lastRefresh < 1.5
				local n15 = bit32.bor(v30, 1317433540) - 1275342852
			end

			if refreshing then
				return
			end
			tbl29.refreshing = true
			tbl29.lastRefresh = now
			local v31 = task
			bit32.bxor(n12, 1236250293)
			local defer = v31.defer
			local v32 = n14

			local function fn39()
				local n15 = 1481921525
				local v33 = bit32.bxor(v32, 2583123375)
				local flag = not tbl29.active
				local n16 = 124943303
				local n17 = 637114417 - v33
				if flag or not tbl29.targetUserId then
					tbl29.refreshing = false
					return
				end

				pcall(function()
					GuiService:CloseInspectMenu()
				end)

				local v34 = task
				local v35 = bit32.bor(v33, 3058589035)
				v34.wait()
				local flag2 = false

				if tbl29.targetDescription then
					local v36 = pcall
					local n18 = 433978630

					local function fn40()
						local n19 = 1603364554
						local v37 = GuiService
						local inspectPlayerFromHumanoidDescrip = v37.InspectPlayerFromHumanoidDescription
						local targetDescription = tbl29.targetDescription
						local targetName = tbl29.targetName
						local v38

						if targetName then
							v38 = targetName
						else
							local v39 = tostring
							local v40 = tbl29
							bit32.bxor(n19, 982434590)
							v38 = v39(v40.targetUserId)
						end

						inspectPlayerFromHumanoidDescrip(v37, targetDescription, v38)
					end

					bit32.bxor(n15, 758855465)
					flag2 = v36(fn40)
				end

				if not flag2 then
					pcall(function()
						GuiService:InspectPlayerFromUserId(tbl29.targetUserId)
					end)
				end

				local v36 = task
				bit32.band(v35, 2500974900)

				v36.delay(1.25, function()
					tbl29.refreshing = false
				end)
			end

			bit32.bxor(n14, 3573889079)
			defer(fn39)
		end

		fn21 = function(arg)
			local n12 = 1660106711
			local n13 = 676789969
			local n14 = 3285687499
			local n15 = 3757705292
			if tbl13.active then
				return
			end
			local flag = not fn4("Headless")
			local v28

			if flag then
				local flag2 = not fn4("Korblox")
				bit32.bxor(n13, 3613912466)
				n14 = bit32.bxor(bit32.band(n14, n15), 365699)
				v28 = flag2
			else
				v28 = flag
			end

			if v28 then
				fn20()

				if fn27 then
					local v29 = fn27
					bit32.bxor(n12, 206902287)
					v29(nil)
				end

				return
			end

			local v29 = n15

			task.spawn(function()
				local n16 = bit32.bxor(v29, 0) + 405904028
				local n17 = 1913344454
				local n18 = 523680600
				local n19 = bit32.bxor(v29, 2420808588)
				local n20 = 8717274495
				local v30 = arg
				local humanoid

				if arg then
					humanoid = arg:FindFirstChildOfClass("Humanoid")
				else
					humanoid = v30
				end

				if not humanoid and arg then
					humanoid = arg:WaitForChild("Humanoid", 10)
					n19 = n19 // 128 - 2968440167
				end

				if not humanoid or not arg.Parent or tbl13.active then
					return
				end
				local appliedDescription = nil
				local v31 = bit32.bxor(n20, 480574983)
				local v32 = pcall
				local v33 = bit32.bor(n17, 2981267738)

				v32(function()
					appliedDescription = humanoid:GetAppliedDescription()
				end)

				appliedDescription = appliedDescription or getTargetDescriptionCached(localPlayer2.UserId)
				local flag2 = not appliedDescription

				if not flag2 then
					flag2 = tbl13.active
					local n21 = bit32.band(n19, v33) - 4093640192
				end

				if flag2 then
					return
				end
				local n21 = v33 + 1965561904
				fn5(appliedDescription)
				local v34 = fn28
				local userId = localPlayer2.UserId
				local v35 = localPlayer2
				bit32.bxor(n18, 1863595037)
				v34(userId, v35.DisplayName, appliedDescription)

				if fn27 then
					fn27(appliedDescription, localPlayer2.UserId)
					local v36 = bit32.bxor(n21 * 2, 3106149906)
				end
			end)
		end

		fn31 = function(arg, arg2, arg3)
			type(0)
			local n12 = 653704177
			local n13 = 3324204966
			local n14 = 3258990467
			local n15 = 406067541
			local flag = type(arg) ~= "string"

			if not flag then
				local v28 = type
				local v29 = bit32.bxor(n14, 4294967295)
				flag = v28(arg2) ~= "string"
				bit32.bxor(n12, 3683228428)
				bit32.bxor(v29, 4294967295)
			end

			if flag or arg2 == "" then
				return arg
			end

			return arg:gsub(arg2:gsub("([^%w])", "%%%1"), function()
				local v28 = tostring
				return v28(arg3 or "")
			end)
		end

		local function fn39(arg)
			local n12 = 4213098749
			local n13 = 1594294560
			local flag = type(arg) == "string"
			local flag2

			if flag then
				n12 = bit32.bxor(n13, 2753153501)
				flag2 = arg ~= ""
			else
				flag2 = flag
			end

			return flag2 and string.match(arg, "[%w_]") ~= nil
		end

		fn32 = function(arg, arg2, arg3)
			local n12 = 1538544715
			local n13 = 3653534713
			local n14 = 1340030878 // n13
			if type(arg) ~= "string" or type(arg2) ~= "string" or arg2 == "" then
				return arg, false
			end
			local tbl30 = {}
			local v28 = fn39(string.sub(arg2, 1, 1))
			local v29 = fn39
			local v30 = string
			bit32.bxor(n12, 1650802074)
			local v31 = bit32.bxor(n14, 2860790064)
			local v32 = v29(v30.sub(arg2, -1))
			local n15 = 1
			local flag = false

			while n15 <= #arg do
				local v33, v34 = string.find(arg, arg2, n15, true)

				if not v33 then
					tbl30[#tbl30 + 1] = string.sub(arg, n15)
					break
				else
					local str3 = v33 > 1 and string.sub(arg, v33 - 1, v33 - 1) or ""
					local str4 = v34 < #arg and string.sub(arg, v34 + 1, v34 + 1) or ""
					local flag2 = not v28 or not fn39(str3)
					local flag3 = not v32 or not fn39(str4)

					if flag2 and flag3 then
						tbl30[#tbl30 + 1] = string.sub(arg, n15, v33 - 1)
						tbl30[#tbl30 + 1] = tostring(arg3 or "")
						n15 = v34 + 1
						flag = true
					else
						tbl30[#tbl30 + 1] = string.sub(arg, n15, v33)
						n15 = v33 + 1
					end
				end
			end

			local v33 = table
			bit32.bxor(n13, v31)
			return v33.concat(tbl30), flag
		end

		local function fn40(arg, arg2, arg3, arg4)
			local n12 = 1145182315
			local n13 = 263228112
			local n14 = 1730446863
			local n15 = 2282160138 // n14
			if type(arg3) ~= "string" or arg3 == "" or arg2[arg3] then
				return
			end
			local n16 = n14 + 2673645813
			arg2[arg3] = true
			bit32.bxor(n12, 3382148509)
			bit32.bxor(n13, 2587378149)
			local n17 = #arg + 1
			local tbl30 = { from = arg3 }
			local to = tostring(arg4 or "")
			bit32.bxor(n15, n16)
			tbl30.to = to
			arg[n17] = tbl30
		end

		local v28 = bit32.bor(v27 + bit32.bxor(v16, 0), 2373347833)

		fn33 = function(arg)
			local flag = type(0) == "vector"
			local n12 = 22420662
			local tbl30 = {}
			local tbl31 = {}

			local function fn41(arg2, arg3, arg4, arg5)
				bit32.bxor(arg2, 0)
				fn40(tbl30, tbl31, arg3, arg5)
				local lower = string.lower
				fn40(tbl30, tbl31, string.lower(arg3), lower(arg5))
				local v29 = fn40
				local n13 = bit32.bxor(arg2, 0) // 3084059975
				local upper = string.upper
				v29(tbl30, tbl31, string.upper(arg3), upper(arg5))
			end

			fn41(66848741, "@" .. localPlayer2.Name, 343600480, "@" .. arg.username)
			fn41(66848741, localPlayer2.DisplayName, 435134908, arg.displayName)
			fn41(66848741, localPlayer2.Name, 486828789, arg.username)

			table.sort(tbl30, function(arg2, arg3)
				return #arg2.from > #arg3.from
			end)

			return tbl30
		end

		fn34 = function(arg, arg2, arg3)
			local flag = type(0) == "table"
			local n12 = 2344692521
			local n13 = 627721135
			local n14 = 123224342

			local ok2, result2 = pcall(function()
				return Players2:GetUserThumbnailAsync(arg, arg2, arg3)
			end)

			if ok2 then
				ok2 = type(result2) == "string"
				local n15 = bit32.band(n12, n14) + 2290166313
			end

			if ok2 and result2 ~= "" then
				return result2
			end
			return nil
		end

		tbl20 = {}
		tbl21 = { Enum.ThumbnailType.HeadShot, "Size48x48", "headshot" }
		local v29 = bit32.band(n8, v28)
		v18 = bit32.bxor(v16, 370839986)
		tbl22 = { Enum.ThumbnailType.HeadShot, "Size60x60", "headshot" }
		local v30 = bit32.bor(v28, v29)
		tbl23 = { Enum.ThumbnailType.HeadShot, "Size100x100", "headshot" }
		tbl24 = {}
		local thumbnailType = Enum.ThumbnailType
		local v31 = bit32.bxor(v30, 4294967295)
		tbl24[1] = thumbnailType.HeadShot
		tbl24[2] = "Size150x150"
		tbl24[3] = "headshot"
		tbl25 = { Enum.ThumbnailType.HeadShot, "Size420x420", "headshot" }
		tbl26 = {}
		local avatarBust = Enum.ThumbnailType.AvatarBust
		local v32 = bit32.bxor(v18, 0)
		tbl26[1] = avatarBust
		tbl26[2] = "Size150x150"
		tbl26[3] = "bust"
		local tbl30 = { Enum.ThumbnailType.AvatarBust, "Size352x352", "bust" }
		local tbl31 = {}
		local v33 = Enum
		bit32.bxor(v17, 982752514)
		tbl31[1] = v33.ThumbnailType.AvatarBust
		tbl31[2] = "Size420x420"
		tbl31[3] = "bust"
		local tbl32 = {}
		n9 = (v31 + 1265985783) // v32
		local avatarThumbnail = Enum.ThumbnailType.AvatarThumbnail
		v19 = bit32.band(v32, 2580130962)
		tbl32[1] = avatarThumbnail
		tbl32[2] = "Size150x150"
		tbl32[3] = "full"
		local tbl33 = { Enum.ThumbnailType.AvatarThumbnail, "Size352x352", "full" }
		local tbl34 = {}
		local avatarThumbnail2 = Enum.ThumbnailType.AvatarThumbnail
		v20 = bit32.bxor(v18, 396353498)
		tbl34[1] = avatarThumbnail2
		tbl34[2] = "Size420x420"
		tbl34[3] = "full"
		local tbl35 = { Enum.ThumbnailType.AvatarThumbnail, "Size720x720", "full" }
		tbl20[1] = tbl21
		tbl20[2] = tbl22
		tbl20[3] = tbl23
		tbl20[4] = tbl24
		tbl20[5] = tbl25
		tbl20[6] = tbl26
		tbl20[7] = tbl30
		tbl20[8] = tbl31
		tbl20[9] = tbl32
		tbl20[10] = tbl33
		tbl20[11] = tbl34
		tbl20[12] = tbl35
	end

	local fn35

	fn35 = function(arg)
		local n10 = 1696260207
		local tbl27 = {}
		local v21 = ipairs
		bit32.bxor(1341760137, n10)

		for _, v22 in v21(tbl20) do
			local n11 = 9027133041

			local ok2, result2 = pcall(function()
				return Enum.ThumbnailSize[v22[2]]
			end)

			if ok2 and result2 then
				local v23 = fn34(localPlayer2.UserId, v22[1], result2)
				local v24 = fn34(arg, v22[1], result2)

				if v23 and v24 then
					tbl27[v23] = v24
				end
			end
		end

		return tbl27
	end

	local tbl27
	tbl27 = {}
	local v21

	do
		local n10 = n9 + v19 - bit32.bxor(v20, 0)
		tbl27.serial = 0
		tbl27.active = false
		tbl27.userId = nil
		local v22 = bit32.rshift(v19 // 7, 10)
		tbl27.description = nil
		tbl27.modelTemplate = nil
		tbl27.contentKinds = {}
		local v23 = bit32.rshift(v22, 22)
		tbl27.overlays = setmetatable({}, { __mode = "k" })
		local v24 = bit32.lshift(n10, 13)
		tbl27.boundImages = setmetatable({}, { __mode = "k" })
		local v25 = v23
		tbl27.boundRoots = setmetatable({}, { __mode = "k" })
		tbl27.connections = {}
		local v26 = bit32.bxor(v23, 1198377976)

		local function fn36()
			local n11 = 3605057995
			local n12 = 159359790
			local n13 = 574493719

			for i = #tbl27.connections, 1, -1 do
				local v27 = tbl27.connections[i]
				tbl27.connections[i] = nil

				if v27 and v27.Connected then
					local v28 = pcall
					local v29 = table.pack(bit32.band(i, 4294967295))
					local v30 = table.pack(bit32.band(v29[1], 65535))
					local v31 = bit32.band(18325 * v30[1] + bit32.lshift(bit32.band(18325 * bit32.rshift(v29[1], 16) + 43176 * v30[1], 65535), 16), 4294967295)
					local v32 = table.pack(bit32.band(bit32.bnot(i), 4294967295))
					local v33 = table.pack(bit32.band(v32[1], 65535))
					local n14 = 3610070718 + v31 + bit32.band(18325 * v33[1] + bit32.lshift(bit32.band(18325 * bit32.rshift(v32[1], 16) + 43176 * v33[1], 65535), 16), 4294967295)

					v28(function()
						v27:Disconnect()
					end)
				end
			end

			tbl27.boundImages = setmetatable({}, { __mode = "k" })
			local v27 = tbl27
			local v28 = table.pack(bit32.band(n12, 4294967295))
			local v29 = table.pack(bit32.band(n13, 4294967295))
			local v30 = table.pack(bit32.band(v28[1], 65535))
			local v31 = table.pack(bit32.rshift(v28[1], 16))
			local v32 = table.pack(bit32.band(v29[1], 65535))
			local v33 = setmetatable
			local tbl28 = {}
			bit32.rshift(bit32.band(v30[1] * v32[1] + bit32.lshift(bit32.band(v30[1] * bit32.rshift(v29[1], 16) + v31[1] * v32[1], 65535), 16), 4294967295), 18)
			bit32.bxor(n11, 3510307399)
			tbl28.__mode = "k"
			v27.boundRoots = v33({}, tbl28)
		end

		local function fn37(arg)
			local n11 = 1018957854
			local v27 = tbl27.overlays[arg]
			local n12 = 1310049423
			if not v27 then
				return
			end
			tbl27.overlays[arg] = nil

			if arg and arg.Parent then
				local n13 = 228323354

				pcall(function()
					local n14 = 2170827747
					local n15 = 2769764521
					local v28 = arg
					local v29 = bit32.bxor(2750020611, n15)

					if v28.ImageTransparency == 1 then
						arg.ImageTransparency = v27.imageTransparency
						local n16 = bit32.band(n15, v29) - 1593753599
						bit32.bxor(n14, 2873455877)
					end
				end)
			end

			if v27.viewport then
				local n13 = 231774231

				pcall(function()
					v27.viewport:Destroy()
				end)
			end
		end

		fn22 = function()
			local n11 = 3192840360
			tbl27.active = false
			local n12 = 2367997142
			tbl27.serial = tbl27.serial + 1
			fn36()
			local n13 = 86032528

			for k in pairs(tbl27.overlays) do
				fn37(k)
			end

			local v27 = tbl27
			local v28 = bit32.bor(n13, n12)
			v27.overlays = setmetatable({}, { __mode = "k" })
			tbl27.contentKinds = {}
			tbl27.userId = nil
			local n14 = n12 - 2136692211

			if tbl27.modelTemplate then
				local n15 = 752424042

				pcall(function()
					tbl27.modelTemplate:Destroy()
				end)

				tbl27.modelTemplate = nil
			end

			if tbl27.description then
				local n15 = 393672939

				pcall(function()
					tbl27.description:Destroy()
				end)

				bit32.bxor(n11, 4023207106)
				tbl27.description = nil
				local n16 = n14 // 11 + 210277210
			end
		end

		local function fn38(arg)
			local n11 = 3636662788
			local n12 = 1594949275
			local n13 = 609442797
			local n14 = 3856935917
			if not tbl27.active or not arg then
				return nil
			end

			local ok2, result2 = pcall(function()
				return arg.Image
			end)

			local v27 = bit32.bxor(n11, 4294967295)
			local flag = not ok2 or type(result2) ~= "string"

			if not flag then
				flag = result2 == ""
				local v28 = table.pack(bit32.band(n14, 4294967295))
				local v29 = table.pack(bit32.band(v27, 4294967295))
				local v30 = table.pack(bit32.band(v28[1], 65535))
				local v31 = table.pack(bit32.rshift(v28[1], 16))
				local v32 = table.pack(bit32.band(v29[1], 65535))
				n14 = bit32.bxor(bit32.band(v30[1] * v32[1] + bit32.lshift(bit32.band(v30[1] * bit32.rshift(v29[1], 16) + v31[1] * v32[1], 65535), 16), 4294967295), 3960033714)
			end

			if flag then
				return nil
			end
			local str2 = tbl27.contentKinds[result2]

			if not str2 then
				local v28 = string
				local v29 = table.pack(bit32.band(v27, 4294967295))
				local v30 = table.pack(bit32.band(v29[1], 65535))
				local n15 = bit32.band(v30[1] * 36407 + bit32.lshift(bit32.band(v30[1] * 0 + bit32.rshift(v29[1], 16) * 36407, 65535), 16), 4294967295)
				local v31 = v28.lower(result2)
				local v32 = tostring
				local v33 = localPlayer2
				local v34 = table.pack(bit32.band(n14, 4294967295))
				local v35 = table.pack(bit32.band(n15, 4294967295))
				local v36 = table.pack(bit32.band(v34[1], 65535))
				local v37 = table.pack(bit32.rshift(v34[1], 16))
				local v38 = table.pack(bit32.band(v35[1], 65535))
				local n16 = bit32.band(v36[1] * v38[1] + bit32.lshift(bit32.band(v36[1] * bit32.rshift(v35[1], 16) + v37[1] * v38[1], 65535), 16), 4294967295)
				local v39 = v32(v33.UserId)
				local str3 = tostring(tbl27.userId or "")
				local flag2 = not string.find(result2, v39, 1, true)

				if flag2 then
					flag2 = str3 == ""

					if not flag2 then
						local n17 = n16 - 2214497358
						local find = string.find
						local v40 = bit32.bxor(n15, n17)
						flag2 = not find(result2, str3, 1, true)
						n16 = n17 - 2080469938
						n15 = v40 - 870764553
					end
				end

				if flag2 then
					return nil
				end

				if string.find(v31, "headshot", 1, true) then
					str2 = "headshot"
				else
					local n17 = n16 + 2860115298

					if string.find(v31, "bust", 1, true) then
						str2 = "bust"
					else
						local v40 = string.find(v31, "avatar", 1, true)
						local v41 = table.pack(bit32.band(n15 + n17, 4294967295))
						local v42 = table.pack(bit32.band(n17, 4294967295))
						local v43 = table.pack(bit32.band(v41[1], 65535))
						local v44 = table.pack(bit32.rshift(v41[1], 16))
						local v45 = table.pack(bit32.band(v42[1], 65535))
						local v46 = bit32.band(v43[1] * v45[1] + bit32.lshift(bit32.band(v43[1] * bit32.rshift(v42[1], 16) + v44[1] * v45[1], 65535), 16), 4294967295)

						if v40 or string.find(v31, "thumbnail", 1, true) then
							str2 = "full"
						end

						n15 = v46 + 354057477
					end

					n16 = n17 + 1434851998
				end

				n14 = n16 + 167653252
				v27 = bit32.bxor(n15, 488945430)
			end

			bit32.bor(n14, v27)
			if not str2 then
				return nil
			end

			if str2 == "full" then
				for i = 1, 8 do
					if not arg then
						break
					end
					local v28 = string.lower(arg.Name or "")
					if string.find(v28, "playerlist", 1, true) or string.find(v28, "player_list", 1, true) or string.find(v28, "player list", 1, true) or string.find(v28, "playercard", 1, true) or string.find(v28, "playerprofile", 1, true) then
						return nil
					end
					local descendants = arg:GetDescendants()

					for i2 = 1, MathMin(#descendants, 100) do
						local v29 = descendants[i2]

						if v29:IsA("TextLabel") or v29:IsA("TextButton") then
							local n15 = 8627114635

							local ok3, result3 = pcall(function()
								local n16 = 2413681334
								local lower = string.lower
								local text = v29.Text
								local str3

								if text then
									str3 = text
								else
									bit32.bxor(n16, 1684043046)
									str3 = ""
								end

								return lower(str3)
							end)

							if ok3 and string.find(result3, "in this server", 1, true) then
								return nil
							end
						end
					end

					arg = arg.Parent
					n12 = bit32.bxor(n12, 2960235480)
				end
			end

			return str2
		end

		v21 = bit32.bor(v25, 3015037010)

		local function fn39(arg)
			type(0)
			local n11 = 91177988
			local n12 = 94258852
			local n13 = 525206609
			local n14 = 3501382318
			local v27 = nil
			if not pcall(function()
				v27 = Players2:CreateHumanoidModelFromDescription(arg, Enum.HumanoidRigType.R15)
			end) or not v27 then
				return nil
			end
			local v28 = ipairs
			local v29 = bit32.bor(n14, n12)

			for _, descendant in v28(v27:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant.Anchored = true
					descendant.CanCollide = false
					descendant.CanTouch = false
					descendant.CanQuery = false
				elseif descendant:IsA("Script") or descendant:IsA("LocalScript") then
					descendant:Destroy()
				end
			end

			local humanoid = v27:FindFirstChildOfClass("Humanoid")

			if humanoid then
				local v30 = Enum
				bit32.bxor(n11, 4050365879)
				humanoid.DisplayDistanceType = v30.HumanoidDisplayDistanceType.None
			end

			return v27
		end

		v9 = bit32.bxor(v20, 219610806)

		local function fn40(arg, arg2)
			local n11 = 2331908393
			local n12 = 1241822112
			local n13 = -69559297
			local v27 = nil
			local v28 = nil

			for _, child in ipairs(arg:GetChildren()) do
				if child:IsA("BasePart") then
					local n14 = child.Size / 2
					local n15 = child.Position - n14
					local n16 = child.Position + n14

					if v27 then
						local v29 = MathMin
						local z = v27.Z
						local z2 = n15.Z
						v27 = Vector3New(MathMin(v27.X, n15.X), MathMin(v27.Y, n15.Y), v29(z, z2))
					end

					v27 = v27 or n15

					if v28 then
						local v29 = MathMax
						local z = v28.Z
						local z2 = n16.Z
						v28 = Vector3New(MathMax(v28.X, n16.X), MathMax(v28.Y, n16.Y), v29(z, z2))
					end

					v28 = v28 or n16
				end
			end

			if not v27 or not v28 then
				return nil, nil
			end
			local n14 = v28 - v27
			local v29 = bit32.bxor(n12, 238591094)
			local v30 = MathMax
			local y = n14.Y
			bit32.bxor(n11, 3262461255)
			return (v27 + v28) / 2, v30(y, n14.X * 1.35, 4) / 2 * math.tan(MathRad(arg2) / 2) * 1.08
		end

		local function fn41(parent, arg, arg2)
			local n11 = 1643254055
			local n12 = 727536292
			local n13 = 142785989
			local v27 = Instance
			local n14 = bit32.bor(2040376056, n13)
			local Camera = v27.new("Camera")
			Camera.FieldOfView = arg2 == "full" and 28 or 24
			local n15 = bit32.band(n13, n14)
			Camera.Parent = parent
			parent.CurrentCamera = Camera
			local flag = arg2 == "headshot"
			local flag2

			if flag then
				flag2 = flag
			else
				flag2 = arg2 == "bust"
				bit32.bxor(n11, 699713104)
				n14 = n14 - 993044069 - 3301923227
			end

			local n16 = nil
			local n17 = nil

			if flag2 then
				local head2 = arg:FindFirstChild("Head")
				local upperTorso = arg:FindFirstChild("UpperTorso") or arg:FindFirstChild("Torso")

				if head2 then
					local position = head2.Position
					local v28 = Vector3New
					local n18 = arg2 == "bust" and -0.35 or -0.05
					local n19 = n15 // 86
					n16 = position + v28(0, n18, 0)
					n17 = arg2 == "bust" and 6.2 or 4.3
					n15 = n19 + 141125687
				else
					n16 = nil
					n17 = nil

					if upperTorso then
						local v28 = bit32.bxor(n15, n14)
						n16 = upperTorso.Position + Vector3New(0, 0.7, 0)
						n15 = bit32.bxor(v28, 2040512509)
						n17 = 5
					end
				end
			end

			if not n16 then
				local v28 = fn40
				local v29 = bit32.lshift(n14, 14)
				n16, n17 = v28(arg, Camera.FieldOfView)
				n14 = v29 - 1985970179
			end

			if not n16 then
				n16 = arg:FindFirstChild("HumanoidRootPart")

				if n16 then
					local v28 = bit32.bxor(n14, n15)
					n16 = n16.Position + Vector3New(0, 0.25, 0)
					n14 = bit32.bxor(v28, 142785989)
				end

				n16 = n16 or Vector3Zero
				n17 = 12
			end

			local humanoidRootPart = arg:FindFirstChild("HumanoidRootPart")
			humanoidRootPart = humanoidRootPart and humanoidRootPart.CFrame.LookVector

			if not humanoidRootPart then
				local v28 = Vector3New
				local v29 = table.pack(bit32.band(n15, 4294967295))
				local v30 = table.pack(bit32.band(n14, 4294967295))
				local v31 = table.pack(bit32.band(v29[1], 65535))
				local v32 = table.pack(bit32.rshift(v29[1], 16))
				local v33 = table.pack(bit32.band(v30[1], 65535))
				local v34 = bit32.band(v31[1] * v33[1] + bit32.lshift(bit32.band(v31[1] * bit32.rshift(v30[1], 16) + v32[1] * v33[1], 65535), 16), 4294967295)
				humanoidRootPart = v28(0, 0, -1)
				n15 = v34 - 3869493484
			end

			bit32.bxor(n12, 2346764181)
			Camera.CFrame = CFrameNew(n16 + humanoidRootPart * n17, n16)
		end

		local function fn42(parent)
			local n11 = 4127908960
			local n12 = 4102462350
			local n13 = 4138713551 + n12
			if not tbl27.active or not tbl27.description or not parent.Parent then
				return
			end
			local v27 = fn38(parent)
			if not v27 then
				fn37(parent)
				return
			end
			local overlays = tbl27.overlays
			local v28 = bit32.bxor(n12, 813679019)
			local v29 = overlays[parent]
			local flag

			if v29 then
				flag = v29.kind == v27
				v28 = bit32.bxor(v28 + 4210751742, 2064451846)
			else
				flag = v29
			end

			if flag and v29.viewport and v29.viewport.Parent then
				return
			end
			fn37(parent)
			local clone = nil
			local n14 = n13 // 252

			if tbl27.modelTemplate then
				local n15 = 475211337

				pcall(function()
					clone = tbl27.modelTemplate:Clone()
				end)
			end

			if not clone then
				return
			end
			local viewportFrame = Instance.new("ViewportFrame")
			viewportFrame.Name = "CiderAvatarVisual"
			local n15 = v28 // 209
			viewportFrame.BackgroundTransparency = 1
			viewportFrame.BorderSizePixel = 0
			local n16 = n14 - n15
			viewportFrame.Size = UDim2.new(1, 0, 1, 0)
			viewportFrame.Position = UDim2.new(0, 0, 0, 0)
			local v30 = Vector2New
			local v31 = bit32.bor(n15, n16)
			bit32.bxor(n11, 3526990040)
			viewportFrame.AnchorPoint = v30(0, 0)
			viewportFrame.ZIndex = parent.ZIndex + 1
			viewportFrame.Active = false
			viewportFrame.Ambient = Color3RGB(190, 190, 190)
			local v32 = Color3RGB
			local v33 = bit32.rshift(n16, 15)
			viewportFrame.LightColor = v32(255, 255, 255)
			local n17 = v33 - 525704
			viewportFrame.LightDirection = Vector3New(-1, -1, -1)
			local worldModel = Instance.new("WorldModel")
			worldModel.Parent = viewportFrame
			local v34 = bit32.rshift(v31, 29)
			clone.Parent = worldModel
			fn41(viewportFrame, clone, v27)
			local uiCorner = parent:FindFirstChildOfClass("UICorner")

			if uiCorner then
				uiCorner:Clone().Parent = viewportFrame
			end

			tbl27.overlays[parent] = { viewport = viewportFrame, imageTransparency = parent.ImageTransparency, kind = v27 }
			viewportFrame.Parent = parent
			parent.ImageTransparency = 1
			bit32.bor(n17, 3803892559)
		end

		local function fn43(arg)
			type(304591307)
			local n11 = 104405642
			local n12 = 890131059
			local n13 = 463310218
			local n14 = 570851864
			local flag = not arg
			local v27

			if flag then
				v27 = flag
			else
				local v28 = tbl27.boundImages[arg]
				n12 = bit32.bxor(n12, 2679859894) + 2321095086
				v27 = v28
			end

			if v27 then
				return
			end

			if not arg:IsA("ImageLabel") and not arg:IsA("ImageButton") then
				return
			end
			local v28 = tbl27
			bit32.bxor(n13, 2831232375)
			local v29 = table.pack(bit32.band(n11, 4294967295))
			local v30 = table.pack(bit32.band(v29[1], 65535))
			local n15 = bit32.band(47808 * v30[1] + bit32.lshift(bit32.band(47808 * bit32.rshift(v29[1], 16) + 26885 * v30[1], 65535), 16), 4294967295) + 2147890496
			local v31 = table.pack(bit32.band(bit32.bor(n11, 25698111), 4294967295))
			local v32 = table.pack(bit32.band(v31[1], 65535))
			local v33 = bit32.band(17729 * v32[1] + bit32.lshift(bit32.band(17729 * bit32.rshift(v31[1], 16) + 38650 * v32[1], 65535), 16), 4294967295)
			local v34 = table.pack(bit32.band(bit32.band(n11, 25698111), 4294967295))
			local v35 = table.pack(bit32.band(v34[1], 65535))
			local n16 = n15 + v33 + bit32.band(17727 * v35[1] + bit32.lshift(bit32.band(17727 * bit32.rshift(v34[1], 16) + 38650 * v35[1], 65535), 16), 4294967295)
			local v36 = bit32.band(n14, 3328484844)
			v28.boundImages[arg] = true

			tbl27.connections[#tbl27.connections + 1] = arg:GetPropertyChangedSignal("Image"):Connect(function()
				local flag2 = bit32.bxor(bit32.bxor(n16, 0), 253565167) == 265927255
				local n17 = 584429405
				if not tbl27.active then
					return
				end

				task.defer(function()
					if arg.Parent then
						fn42(arg)
					end
				end)
			end)

			local v37 = fn42
			bit32.bor(v36, n12)
			v37(arg)
		end

		local function fn44(arg)
			local n11 = 496551046
			type(496551046)
			local n12 = 953447366
			local n13 = 1608781756
			local n14 = 535864284
			local n15 = 3661443815
			local flag = not arg

			if not flag then
				n12 = n15
				flag = tbl27.boundRoots[arg]
			end

			if flag then
				return
			end
			tbl27.boundRoots[arg] = true
			local descendantAdded = arg.DescendantAdded
			local v27 = table.pack(bit32.band(n11, 4294967295))
			local v28 = table.pack(bit32.band(v27[1], 65535))
			local n16 = bit32.band(11460 * v28[1] + bit32.lshift(bit32.band(11460 * bit32.rshift(v27[1], 16) + 24657 * v28[1], 65535), 16), 4294967295) + 3811584968
			local v29 = table.pack(bit32.band(bit32.bor(n11, 115308946), 4294967295))
			local v30 = table.pack(bit32.band(v29[1], 65535))
			local v31 = bit32.band(54077 * v30[1] + bit32.lshift(bit32.band(54077 * bit32.rshift(v29[1], 16) + 40878 * v30[1], 65535), 16), 4294967295)
			local v32 = table.pack(bit32.band(bit32.band(n11, 115308946), 4294967295))
			local v33 = table.pack(bit32.band(v32[1], 65535))
			local v34 = bit32.bxor(n16 + v31 + bit32.band(54075 * v33[1] + bit32.lshift(bit32.band(54075 * bit32.rshift(v32[1], 16) + 40878 * v33[1], 65535), 16), 4294967295), 88316785)
			bit32.bxor(n13, 1376056216)

			local connection4 = descendantAdded:Connect(function(arg2)
				local n17 = 394603666
				local n18 = 574472384
				local n19 = 3530324297
				if not tbl27.active then
					return
				end
				local v35 = fn43
				bit32.bxor(n17, 3005861496)
				local v36 = table.pack(bit32.band(n18, 4294967295))
				local v37 = table.pack(bit32.band(n19, 4294967295))
				local v38 = table.pack(bit32.band(v36[1], 65535))
				local v39 = table.pack(bit32.rshift(v36[1], 16))
				local v40 = table.pack(bit32.band(v37[1], 65535))
				bit32.band(v38[1] * v40[1] + bit32.lshift(bit32.band(v38[1] * bit32.rshift(v37[1], 16) + v39[1] * v40[1], 65535), 16), 4294967295)
				v35(arg2)
			end)

			local v35 = tbl27
			bit32.bxor(n12, 2104364122)
			v35.connections[#tbl27.connections + 1] = connection4
		end

		local function fn45()
			local n11 = 2344139134
			local n12 = 2693235605
			local n13 = 3299124116
			if not tbl27.active then
				return
			end
			local tbl28 = {}
			local v27 = table.pack(localPlayer2:FindFirstChildOfClass("PlayerGui"))
			tbl28[1] = CoreGui

			do
				local values = table.pack(table.unpack(v27, 1, v27.n))
				table.move(values, 1, values.n, 2, tbl28)
			end

			local v28 = ipairs
			bit32.bxor(n12, 2763634658)

			for _, v29 in v28(tbl28) do
				if v29 then
					local v30 = fn44
					n11 = bit32.bxor(n11, 1462926783)
					v30(v29)

					for _, descendant in ipairs(v29:GetDescendants()) do
						fn43(descendant)
					end
				end
			end
		end

		fn27 = function(arg, arg2)
			local n11 = 44055859
			local n12 = 1518174803
			local n13 = 930911337
			local n14 = 631884409
			fn22()
			if not arg then
				return
			end
			local flag = not fn4("Headless")
			local flag2

			if flag then
				n12 = n12 // n13 - 2776792494
				flag2 = not fn4("Korblox")
			else
				flag2 = flag
			end

			if flag2 then
				return
			end
			local clone = nil

			pcall(function()
				clone = arg:Clone()
			end)

			if not clone then
				return
			end
			fn5(clone)
			local v27 = fn39
			local v28 = bit32.rshift(n13, 20)
			local v29 = v27(clone)
			if not v29 then
				clone:Destroy()
				return
			end
			tbl27.description = clone
			tbl27.modelTemplate = v29
			tbl27.userId = tonumber(arg2) or localPlayer2.UserId
			local v30 = bit32.bxor(n12, 3812432177)
			bit32.bxor(n11, 1461688)
			tbl27.active = true
			local v31 = bit32.band(v30, v28)
			tbl27.serial = tbl27.serial + 1
			local serial = tbl27.serial
			fn45()
			local v32 = task
			bit32.bxor(v28, 4294967295)
			local v33 = v31

			v32.spawn(function()
				local n15 = 2581428822
				local tbl28 = { localPlayer2.UserId }
				local n16 = bit32.bxor(v33, 1647459017) - 4252589348
				local flag3 = tbl27.userId ~= localPlayer2.UserId
				local v34 = bit32.band(4252589348, n16)

				if flag3 then
					bit32.bxor(n15, 1944660075)
					tbl28[#tbl28 + 1] = tbl27.userId
				end

				local contentKinds = {}

				for _, v35 in ipairs(tbl28) do
					for _, v36 in ipairs(tbl20) do
						local flag4 = not tbl27.active
						local n17 = 152119191
						if flag4 or serial ~= tbl27.serial then
							return
						end

						local ok2, result2 = pcall(function()
							return Enum.ThumbnailSize[v36[2]]
						end)

						if ok2 and result2 then
							local v37 = fn34(v35, v36[1], result2)

							if v37 then
								contentKinds[v37] = v36[3]
							end
						end
					end
				end

				local flag4 = not tbl27.active

				if not flag4 then
					flag4 = serial ~= tbl27.serial
					local n17 = bit32.rshift(n16, 19) - 2605133840
				end

				if flag4 then
					return
				end
				tbl27.contentKinds = contentKinds
				fn45()
			end)
		end

		bit32.bxor(v15, v)
		local v27 = bit32.bxor(v9, 0)
		v10 = bit32.band(v26 * 3, v27)
	end

	do
		local function fn36(arg)
			local n10 = 1193807291
			local n11 = 1259048683
			local n12 = 813049392
			local n13 = 418275261
			local v22 = tbl19.identityCache[arg]
			local flag

			if v22 then
				local timestamp = v22.timestamp
				flag = os.clock() - timestamp <= 60
				n11 = n12 - 3848968005
			else
				flag = v22
			end

			if flag then
				return v22.identity
			end
			local playerByUserId = nil
			local v23 = table.pack(bit32.band(n13, 4294967295))
			local v24 = table.pack(bit32.band(v23[1], 65535))
			local n14 = bit32.band(53921 * v24[1] + bit32.lshift(bit32.band(53921 * bit32.rshift(v23[1], 16) + 16351 * v24[1], 65535), 16), 4294967295) + 1070723765
			local v25 = table.pack(bit32.band(bit32.bor(n13, 314145685), 4294967295))
			local v26 = table.pack(bit32.band(v25[1], 65535))
			local v27 = bit32.band(23230 * v26[1] + bit32.lshift(bit32.band(23230 * bit32.rshift(v25[1], 16) + 32832 * v26[1], 65535), 16), 4294967295)
			local v28 = table.pack(bit32.band(bit32.bxor(n13, 314145685), 4294967295))
			local v29 = table.pack(bit32.band(v28[1], 65535))
			local n15 = n14 + v27 + bit32.band(53922 * v29[1] + bit32.lshift(bit32.band(53922 * bit32.rshift(v28[1], 16) + 16351 * v29[1], 65535), 16), 4294967295)
			local n16 = n12 * 4

			pcall(function()
				playerByUserId = Players2:GetPlayerByUserId(arg)
			end)

			local name = playerByUserId and playerByUserId.Name or nil
			local displayName = playerByUserId and playerByUserId.DisplayName or nil

			if not name or not displayName then
				local function fn37()
					return game:GetService("UserService")
				end

				local n17 = n16 - n11
				local ok2, result2 = pcall(fn37)

				if ok2 and result2 then
					local n18 = n11 // n17

					local ok3, result3 = pcall(function()
						return result2:GetUserInfosByUserIdsAsync({ arg })
					end)

					ok3 = ok3 and type(result3) == "table" and result3[1] or nil

					if ok3 then
						name = name or ok3.Username or ok3.Name

						if not displayName then
							displayName = ok3.DisplayName
							n17 = bit32.bxor(bit32.band(n17, n18), 1993148885)
						end
					end

					n11 = bit32.bxor(n18, 1259048683)
				end

				n16 = n17 + 1259048683
			end

			local v30

			if not name then
				local n17 = 907631731

				local ok2, result2 = pcall(function()
					return Players2:GetNameFromUserIdAsync(arg)
				end)

				if not ok2 then
					result2 = name
				end

				v30 = result2
			else
				v30 = name
			end

			local str2 = tostring(v30 or arg)
			local tbl28 = { userId = arg, username = str2, displayName = tostring(displayName or str2), thumbnailMap = {} }
			local v31 = bit32.lshift(n16, 29)
			tbl28.replacements = fn33(tbl28)
			bit32.bxor(n11, 1681230599)
			local identityCache = tbl19.identityCache
			local tbl29 = { identity = tbl28 }
			bit32.bxor(n10, 3459883794)
			tbl29.timestamp = os.clock()
			identityCache[arg] = tbl29

			task.spawn(function()
				local n17 = 3937270449
				local v32 = fn35(arg)
				local v33 = tbl19.identityCache[arg]

				if v33 and v33.identity == tbl28 then
					tbl28.thumbnailMap = v32
				end
			end)

			return tbl28
		end

		local function fn37(arg, arg2, original, spoofed)
			local n10 = 2450080192
			local n11 = 3584400228
			local tbl28 = tbl19.originals[arg]
			local n12 = 423848125

			if not tbl28 then
				tbl28 = {}
				tbl19.originals[arg] = tbl28
			end

			local v22 = tbl28[arg2]

			if not v22 then
				local tbl29 = {}
				bit32.bxor(n10, 4231113109)
				tbl29.original = original
				local v23 = bit32.bor(n11, n12)
				tbl29.spoofed = spoofed
				tbl28[arg2] = tbl29
			else
				v22.spoofed = spoofed
			end
		end

		local function fn38()
			local n10 = 3599373599
			local n11 = 1757155047

			for i = #tbl19.connections, 1, -1 do
				local v22 = tbl19.connections[i]
				tbl19.connections[i] = nil

				if v22 and v22.Connected then
					local n12 = 13306823858

					pcall(function()
						v22:Disconnect()
					end)
				end
			end

			tbl19.boundObjects = setmetatable({}, { __mode = "k" })
			local v22 = tbl19
			local boundRoots = setmetatable({}, { __mode = "k" })
			bit32.rshift(n11, 17)
			v22.boundRoots = boundRoots
		end

		fn23 = function()
			local n10 = 2133423157
			tbl19.active = false
			local n11 = 3730622627
			local n12 = 3730622627
			tbl19.serial = tbl19.serial + 1
			fn38()
			local n13 = 3282742765

			for k, original in pairs(tbl19.originals) do
				if k then
					for k2, v22 in pairs(original) do
						local n14 = 404560734

						pcall(function()
							local n15 = 2698663984
							local n16 = 4256705868

							if k[k2] == v22.spoofed then
								local v23 = k
								local v24 = k2
								local v25 = v22
								local v26 = bit32.rshift(n16, 4)
								v23[v24] = v25.original
								local n17 = v26 + 3990661752
								bit32.bxor(n15, 4052099406)
							end
						end)
					end
				end
			end

			tbl19.originals = setmetatable({}, { __mode = "k" })
			bit32.bxor(n11, 482007871)
			bit32.bxor(n10, 3890683792)
			tbl19.identity = nil
			tbl13.guiIdentity = nil
		end

		local function fn39(arg, arg2)
			local n10 = 2634841154
			local n11 = 2928075846
			local n12 = 1524361929
			local n13 = 4162026709
			if type(arg) ~= "string" or arg == "" then
				return arg
			end
			local tbl28 = {}
			local v22 = ipairs
			local v23 = bit32.bor(n12, n13)
			bit32.band(n13, v23)

			for k, replacement in v22(arg2.replacements) do
				local str2 = tostring(k)
				n11 = bit32.bxor(n11, 2398618663)
				local str3 = "\1CIDER_ID_" .. str2 .. "\2"
				local v24 = fn32
				n10 = bit32.bxor(n10, 22525550)
				local v25, v26 = v24(arg, replacement.from, str3)

				if v26 then
					tbl28[#tbl28 + 1] = { token = str3, value = replacement.to }
					arg = v25
				end
			end

			for _, v24 in ipairs(tbl28) do
				arg = fn31(arg, v24.token, v24.value)
			end

			return arg
		end

		local function fn40(arg, arg2)
			local n10 = 1885670399
			local n11 = 3361615683
			local kind = type(arg)
			local v22 = table.pack(bit32.band(n11, 4294967295))
			local v23 = table.pack(bit32.band(v22[1], 65535))
			local n12 = bit32.band(29356 * v23[1] + bit32.lshift(bit32.band(29356 * bit32.rshift(v22[1], 16) + 7910 * v23[1], 65535), 16), 4294967295)
			if kind ~= "string" or arg == "" then
				return arg
			end
			local v24 = arg2.thumbnailMap[arg]
			if v24 then
				return v24
			end
			local v25 = string.lower(arg)
			local str2 = tostring(localPlayer2.UserId)
			local find = string.find
			bit32.bxor(n10, 1365598229)
			local v26 = bit32.bor(n11 // 3, 488007409)
			local v27 = v26
			if not find(arg, str2, 1, true) then
				return arg
			end
			local v28 = string.find(v25, "rbxthumb", 1, true) or string.find(v25, "thumbnail", 1, true)

			if not v28 then
				v28 = string.find(v25, "headshot", 1, true)
				n12 = bit32.bxor(n12 // 154, 3790646317)
			end

			if not v28 then
				v27 = v27
				v28 = string.find(v25, "avatar", 1, true)
			end

			if not v28 then
				local find2 = string.find
				local v29 = bit32.band(n12, v27)
				v28 = find2(v25, "userid", 1, true)
				n12 = v29 - 1610510332
			end

			local v29

			if v28 then
				v29 = v28
			else
				v29 = string.find(v25, "userids", 1, true)
				local n13 = bit32.bor(v27, n12) - 2684456964
			end

			if not v29 then
				return arg
			end
			return fn31(arg, str2, tostring(arg2.userId))
		end

		local function fn41(arg, arg2)
			local n10 = 722222999
			local n11 = 3700303136
			local n12 = 2257343668
			local n13 = 1506965946
			if not arg then
				return
			end

			if arg:IsA("TextLabel") or arg:IsA("TextButton") or arg:IsA("TextBox") then
				local ok2, result2 = pcall(function()
					return arg.Text
				end)

				if ok2 then
					if fn29(result2) then
						fn30()
						n12 = n13 + 750377722
					end

					local v22 = fn39(result2, arg2)

					if v22 ~= result2 then
						local v23 = pcall
						local v24 = bit32.bor(n13, n12)
						local n14 = 538472963

						if v23(function()
							arg.Text = v22
						end) then
							fn37(arg, "Text", result2, v22)
						end
					end
				end
			elseif arg:IsA("ImageLabel") or arg:IsA("ImageButton") then
				local ok2, result2 = pcall(function()
					return arg.Image
				end)

				if ok2 then
					local v22 = fn40(result2, arg2)
					local v23 = bit32.rshift(n12, 16)

					if v22 ~= result2 then
						local v24 = pcall
						local n14 = 289156284

						local function fn42()
							arg.Image = v22
						end

						bit32.bxor(n11, 4248827769)
						local n15 = n13 - v23

						if v24(fn42) then
							local v25 = fn37
							bit32.bxor(n10, 2985438409)
							v25(arg, "Image", result2, v22)
						end

						bit32.bxor(n15, 232084)
					end
				end
			end
		end

		local function fn42(arg, arg2)
			type(41382458)
			local n10 = 3008313601
			local n11 = 8602385288
			local n12 = 2520020425
			if not arg or tbl19.boundObjects[arg] then
				return
			end
			local str2 = nil
			local isTextLabel = arg:IsA("TextLabel")

			if not isTextLabel then
				isTextLabel = arg:IsA("TextButton")
				n12 = bit32.bxor(bit32.bxor(n12, 4294967295), 4294967295)
			end

			if isTextLabel or arg:IsA("TextBox") then
				str2 = "Text"
			else
				local isImageLabel = arg:IsA("ImageLabel")

				if not isImageLabel then
					isImageLabel = arg:IsA("ImageButton")
					n10 = n10 // n12 + 3008313600
				end

				if isImageLabel then
					str2 = "Image"
				end
			end

			if not str2 then
				return
			end

			local ok2, result2 = pcall(function()
				local flag = bit32.bxor(n11, 0) ~= 12450696
				local v22

				return arg:GetPropertyChangedSignal(str2):Connect(function()
					local n13 = 588617810
					local v23 = tbl19
					local v24 = table.pack(bit32.band(n13, 4294967295))
					local v25 = table.pack(bit32.band(v24[1], 65535))
					bit32.band(8373 * v25[1] + bit32.lshift(bit32.band(8373 * bit32.rshift(v24[1], 16) + 42329 * v25[1], 65535), 16), 4294967295)
					local flag2 = not v23.active
					if flag2 or tbl19.identity ~= arg2 then
						return
					end
					fn41(arg, arg2)
				end)
			end)

			if ok2 and result2 then
				local boundObjects = tbl19.boundObjects
				local v22 = table.pack(bit32.band(n10, 4294967295))
				local v23 = table.pack(bit32.band(n12, 4294967295))
				local v24 = table.pack(bit32.band(v22[1], 65535))
				local v25 = table.pack(bit32.rshift(v22[1], 16))
				local v26 = table.pack(bit32.band(v23[1], 65535))
				local v27 = bit32.band(v24[1] * v26[1] + bit32.lshift(bit32.band(v24[1] * bit32.rshift(v23[1], 16) + v25[1] * v26[1], 65535), 16), 4294967295)
				boundObjects[arg] = true
				tbl19.connections[#tbl19.connections + 1] = result2
				bit32.bxor(n12 + 865407233, 1610478339)
			end
		end

		local function fn43(arg, arg2)
			local flag = type(0) == "boolean"
			local n10 = 4213872983
			local n11 = 1268635628
			local n12 = 3132096209
			local n13 = 209629036
			local flag2 = not arg

			if not flag2 then
				flag2 = tbl19.boundRoots[arg]
				local n14 = bit32.lshift(n12, 24) - 374341935
			end

			if flag2 then
				return
			end

			local ok2, result2 = pcall(function()
				local flag3 = bit32.bxor(n13, 0) + 299965477 ~= 509594513
				local v22

				return arg.DescendantAdded:Connect(function(descendant)
					local n14 = 2893138082
					local n15 = 2518121319
					local n16 = 2763191105
					local flag4 = not tbl19.active
					local n17 = 847020544
					if flag4 or tbl19.identity ~= arg2 then
						return
					end
					fn42(descendant, arg2)
					local v23 = fn41
					bit32.bxor(n15, 924953956)
					bit32.bxor(n14, 3967554373)
					v23(descendant, arg2)
				end)
			end)

			if ok2 and result2 then
				tbl19.boundRoots[arg] = true
				local connections = tbl19.connections
				local v22 = tbl19
				local v23 = bit32.bxor(n11 + 3440703835, 3326748008)
				connections[#v22.connections + 1] = result2
				bit32.bxor(n10, 4256954293)
				local n14 = v23 - 2472221763
			end
		end

		local function fn44(arg)
			local n10 = 246418356
			local tbl28 = {}
			local v22 = table.pack(localPlayer2:FindFirstChildOfClass("PlayerGui"))
			tbl28[1] = CoreGui

			do
				local values = table.pack(table.unpack(v22, 1, v22.n))
				table.move(values, 1, values.n, 2, tbl28)
			end

			local n11 = 3933994104

			for _, v23 in ipairs(tbl28) do
				if v23 then
					fn43(v23, arg)
					n10 = bit32.bxor(n10, 3405194100)
					fn41(v23, arg)
					local n12 = 8760933326

					local ok2, result2 = pcall(function()
						return v23:GetDescendants()
					end)

					if ok2 then
						for _, v24 in ipairs(result2) do
							fn42(v24, arg)
							fn41(v24, arg)
						end
					end
				end
			end
		end

		fn24 = function(arg, arg2)
			fn23()
			fn22()
			fn28(arg)
			tbl19.active = true
			tbl19.serial = tbl19.serial + 1
			local serial = tbl19.serial
			local n10 = 110200779

			task.spawn(function()
				local n11 = 63174191
				type(0)
				local n12 = 3285035421
				local n13 = 22360781
				local v22 = bit32.bxor(n10, 2668819808)
				local n14 = 912593686
				local v23 = fn36(arg)
				local v24 = tbl19
				local v25 = bit32.bxor(v22, n14)
				if not v24.active or serial ~= tbl19.serial then
					return
				end
				local active = tbl13.active
				local v26 = bit32.bxor(n11, 102085257)
				local flag = not active

				if not flag then
					flag = arg2 ~= n2
					local v27 = bit32.band(n14, v25)
					bit32.bxor(n13, 240817033)
					n14 = v27 - 4026461694
					bit32.bxor(n12, 1243016151)
				end

				if flag then
					return
				end
				tbl19.identity = v23
				local v27 = tbl13
				local v28 = bit32.band(v25, n14)
				v27.guiIdentity = v23
				fn28(arg, v23.displayName)
				local v29 = task
				local v30 = table.pack(bit32.band(v26, 4294967295))
				local v31 = table.pack(bit32.band(v30[1], 65535))
				local n15 = bit32.band(19861 * v31[1] + bit32.lshift(bit32.band(19861 * bit32.rshift(v30[1], 16) + 8225 * v31[1], 65535), 16), 4294967295) + 2436367444
				local v32 = table.pack(bit32.band(bit32.bor(v26, 300422660), 4294967295))
				local v33 = table.pack(bit32.band(v32[1], 65535))
				local v34 = bit32.band(45676 * v33[1] + bit32.lshift(bit32.band(45676 * bit32.rshift(v32[1], 16) + 57310 * v33[1], 65535), 16), 4294967295)
				local v35 = table.pack(bit32.band(bit32.band(v26, 300422660), 4294967295))
				local v36 = table.pack(bit32.band(v35[1], 65535))
				local n16 = n15 + v34 + bit32.band(45674 * v36[1] + bit32.lshift(bit32.band(45674 * bit32.rshift(v35[1], 16) + 57310 * v36[1], 65535), 16), 4294967295)

				v29.spawn(function()
					local n17 = 3026667009
					local n18 = 48487701
					local v37 = getTargetDescriptionCached(arg)
					local flag2 = not tbl19.active

					if flag2 or serial ~= tbl19.serial then
						if v37 then
							local n19 = 13309908073

							pcall(function()
								v37:Destroy()
							end)
						end

						return
					end

					if v37 then
						fn28(arg, v23.displayName, v37)
						fn27(v37, arg)
						local v38 = table.pack(bit32.band(n17, 4294967295))
						local v39 = table.pack(bit32.band(n18, 4294967295))
						local v40 = table.pack(bit32.band(v38[1], 65535))
						local v41 = table.pack(bit32.rshift(v38[1], 16))
						local v42 = table.pack(bit32.band(v39[1], 65535))
						bit32.bxor(bit32.band(v40[1] * v42[1] + bit32.lshift(bit32.band(v40[1] * bit32.rshift(v39[1], 16) + v41[1] * v42[1], 65535), 16), 4294967295), 3165510932)
					end
				end)

				while tbl19.active and serial == tbl19.serial and tbl13.active and arg2 == n2 do
					fn44(v23)
					task.wait(2)
				end
			end)
		end
	end

	v11 = bit32.lshift(v21 + v10, 31)
end

local fn25

fn25 = function(arg)
	local n3 = 3266091562
	local n4 = 1881155101
	local n5 = 3704079720
	if not arg then
		return
	end

	if arg.bodyColors then
		bit32.bxor(n4, 453000757)
		local v12 = pcall
		bit32.bxor(n3, 1138149744)
		local n6 = 520696053

		v12(function()
			arg.bodyColors:Destroy()
		end)

		arg.bodyColors = nil
	end
end

local teardown

teardown = function()
	local n3 = 3077887176
	local colorSnapshot = tbl13.colorSnapshot
	tbl13.active = false
	n2 += 1
	tbl13.currentUserId = nil
	fn25(colorSnapshot)
	tbl13.colorSnapshot = nil
	v4 = nil
	fn11()
	local n4 = 2899880781
	fn23()
	fn20()
	local n5 = 336447515 // n4
	fn22()

	if connection2 then
		connection2:Disconnect()
		connection2 = nil
	end

	if connection3 then
		connection3:Disconnect()
		connection3 = nil
		n3 = n4
	end

	clearAvatarCaches()

	if typeof(animCleanup) == "function" then
		animCleanup()
	end

	if ok and result then
		local copyOutfitColorSnapshot = result.__CopyOutfitColorSnapshot

		if copyOutfitColorSnapshot then
			local v12 = result
			n5 = bit32.lshift(n5, 2)
			copyOutfitColorSnapshot = v12.__CopyOutfitColorSnapshot ~= colorSnapshot
		end

		if copyOutfitColorSnapshot then
			fn25(result.__CopyOutfitColorSnapshot)
		end

		result.__CopyOutfitColorSnapshot = nil
		local n6 = n4 // 7
		local v12 = result[str]
		bit32.bxor(n3, 785668746)

		if v12 == tbl13 then
			result[str] = nil
		end
	end
end

tbl13.teardown = teardown
local fn26

fn26 = function(arg)
	local n3 = 1337881277
	local n4 = 3801678054
	if not arg then
		return nil
	end
	local v12 = n3
	local tbl18 = { bodyColors = nil, partColors = {} }
	local bodyColors = arg:FindFirstChildOfClass("BodyColors")

	if bodyColors then
		tbl18.bodyColors = bodyColors:Clone()
	end

	for _, child in ipairs(arg:GetChildren()) do
		local isBasePart = child:IsA("BasePart")
		v12 = bit32.bxor(v12, 2005605035)

		if isBasePart then
			tbl18.partColors[child.Name] = child.BrickColor
		end
	end

	return tbl18
end

local fn27

fn27 = function(arg)
	fn25(tbl13.colorSnapshot)
	local n3 = 617692672
	local v12 = fn26(arg)
	tbl13.colorSnapshot = v12

	if ok and result then
		local v13 = result
		bit32.bxor(n3, 4189403033)
		v13.__CopyOutfitColorSnapshot = v12
	end
end

local fn28

fn28 = function(arg)
	return tbl13.active and arg == n2
end

local fn29

fn29 = function(arg, texture)
	local n3 = 504470475
	local n4 = 865371985
	local n5 = 3014262487
	local n6 = 1692301980
	local head = arg:FindFirstChild("Head")
	if not head then
		return
	end
	local n7 = bit32.band(n5, 3375996057)

	if fn4("Headless") then
		head.Transparency = 1
		fn6(head)
		return
	end

	local v12 = ipairs
	bit32.bxor(n4, 3327816839)

	for _, child in v12(head:GetChildren()) do
		local isDecal = child:IsA("Decal")
		local flag

		if isDecal then
			flag = child.Name == "face" or child.Face == Enum.NormalId.Front
		else
			flag = isDecal
		end

		if flag then
			child:Destroy()
		end
	end

	if head:IsA("MeshPart") then
		pcall(function()
			head.TextureID = ""
		end)

		n6 = n6 * 2 - 1692301980
	end

	local specialMesh = head:FindFirstChildOfClass("SpecialMesh")

	if specialMesh then
		bit32.bxor(n6, 244724931)
		local n8 = 8919954427

		pcall(function()
			specialMesh.TextureId = ""
		end)
	end

	local surfaceAppearance = head:FindFirstChildOfClass("SurfaceAppearance")

	if surfaceAppearance then
		local n8 = 69903019

		pcall(function()
			surfaceAppearance:Destroy()
		end)
	end

	local flag = not texture

	if not flag then
		local v13 = bit32.bor(n7, 2651291246)
		bit32.bxor(n3, 1326347356)
		flag = texture == ""
		n7 = v13 - 503734894
	end

	if flag then
		texture = "rbxassetid://0"
	end

	local decal = Instance.new("Decal")
	decal.Name = "face"
	decal.Face = Enum.NormalId.Front
	decal.Texture = texture
	decal.Parent = head
end

local v12
v12 = bit32.bor(v10, v11)
local fn30

fn30 = function(arg, arg2, arg3)
	type(334235051)
	local n3 = 3061747240
	local n4 = 1258595353
	local n5 = 3217995392
	local v13 = cacheGetTimed(tbl5, tbl6, arg, 20)
	local n6 = 8898701011
	if v13 then
		return v13
	end
	arg2 = arg2 and arg2:FindFirstChild("Head")
	local v14 = fn16
	bit32.bxor(n3, 2534322288)
	local n7 = n4 // n5
	local v15 = v14(arg2)
	if v15 then
		return fn17(arg, v15)
	end

	if arg3 and arg3.Face and arg3.Face ~= 0 then
		return fn18(arg3.Face, arg)
	end
	local v16 = getCharacterAppearanceInfoCached
	local v17 = bit32.bxor(n6, 112886080)
	local v18 = v16(arg)

	if v18 and v18.assets then
		local v19, v20, v21 = ipairs(v18.assets)
		local v22 = bit32.lshift(n7, 25)

		for _, v23 in v19, v20, v21 do
			if v23.assetType and v23.assetType.id == 18 and v23.id then
				return fn18(v23.id, arg)
			end
		end
	end

	local ok2, result2 = pcall(function()
		return Players2:CreateHumanoidModelFromUserId(arg)
	end)

	if ok2 and result2 then
		local head = result2:FindFirstChild("Head")
		local v19 = fn16(head)
		result2:Destroy()
		local v20 = bit32.bor(n5, 2405121004)
		if v19 then
			return fn17(arg, v19)
		end
		bit32.bxor(v20, 1116524)
	end

	return nil
end

local fn31

fn31 = function(arg)
	local tbl18 = {}

	for _, child in ipairs(arg:GetChildren()) do
		if child:IsA("BasePart") then
			tbl18[child.Name] = child.Size
		end
	end

	return tbl18
end

local fn32

fn32 = function(arg, arg2, arg3, arg4, arg5)
	local n3 = 2623501666
	local n4 = 1937815280
	local n5 = 1035677510
	local handle = arg:FindFirstChild("Handle")
	local flag = not handle

	if not flag then
		flag = not handle:IsA("BasePart")
		n5 = bit32.lshift(n5, 3) + 1340192022
	end

	if flag then
		return
	end
	local v13 = nil

	for _, child in ipairs(handle:GetChildren()) do
		local v14

		if child:IsA("Attachment") then
			local v15 = arg5 and arg5[child.Name] or nil

			if type(v15) == "string" then
				v13 = v15
				break
			else
				n3 = bit32.bxor(n3, 4010432284)

				if v15 ~= false then
					v14 = v13

					if v14 then
						v13 = v14
						break
					else
						v13 = v14
					end
				else
					local v16 = arg4 or fn14(arg2)

					for k, v17 in pairs(v16) do
						if v17 and v17:IsA("BasePart") and v17:FindFirstChild(child.Name) then
							v13 = k
							break
						end
					end

					v14 = v13

					if v14 then
						v13 = v14
						break
					else
						v13 = v14
					end
				end
			end
		else
			v14 = v13

			if v14 then
				v13 = v14
				break
			else
				v13 = v14
			end
		end
	end

	if not handle:GetAttribute("_cpBaseSizeX") then
		handle:SetAttribute("_cpBaseSizeX", handle.Size.X)
		handle:SetAttribute("_cpBaseSizeY", handle.Size.Y)
		local n6 = n4 - n5
		handle:SetAttribute("_cpBaseSizeZ", handle.Size.Z)

		for _, child in ipairs(handle:GetChildren()) do
			if child:IsA("Attachment") then
				child:SetAttribute("_cpBasePosX", child.Position.X)
				child:SetAttribute("_cpBasePosY", child.Position.Y)
				child:SetAttribute("_cpBasePosZ", child.Position.Z)
			end
		end

		local specialMesh = handle:FindFirstChildOfClass("SpecialMesh")

		if specialMesh then
			specialMesh:SetAttribute("_cpBaseScaleX", specialMesh.Scale.X)
			specialMesh:SetAttribute("_cpBaseScaleY", specialMesh.Scale.Y)
			specialMesh:SetAttribute("_cpBaseScaleZ", specialMesh.Scale.Z)
		end

		n4 = n6 + 1035677510
	end

	local n6 = nil

	if v13 then
		local v14 = arg3[v13]
		local v15 = arg2:FindFirstChild(v13)
		local isBasePart = v14 and v15 and v15:IsA("BasePart")
		n6 = nil

		if isBasePart then
			local max = math.max
			local v16 = bit32.bor(n5, n4)
			local v17 = max(v14.X, 0.001)
			local v18 = math
			local v19 = bit32.bxor(n4, v16)
			local v20 = v18.max(v14.Y, 0.001)
			local n7 = math.max(v14.Z, 0.001)
			local n8 = v15.Size.X / v17 + v15.Size.Y / v20
			local z = v15.Size.Z
			local v21 = bit32.bor(v19, 3528323112)
			n6 = (n8 + z / n7) / 3
			n5 = bit32.bxor(v16 - 3673222141, 2574384319)
			n4 = v21 - 1795113534
		end
	end

	local v14 = n5

	local function fn33(arg6, arg7, arg8)
		local n7 = 1306106687
		local v15 = bit32.bxor(arg6, 0)
		local n8 = bit32.bxor(v14, 4086831939)
		local attribute = handle:GetAttribute("_cpBaseSizeX")
		local attribute2 = handle:GetAttribute("_cpBaseSizeY")
		local attribute3 = handle:GetAttribute("_cpBaseSizeZ")

		if attribute and attribute2 and attribute3 then
			local v16 = pcall
			local v17 = bit32.bxor(n8, 1500495692)
			local n9 = 457188856

			v16(function()
				handle.Size = Vector3.new(attribute * arg7, attribute2 * arg7, attribute3 * arg7)
			end)

			n8 = v17 - 3374929732
		end

		local v16 = ipairs
		local v17 = table.pack(handle:GetChildren())
		bit32.bxor(v15, 2334081069)
		local v18 = bit32.bxor(arg8, 0)

		for _, v19 in v16(table.unpack(v17, 1, v17.n)) do
			if v19:IsA("Attachment") then
				local attribute4 = v19:GetAttribute("_cpBasePosX")
				local attribute5 = v19:GetAttribute("_cpBasePosY")
				local attribute6 = v19:GetAttribute("_cpBasePosZ")

				if attribute4 and attribute5 and attribute6 then
					pcall(function()
						v19.Position = Vector3.new(attribute4 * arg7, attribute5 * arg7, attribute6 * arg7)
					end)
				end
			end
		end

		local specialMesh = handle:FindFirstChildOfClass("SpecialMesh")

		if specialMesh then
			local attribute4 = specialMesh:GetAttribute("_cpBaseScaleX")
			local attribute5 = specialMesh:GetAttribute("_cpBaseScaleY")
			local v19 = table.pack(bit32.band(v18, 4294967295))
			local v20 = table.pack(bit32.band(v19[1], 65535))
			local v21 = bit32.band(17154 * v20[1] + bit32.lshift(bit32.band(17154 * bit32.rshift(v19[1], 16) + 30255 * v20[1], 65535), 16), 4294967295)
			local v22 = table.pack(bit32.band(bit32.bnot(v18), 4294967295))
			local v23 = table.pack(bit32.band(v22[1], 65535))
			local n9 = 4059838355 + v21 + bit32.band(17154 * v23[1] + bit32.lshift(bit32.band(17154 * bit32.rshift(v22[1], 16) + 30255 * v23[1], 65535), 16), 4294967295) + 2941418587
			local attribute6 = specialMesh:GetAttribute("_cpBaseScaleZ")
			local v24 = pcall

			local function fn34()
				local n10 = 3809824792
				local n11 = 2484479454
				local n12 = 727056020

				if attribute4 and attribute5 and attribute6 then
					local v25 = specialMesh
					local v26 = Vector3
					local v27 = bit32.bxor(n11, n12)
					v25.Scale = v26.new(attribute4 * arg7, attribute5 * arg7, attribute6 * arg7)
					bit32.bxor(v27, 727056020)
				else
					local v25 = specialMesh
					local v26 = specialMesh
					bit32.bxor(n10, 3309397167)
					v25.Scale = v26.Scale * arg7
				end
			end

			local v25 = table.pack(bit32.band(n8, 4294967295))
			local v26 = table.pack(bit32.band(v25[1], 65535))
			local v27 = bit32.band(v26[1] * 298 + bit32.lshift(bit32.band(v26[1] * 0 + bit32.rshift(v25[1], 16) * 298, 65535), 16), 4294967295)
			v24(fn34)
		end
	end

	local flag2

	if n6 then
		local n7 = n5 + n4
		local n8 = math.abs(n6 - 1)
		local v15 = bit32.bxor(n4, n7)
		flag2 = n8 > 0.01
	else
		flag2 = n6
	end

	if flag2 then
		fn33(152048623, n6, 44151661)
	else
		fn33(214348906, 1, 44151661)
	end
end

local fn33

fn33 = function(arg, arg2, arg3, arg4)
	local n3 = 104518021

	for _, child in ipairs(arg:GetChildren()) do
		if fn13(child.ClassName) then
			fn32(child, arg, arg2, arg3, arg4)
			n3 = bit32.bxor(n3, 37581548)
		end
	end
end

local n3
n3 = v11 - bit32.bxor(v9, 0)
local fn34

fn34 = function(arg, arg2)
	local n4 = 2964903725
	local n5 = 3964568594
	local humanoid = arg2:FindFirstChildOfClass("Humanoid")
	local n6 = 8918047383
	if not humanoid or not arg then
		return false
	end
	local v13 = ipairs
	local v14 = bit32.bxor(n6, 382808262)
	bit32.bxor(n4, 167038639)

	for _, v15 in v13(tbl16) do
		local n7 = 521555284

		pcall(function()
			arg[v15] = 0
		end)
	end

	local v15 = pcall

	local function fn35()
		humanoid:ApplyDescription(arg)
	end

	bit32.bxor(n5, 4294967295)
	return (v15(fn35))
end

local fn35, fn36, n4, v13, tbl18, v14, tbl19, tbl20, tbl21, tbl22
local n5, n6, tbl23, n7, tbl24, v15, v16, v17

do
	local function fn37(arg)
		local n8 = 643352526
		local n9 = 2031646344
		local kind = typeof(arg)
		local n10 = 3552174222 // n9
		if kind == "Color3" then
			return arg
		end

		if kind == "BrickColor" then
			return arg.Color
		end

		if kind == "number" then
			local flag = type("number") == "thread"
			local n11 = 223566353

			local ok2, result2 = pcall(function()
				return BrickColor.new(arg)
			end)

			bit32.bxor(n8, 2310333070)
			if ok2 and result2 then
				return result2.Color
			end
		end

		return nil
	end

	local function fn38(arg, parent, arg2, arg3)
		type(435600856)
		local n8 = 3993404845
		local n9 = 2001722247
		local v18 = table.pack(bit32.band(n9, 4294967295))
		local v19 = table.pack(bit32.band(v18[1], 65535))
		local n10 = bit32.band(51136 * v19[1] + bit32.lshift(bit32.band(51136 * bit32.rshift(v18[1], 16) + 8565 * v19[1], 65535), 16), 4294967295)
		local n11 = 8949485226
		if not parent then
			return
		end
		local bodyColors = parent:FindFirstChildOfClass("BodyColors")

		if not bodyColors then
			bodyColors = Instance.new("BodyColors")
			bodyColors.Parent = parent
		end

		local bodyColors2 = arg3 and arg3.bodyColors

		if not bodyColors2 then
			n9 = bit32.bor(n9, n10) + 4157602752
			bodyColors2 = nil
		end

		arg2 = arg2 and arg2:FindFirstChildOfClass("BodyColors")
		local headColor3 = bodyColors2 and bodyColors2.HeadColor3 or arg and fn37(arg.HeadColor)

		if not headColor3 then
			if arg2 then
				local v20 = table.pack(bit32.band(n9, 4294967295))
				local v21 = table.pack(bit32.band(n10, 4294967295))
				local v22 = table.pack(bit32.band(v20[1], 65535))
				local v23 = table.pack(bit32.rshift(v20[1], 16))
				local v24 = table.pack(bit32.band(v21[1], 65535))
				headColor3 = arg2.HeadColor3
				n9 = bit32.band(v22[1] * v24[1] + bit32.lshift(bit32.band(v22[1] * bit32.rshift(v21[1], 16) + v23[1] * v24[1], 65535), 16), 4294967295) + 4237090759
			else
				headColor3 = arg2
			end
		end

		local leftArmColor3 = bodyColors2 and bodyColors2.LeftArmColor3 or arg and fn37(arg.LeftArmColor) or arg2 and arg2.LeftArmColor3
		local rightArmColor3 = bodyColors2 and bodyColors2.RightArmColor3
		local rightArmColor32

		if rightArmColor3 then
			rightArmColor32 = rightArmColor3
		elseif arg then
			rightArmColor32 = fn37(arg.RightArmColor)
			n10 = n10 // n9 + 1262327360
		else
			rightArmColor32 = arg
		end

		rightArmColor32 = rightArmColor32 or arg2 and arg2.RightArmColor3
		local torsoColor3 = bodyColors2 and bodyColors2.TorsoColor3 or arg and fn37(arg.TorsoColor)

		if not torsoColor3 then
			if arg2 then
				torsoColor3 = arg2.TorsoColor3
				bit32.bxor(n8, 3141765942)
				n10 = bit32.bxor(bit32.bor(n10, 4284595231), 3024103455)
			else
				torsoColor3 = arg2
			end
		end

		local leftLegColor3 = bodyColors2 and bodyColors2.LeftLegColor3 or arg and fn37(arg.LeftLegColor) or arg2 and arg2.LeftLegColor3
		local rightLegColor3 = bodyColors2 and bodyColors2.RightLegColor3

		if not rightLegColor3 then
			if arg then
				local v20 = fn37
				local v21 = bit32.rshift(n9, 20)
				rightLegColor3 = v20(arg.RightLegColor)
				n9 = v21 + 2001720339
			else
				rightLegColor3 = arg
			end
		end

		rightLegColor3 = rightLegColor3 or arg2 and arg2.RightLegColor3
		local partColors = arg3 and arg3.partColors or nil

		local function fn39(arg4, arg5, arg6)
			local v20 = bit32.bxor(arg4, 0)
			local n12 = 3871847355

			if partColors then
				local v21 = fn37
				bit32.bxor(v20, 396015984)
				local v22 = bit32.rshift(n12, 8)
				local v23 = v21(partColors[arg5])
				if v23 then
					return v23
				end
			end

			return arg6
		end

		if headColor3 then
			bodyColors.HeadColor3 = headColor3
			n9 = n9 // n10 + 2001722246
		end

		if leftArmColor3 then
			bodyColors.LeftArmColor3 = leftArmColor3
		end

		if rightArmColor32 then
			local v20 = bit32.bxor(n10, 4294967295)
			bodyColors.RightArmColor3 = rightArmColor32
			n10 = bit32.bxor(v20, 4294967295)
		end

		if torsoColor3 then
			bodyColors.TorsoColor3 = torsoColor3
		end

		if leftLegColor3 then
			bodyColors.LeftLegColor3 = leftLegColor3
		end

		if rightLegColor3 then
			bodyColors.RightLegColor3 = rightLegColor3
		end

		local n12 = n9 // n10
		local n13 = n10 * n12
		local n14 = n12 * n13

		local tbl25 = {
			Head = fn39(455801534, "Head", headColor3, 417593404),
			LeftArm = fn39(239255052, "LeftArm", leftArmColor3, 417593404),
			RightArm = fn39(85525528, "RightArm", rightArmColor32, 417593404),
			["Left Arm"] = fn39(191413798, "Left Arm", leftArmColor3, 417593404),
			["Right Arm"] = fn39(100725384, "Right Arm", rightArmColor32, 417593404),
		}

		local v20 = bit32.band(n13, n14)
		tbl25.LeftUpperArm = fn39(64316617, "LeftUpperArm", leftArmColor3, 417593404)
		tbl25.LeftLowerArm = fn39(69280917, "LeftLowerArm", leftArmColor3, 417593404)
		local v21 = table.pack(bit32.band(n14, 4294967295))
		local v22 = table.pack(bit32.band(v21[1], 65535))
		local v23 = bit32.band(v22[1] * 8958 + bit32.lshift(bit32.band(v22[1] * 0 + bit32.rshift(v21[1], 16) * 8958, 65535), 16), 4294967295)
		tbl25.LeftHand = fn39(272911310, "LeftHand", leftArmColor3, 417593404)
		local v24 = bit32.bxor(v20, 3905498089)
		tbl25.RightUpperArm = fn39(10464876, "RightUpperArm", rightArmColor32, 417593404)
		tbl25.RightLowerArm = fn39(292217627, "RightLowerArm", rightArmColor32, 417593404)
		tbl25.RightHand = fn39(101706172, "RightHand", rightArmColor32, 417593404)
		local v25 = bit32.bor(v23, 2966317822)
		local torso = fn39(31415590, "Torso", torsoColor3, 417593404)
		local v26 = bit32.bxor(v24, 357039332)
		tbl25.Torso = torso
		tbl25.UpperTorso = fn39(115777505, "UpperTorso", torsoColor3, 417593404)
		local v27 = bit32.bor(v26, 2323040927)
		tbl25.LowerTorso = fn39(451108791, "LowerTorso", torsoColor3, 417593404)
		tbl25.LeftLeg = fn39(419705412, "LeftLeg", leftLegColor3, 417593404)
		tbl25.LeftUpperLeg = fn39(455245041, "LeftUpperLeg", leftLegColor3, 417593404)
		tbl25.LeftLowerLeg = fn39(470705408, "LeftLowerLeg", leftLegColor3, 417593404)
		local n15 = v27 + 837414617
		tbl25.LeftFoot = fn39(284211346, "LeftFoot", leftLegColor3, 417593404)
		tbl25["Left Leg"] = fn39(130658249, "Left Leg", leftLegColor3, 417593404)
		local v28 = bit32.bxor(v27, 4214257481)
		tbl25["Right Leg"] = fn39(529898873, "Right Leg", rightLegColor3, 417593404)
		tbl25.RightLeg = fn39(138164489, "RightLeg", rightLegColor3, 417593404)
		local v29 = bit32.bxor(v28, n15)
		tbl25.RightUpperLeg = fn39(83142504, "RightUpperLeg", rightLegColor3, 417593404)
		bit32.bor(n15, 818162526)
		tbl25.RightLowerLeg = fn39(493018955, "RightLowerLeg", rightLegColor3, 417593404)
		bit32.rshift(v29, 13)
		tbl25.RightFoot = fn39(44827915, "RightFoot", rightLegColor3, 417593404)

		for k, v30 in pairs(tbl25) do
			if v30 then
				local v31 = parent:FindFirstChild(k)

				if v31 and v31:IsA("BasePart") then
					local n16 = 436006653

					pcall(function()
						v31.Color = v30
					end)
				end
			end
		end
	end

	local n8 = 0
	fn35 = nil

	local function fn39(arg, arg2)
		local n9 = 178774792
		type(0)
		local n10 = 2251156179
		local n11 = 2683915364
		local n12 = 2592555085
		local tbl25 = {}
		local widthScale

		if arg2 then
			widthScale = arg2.WidthScale
			n12 = bit32.rshift(n12, 9) - 1707475795
		else
			widthScale = arg2
		end

		tbl25.width = widthScale or 1
		tbl25.depth = arg2 and arg2.DepthScale or 1
		local v18

		if arg2 then
			local heightScale = arg2.HeightScale
			n11 = bit32.bor(n11, n12) + 4294574071
			v18 = heightScale
		else
			v18 = arg2
		end

		tbl25.height = v18 or 1
		tbl25.head = arg2 and arg2.HeadScale or 1
		local proportionScale

		if arg2 then
			proportionScale = arg2.ProportionScale
			n11 = n11 - n12 + 2592555085
		else
			proportionScale = arg2
		end

		tbl25.proportion = proportionScale or 0
		local v19 = table.pack(bit32.band(n9, 4294967295))
		local v20 = table.pack(bit32.band(v19[1], 65535))
		local n13 = bit32.band(10902 * v20[1] + bit32.lshift(bit32.band(10902 * bit32.rshift(v19[1], 16) + 13148 * v20[1], 65535), 16), 4294967295) + 2278756608
		local v21 = table.pack(bit32.band(bit32.bor(n9, 487967104), 4294967295))
		local v22 = table.pack(bit32.band(v21[1], 65535))
		local v23 = bit32.band(43732 * v22[1] + bit32.lshift(bit32.band(43732 * bit32.rshift(v21[1], 16) + 39239 * v22[1], 65535), 16), 4294967295)
		local v24 = table.pack(bit32.band(bit32.bxor(n9, 487967104), 4294967295))
		local v25 = table.pack(bit32.band(v24[1], 65535))
		local n14 = n13 + v23 + bit32.band(10903 * v25[1] + bit32.lshift(bit32.band(10903 * bit32.rshift(v24[1], 16) + 13148 * v25[1], 65535), 16), 4294967295)
		tbl25.bodyType = arg2 and arg2.BodyTypeScale or 0
		local v26 = bit32.bxor(n14, 172440047)

		local ok2, result2 = pcall(function()
			return Players2:GetPlayerByUserId(arg)
		end)

		local character = ok2 and result2 and result2.Character
		local v27

		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			n12 = bit32.bxor(n12, 299369132) + 254279020
			v27 = humanoid
		else
			v27 = character
		end

		if not v27 then
			return tbl25
		end

		local ok3, result3 = pcall(function()
			return v27:GetAppliedDescription()
		end)

		local function fn40(arg3, arg4, arg5, arg6, arg7)
			local v28 = bit32.bxor(arg4, 0)
			local v29 = bit32.bxor(arg6, 0)
			local n15 = 4116473920
			local n16 = 2403835430
			local v30 = v27:FindFirstChild(arg3)

			if v30 and v30:IsA("NumberValue") then
				bit32.bxor(v29, arg6)
				local value = v30.Value
				bit32.rshift(n15, 10)
				return value
			end

			if ok3 and result3 then
				bit32.bxor(n16, 125624074)
				local n17 = 8744207403

				local ok4, result4 = pcall(function()
					return result3[arg5]
				end)

				local n18 = 2403835430

				if ok4 then
					ok4 = type(result4) == "number"
					bit32.bxor(v28, arg4)
					n18 = n16 // n15 - 1891131866
				end

				if ok4 then
					return result4
				end
			end

			return arg7
		end

		tbl25.width = fn40("BodyWidthScale", 501413084, "WidthScale", 453523933, tbl25.width)
		tbl25.depth = fn40("BodyDepthScale", 399439417, "DepthScale", 453523933, tbl25.depth)
		local height = tbl25.height
		local v28 = table.pack(bit32.band(n11 - 3520400133, 4294967295))
		local v29 = table.pack(bit32.band(v28[1], 65535))
		local v30 = bit32.band(v29[1] * 63279 + bit32.lshift(bit32.band(v29[1] * 0 + bit32.rshift(v28[1], 16) * 63279, 65535), 16), 4294967295)
		tbl25.height = fn40("BodyHeightScale", 363434415, "HeightScale", 453523933, height)
		local v31 = bit32.lshift(n12 // 5, 26)
		bit32.bxor(n10, 453523933)
		tbl25.head = fn40("HeadScale", 250694264, "HeadScale", 453523933, tbl25.head)
		tbl25.proportion = fn40("BodyProportionScale", 487825281, "ProportionScale", 453523933, tbl25.proportion)
		local v32 = table.pack(bit32.band(v31, 4294967295))
		local v33 = table.pack(bit32.band(v30, 4294967295))
		local v34 = table.pack(bit32.band(v32[1], 65535))
		local v35 = table.pack(bit32.rshift(v32[1], 16))
		local v36 = table.pack(bit32.band(v33[1], 65535))
		bit32.band(v34[1] * v36[1] + bit32.lshift(bit32.band(v34[1] * bit32.rshift(v33[1], 16) + v35[1] * v36[1], 65535), 16), 4294967295)
		tbl25.bodyType = fn40("BodyTypeScale", 193840070, "BodyTypeScale", 453523933, tbl25.bodyType)
		return tbl25
	end

	local v18 = n3

	fn36 = function(arg)
		local v19 = bit32.bxor(v18, 3700573731)
		local n9 = 1303545299
		local charchanger = tbl3 and tbl3.charchanger
		local v20 = v19
		if not charchanger then
			return
		end

		if not arg or not arg.Parent then
			return
		end
		local humanoid = arg:FindFirstChildOfClass("Humanoid")
		local v21 = table.pack(bit32.band(v19, 4294967295))
		local v22 = table.pack(bit32.band(v21[1], 65535))
		local v23 = bit32.band(v22[1] * 42241 + bit32.lshift(bit32.band(v22[1] * 0 + bit32.rshift(v21[1], 16) * 42241, 65535), 16), 4294967295)
		if not humanoid then
			return
		end
		local enabled = charchanger.enabled and charchanger or charchanger.targetScales
		if not enabled then
			return
		end
		local tbl25 = { BodyWidthScale = enabled.width, BodyDepthScale = enabled.depth, BodyHeightScale = enabled.height }
		bit32.bxor(v23, 2170199979)
		tbl25.HeadScale = enabled.head
		tbl25.BodyProportionScale = enabled.proportion
		tbl25.BodyTypeScale = enabled.bodyType
		local v24 = pairs
		bit32.bxor(v23, v20 // 46)

		for k, v25 in v24(tbl25) do
			if type(v25) == "number" then
				local v26 = humanoid:FindFirstChild(k)

				if v26 and v26:IsA("NumberValue") then
					if math.abs(v26.Value - v25) > 0.001 then
						type("height")
						local n10 = 8943169445

						pcall(function()
							v26.Value = v25
						end)
					end
				end
			end
		end
	end

	local n9 = v12 + n3

	local function fn40(arg)
		type(274437596)
		local n10 = 3241094484
		local n11 = 1898864788
		local n12 = 286076511
		n8 += 1
		local v19 = n8
		local n13 = 13396877476
		local charchanger = tbl3

		if tbl3 then
			local v20 = tbl3
			bit32.bxor(n10, 2592036799)
			charchanger = v20.charchanger
		end

		local v20

		if charchanger then
			local num = tonumber(charchanger.enforceIntervalSeconds)
			local v21 = bit32.bxor(n12 * 8, 2573491367)
			v20 = num
		else
			v20 = charchanger
		end

		local n14 = v20 or 0.8
		local spawn = task.spawn
		bit32.bxor(n11, 224370996)

		spawn(function()
			local n15 = 529943586

			while true do
				task.wait(n14)
				local character = localPlayer2.Character
				local flag = not character

				if not flag then
					n15 = bit32.bxor(n15, 2350225639)
					flag = not character.Parent
				end

				if flag then
					arg = nil
				else
					arg = character
				end

				if arg then
					fn36(arg)
				end
			end
		end)
	end

	if ok and result then
		local nxhbtc = {
			Set = function(arg)
				local n10 = 3779266643
				local n11 = 3997771365
				local n12 = 1347732496
				if type(arg) ~= "table" then
					return
				end

				for k, v19 in pairs(arg) do
					if tbl3.charchanger[k] ~= nil then
						tbl3.charchanger[k] = v19
					end
				end

				local n13 = n11 // n12

				if arg.enabled ~= nil then
					local bodySize = shared.Cider.Char["Body Size"]
					local enabled = arg.enabled == true
					bit32.bxor(n10, 2875936249)
					bodySize.Enabled = enabled
					local n14 = n13 + 1347732494
				end

				fn36(localPlayer2.Character)
			end,
			Enable = function()
				tbl3.charchanger.enabled = true
				local n10 = 3097084611
				shared.Cider.Char["Body Size"].Enabled = true
				fn36(localPlayer2.Character)
				local n11 = 2734686464
				fn40(localPlayer2.Character)
				local currentUserId = tbl13.currentUserId or v4

				if not currentUserId then
					currentUserId = fn19()
					local n12 = bit32.bor(n10, n11) + 4244635392
				end

				if currentUserId then
					fn35(currentUserId)
				end
			end,
		}

		local v19 = bit32.bxor(v9, 0)
		local v20 = bit32.bor(n9, v19)

		nxhbtc.Disable = function()
			local n10 = 2122481312
			tbl3.charchanger.enabled = false
			local n11 = 0
			local n12 = 3741638998 - n11
			shared.Cider.Char["Body Size"].Enabled = false
			n8 += 1
			local currentUserId = tbl13.currentUserId or v4
			local v21

			if currentUserId then
				v21 = currentUserId
			else
				v21 = fn19()
				local v22 = bit32.bxor(n11, n12)
				bit32.bxor(n10, 162398659)
			end

			if v21 then
				fn35(v21)
			end
		end

		nxhbtc.Reapply = function()
			local n10 = 1994556282
			local n11 = 1321867690
			local n12 = 1321867690
			fn36(localPlayer2.Character)
			local currentUserId = tbl13.currentUserId or v4 or fn19()

			if currentUserId then
				local v21 = fn35
				local v22 = table.pack(bit32.band(n10, 4294967295))
				local v23 = table.pack(bit32.band(n12, 4294967295))
				local v24 = table.pack(bit32.band(v22[1], 65535))
				local v25 = table.pack(bit32.rshift(v22[1], 16))
				local v26 = table.pack(bit32.band(v23[1], 65535))
				local v27 = bit32.band(v24[1] * v26[1] + bit32.lshift(bit32.band(v24[1] * bit32.rshift(v23[1], 16) + v25[1] * v26[1], 65535), 16), 4294967295)
				v21(currentUserId)
				bit32.bxor(n11, 2700225546)
				local n13 = v27 + 2069645942
			end
		end

		result.nxhbtc = nxhbtc
		n9 = bit32.bxor(v20, 18909206)
	end

	local function fn41(arg, parent, arg2)
		local n10 = 3264611143
		local n11 = 3878467752
		local n12 = 2278925351
		local n13 = 3697689020
		local n14 = 108395218
		if not fn28(arg2) then
			return
		end
		local v19 = getCharacterAppearanceModel
		local v20 = bit32.bxor(n14, 0)
		local v21 = bit32.band(n13, v20)
		local v22 = v19(arg)
		if not v22 then
			return
		end
		local v23 = fn28(arg2)
		local v24 = bit32.bxor(n12, 4294967295)
		if not v23 then
			v22:Destroy()
			return
		end
		clearCopyChildren(parent)
		local flag = v22:FindFirstChild("Head") ~= nil
		local v25 = hasAnySourceBodyPart
		bit32.bxor(n10, 3304084293)
		local n15 = v24 - 3175400511
		local v26 = v25(v22)
		local flag2 = not flag or not v26
		local v27 = nil
		local result2

		if flag2 then
			local ok2

			ok2, result2 = pcall(function()
				return Players2:CreateHumanoidModelFromUserId(arg)
			end)

			ok2 = ok2 and result2
			v27 = nil

			if ok2 then
				v27 = result2
			else
				result2 = v22
			end
		else
			result2 = v22
		end

		local v28 = fn28(arg2)
		local v29 = bit32.bxor(v21, n15)

		if not v28 then
			if v27 then
				v27:Destroy()
			end

			v22:Destroy()
			return
		end

		local v30 = fn5(getTargetDescriptionCached(arg))
		tbl3.charchanger.targetScales = fn39(arg, v30)
		local v31 = table.pack(bit32.band(n15, 4294967295))
		local v32 = table.pack(bit32.band(v31[1], 65535))
		local v33 = bit32.band(v32[1] * 2183 + bit32.lshift(bit32.band(v32[1] * 0 + bit32.rshift(v31[1], 16) * 2183, 65535), 16), 4294967295)
		local n16 = v29 + v33
		local v34 = fn34(v30, parent)
		task.wait()
		local n17 = v33 // 52
		local v35 = table.pack(bit32.band(n14, 4294967295))
		local v36 = table.pack(bit32.band(v35[1], 65535))
		local n18 = bit32.band(33423 * v36[1] + bit32.lshift(bit32.band(33423 * bit32.rshift(v35[1], 16) + 1114 * v36[1], 65535), 16), 4294967295) + 2958889377
		local v37 = table.pack(bit32.band(bit32.bor(n14, 314212559), 4294967295))
		local v38 = table.pack(bit32.band(v37[1], 65535))
		local v39 = bit32.band(32114 * v38[1] + bit32.lshift(bit32.band(32114 * bit32.rshift(v37[1], 16) + 64421 * v38[1], 65535), 16), 4294967295)
		local v40 = table.pack(bit32.band(bit32.band(n14, 314212559), 4294967295))
		local v41 = table.pack(bit32.band(v40[1], 65535))
		local v42 = bit32.band(32112 * v41[1] + bit32.lshift(bit32.band(32112 * bit32.rshift(v40[1], 16) + 64421 * v41[1], 65535), 16), 4294967295)
		local v43 = bit32.bxor(n14, 0)
		local v44 = table.pack(bit32.band(n16, 4294967295))
		local v45 = table.pack(bit32.band(v43, 4294967295))
		local v46 = table.pack(bit32.band(v44[1], 65535))
		local v47 = table.pack(bit32.rshift(v44[1], 16))
		local v48 = table.pack(bit32.band(v45[1], 65535))
		local n19 = bit32.band(v46[1] * v48[1] + bit32.lshift(bit32.band(v46[1] * bit32.rshift(v45[1], 16) + v47[1] * v48[1], 65535), 16), 4294967295)
		local n20 = n18 + v39 + v42
		local v49 = nil

		if v34 then
			v49 = fn26(parent)
		end

		local tbl25 = nil

		if v49 and v49.bodyColors then
			local n21 = n19 // 113
			tbl25 = { bodyColors = v49.bodyColors:Clone(), partColors = {} }
			local v50 = pairs
			local v51 = bit32.lshift(n17, 22)
			local partColors = v49.partColors or {}

			for k, partColor in v50(partColors) do
				tbl25.partColors[k] = partColor
			end

			n19 = n21 + 1901159363
			n17 = v51 - 136537041
		end

		if not fn28(arg2) then
			fn25(v49)
			fn25(tbl25)

			if v27 then
				v27:Destroy()
			end

			v22:Destroy()
			return
		end

		local v50

		if v34 then
			local v51 = pcall

			local function fn42()
				return Players2:CreateHumanoidModelFromUserId(arg)
			end

			local v52 = bit32.bor(n19, n17)
			local v53, v54 = v51(fn42)
			v53 = v53 and v54
			v50 = nil

			if v53 then
				v50 = v54
			end

			n19 = v52 + 4269238257
		else
			v50 = nil
		end

		local v51 = v50 or result2
		local v52 = fn30
		local v53 = bit32.bxor(n20, 194056537)
		local v54 = v53
		local v55 = v52(arg, v51, v30)
		local v56 = fn31(v51)
		local v57 = fn14(parent)
		local v58 = bit32.bxor(n19, 4294967295)
		local v59 = fn15(v57)
		local v60, v61, v62 = ipairs(tbl17)
		local v63 = table.pack(bit32.band(n17, 4294967295))
		local v64 = table.pack(bit32.band(v63[1], 65535))
		local v65 = bit32.band(v64[1] * 61154 + bit32.lshift(bit32.band(v64[1] * 0 + bit32.rshift(v63[1], 16) * 61154, 65535), 16), 4294967295)

		for _, v66 in v60, v61, v62 do
			if v34 then
				if v66 == "Head" then
					local v67 = fn29
					local v68 = bit32.bxor(v54, 368907383)
					v67(parent, v55)
					v54 = bit32.bxor(v68, 368907383)
				end
			else
				local v67 = v51:FindFirstChild(v66) or result2:FindFirstChild(v66)
				local v68 = parent:FindFirstChild(v66)

				if v67 and v68 then
					local flag3 = bit32.bxor(v65, 483227921) == 250920170
					v68.Transparency = v67.Transparency
					local specialMesh = v67:FindFirstChildOfClass("SpecialMesh")
					local v69 = table.pack(bit32.band(v53, 4294967295))
					local v70 = table.pack(bit32.band(v69[1], 65535))
					local v71 = bit32.band(51244 * v70[1] + bit32.lshift(bit32.band(51244 * bit32.rshift(v69[1], 16) + 51450 * v70[1], 65535), 16), 4294967295)
					local v72 = table.pack(bit32.band(bit32.bnot(v53), 4294967295))
					local v73 = table.pack(bit32.band(v72[1], 65535))
					local n21 = 4252730778 + v71 + bit32.band(51244 * v73[1] + bit32.lshift(bit32.band(51244 * bit32.rshift(v72[1], 16) + 51450 * v73[1], 65535), 16), 4294967295)
					local specialMesh2 = v68:FindFirstChildOfClass("SpecialMesh")

					if specialMesh then
						if not specialMesh2 then
							specialMesh:Clone().Parent = v68
						else
							specialMesh2.MeshId = specialMesh.MeshId
							specialMesh2.TextureId = specialMesh.TextureId
							specialMesh2.Scale = specialMesh.Scale
							specialMesh2.Offset = specialMesh.Offset
						end
					elseif specialMesh2 then
						specialMesh2:Destroy()
					end

					local function fn42()
						local n22 = 1977805410
						local n23 = 1196470347
						local n24 = 3559416074
						local n25 = 3216341363

						if v67:IsA("MeshPart") and v68:IsA("MeshPart") then
							local v74 = v68
							bit32.bxor(n23, 2078651533)
							local v75 = v67
							local v76 = bit32.band(n25, 216998623)
							v74.MeshId = v75.MeshId
							local v77 = v68
							local v78 = bit32.rshift(n24, 22)
							v77.TextureID = v67.TextureID
							bit32.bxor(n22, 2588248723)
						end
					end

					pcall(fn42)

					for _, child in ipairs(v67:GetChildren()) do
						if child:IsA("Attachment") then
							local v74 = v68:FindFirstChild(child.Name)

							if v74 then
								v74.Position = child.Position
								v74.Orientation = child.Orientation
							else
								child:Clone().Parent = v68
							end
						end
					end

					if v66 == "Head" then
						fn29(parent, v55)
					end
				end
			end
		end

		if not fn28(arg2) then
			fn25(v49)

			if v50 then
				v50:Destroy()
			end

			if v27 then
				v27:Destroy()
				local n21 = bit32.bxor(v65, 2558276645) - 2274628573
			end

			v22:Destroy()
			return
		end

		for _, child in ipairs(result2:GetChildren()) do
			if fn12(child.ClassName) then
				if not (v34 and child.ClassName == "CharacterMesh") then
					local clone = child:Clone()
					clone.Parent = parent

					if fn13(clone.ClassName) then
						fn32(clone, parent, v56, v57, v59)
					end
				end
			end
		end

		local n21 = 0
		local v66 = v54
		local v67 = bit32.bxor(v66, 167554666)

		local function fn42(arg3)
			local n22 = 1143804906
			n21 += 1
			local v68 = n21
			local delay = task.delay
			local n23 = 448535252
			local n24 = arg3 or 0

			local function fn43()
				local n25 = 2965122095
				local n26 = 2480208960
				local n27 = 1931821717
				local n28 = bit32.bxor(n23, 1341906532) // 2
				if not fn28(arg2) then
					return
				end
				bit32.bxor(n25, 4053645402)
				if not parent.Parent then
					return
				end
				local humanoid = parent:FindFirstChildOfClass("Humanoid")

				if humanoid then
					local n29 = 8626521148

					pcall(function()
						humanoid:BuildRigFromAttachments()
					end)

					n27 = bit32.bxor(n27 - 1463405121, 1758345921)
				end

				fn29(parent, v55)
				fn7(parent)
				local v69 = fn8
				bit32.bxor(n26, 4190365355)
				v69(parent, arg)
			end

			bit32.bxor(n22, 340157332)
			delay(n24, fn43)
		end

		local humanoid = parent:FindFirstChildOfClass("Humanoid")

		if humanoid then
			local v68 = pcall
			local n22 = 462493853

			local function fn43()
				humanoid:BuildRigFromAttachments()
			end

			if not v57 then
				n22 += 1127672137
			end

			v68(fn43)
		end

		local flag3 = not fn28(arg2)
		local v68 = bit32.lshift(v58, 30)

		if flag3 then
			fn25(v49)
			bit32.bxor(v65, v68)
			fn25(tbl25)

			if v50 then
				v50:Destroy()
			end

			if v27 then
				v27:Destroy()
			end

			v22:Destroy()
			return
		end

		fn38(v30, parent, v51, v49)
		local v69 = bit32.bxor(v67, 0)
		local v70 = bit32.band(v68, v69)
		fn25(v49)
		fn29(parent, v55)
		fn7(parent)
		fn27(parent)
		fn36(parent)
		local v71 = task
		local v72 = bit32.band(v70, 3618790863)

		v71.defer(function()
			local n22 = 2135139566
			local n23 = 2563950704
			local n24 = 722446625

			for _, v73 in ipairs({ 0.1, 0.28, 0.55 }) do
				task.wait(v73)
				if not fn28(arg2) then
					fn25(tbl25)
					return
				end

				if not parent.Parent then
					fn25(tbl25)
					return
				end

				if tbl25 then
					if tbl25.bodyColors then
						local n25 = 762788353

						local ok2, result3 = pcall(function()
							return tbl25.bodyColors:Clone()
						end)

						if ok2 and result3 then
							pcall(function()
								local n26 = 1320458469
								local bodyColors = parent:FindFirstChildOfClass("BodyColors")

								if bodyColors then
									bodyColors:Destroy()
								end

								local v74 = result3
								bit32.bxor(n26, 4290853015)
								v74.Parent = parent
							end)
						end
					end

					local v74 = pairs
					local partColors = tbl25.partColors

					if not partColors then
						partColors = {}
						n23 = bit32.bxor(n23, 2661329673)
					end

					for k, partColor in v74(partColors) do
						local v75 = parent:FindFirstChild(k)

						if v75 and v75:IsA("BasePart") and partColor then
							bit32.bxor(n24, 41131367)
							local n25 = 298015858

							pcall(function()
								v75.BrickColor = partColor
							end)
						end
					end

					local v75 = fn38
					n22 = bit32.bxor(n22, 3810691698)
					v75(nil, parent, nil, tbl25)
				else
					fn38(v30, parent, nil, nil)
				end

				fn36(parent)
				fn7(parent)
			end

			fn25(tbl25)
		end)

		fn11()
		local v73 = bit32.bxor(v65, v72)
		local childAdded = parent.ChildAdded
		local v74 = bit32.bxor(v67, 300926014)

		connection = childAdded:Connect(function(arg3)
			local n22 = 2850861535
			local n23 = 87686474
			local n24 = 3414435573
			local n25 = 3947703863

			if fn13(arg3.ClassName) then
				local flag4 = bit32.bxor(n25, 467923079) == 272738009
				local defer = task.defer
				local n26 = 114210524

				local function fn43()
					local n27 = 2443408479
					local n28 = 590598832
					local n29 = 2771747753
					local n30 = 2295589844
					if not fn28(arg2) then
						return
					end
					local v75 = parent
					bit32.bxor(n28, 902720039)
					local n31 = n29 + 4162304481
					if not v75.Parent then
						return
					end
					local v76 = fn14(parent)
					bit32.bxor(n27, 2148412163)
					local v77 = fn15
					bit32.bxor(n30, n31)
					local v78 = v77(v76)
					fn32(arg3, parent, v56, v76, v78)
					fn42(0.03)
				end

				local v75 = bit32.lshift(n25, 21)
				defer(fn43)
			else
				local flag4 = arg3.Name == "Head"
				bit32.bxor(n23, 987028987)
				local n26 = n24 - n25

				if flag4 or arg3:IsA("Decal") then
					local name = arg3.Name
					local v75 = bit32.bxor(n26, 4294967295)

					if name == "Head" then
						local v76 = fn10
						bit32.bxor(n22, 4048770153)
						v76(arg3)
					end

					fn42(0.02)
					n26 = v75 - 1066536579
				end
			end
		end)

		fn10(parent:FindFirstChild("Head"))
		local spawn = task.spawn

		local function fn43()
			for _, v75 in ipairs({ 0.05, 0.12, 0.24, 0.4, 0.65, 0.95 }) do
				task.wait(v75)
				if not fn28(arg2) then
					return
				end

				if not parent.Parent then
					return
				end
				fn42(0.02)
			end
		end

		local v75 = bit32.bxor(v74, 0)
		local v76 = table.pack(bit32.band(v73, 4294967295))
		local v77 = table.pack(bit32.band(v75, 4294967295))
		local v78 = table.pack(bit32.band(v76[1], 65535))
		local v79 = table.pack(bit32.rshift(v76[1], 16))
		local v80 = table.pack(bit32.band(v77[1], 65535))
		local v81 = bit32.band(v78[1] * v80[1] + bit32.lshift(bit32.band(v78[1] * bit32.rshift(v77[1], 16) + v79[1] * v80[1], 65535), 16), 4294967295)
		spawn(fn43)
		local flag4 = false
		local flag5 = false
		local fn44 = nil

		fn44 = function()
			local n22 = 981401329
			local n23 = 3339959938
			local n24 = 1514663017
			if flag4 then
				flag5 = true
				return
			end
			flag4 = true
			local v82 = table.pack(bit32.band(n23, 4294967295))
			local v83 = table.pack(bit32.band(v82[1], 65535))
			bit32.band(v83[1] * 36468 + bit32.lshift(bit32.band(v83[1] * 0 + bit32.rshift(v82[1], 16) * 36468, 65535), 16), 4294967295)
			local v84 = task
			bit32.bxor(n22, 2769843231)
			local v85 = n24

			v84.delay(0.03, function()
				local n25 = 1448275040
				local n26 = 316580075
				local v86 = bit32.bxor(v85, 472075332)
				local n27 = 1930717678
				flag4 = false
				if not fn28(arg2) then
					fn11()
					return
				end
				local parent2 = parent.Parent
				bit32.bxor(n25, 1961211358)
				local v87 = bit32.bor(v86, n27)
				if not parent2 then
					fn11()
					return
				end
				local v88 = fn14
				local v89 = bit32.band(n27, 1939172383)
				local v90 = v88(parent)
				local v91 = fn15(v90)
				fn33(parent, v56, v90, v91)
				fn42(0.02)

				if flag5 then
					flag5 = false
					fn44()
					bit32.bxor(n26, 3881037905)
					bit32.bxor(v89 // v87, 1930717198)
				end
			end)
		end

		local function fn45()
			fn44()
		end

		local n22 = v72 // v81
		local humanoid2 = parent:FindFirstChildOfClass("Humanoid")

		if humanoid2 then
			local function fn46(arg3)
				local n23 = 1249823104
				local n24 = 2219150149
				local n25 = 1589665707
				if not arg3 or not arg3:IsA("NumberValue") then
					return
				end
				local n26 = n24 - n25
				if not tbl15[arg3.Name] then
					return
				end
				local connection4 = arg3:GetPropertyChangedSignal("Value"):Connect(fn45)
				local v82 = tbl4
				local n27 = #tbl4
				bit32.bxor(n23, 2922231931)
				bit32.bor(n25, n26)
				v82[n27 + 1] = connection4
			end

			for _, child in ipairs(humanoid2:GetChildren()) do
				n11 = bit32.bxor(n11, v66)
				fn46(child)
			end

			tbl4[#tbl4 + 1] = humanoid2.ChildAdded:Connect(function(child)
				fn46(child)
			end)

			bit32.bxor(n22 - v81, 606947872)
		end

		task.delay(0.2, fn45)

		if v50 then
			v50:Destroy()
		end

		if v27 then
			v27:Destroy()
			local bxor = bit32.bxor
			local v82 = bit32.bxor(v74, 0)
			bit32.bxor(bxor(v81, v82), 122487056)
		end

		v22:Destroy()
	end

	local function fn42(arg)
		fn11()
		if not arg then
			return
		end
		clearCopyChildren(arg)
	end

	n4 = n3 + bit32.bxor(v9, 0)

	local function fn43(arg, arg2)
		local flag = false
		local n10 = 3562826229

		for _, v19 in ipairs({ 0, 0.45, 1.25, 3 }) do
			local flag2 = bit32.bxor(n10, 174619336) == 178699678
			local n11 = 779120653

			task.delay(v19, function()
				local n12 = 958774566
				local n13 = 355898308
				local n14 = 1720530236
				local v20 = flag
				local flag3

				if flag then
					flag3 = v20
				else
					flag3 = not tbl13.active
				end

				if not flag3 then
					flag3 = arg2 ~= n2
					n13 = bit32.bxor(n13, 4294967295) + 711796617
				end

				if flag3 then
					return
				end
				local v21 = result
				local v22 = table.pack(bit32.band(n14, 4294967295))
				local v23 = table.pack(bit32.band(n13, 4294967295))
				local v24 = table.pack(bit32.band(v22[1], 65535))
				local v25 = table.pack(bit32.rshift(v22[1], 16))
				local v26 = table.pack(bit32.band(v23[1], 65535))
				local v27 = bit32.band(v24[1] * v26[1] + bit32.lshift(bit32.band(v24[1] * bit32.rshift(v23[1], 16) + v25[1] * v26[1], 65535), 16), 4294967295)
				bit32.bxor(n12, 2522329429)
				local v28 = result
				local emoteMimic

				if v21 then
					emoteMimic = result.EmoteMimic
				else
					emoteMimic = v28
				end

				if emoteMimic and type(emoteMimic.SetTargetUserId) == "function" then
					local flag4 = bit32.bxor(n13, 307285414) == 356775629
					local n15 = 8635829643

					local ok2, result2 = pcall(function()
						return emoteMimic.SetTargetUserId(arg)
					end)

					if ok2 and result2 then
						flag = true
					end
				end
			end)
		end
	end

	fn35 = function(currentUserId)
		local n10 = 2110627795
		local n11 = 2000122581
		local n12 = 3171573310
		local n13 = 8670641783
		local n14 = 2003040241
		if not tbl13.active then
			return
		end

		if not shared.Cider.Char.Enabled then
			return
		end
		local v19 = localPlayer2
		local v20 = bit32.bxor(n12, 1669624078)
		local character = v19.Character
		if not character then
			return
		end
		n2 += 1
		local v21 = n2
		bit32.bxor(n11, 4181686875)
		v4 = currentUserId
		local v22 = tbl13
		bit32.band(n14, 722404612)
		v22.currentUserId = currentUserId
		fn42(character)
		local v23 = fn24
		bit32.bxor(n10, 2032530553)
		local v24 = table.pack(bit32.band(v20, 4294967295))
		local v25 = table.pack(bit32.band(v24[1], 65535))
		bit32.band(v25[1] * 31727 + bit32.lshift(bit32.band(v25[1] * 0 + bit32.rshift(v24[1], 16) * 31727, 65535), 16), 4294967295)
		v23(currentUserId, v21)
		local v26 = bit32.bxor(n13, 322393829)

		task.spawn(function()
			local n15 = 429193579
			local n16 = bit32.bxor(v26, 0) + 523334988
			local n17 = 62451761
			local n18 = 2202787146
			local v27 = bit32.bxor(v26, 990973646)
			local n19 = 3175642829
			if not tbl13.active then
				return
			end
			local v28 = v27
			local v29 = fn41
			local v30 = bit32.bxor(v27, 1026735612)
			local v31 = table.pack(bit32.band(n15, 4294967295))
			local v32 = table.pack(bit32.band(v31[1], 65535))
			local n20 = bit32.band(52239 * v32[1] + bit32.lshift(bit32.band(52239 * bit32.rshift(v31[1], 16) + 31873 * v32[1], 65535), 16), 4294967295) + 4029449397
			local v33 = table.pack(bit32.band(bit32.bor(n15, 265517899), 4294967295))
			local v34 = table.pack(bit32.band(v33[1], 65535))
			local v35 = bit32.band(2 * v34[1] + bit32.lshift(bit32.band(2 * bit32.rshift(v33[1], 16) + 0 * v34[1], 65535), 16), 4294967295)
			local v36 = table.pack(bit32.band(bit32.bnot(n15), 4294967295))
			local v37 = table.pack(bit32.band(v36[1], 65535))
			local n21 = n20 + v35 + 2088881168 + bit32.band(52240 * v37[1] + bit32.lshift(bit32.band(52240 * bit32.rshift(v36[1], 16) + 31873 * v37[1], 65535), 16), 4294967295)
			v29(currentUserId, character, v21)
			fn43(currentUserId, v21)
			local v38 = fn8
			bit32.bxor(n17, 3043686615)
			v38(character, currentUserId)
			local v39 = task
			bit32.bxor(n18, 1432004514)
			local v40 = bit32.bxor(n21, 405237955)

			v39.delay(1, function()
				local n22 = 2688394091
				local n23 = 583500339
				local n24 = 3281356301
				local active = tbl13.active
				local v41

				if active then
					local parent = character.Parent
					bit32.bxor(n23, 1397524726)
					v41 = parent
				else
					v41 = active
				end

				if v41 then
					fn8(character, currentUserId)
					local v42 = bit32.bxor(n24 // 201, 3278674990)
					bit32.bxor(n22, 671310561)
				end
			end)

			task.delay(3, function()
				local n22 = 1897585323
				local n23 = 2315851727
				local active = tbl13.active
				local n24 = 478984355

				if active and character.Parent then
					local v41 = fn8
					bit32.bxor(n22, 2562626410)
					v41(character, currentUserId)
					bit32.bxor(n24, 2525343596)
				end
			end)
		end)
	end

	if ok and result then
		local n10 = 679778989

		local function setTargetUserId(arg)
			local n11 = 3710896125
			local n12 = 2757314565
			local n13 = 2467604538
			local n14 = 2900862864
			local v19 = resolveUserToId(arg)
			if not v19 then
				return
			end
			v4 = v19
			bit32.bxor(n11, 136054447)
			tbl13.currentUserId = v19
			local v20 = bit32.band(n13, n14)
			bit32.bxor(n12, 978588818)
			fn35(v19)
		end

		local function reapply()
			local n11 = 200669248
			local n12 = 2623631106
			local currentUserId = tbl13.currentUserId or v4 or fn19()

			if currentUserId then
				local v19 = fn35
				local v20 = bit32.band(n12, n11)
				v19(currentUserId)
			end
		end

		local function useDefaultTarget()
			tbl13.currentUserId = nil
			v4 = nil
			local v19 = fn19()

			if v19 then
				fn35(v19)
			end
		end

		local outfitCopy = { SetTarget = setTargetUserId }
		local v19 = table.pack(bit32.band(n9, 4294967295))
		local v20 = table.pack(bit32.band(v19[1], 65535))
		local v21 = bit32.band(v20[1] * 44794 + bit32.lshift(bit32.band(v20[1] * 0 + bit32.rshift(v19[1], 16) * 44794, 65535), 16), 4294967295)
		outfitCopy.SetTargetUserId = setTargetUserId
		outfitCopy.SetTargetUsername = setTargetUserId
		outfitCopy.Reapply = reapply
		outfitCopy.UseDefaultTarget = useDefaultTarget
		outfitCopy.Cleanup = teardown
		result.OutfitCopy = outfitCopy
		result.CopySetUserId = setTargetUserId
		result.CopyReapplyOutfit = reapply
		result.CopyUseDefaultTarget = useDefaultTarget
		result.CopyOutfitCleanup = teardown
		n4 = bit32.bxor(v21, 3384506250)
		n9 = v21 - 3403415457
	end

	local characterAdded = localPlayer2.CharacterAdded
	local v19 = bit32.rshift(n9, 17)

	connection2 = characterAdded:Connect(function(arg)
		local flag = type(0) == "boolean"
		local n10 = 3435188304
		local n11 = 3674627814
		fn9(arg)
		local n12 = 3732584039 - n11
		local n13 = 309584691

		task.delay(1.5, function()
			if arg.Parent then
				fn21(arg)
			end
		end)

		if not tbl13.active then
			return
		end
		local v20 = n2
		local v21 = n11
		fn11()
		local currentUserId = tbl13.currentUserId

		if not currentUserId then
			currentUserId = v4
			n12 = n12 + 1729472885 - 1729472885
			bit32.bxor(v21, 3190623154)
		end

		currentUserId = currentUserId or fn19()
		if not currentUserId then
			return
		end

		if not arg:WaitForChild("Humanoid", 10) then
			return
		end
		task.wait(0.5)
		local flag2 = not tbl13.active or v20 ~= n2

		if not flag2 then
			local v22 = bit32.bor(n11, 3558973070)
			local parent = arg.Parent
			local v23 = bit32.lshift(n12, 4)
			flag2 = not parent
			bit32.bxor(n10, 3951424397)
			bit32.bxor(v23, 875638673)
		end

		if flag2 then
			return
		end
		fn35(currentUserId)
		fn36(arg)
		fn40(arg)
	end)

	if localPlayer2.Character then
		fn9(localPlayer2.Character)
		local v20 = bit32.bxor(n4, 1638556638)

		if localPlayer2.Character:WaitForChild("Humanoid", 10) then
			fn7(localPlayer2.Character)
			fn21(localPlayer2.Character)
			local n10 = v19 * 17258
			local currentUserId = tbl13.currentUserId or fn19()

			if currentUserId then
				fn35(currentUserId)
			end

			local character = localPlayer2.Character
			local v21 = bit32.bxor(v20, 1424428141)
			fn36(character)
			fn40(localPlayer2.Character)
			v20 = bit32.bxor(v21, 1424428141)
			v19 = bit32.bxor(n10, 562999193)
		end

		n4 = v20 - 1638556638
	end

	v13 = localPlayer2
	tbl18 = {}
	local v20 = bit32.bor(v19, 739112033)
	tbl18.climb = "rbxassetid://507765644"
	tbl18.fall = "rbxassetid://507765000"
	v14 = bit32.bxor(v9, 441821383)
	tbl18.jump = "rbxassetid://507765000"
	tbl18.run = "rbxassetid://913376220"
	tbl18.walk = "rbxassetid://913402848"
	tbl18.swim = "rbxassetid://913384386"
	tbl18.idle1 = "rbxassetid://507766388"
	tbl18.idle2 = "rbxassetid://507766666"
	tbl19 = {}
	tbl20 = { folder = "climb", fallback = tbl18.climb }
	local n10 = v20 // 3 + 437825558
	tbl21 = { folder = "fall", fallback = tbl18.fall }
	tbl22 = { folder = "jump" }
	n5 = n4 // 8 * 5440 // n10
	local v21 = table.pack(bit32.band(v14, 4294967295))
	local v22 = table.pack(bit32.band(v21[1], 65535))
	local n11 = bit32.band(51918 * v22[1] + bit32.lshift(bit32.band(51918 * bit32.rshift(v21[1], 16) + 33493 * v22[1], 65535), 16), 4294967295) + 4089204144
	local v23 = bit32.band(n10, 1088727215)
	local v24 = table.pack(bit32.band(bit32.bor(v14, 205763152), 4294967295))
	local v25 = table.pack(bit32.band(v24[1], 65535))
	local v26 = bit32.band(2 * v25[1] + bit32.lshift(bit32.band(2 * bit32.rshift(v24[1], 16) + 0 * v25[1], 65535), 16), 4294967295)
	local v27 = table.pack(bit32.band(bit32.bnot(v14), 4294967295))
	local v28 = table.pack(bit32.band(v27[1], 65535))
	n6 = n11 + v26 + 2195049167 + bit32.band(51919 * v28[1] + bit32.lshift(bit32.band(51919 * bit32.rshift(v27[1], 16) + 33493 * v28[1], 65535), 16), 4294967295)
	tbl22.fallback = tbl18.jump
	local n12 = n5 * 4
	local tbl25 = { folder = "run", fallback = tbl18.run }
	local tbl26 = {}
	local v29 = bit32.bxor(v23, n12)
	tbl26.folder = "walk"
	tbl26.fallback = tbl18.walk
	local tbl27 = { folder = "swim", fallback = tbl18.swim }
	local v30 = bit32.band(n12, v29)
	tbl19[1] = tbl20
	tbl19[2] = tbl21
	tbl19[3] = tbl22
	tbl19[4] = tbl25
	tbl19[5] = tbl26
	tbl19[6] = tbl27
	local v31 = v30

	if result and result.__AnimationMimicState and result.__AnimationMimicState.cleanup then
		pcall(result.__AnimationMimicState.cleanup)
	end

	tbl23 = { connections = {}, originalByCharacter = {} }
	local n13 = v30 // bit32.bxor(n6, 0)
	tbl23.directControllerByChar = {}
	local v32 = bit32.bxor(n6, 0)
	local v33 = bit32.bor(n13, v32)
	tbl23.lastTargetInput = tbl3.target
	tbl23.pinnedTargetUserId = nil
	tbl23.lastSourceUserId = nil
	local n14 = v31 - v33
	tbl23.applyToken = 0
	tbl23.animationSetCache = {}
	tbl23.active = tbl2.Enabled == true and tbl2["Override Animation"] ~= true
	local v34 = bit32.bor(v33, 2315110781)
	n7 = n14 // 4

	tbl23.settings = {
		autoApplyOnRespawn = true,
		useFallbackWhenMissing = true,
		useDirectTrackFallback = true,
		cacheTtlSeconds = 22,
		minLiveCoverage = 1,
		replicateDescriptionToOthers = false,
		invalidateAnimationCacheOnTargetSwitch = false,
	}

	animState = tbl23

	if result then
		result.__AnimationMimicState = animState
	end

	normalizeAnimationId = function(arg)
		local n15 = 3911445166
		local n16 = 2438770558
		local n17 = 2905335666
		if arg == nil then
			return nil
		end
		local match = tostring(arg):match("%d+")
		if not match then
			return nil
		end
		local num = tonumber(match)
		bit32.bxor(n15, 1673662796)
		if (num or 0) <= 0 then
			return nil
		end
		return "rbxassetid://" .. match
	end

	local v35 = bit32.band(v34, n7)

	numericIdFromContentId = function(arg)
		local n15 = 2075702427
		local n16 = 32307451
		if not arg then
			return nil
		end
		local match = tostring(arg):match("%d+")
		bit32.bxor(n15, 2563662097)
		return match and tonumber(match) or nil
	end

	tbl24 = { climb = numericIdFromContentId(tbl18.climb) }
	local v36 = v35
	v15 = bit32.bxor(n6, 333426003)
	tbl24.fall = numericIdFromContentId(tbl18.fall)
	local v37 = numericIdFromContentId
	local jump = tbl18.jump
	bit32.bor(n7, 1173804481)
	v16 = v36
	tbl24.jump = v37(jump)
	tbl24.run = numericIdFromContentId(tbl18.run)
	local v38 = numericIdFromContentId(tbl18.walk)
	local v39 = table.pack(bit32.band(v36, 4294967295))
	local v40 = table.pack(bit32.band(v16, 4294967295))
	local v41 = table.pack(bit32.band(v39[1], 65535))
	local v42 = table.pack(bit32.rshift(v39[1], 16))
	local v43 = table.pack(bit32.band(v40[1], 65535))
	local v44 = bit32.band(v41[1] * v43[1] + bit32.lshift(bit32.band(v41[1] * bit32.rshift(v40[1], 16) + v42[1] * v43[1], 65535), 16), 4294967295)
	tbl24.walk = v38
	tbl24.swim = numericIdFromContentId(tbl18.swim)
	local v45 = numericIdFromContentId(tbl18.idle1)
	local v46 = table.pack(bit32.band(v44, 4294967295))
	local v47 = table.pack(bit32.band(v46[1], 65535))
	v17 = bit32.band(v47[1] * 61704 + bit32.lshift(bit32.band(v47[1] * 0 + bit32.rshift(v46[1], 16) * 61704, 65535), 16), 4294967295)
	tbl24.idle1 = v45
end

FALLBACK_ANIMATION_NUMERIC_IDS = tbl24

getLocalRigType = function()
	local n8 = 3033505287
	local n9 = 4279336605
	local n10 = 3765123169
	local character = v13.Character
	local rigType

	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		n10 = bit32.bxor(n10, n9) - 1057951387
		rigType = humanoid
	else
		rigType = character
	end

	rigType = rigType and rigType.RigType

	if not rigType then
		local humanoidRigType = Enum.HumanoidRigType
		local v18 = table.pack(bit32.band(n9, 4294967295))
		local v19 = table.pack(bit32.band(n10, 4294967295))
		local v20 = table.pack(bit32.band(v18[1], 65535))
		local v21 = table.pack(bit32.rshift(v18[1], 16))
		local v22 = table.pack(bit32.band(v19[1], 65535))
		rigType = humanoidRigType.R15
		local v23 = bit32.band(v20[1] * v22[1] + bit32.lshift(bit32.band(v20[1] * bit32.rshift(v19[1], 16) + v21[1] * v22[1], 65535), 16), 4294967295)
		bit32.bxor(n8, 3460392153)
	end

	return rigType
end

isCharacterR15 = function(arg)
	local n8 = 838635410
	local n9 = 3825813144
	local n10 = 3179032573
	local n11 = 1595516594
	arg = arg and arg:FindFirstChildOfClass("Humanoid")
	local flag = arg ~= nil
	local v18

	if flag then
		local rigType = arg.RigType
		local v19 = bit32.bor(n11, n10)
		bit32.bxor(n8, 2255922243)
		local v20 = Enum
		bit32.bxor(n9, 2114911491)
		local n12 = n10 + v19
		local flag2 = rigType == v20.HumanoidRigType.R15
		local v21 = bit32.bxor(v19, 2690910541)
		local n13 = n12 + 8540161
		v18 = flag2
	else
		v18 = flag
	end

	return v18
end

normalizeAvatarType = function(arg)
	local n8 = 3527714664
	local n9 = 1116759868
	local n10 = 3571187713
	if arg == nil then
		return nil
	end
	local v18 = tostring
	bit32.bxor(n8, 2256947200)
	local v19 = v18(arg)
	bit32.bxor(n9, 2911847736)
	local str2 = v19:upper()
	local pos = str2:find("R15")

	if not pos then
		pos = str2 == "2"
		local n11 = bit32.lshift(n10, 4) - 2028208143
	end

	if pos then
		return "R15"
	end

	if str2:find("R6") or str2 == "1" then
		return "R6"
	end
	return nil
end

getUserAvatarType = function(arg)
	local n8 = 2483697898
	local n9 = 2384947580
	local n10 = 3720647006
	local playerAvatarType = getCharacterAppearanceInfoCached(arg)
	local v18 = normalizeAvatarType

	if playerAvatarType then
		local v19 = bit32.rshift(n10, 30)
		local playerAvatarType2 = playerAvatarType.playerAvatarType

		if playerAvatarType2 then
			playerAvatarType = playerAvatarType2
		else
			bit32.bxor(n9, 1941404822)
			playerAvatarType = playerAvatarType.PlayerAvatarType
		end

		bit32.bxor(n8, 3976538488)
	end

	return v18(playerAvatarType)
end

resolveTargetToUserId = function(arg)
	return resolveUserToId(arg)
end

local v18
local v19 = bit32.bor(v16, 2083326378)

rememberOriginal = function(arg, arg2)
	local n8 = 613996521
	local n9 = 3526682390
	local n10 = 731180500
	local n11 = 884250122
	local flag = not arg
	local flag2

	if flag then
		flag2 = flag
	else
		n11 = bit32.bxor(bit32.bxor(n11, n10), 731180500)
		flag2 = not arg2
	end

	if flag2 then
		return
	end

	if not animState.originalByCharacter[arg] then
		animState.originalByCharacter[arg] = {}
	end

	if animState.originalByCharacter[arg][arg2] == nil then
		local v20 = animState
		bit32.bxor(n9, 2743490207)
		v20.originalByCharacter[arg][arg2] = arg2.AnimationId
		bit32.bxor(n11 * 2, 1574812190)
		bit32.bxor(n8, 1425143097)
	end
end

resetCharacterAnimations = function(arg)
	local n8 = 3945227219
	local n9 = 20043684
	local v20 = animState.originalByCharacter[arg]
	if not v20 then
		return false
	end

	for k, v21 in pairs(v20) do
		if k and k.Parent then
			k.AnimationId = v21
		end
	end

	local v21 = animState
	bit32.bxor(n8, 1681764985)
	bit32.bor(n9, 4156075409)
	v21.originalByCharacter[arg] = nil
	return true
end

extractFolderAnimationData = function(arg, arg2)
	local n8 = 996516627
	local n9 = 2798441185
	local n10 = 3882595594
	local n11 = 3223063204
	local v20 = arg and arg:FindFirstChild(arg2)
	if not v20 then
		return nil
	end
	local tbl25 = { byName = {} }
	local v21 = bit32.rshift(n11, 16)
	tbl25.ordered = {}
	tbl25.first = nil

	for _, child in ipairs(v20:GetChildren()) do
		if child:IsA("Animation") then
			local v22 = normalizeAnimationId
			n9 = bit32.bxor(n9, 522039902)
			local v23 = v22(child.AnimationId)

			if v23 then
				if not tbl25.first then
					tbl25.first = v23
				end

				tbl25.byName[child.Name] = v23
				local ordered = tbl25.ordered
				n8 = bit32.bxor(n8, 1532864654)
				ordered[#tbl25.ordered + 1] = v23
			end
		end
	end

	return tbl25
end

buildAnimationSetFromAnimate = function(arg)
	local n8 = 2401034940
	local n9 = 1883893327
	local n10 = 1325018327
	if not arg then
		return nil
	end

	local tbl25 = {
		climb = extractFolderAnimationData(arg, "climb"),
		fall = extractFolderAnimationData(arg, "fall"),
		jump = extractFolderAnimationData(arg, "jump"),
	}

	local n11 = n10 // n9
	bit32.bxor(n9, 99562587)
	tbl25.run = extractFolderAnimationData(arg, "run")
	local v20 = bit32.rshift(n9, 21)
	tbl25.walk = extractFolderAnimationData(arg, "walk")
	tbl25.swim = extractFolderAnimationData(arg, "swim")
	local v21 = extractFolderAnimationData
	bit32.bxor(n8, 2174086376)
	tbl25.idle = v21(arg, "idle")
	return tbl25
end

resolveIdFromFolderData = function(arg, arg2, arg3)
	local n8 = 994443198
	local n9 = 1637056706
	local first = nil

	if arg then
		first = arg.byName[arg2]
		bit32.bxor(n8, 2695456966)
		first = first or arg.ordered[arg3]

		if not first then
			first = arg.first
			local n10 = bit32.bor(n9, 2819077482) - 2281977128
		end
	end

	return normalizeAnimationId(first)
end

resolveIdFromFolderDataWithFallback = function(arg, arg2, arg3, arg4)
	local n8 = 4089652867
	local n9 = 2504581561
	if animState.settings.useFallbackWhenMissing then
		return resolveIdFromFolderData(arg, arg2, arg3) or normalizeAnimationId(arg4)
	end
	local v20 = resolveIdFromFolderData
	bit32.band(n9, n8)
	return v20(arg, arg2, arg3)
end

makeSingleAnimationData = function(arg, arg2)
	local n8 = 3398611005
	local n9 = 1904413954
	local v20 = normalizeAnimationId(arg2)
	if not v20 then
		return nil
	end
	local tbl25 = {}
	bit32.lshift(n8, 21)
	tbl25.byName = { [arg] = v20 }
	bit32.band(n9, 1726703340)
	tbl25.ordered = { v20 }
	tbl25.first = v20
	return tbl25
end

makeIdleAnimationData = function(arg)
	local n8 = 1956138527
	local n9 = 2170496343
	local n10 = 1979792305
	local n11 = 2400848978
	local v20 = normalizeAnimationId(arg)
	if not v20 then
		return nil
	end
	local tbl25 = {}
	bit32.bxor(n8, 3670501716)
	local byName = { Animation1 = v20 }
	bit32.bxor(n9, 3216603916)
	byName.Animation2 = v20
	tbl25.byName = byName
	tbl25.ordered = { v20, v20 }
	tbl25.first = v20
	return tbl25
end

ANIM_KEYS = { "climb", "fall", "jump", "run", "walk", "swim", "idle" }

hasAnimationFolderData = function(arg)
	local n8 = 2217741947
	local flag = arg ~= nil
	local v20

	if flag then
		local flag2 = arg.first ~= nil
		bit32.bxor(n8, 2550696011)
		v20 = flag2
	else
		v20 = flag
	end

	return v20
end

v18 = bit32.rshift(v19 - 2348904058, 22)

countAnimationSetCoverage = function(arg)
	local n8 = 1570472473
	local n9 = 2097700997
	if not arg then
		return 0
	end
	local n10 = 0

	for _, v20 in ipairs(ANIM_KEYS) do
		local v21 = hasAnimationFolderData
		n8 = bit32.bxor(n8, 1299145547)

		if v21(arg[v20]) then
			n10 += 1
		end
	end

	return n10
end

getCachedAnimationSet = function(arg)
	local n8 = 4122581287
	local v20 = cacheGetEntry(animState.animationSetCache, arg, animState.settings.cacheTtlSeconds)
	if not v20 then
		return nil
	end
	local set = v20.set
	bit32.bxor(n8, 2402651219)
	return set
end

setCachedAnimationSet = function(arg, set)
	local n8 = 1672241059
	local n9 = 1208213180
	local n10 = 1553873503
	if not arg or not set then
		return
	end
	local v20 = cacheSetEntry
	local animationSetCache = animState.animationSetCache
	local tbl25 = {}
	bit32.bxor(n8, 3770494755)
	bit32.band(n10, n9)
	tbl25.set = set
	tbl25.timestamp = os.clock()
	v20(animationSetCache, arg, tbl25, tbl12.animationSet)
end

getAnimationSetFromLivePlayer = function(arg)
	type(39274548)
	local n8 = 2235355751
	local n9 = 844928827
	local v20 = pcall
	local n10 = 434327230
	bit32.bxor(3088745306, n9)

	local v21, v22 = v20(function()
		return Players2:GetPlayerByUserId(arg)
	end)

	local flag = not v21

	if not flag then
		flag = not v22
		bit32.bxor(n8, 4192717177)
	end

	if flag then
		return nil
	end
	local character = v22.Character
	if not character then
		return nil
	end
	local animate = character:FindFirstChild("Animate")
	if not animate then
		return nil
	end
	local v23 = buildAnimationSetFromAnimate(animate)
	return countAnimationSetCoverage(v23) > 0 and v23 or nil
end

getAnimationSetFromDescription = function(arg)
	local n8 = 3581401974
	local n9 = 417417249
	local n10 = 3727178720
	local v20 = getTargetDescriptionCached(arg)
	local n11 = 2389752604
	if not v20 then
		return nil
	end
	local tbl25 = { climb = makeSingleAnimationData("ClimbAnim", v20.ClimbAnimation) }
	local v21 = makeSingleAnimationData
	local v22 = bit32.band(n10, 2810882443)
	tbl25.fall = v21("FallAnim", v20.FallAnimation)
	tbl25.jump = makeSingleAnimationData("JumpAnim", v20.JumpAnimation)
	local v23 = table.pack(bit32.band(v22, 4294967295))
	local v24 = table.pack(bit32.band(n11, 4294967295))
	local v25 = table.pack(bit32.band(v23[1], 65535))
	local v26 = table.pack(bit32.rshift(v23[1], 16))
	local v27 = table.pack(bit32.band(v24[1], 65535))
	local v28 = bit32.band(v25[1] * v27[1] + bit32.lshift(bit32.band(v25[1] * bit32.rshift(v24[1], 16) + v26[1] * v27[1], 65535), 16), 4294967295)
	tbl25.run = makeSingleAnimationData("RunAnim", v20.RunAnimation)
	tbl25.walk = makeSingleAnimationData("WalkAnim", v20.WalkAnimation)
	local v29 = makeSingleAnimationData
	bit32.bxor(n11 // 207, v28)
	bit32.bxor(n9, 1368106049)
	tbl25.swim = v29("Swim", v20.SwimAnimation)
	local v30 = makeIdleAnimationData(v20.IdleAnimation)
	bit32.bxor(n8, 1109190033)
	tbl25.idle = v30
	return tbl25
end

getAnimationSetFromTempRig = function(arg)
	type(0)
	local n8 = 3877121568
	local n9 = 8918937886
	local n10 = 1816234982
	local v20 = getLocalRigType()
	local v21 = bit32.bor(1921938121, n10)

	local ok2, result2 = pcall(function()
		return Players2:CreateHumanoidModelFromUserId(arg, v20)
	end)

	if not ok2 or not result2 then
		return nil
	end
	result2.Name = "AnimationMimicTempRig"
	local animate = result2:FindFirstChild("Animate") or result2:WaitForChild("Animate", 5)
	bit32.bxor(n8, 2388837980)
	bit32.band(n10, v21)
	if not animate then
		result2:Destroy()
		return nil
	end
	local v22 = buildAnimationSetFromAnimate(animate)
	result2:Destroy()
	return v22
end

getAnimationSetFromUserId = function(arg)
	local n8 = 1138189589
	local n9 = 4253361782
	local n10 = 3259731340
	local v20 = getCachedAnimationSet(arg)
	if v20 then
		return v20
	end
	local v21 = getAnimationSetFromLivePlayer(arg)
	local v22 = countAnimationSetCoverage(v21)
	local settings = animState.settings
	bit32.bxor(n9, 1170673934)
	local flag = v22 >= (settings.minLiveCoverage or 1)
	local v23 = table.pack(bit32.band(n10, 4294967295))
	local v24 = table.pack(bit32.band(v23[1], 65535))
	local v25 = bit32.band(v24[1] * 21363 + bit32.lshift(bit32.band(v24[1] * 0 + bit32.rshift(v23[1], 16) * 21363, 65535), 16), 4294967295)
	if flag and v22 > 0 then
		setCachedAnimationSet(arg, v21)
		return v21
	end
	local v26 = getAnimationSetFromDescription(arg)
	local v27 = getAnimationSetFromTempRig(arg)
	local v28 = v25

	local function fn37(arg2, arg3, arg4, arg5)
		local v29 = bit32.bxor(arg4, 0)
		local v30 = bit32.bxor(arg4, 0)
		local v31 = bit32.bxor(v28, 145124432)
		local n11 = 1498532032
		if not arg5 then
			return arg3
		end
		local v32 = countAnimationSetCoverage(arg5.set)
		bit32.bxor(v29, arg2)
		local v33 = bit32.bxor(arg2, 0)
		local v34 = bit32.bxor(n11, v33)
		if v32 <= 0 then
			return arg3
		end

		if not arg3 then
			local tbl25 = { set = arg5.set }
			local v35 = bit32.bxor(v31, 4294967295)
			tbl25.coverage = v32
			tbl25.priority = arg5.priority
			bit32.bxor(v35, 1477474201)
			return tbl25
		end

		if arg3.coverage < v32 then
			return { set = arg5.set, coverage = v32, priority = arg5.priority }
		end
		local coverage = arg3.coverage
		local v35 = bit32.bxor(v34, v31)
		bit32.bxor(v30, 2330812045)
		local v36 = v35
		local flag2 = v32 == coverage

		if flag2 then
			flag2 = arg5.priority > arg3.priority
			v31 = bit32.bxor(v31 // 181, 3478218827)
		end

		if flag2 then
			local tbl25 = { set = arg5.set }
			bit32.band(v36, v31)
			tbl25.coverage = v32
			tbl25.priority = arg5.priority
			return tbl25
		end

		return arg3
	end

	local tbl25 = {}
	local v29 = bit32.bxor(n9, v25)
	tbl25.set = v21
	tbl25.priority = 3
	local v30 = fn37(422537285, nil, 289932349, tbl25)
	local v31 = bit32.rshift(v25, 30)
	local tbl26 = { set = v26, priority = 1 }
	local v32 = fn37(422537285, fn37(422537285, v30, 36266390, { set = v27, priority = 2 }), 220171936, tbl26)
	local flag2 = not v32

	if not flag2 then
		local set = v32.set
		bit32.bxor(n8, 220171936)
		flag2 = not set
	end

	if flag2 then
		return nil
	end
	setCachedAnimationSet(arg, v32.set)
	return v32.set
end

getAnimationSetFromUserIdWithRetry = function(arg, arg2)
	local n8 = 695899656
	local n9 = 680964876
	local n10 = 893879
	local n11 = arg2 or 2
	bit32.bor(n10, n9)
	bit32.bxor(n8, 2439209178)

	for i = 1, n11 do
		local v20 = getAnimationSetFromUserId(arg)
		if v20 then
			return v20
		end

		if i < n11 then
			task.wait(0.12)
		end
	end

	return nil
end

applyAnimationSetToDescriptionFields = function(arg, arg2)
	type(441912023)
	local n8 = 2358789324
	local n9 = 4542204
	local n10 = 2558475296
	local flag = not arg
	local n11 = 253464418
	if flag or not arg2 then
		bit32.bxor(n8, 3499342110)
		return false
	end

	local function fn37(arg3, arg4, arg5, arg6, arg7, arg8)
		bit32.bxor(arg5, 0)
		local v20 = numericIdFromContentId
		local v21 = resolveIdFromFolderDataWithFallback
		bit32.bxor(1325729519, arg5)
		return v20(v21(arg2[arg3], arg6, arg7, arg8))
	end

	local n12 = n10 - 1801929708
	local climb = fn37("climb", 262543674, 204593176, "ClimbAnim", 1, tbl18.climb)

	if not climb then
		climb = FALLBACK_ANIMATION_NUMERIC_IDS.climb
		n9 = bit32.bxor(bit32.bxor(n9, 4294967295), 4294967295)
	end

	arg.ClimbAnimation = climb
	local v20 = bit32.bor(n9, n12)
	arg.FallAnimation = fn37("fall", 262543674, 160205088, "FallAnim", 1, tbl18.fall) or FALLBACK_ANIMATION_NUMERIC_IDS.fall
	local v21 = n12
	local jump = fn37("jump", 262543674, 62240701, "JumpAnim", 1, tbl18.jump)
	local jump2

	if jump then
		jump2 = jump
	else
		local v22 = v20
		v21 = v22
		v20 = v22
		jump2 = FALLBACK_ANIMATION_NUMERIC_IDS.jump
	end

	arg.JumpAnimation = jump2
	local n13 = n12 - v20
	arg.RunAnimation = fn37("run", 262543674, 254678793, "RunAnim", 1, tbl18.run) or FALLBACK_ANIMATION_NUMERIC_IDS.run
	local n14 = v20 - n13
	arg.WalkAnimation = fn37("walk", 262543674, 402196730, "WalkAnim", 1, tbl18.walk) or FALLBACK_ANIMATION_NUMERIC_IDS.walk
	local swim = fn37("swim", 262543674, 249151465, "Swim", 1, tbl18.swim)

	if not swim then
		swim = FALLBACK_ANIMATION_NUMERIC_IDS.swim
		n14 = bit32.band(n14, n13) + 1220
	end

	arg.SwimAnimation = swim
	local v22 = bit32.bor(n13, n14)
	local idle = fn37("idle", 262543674, 315711563, "Animation1", 1, tbl18.idle1)
	local idle1

	if idle then
		idle1 = idle
	else
		idle1 = FALLBACK_ANIMATION_NUMERIC_IDS.idle1
		local v23 = bit32.bxor(v22, 4294967295)
		bit32.bxor(v21, 482502962)
	end

	arg.IdleAnimation = idle1
	return true
end

getCurrentScaleValues = function(arg)
	type(18409710)
	local n8 = 270762156
	local n9 = 301870150
	local n10 = 2690935404
	local n11 = 3988914154
	if not arg then
		return nil
	end

	local function fn37(arg2, arg3, arg4, arg5)
		local n12 = 1194120203
		local v20 = bit32.bxor(arg5, 0)
		local v21 = arg:FindFirstChild(arg3)
		local isNumberValue = v21 and v21:IsA("NumberValue")

		if isNumberValue then
			local bor = bit32.bor
			local v22 = bit32.bxor(arg2, 0)
			local v23 = bor(n12, v22)
			bit32.bxor(v20, 3258267137)
			isNumberValue = v21.Value
		end

		return isNumberValue or arg4
	end

	local ok2, result2 = pcall(function()
		return arg:GetAppliedDescription()
	end)

	local tbl25 = { height = fn37(435142459, "BodyHeightScale", ok2 and result2 and result2.HeightScale or 1, 514313518) }
	local v20 = table.pack(bit32.band(n10, 4294967295))
	local v21 = table.pack(bit32.band(v20[1], 65535))
	local v22 = bit32.band(v21[1] * 62958 + bit32.lshift(bit32.band(v21[1] * 0 + bit32.rshift(v20[1], 16) * 62958, 65535), 16), 4294967295)
	local widthScale = ok2 and result2 and result2.WidthScale or 1
	local n12 = v22 // 113
	tbl25.width = fn37(435142459, "BodyWidthScale", widthScale, 199274106)
	local depthScale = ok2 and result2 and result2.DepthScale or 1
	local n13 = n11 - n12
	tbl25.depth = fn37(435142459, "BodyDepthScale", depthScale, 313875981)
	bit32.bxor(n8, 514313518)
	tbl25.head = fn37(435142459, "HeadScale", ok2 and result2 and result2.HeadScale or 1, 175526176)
	local n14 = n12 * 37
	local bodyTypeScale = ok2 and result2 and result2.BodyTypeScale or 0
	local v23 = bit32.bxor(n13, n14)
	tbl25.bodyType = fn37(435142459, "BodyTypeScale", bodyTypeScale, 244929956)
	tbl25.proportion = fn37(435142459, "BodyProportionScale", ok2 and result2 and result2.ProportionScale or 0, 491923308)
	return tbl25
end

local v20
v20 = fn25

restoreCharacterColors = function(parent, arg)
	local n8 = 208710096
	local n9 = 1123704112
	local n10 = 3694871828
	if not parent or not arg then
		return
	end
	local str2 = "bodyColors"
	local v21 = bit32.bor(n9, n10)

	if arg.bodyColors then
		local bodyColors = arg.bodyColors

		local ok2, result2 = pcall(function()
			return bodyColors:Clone()
		end)

		if ok2 and result2 then
			local bodyColors2 = parent:FindFirstChildOfClass("BodyColors")

			if bodyColors2 then
				local n11 = 224854069

				pcall(function()
					bodyColors2:Destroy()
				end)
			end

			if not pcall(function()
				result2.Parent = parent
			end) then
				local n11 = 446486894

				local function fn37()
					result2:Destroy()
				end

				local v22 = v21
				pcall(fn37)

				task.defer(function()
					local flag = type(315211683) == "table"
					local n12 = 1543123181
					local n13 = 3388254976
					task.wait(0.12)
					local n14 = 660096967
					if not parent.Parent then
						return
					end

					local ok3, result3 = pcall(function()
						return bodyColors:Clone()
					end)

					if not ok3 or not result3 then
						return
					end
					local v23 = pcall
					bit32.bxor(n12, 575347584)

					local function fn38()
						local n15 = 2155116188
						local n16 = 3349895017
						local n17 = 980534756
						local bodyColors3 = parent:FindFirstChildOfClass("BodyColors")

						if bodyColors3 then
							bodyColors3:Destroy()
							local v24 = table.pack(bit32.band(n17, 4294967295))
							local v25 = table.pack(bit32.band(v24[1], 65535))
							local n18 = bit32.band(v25[1] * 59088 + bit32.lshift(bit32.band(v25[1] * 0 + bit32.rshift(v24[1], 16) * 59088, 65535), 16), 4294967295) + 2251695268
						end

						local v24 = result3
						bit32.bxor(n16, 879292951)
						bit32.bxor(n15, 723128962)
						v24.Parent = parent
					end

					bit32.band(n13, 307287460)
					v23(fn38)
				end)

				bit32.bxor(n8, 106669001)
			end
		end
	end

	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA("BasePart") then
			local v22 = arg.partColors[child.Name]

			if v22 then
				child.BrickColor = v22
			end
		end
	end
end

local n8, v21, v22

do
	local function fn37(arg, arg2)
		local n9 = 476124359
		local n10 = 2195093956
		local n11 = 2788876851
		if not animState.settings.replicateDescriptionToOthers then
			return true
		end
		local humanoid = arg and arg:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return false
		end
		local n12 = n11
		local v23 = fn26(arg)
		local v24 = getCurrentScaleValues(humanoid)

		local ok2, result2 = pcall(function()
			return humanoid:GetAppliedDescription()
		end)

		local flag = not ok2

		if not flag then
			flag = not result2
			n11 = bit32.bxor(bit32.bxor(n11, 2094001129), 2094001129)
		end

		if flag then
			v20(v23)
			return false
		end

		if v24 then
			result2.HeightScale = v24.height
			result2.WidthScale = v24.width
			result2.DepthScale = v24.depth
			result2.HeadScale = v24.head
			local bodyType = v24.bodyType
			local v25 = bit32.bxor(n11, 4294967295)
			result2.BodyTypeScale = bodyType
			result2.ProportionScale = v24.proportion
			n12 = n12 - 2527798911 - 1767168385
			n11 = v25 - 3012180889
		end

		if not applyAnimationSetToDescriptionFields(result2, arg2) then
			v20(v23)
			return false
		end

		if humanoid.ApplyDescriptionClientServer then
			local n13 = 494510901
			local n14 = n11 // n12

			if pcall(function()
				humanoid:ApplyDescriptionClientServer(result2)
			end) then
				n13 = restoreCharacterColors
				n13(arg, v23)
				n13 = task
				local n15 = 194195868

				n13.defer(function()
					task.wait(0.08)
					restoreCharacterColors(arg, v23)
					v20(v23)
				end)

				return true
			end

			local n15 = n14 - 1506090446
			bit32.bxor(n9, 2901065740)
		end

		v20(v23)
		return false
	end

	local n9 = v18 - 1096490850
	replicateAnimationStateForOthers = fn37

	applyAnimationSetViaDescription = function(arg, arg2)
		local n10 = 1197825812
		local n11 = 3614508136
		local n12 = 4214438570
		local n13 = 2679755390
		local n14 = 350679796
		local flag = not arg
		local n15 = 4214438570
		local flag2

		if flag then
			flag2 = flag
		else
			flag2 = not arg2
			bit32.bxor(n10, 839612975)
		end

		if flag2 then
			return false
		end

		local ok2, result2 = pcall(function()
			return arg:GetAppliedDescription()
		end)

		if not ok2 or not result2 then
			return false
		end

		if not applyAnimationSetToDescriptionFields(result2, arg2) then
			return false
		end
		local applyDescriptionClientServer = arg.ApplyDescriptionClientServer
		bit32.bxor(n11, 2885856679)

		if applyDescriptionClientServer then
			local n16 = 339535476
			if pcall(function()
				arg:ApplyDescriptionClientServer(result2)
			end) then
				return true
			end
		end

		return (pcall(function()
			arg:ApplyDescription(result2)
		end))
	end

	stopDirectController = function(arg)
		local n10 = 1500533011
		local n11 = 604724980
		local n12 = 822767625
		if not arg then
			return
		end
		local v23 = animState.directControllerByChar[arg]
		local v24 = bit32.band(n12, 4249834049)
		if not v23 then
			return
		end

		if v23.connection and v23.connection.Connected then
			v23.connection:Disconnect()
			n11 = n11 + v24 + 3472207871
		end

		if v23.tracks then
			for _, track in pairs(v23.tracks) do
				local n13 = 272252530

				pcall(function()
					track:Stop(0.08)
				end)
			end
		end

		if v23.animations then
			for _, animation in pairs(v23.animations) do
				local v25 = pcall
				local n13 = 164933348

				local function fn38()
					animation:Destroy()
				end

				n10 = bit32.bxor(n10, 1124811433)
				v25(fn38)
			end
		end

		animState.directControllerByChar[arg] = nil
		bit32.bor(v24, 3760930251)
	end

	stopAllDirectControllers = function()
		local n10 = 3729100011
		local n11 = 338257806
		local tbl25 = {}
		local v23, v24, v25 = pairs(animState.directControllerByChar)
		local v26 = bit32.band(1343390971, n11)

		for k in v23, v24, v25 do
			tbl25[#tbl25 + 1] = k
		end

		for _, v27 in ipairs(tbl25) do
			stopDirectController(v27)
		end

		animState.directControllerByChar = {}
		bit32.bxor(n10, 3771879509)
	end

	local function fn38(arg)
		local n10 = 92007862
		local n11 = 4091858627

		for k in pairs(animState.originalByCharacter) do
			if k ~= arg and (not k.Parent or k ~= v13.Character) then
				resetCharacterAnimations(k)
				animState.originalByCharacter[k] = nil
			end
		end

		local v23 = pairs
		local v24 = animState
		bit32.bxor(n11, 1488813101)
		local v25, v26, v27 = v23(v24.directControllerByChar)
		bit32.bxor(n10, 2402473793)

		for k in v25, v26, v27 do
			if k ~= arg and (not k.Parent or k ~= v13.Character) then
				stopDirectController(k)
			end
		end
	end

	n8 = v17 // 6 // n9
	pruneStaleCharacterAnimationState = fn38

	startDirectController = function(arg, arg2)
		local n10 = 2881802131
		local n11 = 13040765098
		local n12 = 1790499573
		local n13 = 2108788244
		local n14 = 7452499
		if not animState.settings.useDirectTrackFallback then
			return false
		end
		local humanoid = arg and arg:FindFirstChildOfClass("Humanoid")
		if not humanoid or not arg2 then
			return false
		end
		stopDirectController(arg)
		local v23 = n14
		local animator = humanoid:FindFirstChildOfClass("Animator")

		if not animator then
			local n15 = 267821028

			local ok2, result2 = pcall(function()
				return Instance.new("Animator")
			end)

			if ok2 and result2 then
				result2.Parent = humanoid
				local v24 = table.pack(bit32.band(v23, 4294967295))
				local v25 = table.pack(bit32.band(v24[1], 65535))
				animator = result2
				v23 = bit32.bxor(bit32.band(v25[1] * 58051 + bit32.lshift(bit32.band(v25[1] * 0 + bit32.rshift(v24[1], 16) * 58051, 65535), 16), 4294967295), 3120848234)
			end
		end

		if not animator then
			return false
		end

		local function fn39(arg3, arg4, arg5, arg6, arg7, arg8)
			local v24 = bit32.bxor(arg7, 0)
			local v25 = resolveIdFromFolderDataWithFallback
			bit32.bxor(bit32.bxor(arg7, 0), arg5)
			local v26 = arg2[arg3]
			local n15 = 1469405612 // bit32.bxor(arg7, 0)
			bit32.bxor(v24, 175631092)
			return v25(v26, arg4, arg6, arg8)
		end

		local tbl25 = {}
		local idle = fn39("idle", "Animation1", 481789794, 1, 87743293, tbl18.idle1)
		local v24 = bit32.band(n14, v23)
		tbl25.idle = idle
		local run = tbl18.run
		local v25 = table.pack(bit32.band(v23, 4294967295))
		local v26 = table.pack(bit32.band(v24, 4294967295))
		local v27 = table.pack(bit32.band(v25[1], 65535))
		local v28 = table.pack(bit32.rshift(v25[1], 16))
		local v29 = table.pack(bit32.band(v26[1], 65535))
		local v30 = bit32.band(v27[1] * v29[1] + bit32.lshift(bit32.band(v27[1] * bit32.rshift(v26[1], 16) + v28[1] * v29[1], 65535), 16), 4294967295)
		tbl25.run = fn39("run", "RunAnim", 16625443, 1, 87743293, run)
		tbl25.walk = fn39("walk", "WalkAnim", 359646630, 1, 87743293, tbl18.walk)
		local v31 = table.pack(bit32.band(v24, 4294967295))
		local v32 = table.pack(bit32.band(v30, 4294967295))
		local v33 = table.pack(bit32.band(v31[1], 65535))
		local v34 = table.pack(bit32.rshift(v31[1], 16))
		local v35 = table.pack(bit32.band(v32[1], 65535))
		local v36 = bit32.bxor(bit32.band(v33[1] * v35[1] + bit32.lshift(bit32.band(v33[1] * bit32.rshift(v32[1], 16) + v34[1] * v35[1], 65535), 16), 4294967295), 4294967295)
		tbl25.jump = fn39("jump", "JumpAnim", 371944935, 1, 87743293, tbl18.jump)
		local v37 = v36
		tbl25.fall = fn39("fall", "FallAnim", 266122918, 1, 87743293, tbl18.fall)
		local n15 = v36 - v37
		local n16 = v37 + n15
		tbl25.climb = fn39("climb", "ClimbAnim", 432876219, 1, 87743293, tbl18.climb)
		tbl25.swim = fn39("swim", "Swim", 45126546, 1, 87743293, tbl18.swim)
		local tbl26 = {}
		local tbl27 = {}
		local v38 = bit32.bor(n15, n16)
		local flag = false

		for k, v39 in pairs(tbl25) do
			if v39 then
				local animation = Instance.new("Animation")
				animation.Name = "Mimic_" .. k
				animation.AnimationId = v39
				tbl27[k] = animation

				local ok2, result2 = pcall(function()
					return animator:LoadAnimation(animation)
				end)

				if ok2 and result2 then
					local idle2 = k == "idle" and Enum.AnimationPriority.Idle

					if not idle2 then
						local animationPriority = Enum.AnimationPriority
						n12 = bit32.bxor(n12, 87743293)
						idle2 = animationPriority.Movement
					end

					result2.Priority = idle2
					result2.Looped = k ~= "jump" and k ~= "fall"
					tbl26[k] = result2
					n10 = bit32.bxor(n10, 45126546)
					flag = true
				end
			end
		end

		if not flag then
			for _, v39 in pairs(tbl27) do
				pcall(function()
					v39:Destroy()
				end)
			end

			return false
		end

		local tbl28 = { tracks = tbl26, animations = tbl27, connection = nil }
		local n17 = bit32.lshift(n16, 22) // v38
		tbl28.active = nil
		tbl28.nextUpdateAt = 0
		animState.directControllerByChar[arg] = tbl28

		local function fn40(active)
			local n18 = 4191138297
			local n19 = 1613184040
			local n20 = 1896450624

			if tbl28.active == active then
				local n21 = n20 + 3801943410
				local v39 = tbl28.tracks[active]

				if v39 and not v39.IsPlaying then
					pcall(function()
						v39:Play(0.08, 1, 1)
					end)

					bit32.bxor(bit32.bor(n19, n21), 327189394)
				end

				return
			end

			tbl28.active = active

			for k, track in pairs(tbl28.tracks) do
				if k == active then
					local n21 = 535988824

					pcall(function()
						local n22 = 3288313065
						local n23 = 2481442796
						local n24 = 551148557

						if not track.IsPlaying then
							track:Play(0.08, 1, 1)
							local v39 = bit32.bxor(n23 // n24, 2481442792)
							bit32.bxor(n22, 288292330)
						end
					end)
				else
					local v39 = pcall
					n18 = bit32.bxor(n18, 4263633865)
					local n21 = 4362238561

					v39(function()
						if track.IsPlaying then
							track:Stop(0.08)
						end
					end)
				end
			end
		end

		local heartbeat = RunService2.Heartbeat
		bit32.bxor(v38, n17)
		local v39 = n17

		tbl28.connection = heartbeat:Connect(function()
			local n18 = 551421254
			local n19 = 2144974846
			local n20 = 3650626454
			local n21 = bit32.bxor(v39, 2911819766)
			local flag2 = not animState.active

			if not flag2 then
				flag2 = not arg.Parent
				n21 = n21 + n20 - 3650626454
			end

			if flag2 then
				stopDirectController(arg)
				return
			end
			local n22 = n20 + n21
			local now = os.clock()
			if now < tbl28.nextUpdateAt then
				return
			end
			tbl28.nextUpdateAt = now + 0.03
			bit32.bxor(n19, 1851990933)
			local v40 = bit32.lshift(n21, 9)
			local magnitude = humanoid.MoveDirection.Magnitude
			local state = humanoid:GetState()
			local v41 = Enum
			local v42 = bit32.band(n22, v40)

			if state == v41.HumanoidStateType.Freefall then
				local v43 = tbl26
				local v44 = table.pack(bit32.band(v40, 4294967295))
				local v45 = table.pack(bit32.band(v44[1], 65535))
				bit32.band(v45[1] * 33173 + bit32.lshift(bit32.band(v45[1] * 0 + bit32.rshift(v44[1], 16) * 33173, 65535), 16), 4294967295)

				if v43.fall then
					fn40("fall")
				elseif tbl26.jump then
					fn40("jump")
				end

				return
			end

			local humanoidStateType = Enum.HumanoidStateType
			local n23 = v42 // v40
			bit32.bxor(n18, 447493075)
			if state == humanoidStateType.Jumping and tbl26.jump then
				fn40("jump")
				return
			end
			local v43 = n23
			local flag3 = state == Enum.HumanoidStateType.Climbing

			if flag3 then
				flag3 = tbl26.climb
				n23 = n23 - 945246524 + 945246524
			end

			if flag3 then
				fn40("climb")
				return
			end

			if state == Enum.HumanoidStateType.Swimming and tbl26.swim then
				fn40("swim")
				return
			end

			if magnitude > 0.08 then
				if tbl26.run then
					fn40("run")
				elseif tbl26.walk then
					fn40("walk")
				end

				return
			end

			if tbl26.idle then
				local v44 = fn40
				bit32.bor(v43, n23)
				v44("idle")
			end
		end)

		return true
	end

	applyFolderDataToFolder = function(arg, arg2, arg3, arg4)
		local n10 = 3068554874
		local n11 = 1355029604
		if not arg2 then
			return 0
		end
		bit32.bxor(n11, 2729748898)
		local n12 = 0
		local n13 = 0

		for _, child in ipairs(arg2:GetChildren()) do
			if child:IsA("Animation") then
				n12 += 1
				local v23 = resolveIdFromFolderData(arg3, child.Name, n12)

				if v23 then
					if arg4 then
						rememberOriginal(arg, child)
					end

					child.AnimationId = v23
					n10 = bit32.bxor(n10, 2163924787)
					n13 += 1
				end
			end
		end

		return n13
	end

	v21 = bit32.bxor(v15, 119761161)

	local function fn39(arg)
		local n10 = 2026127366
		if not arg then
			return nil
		end

		for _, child in ipairs(arg:GetChildren()) do
			if child:IsA("Animation") then
				return child
			end
		end

		bit32.bxor(n10, 4294967295)
		return nil
	end

	v22 = bit32.bxor(n9, 579622208)
	getFirstAnimationInFolder = fn39
end

applySlotFromSet = function(arg, arg2, arg3, arg4, arg5, arg6)
	local n9 = 1815995510
	local n10 = 1490266360
	local v23 = arg2:FindFirstChild(arg4)
	if applyFolderDataToFolder(arg, v23, arg3 and arg3[arg4], arg6) > 0 then
		return true
	end
	local v24 = getFirstAnimationInFolder(v23)
	local v25 = n10
	local flag = not v24
	local v26 = n10
	if flag or not animState.settings.useFallbackWhenMissing then
		return false
	end
	local v27 = normalizeAnimationId(arg5)
	bit32.bxor(v26, 4289562395)
	if not v27 then
		return false
	end

	if arg6 then
		rememberOriginal(arg, v24)
	end

	v24.AnimationId = v27
	return true
end

local function fn37(arg, arg2, arg3, arg4)
	local idle = arg2:FindFirstChild("idle")
	if not idle then
		return false
	end
	local n9 = 0
	local n10 = 0

	for _, child in ipairs(idle:GetChildren()) do
		if child:IsA("Animation") then
			n9 += 1
			local idle2 = nil

			if animState.settings.useFallbackWhenMissing then
				idle2 = child.Name == "Animation2" and tbl18.idle2 or tbl18.idle1
			end

			local v23 = resolveIdFromFolderDataWithFallback(arg3, child.Name, n9, idle2)

			if v23 then
				if arg4 then
					rememberOriginal(arg, child)
				end

				child.AnimationId = v23
				n10 += 1
			end
		end
	end

	return n10 > 0
end

applyIdleFromSet = fn37

hardResetAnimator = function(arg)
	local n9 = 3904641846
	local n10 = 1035523273
	local n11 = 203356582
	if not arg then
		return
	end
	local playingAnimationTracks = arg:GetPlayingAnimationTracks()
	local v23 = ipairs
	bit32.bxor(n10, 1033785058)
	bit32.bxor(n9, 880787379)

	for _, playingAnimationTrack in v23(playingAnimationTracks) do
		playingAnimationTrack:Stop(0)
	end
end

flushAnimationState = function(arg)
	local n9 = 1162464148
	local n10 = 3085435555
	if not arg then
		return
	end
	local humanoid = arg:FindFirstChildOfClass("Humanoid")
	bit32.bxor(n9, 447284128)
	if not humanoid then
		return
	end
	local playingAnimationTracks = humanoid:GetPlayingAnimationTracks()

	for _, playingAnimationTrack in ipairs(playingAnimationTracks) do
		playingAnimationTrack:Stop(0)
	end
end

refreshAnimate = function(arg)
	local n9 = 1025800632
	local n10 = 1653689628
	local n11 = 2324853787
	local animate = arg and arg:FindFirstChild("Animate")

	if animate and animate:IsA("LocalScript") then
		animate.Disabled = true
		local v23 = task
		bit32.bxor(n9, 3374306433)
		local wait = v23.wait
		local v24 = bit32.bxor(n11, n10)
		wait()
		animate.Disabled = false
		n11 = bit32.bxor(v24, 1653689628)
	end

	arg = arg and arg:FindFirstChildOfClass("Humanoid")

	if arg then
		local playingAnimationTracks = arg:GetPlayingAnimationTracks()
		local n12 = n10 + n11

		for _, playingAnimationTrack in ipairs(playingAnimationTracks) do
			playingAnimationTrack:Stop(0)
		end

		arg:ChangeState(Enum.HumanoidStateType.Running)
		bit32.bxor(n12, 2410843179)
	end
end

forceAnimationKick = function(arg)
	type(0)
	local n9 = 2314526251
	local n10 = 2747387413
	local n11 = 717671888
	local n12 = 661291567
	local n13 = 81601492
	local v23

	if arg then
		local humanoid = arg:FindFirstChildOfClass("Humanoid")
		bit32.bxor(n10, 3226354013)
		v23 = humanoid
	else
		v23 = arg
	end

	if not v23 then
		return
	end
	v23:Move(Vector3.zero, true)
	v23:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
	local wait = task.wait
	local v24 = bit32.bxor(n13, 4294967295)
	wait()
	v23:ChangeState(Enum.HumanoidStateType.Running)
	local v25 = task
	bit32.bxor(n9, 25446668)
	local n14 = n12 - 72486569

	v25.defer(function()
		local n15 = 1535515614
		local n16 = 111131343
		local n17 = 1090350667
		if not arg.Parent then
			return
		end
		local n18 = #v23:GetPlayingAnimationTracks()
		bit32.bxor(n16, 1576629685)
		if n18 > 0 then
			return
		end
		v23:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
		local v26 = task
		bit32.bxor(n15, 1470025943)
		v26.wait()
		v23:ChangeState(Enum.HumanoidStateType.Running)
	end)
end

scrubTracksForDuration = function(arg, arg2)
	local n9 = 701134454
	local n10 = 2667863945
	local n11 = 1954254019
	arg = arg and arg:FindFirstChildOfClass("Humanoid")
	local v23 = table.pack(bit32.band(n10, 4294967295))
	local v24 = table.pack(bit32.band(n11, 4294967295))
	local v25 = table.pack(bit32.band(v23[1], 65535))
	local v26 = table.pack(bit32.rshift(v23[1], 16))
	local v27 = table.pack(bit32.band(v24[1], 65535))
	local v28 = bit32.band(v25[1] * v27[1] + bit32.lshift(bit32.band(v25[1] * bit32.rshift(v24[1], 16) + v26[1] * v27[1], 65535), 16), 4294967295)
	if not arg then
		return
	end
	local playingAnimationTracks = arg:GetPlayingAnimationTracks()

	for _, playingAnimationTrack in ipairs(playingAnimationTracks) do
		playingAnimationTrack:Stop(0)
	end

	local wait = task.wait
	bit32.bor(n11, v28)
	bit32.bxor(n9, 3768100245)
	wait(arg2 or 0.2)
	local playingAnimationTracks2 = arg:GetPlayingAnimationTracks()

	for _, v29 in ipairs(playingAnimationTracks2) do
		v29:Stop(0)
	end
end

applyAnimationSetToCharacter = function(arg, arg2)
	type(534209238)
	local n9 = 3993054526
	local n10 = 2990918202
	local n11 = 933664033
	local n12 = 323329317
	local flag = not arg
	local n13 = -286509082
	if flag or not arg2 then
		return false
	end
	local animate = arg:FindFirstChild("Animate")
	local humanoid = arg:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return false
	end
	hardResetAnimator(humanoid)
	local n14 = n11 - 329750631
	local n15 = 0

	if animate then
		local n16 = n12 // 3

		for _, v23 in ipairs(tbl19) do
			if applySlotFromSet(arg, animate, arg2, v23.folder, v23.fallback, true) then
				n10 = bit32.bxor(n10, 3025587491)
				n15 += 1
			end
		end

		if applyIdleFromSet(arg, animate, arg2.idle, true) then
			n15 += 1
		end

		n12 = bit32.bxor(n16, 355013778)
		bit32.bxor(n9, 2377486481)
	end

	local v23 = bit32.bxor(n13, n12)

	if n15 > 0 then
		stopDirectController(arg)
		refreshAnimate(arg)
	elseif applyAnimationSetViaDescription(humanoid, arg2) then
		stopDirectController(arg)
	else
		local flag2 = not startDirectController(arg, arg2)
		local v24 = table.pack(bit32.band(n12, 4294967295))
		local v25 = table.pack(bit32.band(v23, 4294967295))
		local v26 = table.pack(bit32.band(v24[1], 65535))
		local v27 = table.pack(bit32.rshift(v24[1], 16))
		local v28 = table.pack(bit32.band(v25[1], 65535))
		local v29 = bit32.band(v26[1] * v28[1] + bit32.lshift(bit32.band(v26[1] * bit32.rshift(v25[1], 16) + v27[1] * v28[1], 65535), 16), 4294967295)
		if flag2 then
			return false
		end
		n12 = v29 + 3698808822
	end

	forceAnimationKick(arg)
	replicateAnimationStateForOthers(arg, arg2)

	task.defer(function()
		local n16 = bit32.bxor(n14, 0) + 279439406
		local n17 = 1562678541
		local n18 = 326990571
		local v24 = animState
		local v25 = table.pack(bit32.band(n18, 4294967295))
		local v26 = table.pack(bit32.band(v25[1], 65535))
		bit32.band(53841 * v26[1] + bit32.lshift(bit32.band(53841 * bit32.rshift(v25[1], 16) + 20405 * v26[1], 65535), 16), 4294967295)
		local n19 = 845706557
		if not v24.active then
			return
		end
		local emoteMimic = result and result.EmoteMimic

		if emoteMimic then
			local v27 = type
			bit32.bxor(n17, 1095482613)
			emoteMimic = v27(result.EmoteMimic.Reapply) == "function"
		end

		if not emoteMimic then
			return
		end

		pcall(function()
			result.EmoteMimic.Reapply()
		end)
	end)

	bit32.rshift(n12, 14)
	return true
end

restoreOwnAnimationsHard = function(arg)
	local n9 = 410761710
	type(410761710)
	local n10 = 454707710
	local n11 = 1325284093
	local n12 = 2758587845
	local n13 = 1663211629
	if not arg then
		return false
	end
	local v23 = getAnimationSetFromUserId(v13.UserId)
	local n14 = bit32.bxor(n12, 982159844)
	if not v23 then
		return false
	end
	local animate = arg:FindFirstChild("Animate")
	local humanoid = arg:FindFirstChildOfClass("Humanoid")
	local n15 = n13 + 4129794807
	if not humanoid then
		return false
	end
	hardResetAnimator(humanoid)
	local n16 = n9 + 501925130
	local n17 = 0

	if animate then
		for _, v24 in ipairs(tbl19) do
			if applySlotFromSet(arg, animate, v23, v24.folder, v24.fallback, false) then
				n17 += 1
			end
		end

		if applyIdleFromSet(arg, animate, v23.idle, false) then
			n17 += 1
			n14 = n14 + 1670062761 - 1670062761
		end
	end

	if n17 > 0 then
		stopDirectController(arg)
		refreshAnimate(arg)
	elseif applyAnimationSetViaDescription(humanoid, v23) then
		stopDirectController(arg)
	else
		n11 = n15
		if not animState.active then
			return false
		end

		if not startDirectController(arg, v23) then
			return false
		end
	end

	forceAnimationKick(arg)
	local v24 = replicateAnimationStateForOthers
	bit32.bxor(n10, 2760554804)
	v24(arg, v23)
	local v25 = bit32.bxor(n11, 3655594890)
	local v26 = table.pack(bit32.band(n16, 4294967295))
	local v27 = table.pack(bit32.band(v26[1], 65535))
	local n18 = 2960207949 + bit32.band(18029 * v27[1] + bit32.lshift(bit32.band(18029 * bit32.rshift(v26[1], 16) + 50291 * v27[1], 65535), 16), 4294967295)
	local v28 = table.pack(bit32.band(n17, 4294967295))
	local v29 = table.pack(bit32.band(v28[1], 65535))
	local v30 = bit32.band(1874 * v29[1] + bit32.lshift(bit32.band(1874 * bit32.rshift(v28[1], 16) + 60986 * v29[1], 65535), 16), 4294967295)
	local v31 = table.pack(bit32.band(bit32.bnot(n17), 4294967295))
	local v32 = table.pack(bit32.band(v31[1], 65535))
	local v33 = bit32.band(1874 * v32[1] + bit32.lshift(bit32.band(1874 * bit32.rshift(v31[1], 16) + 60986 * v32[1], 65535), 16), 4294967295)
	local v34 = table.pack(bit32.band(bit32.bnot(n16), 4294967295))
	local v35 = table.pack(bit32.band(v34[1], 65535))
	local n19 = n18 + v30 + v33 + bit32.band(18028 * v35[1] + bit32.lshift(bit32.band(18028 * bit32.rshift(v34[1], 16) + 50291 * v35[1], 65535), 16), 4294967295)

	task.defer(function()
		local n20 = 43625356

		if bit32.bxor(n19, 0) + 445637599 == 92324226 then
			bit32.bxor(n20, 45991521)
		end

		local n21 = 1915997800
		local n22 = 2098251477
		local v36 = table.pack(bit32.band(n20, 4294967295))
		local v37 = table.pack(bit32.band(v36[1], 65535))
		local n23 = bit32.band(28474 * v37[1] + bit32.lshift(bit32.band(28474 * bit32.rshift(v36[1], 16) + 40470 * v37[1], 65535), 16), 4294967295) + 1527927394
		local v38 = table.pack(bit32.band(bit32.bor(n20, 407192997), 4294967295))
		local v39 = table.pack(bit32.band(v38[1], 65535))
		local v40 = bit32.band(37063 * v39[1] + bit32.lshift(bit32.band(37063 * bit32.rshift(v38[1], 16) + 25065 * v39[1], 65535), 16), 4294967295)
		local v41 = table.pack(bit32.band(bit32.band(n20, 407192997), 4294967295))
		local v42 = table.pack(bit32.band(v41[1], 65535))
		local n24 = 2944920602
		local flag = not animState.active
		local v43 = bit32.bxor(n23 + v40 + bit32.band(37061 * v42[1] + bit32.lshift(bit32.band(37061 * bit32.rshift(v41[1], 16) + 25065 * v42[1], 65535), 16), 4294967295), 399453639)
		if flag then
			return
		end
		local emoteMimic = result and result.EmoteMimic

		if emoteMimic then
			local v44 = type
			bit32.bxor(n21, 2020145582)
			local v45 = bit32.bor(n22, 2050916150)
			emoteMimic = v44(result.EmoteMimic.Reapply) == "function"
			n22 = v45 - 36583714
		end

		if not emoteMimic then
			return
		end
		local v44 = pcall
		bit32.bor(n24, n22)

		v44(function()
			result.EmoteMimic.Reapply()
		end)
	end)

	bit32.bxor(n14, 3608257349)
	return true
end

local v23
local v24 = bit32.bxor(v21, 0)
v23 = bit32.bxor(v22, v24)

mimicAnimationsFromUserId = function(arg, arg2)
	local n9 = 168243708
	local n10 = 13497629
	local n11 = 3754301116
	local n12 = 1917734769
	local n13 = 10223696
	if not animState.active then
		return false
	end
	arg2 = arg2 ~= false and arg2 or false
	local lastSourceUserId = tonumber(arg)
	if not lastSourceUserId then
		return false
	end
	local character = v13.Character
	local n14 = n11 + n13
	if not character then
		return false
	end
	pruneStaleCharacterAnimationState(character)
	local flag = not arg2

	if flag then
		flag = animState.lastSourceUserId == lastSourceUserId
		n14 = bit32.rshift(n14, 20) + 3764521222
	end

	if flag then
		return true
	end
	local v25 = animState
	local n15 = n9 + 31392792
	local v26 = animState
	local v27 = bit32.band(n13, 1416098420)
	v25.applyToken = v26.applyToken + 1
	local applyToken = animState.applyToken

	if getUserAvatarType(lastSourceUserId) == "R6" then
		animState.lastSourceUserId = nil
		restoreOwnAnimationsHard(character)
		bit32.rshift(n14, 12)
		flushAnimationState(character)
		return false
	end

	local v28 = getAnimationSetFromUserIdWithRetry(lastSourceUserId, 3)
	local v29 = bit32.bxor(v27, 4294967295)
	if not v28 then
		animState.lastSourceUserId = nil
		return false
	end
	local v30 = animState
	local n16 = n15 + 33073742
	local v31 = bit32.lshift(v29, 5)
	if applyToken ~= v30.applyToken then
		return false
	end
	local lastSourceUserId2 = animState.lastSourceUserId

	if lastSourceUserId2 then
		local v32 = animState
		bit32.bxor(n10, 1271256180)
		local lastSourceUserId3 = v32.lastSourceUserId
		bit32.bxor(n12, 1453975701)
		lastSourceUserId2 = lastSourceUserId3 ~= lastSourceUserId
		n14 = n14 - 981295841 - 3313671455
	end

	if lastSourceUserId2 then
		restoreOwnAnimationsHard(character)
		flushAnimationState(character)
		scrubTracksForDuration(character, 0.18)
		local v32 = animState
		local v33 = bit32.band(v31, n14)
		if applyToken ~= v32.applyToken then
			return false
		end
		v31 = bit32.bxor(v33, 522051808)
	end

	animState.lastSourceUserId = lastSourceUserId
	animState.pinnedTargetUserId = lastSourceUserId
	local v32 = applyAnimationSetToCharacter(character, v28)
	bit32.bxor(v31, n14 - v31)
	if not v32 then
		return false
	end

	task.defer(function()
		local n17 = 1574797
		local n18 = 414544906
		local v33 = bit32.bxor(n16, 2241664875)
		task.wait(0.2)
		local n19 = 3370334314
		if applyToken ~= animState.applyToken then
			return
		end
		bit32.bxor(n18, 2449517438)
		if not character.Parent then
			return
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end
		local n20 = v33 - n19

		if #humanoid:GetPlayingAnimationTracks() == 0 then
			restoreOwnAnimationsHard(character)
			local v34 = applyAnimationSetToCharacter
			bit32.bxor(n17, 2353931978)
			v34(character, v28)
			local v35 = table.pack(bit32.band(n20, 4294967295))
			local v36 = table.pack(bit32.band(n19, 4294967295))
			local v37 = table.pack(bit32.band(v35[1], 65535))
			local v38 = table.pack(bit32.rshift(v35[1], 16))
			local v39 = table.pack(bit32.band(v36[1], 65535))
			local n21 = bit32.band(v37[1] * v39[1] + bit32.lshift(bit32.band(v37[1] * bit32.rshift(v36[1], 16) + v38[1] * v39[1], 65535), 16), 4294967295) - 3881695031
		end
	end)

	return v32
end

mimicAnimationsFromTarget = function(lastTargetInput)
	local n9 = 2164724767
	local n10 = 2027331196
	local n11 = 934343588
	local n12 = 1938048409
	if not animState.active then
		bit32.bxor(n10, 3688761267)
		return false
	end
	local v25 = resolveTargetToUserId(lastTargetInput)

	if not v25 then
		bit32.bxor(n9, 3837643999)
		bit32.bxor(n11, n12)
		return false
	end

	animState.lastTargetInput = lastTargetInput
	animState.pinnedTargetUserId = v25
	local v26 = animState
	local v27 = bit32.band(n12, 2354968863)

	if v26.settings.invalidateAnimationCacheOnTargetSwitch then
		local v28 = animState
		local v29 = table.pack(bit32.band(n11, 4294967295))
		local v30 = table.pack(bit32.band(v27, 4294967295))
		local v31 = table.pack(bit32.band(v29[1], 65535))
		local v32 = table.pack(bit32.rshift(v29[1], 16))
		local v33 = table.pack(bit32.band(v30[1], 65535))
		local v34 = bit32.band(v31[1] * v33[1] + bit32.lshift(bit32.band(v31[1] * bit32.rshift(v30[1], 16) + v32[1] * v33[1], 65535), 16), 4294967295)
		v28.animationSetCache[v25] = nil
	end

	return mimicAnimationsFromUserId(v25, true)
end

disconnectAllConnections = function()
	local n9 = 2245561247

	for _, connection4 in ipairs(animState.connections) do
		if connection4 and connection4.Connected then
			connection4:Disconnect()
		end
	end

	animState.connections = {}
	bit32.bxor(n9, 3611716458)
end

clearRuntimeCaches = function()
	animState.animationSetCache = {}
end

restoreCharacterToSelf = function(arg)
	local n9 = 214044623
	local n10 = 4198547708
	local n11 = 2292685286
	local n12 = 3346342088
	if not arg then
		return false
	end
	resetCharacterAnimations(arg)
	bit32.bxor(n9, 2642300913)
	local v25 = restoreOwnAnimationsHard
	bit32.bxor(n10, 2235909000)
	local v26 = v25(arg)
	flushAnimationState(arg)
	return v26
end

animCleanup = function()
	local n9 = 42525173
	local n10 = 79236544
	local n11 = 4136196243
	local n12 = 1942323967
	if not animState.active then
		return
	end
	local v25 = animState
	local v26 = bit32.lshift(n12, 12)
	v25.active = false
	local v27 = animState
	bit32.bxor(n10, 1209843621)
	local v28 = table.pack(bit32.band(n11, 4294967295))
	local v29 = table.pack(bit32.band(v28[1], 65535))
	local v30 = bit32.band(v29[1] * 13192 + bit32.lshift(bit32.band(v29[1] * 0 + bit32.rshift(v28[1], 16) * 13192, 65535), 16), 4294967295)
	v27.lastSourceUserId = nil
	animState.pinnedTargetUserId = nil
	animState.lastTargetInput = nil
	local v31 = animState
	local applyToken = animState.applyToken
	local v32 = bit32.bxor(v26, 3075305748)
	v31.applyToken = applyToken + 1
	bit32.bxor(v30, 4294967295)
	disconnectAllConnections()
	local character = v13.Character
	stopAllDirectControllers()
	bit32.bxor(n9, 667348787)
	restoreCharacterToSelf(character)
	flushAnimationState(character)
	animState.originalByCharacter = {}
	clearRuntimeCaches()
end

animState.cleanup = animCleanup
local n9 = n8 + v23 + bit32.bxor(v21, 0)

if result then
	result.CloneAnimationsFromTarget = mimicAnimationsFromTarget
	result.AnimationMimicCleanup = animCleanup
end

local emoteMimicState = result and result.__EmoteMimicState

if emoteMimicState then
	emoteMimicState = type(result.__EmoteMimicState.cleanup) == "function"
	local v25 = table.pack(bit32.band(v23, 4294967295))
	local v26 = table.pack(bit32.band(v25[1], 65535))
	v23 = bit32.bxor(bit32.band(v26[1] * 9202 + bit32.lshift(bit32.band(v26[1] * 0 + bit32.rshift(v25[1], 16) * 9202, 65535), 16), 4294967295), 4240893046)
end

if emoteMimicState then
	pcall(result.__EmoteMimicState.cleanup)
end

local fn38
fn38 = nil
local v25
v25 = bit32.bxor(v21, 42342536)

fn38 = function(arg, arg2)
	local n10 = 2655460533
	local n11 = 1261751509
	local kind = type(arg)
	local v26 = table.pack(bit32.band(n11, 4294967295))
	local v27 = table.pack(bit32.band(v26[1], 65535))
	bit32.band(61983 * v27[1] + bit32.lshift(bit32.band(61983 * bit32.rshift(v26[1], 16) + 23807 * v27[1], 65535), 16), 4294967295)
	if kind ~= "table" then
		return arg
	end
	local tbl25 = arg2 or {}

	if tbl25[arg] then
		local v28 = tbl25[arg]
		bit32.bxor(n10, 2368233374)
		return v28
	end

	local tbl26 = {}
	tbl25[arg] = tbl26
	local v28, v29, v30 = pairs(arg)
	bit32.lshift(n11, 31)

	for k, v31 in v28, v29, v30 do
		tbl26[fn38(k, tbl25)] = fn38(v31, tbl25)
	end

	return tbl26
end

local emoteMimicState2, v26

do
	local n10 = v23 - 2663515055
	emoteMimicState2 = { active = tbl2.Enabled == true, targetInput = tbl3.target }
	local v27 = bit32.lshift(n10, 8)
	emoteMimicState2.currentUserId = nil
	emoteMimicState2.applyToken = 0
	emoteMimicState2.connections = {}
	emoteMimicState2.emoteCache = {}
	emoteMimicState2.cacheTtlSeconds = 20
	emoteMimicState2.cleanup = nil
	local settings = {}
	v26 = bit32.band(n10 - 61194331, v27)
	settings.autoApplyOnRespawn = true
	emoteMimicState2.settings = settings
end

if result then
	result.__EmoteMimicState = emoteMimicState2
end

local fn39

fn39 = function()
	local n10 = 3079517531
	local n11 = 2035169379

	for _, connection4 in ipairs(emoteMimicState2.connections) do
		if connection4 and connection4.Connected then
			connection4:Disconnect()
		end
	end

	emoteMimicState2.connections = {}
end

local fn40

fn40 = function()
	emoteMimicState2.emoteCache = {}
end

local fn41, v27, v28, cloneEmotesFromUserId

do
	local function fn42(arg)
		local n10 = 1418137249
		local n11 = 2572807281
		local n12 = 295940981
		local n13 = 369374168
		if not arg then
			return nil
		end
		local kind = type(arg.GetEmotes)
		local n14 = bit32.rshift(n12, 14)
		local tbl25 = nil

		if kind == "function" then
			local ok2, result2 = pcall(function()
				return arg:GetEmotes()
			end)

			local v29 = n14
			local flag = ok2 and type(result2) == "table"
			tbl25 = nil

			if flag then
				tbl25 = fn38(result2)
			end

			n13 = bit32.bxor(v29, 369390934)
		end

		local v29 = type
		local v30 = bit32.band(n13, 2020026670)
		bit32.bxor(n10, 3944110534)
		local n15 = v30
		local tbl26 = nil

		if v29(arg.GetEquippedEmotes) == "function" then
			local n16 = 37602610

			local ok2, result2 = pcall(function()
				return arg:GetEquippedEmotes()
			end)

			local v31 = bit32.band(n14, 2375902121)
			ok2 = ok2 and type(result2) == "table"
			tbl26 = nil

			if ok2 then
				tbl26 = fn38(result2)
			end

			n14 = v31 - 4294966266
		end

		if tbl25 == nil then
			local ok2, result2 = pcall(function()
				return arg.Emotes
			end)

			if ok2 then
				ok2 = type(result2) == "table"
				n14 = bit32.bxor(bit32.band(n14, 482662517), 1674)
			end

			if ok2 then
				tbl25 = fn38(result2)
			end
		end

		if tbl26 == nil then
			local n16 = 665522015

			local ok2, result2 = pcall(function()
				return arg.EquippedEmotes
			end)

			if ok2 then
				ok2 = type(result2) == "table"
				n15 = bit32.band(n15, 2072539283) + 262408
			end

			if ok2 then
				tbl26 = fn38(result2)
			end
		end

		if type(tbl25) ~= "table" then
			tbl25 = {}
		end

		local kind2 = type(tbl26)
		bit32.bxor(n11, 2727548609)

		if kind2 ~= "table" then
			tbl26 = {}
		end

		return { emotes = tbl25, equipped = tbl26 }
	end

	local function fn43(arg)
		local n10 = 3017549246
		local n11 = 509697037
		local flag = type(arg) == "table"

		if flag then
			flag = next(arg) ~= nil
			local v29 = bit32.rshift(n11, 4)
			bit32.bxor(n10, 2957483746)
		end

		return flag
	end

	fn41 = function(arg)
		local n10 = 1347230384
		local n11 = 4173836108
		local n12 = 73489868
		local n13 = 1067807775
		if type(arg) ~= "table" then
			return false
		end
		local v29 = fn43
		bit32.bxor(n10, 1465544643)
		local v30 = bit32.bxor(n11, 4294967295)
		local emotes = arg.emotes
		bit32.bxor(n12, 3218769575)
		local v31 = v29(emotes)
		local n14 = 1067807775
		local v32

		if v31 then
			v32 = v31
		else
			v32 = fn43(arg.equipped)
			bit32.bxor(n13 - v30, 130570099)
		end

		return v32
	end

	local function fn44(arg)
		type(446273838)
		local n10 = 4065735616
		local n11 = 1521379931
		local n12 = 289607934

		local function fn45()
			return Players2:GetPlayerByUserId(arg)
		end

		local n13 = 1615339520
		local ok2, result2 = pcall(fn45)
		if not ok2 or not result2 then
			return nil
		end
		local character = result2.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		bit32.band(n11, n13)
		if not humanoid then
			return nil
		end

		local ok3, result3 = pcall(function()
			return humanoid:GetAppliedDescription()
		end)

		if not ok3 or not result3 then
			bit32.bxor(n10, 803483224)
			return nil
		end
		local v29 = fn42(result3)

		pcall(function()
			result3:Destroy()
		end)

		return v29
	end

	local function fn45(arg)
		local n10 = 3360716308
		local n11 = 2146780897
		local n12 = 1918807335
		local v29 = cacheGetEntry
		local emoteCache = emoteMimicState2.emoteCache
		local v30 = emoteMimicState2
		local v31 = bit32.bxor(1483975778, n12)
		local v32 = v29(emoteCache, arg, v30.cacheTtlSeconds)

		if v32 and v32.data then
			local tbl25 = {}
			local v33 = fn38
			local data = v32.data
			bit32.bxor(n10, 493230426)
			tbl25.emotes = v33(data.emotes)
			local v34 = fn38
			bit32.bxor(v31, n12)
			tbl25.equipped = v34(v32.data.equipped)
			return tbl25
		end

		local v33 = nil
		local v34 = getTargetDescriptionCached(arg)
		local v35 = nil

		if v34 then
			local n13 = 75317668

			if v33 then
			end

			local v36 = fn42
			local v37 = table.pack(bit32.band(n12, 4294967295))
			local v38 = table.pack(bit32.band(v37[1], 65535))
			local v39 = bit32.band(v38[1] * 33726 + bit32.lshift(bit32.band(v38[1] * 0 + bit32.rshift(v37[1], 16) * 33726, 65535), 16), 4294967295)
			local n14 = n13 + 147806728 + 94746320
			local v40 = v36(v34)

			pcall(function()
				v34:Destroy()
			end)

			n12 = v39 - 3800091339
			v35 = v40
		end

		if not fn41(v35) then
			local n13 = v31 // 14 - 3637917101
			v35 = fn44(arg)
		end

		local flag = not v35

		if not flag then
			flag = not fn41(v35)
			bit32.bxor(n11, 3815548561)
		end

		if flag then
			return nil
		end
		local v36 = cacheSetEntry
		local emoteCache2 = emoteMimicState2.emoteCache
		local tbl25 = { data = v35, timestamp = os.clock() }
		local emoteData = tbl12.emoteData
		bit32.lshift(n12 + 1361364378, 14)
		v36(emoteCache2, arg, tbl25, emoteData)
		return v35
	end

	local function fn46(arg, arg2)
		local n10 = 3465802651
		local n11 = 284811407
		local n12 = 1155491951
		if not arg or not arg2 then
			return false
		end
		local flag = false

		if fn43(arg2.emotes) then
			local n13 = 497114971
			local n14 = n12 * 3

			flag = pcall(function()
				arg:SetEmotes(fn38(arg2.emotes))
			end)

			local v29 = n14
			n12 = n14 - 2310983902
			bit32.bxor(n11, 1929391580)
		end

		if fn43(arg2.equipped) then
			local n13 = 212997827

			local ok2 = pcall(function()
				arg:SetEquippedEmotes(fn38(arg2.equipped))
			end)

			flag = flag or ok2
		end

		return flag
	end

	v27 = bit32.bxor(v25, 0)

	local function fn47(arg, arg2)
		local n10 = 2262837448
		local n11 = 1610138824
		local n12 = 960830383
		if not arg or not arg2 then
			return
		end
		arg.HeightScale = arg2.height
		local n13 = n11 // 14
		arg.WidthScale = arg2.width
		local depth = arg2.depth
		bit32.bxor(n10, 4245450148)
		arg.DepthScale = depth
		local head = arg2.head
		local v29 = table.pack(bit32.band(n12, 4294967295))
		local v30 = table.pack(bit32.band(n13, 4294967295))
		local v31 = table.pack(bit32.band(v29[1], 65535))
		local v32 = table.pack(bit32.rshift(v29[1], 16))
		local v33 = table.pack(bit32.band(v30[1], 65535))
		local v34 = bit32.band(v31[1] * v33[1] + bit32.lshift(bit32.band(v31[1] * bit32.rshift(v30[1], 16) + v32[1] * v33[1], 65535), 16), 4294967295)
		arg.HeadScale = head
		arg.BodyTypeScale = arg2.bodyType
		arg.ProportionScale = arg2.proportion
	end

	local function fn48(arg, arg2)
		type(0)
		local n10 = 1632781494
		local n11 = 2882526824
		local n12 = 468254579
		local n13 = 4050181794
		if not arg2 then
			return
		end
		restoreCharacterColors(arg, arg2)

		task.defer(function()
			local n14 = 3059938426
			local n15 = 3594957706 // 2454041505
			task.wait(0.06)
			local parent = arg

			if arg then
				parent = arg.Parent
			end

			if parent then
				restoreCharacterColors(arg, arg2)
				bit32.bxor(n14, 65946846)
			end
		end)

		local v29 = task
		bit32.bxor(n10, 1223257296)

		v29.defer(function()
			local n14 = 1645821595
			local v30 = task
			local v31 = table.pack(bit32.band(n14, 4294967295))
			local v32 = table.pack(bit32.band(v31[1], 65535))
			bit32.band(14177 * v32[1] + bit32.lshift(bit32.band(14177 * bit32.rshift(v31[1], 16) + 65029 * v32[1], 65535), 16), 4294967295)
			v30.wait(0.2)

			if arg and arg.Parent then
				restoreCharacterColors(arg, arg2)
			end

			bit32.bxor(n14, 4294967295)
			v20(arg2)
		end)
	end

	local function fn49(arg, arg2)
		local n10 = 482981303
		local n11 = 3364659155
		local n12 = 3182076512
		if not arg or not arg2 then
			bit32.lshift(n11, 15)
			return false
		end

		if not fn41(arg2) then
			return false
		end
		local parent = arg.Parent
		local v29 = fn26(parent)
		local v30 = getCurrentScaleValues(arg)
		local humanoidDescription = arg:FindFirstChildOfClass("HumanoidDescription") or arg:FindFirstChild("HumanoidDescription")
		local v31

		if humanoidDescription then
			v31 = fn46(humanoidDescription, arg2)
			n12 = n12 + 3698326491 - 3510644587 - 187681904
		else
			v31 = humanoidDescription
		end

		if v31 then
			v20(v29)
			local n13 = 8626112080

			task.defer(function()
				local n14 = 4101398366
				local n15 = 6690719720
				local flag = not emoteMimicState2.active

				if not flag then
					flag = not humanoidDescription.Parent
					bit32.bxor(n15, 2059016374)
				end

				if flag then
					return
				end
				fn46(humanoidDescription, arg2)
			end)

			return true
		end

		local ok2, result2 = pcall(function()
			return arg:GetAppliedDescription()
		end)

		if not ok2 or not result2 then
			v20(v29)
			return false
		end
		local n13 = n11 + n12

		if not fn46(result2, arg2) then
			v20(v29)

			pcall(function()
				result2:Destroy()
			end)

			bit32.bxor(n13, 1758662844)
			return false
		end

		fn47(result2, v30)

		if arg.ApplyDescriptionClientServer then
			if pcall(function()
				arg:ApplyDescriptionClientServer(result2)
			end) then
				fn48(parent, v29)
				local n14 = 110035104
				bit32.bxor(n12, n13)

				pcall(function()
					result2:Destroy()
				end)

				return true
			end
		end

		local v32 = pcall

		local function fn50()
			arg:ApplyDescription(result2)
		end

		bit32.bxor(n10, 3739564954)
		local v33 = v32(fn50)
		fn48(parent, v29)

		pcall(function()
			result2:Destroy()
		end)

		return v33
	end

	v28 = bit32.bxor(v25, 28096943)

	cloneEmotesFromUserId = function(arg)
		local n10 = 2330032338
		local n11 = 2414798549
		local n12 = 939098507
		if not emoteMimicState2.active then
			return false
		end
		local currentUserId = tonumber(arg)
		local v29 = bit32.bxor(n12, n11)
		if not currentUserId then
			return false
		end
		local character = v13.Character
		character = character and character:FindFirstChildOfClass("Humanoid")
		if not character then
			return false
		end
		local v30 = emoteMimicState2
		local v31 = emoteMimicState2
		local v32 = bit32.bor(n11, 2672266914)
		v30.applyToken = v31.applyToken + 1
		local applyToken = emoteMimicState2.applyToken
		local n13 = v29 - v32
		bit32.bxor(n10, 3862298847)
		local v33 = fn45(currentUserId)
		if not v33 then
			bit32.bor(v32, 236938912)
			return false
		end

		if applyToken ~= emoteMimicState2.applyToken or not emoteMimicState2.active then
			return false
		end
		local flag = false

		for i = 1, 3 do
			flag = fn49(character, v33)

			if not flag then
				if i < 3 then
					task.wait(0.12)
				end

				continue
			end

			break
		end

		if flag then
			emoteMimicState2.currentUserId = currentUserId
		end

		return flag
	end
end

local cloneEmotesFromTarget

cloneEmotesFromTarget = function(targetInput)
	local n10 = 90539500
	local n11 = 3344841577
	if not emoteMimicState2.active then
		return false
	end
	local v29 = resolveTargetToUserId
	bit32.bxor(n10, 549229617)
	local v30 = v29(targetInput)
	if not v30 then
		return false
	end
	emoteMimicState2.targetInput = targetInput
	bit32.bor(n11, 1210439528)
	return cloneEmotesFromUserId(v30)
end

local fn42

fn42 = function()
	local n10 = 3648192416
	local n11 = 3274730212
	local n12 = 733448439

	if emoteMimicState2.currentUserId then
		local currentUserId = emoteMimicState2.currentUserId
		bit32.band(n12, 2809175107)
		return cloneEmotesFromUserId(currentUserId)
	end

	local v29 = cloneEmotesFromTarget
	local v30 = emoteMimicState2
	bit32.bxor(n11, 4094121557)
	local targetInput = v30.targetInput
	local target

	if targetInput then
		target = targetInput
	else
		local v31 = tbl3
		bit32.bxor(n10, 1488810552)
		target = v31.target
	end

	return v29(target)
end

local useDefaultTarget

useDefaultTarget = function()
	emoteMimicState2.currentUserId = nil
	return cloneEmotesFromTarget(tbl3.target)
end

local cleanup

cleanup = function()
	local n10 = 3689286840
	local n11 = 1874852102
	local n12 = 53869732
	local n13 = 1612302427
	if not emoteMimicState2.active then
		return
	end
	emoteMimicState2.active = false
	local v29 = emoteMimicState2
	local v30 = emoteMimicState2
	local v31 = bit32.bor(n12, n12)
	v29.applyToken = v30.applyToken + 1
	fn39()
	fn40()
	local v32 = result
	bit32.bxor(n11, 1379700500)
	local flag = result

	if v32 then
		flag = result.__EmoteMimicState == emoteMimicState2
	end

	if flag then
		result.__EmoteMimicState = nil
		bit32.bxor(n10, 2652944828)
	end
end

local v29 = table.pack(bit32.band(v26 - 2645867100, 4294967295))
local v30 = table.pack(bit32.band(v29[1], 65535))
local n10
n10 = bit32.band(v30[1] * 58701 + bit32.lshift(bit32.band(v30[1] * 0 + bit32.rshift(v29[1], 16) * 58701, 65535), 16), 4294967295)
emoteMimicState2.cleanup = cleanup

do
	local connection4 = v13.CharacterAdded:Connect(function(character)
		local n11 = 2478040320
		local n12 = 783735255
		local n13 = 4186647240
		local n14 = 7695910
		if not emoteMimicState2.active then
			return
		end
		local v31 = emoteMimicState2
		local applyToken = emoteMimicState2.applyToken
		bit32.bxor(n11, 2249680163)
		v31.applyToken = applyToken + 1
		local v32 = emoteMimicState2
		bit32.lshift(n13, 18)
		local applyToken2 = v32.applyToken
		local flag = not character:WaitForChild("Humanoid", 10) or applyToken2 ~= emoteMimicState2.applyToken

		if not flag then
			flag = not emoteMimicState2.active
			local v33 = table.pack(bit32.band(n14, 4294967295))
			local v34 = table.pack(bit32.band(v33[1], 65535))
			n14 = bit32.bxor(bit32.band(v34[1] * 3785 + bit32.lshift(bit32.band(v34[1] * 0 + bit32.rshift(v33[1], 16) * 3785, 65535), 16), 4294967295), 3360481776)
		end

		if flag then
			return
		end
		local v33 = task
		bit32.bxor(n12, 1982972884)
		local v34 = n14

		v33.spawn(function()
			local n15 = 2124344265
			local n16 = 2526917096
			local n17 = 242603641
			local tbl25 = {}
			local v35 = bit32.bor(bit32.bxor(v34, 3819997540), 1500585107)
			tbl25[1] = 0.2
			tbl25[2] = 0.45
			tbl25[3] = 0.8

			for _, v36 in ipairs(tbl25) do
				if not emoteMimicState2.active or applyToken2 ~= emoteMimicState2.applyToken or not character.Parent then
					return
				end
				task.wait(v36)
				local flag2 = not emoteMimicState2.active

				if not flag2 then
					local v37 = applyToken2
					local v38 = emoteMimicState2
					n15 = bit32.bxor(n15, 2892679967)
					flag2 = v37 ~= v38.applyToken
				end

				if flag2 or not character.Parent then
					return
				end

				if fn42() then
					break
				end
			end

			task.wait(0.9)
			local flag2 = not emoteMimicState2.active
			local n18 = 242603641

			if not flag2 then
				flag2 = applyToken2 ~= emoteMimicState2.applyToken
				n17 = bit32.band(n17, 2938577756) - 4289670111
			end

			local flag3

			if flag2 then
				flag3 = flag2
			else
				local v36 = character
				local v37 = bit32.bxor(n17, v35)
				bit32.bxor(n16, 1116393417)
				flag3 = not v36.Parent
				bit32.bxor(v37, 4227203027)
			end

			if flag3 then
				return
			end
			fn42()
		end)
	end)

	local v31 = table
	local v32 = bit32.bxor(v28, 0)
	local v33 = bit32.bxor(v27, v32)
	v31.insert(emoteMimicState2.connections, connection4)
	local n11 = v33 + 26719467

	if result then
		local emoteMimic = { SetTarget = cloneEmotesFromTarget, SetTargetUserId = cloneEmotesFromUserId, Reapply = fn42 }
		local v34 = bit32.rshift(n10, 5)
		emoteMimic.UseDefaultTarget = useDefaultTarget
		emoteMimic.Cleanup = cleanup
		result.EmoteMimic = emoteMimic
		result.CloneEmotesFromTarget = cloneEmotesFromTarget
		result.CloneEmotesFromUserId = cloneEmotesFromUserId
		result.EmoteMimicCleanup = cleanup
		n10 = v34 - 3140593430
	end

	task.defer(function()
		if not emoteMimicState2.active then
			return
		end
		cloneEmotesFromTarget(tbl3.target)
	end)

	local n12 = n11 // n10
end

do
	local function switchTargetSafe(arg)
		local n11 = 1220853342
		local n12 = 1020903249
		local n13 = 3884060807
		if arg == nil then
			return false
		end
		local v31 = result
		local v32

		if result then
			local outfitCopy = result.OutfitCopy
			n13 = bit32.bxor(n13 - n12, 1294614961)
			v32 = outfitCopy
		else
			v32 = v31
		end

		local flag

		if v32 then
			flag = type(v32.SetTarget) == "function"
			local v33 = bit32.bxor(n12, n13)
			bit32.bxor(n11, 4037220064)
			n12 = v33 + 1635651451
		else
			flag = v32
		end

		local ok2

		if flag then
			local n14 = 242044359

			ok2 = pcall(function()
				v32.SetTarget(arg)
			end)
		else
			local flag2 = result

			if result then
				local v33 = type
				local v34 = result
				local v35 = table.pack(bit32.band(n13, 4294967295))
				local v36 = table.pack(bit32.band(n12, 4294967295))
				local v37 = table.pack(bit32.band(v35[1], 65535))
				local v38 = table.pack(bit32.rshift(v35[1], 16))
				local v39 = table.pack(bit32.band(v36[1], 65535))
				local v40 = bit32.band(v37[1] * v39[1] + bit32.lshift(bit32.band(v37[1] * bit32.rshift(v36[1], 16) + v38[1] * v39[1], 65535), 16), 4294967295)
				flag2 = v33(v34.CopySetUserId) == "function"
				n13 = v40 + 4137098448
			end

			ok2 = false

			if flag2 then
				bit32.bxor(n13, 77283335)
				local n14 = 534008422

				ok2 = pcall(function()
					result.CopySetUserId(arg)
				end)

				local n15 = bit32.band(n12, n13) - 3886436528
			end
		end

		task.defer(function()
			local n14 = 2770319750
			local n15 = 264074763

			if animState.active then
				mimicAnimationsFromTarget(arg)
				n14 = n14 // 87 + 2738476995
			end

			local v33 = emoteMimicState2
			local v34 = table.pack(bit32.band(n15, 4294967295))
			local v35 = table.pack(bit32.band(n14, 4294967295))
			local v36 = table.pack(bit32.band(v34[1], 65535))
			local v37 = table.pack(bit32.rshift(v34[1], 16))
			local v38 = table.pack(bit32.band(v35[1], 65535))
			bit32.band(v36[1] * v38[1] + bit32.lshift(bit32.band(v36[1] * bit32.rshift(v35[1], 16) + v37[1] * v38[1], 65535), 16), 4294967295)

			if v33.active then
				cloneEmotesFromTarget(arg)
			end
		end)

		return ok2
	end

	local function fullComboCleanup()
		pcall(teardown)
		pcall(animCleanup)
		pcall(cleanup)
	end

	if result then
		local n11 = n10 // bit32.bxor(v28, 0)
		result.SwitchTargetSafe = switchTargetSafe
		result.SetTargetSafe = switchTargetSafe
		result.FullComboCleanup = fullComboCleanup
		result.CloneFullCleanup = fullComboCleanup
	end
end

task.defer(function()
	local n11 = 2603205912
	local n12 = 2794798732
	if not animState.active then
		return
	end

	if animState.pinnedTargetUserId then
		mimicAnimationsFromUserId(animState.pinnedTargetUserId)
		bit32.bxor(n12 + 320241508, 524190588)
	else
		local v31 = animState
		local v32 = table.pack(bit32.band(n11, 4294967295))
		local v33 = table.pack(bit32.band(v32[1], 65535))
		local n13 = bit32.band(v33[1] * 30600 + bit32.lshift(bit32.band(v33[1] * 0 + bit32.rshift(v32[1], 16) * 30600, 65535), 16), 4294967295)

		if v31.lastSourceUserId then
			local v34 = mimicAnimationsFromUserId
			local lastSourceUserId = animState.lastSourceUserId
			local v35 = bit32.bor(n12, n13)
			v34(lastSourceUserId)
		elseif animState.lastTargetInput ~= nil then
			local v34 = mimicAnimationsFromTarget
			local v35 = animState
			local v36 = bit32.bxor(n13, n12)
			v34(v35.lastTargetInput)
			n13 = v36 - 2777482636
		else
			mimicAnimationsFromTarget(tbl3.target)
		end

		bit32.bxor(n13, 1139218904)
	end
end)

if animState.settings.autoApplyOnRespawn then
	local connection4 = v13.CharacterAdded:Connect(function(character)
		local n11 = 1630098354
		local n12 = 2849253451
		local n13 = 2500785799
		local n14 = 3060043310
		if not animState.active then
			return
		end
		local v31 = animState
		local v32 = animState
		bit32.bxor(n11, 2059336717)
		local applyToken = v32.applyToken
		bit32.bxor(n12, 258639385)
		v31.applyToken = applyToken + 1
		local v33 = animState
		local n15 = bit32.bxor(n13, n14)
		local applyToken2 = v33.applyToken
		pruneStaleCharacterAnimationState(character)
		local flag = not character:WaitForChild("Humanoid", 10)

		if not flag then
			flag = applyToken2 ~= animState.applyToken
			n15 = bit32.rshift(n15, 22) + 594180124
		end

		if flag or not animState.active then
			return
		end
		local wait = task.wait
		bit32.band(n14, 2915467193)
		wait(0.15)
		if applyToken2 ~= animState.applyToken or not animState.active or not character.Parent then
			return
		end
		local v34 = n15

		task.spawn(function()
			local n16 = 1003136980
			bit32.bxor(v34, 477041359)
			local n17 = 0.25

			for i = 1, 4 do
				if not animState.active or applyToken2 ~= animState.applyToken or not character.Parent then
					return
				end

				if animState.pinnedTargetUserId and mimicAnimationsFromUserId(animState.pinnedTargetUserId, true) then
					return
				end
				local lastSourceUserId = animState.lastSourceUserId

				if lastSourceUserId then
					local v35 = mimicAnimationsFromUserId
					local v36 = animState
					n16 = bit32.bxor(n16, 604955816)
					lastSourceUserId = v35(v36.lastSourceUserId, true)
				end

				if lastSourceUserId then
					return
				end

				if animState.lastTargetInput ~= nil and mimicAnimationsFromTarget(animState.lastTargetInput) then
					return
				end
				task.wait(n17)
				if not animState.active or applyToken2 ~= animState.applyToken then
					return
				end
				n17 = math.min(n17 * 2, 2)
			end
		end)
	end)

	table.insert(animState.connections, connection4)
end
