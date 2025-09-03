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
local exports = {}
local DislikeAnalyzer = require(script.Parent.Parent.dislike["dislike_analyzer"]).DislikeAnalyzer
local Hct = require(script.Parent.Parent.hct["hct"]).Hct
--local TonalPalette = require(script.Parent.Parent.palettes["tonal_palette"]).TonalPalette
--local math_ = require(script.Parent.Parent.utils["math_utils"])
--local ColorSpecDelegate = require(script.Parent["color_spec"]).ColorSpecDelegate
local ContrastCurve = require(script.Parent["contrast_curve"]).ContrastCurve
local DynamicColor = require(script.Parent["dynamic_color"]).DynamicColor
local ToneDeltaPair = require(script.Parent["tone_delta_pair"]).ToneDeltaPair
local Variant = require(script.Parent["variant"]).Variant
--[[*
 * Returns true if the scheme is Fidelity or Content.
 ]]
local function isFidelity(scheme: DynamicScheme): boolean
	return scheme.variant == Variant.FIDELITY or scheme.variant == Variant.CONTENT
end
--[[*
 * Returns true if the scheme is Monochrome.
 ]]
local function isMonochrome(scheme: DynamicScheme): boolean
	return scheme.variant == Variant.MONOCHROME
end
--[[*
 * Returns the desired chroma for a given tone at a specific hue.
 *
 * @param hue The given hue.
 * @param chroma The target chroma.
 * @param tone The tone to start with.
 * @param byDecreasingTone Whether to search for lower tones.
 ]]
local function findDesiredChromaByTone(
	hue: number,
	chroma: number,
	tone: number,
	byDecreasingTone: boolean
): number
	local answer = tone
	local closestToChroma = Array.from(Hct, hue, chroma, tone) --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
	if
		closestToChroma.chroma
		< chroma --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
	then
		local chromaPeak = closestToChroma.chroma
		while
			closestToChroma.chroma
			< chroma --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		do
			answer += if Boolean.toJSBoolean(byDecreasingTone) then -1.0 else 1.0
			local potentialSolution = Array.from(Hct, hue, chroma, answer) --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
			if
				chromaPeak
				> potentialSolution.chroma --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
			then
				break
			end
			if
				math.abs(potentialSolution.chroma - chroma)
				< 0.4 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
			then
				break
			end
			local potentialDelta = math.abs(potentialSolution.chroma - chroma)
			local currentDelta = math.abs(closestToChroma.chroma - chroma)
			if
				potentialDelta
				< currentDelta --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
			then
				closestToChroma = potentialSolution
			end
			chromaPeak = math.max(chromaPeak, potentialSolution.chroma)
		end
	end
	return answer
end
--[[*
 * A delegate for the dynamic color spec of a DynamicScheme in the 2021 spec.
 ]]
