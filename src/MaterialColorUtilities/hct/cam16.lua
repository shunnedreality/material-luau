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
type Array<T> = LuauPolyfill.Array<T>
local exports = {}
local utils = require(script.Parent.Parent.utils["color_utils"])
local math_ = require(script.Parent.Parent.utils["math_utils"])
local ViewingConditions = require(script.Parent["viewing_conditions"]).ViewingConditions
--[[*
 * CAM16, a color appearance model. Colors are not just defined by their hex
 * code, but rather, a hex code and viewing conditions.
 *
 * CAM16 instances also have coordinates in the CAM16-UCS space, called J*, a*,
 * b*, or jstar, astar, bstar in code. CAM16-UCS is included in the CAM16
 * specification, and should be used when measuring distances between colors.
 *
 * In traditional color spaces, a color can be identified solely by the
 * observer's measurement of the color. Color appearance models such as CAM16
 * also use information about the environment where the color was
 * observed, known as the viewing conditions.
 *
 * For example, white under the traditional assumption of a midday sun white
 * point is accurately measured as a slightly chromatic blue by CAM16. (roughly,
 * hue 203, chroma 3, lightness 100)
 ]]
export type Cam16 = { --[[*
   * CAM16 instances also have coordinates in the CAM16-UCS space, called J*,
   * a*, b*, or jstar, astar, bstar in code. CAM16-UCS is included in the CAM16
   * specification, and is used to measure distances between colors.
   ]]
	distance: (self: Cam16, other: Cam16) -> number,
	--[[*
   * @param argb ARGB representation of a color.
   * @return CAM16 color, assuming the color was viewed in default viewing
   *     conditions.
   ]]
	--[[*
   *  @return ARGB representation of color, assuming the color was viewed in
   *     default viewing conditions, which are near-identical to the default
   *     viewing conditions for sRGB.
   ]]
	toInt: (self: Cam16) -> number,
	--[[*
   * @param viewingConditions Information about the environment where the color
   *     will be viewed.
   * @return ARGB representation of color
   ]]
	viewed: (self: Cam16, viewingConditions: ViewingConditions) -> number,
	--/ Given color expressed in XYZ and viewed in [viewingConditions], convert to
	--/ CAM16.
	--/ XYZ representation of CAM16 seen in [viewingConditions].
	xyzInViewingConditions: (self: Cam16, viewingConditions: ViewingConditions) -> Array<number>,
}
type Cam16_statics = {
	new: (
		hue: number,
		chroma: number,
		j: number,
		q: number,
		m: number,
		s: number,
		jstar: number,
		astar: number,
		bstar: number
	) -> Cam16,
}
local Cam16 = {} :: Cam16 & Cam16_statics;
(Cam16 :: any).__index = Cam16
--[[*
   * All of the CAM16 dimensions can be calculated from 3 of the dimensions, in
   * the following combinations:
   *      -  {j or q} and {c, m, or s} and hue
   *      - jstar, astar, bstar
   * Prefer using a static method that constructs from 3 of those dimensions.
   * This constructor is intended for those methods to use to return all
   * possible dimensions.
   *
   * @param hue
   * @param chroma informally, colorfulness / color intensity. like saturation
   *     in HSL, except perceptually accurate.
   * @param j lightness
   * @param q brightness; ratio of lightness to white point's lightness
   * @param m colorfulness
   * @param s saturation; ratio of chroma to white point's chroma
   * @param jstar CAM16-UCS J coordinate
   * @param astar CAM16-UCS a coordinate
   * @param bstar CAM16-UCS b coordinate
   ]]
function Cam16.new(
	hue: number,
	chroma: number,
	j: number,
	q: number,
	m: number,
	s: number,
	jstar: number,
	astar: number,
	bstar: number
): Cam16
	local self = setmetatable({}, Cam16)
	self.hue = hue
	self.chroma = chroma
	self.j = j
	self.q = q
	self.m = m
	self.s = s
	self.jstar = jstar
	self.astar = astar
	self.bstar = bstar
	return (self :: any) :: Cam16
end
function Cam16:distance(other: Cam16): number
	local dJ = self.jstar - other.jstar
	local dA = self.astar - other.astar
	local dB = self.bstar - other.bstar
	local dEPrime = math.sqrt(dJ * dJ + dA * dA + dB * dB)
	local dE = 1.41 * math.pow(dEPrime, 0.63)
	return dE
