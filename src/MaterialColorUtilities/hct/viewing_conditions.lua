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
local Boolean = LuauPolyfill.Boolean
local Math = LuauPolyfill.Math
type Array<T> = LuauPolyfill.Array<T>
local exports = {}
local utils = require(script.Parent.Parent.utils["color_utils"])
local math_ = require(script.Parent.Parent.utils["math_utils"])
--[[*
 * In traditional color spaces, a color can be identified solely by the
 * observer's measurement of the color. Color appearance models such as CAM16
 * also use information about the environment where the color was
 * observed, known as the viewing conditions.
 *
 * For example, white under the traditional assumption of a midday sun white
 * point is accurately measured as a slightly chromatic blue by CAM16. (roughly,
 * hue 203, chroma 3, lightness 100)
 *
 * This class caches intermediate values of the CAM16 conversion process that
 * depend only on viewing conditions, enabling speed ups.
 ]]
export type ViewingConditions = {
	n: number,
	aw: number,
	nbb: number,
	ncb: number,
	c: number,
	nc: number,
	rgbD: Array<number>,
	fl: number,
	fLRoot: number,
	z: number,
}
type ViewingConditions_private = { --
	-- *** PUBLIC ***
	--
	n: number,
	aw: number,
	nbb: number,
	ncb: number,
	c: number,
	nc: number,
	rgbD: Array<number>,
	fl: number,
	fLRoot: number,
	z: number,
}
type ViewingConditions_statics = {
	new: (
		n: number,
		aw: number,
		nbb: number,
		ncb: number,
		c: number,
		nc: number,
		rgbD: Array<number>,
		fl: number,
		fLRoot: number,
		z: number
	) -> ViewingConditions,
}
local ViewingConditions = {} :: ViewingConditions & ViewingConditions_statics
local ViewingConditions_private =
	ViewingConditions :: ViewingConditions_private & ViewingConditions_statics;
(ViewingConditions :: any).__index = ViewingConditions;

local function cbrt(n: number)
	return n ^ (1/3)
end

--[[*
   * Parameters are intermediate values of the CAM16 conversion process. Their
   * names are shorthand for technical color science terminology, this class
   * would not benefit from documenting them individually. A brief overview
   * is available in the CAM16 specification, and a complete overview requires
   * a color science textbook, such as Fairchild's Color Appearance Models.
   ]]
function ViewingConditions_private.new(
	n: number,
	aw: number,
	nbb: number,
	ncb: number,
	c: number,
	nc: number,
	rgbD: Array<number>,
	fl: number,
	fLRoot: number,
	z: number
): ViewingConditions
	local self = setmetatable({}, ViewingConditions)
	self.n = n
	self.aw = aw
	self.nbb = nbb
	self.ncb = ncb
	self.c = c
	self.nc = nc
	self.rgbD = rgbD
	self.fl = fl
	self.fLRoot = fLRoot
	self.z = z
	return (self :: any) :: ViewingConditions