export type ColorSpecDelegateImpl2021 = { --//////////////////////////////////////////////////////////////
	-- Main Palettes                                              //
	--//////////////////////////////////////////////////////////////
	primaryPaletteKeyColor: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	secondaryPaletteKeyColor: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	tertiaryPaletteKeyColor: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	neutralPaletteKeyColor: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	neutralVariantPaletteKeyColor: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	errorPaletteKeyColor: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	--//////////////////////////////////////////////////////////////
	-- Surfaces [S]                                               //
	--//////////////////////////////////////////////////////////////
	background: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	onBackground: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	surface: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	surfaceDim: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	surfaceBright: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	surfaceContainerLowest: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	surfaceContainerLow: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	surfaceContainer: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	surfaceContainerHigh: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	surfaceContainerHighest: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	onSurface: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	surfaceVariant: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	onSurfaceVariant: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	inverseSurface: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	inverseOnSurface: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	outline: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	outlineVariant: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	shadow: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	scrim: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	surfaceTint: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	--//////////////////////////////////////////////////////////////
	-- Primary [P].                                               //
	--//////////////////////////////////////////////////////////////
	primary: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	primaryDim: (self: ColorSpecDelegateImpl2021) -> DynamicColor | nil,
	onPrimary: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	primaryContainer: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	onPrimaryContainer: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	inversePrimary: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	--///////////////////////////////////////////////////////////////
	-- Secondary [Q].                                              //
	--///////////////////////////////////////////////////////////////
	secondary: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	secondaryDim: (self: ColorSpecDelegateImpl2021) -> DynamicColor | nil,
	onSecondary: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	secondaryContainer: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	onSecondaryContainer: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	--///////////////////////////////////////////////////////////////
	-- Tertiary [T].                                               //
	--///////////////////////////////////////////////////////////////
	tertiary: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	tertiaryDim: (self: ColorSpecDelegateImpl2021) -> DynamicColor | nil,
	onTertiary: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	tertiaryContainer: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	onTertiaryContainer: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	--////////////////////////////////////////////////////////////////
	-- Error [E].                                                   //
	--////////////////////////////////////////////////////////////////
	error_: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	errorDim: (self: ColorSpecDelegateImpl2021) -> DynamicColor | nil,
	onError: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	errorContainer: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	onErrorContainer: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	--////////////////////////////////////////////////////////////////
	-- Primary Fixed [PF]                                           //
	--////////////////////////////////////////////////////////////////
	primaryFixed: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	primaryFixedDim: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	onPrimaryFixed: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	onPrimaryFixedVariant: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	--/////////////////////////////////////////////////////////////////
	-- Secondary Fixed [QF]                                          //
	--/////////////////////////////////////////////////////////////////
	secondaryFixed: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	secondaryFixedDim: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	onSecondaryFixed: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	onSecondaryFixedVariant: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	--///////////////////////////////////////////////////////////////
	-- Tertiary Fixed [TF]                                         //
	--///////////////////////////////////////////////////////////////
	tertiaryFixed: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	tertiaryFixedDim: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	onTertiaryFixed: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	onTertiaryFixedVariant: (self: ColorSpecDelegateImpl2021) -> DynamicColor,
	--//////////////////////////////////////////////////////////////
	-- Other                                                      //
	--//////////////////////////////////////////////////////////////
	highestSurface: (self: ColorSpecDelegateImpl2021, s: DynamicScheme) -> DynamicColor,
}
type ColorSpecDelegateImpl2021_statics = { new: () -> ColorSpecDelegateImpl2021 }
local ColorSpecDelegateImpl2021 =
	{} :: ColorSpecDelegateImpl2021 & ColorSpecDelegateImpl2021_statics;
(ColorSpecDelegateImpl2021 :: any).__index = ColorSpecDelegateImpl2021
function ColorSpecDelegateImpl2021.new(): ColorSpecDelegateImpl2021
	local self = setmetatable({}, ColorSpecDelegateImpl2021)
	return (self :: any) :: ColorSpecDelegateImpl2021
end
function ColorSpecDelegateImpl2021:primaryPaletteKeyColor(): DynamicColor
	return DynamicColor.fromPalette({
		name = "primary_palette_key_color",
		palette = function(s)
			return s.primaryPalette
		end,
		tone = function(s)
			return s.primaryPalette.keyColor.tone
		end,
	})
end
function ColorSpecDelegateImpl2021:secondaryPaletteKeyColor(): DynamicColor
	return DynamicColor.fromPalette({
		name = "secondary_palette_key_color",
		palette = function(s)
			return s.secondaryPalette
		end,
		tone = function(s)
			return s.secondaryPalette.keyColor.tone
		end,
	})
end
function ColorSpecDelegateImpl2021:tertiaryPaletteKeyColor(): DynamicColor
	return DynamicColor.fromPalette({
		name = "tertiary_palette_key_color",
		palette = function(s)
			return s.tertiaryPalette
		end,
		tone = function(s)
			return s.tertiaryPalette.keyColor.tone
		end,
	})
end
function ColorSpecDelegateImpl2021:neutralPaletteKeyColor(): DynamicColor
	return DynamicColor.fromPalette({
		name = "neutral_palette_key_color",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			return s.neutralPalette.keyColor.tone
		end,
	})