end
function Cam16.fromInt(argb: number): Cam16
	return Cam16.fromIntInViewingConditions(argb, ViewingConditions.DEFAULT)
end
function Cam16.fromIntInViewingConditions(argb: number, viewingConditions: ViewingConditions): Cam16
	local red = bit32.arshift(
		bit32.band(argb, 0x00ff0000), --[[ ROBLOX CHECK: `bit32.band` clamps arguments and result to [0,2^32 - 1] ]]
		16
	) --[[ ROBLOX CHECK: `bit32.arshift` clamps arguments and result to [0,2^32 - 1] ]]
	local green = bit32.arshift(
		bit32.band(argb, 0x0000ff00), --[[ ROBLOX CHECK: `bit32.band` clamps arguments and result to [0,2^32 - 1] ]]
		8
	) --[[ ROBLOX CHECK: `bit32.arshift` clamps arguments and result to [0,2^32 - 1] ]]
	local blue = bit32.band(argb, 0x000000ff) --[[ ROBLOX CHECK: `bit32.band` clamps arguments and result to [0,2^32 - 1] ]]
	local redL = utils.linearized(red)
	local greenL = utils.linearized(green)
	local blueL = utils.linearized(blue)
	local x = 0.41233895 * redL + 0.35762064 * greenL + 0.18051042 * blueL
	local y = 0.2126 * redL + 0.7152 * greenL + 0.0722 * blueL
	local z = 0.01932141 * redL + 0.11916382 * greenL + 0.95034478 * blueL
	local rC = 0.401288 * x + 0.650173 * y - 0.051461 * z
	local gC = -0.250268 * x + 1.204414 * y + 0.045854 * z
	local bC = -0.002079 * x + 0.048952 * y + 0.953127 * z
	local rD = viewingConditions.rgbD[
		1 --[[ ROBLOX adaptation: added 1 to array index ]]
	] * rC
	local gD = viewingConditions.rgbD[
		2 --[[ ROBLOX adaptation: added 1 to array index ]]
	] * gC
	local bD = viewingConditions.rgbD[
		3 --[[ ROBLOX adaptation: added 1 to array index ]]
	] * bC
	local rAF = math.pow(viewingConditions.fl * math.abs(rD) / 100.0, 0.42)
	local gAF = math.pow(viewingConditions.fl * math.abs(gD) / 100.0, 0.42)
	local bAF = math.pow(viewingConditions.fl * math.abs(bD) / 100.0, 0.42)
	local rA = math_.signum(rD) * 400.0 * rAF / (rAF + 27.13)
	local gA = math_.signum(gD) * 400.0 * gAF / (gAF + 27.13)
	local bA = math_.signum(bD) * 400.0 * bAF / (bAF + 27.13)
	local a = (11.0 * rA + -12.0 * gA + bA) / 11.0
	local b = (rA + gA - 2.0 * bA) / 9.0
	local u = (20.0 * rA + 20.0 * gA + 21.0 * bA) / 20.0
	local p2 = (40.0 * rA + 20.0 * gA + bA) / 20.0
	local atan2 = math.atan2(b, a)
	local atanDegrees = atan2 * 180.0 / math.pi
	local hue = if atanDegrees
			< 0 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		then atanDegrees + 360.0
		else if atanDegrees
				>= 360 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
			then atanDegrees - 360.0
			else atanDegrees
	local hueRadians = hue * math.pi / 180.0
	local ac = p2 * viewingConditions.nbb
	local j = 100.0 * math.pow(ac / viewingConditions.aw, viewingConditions.c * viewingConditions.z)
	local q = 4.0
		/ viewingConditions.c
		* math.sqrt(j / 100.0)
		* (viewingConditions.aw + 4.0)
		* viewingConditions.fLRoot
	local huePrime = if hue
			< 20.14 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		then hue + 360
		else hue
	local eHue = 0.25 * (math.cos(huePrime * math.pi / 180.0 + 2.0) + 3.8)
	local p1 = 50000.0 / 13.0 * eHue * viewingConditions.nc * viewingConditions.ncb
	local t = p1 * math.sqrt(a * a + b * b) / (u + 0.305)
	local alpha = math.pow(t, 0.9) * math.pow(1.64 - math.pow(0.29, viewingConditions.n), 0.73)
	local c = alpha * math.sqrt(j / 100.0)
	local m = c * viewingConditions.fLRoot
	local s = 50.0 * math.sqrt(alpha * viewingConditions.c / (viewingConditions.aw + 4.0))
	local jstar = (1.0 + 100.0 * 0.007) * j / (1.0 + 0.007 * j)
	local mstar = 1.0 / 0.0228 * math.log(1.0 + 0.0228 * m)
	local astar = mstar * math.cos(hueRadians)
	local bstar = mstar * math.sin(hueRadians)
	return Cam16.new(hue, c, j, q, m, s, jstar, astar, bstar)
