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
local Map = LuauPolyfill.Map
local Math = LuauPolyfill.Math
local exports = {}
local Hct = require(script.Parent.Parent.hct["hct"]).Hct
--[[*
 *  A convenience class for retrieving colors that are constant in hue and
 *  chroma, but vary in tone.
 ]]
--[[*
 * Key color is a color that represents the hue and chroma of a tonal palette
 ]]
type KeyColor = { --[[*
   * Creates a key color from a [hue] and a [chroma].
   * The key color is the first tone, starting from T50, matching the given hue
   * and chroma.
   *
   * @return Key color [Hct]
   ]]
	create: (self: KeyColor) -> Hct,
	-- Find the maximum chroma for a given tone
}
type KeyColor_private = { --
	-- *** PUBLIC ***
	--
	create: (self: KeyColor_private) -> Hct,
	--
	-- *** PRIVATE ***
	--
	-- Cache that maps tone to max chroma to avoid duplicated HCT calculation.
	chromaCache: any,
	maxChromaValue: number,
	maxChroma: (self: KeyColor_private, tone: number) -> number,
}
type KeyColor_statics = { new: (hue: number, requestedChroma: number) -> KeyColor }
local KeyColor = {} :: KeyColor & KeyColor_statics
local KeyColor_private = KeyColor :: KeyColor_private & KeyColor_statics;
(KeyColor :: any).__index = KeyColor
function KeyColor_private.new(hue: number, requestedChroma: number): KeyColor
	local self = setmetatable({}, KeyColor)
	self.hue = hue
	self.requestedChroma = requestedChroma
	self.chromaCache = Map.new()
	self.maxChromaValue = 200.0
	return (self :: any) :: KeyColor
end
function KeyColor_private:create(): Hct
	-- Pivot around T50 because T50 has the most chroma available, on
	-- average. Thus it is most likely to have a direct answer.
	local pivotTone = 50
	local toneStepSize = 1
	-- Epsilon to accept values slightly higher than the requested chroma.
	local epsilon = 0.01
	-- Binary search to find the tone that can provide a chroma that is closest
	-- to the requested chroma.
	local lowerTone = 0
	local upperTone = 100
	while
		lowerTone
		< upperTone --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
	do
		local midTone = math.floor((lowerTone + upperTone) / 2);

		local isAscending = self:maxChroma(midTone) < self:maxChroma(midTone + toneStepSize) --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		local sufficientChroma = self:maxChroma(midTone) >= self.requestedChroma - epsilon --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
		if Boolean.toJSBoolean(sufficientChroma) then
			-- Either range [lowerTone, midTone] or [midTone, upperTone] has
			-- the answer, so search in the range that is closer the pivot tone.
			if
				math.abs(lowerTone - pivotTone)
				< math.abs(upperTone - pivotTone) --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
			then
				upperTone = midTone
			else
				if lowerTone == midTone then
					return Array.from(Hct, self.hue, self.requestedChroma, lowerTone) --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
				end
				lowerTone = midTone
			end
		else
			-- As there is no sufficient chroma in the midTone, follow the direction
			-- to the chroma peak.
			if Boolean.toJSBoolean(isAscending) then
				lowerTone = midTone + toneStepSize
			else
				-- Keep midTone for potential chroma peak.
				upperTone = midTone
			end
		end
	end
	return Array.from(Hct, self.hue, self.requestedChroma, lowerTone) --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
end
function KeyColor_private:maxChroma(tone: number): number
	if Boolean.toJSBoolean(self.chromaCache:has(tone)) then
		return self.chromaCache:get(tone) :: any
	end
	local chroma = Hct.from(self.hue, self.maxChromaValue, tone) --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
		:chroma();

	self.chromaCache:set(tone, chroma)
	return chroma
end

export type TonalPalette = { --[[*
   * @param tone HCT tone, measured from 0 to 100.
   * @return ARGB representation of a color with that tone.
   ]]
	tone: (self: TonalPalette, tone: number) -> number,
	--[[*
   * @param tone HCT tone.
   * @return HCT representation of a color with that tone.
   ]]
	getHct: (self: TonalPalette, tone: number) -> Hct,
}
type TonalPalette_private = { --
	-- *** PUBLIC ***
	--
	tone: (self: TonalPalette_private, tone: number) -> number,
	getHct: (self: TonalPalette_private, tone: number) -> Hct,
	--
	-- *** PRIVATE ***
	--
	cache: any,
	--[[*
   * @param argb ARGB representation of a color
   * @return Tones matching that color's hue and chroma.
   ]]
	averageArgb: (self: TonalPalette_private, argb1: number, argb2: number) -> number,
}
type TonalPalette_statics = { new: (hue: number, chroma: number, keyColor: Hct) -> TonalPalette }
local TonalPalette = {} :: TonalPalette & TonalPalette_statics
local TonalPalette_private = TonalPalette :: TonalPalette_private & TonalPalette_statics;
(TonalPalette :: any).__index = TonalPalette
function TonalPalette_private.new(hue: number, chroma: number, keyColor: Hct): TonalPalette
	local self = setmetatable({}, TonalPalette)
	self.hue = hue
	self.chroma = chroma
	self.keyColor = keyColor
	self.cache = Map.new()
	return (self :: any) :: TonalPalette