end
function ColorSpecDelegateImpl2021:neutralVariantPaletteKeyColor(): DynamicColor
	return DynamicColor.fromPalette({
		name = "neutral_variant_palette_key_color",
		palette = function(s)
			return s.neutralVariantPalette
		end,
		tone = function(s)
			return s.neutralVariantPalette.keyColor.tone
		end,
	})
end
function ColorSpecDelegateImpl2021:errorPaletteKeyColor(): DynamicColor
	return DynamicColor.fromPalette({
		name = "error_palette_key_color",
		palette = function(s)
			return s.errorPalette
		end,
		tone = function(s)
			return s.errorPalette.keyColor.tone
		end,
	})
end
function ColorSpecDelegateImpl2021:background(): DynamicColor
	return DynamicColor.fromPalette({
		name = "background",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark) then 6 else 98
		end,
		isBackground = true,
	})
end
function ColorSpecDelegateImpl2021:onBackground(): DynamicColor
	return DynamicColor.fromPalette({
		name = "on_background",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark) then 90 else 10
		end,
		background = function(s)
			return self:background()
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(3, 3, 4.5, 7)
		end,
	})
end
function ColorSpecDelegateImpl2021:surface(): DynamicColor
	return DynamicColor.fromPalette({
		name = "surface",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark) then 6 else 98
		end,
		isBackground = true,
	})
end
function ColorSpecDelegateImpl2021:surfaceDim(): DynamicColor
	return DynamicColor.fromPalette({
		name = "surface_dim",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark)
				then 6
				else ContrastCurve.new(87, 87, 80, 75):get(s.contrastLevel)
		end,
		isBackground = true,
	})
end
function ColorSpecDelegateImpl2021:surfaceBright(): DynamicColor
	return DynamicColor.fromPalette({
		name = "surface_bright",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark)
				then ContrastCurve.new(24, 24, 29, 34):get(s.contrastLevel)
				else 98
		end,
		isBackground = true,
	})
end
function ColorSpecDelegateImpl2021:surfaceContainerLowest(): DynamicColor
	return DynamicColor.fromPalette({
		name = "surface_container_lowest",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark)
				then ContrastCurve.new(4, 4, 2, 0):get(s.contrastLevel)
				else 100
		end,
		isBackground = true,
	})
end
function ColorSpecDelegateImpl2021:surfaceContainerLow(): DynamicColor
	return DynamicColor.fromPalette({
		name = "surface_container_low",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark)
				then ContrastCurve.new(10, 10, 11, 12):get(s.contrastLevel)
				else ContrastCurve.new(96, 96, 96, 95):get(s.contrastLevel)
		end,
		isBackground = true,
	})
end
function ColorSpecDelegateImpl2021:surfaceContainer(): DynamicColor
	return DynamicColor.fromPalette({
		name = "surface_container",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark)
				then ContrastCurve.new(12, 12, 16, 20):get(s.contrastLevel)
				else ContrastCurve.new(94, 94, 92, 90):get(s.contrastLevel)
		end,
		isBackground = true,
	})
end
function ColorSpecDelegateImpl2021:surfaceContainerHigh(): DynamicColor
	return DynamicColor.fromPalette({
		name = "surface_container_high",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark)
				then ContrastCurve.new(17, 17, 21, 25):get(s.contrastLevel)
				else ContrastCurve.new(92, 92, 88, 85):get(s.contrastLevel)
		end,
		isBackground = true,
	})
end
function ColorSpecDelegateImpl2021:surfaceContainerHighest(): DynamicColor
	return DynamicColor.fromPalette({
		name = "surface_container_highest",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark)
				then ContrastCurve.new(22, 22, 26, 30):get(s.contrastLevel)
				else ContrastCurve.new(90, 90, 84, 80):get(s.contrastLevel)
		end,
		isBackground = true,
	})
end
function ColorSpecDelegateImpl2021:onSurface(): DynamicColor
	return DynamicColor.fromPalette({
		name = "on_surface",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark) then 90 else 10
		end,
		background = function(s)
			return self:highestSurface(s)
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(4.5, 7, 11, 21)
		end,
	})