end
function Cam16.fromJch(j: number, c: number, h: number): Cam16
	return Cam16:fromJchInViewingConditions(j, c, h, ViewingConditions.DEFAULT)
end
function Cam16.fromJchInViewingConditions(
	j: number,
	c: number,
	h: number,
	viewingConditions: ViewingConditions
): Cam16
	local q = 4.0
		/ viewingConditions.c
		* math.sqrt(j / 100.0)
		* (viewingConditions.aw + 4.0)
		* viewingConditions.fLRoot
	local m = c * viewingConditions.fLRoot
	local alpha = c / math.sqrt(j / 100.0)
	local s = 50.0 * math.sqrt(alpha * viewingConditions.c / (viewingConditions.aw + 4.0))
	local hueRadians = h * math.pi / 180.0
	local jstar = (1.0 + 100.0 * 0.007) * j / (1.0 + 0.007 * j)
	local mstar = 1.0 / 0.0228 * math.log(1.0 + 0.0228 * m)
	local astar = mstar * math.cos(hueRadians)
	local bstar = mstar * math.sin(hueRadians)
	return Cam16.new(h, c, j, q, m, s, jstar, astar, bstar)
end
function Cam16.fromUcs(jstar: number, astar: number, bstar: number): Cam16
	return Cam16:fromUcsInViewingConditions(jstar, astar, bstar, ViewingConditions.DEFAULT)
end
function Cam16.fromUcsInViewingConditions(
	jstar: number,
	astar: number,
	bstar: number,
	viewingConditions: ViewingConditions
): Cam16
	local a = astar
	local b = bstar
	local m = math.sqrt(a * a + b * b)
	local M = (math.exp(m * 0.0228) - 1.0) / 0.0228
	local c = M / viewingConditions.fLRoot
	local h = math.atan2(b, a) * (180.0 / math.pi)
	if
		h
		< 0.0 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
	then
		h += 360.0
	end
	local j = jstar / (1 - (jstar - 100) * 0.007)
	return Cam16:fromJchInViewingConditions(j, c, h, viewingConditions)
end
function Cam16:toInt(): number
	return self:viewed(ViewingConditions.DEFAULT)
