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
local Boolean = LuauPolyfill.Boolean
local Error = LuauPolyfill.Error
type Array<T> = LuauPolyfill.Array<T>
local Promise = require(Packages.Promise)
local RegExp = require(Packages.RegExp)
local exports = {}
local QuantizerCelebi =
	require(script.Parent.Parent.quantize["quantizer_celebi"]).QuantizerCelebi
local Score = require(script.Parent.Parent.score["score"]).Score
local argbFromRgb = require(script.Parent["color_utils"]).argbFromRgb
--[[*
 * Get the source color from an image.
 *
 * @param image The image element
 * @return Source color - the color most suitable for creating a UI theme
 ]]
local function sourceColorFromImage(image: HTMLImageElement)
	return Promise.resolve():andThen(function()
		-- Convert Image data to Pixel Array
		local imageBytes = Promise.new(function(resolve, reject)
			local canvas = document:createElement("canvas")
			local context = canvas:getContext("2d")
			if not Boolean.toJSBoolean(context) then
				reject(Error.new("Could not get canvas context"))
				return
			end
			local function loadCallback()
				canvas.width = image.width
				canvas.height = image.height
				context:drawImage(image, 0, 0)
				local rect = { 0, 0, image.width, image.height }
				local area = image.dataset["area"]
				if
					Boolean.toJSBoolean(
						if Boolean.toJSBoolean(area)
							then RegExp("^\\d+(\\s*,\\s*\\d+){3}$"):test(area)
							else area
					)
				then
					rect = Array.map(area:split(RegExp("\\s*,\\s*")), function(s)
						-- tslint:disable-next-line:ban
						return tonumber(s, 10)
					end) --[[ ROBLOX CHECK: check if 'area.split(/\s*,\s*/)' is an Array ]]
				end
				local sx, sy, sw, sh = table.unpack(rect, 1, 4)
				resolve(context:getImageData(sx, sy, sw, sh).data)
			end
			local function errorCallback()
				reject(Error.new("Image load failed"))
			end
			if Boolean.toJSBoolean(image.complete) then
				loadCallback()
			else
				image.onload = loadCallback
				image.onerror = errorCallback
			end
		end):expect()
		return sourceColorFromImageBytes(imageBytes)
	end)
end
exports.sourceColorFromImage = sourceColorFromImage
--[[*
 * Get the source color from image bytes.
 *
 * @param imageBytes The image bytes
 * @return Source color - the color most suitable for creating a UI theme
 ]]
local function sourceColorFromImageBytes(imageBytes: Uint8ClampedArray)
	-- Convert Image data to Pixel Array
	local pixels: Array<number> = {}
	do
		local i = 0
		while
			i
			< imageBytes.length --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		do
			local r = imageBytes[tostring(i)]
			local g = imageBytes[tostring(i + 1)]
			local b = imageBytes[tostring(i + 2)]
			local a = imageBytes[tostring(i + 3)]
			if
				a
				< 255 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
			then
				i += 4
				continue
			end
			local argb = argbFromRgb(r, g, b)
			table.insert(pixels, argb) --[[ ROBLOX CHECK: check if 'pixels' is an Array ]]
			i += 4
		end
	end
	-- Convert Pixels to Material Colors
	local result = QuantizerCelebi:quantize(pixels, 128)
	local ranked = Score:score(result)
	local top = ranked[
		1 --[[ ROBLOX adaptation: added 1 to array index ]]
	]
	return top
end
exports.sourceColorFromImageBytes = sourceColorFromImageBytes
return exports