end
function ColorSpecDelegateImpl2021:surfaceVariant(): DynamicColor
	return DynamicColor.fromPalette({
		name = "surface_variant",
		palette = function(s)
			return s.neutralVariantPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark) then 30 else 90
		end,
		isBackground = true,
	})
end
function ColorSpecDelegateImpl2021:onSurfaceVariant(): DynamicColor
	return DynamicColor.fromPalette({
		name = "on_surface_variant",
		palette = function(s)
			return s.neutralVariantPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark) then 80 else 30
		end,
		background = function(s)
			return self:highestSurface(s)
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(3, 4.5, 7, 11)
		end,
	})
end
function ColorSpecDelegateImpl2021:inverseSurface(): DynamicColor
	return DynamicColor.fromPalette({
		name = "inverse_surface",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark) then 90 else 20
		end,
		isBackground = true,
	})
end
function ColorSpecDelegateImpl2021:inverseOnSurface(): DynamicColor
	return DynamicColor.fromPalette({
		name = "inverse_on_surface",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark) then 20 else 95
		end,
		background = function(s)
			return self:inverseSurface()
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(4.5, 7, 11, 21)
		end,
	})
end
function ColorSpecDelegateImpl2021:outline(): DynamicColor
	return DynamicColor.fromPalette({
		name = "outline",
		palette = function(s)
			return s.neutralVariantPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark) then 60 else 50
		end,
		background = function(s)
			return self:highestSurface(s)
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(1.5, 3, 4.5, 7)
		end,
	})
end
function ColorSpecDelegateImpl2021:outlineVariant(): DynamicColor
	return DynamicColor.fromPalette({
		name = "outline_variant",
		palette = function(s)
			return s.neutralVariantPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark) then 30 else 80
		end,
		background = function(s)
			return self:highestSurface(s)
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(1, 1, 3, 4.5)
		end,
	})
end
function ColorSpecDelegateImpl2021:shadow(): DynamicColor
	return DynamicColor.fromPalette({
		name = "shadow",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			return 0
		end,
	})
end
function ColorSpecDelegateImpl2021:scrim(): DynamicColor
	return DynamicColor.fromPalette({
		name = "scrim",
		palette = function(s)
			return s.neutralPalette
		end,
		tone = function(s)
			return 0
		end,
	})
end
function ColorSpecDelegateImpl2021:surfaceTint(): DynamicColor
	return DynamicColor.fromPalette({
		name = "surface_tint",
		palette = function(s)
			return s.primaryPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark) then 80 else 40
		end,
		isBackground = true,
	})
end
function ColorSpecDelegateImpl2021:primary(): DynamicColor
	return DynamicColor.fromPalette({
		name = "primary",
		palette = function(s)
			return s.primaryPalette
		end,
		tone = function(s)
			if Boolean.toJSBoolean(isMonochrome(s)) then
				return if Boolean.toJSBoolean(s.isDark) then 100 else 0
			end
			return if Boolean.toJSBoolean(s.isDark) then 80 else 40
		end,
		isBackground = true,
		background = function(s)
			return self:highestSurface(s)
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(3, 4.5, 7, 7)
		end,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(self:primaryContainer(), self:primary(), 10, "nearer", false)
		end,
	})
end
function ColorSpecDelegateImpl2021:primaryDim(): DynamicColor | nil
	return nil
end
function ColorSpecDelegateImpl2021:onPrimary(): DynamicColor
	return DynamicColor.fromPalette({
		name = "on_primary",
		palette = function(s)
			return s.primaryPalette
		end,
		tone = function(s)
			if Boolean.toJSBoolean(isMonochrome(s)) then
				return if Boolean.toJSBoolean(s.isDark) then 10 else 90
			end
			return if Boolean.toJSBoolean(s.isDark) then 20 else 100
		end,
		background = function(s)
			return self:primary()
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(4.5, 7, 11, 21)
		end,
	})
