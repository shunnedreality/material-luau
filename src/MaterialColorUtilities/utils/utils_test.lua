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
require(Packages.jasmine)
local colorUtils = require(script.Parent["color_utils"])
local mathUtils = require(script.Parent["math_utils"])
describe("argbFromRgb", function()
	it("returns correct value for black", function()
		expect(colorUtils:argbFromRgb(255, 255, 255)).toBe(0xffffffff)
		expect(colorUtils:argbFromRgb(255, 255, 255)).toBe(4294967295)
	end)
	it("returns correct value for white", function()
		expect(colorUtils:argbFromRgb(0, 0, 0)).toBe(0xff000000)
		expect(colorUtils:argbFromRgb(0, 0, 0)).toBe(4278190080)
	end)
	it("returns correct value for random color", function()
		expect(colorUtils:argbFromRgb(50, 150, 250)).toBe(0xff3296fa)
		expect(colorUtils:argbFromRgb(50, 150, 250)).toBe(4281505530)
	end)
end)
local function rotationDirection(from: number, to: number): number
	local a = to - from
	local b = to - from + 360.0
	local c = to - from - 360.0
	local aAbs = math.abs(a)
	local bAbs = math.abs(b)
	local cAbs = math.abs(c)
	if
		aAbs <= bAbs --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]]
		and aAbs <= cAbs --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]]
	then
		return if a
				>= 0.0 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
			then 1.0
			else -1.0
	elseif
		bAbs <= aAbs --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]]
		and bAbs <= cAbs --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]]
	then
		return if b
				>= 0.0 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
			then 1.0
			else -1.0
	else
		return if c
				>= 0.0 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
			then 1.0
			else -1.0
	end
end
describe("rotationDirection", function()
	it("is identical to the original implementation", function()
		do
			local from = 0.0
			while
				from
				< 360.0 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
			do
				do
					local to = 7.5
					while
						to
						< 360.0 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
					do
						local expectedAnswer = rotationDirection(from, to)
						local actualAnswer = mathUtils:rotationDirection(from, to)
						expect(actualAnswer).toBe(expectedAnswer)
						expect(math.abs(actualAnswer)).toBe(1.0)
						to += 15.0
					end
				end
				from += 15.0
			end
		end
	end)
end)
describe("yFromLstar", function()
	it("satisfies given values", function()
		expect(colorUtils.yFromLstar(0.0)).toBeCloseTo(0.0, 5)
		expect(colorUtils.yFromLstar(0.1)).toBeCloseTo(0.0110705, 5)
		expect(colorUtils.yFromLstar(0.2)).toBeCloseTo(0.0221411, 5)
		expect(colorUtils.yFromLstar(0.3)).toBeCloseTo(0.0332116, 5)
		expect(colorUtils.yFromLstar(0.4)).toBeCloseTo(0.0442822, 5)
		expect(colorUtils.yFromLstar(0.5)).toBeCloseTo(0.0553528, 5)
		expect(colorUtils.yFromLstar(1.0)).toBeCloseTo(0.1107056, 5)
		expect(colorUtils.yFromLstar(2.0)).toBeCloseTo(0.2214112, 5)
		expect(colorUtils.yFromLstar(3.0)).toBeCloseTo(0.3321169, 5)
		expect(colorUtils.yFromLstar(4.0)).toBeCloseTo(0.4428225, 5)
		expect(colorUtils.yFromLstar(5.0)).toBeCloseTo(0.5535282, 5)
		expect(colorUtils.yFromLstar(8.0)).toBeCloseTo(0.8856451, 5)
		expect(colorUtils.yFromLstar(10.0)).toBeCloseTo(1.1260199, 5)
		expect(colorUtils.yFromLstar(15.0)).toBeCloseTo(1.9085832, 5)
		expect(colorUtils.yFromLstar(20.0)).toBeCloseTo(2.9890524, 5)
		expect(colorUtils.yFromLstar(25.0)).toBeCloseTo(4.4154767, 5)
		expect(colorUtils.yFromLstar(30.0)).toBeCloseTo(6.2359055, 5)
		expect(colorUtils.yFromLstar(40.0)).toBeCloseTo(11.2509737, 5)
		expect(colorUtils.yFromLstar(50.0)).toBeCloseTo(18.4186518, 5)
		expect(colorUtils.yFromLstar(60.0)).toBeCloseTo(28.1233342, 5)
		expect(colorUtils.yFromLstar(70.0)).toBeCloseTo(40.7494157, 5)
		expect(colorUtils.yFromLstar(80.0)).toBeCloseTo(56.6812907, 5)
		expect(colorUtils.yFromLstar(90.0)).toBeCloseTo(76.3033539, 5)
		expect(colorUtils.yFromLstar(95.0)).toBeCloseTo(87.6183294, 5)
		expect(colorUtils.yFromLstar(99.0)).toBeCloseTo(97.4360239, 5)
		expect(colorUtils.yFromLstar(100.0)).toBeCloseTo(100.0, 5)
	end)
	it("is inverse of lstarFromY", function()
		do
			local y = 0.0
			while
				y
				<= 100.0 --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]]
			do
				local lstar = colorutils.lstarFromY(y)
				local reconstructedY = colorUtils.yFromLstar(lstar)
				expect(reconstructedY).toBeCloseTo(y, 8)
				y += 0.1
			end
		end
	end)