end
function Cam16:viewed(viewingConditions: ViewingConditions): number
	local alpha = if self.chroma == 0.0 or self.j == 0.0
		then 0.0
		else self.chroma / math.sqrt(self.j / 100.0)
	local t =
		math.pow(alpha / math.pow(1.64 - math.pow(0.29, viewingConditions.n), 0.73), 1.0 / 0.9)
	local hRad = self.hue * math.pi / 180.0
	local eHue = 0.25 * (math.cos(hRad + 2.0) + 3.8)
	local ac = viewingConditions.aw
		* math.pow(self.j / 100.0, 1.0 / viewingConditions.c / viewingConditions.z)
	local p1 = eHue * (50000.0 / 13.0) * viewingConditions.nc * viewingConditions.ncb
	local p2 = ac / viewingConditions.nbb
	local hSin = math.sin(hRad)
	local hCos = math.cos(hRad)
	local gamma = 23.0 * (p2 + 0.305) * t / (23.0 * p1 + 11.0 * t * hCos + 108.0 * t * hSin)
	local a = gamma * hCos
	local b = gamma * hSin
	local rA = (460.0 * p2 + 451.0 * a + 288.0 * b) / 1403.0
	local gA = (460.0 * p2 - 891.0 * a - 261.0 * b) / 1403.0
	local bA = (460.0 * p2 - 220.0 * a - 6300.0 * b) / 1403.0
	local rCBase = math.max(0, 27.13 * math.abs(rA) / (400.0 - math.abs(rA)))
	local rC = math_.signum(rA) * (100.0 / viewingConditions.fl) * math.pow(rCBase, 1.0 / 0.42)
	local gCBase = math.max(0, 27.13 * math.abs(gA) / (400.0 - math.abs(gA)))
	local gC = math_.signum(gA) * (100.0 / viewingConditions.fl) * math.pow(gCBase, 1.0 / 0.42)
	local bCBase = math.max(0, 27.13 * math.abs(bA) / (400.0 - math.abs(bA)))
	local bC = math_.signum(bA) * (100.0 / viewingConditions.fl) * math.pow(bCBase, 1.0 / 0.42)
	local rF = rC
		/ viewingConditions.rgbD[
			1 --[[ ROBLOX adaptation: added 1 to array index ]]
		]
	local gF = gC
		/ viewingConditions.rgbD[
			2 --[[ ROBLOX adaptation: added 1 to array index ]]
		]
	local bF = bC
		/ viewingConditions.rgbD[
			3 --[[ ROBLOX adaptation: added 1 to array index ]]
		]
	local x = 1.86206786 * rF - 1.01125463 * gF + 0.14918677 * bF
	local y = 0.38752654 * rF + 0.62144744 * gF - 0.00897398 * bF
	local z = -0.01584150 * rF - 0.03412294 * gF + 1.04996444 * bF
	local argb = utils:argbFromXyz(x, y, z)
	return argb
end
function Cam16.fromXyzInViewingConditions(
	x: number,
	y: number,
	z: number,
	viewingConditions: ViewingConditions
): Cam16
	-- Transform XYZ to 'cone'/'rgb' responses
	local rC = 0.401288 * x + 0.650173 * y - 0.051461 * z
	local gC = -0.250268 * x + 1.204414 * y + 0.045854 * z
	local bC = -0.002079 * x + 0.048952 * y + 0.953127 * z
	-- Discount illuminant
	local rD = viewingConditions.rgbD[
		1 --[[ ROBLOX adaptation: added 1 to array index ]]
	] * rC
	local gD = viewingConditions.rgbD[
		2 --[[ ROBLOX adaptation: added 1 to array index ]]
	] * gC
	local bD = viewingConditions.rgbD[
		3 --[[ ROBLOX adaptation: added 1 to array index ]]
	] * bC
	-- chromatic adaptation
	local rAF = math.pow(viewingConditions.fl * math.abs(rD) / 100.0, 0.42)
	local gAF = math.pow(viewingConditions.fl * math.abs(gD) / 100.0, 0.42)
	local bAF = math.pow(viewingConditions.fl * math.abs(bD) / 100.0, 0.42)
	local rA = math_.signum(rD) * 400.0 * rAF / (rAF + 27.13)
	local gA = math_.signum(gD) * 400.0 * gAF / (gAF + 27.13)
	local bA = math_.signum(bD) * 400.0 * bAF / (bAF + 27.13)
	-- redness-greenness
	local a = (11.0 * rA + -12.0 * gA + bA) / 11.0
	-- yellowness-blueness
	local b = (rA + gA - 2.0 * bA) / 9.0
	-- auxiliary components
	local u = (20.0 * rA + 20.0 * gA + 21.0 * bA) / 20.0
	local p2 = (40.0 * rA + 20.0 * gA + bA) / 20.0
	-- hue
	local atan2 = math.atan2(b, a)
	local atanDegrees = atan2 * 180.0 / math.pi
	local hue = if atanDegrees
			< 0 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		then atanDegrees + 360.0
		else if atanDegrees
				>= 360 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
			then atanDegrees - 360
			else atanDegrees
	local hueRadians = hue * math.pi / 180.0
	-- achromatic response to color
	local ac = p2 * viewingConditions.nbb
	-- CAM16 lightness and brightness
	local J = 100.0 * math.pow(ac / viewingConditions.aw, viewingConditions.c * viewingConditions.z)
	local Q = 4.0
		/ viewingConditions.c
		* math.sqrt(J / 100.0)
		* (viewingConditions.aw + 4.0)
		* viewingConditions.fLRoot
	local huePrime = if hue
			< 20.14 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		then hue + 360
		else hue
	local eHue = 1.0 / 4.0 * (math.cos(huePrime * math.pi / 180.0 + 2.0) + 3.8)
	local p1 = 50000.0 / 13.0 * eHue * viewingConditions.nc * viewingConditions.ncb
	local t = p1 * math.sqrt(a * a + b * b) / (u + 0.305)
	local alpha = math.pow(t, 0.9) * math.pow(1.64 - math.pow(0.29, viewingConditions.n), 0.73)
	-- CAM16 chroma, colorfulness, chroma
	local C = alpha * math.sqrt(J / 100.0)
	local M = C * viewingConditions.fLRoot
	local s = 50.0 * math.sqrt(alpha * viewingConditions.c / (viewingConditions.aw + 4.0))
	-- CAM16-UCS components
	local jstar = (1.0 + 100.0 * 0.007) * J / (1.0 + 0.007 * J)
	local mstar = math.log(1.0 + 0.0228 * M) / 0.0228
	local astar = mstar * math.cos(hueRadians)
	local bstar = mstar * math.sin(hueRadians)
	return Cam16.new(hue, C, J, Q, M, s, jstar, astar, bstar)