end
function ColorSpecDelegateImpl2021:primaryContainer(): DynamicColor
	return DynamicColor.fromPalette({
		name = "primary_container",
		palette = function(s)
			return s.primaryPalette
		end,
		tone = function(s)
			if Boolean.toJSBoolean(isFidelity(s)) then
				return s.sourceColorHct.tone
			end
			if Boolean.toJSBoolean(isMonochrome(s)) then
				return if Boolean.toJSBoolean(s.isDark) then 85 else 25
			end
			return if Boolean.toJSBoolean(s.isDark) then 30 else 90
		end,
		isBackground = true,
		background = function(s)
			return self:highestSurface(s)
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(1, 1, 3, 4.5)
		end,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(self:primaryContainer(), self:primary(), 10, "nearer", false)
		end,
	})
end
function ColorSpecDelegateImpl2021:onPrimaryContainer(): DynamicColor
	return DynamicColor.fromPalette({
		name = "on_primary_container",
		palette = function(s)
			return s.primaryPalette
		end,
		tone = function(s)
			if Boolean.toJSBoolean(isFidelity(s)) then
				return DynamicColor:foregroundTone(self:primaryContainer():tone(s), 4.5)
			end
			if Boolean.toJSBoolean(isMonochrome(s)) then
				return if Boolean.toJSBoolean(s.isDark) then 0 else 100
			end
			return if Boolean.toJSBoolean(s.isDark) then 90 else 30
		end,
		background = function(s)
			return self:primaryContainer()
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(3, 4.5, 7, 11)
		end,
	})
end
function ColorSpecDelegateImpl2021:inversePrimary(): DynamicColor
	return DynamicColor.fromPalette({
		name = "inverse_primary",
		palette = function(s)
			return s.primaryPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark) then 40 else 80
		end,
		background = function(s)
			return self:inverseSurface()
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(3, 4.5, 7, 7)
		end,
	})
end
function ColorSpecDelegateImpl2021:secondary(): DynamicColor
	return DynamicColor.fromPalette({
		name = "secondary",
		palette = function(s)
			return s.secondaryPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark) then 80 else 40
		end,
		isBackground = true,
		background = function(s)
			return self:highestSurface(s)
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(3, 4.5, 7, 7)
		end,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(
				self:secondaryContainer(),
				self:secondary(),
				10,
				"nearer",
				false
			)
		end,
	})
end
function ColorSpecDelegateImpl2021:secondaryDim(): DynamicColor | nil
	return nil
end
function ColorSpecDelegateImpl2021:onSecondary(): DynamicColor
	return DynamicColor.fromPalette({
		name = "on_secondary",
		palette = function(s)
			return s.secondaryPalette
		end,
		tone = function(s)
			if Boolean.toJSBoolean(isMonochrome(s)) then
				return if Boolean.toJSBoolean(s.isDark) then 10 else 100
			else
				return if Boolean.toJSBoolean(s.isDark) then 20 else 100
			end
		end,
		background = function(s)
			return self:secondary()
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(4.5, 7, 11, 21)
		end,
	})
end
function ColorSpecDelegateImpl2021:secondaryContainer(): DynamicColor
	return DynamicColor.fromPalette({
		name = "secondary_container",
		palette = function(s)
			return s.secondaryPalette
		end,
		tone = function(s)
			local initialTone = if Boolean.toJSBoolean(s.isDark) then 30 else 90
			if Boolean.toJSBoolean(isMonochrome(s)) then
				return if Boolean.toJSBoolean(s.isDark) then 30 else 85
			end
			if not Boolean.toJSBoolean(isFidelity(s)) then
				return initialTone
			end
			return findDesiredChromaByTone(
				s.secondaryPalette.hue,
				s.secondaryPalette.chroma,
				initialTone,
				if Boolean.toJSBoolean(s.isDark) then false else true
			)
		end,
		isBackground = true,
		background = function(s)
			return self:highestSurface(s)
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(1, 1, 3, 4.5)
		end,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(
				self:secondaryContainer(),
				self:secondary(),
				10,
				"nearer",
				false
			)
		end,
	})