end
function TonalPalette_private.fromInt(argb: number): TonalPalette
	local hct = Hct.fromInt(argb)
	return TonalPalette:fromHct(hct)
end
function TonalPalette_private.fromHct(hct: Hct)
	return TonalPalette.new(hct.hue, hct.chroma, hct)
end
function TonalPalette_private.fromHueAndChroma(hue: number, chroma: number): TonalPalette
	local keyColor = KeyColor.new(hue, chroma):create()
	return TonalPalette.new(hue, chroma, keyColor)
end
function TonalPalette_private:tone(tone: number): number
	local argb = self.cache:get(tone)
	if argb == nil then
		if
			Boolean.toJSBoolean(
				tone == 99 --[[ ROBLOX CHECK: loose equality used upstream ]]
					and Hct.isYellow(self.hue)
			)
		then
			argb = self:averageArgb(self:tone(98), self:tone(100))
		else
			argb = Hct.from(self.hue, self.chroma, tone) --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
				:toInt()
		end
		self.cache:set(tone, argb)
	end
	return argb
end
function TonalPalette_private:getHct(tone: number): Hct
	return Hct.fromInt(self:tone(tone))
end
function TonalPalette_private:averageArgb(argb1: number, argb2: number): number
	local red1 = bit32.band(
		bit32.rshift(argb1, 16), --[[ ROBLOX CHECK: `bit32.rshift` clamps arguments and result to [0,2^32 - 1] ]]
		0xff
	) --[[ ROBLOX CHECK: `bit32.band` clamps arguments and result to [0,2^32 - 1] ]]
	local green1 = bit32.band(
		bit32.rshift(argb1, 8), --[[ ROBLOX CHECK: `bit32.rshift` clamps arguments and result to [0,2^32 - 1] ]]
		0xff
	) --[[ ROBLOX CHECK: `bit32.band` clamps arguments and result to [0,2^32 - 1] ]]
	local blue1 = bit32.band(argb1, 0xff) --[[ ROBLOX CHECK: `bit32.band` clamps arguments and result to [0,2^32 - 1] ]]
	local red2 = bit32.band(
		bit32.rshift(argb2, 16), --[[ ROBLOX CHECK: `bit32.rshift` clamps arguments and result to [0,2^32 - 1] ]]
		0xff
	) --[[ ROBLOX CHECK: `bit32.band` clamps arguments and result to [0,2^32 - 1] ]]
	local green2 = bit32.band(
		bit32.rshift(argb2, 8), --[[ ROBLOX CHECK: `bit32.rshift` clamps arguments and result to [0,2^32 - 1] ]]
		0xff
	) --[[ ROBLOX CHECK: `bit32.band` clamps arguments and result to [0,2^32 - 1] ]]
	local blue2 = bit32.band(argb2, 0xff) --[[ ROBLOX CHECK: `bit32.band` clamps arguments and result to [0,2^32 - 1] ]]
	local red = Math.round((red1 + red2) / 2) --[[ ROBLOX NOTE: Math.round is currently not supported by the Luau Math polyfill, please add your own implementation or file a ticket on the same ]]
	local green = Math.round((green1 + green2) / 2) --[[ ROBLOX NOTE: Math.round is currently not supported by the Luau Math polyfill, please add your own implementation or file a ticket on the same ]]
	local blue = Math.round((blue1 + blue2) / 2) --[[ ROBLOX NOTE: Math.round is currently not supported by the Luau Math polyfill, please add your own implementation or file a ticket on the same ]]
	return bit32.rshift(
		bit32.bor(
			bit32.bor(
				bit32.bor(
					bit32.lshift(255, 24), --[[ ROBLOX CHECK: `bit32.lshift` clamps arguments and result to [0,2^32 - 1] ]]
					bit32.lshift(
						bit32.band(red, 255), --[[ ROBLOX CHECK: `bit32.band` clamps arguments and result to [0,2^32 - 1] ]]
						16
					) --[[ ROBLOX CHECK: `bit32.lshift` clamps arguments and result to [0,2^32 - 1] ]]
				), --[[ ROBLOX CHECK: `bit32.bor` clamps arguments and result to [0,2^32 - 1] ]]
				bit32.lshift(
					bit32.band(green, 255), --[[ ROBLOX CHECK: `bit32.band` clamps arguments and result to [0,2^32 - 1] ]]
					8
				) --[[ ROBLOX CHECK: `bit32.lshift` clamps arguments and result to [0,2^32 - 1] ]]
			), --[[ ROBLOX CHECK: `bit32.bor` clamps arguments and result to [0,2^32 - 1] ]]
			bit32.band(blue, 255) --[[ ROBLOX CHECK: `bit32.band` clamps arguments and result to [0,2^32 - 1] ]]
		), --[[ ROBLOX CHECK: `bit32.bor` clamps arguments and result to [0,2^32 - 1] ]]
		0
	) --[[ ROBLOX CHECK: `bit32.rshift` clamps arguments and result to [0,2^32 - 1] ]]
end
exports.TonalPalette = TonalPalette

return exports