end
function Cam16:xyzInViewingConditions(viewingConditions: ViewingConditions): Array<number>
	local alpha = if self.chroma == 0.0 or self.j == 0.0
		then 0.0
		else self.chroma / math.sqrt(self.j / 100.0)
	local t =
		math.pow(alpha / math.pow(1.64 - math.pow(0.29, viewingConditions.n), 0.73), 1.0 / 0.9)
	local hRad = self.hue * math.pi / 180.0
	local eHue = 0.25 * (math.cos(hRad + 2.0) + 3.8)
	local ac = viewingConditions.aw
		* math.pow(self.j / 100.0, 1.0 / viewingConditions.c / viewingConditions.z)
	local p1 = eHue * (50000.0 / 13.0) * viewingConditions.nc * viewingConditions.ncb
	local p2 = ac / viewingConditions.nbb
	local hSin = math.sin(hRad)
	local hCos = math.cos(hRad)
	local gamma = 23.0 * (p2 + 0.305) * t / (23.0 * p1 + 11 * t * hCos + 108.0 * t * hSin)
	local a = gamma * hCos
	local b = gamma * hSin
	local rA = (460.0 * p2 + 451.0 * a + 288.0 * b) / 1403.0
	local gA = (460.0 * p2 - 891.0 * a - 261.0 * b) / 1403.0
	local bA = (460.0 * p2 - 220.0 * a - 6300.0 * b) / 1403.0
	local rCBase = math.max(0, 27.13 * math.abs(rA) / (400.0 - math.abs(rA)))
	local rC = math_.signum(rA) * (100.0 / viewingConditions.fl) * math.pow(rCBase, 1.0 / 0.42)
	local gCBase = math.max(0, 27.13 * math.abs(gA) / (400.0 - math.abs(gA)))
	local gC = math_.signum(gA) * (100.0 / viewingConditions.fl) * math.pow(gCBase, 1.0 / 0.42)
	local bCBase = math.max(0, 27.13 * math.abs(bA) / (400.0 - math.abs(bA)))
	local bC = math_.signum(bA) * (100.0 / viewingConditions.fl) * math.pow(bCBase, 1.0 / 0.42)
	local rF = rC
		/ viewingConditions.rgbD[
			1 --[[ ROBLOX adaptation: added 1 to array index ]]
		]
	local gF = gC
		/ viewingConditions.rgbD[
			2 --[[ ROBLOX adaptation: added 1 to array index ]]
		]
	local bF = bC
		/ viewingConditions.rgbD[
			3 --[[ ROBLOX adaptation: added 1 to array index ]]
		]
	local x = 1.86206786 * rF - 1.01125463 * gF + 0.14918677 * bF
	local y = 0.38752654 * rF + 0.62144744 * gF - 0.00897398 * bF
	local z = -0.01584150 * rF - 0.03412294 * gF + 1.04996444 * bF
	return { x, y, z }
end
exports.Cam16 = Cam16
return exports