end)
describe("lstarFromY", function()
	it("satisfies given values", function()
		expect(colorutils.lstarFromY(0.0)).toBeCloseTo(0.0, 5)
		expect(colorutils.lstarFromY(0.1)).toBeCloseTo(0.9032962, 5)
		expect(colorutils.lstarFromY(0.2)).toBeCloseTo(1.8065925, 5)
		expect(colorutils.lstarFromY(0.3)).toBeCloseTo(2.7098888, 5)
		expect(colorutils.lstarFromY(0.4)).toBeCloseTo(3.6131851, 5)
		expect(colorutils.lstarFromY(0.5)).toBeCloseTo(4.5164814, 5)
		expect(colorutils.lstarFromY(0.8856451)).toBeCloseTo(8.0, 5)
		expect(colorutils.lstarFromY(1.0)).toBeCloseTo(8.9914424, 5)
		expect(colorutils.lstarFromY(2.0)).toBeCloseTo(15.4872443, 5)
		expect(colorutils.lstarFromY(3.0)).toBeCloseTo(20.0438970, 5)
		expect(colorutils.lstarFromY(4.0)).toBeCloseTo(23.6714419, 5)
		expect(colorutils.lstarFromY(5.0)).toBeCloseTo(26.7347653, 5)
		expect(colorutils.lstarFromY(10.0)).toBeCloseTo(37.8424304, 5)
		expect(colorutils.lstarFromY(15.0)).toBeCloseTo(45.6341970, 5)
		expect(colorutils.lstarFromY(20.0)).toBeCloseTo(51.8372115, 5)
		expect(colorutils.lstarFromY(25.0)).toBeCloseTo(57.0754208, 5)
		expect(colorutils.lstarFromY(30.0)).toBeCloseTo(61.6542222, 5)
		expect(colorutils.lstarFromY(40.0)).toBeCloseTo(69.4695307, 5)
		expect(colorutils.lstarFromY(50.0)).toBeCloseTo(76.0692610, 5)
		expect(colorutils.lstarFromY(60.0)).toBeCloseTo(81.8381891, 5)
		expect(colorutils.lstarFromY(70.0)).toBeCloseTo(86.9968642, 5)
		expect(colorutils.lstarFromY(80.0)).toBeCloseTo(91.6848609, 5)
		expect(colorutils.lstarFromY(90.0)).toBeCloseTo(95.9967686, 5)
		expect(colorutils.lstarFromY(95.0)).toBeCloseTo(98.0335184, 5)
		expect(colorutils.lstarFromY(99.0)).toBeCloseTo(99.6120372, 5)
		expect(colorutils.lstarFromY(100.0)).toBeCloseTo(100.0, 5)
	end)
	it("is inverse of yFromLstar", function()
		do
			local lstar = 0.0
			while
				lstar
				<= 100.0 --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]]
			do
				local y = colorUtils.yFromLstar(lstar)
				local reconstructedLstar = colorutils.lstarFromY(y)
				expect(reconstructedLstar).toBeCloseTo(lstar, 8)
				lstar += 0.1
			end
		end
	end)
end)