end
function ColorSpecDelegateImpl2021:onSecondaryContainer(): DynamicColor
	return DynamicColor.fromPalette({
		name = "on_secondary_container",
		palette = function(s)
			return s.secondaryPalette
		end,
		tone = function(s)
			if Boolean.toJSBoolean(isMonochrome(s)) then
				return if Boolean.toJSBoolean(s.isDark) then 90 else 10
			end
			if not Boolean.toJSBoolean(isFidelity(s)) then
				return if Boolean.toJSBoolean(s.isDark) then 90 else 30
			end
			return DynamicColor:foregroundTone(self:secondaryContainer():tone(s), 4.5)
		end,
		background = function(s)
			return self:secondaryContainer()
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(3, 4.5, 7, 11)
		end,
	})
end
function ColorSpecDelegateImpl2021:tertiary(): DynamicColor
	return DynamicColor.fromPalette({
		name = "tertiary",
		palette = function(s)
			return s.tertiaryPalette
		end,
		tone = function(s)
			if Boolean.toJSBoolean(isMonochrome(s)) then
				return if Boolean.toJSBoolean(s.isDark) then 90 else 25
			end
			return if Boolean.toJSBoolean(s.isDark) then 80 else 40
		end,
		isBackground = true,
		background = function(s)
			return self:highestSurface(s)
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(3, 4.5, 7, 7)
		end,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(self:tertiaryContainer(), self:tertiary(), 10, "nearer", false)
		end,
	})
end
function ColorSpecDelegateImpl2021:tertiaryDim(): DynamicColor | nil
	return nil
end
function ColorSpecDelegateImpl2021:onTertiary(): DynamicColor
	return DynamicColor.fromPalette({
		name = "on_tertiary",
		palette = function(s)
			return s.tertiaryPalette
		end,
		tone = function(s)
			if Boolean.toJSBoolean(isMonochrome(s)) then
				return if Boolean.toJSBoolean(s.isDark) then 10 else 90
			end
			return if Boolean.toJSBoolean(s.isDark) then 20 else 100
		end,
		background = function(s)
			return self:tertiary()
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(4.5, 7, 11, 21)
		end,
	})
end
function ColorSpecDelegateImpl2021:tertiaryContainer(): DynamicColor
	return DynamicColor.fromPalette({
		name = "tertiary_container",
		palette = function(s)
			return s.tertiaryPalette
		end,
		tone = function(s)
			if Boolean.toJSBoolean(isMonochrome(s)) then
				return if Boolean.toJSBoolean(s.isDark) then 60 else 49
			end
			if not Boolean.toJSBoolean(isFidelity(s)) then
				return if Boolean.toJSBoolean(s.isDark) then 30 else 90
			end
			local proposedHct = s.tertiaryPalette:getHct(s.sourceColorHct.tone)
			return DislikeAnalyzer:fixIfDisliked(proposedHct).tone
		end,
		isBackground = true,
		background = function(s)
			return self:highestSurface(s)
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(1, 1, 3, 4.5)
		end,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(self:tertiaryContainer(), self:tertiary(), 10, "nearer", false)
		end,
	})
end
function ColorSpecDelegateImpl2021:onTertiaryContainer(): DynamicColor
	return DynamicColor.fromPalette({
		name = "on_tertiary_container",
		palette = function(s)
			return s.tertiaryPalette
		end,
		tone = function(s)
			if Boolean.toJSBoolean(isMonochrome(s)) then
				return if Boolean.toJSBoolean(s.isDark) then 0 else 100
			end
			if not Boolean.toJSBoolean(isFidelity(s)) then
				return if Boolean.toJSBoolean(s.isDark) then 90 else 30
			end
			return DynamicColor:foregroundTone(self:tertiaryContainer():tone(s), 4.5)
		end,
		background = function(s)
			return self:tertiaryContainer()
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(3, 4.5, 7, 11)
		end,
	})
end
function ColorSpecDelegateImpl2021:error_(): DynamicColor
	return DynamicColor.fromPalette({
		name = "error",
		palette = function(s)
			return s.errorPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark) then 80 else 40
		end,
		isBackground = true,
		background = function(s)
			return self:highestSurface(s)
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(3, 4.5, 7, 7)
		end,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(self:errorContainer(), self:error_(), 10, "nearer", false)
		end,
	})
