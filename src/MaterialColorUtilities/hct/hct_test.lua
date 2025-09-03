-- ROBLOX NOTE: no upstream
--[[*
 * @license
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ]]
local Packages = script.Parent.Parent.Parent
local LuauPolyfill = require(Packages.LuauPolyfill)
local Array = LuauPolyfill.Array
require(Packages.jasmine)
local colorUtils = require(script.Parent.Parent.utils["color_utils"])
local Cam16 = require(script.Parent["cam16"]).Cam16
local Hct = require(script.Parent["hct"]).Hct
local ViewingConditions = require(script.Parent["viewing_conditions"]).ViewingConditions
local RED = 0xffff0000
local GREEN = 0xff00ff00
local BLUE = 0xff0000ff
local WHITE = 0xffffffff
local BLACK = 0xff000000
describe("CAM to ARGB", function()
	it("red", function()
		local cam = Cam16.fromInt(RED)
		expect(cam.hue).toBeCloseTo(27.408, 3)
		expect(cam.chroma).toBeCloseTo(113.358, 3)
		expect(cam.j).toBeCloseTo(46.445, 3)
		expect(cam.m).toBeCloseTo(89.494, 3)
		expect(cam.s).toBeCloseTo(91.890, 3)
		expect(cam.q).toBeCloseTo(105.989, 3)
	end)
	it("green", function()
		local cam = Cam16.fromInt(GREEN)
		expect(cam.hue).toBeCloseTo(142.140, 3)
		expect(cam.chroma).toBeCloseTo(108.410, 3)
		expect(cam.j).toBeCloseTo(79.332, 3)
		expect(cam.m).toBeCloseTo(85.588, 3)
		expect(cam.s).toBeCloseTo(78.605, 3)
		expect(cam.q).toBeCloseTo(138.520, 3)
	end)
	it("blue", function()
		local cam = Cam16.fromInt(BLUE)
		expect(cam.hue).toBeCloseTo(282.788, 3)
		expect(cam.chroma).toBeCloseTo(87.231, 3)
		expect(cam.j).toBeCloseTo(25.466, 3)
		expect(cam.m).toBeCloseTo(68.867, 3)
		expect(cam.s).toBeCloseTo(93.675, 3)
		expect(cam.q).toBeCloseTo(78.481, 3)
	end)
	it("white", function()
		local cam = Cam16.fromInt(WHITE)
		expect(cam.hue).toBeCloseTo(209.492, 3)
		expect(cam.chroma).toBeCloseTo(2.869, 3)
		expect(cam.j).toBeCloseTo(100.0, 3)
		expect(cam.m).toBeCloseTo(2.265, 3)
		expect(cam.s).toBeCloseTo(12.068, 3)
		expect(cam.q).toBeCloseTo(155.521, 3)
	end)
	it("black", function()
		local cam = Cam16.fromInt(BLACK)
		expect(cam.hue).toBeCloseTo(0.0, 3)
		expect(cam.chroma).toBeCloseTo(0.0, 3)
		expect(cam.j).toBeCloseTo(0.0, 3)
		expect(cam.m).toBeCloseTo(0.0, 3)
		expect(cam.s).toBeCloseTo(0.0, 3)
		expect(cam.q).toBeCloseTo(0.0, 3)
	end)
end)
describe("CAM to ARGB to CAM", function()
	it("red", function()
		local cam = Cam16.fromInt(RED)
		local argb = cam:toInt()
		expect(argb).toEqual(RED)
	end)
	it("green", function()
		local cam = Cam16.fromInt(GREEN)
		local argb = cam:toInt()
		expect(argb).toEqual(GREEN)
	end)
	it("blue", function()
		local cam = Cam16.fromInt(BLUE)
		local argb = cam:toInt()
		expect(argb).toEqual(BLUE)
	end)
end)
describe("ARGB to HCT", function()
	it("green", function()
		local hct = Hct.fromInt(GREEN)
		expect(hct.hue).toBeCloseTo(142.139, 2)
		expect(hct.chroma).toBeCloseTo(108.410, 2)
		expect(hct.tone).toBeCloseTo(87.737, 2)
	end)
	it("blue", function()
		local hct = Hct.fromInt(BLUE)
		expect(hct.hue).toBeCloseTo(282.788, 2)
		expect(hct.chroma).toBeCloseTo(87.230, 2)
		expect(hct.tone).toBeCloseTo(32.302, 2)
	end)
	it("blue tone 90", function()
		local hct = Array.from(Hct, 282.788, 87.230, 90.0) --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
		expect(hct.hue).toBeCloseTo(282.239, 2)
		expect(hct.chroma).toBeCloseTo(19.144, 2)
		expect(hct.tone).toBeCloseTo(90.035, 2)
	end)
end)
describe("viewing conditions", function()
	it("default", function()
		local vc = ViewingConditions.DEFAULT
		expect(vc.n).toBeCloseTo(0.184, 3)
		expect(vc.aw).toBeCloseTo(29.981, 3)
		expect(vc.nbb).toBeCloseTo(1.017, 3)
		expect(vc.ncb).toBeCloseTo(1.017, 3)
		expect(vc.c).toBeCloseTo(0.69, 3)
		expect(vc.nc).toBeCloseTo(1.0, 3)
		expect(vc.rgbD[
			1 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBeCloseTo(1.021, 3)
		expect(vc.rgbD[
			2 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBeCloseTo(0.986, 3)
		expect(vc.rgbD[
			3 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBeCloseTo(0.934, 3)
		expect(vc.fl).toBeCloseTo(0.388, 3)
		expect(vc.fLRoot).toBeCloseTo(0.789, 3)
		expect(vc.z).toBeCloseTo(1.909, 3)
	end)
end)
local function colorIsOnBoundary(argb: number): boolean
	return colorUtils:redFromArgb(argb) == 0
		or colorUtils:redFromArgb(argb) == 255
		or colorUtils:greenFromArgb(argb) == 0
		or colorUtils:greenFromArgb(argb) == 255
		or colorUtils:blueFromArgb(argb) == 0
		or colorUtils:blueFromArgb(argb) == 255
end
describe("CamSolver", function()
	it("returns a sufficiently close color", function()
		do
			local hue = 15
			while
				hue
				< 360 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
			do
				do
					local chroma = 0
					while
						chroma
						<= 100 --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]]
					do
						do
							local tone = 20
							while
								tone
								<= 80 --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]]
							do
								local hctColor = Array.from(Hct, hue, chroma, tone) --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
								if
									chroma
									> 0 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
								then
									expect(math.abs(hctColor.hue - hue)).toBeLessThanOrEqual(4.0)
								end
								expect(hctColor.chroma).toBeGreaterThanOrEqual(0)
								expect(hctColor.chroma).toBeLessThanOrEqual(chroma + 2.5)
								if
									hctColor.chroma
									< chroma - 2.5 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
								then
									expect(colorIsOnBoundary(hctColor:toInt())).toBe(true)
								end
								expect(math.abs(hctColor.tone - tone)).toBeLessThanOrEqual(0.5)
								tone += 10
							end
						end
						chroma += 10
					end
				end
				hue += 30
			end
		end
	end)
end)