end
function ViewingConditions_private.make(
	whitePoint_: any?,
	adaptingLuminance_: any?,
	backgroundLstar_: number?,
	surround_: number?,
	discountingIlluminant_: boolean?
): ViewingConditions
	local whitePoint: any = if whitePoint_ ~= nil then whitePoint_ else utils:whitePointD65()
	local adaptingLuminance: any = if adaptingLuminance_ ~= nil
		then adaptingLuminance_
		else 200.0 / math.pi * utils.yFromLstar(50.0) / 100.0
	local backgroundLstar: number = if backgroundLstar_ ~= nil then backgroundLstar_ else 50.0
	local surround: number = if surround_ ~= nil then surround_ else 2.0
	local discountingIlluminant: boolean = if discountingIlluminant_ ~= nil
		then discountingIlluminant_
		else false
	local xyz = whitePoint;

	local rW = xyz[
		1 --[[ ROBLOX adaptation: added 1 to array index ]]
	] * 0.401288
		+ xyz[
			2 --[[ ROBLOX adaptation: added 1 to array index ]]
		] * 0.650173
		+ xyz[
			3 --[[ ROBLOX adaptation: added 1 to array index ]]
		] * -0.051461
	local gW = xyz[
		1 --[[ ROBLOX adaptation: added 1 to array index ]]
	] * -0.250268
		+ xyz[
			2 --[[ ROBLOX adaptation: added 1 to array index ]]
		] * 1.204414
		+ xyz[
			3 --[[ ROBLOX adaptation: added 1 to array index ]]
		] * 0.045854
	local bW = xyz[
		1 --[[ ROBLOX adaptation: added 1 to array index ]]
	] * -0.002079
		+ xyz[
			2 --[[ ROBLOX adaptation: added 1 to array index ]]
		] * 0.048952
		+ xyz[
			3 --[[ ROBLOX adaptation: added 1 to array index ]]
		] * 0.953127
	local f = 0.8 + surround / 10.0
	local c = if f
			>= 0.9 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
		then math_.lerp(0.59, 0.69, (f - 0.9) * 10.0)
		else math_.lerp(0.525, 0.59, (f - 0.8) * 10.0)
	local d = if Boolean.toJSBoolean(discountingIlluminant)
		then 1.0
		else f * (1.0 - 1.0 / 3.6 * math.exp((-adaptingLuminance - 42.0) / 92.0))
	d = if d
			> 1.0 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
		then 1.0
		else if d
				< 0.0 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
			then 0.0
			else d
	local nc = f
	local rgbD =
		{ d * (100.0 / rW) + 1.0 - d, d * (100.0 / gW) + 1.0 - d, d * (100.0 / bW) + 1.0 - d }
	local k = 1.0 / (5.0 * adaptingLuminance + 1.0)
	local k4 = k * k * k * k
	local k4F = 1.0 - k4
	local fl = k4 * adaptingLuminance + 0.1 * k4F * k4F * cbrt(5.0 * adaptingLuminance) --[[ ROBLOX NOTE: Math.cbrt is currently not supported by the Luau Math polyfill, please add your own implementation or file a ticket on the same ]]
	local n = utils.yFromLstar(backgroundLstar)
		/ whitePoint[
			2 --[[ ROBLOX adaptation: added 1 to array index ]]
		]
	local z = 1.48 + math.sqrt(n)
	local nbb = 0.725 / math.pow(n, 0.2)
	local ncb = nbb
	local rgbAFactors = {
		math.pow(fl * rgbD[
			1 --[[ ROBLOX adaptation: added 1 to array index ]]
		] * rW / 100.0, 0.42),
		math.pow(fl * rgbD[
			2 --[[ ROBLOX adaptation: added 1 to array index ]]
		] * gW / 100.0, 0.42),
		math.pow(fl * rgbD[
			3 --[[ ROBLOX adaptation: added 1 to array index ]]
		] * bW / 100.0, 0.42),
	}
	local rgbA = {
		400.0
			* rgbAFactors[
				1 --[[ ROBLOX adaptation: added 1 to array index ]]
			]
			/ (
				rgbAFactors[
					1 --[[ ROBLOX adaptation: added 1 to array index ]]
				] + 27.13
			),
		400.0
			* rgbAFactors[
				2 --[[ ROBLOX adaptation: added 1 to array index ]]
			]
			/ (
				rgbAFactors[
					2 --[[ ROBLOX adaptation: added 1 to array index ]]
				] + 27.13
			),
		400.0
			* rgbAFactors[
				3 --[[ ROBLOX adaptation: added 1 to array index ]]
			]
			/ (
				rgbAFactors[
					3 --[[ ROBLOX adaptation: added 1 to array index ]]
				] + 27.13
			),
	}
	local aw = (
		2.0 * rgbA[
			1 --[[ ROBLOX adaptation: added 1 to array index ]]
		]
		+ rgbA[
			2 --[[ ROBLOX adaptation: added 1 to array index ]]
		]
		+ 0.05 * rgbA[
			3 --[[ ROBLOX adaptation: added 1 to array index ]]
		]
	) * nbb
	return ViewingConditions.new(n, aw, nbb, ncb, c, nc, rgbD, fl, math.pow(fl, 0.25), z)
end

ViewingConditions.DEFAULT = ViewingConditions.make();

exports.ViewingConditions = ViewingConditions
return exports