end
function ColorSpecDelegateImpl2021:errorDim(): DynamicColor | nil
	return nil
end
function ColorSpecDelegateImpl2021:onError(): DynamicColor
	return DynamicColor.fromPalette({
		name = "on_error",
		palette = function(s)
			return s.errorPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark) then 20 else 100
		end,
		background = function(s)
			return self:error_()
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(4.5, 7, 11, 21)
		end,
	})
end
function ColorSpecDelegateImpl2021:errorContainer(): DynamicColor
	return DynamicColor.fromPalette({
		name = "error_container",
		palette = function(s)
			return s.errorPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(s.isDark) then 30 else 90
		end,
		isBackground = true,
		background = function(s)
			return self:highestSurface(s)
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(1, 1, 3, 4.5)
		end,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(self:errorContainer(), self:error_(), 10, "nearer", false)
		end,
	})
end
function ColorSpecDelegateImpl2021:onErrorContainer(): DynamicColor
	return DynamicColor.fromPalette({
		name = "on_error_container",
		palette = function(s)
			return s.errorPalette
		end,
		tone = function(s)
			if Boolean.toJSBoolean(isMonochrome(s)) then
				return if Boolean.toJSBoolean(s.isDark) then 90 else 10
			end
			return if Boolean.toJSBoolean(s.isDark) then 90 else 30
		end,
		background = function(s)
			return self:errorContainer()
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(3, 4.5, 7, 11)
		end,
	})
end
function ColorSpecDelegateImpl2021:primaryFixed(): DynamicColor
	return DynamicColor.fromPalette({
		name = "primary_fixed",
		palette = function(s)
			return s.primaryPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(isMonochrome(s)) then 40.0 else 90.0
		end,
		isBackground = true,
		background = function(s)
			return self:highestSurface(s)
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(1, 1, 3, 4.5)
		end,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(
				self:primaryFixed(),
				self:primaryFixedDim(),
				10,
				"lighter",
				true
			)
		end,
	})
end
function ColorSpecDelegateImpl2021:primaryFixedDim(): DynamicColor
	return DynamicColor.fromPalette({
		name = "primary_fixed_dim",
		palette = function(s)
			return s.primaryPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(isMonochrome(s)) then 30.0 else 80.0
		end,
		isBackground = true,
		background = function(s)
			return self:highestSurface(s)
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(1, 1, 3, 4.5)
		end,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(
				self:primaryFixed(),
				self:primaryFixedDim(),
				10,
				"lighter",
				true
			)
		end,
	})
end
function ColorSpecDelegateImpl2021:onPrimaryFixed(): DynamicColor
	return DynamicColor.fromPalette({
		name = "on_primary_fixed",
		palette = function(s)
			return s.primaryPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(isMonochrome(s)) then 100.0 else 10.0
		end,
		background = function(s)
			return self:primaryFixedDim()
		end,
		secondBackground = function(s)
			return self:primaryFixed()
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(4.5, 7, 11, 21)
		end,
	})
end
function ColorSpecDelegateImpl2021:onPrimaryFixedVariant(): DynamicColor
	return DynamicColor.fromPalette({
		name = "on_primary_fixed_variant",
		palette = function(s)
			return s.primaryPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(isMonochrome(s)) then 90.0 else 30.0
		end,
		background = function(s)
			return self:primaryFixedDim()
		end,
		secondBackground = function(s)
			return self:primaryFixed()
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(3, 4.5, 7, 11)
		end,
	})
end
function ColorSpecDelegateImpl2021:secondaryFixed(): DynamicColor
	return DynamicColor.fromPalette({
		name = "secondary_fixed",
		palette = function(s)
			return s.secondaryPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(isMonochrome(s)) then 80.0 else 90.0
		end,
		isBackground = true,
		background = function(s)
			return self:highestSurface(s)
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(1, 1, 3, 4.5)
		end,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(
				self:secondaryFixed(),
				self:secondaryFixedDim(),
				10,
				"lighter",
				true
			)
		end,
	})
