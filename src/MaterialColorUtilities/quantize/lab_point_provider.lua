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
local PointProvider = require(script.Parent["point_provider"]).PointProvider
--[[*
 * Provides conversions needed for K-Means quantization. Converting input to
 * points, and converting the final state of the K-Means algorithm to colors.
 ]]
export type LabPointProvider = { --[[*
   * Convert a color represented in ARGB to a 3-element array of L*a*b*
   * coordinates of the color.
   ]]
	fromInt: (self: LabPointProvider, argb: number) -> Array<number>,
	--[[*
   * Convert a 3-element array to a color represented in ARGB.
   ]]
	toInt: (self: LabPointProvider, point: Array<number>) -> number,
	--[[*
   * Standard CIE 1976 delta E formula also takes the square root, unneeded
   * here. This method is used by quantization algorithms to compare distance,
   * and the relative ordering is the same, with or without a square root.
   *
   * This relatively minor optimization is helpful because this method is
   * called at least once for each pixel in an image.
   ]]
	distance: (self: LabPointProvider, from: Array<number>, to: Array<number>) -> number,
}
type LabPointProvider_statics = { new: () -> LabPointProvider }
local LabPointProvider = {} :: LabPointProvider & LabPointProvider_statics;
(LabPointProvider :: any).__index = LabPointProvider
function LabPointProvider.new(): LabPointProvider
	local self = setmetatable({}, LabPointProvider)
	return (self :: any) :: LabPointProvider
end
function LabPointProvider:fromInt(argb: number): Array<number>
	return utils:labFromArgb(argb)
end
function LabPointProvider:toInt(point: Array<number>): number
	return utils:argbFromLab(
		point[
			1 --[[ ROBLOX adaptation: added 1 to array index ]]
		],
		point[
			2 --[[ ROBLOX adaptation: added 1 to array index ]]
		],
		point[
			3 --[[ ROBLOX adaptation: added 1 to array index ]]
		]
	)
end
function LabPointProvider:distance(from: Array<number>, to: Array<number>): number
	local dL = from[
		1 --[[ ROBLOX adaptation: added 1 to array index ]]
	] - to[
			1 --[[ ROBLOX adaptation: added 1 to array index ]]
		]
	local dA = from[
		2 --[[ ROBLOX adaptation: added 1 to array index ]]
	] - to[
			2 --[[ ROBLOX adaptation: added 1 to array index ]]
		]
	local dB = from[
		3 --[[ ROBLOX adaptation: added 1 to array index ]]
	] - to[
			3 --[[ ROBLOX adaptation: added 1 to array index ]]
		]
	return dL * dL + dA * dA + dB * dB
end
exports.LabPointProvider = LabPointProvider
return exports
