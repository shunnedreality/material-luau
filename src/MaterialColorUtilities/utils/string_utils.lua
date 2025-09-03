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
local exports = {}
local colorUtils = require(script.Parent["color_utils"])
--[[*
 * Utility methods for hexadecimal representations of colors.
 ]]
--[[*
 * @param argb ARGB representation of a color.
 * @return Hex string representing color, ex. #ff0000 for red.
 ]]
local function hexFromArgb(argb: number)
	local r = colorUtils:redFromArgb(argb)
	local g = colorUtils:greenFromArgb(argb)
	local b = colorUtils:blueFromArgb(argb)
	local outParts = { r:toString(16), g:toString(16), b:toString(16) }
	-- Pad single-digit output values
	for _, ref in outParts:entries() do
		local i, part = table.unpack(ref, 1, 2)
		if part.length == 1 then
			outParts[tostring(i)] = "0" .. tostring(part)
		end
	end
	return "#"
		.. tostring(Array.join(outParts, "") --[[ ROBLOX CHECK: check if 'outParts' is an Array ]])
end
exports.hexFromArgb = hexFromArgb
--[[*
 * @param hex String representing color as hex code. Accepts strings with or
 *     without leading #, and string representing the color using 3, 6, or 8
 *     hex characters.
 * @return ARGB representation of color.
 ]]
local function argbFromHex(hex: string)
	hex = hex:gsub("#", "");
	local isThree = #hex == 3
	local isSix = #hex == 6
	local isEight = #hex == 8
	if
		not Boolean.toJSBoolean(isThree)
		and not Boolean.toJSBoolean(isSix)
		and not Boolean.toJSBoolean(isEight)
	then
		error(Error.new("unexpected hex " .. tostring(hex)))
	end
	local r = 0
	local g = 0
	local b = 0
	if Boolean.toJSBoolean(isThree) then
		r = parseIntHex(
			string.rep(string.sub(hex, 0, 1) --[[ ROBLOX CHECK: check if 'hex' is an Array ]], 2) --[[ ROBLOX CHECK: check if 'hex.slice(0, 1)' is a string ]]
		)
		g = parseIntHex(
			string.rep(string.sub(hex, 1, 2) --[[ ROBLOX CHECK: check if 'hex' is an Array ]], 2) --[[ ROBLOX CHECK: check if 'hex.slice(1, 2)' is a string ]]
		)
		b = parseIntHex(
			string.rep(string.sub(hex, 2, 3) --[[ ROBLOX CHECK: check if 'hex' is an Array ]], 2) --[[ ROBLOX CHECK: check if 'hex.slice(2, 3)' is a string ]]
		)
	elseif Boolean.toJSBoolean(isSix) then
		r = parseIntHex(string.sub(hex, 0, 2) --[[ ROBLOX CHECK: check if 'hex' is an Array ]])
		g = parseIntHex(string.sub(hex, 2, 4) --[[ ROBLOX CHECK: check if 'hex' is an Array ]])
		b = parseIntHex(string.sub(hex, 4, 6) --[[ ROBLOX CHECK: check if 'hex' is an Array ]])
	elseif Boolean.toJSBoolean(isEight) then
		r = parseIntHex(string.sub(hex, 2, 4) --[[ ROBLOX CHECK: check if 'hex' is an Array ]])
		g = parseIntHex(string.sub(hex, 4, 6) --[[ ROBLOX CHECK: check if 'hex' is an Array ]])
		b = parseIntHex(string.sub(hex, 6, 8) --[[ ROBLOX CHECK: check if 'hex' is an Array ]])
	end
	return bit32.rshift(
		bit32.bor(
			bit32.bor(
				bit32.bor(
					bit32.lshift(255, 24), --[[ ROBLOX CHECK: `bit32.lshift` clamps arguments and result to [0,2^32 - 1] ]]
					bit32.lshift(
						bit32.band(r, 0x0ff), --[[ ROBLOX CHECK: `bit32.band` clamps arguments and result to [0,2^32 - 1] ]]
						16
					) --[[ ROBLOX CHECK: `bit32.lshift` clamps arguments and result to [0,2^32 - 1] ]]
				), --[[ ROBLOX CHECK: `bit32.bor` clamps arguments and result to [0,2^32 - 1] ]]
				bit32.lshift(
					bit32.band(g, 0x0ff), --[[ ROBLOX CHECK: `bit32.band` clamps arguments and result to [0,2^32 - 1] ]]
					8
				) --[[ ROBLOX CHECK: `bit32.lshift` clamps arguments and result to [0,2^32 - 1] ]]
			), --[[ ROBLOX CHECK: `bit32.bor` clamps arguments and result to [0,2^32 - 1] ]]
			bit32.band(b, 0x0ff) --[[ ROBLOX CHECK: `bit32.band` clamps arguments and result to [0,2^32 - 1] ]]
		), --[[ ROBLOX CHECK: `bit32.bor` clamps arguments and result to [0,2^32 - 1] ]]
		0
	) --[[ ROBLOX CHECK: `bit32.rshift` clamps arguments and result to [0,2^32 - 1] ]]
end
exports.argbFromHex = argbFromHex
function parseIntHex(value: string)
	-- tslint:disable-next-line:ban
	return tonumber(value, 16)
end
return exports