end
function ColorSpecDelegateImpl2021:secondaryFixedDim(): DynamicColor
	return DynamicColor.fromPalette({
		name = "secondary_fixed_dim",
		palette = function(s)
			return s.secondaryPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(isMonochrome(s)) then 70.0 else 80.0
		end,
		isBackground = true,
		background = function(s)
			return self:highestSurface(s)
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(1, 1, 3, 4.5)
		end,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(
				self:secondaryFixed(),
				self:secondaryFixedDim(),
				10,
				"lighter",
				true
			)
		end,
	})
end
function ColorSpecDelegateImpl2021:onSecondaryFixed(): DynamicColor
	return DynamicColor.fromPalette({
		name = "on_secondary_fixed",
		palette = function(s)
			return s.secondaryPalette
		end,
		tone = function(s)
			return 10.0
		end,
		background = function(s)
			return self:secondaryFixedDim()
		end,
		secondBackground = function(s)
			return self:secondaryFixed()
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(4.5, 7, 11, 21)
		end,
	})
end
function ColorSpecDelegateImpl2021:onSecondaryFixedVariant(): DynamicColor
	return DynamicColor.fromPalette({
		name = "on_secondary_fixed_variant",
		palette = function(s)
			return s.secondaryPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(isMonochrome(s)) then 25.0 else 30.0
		end,
		background = function(s)
			return self:secondaryFixedDim()
		end,
		secondBackground = function(s)
			return self:secondaryFixed()
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(3, 4.5, 7, 11)
		end,
	})
end
function ColorSpecDelegateImpl2021:tertiaryFixed(): DynamicColor
	return DynamicColor.fromPalette({
		name = "tertiary_fixed",
		palette = function(s)
			return s.tertiaryPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(isMonochrome(s)) then 40.0 else 90.0
		end,
		isBackground = true,
		background = function(s)
			return self:highestSurface(s)
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(1, 1, 3, 4.5)
		end,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(
				self:tertiaryFixed(),
				self:tertiaryFixedDim(),
				10,
				"lighter",
				true
			)
		end,
	})
end
function ColorSpecDelegateImpl2021:tertiaryFixedDim(): DynamicColor
	return DynamicColor.fromPalette({
		name = "tertiary_fixed_dim",
		palette = function(s)
			return s.tertiaryPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(isMonochrome(s)) then 30.0 else 80.0
		end,
		isBackground = true,
		background = function(s)
			return self:highestSurface(s)
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(1, 1, 3, 4.5)
		end,
		toneDeltaPair = function(s)
			return ToneDeltaPair.new(
				self:tertiaryFixed(),
				self:tertiaryFixedDim(),
				10,
				"lighter",
				true
			)
		end,
	})
end
function ColorSpecDelegateImpl2021:onTertiaryFixed(): DynamicColor
	return DynamicColor.fromPalette({
		name = "on_tertiary_fixed",
		palette = function(s)
			return s.tertiaryPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(isMonochrome(s)) then 100.0 else 10.0
		end,
		background = function(s)
			return self:tertiaryFixedDim()
		end,
		secondBackground = function(s)
			return self:tertiaryFixed()
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(4.5, 7, 11, 21)
		end,
	})
end
function ColorSpecDelegateImpl2021:onTertiaryFixedVariant(): DynamicColor
	return DynamicColor.fromPalette({
		name = "on_tertiary_fixed_variant",
		palette = function(s)
			return s.tertiaryPalette
		end,
		tone = function(s)
			return if Boolean.toJSBoolean(isMonochrome(s)) then 90.0 else 30.0
		end,
		background = function(s)
			return self:tertiaryFixedDim()
		end,
		secondBackground = function(s)
			return self:tertiaryFixed()
		end,
		contrastCurve = function(s)
			return ContrastCurve.new(3, 4.5, 7, 11)
		end,
	})
end
function ColorSpecDelegateImpl2021:highestSurface(s: DynamicScheme): DynamicColor
	return if Boolean.toJSBoolean(s.isDark) then self:surfaceBright() else self:surfaceDim()
end
exports.ColorSpecDelegateImpl2021 = ColorSpecDelegateImpl2021
return exports
