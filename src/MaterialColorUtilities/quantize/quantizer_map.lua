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
local Map = LuauPolyfill.Map
type Array<T> = LuauPolyfill.Array<T>
type Map<T, U> = LuauPolyfill.Map<T, U>
local exports = {}
local utils = require(script.Parent.Parent.utils["color_utils"])
--[[*
 * Quantizes an image into a map, with keys of ARGB colors, and values of the
 * number of times that color appears in the image.
 ]]
-- material_color_utilities is designed to have a consistent API across
-- platforms and modular components that can be moved around easily. Using a
-- class as a namespace facilitates this.
--
-- tslint:disable-next-line:class-as-namespace
export type QuantizerMap = {}
type QuantizerMap_statics = { new: () -> QuantizerMap }
local QuantizerMap = {} :: QuantizerMap & QuantizerMap_statics;
(QuantizerMap :: any).__index = QuantizerMap
function QuantizerMap.new(): QuantizerMap
	local self = setmetatable({}, QuantizerMap)
	return (self :: any) :: QuantizerMap
end
function QuantizerMap.quantize(pixels: Array<number>): Map<number, number>
	local countByColor = Map.new()
	do
		local i = 0
		while
			i
			< pixels.length --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		do
			local pixel = pixels[tostring(i)]
			local alpha = utils:alphaFromArgb(pixel)
			if
				alpha
				< 255 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
			then
				i += 1
				continue
			end
			countByColor:set(pixel, (function()
				local ref = countByColor:get(pixel)
				return if ref ~= nil then ref else 0
			end)() + 1)
			i += 1
		end
	end
	return countByColor
end
exports.QuantizerMap = QuantizerMap
return exports
