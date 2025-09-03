-- ROBLOX NOTE: no upstream
--[[*
 * @license
 * Copyright 2025 Google LLC
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
local Object = LuauPolyfill.Object
local exports = {}
--local Contrast = require(script.Parent.Parent.contrast["contrast"]).Contrast
local Hct = require(script.Parent.Parent.hct["hct"]).Hct
--local TonalPalette = require(script.Parent.Parent.palettes["tonal_palette"]).TonalPalette
local math_ = require(script.Parent.Parent.utils["math_utils"])
local ColorSpecDelegateImpl2021 =
	require(script.Parent["color_spec_2021"]).ColorSpecDelegateImpl2021
local ContrastCurve = require(script.Parent["contrast_curve"]).ContrastCurve
local dynamic_colorModule = require(script.Parent.dynamic_color)
local DynamicColor = dynamic_colorModule.DynamicColor
local extendSpecVersion = dynamic_colorModule.extendSpecVersion
local ToneDeltaPair = require(script.Parent["tone_delta_pair"]).ToneDeltaPair
local Variant = require(script.Parent["variant"]).Variant
--[[*
 * Returns the maximum tone for a given chroma in the palette.
 *
 * @param palette The tonal palette to use.
 * @param lowerBound The lower bound of the tone.
 * @param upperBound The upper bound of the tone.
 ]]
local function tMaxC(
	palette: TonalPalette,
	lowerBound_: number?,
	upperBound_: number?,
	chromaMultiplier_: number?
): number
	local lowerBound: number = if lowerBound_ ~= nil then lowerBound_ else 0
	local upperBound: number = if upperBound_ ~= nil then upperBound_ else 100
	local chromaMultiplier: number = if chromaMultiplier_ ~= nil then chromaMultiplier_ else 1
	local answer = findBestToneForChroma(palette.hue, palette.chroma * chromaMultiplier, 100, true)
	return math_:clampDouble(lowerBound, upperBound, answer)
end
--[[*
 * Returns the minimum tone for a given chroma in the palette.
 *
 * @param palette The tonal palette to use.
 * @param lowerBound The lower bound of the tone.
 * @param upperBound The upper bound of the tone.
 ]]
local function tMinC(palette: TonalPalette, lowerBound_: number?, upperBound_: number?): number
	local lowerBound: number = if lowerBound_ ~= nil then lowerBound_ else 0
	local upperBound: number = if upperBound_ ~= nil then upperBound_ else 100
	local answer = findBestToneForChroma(palette.hue, palette.chroma, 0, false)
	return math_:clampDouble(lowerBound, upperBound, answer)
end
--[[*
 * Searches for the best tone with a given chroma from a given tone at a
 * specific hue.
 *
 * @param hue The given hue.
 * @param chroma The target chroma.
 * @param tone The tone to start with.
 * @param byDecreasingTone Whether to search for lower tones.
 ]]
local function findBestToneForChroma(
	hue: number,
	chroma: number,
	tone: number,
	byDecreasingTone: boolean
): number
	local answer = tone
	local bestCandidate = Array.from(Hct, hue, chroma, answer) --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
	while
		bestCandidate.chroma
		< chroma --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
	do
		if
			tone < 0 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
			or tone > 100 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
		then
			break
		end
		tone += if Boolean.toJSBoolean(byDecreasingTone) then -1.0 else 1.0
		local newCandidate = Array.from(Hct, hue, chroma, tone) --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
		if
			bestCandidate.chroma
			< newCandidate.chroma --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		then
			bestCandidate = newCandidate
			answer = tone
		end
	end
	return answer
end
--[[*
 * Returns the contrast curve for a given default contrast.
 *
 * @param defaultContrast The default contrast to use.
 ]]
local function getCurve(defaultContrast: number): ContrastCurve
	if defaultContrast == 1.5 then
		return ContrastCurve.new(1.5, 1.5, 3, 4.5)
	elseif defaultContrast == 3 then
		return ContrastCurve.new(3, 3, 4.5, 7)
	elseif defaultContrast == 4.5 then
		return ContrastCurve.new(4.5, 4.5, 7, 11)
	elseif defaultContrast == 6 then
		return ContrastCurve.new(6, 6, 7, 11)
	elseif defaultContrast == 7 then
		return ContrastCurve.new(7, 7, 11, 21)
	elseif defaultContrast == 9 then
		return ContrastCurve.new(9, 9, 11, 21)
	elseif defaultContrast == 11 then
		return ContrastCurve.new(11, 11, 21, 21)
	elseif defaultContrast == 21 then
		return ContrastCurve.new(21, 21, 21, 21)
	else
		-- Shouldn't happen.
		return ContrastCurve.new(defaultContrast, defaultContrast, 7, 21)
	end
end

local super = ColorSpecDelegateImpl2021.new();

--[[*
 * A delegate for the dynamic color spec of a DynamicScheme in the 2025 spec.
 ]]
export type ColorSpecDelegateImpl2025 = ColorSpecDelegateImpl2021 & { --//////////////////////////////////////////////////////////////
	-- Surfaces [S]                                               //
	--//////////////////////////////////////////////////////////////
	surface: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	surfaceDim: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	surfaceBright: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	surfaceContainerLowest: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	surfaceContainerLow: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	surfaceContainer: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	surfaceContainerHigh: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	surfaceContainerHighest: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	onSurface: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	onSurfaceVariant: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	outline: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	outlineVariant: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	inverseSurface: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	inverseOnSurface: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	--//////////////////////////////////////////////////////////////
	-- Primaries [P]                                              //
	--//////////////////////////////////////////////////////////////
	primary: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	primaryDim: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	onPrimary: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	primaryContainer: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	onPrimaryContainer: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	primaryFixed: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	primaryFixedDim: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	onPrimaryFixed: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	onPrimaryFixedVariant: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	inversePrimary: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	--//////////////////////////////////////////////////////////////
	-- Secondaries [Q]                                            //
	--//////////////////////////////////////////////////////////////
	secondary: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	secondaryDim: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	onSecondary: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	secondaryContainer: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	onSecondaryContainer: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	secondaryFixed: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	secondaryFixedDim: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	onSecondaryFixed: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	onSecondaryFixedVariant: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	--//////////////////////////////////////////////////////////////
	-- Tertiaries [T]                                             //
	--//////////////////////////////////////////////////////////////
	tertiary: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	tertiaryDim: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	onTertiary: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	tertiaryContainer: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	onTertiaryContainer: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	tertiaryFixed: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	tertiaryFixedDim: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	onTertiaryFixed: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	onTertiaryFixedVariant: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	--//////////////////////////////////////////////////////////////
	-- Errors [E]                                                 //
	--//////////////////////////////////////////////////////////////
	error_: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	errorDim: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	onError: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	errorContainer: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	onErrorContainer: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	--///////////////////////////////////////////////////////////////
	-- Remapped Colors                                             //
	--///////////////////////////////////////////////////////////////
	surfaceVariant: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	surfaceTint: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	background: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
	onBackground: (self: ColorSpecDelegateImpl2025) -> DynamicColor,
}
type ColorSpecDelegateImpl2025_statics = { new: () -> ColorSpecDelegateImpl2025 }
local ColorSpecDelegateImpl2025 = (
	setmetatable({}, { __index = ColorSpecDelegateImpl2021 }) :: any
) :: ColorSpecDelegateImpl2025 & ColorSpecDelegateImpl2025_statics;
(ColorSpecDelegateImpl2025 :: any).__index = ColorSpecDelegateImpl2025
function ColorSpecDelegateImpl2025.new(): ColorSpecDelegateImpl2025
	local self = setmetatable({}, ColorSpecDelegateImpl2025) --[[ ROBLOX TODO: super constructor may be used ]]
	return (self :: any) :: ColorSpecDelegateImpl2025
end
function ColorSpecDelegateImpl2025:surface(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "surface",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			ColorSpecDelegateImpl2021.new().surface.tone(s);
			if s.platform == "phone" then
				if Boolean.toJSBoolean(s.isDark) then
					return 4
				else
					if Boolean.toJSBoolean(Hct:isYellow(s.neutralPalette.hue)) then
						return 99
					elseif s.variant == Variant.VIBRANT then
						return 97
					else
						return 98
					end
				end
			else
				return 0
			end
		end,
		isBackground = true,
	})

	return extendSpecVersion(
		super:surface(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:surfaceDim(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "surface_dim",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			if Boolean.toJSBoolean(s.isDark) then
				return 4
			else
				if Boolean.toJSBoolean(Hct:isYellow(s.neutralPalette.hue)) then
					return 90
				elseif s.variant == Variant.VIBRANT then
					return 85
				else
					return 87
				end
			end
		end,
		isBackground = true,
		chromaMultiplier = function(s)
			if not Boolean.toJSBoolean(s.isDark) then
				if s.variant == Variant.NEUTRAL then
					return 2.5
				elseif s.variant == Variant.TONAL_SPOT then
					return 1.7
				elseif s.variant == Variant.EXPRESSIVE then
					return if Boolean.toJSBoolean(Hct:isYellow(s.neutralPalette.hue))
						then 2.7
						else 1.75
				elseif s.variant == Variant.VIBRANT then
					return 1.36
				end
			end
			return 1
		end,
	})
	return extendSpecVersion(
		super:surfaceDim(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:surfaceBright(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "surface_bright",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			if Boolean.toJSBoolean(s.isDark) then
				return 18
			else
				if Boolean.toJSBoolean(Hct:isYellow(s.neutralPalette.hue)) then
					return 99
				elseif s.variant == Variant.VIBRANT then
					return 97
				else
					return 98
				end
			end
		end,
		isBackground = true,
		chromaMultiplier = function(s)
			if Boolean.toJSBoolean(s.isDark) then
				if s.variant == Variant.NEUTRAL then
					return 2.5
				elseif s.variant == Variant.TONAL_SPOT then
					return 1.7
				elseif s.variant == Variant.EXPRESSIVE then
					return if Boolean.toJSBoolean(Hct:isYellow(s.neutralPalette.hue))
						then 2.7
						else 1.75
				elseif s.variant == Variant.VIBRANT then
					return 1.36
				end
			end
			return 1
		end,
	})
	return extendSpecVersion(
		super:surfaceBright(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:surfaceContainerLowest(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "surface_container_lowest",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark) then 0 else 100
		end,
		isBackground = true,
	})
	return extendSpecVersion(
		super:surfaceContainerLowest(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:surfaceContainerLow(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "surface_container_low",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			if s.platform == "phone" then
				if Boolean.toJSBoolean(s.isDark) then
					return 6
				else
					if Boolean.toJSBoolean(Hct:isYellow(s.neutralPalette.hue)) then
						return 98
					elseif s.variant == Variant.VIBRANT then
						return 95
					else
						return 96
					end
				end
			else
				return 15
			end
		end,
		isBackground = true,
		chromaMultiplier = function(s)
			if s.platform == "phone" then
				if s.variant == Variant.NEUTRAL then
					return 1.3
				elseif s.variant == Variant.TONAL_SPOT then
					return 1.25
				elseif s.variant == Variant.EXPRESSIVE then
					return if Boolean.toJSBoolean(Hct:isYellow(s.neutralPalette.hue))
						then 1.3
						else 1.15
				elseif s.variant == Variant.VIBRANT then
					return 1.08
				end
			end
			return 1
		end,
	})
	return extendSpecVersion(
		super:surfaceContainerLow(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:surfaceContainer(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "surface_container",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			if s.platform == "phone" then
				if Boolean.toJSBoolean(s.isDark) then
					return 9
				else
					if Boolean.toJSBoolean(Hct:isYellow(s.neutralPalette.hue)) then
						return 96
					elseif s.variant == Variant.VIBRANT then
						return 92
					else
						return 94
					end
				end
			else
				return 20
			end
		end,
		isBackground = true,
		chromaMultiplier = function(s)
			if s.platform == "phone" then
				if s.variant == Variant.NEUTRAL then
					return 1.6
				elseif s.variant == Variant.TONAL_SPOT then
					return 1.4
				elseif s.variant == Variant.EXPRESSIVE then
					return if Boolean.toJSBoolean(Hct:isYellow(s.neutralPalette.hue))
						then 1.6
						else 1.3
				elseif s.variant == Variant.VIBRANT then
					return 1.15
				end
			end
			return 1
		end,
	})
	return extendSpecVersion(
		super:surfaceContainer(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:surfaceContainerHigh(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "surface_container_high",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			if s.platform == "phone" then
				if Boolean.toJSBoolean(s.isDark) then
					return 12
				else
					if Boolean.toJSBoolean(Hct:isYellow(s.neutralPalette.hue)) then
						return 94
					elseif s.variant == Variant.VIBRANT then
						return 90
					else
						return 92
					end
				end
			else
				return 25
			end
		end,
		isBackground = true,
		chromaMultiplier = function(s)
			if s.platform == "phone" then
				if s.variant == Variant.NEUTRAL then
					return 1.9
				elseif s.variant == Variant.TONAL_SPOT then
					return 1.5
				elseif s.variant == Variant.EXPRESSIVE then
					return if Boolean.toJSBoolean(Hct:isYellow(s.neutralPalette.hue))
						then 1.95
						else 1.45
				elseif s.variant == Variant.VIBRANT then
					return 1.22
				end
			end
			return 1
		end,
	})
	return extendSpecVersion(
		super:surfaceContainerHigh(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:surfaceContainerHighest(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "surface_container_highest",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			if Boolean.toJSBoolean(s.isDark) then
				return 15
			else
				if Boolean.toJSBoolean(Hct:isYellow(s.neutralPalette.hue)) then
					return 92
				elseif s.variant == Variant.VIBRANT then
					return 88
				else
					return 90
				end
			end
		end,
		isBackground = true,
		chromaMultiplier = function(s)
			if s.variant == Variant.NEUTRAL then
				return 2.2
			elseif s.variant == Variant.TONAL_SPOT then
				return 1.7
			elseif s.variant == Variant.EXPRESSIVE then
				return if Boolean.toJSBoolean(Hct:isYellow(s.neutralPalette.hue)) then 2.3 else 1.6
			elseif s.variant == Variant.VIBRANT then
				return 1.29
			else
				-- default
				return 1
			end
		end,
	})
	return extendSpecVersion(
		super:surfaceContainerHighest(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:onSurface(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "on_surface",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			if s.variant == Variant.VIBRANT then
				return tMaxC(s.neutralPalette, 0, 100, 1.1)
			else
				-- For all other variants, the initial tone should be the default
				-- tone, which is the same as the background color.
				return DynamicColor:getInitialToneFromBackground(function(s)
					return if s.platform == "phone"
						then self:highestSurface(s)
						else self:surfaceContainerHigh()
				end)(s)
			end
		end,
		chromaMultiplier = function(s)
			if s.platform == "phone" then
				if s.variant == Variant.NEUTRAL then
					return 2.2
				elseif s.variant == Variant.TONAL_SPOT then
					return 1.7
				elseif s.variant == Variant.EXPRESSIVE then
					return if Boolean.toJSBoolean(Hct:isYellow(s.neutralPalette.hue))
						then if Boolean.toJSBoolean(s.isDark) then 3.0 else 2.3
						else 1.6
				end
			end
			return 1
		end,
		background = function(s)
			return if s.platform == "phone"
				then self:highestSurface(s)
				else self:surfaceContainerHigh()
		end,
		contrastCurve = function(s)
			return if Boolean.toJSBoolean(s.isDark) then getCurve(11) else getCurve(9)
		end,
	})
	return extendSpecVersion(
		super:onSurface(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:onSurfaceVariant(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "on_surface_variant",
		palette = function(s)
			return s.neutralPalette
		end,
		chromaMultiplier = function(s)
			if s.platform == "phone" then
				if s.variant == Variant.NEUTRAL then
					return 2.2
				elseif s.variant == Variant.TONAL_SPOT then
					return 1.7
				elseif s.variant == Variant.EXPRESSIVE then
					return if Boolean.toJSBoolean(Hct:isYellow(s.neutralPalette.hue))
						then if Boolean.toJSBoolean(s.isDark) then 3.0 else 2.3
						else 1.6
				end
			end
			return 1
		end,
		background = function(s)
			return if s.platform == "phone"
				then self:highestSurface(s)
				else self:surfaceContainerHigh()
		end,
		contrastCurve = function(s)
			return if s.platform == "phone"
				then if Boolean.toJSBoolean(s.isDark) then getCurve(6) else getCurve(4.5)
				else getCurve(7)
		end,
	})
	return extendSpecVersion(
		super:onSurfaceVariant(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:outline(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "outline",
		palette = function(s)
			return s.neutralPalette
		end,
		chromaMultiplier = function(s)
			if s.platform == "phone" then
				if s.variant == Variant.NEUTRAL then
					return 2.2
				elseif s.variant == Variant.TONAL_SPOT then
					return 1.7
				elseif s.variant == Variant.EXPRESSIVE then
					return if Boolean.toJSBoolean(Hct:isYellow(s.neutralPalette.hue))
						then if Boolean.toJSBoolean(s.isDark) then 3.0 else 2.3
						else 1.6
				end
			end
			return 1
		end,
		background = function(s)
			return if s.platform == "phone"
				then self:highestSurface(s)
				else self:surfaceContainerHigh()
		end,
		contrastCurve = function(s)
			return if s.platform == "phone" then getCurve(3) else getCurve(4.5)
		end,
	})
	return extendSpecVersion(
		super:outline(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:outlineVariant(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "outline_variant",
		palette = function(s)
			return s.neutralPalette
		end,
		chromaMultiplier = function(s)
			if s.platform == "phone" then
				if s.variant == Variant.NEUTRAL then
					return 2.2
				elseif s.variant == Variant.TONAL_SPOT then
					return 1.7
				elseif s.variant == Variant.EXPRESSIVE then
					return if Boolean.toJSBoolean(Hct:isYellow(s.neutralPalette.hue))
						then if Boolean.toJSBoolean(s.isDark) then 3.0 else 2.3
						else 1.6
				end
			end
			return 1
		end,
		background = function(s)
			return if s.platform == "phone"
				then self:highestSurface(s)
				else self:surfaceContainerHigh()
		end,
		contrastCurve = function(s)
			return if s.platform == "phone" then getCurve(1.5) else getCurve(3)
		end,
	})
	return extendSpecVersion(
		super:outlineVariant(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:inverseSurface(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "inverse_surface",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark) then 98 else 4
		end,
		isBackground = true,
	})
	return extendSpecVersion(
		super:inverseSurface(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:inverseOnSurface(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "inverse_on_surface",
		palette = function(s)
			return s.neutralPalette
		end,
		background = function(s)
			return self:inverseSurface()
		end,
		contrastCurve = function(s)
			return getCurve(7)
		end,
	})
	return extendSpecVersion(
		super:inverseOnSurface(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:primary(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "primary",
		palette = function(s)
			return s.primaryPalette
		end,
		tone = function(s)
			if s.variant == Variant.NEUTRAL then
				if s.platform == "phone" then
					return if Boolean.toJSBoolean(s.isDark) then 80 else 40
				else
					return 90
				end
			elseif s.variant == Variant.TONAL_SPOT then
				if s.platform == "phone" then
					if Boolean.toJSBoolean(s.isDark) then
						return 80
					else
						return tMaxC(s.primaryPalette)
					end
				else
					return tMaxC(s.primaryPalette, 0, 90)
				end
			elseif s.variant == Variant.EXPRESSIVE then
				return tMaxC(
					s.primaryPalette,
					0,
					if Boolean.toJSBoolean(Hct:isYellow(s.primaryPalette.hue))
						then 25
						else if Boolean.toJSBoolean(Hct:isCyan(s.primaryPalette.hue))
							then 88
							else 98
				)
			else
				-- VIBRANT
				return tMaxC(
					s.primaryPalette,
					0,
					if Boolean.toJSBoolean(Hct:isCyan(s.primaryPalette.hue)) then 88 else 98
				)
			end
		end,
		isBackground = true,
		background = function(s)
			return if s.platform == "phone"
				then self:highestSurface(s)
				else self:surfaceContainerHigh()
		end,
		contrastCurve = function(s)
			return if s.platform == "phone" then getCurve(4.5) else getCurve(7)
		end,
		toneDeltaPair = function(s)
			return if s.platform == "phone"
				then ToneDeltaPair.new(
					self:primaryContainer(),
					self:primary(),
					5,
					"relative_lighter",
					true,
					"farther"
				)
				else nil
		end,
	})
	return extendSpecVersion(
		super:primary(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:primaryDim(): DynamicColor
	return DynamicColor.fromPalette({
		name = "primary_dim",
		palette = function(s)
			return s.primaryPalette
		end,
		tone = function(s)
			if s.variant == Variant.NEUTRAL then
				return 85
			elseif s.variant == Variant.TONAL_SPOT then
				return tMaxC(s.primaryPalette, 0, 90)
			else
				return tMaxC(s.primaryPalette)
			end
		end,
		isBackground = true,
		background = function(s)
			return self:surfaceContainerHigh()
		end,
		contrastCurve = function(s)
			return getCurve(4.5)
		end,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(
				self:primaryDim(),
				self:primary(),
				5,
				"darker",
				true,
				"farther"
			)
		end,
	})
end
function ColorSpecDelegateImpl2025:onPrimary(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "on_primary",
		palette = function(s)
			return s.primaryPalette
		end,
		background = function(s)
			return if s.platform == "phone" then self:primary() else self:primaryDim()
		end,
		contrastCurve = function(s)
			return if s.platform == "phone" then getCurve(6) else getCurve(7)
		end,
	})
	return extendSpecVersion(
		super:onPrimary(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:primaryContainer(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "primary_container",
		palette = function(s)
			return s.primaryPalette
		end,
		tone = function(s)
			if s.platform == "watch" then
				return 30
			elseif s.variant == Variant.NEUTRAL then
				return if Boolean.toJSBoolean(s.isDark) then 30 else 90
			elseif s.variant == Variant.TONAL_SPOT then
				return if Boolean.toJSBoolean(s.isDark)
					then tMinC(s.primaryPalette, 35, 93)
					else tMaxC(s.primaryPalette, 0, 90)
			elseif s.variant == Variant.EXPRESSIVE then
				return if Boolean.toJSBoolean(s.isDark)
					then tMaxC(s.primaryPalette, 30, 93)
					else tMaxC(
						s.primaryPalette,
						78,
						if Boolean.toJSBoolean(Hct:isCyan(s.primaryPalette.hue)) then 88 else 90
					)
			else
				-- VIBRANT
				return if Boolean.toJSBoolean(s.isDark)
					then tMinC(s.primaryPalette, 66, 93)
					else tMaxC(
						s.primaryPalette,
						66,
						if Boolean.toJSBoolean(Hct:isCyan(s.primaryPalette.hue)) then 88 else 93
					)
			end
		end,
		isBackground = true,
		background = function(s)
			return if s.platform == "phone" then self:highestSurface(s) else nil
		end,
		toneDeltaPair = function(s)
			return if s.platform == "phone"
				then nil
				else ToneDeltaPair.new(
					self:primaryContainer(),
					self:primaryDim(),
					10,
					"darker",
					true,
					"farther"
				)
		end,
		contrastCurve = function(s)
			return if s.platform == "phone"
					and s.contrastLevel > 0 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
				then getCurve(1.5)
				else nil
		end,
	})
	return extendSpecVersion(
		super:primaryContainer(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:onPrimaryContainer(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "on_primary_container",
		palette = function(s)
			return s.primaryPalette
		end,
		background = function(s)
			return self:primaryContainer()
		end,
		contrastCurve = function(s)
			return if s.platform == "phone" then getCurve(6) else getCurve(7)
		end,
	})
	return extendSpecVersion(
		super:onPrimaryContainer(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:primaryFixed(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "primary_fixed",
		palette = function(s)
			return s.primaryPalette
		end,
		tone = function(s)
			local tempS = Object.assign({}, s, { isDark = false, contrastLevel = 0 })
			return self:primaryContainer():getTone(tempS)
		end,
		isBackground = true,
		background = function(s)
			return if s.platform == "phone" then self:highestSurface(s) else nil
		end,
		contrastCurve = function(s)
			return if s.platform == "phone"
					and s.contrastLevel > 0 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
				then getCurve(1.5)
				else nil
		end,
	})
	return extendSpecVersion(
		super:primaryFixed(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:primaryFixedDim(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "primary_fixed_dim",
		palette = function(s)
			return s.primaryPalette
		end,
		tone = function(s)
			return self:primaryFixed():getTone(s)
		end,
		isBackground = true,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(
				self:primaryFixedDim(),
				self:primaryFixed(),
				5,
				"darker",
				true,
				"exact"
			)
		end,
	})
	return extendSpecVersion(
		super:primaryFixedDim(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:onPrimaryFixed(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "on_primary_fixed",
		palette = function(s)
			return s.primaryPalette
		end,
		background = function(s)
			return self:primaryFixedDim()
		end,
		contrastCurve = function(s)
			return getCurve(7)
		end,
	})
	return extendSpecVersion(
		super:onPrimaryFixed(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:onPrimaryFixedVariant(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "on_primary_fixed_variant",
		palette = function(s)
			return s.primaryPalette
		end,
		background = function(s)
			return self:primaryFixedDim()
		end,
		contrastCurve = function(s)
			return getCurve(4.5)
		end,
	})
	return extendSpecVersion(
		super:onPrimaryFixedVariant(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:inversePrimary(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "inverse_primary",
		palette = function(s)
			return s.primaryPalette
		end,
		tone = function(s)
			return tMaxC(s.primaryPalette)
		end,
		background = function(s)
			return self:inverseSurface()
		end,
		contrastCurve = function(s)
			return if s.platform == "phone" then getCurve(6) else getCurve(7)
		end,
	})
	return extendSpecVersion(
		super:inversePrimary(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:secondary(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "secondary",
		palette = function(s)
			return s.secondaryPalette
		end,
		tone = function(s)
			if s.platform == "watch" then
				return if s.variant == Variant.NEUTRAL then 90 else tMaxC(s.secondaryPalette, 0, 90)
			elseif s.variant == Variant.NEUTRAL then
				return if Boolean.toJSBoolean(s.isDark)
					then tMinC(s.secondaryPalette, 0, 98)
					else tMaxC(s.secondaryPalette)
			elseif s.variant == Variant.VIBRANT then
				return tMaxC(
					s.secondaryPalette,
					0,
					if Boolean.toJSBoolean(s.isDark) then 90 else 98
				)
			else
				-- EXPRESSIVE and TONAL_SPOT
				return if Boolean.toJSBoolean(s.isDark) then 80 else tMaxC(s.secondaryPalette)
			end
		end,
		isBackground = true,
		background = function(s)
			return if s.platform == "phone"
				then self:highestSurface(s)
				else self:surfaceContainerHigh()
		end,
		contrastCurve = function(s)
			return if s.platform == "phone" then getCurve(4.5) else getCurve(7)
		end,
		toneDeltaPair = function(s)
			return if s.platform == "phone"
				then ToneDeltaPair.new(
					self:secondaryContainer(),
					self:secondary(),
					5,
					"relative_lighter",
					true,
					"farther"
				)
				else nil
		end,
	})
	return extendSpecVersion(
		super:secondary(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:secondaryDim(): DynamicColor
	return DynamicColor.fromPalette({
		name = "secondary_dim",
		palette = function(s)
			return s.secondaryPalette
		end,
		tone = function(s)
			if s.variant == Variant.NEUTRAL then
				return 85
			else
				return tMaxC(s.secondaryPalette, 0, 90)
			end
		end,
		isBackground = true,
		background = function(s)
			return self:surfaceContainerHigh()
		end,
		contrastCurve = function(s)
			return getCurve(4.5)
		end,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(
				self:secondaryDim(),
				self:secondary(),
				5,
				"darker",
				true,
				"farther"
			)
		end,
	})
end
function ColorSpecDelegateImpl2025:onSecondary(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "on_secondary",
		palette = function(s)
			return s.secondaryPalette
		end,
		background = function(s)
			return if s.platform == "phone" then self:secondary() else self:secondaryDim()
		end,
		contrastCurve = function(s)
			return if s.platform == "phone" then getCurve(6) else getCurve(7)
		end,
	})
	return extendSpecVersion(
		super:onSecondary(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:secondaryContainer(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "secondary_container",
		palette = function(s)
			return s.secondaryPalette
		end,
		tone = function(s)
			if s.platform == "watch" then
				return 30
			elseif s.variant == Variant.VIBRANT then
				return if Boolean.toJSBoolean(s.isDark)
					then tMinC(s.secondaryPalette, 30, 40)
					else tMaxC(s.secondaryPalette, 84, 90)
			elseif s.variant == Variant.EXPRESSIVE then
				return if Boolean.toJSBoolean(s.isDark)
					then 15
					else tMaxC(s.secondaryPalette, 90, 95)
			else
				return if Boolean.toJSBoolean(s.isDark) then 25 else 90
			end
		end,
		isBackground = true,
		background = function(s)
			return if s.platform == "phone" then self:highestSurface(s) else nil
		end,
		toneDeltaPair = function(s)
			return if s.platform == "watch"
				then ToneDeltaPair.new(
					self:secondaryContainer(),
					self:secondaryDim(),
					10,
					"darker",
					true,
					"farther"
				)
				else nil
		end,
		contrastCurve = function(s)
			return if s.platform == "phone"
					and s.contrastLevel > 0 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
				then getCurve(1.5)
				else nil
		end,
	})
	return extendSpecVersion(
		super:secondaryContainer(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:onSecondaryContainer(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "on_secondary_container",
		palette = function(s)
			return s.secondaryPalette
		end,
		background = function(s)
			return self:secondaryContainer()
		end,
		contrastCurve = function(s)
			return if s.platform == "phone" then getCurve(6) else getCurve(7)
		end,
	})
	return extendSpecVersion(
		super:onSecondaryContainer(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:secondaryFixed(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "secondary_fixed",
		palette = function(s)
			return s.secondaryPalette
		end,
		tone = function(s)
			local tempS = Object.assign({}, s, { isDark = false, contrastLevel = 0 })
			return self:secondaryContainer():getTone(tempS)
		end,
		isBackground = true,
		background = function(s)
			return if s.platform == "phone" then self:highestSurface(s) else nil
		end,
		contrastCurve = function(s)
			return if s.platform == "phone"
					and s.contrastLevel > 0 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
				then getCurve(1.5)
				else nil
		end,
	})
	return extendSpecVersion(
		super:secondaryFixed(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:secondaryFixedDim(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "secondary_fixed_dim",
		palette = function(s)
			return s.secondaryPalette
		end,
		tone = function(s)
			return self:secondaryFixed():getTone(s)
		end,
		isBackground = true,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(
				self:secondaryFixedDim(),
				self:secondaryFixed(),
				5,
				"darker",
				true,
				"exact"
			)
		end,
	})
	return extendSpecVersion(
		super:secondaryFixedDim(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:onSecondaryFixed(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "on_secondary_fixed",
		palette = function(s)
			return s.secondaryPalette
		end,
		background = function(s)
			return self:secondaryFixedDim()
		end,
		contrastCurve = function(s)
			return getCurve(7)
		end,
	})
	return extendSpecVersion(
		super:onSecondaryFixed(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:onSecondaryFixedVariant(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "on_secondary_fixed_variant",
		palette = function(s)
			return s.secondaryPalette
		end,
		background = function(s)
			return self:secondaryFixedDim()
		end,
		contrastCurve = function(s)
			return getCurve(4.5)
		end,
	})
	return extendSpecVersion(
		super:onSecondaryFixedVariant(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:tertiary(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "tertiary",
		palette = function(s)
			return s.tertiaryPalette
		end,
		tone = function(s)
			if s.platform == "watch" then
				return if s.variant == Variant.TONAL_SPOT
					then tMaxC(s.tertiaryPalette, 0, 90)
					else tMaxC(s.tertiaryPalette)
			elseif s.variant == Variant.EXPRESSIVE or s.variant == Variant.VIBRANT then
				return tMaxC(
					s.tertiaryPalette,
					0,
					if Boolean.toJSBoolean(Hct:isCyan(s.tertiaryPalette.hue))
						then 88
						else if Boolean.toJSBoolean(s.isDark) then 98 else 100
				)
			else
				-- NEUTRAL and TONAL_SPOT
				return if Boolean.toJSBoolean(s.isDark)
					then tMaxC(s.tertiaryPalette, 0, 98)
					else tMaxC(s.tertiaryPalette)
			end
		end,
		isBackground = true,
		background = function(s)
			return if s.platform == "phone"
				then self:highestSurface(s)
				else self:surfaceContainerHigh()
		end,
		contrastCurve = function(s)
			return if s.platform == "phone" then getCurve(4.5) else getCurve(7)
		end,
		toneDeltaPair = function(s)
			return if s.platform == "phone"
				then ToneDeltaPair.new(
					self:tertiaryContainer(),
					self:tertiary(),
					5,
					"relative_lighter",
					true,
					"farther"
				)
				else nil
		end,
	})
	return extendSpecVersion(
		super:tertiary(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:tertiaryDim(): DynamicColor
	return DynamicColor.fromPalette({
		name = "tertiary_dim",
		palette = function(s)
			return s.tertiaryPalette
		end,
		tone = function(s)
			if s.variant == Variant.TONAL_SPOT then
				return tMaxC(s.tertiaryPalette, 0, 90)
			else
				return tMaxC(s.tertiaryPalette)
			end
		end,
		isBackground = true,
		background = function(s)
			return self:surfaceContainerHigh()
		end,
		contrastCurve = function(s)
			return getCurve(4.5)
		end,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(
				self:tertiaryDim(),
				self:tertiary(),
				5,
				"darker",
				true,
				"farther"
			)
		end,
	})
end
function ColorSpecDelegateImpl2025:onTertiary(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "on_tertiary",
		palette = function(s)
			return s.tertiaryPalette
		end,
		background = function(s)
			return if s.platform == "phone" then self:tertiary() else self:tertiaryDim()
		end,
		contrastCurve = function(s)
			return if s.platform == "phone" then getCurve(6) else getCurve(7)
		end,
	})
	return extendSpecVersion(
		super:onTertiary(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:tertiaryContainer(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "tertiary_container",
		palette = function(s)
			return s.tertiaryPalette
		end,
		tone = function(s)
			if s.platform == "watch" then
				return if s.variant == Variant.TONAL_SPOT
					then tMaxC(s.tertiaryPalette, 0, 90)
					else tMaxC(s.tertiaryPalette)
			else
				if s.variant == Variant.NEUTRAL then
					return if Boolean.toJSBoolean(s.isDark)
						then tMaxC(s.tertiaryPalette, 0, 93)
						else tMaxC(s.tertiaryPalette, 0, 96)
				elseif s.variant == Variant.TONAL_SPOT then
					return tMaxC(
						s.tertiaryPalette,
						0,
						if Boolean.toJSBoolean(s.isDark) then 93 else 100
					)
				elseif s.variant == Variant.EXPRESSIVE then
					return tMaxC(
						s.tertiaryPalette,
						75,
						if Boolean.toJSBoolean(Hct:isCyan(s.tertiaryPalette.hue))
							then 88
							else if Boolean.toJSBoolean(s.isDark) then 93 else 100
					)
				else
					-- VIBRANT
					return if Boolean.toJSBoolean(s.isDark)
						then tMaxC(s.tertiaryPalette, 0, 93)
						else tMaxC(s.tertiaryPalette, 72, 100)
				end
			end
		end,
		isBackground = true,
		background = function(s)
			return if s.platform == "phone" then self:highestSurface(s) else nil
		end,
		toneDeltaPair = function(s)
			return if s.platform == "watch"
				then ToneDeltaPair.new(
					self:tertiaryContainer(),
					self:tertiaryDim(),
					10,
					"darker",
					true,
					"farther"
				)
				else nil
		end,
		contrastCurve = function(s)
			return if s.platform == "phone"
					and s.contrastLevel > 0 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
				then getCurve(1.5)
				else nil
		end,
	})
	return extendSpecVersion(
		super:tertiaryContainer(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:onTertiaryContainer(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "on_tertiary_container",
		palette = function(s)
			return s.tertiaryPalette
		end,
		background = function(s)
			return self:tertiaryContainer()
		end,
		contrastCurve = function(s)
			return if s.platform == "phone" then getCurve(6) else getCurve(7)
		end,
	})
	return extendSpecVersion(
		super:onTertiaryContainer(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:tertiaryFixed(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "tertiary_fixed",
		palette = function(s)
			return s.tertiaryPalette
		end,
		tone = function(s)
			local tempS = Object.assign({}, s, { isDark = false, contrastLevel = 0 })
			return self:tertiaryContainer():getTone(tempS)
		end,
		isBackground = true,
		background = function(s)
			return if s.platform == "phone" then self:highestSurface(s) else nil
		end,
		contrastCurve = function(s)
			return if s.platform == "phone"
					and s.contrastLevel > 0 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
				then getCurve(1.5)
				else nil
		end,
	})
	return extendSpecVersion(
		super:tertiaryFixed(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:tertiaryFixedDim(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "tertiary_fixed_dim",
		palette = function(s)
			return s.tertiaryPalette
		end,
		tone = function(s)
			return self:tertiaryFixed():getTone(s)
		end,
		isBackground = true,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(
				self:tertiaryFixedDim(),
				self:tertiaryFixed(),
				5,
				"darker",
				true,
				"exact"
			)
		end,
	})
	return extendSpecVersion(
		super:tertiaryFixedDim(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:onTertiaryFixed(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "on_tertiary_fixed",
		palette = function(s)
			return s.tertiaryPalette
		end,
		background = function(s)
			return self:tertiaryFixedDim()
		end,
		contrastCurve = function(s)
			return getCurve(7)
		end,
	})
	return extendSpecVersion(
		super:onTertiaryFixed(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:onTertiaryFixedVariant(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "on_tertiary_fixed_variant",
		palette = function(s)
			return s.tertiaryPalette
		end,
		background = function(s)
			return self:tertiaryFixedDim()
		end,
		contrastCurve = function(s)
			return getCurve(4.5)
		end,
	})
	return extendSpecVersion(
		super:onTertiaryFixedVariant(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:error_(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "error",
		palette = function(s)
			return s.errorPalette
		end,
		tone = function(s)
			if s.platform == "phone" then
				return if Boolean.toJSBoolean(s.isDark)
					then tMinC(s.errorPalette, 0, 98)
					else tMaxC(s.errorPalette)
			else
				return tMinC(s.errorPalette)
			end
		end,
		isBackground = true,
		background = function(s)
			return if s.platform == "phone"
				then self:highestSurface(s)
				else self:surfaceContainerHigh()
		end,
		contrastCurve = function(s)
			return if s.platform == "phone" then getCurve(4.5) else getCurve(7)
		end,
		toneDeltaPair = function(s)
			return if s.platform == "phone"
				then ToneDeltaPair.new(
					self:errorContainer(),
					self:error_(),
					5,
					"relative_lighter",
					true,
					"farther"
				)
				else nil
		end,
	})
	return extendSpecVersion(
		super:error_(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:errorDim(): DynamicColor
	return DynamicColor.fromPalette({
		name = "error_dim",
		palette = function(s)
			return s.errorPalette
		end,
		tone = function(s)
			return tMinC(s.errorPalette)
		end,
		isBackground = true,
		background = function(s)
			return self:surfaceContainerHigh()
		end,
		contrastCurve = function(s)
			return getCurve(4.5)
		end,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(self:errorDim(), self:error_(), 5, "darker", true, "farther")
		end,
	})
end
function ColorSpecDelegateImpl2025:onError(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "on_error",
		palette = function(s)
			return s.errorPalette
		end,
		background = function(s)
			return if s.platform == "phone" then self:error_() else self:errorDim()
		end,
		contrastCurve = function(s)
			return if s.platform == "phone" then getCurve(6) else getCurve(7)
		end,
	})
	return extendSpecVersion(
		super:onError(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:errorContainer(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "error_container",
		palette = function(s)
			return s.errorPalette
		end,
		tone = function(s)
			if s.platform == "watch" then
				return 30
			else
				return if Boolean.toJSBoolean(s.isDark)
					then tMinC(s.errorPalette, 30, 93)
					else tMaxC(s.errorPalette, 0, 90)
			end
		end,
		isBackground = true,
		background = function(s)
			return if s.platform == "phone" then self:highestSurface(s) else nil
		end,
		toneDeltaPair = function(s)
			return if s.platform == "watch"
				then ToneDeltaPair.new(
					self:errorContainer(),
					self:errorDim(),
					10,
					"darker",
					true,
					"farther"
				)
				else nil
		end,
		contrastCurve = function(s)
			return if s.platform == "phone"
					and s.contrastLevel > 0 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
				then getCurve(1.5)
				else nil
		end,
	})
	return extendSpecVersion(
		super:errorContainer(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:onErrorContainer(): DynamicColor
	local color2025: DynamicColor = DynamicColor.fromPalette({
		name = "on_error_container",
		palette = function(s)
			return s.errorPalette
		end,
		background = function(s)
			return self:errorContainer()
		end,
		contrastCurve = function(s)
			return if s.platform == "phone" then getCurve(4.5) else getCurve(7)
		end,
	})
	return extendSpecVersion(
		super:onErrorContainer(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:surfaceVariant(): DynamicColor
	local color2025: DynamicColor =
		Object.assign(self:surfaceContainerHighest():clone(), { name = "surface_variant" })
	return extendSpecVersion(
		super:surfaceVariant(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:surfaceTint(): DynamicColor
	local color2025: DynamicColor = Object.assign(self:primary():clone(), { name = "surface_tint" })
	return extendSpecVersion(
		super:surfaceTint(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:background(): DynamicColor
	local color2025: DynamicColor = Object.assign(self:surface():clone(), { name = "background", isBackground = true })
	return extendSpecVersion(
		super:background(),
		"2025",
		color2025
	)
end
function ColorSpecDelegateImpl2025:onBackground(): DynamicColor
	local color2025: DynamicColor = Object.assign(self:onSurface():clone(), {
		name = "on_background",
		tone = function(s: DynamicScheme)
			return if s.platform == "watch" then 100.0 else self:onSurface():getTone(s)
		end,
	})
	return extendSpecVersion(
		super:onBackground(),
		"2025",
		color2025
	)
end
exports.ColorSpecDelegateImpl2025 = ColorSpecDelegateImpl2025
return exports
