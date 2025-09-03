-- ROBLOX NOTE: no upstream
--[[*
 * @license
 * Copyright 2022 Google LLC
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
type Array<T> = LuauPolyfill.Array<T>
local exports = {}
local DislikeAnalyzer = require(script.Parent.Parent.dislike["dislike_analyzer"]).DislikeAnalyzer
local Hct = require(script.Parent.Parent.hct["hct"]).Hct
local TonalPalette = require(script.Parent.Parent.palettes["tonal_palette"]).TonalPalette
local math_ = require(script.Parent.Parent.utils["math_utils"])
local ColorSpecDelegateImpl2025 =
	require(script.Parent["color_spec_2025"]).ColorSpecDelegateImpl2025
local ContrastCurve = require(script.Parent["contrast_curve"]).ContrastCurve
local DynamicColor = require(script.Parent["dynamic_color"]).DynamicColor
local ToneDeltaPair = require(script.Parent["tone_delta_pair"]).ToneDeltaPair
local Variant = require(script.Parent["variant"]).Variant
--[[*
 * DynamicColors for the colors in the Material Design system.
 ]]
-- Material Color Utilities namespaces the various utilities it provides.
-- tslint:disable-next-line:class-as-namespace
export type MaterialDynamicColors = {
	highestSurface: (self: MaterialDynamicColors, s: DynamicScheme) -> DynamicColor,
	--//////////////////////////////////////////////////////////////
	-- Main Palettes                                              //
	--//////////////////////////////////////////////////////////////
	primaryPaletteKeyColor: (self: MaterialDynamicColors) -> DynamicColor,
	secondaryPaletteKeyColor: (self: MaterialDynamicColors) -> DynamicColor,
	tertiaryPaletteKeyColor: (self: MaterialDynamicColors) -> DynamicColor,
	neutralPaletteKeyColor: (self: MaterialDynamicColors) -> DynamicColor,
	neutralVariantPaletteKeyColor: (self: MaterialDynamicColors) -> DynamicColor,
	errorPaletteKeyColor: (self: MaterialDynamicColors) -> DynamicColor,
	--//////////////////////////////////////////////////////////////
	-- Surfaces [S]                                               //
	--//////////////////////////////////////////////////////////////
	background: (self: MaterialDynamicColors) -> DynamicColor,
	onBackground: (self: MaterialDynamicColors) -> DynamicColor,
	surface: (self: MaterialDynamicColors) -> DynamicColor,
	surfaceDim: (self: MaterialDynamicColors) -> DynamicColor,
	surfaceBright: (self: MaterialDynamicColors) -> DynamicColor,
	surfaceContainerLowest: (self: MaterialDynamicColors) -> DynamicColor,
	surfaceContainerLow: (self: MaterialDynamicColors) -> DynamicColor,
	surfaceContainer: (self: MaterialDynamicColors) -> DynamicColor,
	surfaceContainerHigh: (self: MaterialDynamicColors) -> DynamicColor,
	surfaceContainerHighest: (self: MaterialDynamicColors) -> DynamicColor,
	onSurface: (self: MaterialDynamicColors) -> DynamicColor,
	surfaceVariant: (self: MaterialDynamicColors) -> DynamicColor,
	onSurfaceVariant: (self: MaterialDynamicColors) -> DynamicColor,
	outline: (self: MaterialDynamicColors) -> DynamicColor,
	outlineVariant: (self: MaterialDynamicColors) -> DynamicColor,
	inverseSurface: (self: MaterialDynamicColors) -> DynamicColor,
	inverseOnSurface: (self: MaterialDynamicColors) -> DynamicColor,
	shadow: (self: MaterialDynamicColors) -> DynamicColor,
	scrim: (self: MaterialDynamicColors) -> DynamicColor,
	surfaceTint: (self: MaterialDynamicColors) -> DynamicColor,
	--//////////////////////////////////////////////////////////////
	-- Primaries [P]                                              //
	--//////////////////////////////////////////////////////////////
	primary: (self: MaterialDynamicColors) -> DynamicColor,
	primaryDim: (self: MaterialDynamicColors) -> DynamicColor | nil,
	onPrimary: (self: MaterialDynamicColors) -> DynamicColor,
	primaryContainer: (self: MaterialDynamicColors) -> DynamicColor,
	onPrimaryContainer: (self: MaterialDynamicColors) -> DynamicColor,
	inversePrimary: (self: MaterialDynamicColors) -> DynamicColor,
	--///////////////////////////////////////////////////////////////
	-- Primary Fixed [PF]                                          //
	--///////////////////////////////////////////////////////////////
	primaryFixed: (self: MaterialDynamicColors) -> DynamicColor,
	primaryFixedDim: (self: MaterialDynamicColors) -> DynamicColor,
	onPrimaryFixed: (self: MaterialDynamicColors) -> DynamicColor,
	onPrimaryFixedVariant: (self: MaterialDynamicColors) -> DynamicColor,
	--//////////////////////////////////////////////////////////////
	-- Secondaries [Q]                                            //
	--//////////////////////////////////////////////////////////////
	secondary: (self: MaterialDynamicColors) -> DynamicColor,
	secondaryDim: (self: MaterialDynamicColors) -> DynamicColor | nil,
	onSecondary: (self: MaterialDynamicColors) -> DynamicColor,
	secondaryContainer: (self: MaterialDynamicColors) -> DynamicColor,
	onSecondaryContainer: (self: MaterialDynamicColors) -> DynamicColor,
	--///////////////////////////////////////////////////////////////
	-- Secondary Fixed [QF]                                        //
	--///////////////////////////////////////////////////////////////
	secondaryFixed: (self: MaterialDynamicColors) -> DynamicColor,
	secondaryFixedDim: (self: MaterialDynamicColors) -> DynamicColor,
	onSecondaryFixed: (self: MaterialDynamicColors) -> DynamicColor,
	onSecondaryFixedVariant: (self: MaterialDynamicColors) -> DynamicColor,
	--//////////////////////////////////////////////////////////////
	-- Tertiaries [T]                                             //
	--//////////////////////////////////////////////////////////////
	tertiary: (self: MaterialDynamicColors) -> DynamicColor,
	tertiaryDim: (self: MaterialDynamicColors) -> DynamicColor | nil,
	onTertiary: (self: MaterialDynamicColors) -> DynamicColor,
	tertiaryContainer: (self: MaterialDynamicColors) -> DynamicColor,
	onTertiaryContainer: (self: MaterialDynamicColors) -> DynamicColor,
	--///////////////////////////////////////////////////////////////
	-- Tertiary Fixed [TF]                                         //
	--///////////////////////////////////////////////////////////////
	tertiaryFixed: (self: MaterialDynamicColors) -> DynamicColor,
	tertiaryFixedDim: (self: MaterialDynamicColors) -> DynamicColor,
	onTertiaryFixed: (self: MaterialDynamicColors) -> DynamicColor,
	onTertiaryFixedVariant: (self: MaterialDynamicColors) -> DynamicColor,
	--//////////////////////////////////////////////////////////////
	-- Errors [E]                                                 //
	--//////////////////////////////////////////////////////////////
	error_: (self: MaterialDynamicColors) -> DynamicColor,
	errorDim: (self: MaterialDynamicColors) -> DynamicColor | nil,
	onError: (self: MaterialDynamicColors) -> DynamicColor,
	errorContainer: (self: MaterialDynamicColors) -> DynamicColor,
	onErrorContainer: (self: MaterialDynamicColors) -> DynamicColor,
	--//////////////////////////////////////////////////////////////
	-- All Colors                                                 //
	--//////////////////////////////////////////////////////////////
	allColors: Array<DynamicColor>,
	-- Static variables are deprecated. Use the instance methods to get correct
	-- specs based on request.
	--[[* @deprecated Use highestSurface() instead. ]]
}
type MaterialDynamicColors_private = { --
	-- *** PUBLIC ***
	--
	highestSurface: (self: MaterialDynamicColors_private, s: DynamicScheme) -> DynamicColor,
	primaryPaletteKeyColor: (self: MaterialDynamicColors_private) -> DynamicColor,
	secondaryPaletteKeyColor: (self: MaterialDynamicColors_private) -> DynamicColor,
	tertiaryPaletteKeyColor: (self: MaterialDynamicColors_private) -> DynamicColor,
	neutralPaletteKeyColor: (self: MaterialDynamicColors_private) -> DynamicColor,
	neutralVariantPaletteKeyColor: (self: MaterialDynamicColors_private) -> DynamicColor,
	errorPaletteKeyColor: (self: MaterialDynamicColors_private) -> DynamicColor,
	background: (self: MaterialDynamicColors_private) -> DynamicColor,
	onBackground: (self: MaterialDynamicColors_private) -> DynamicColor,
	surface: (self: MaterialDynamicColors_private) -> DynamicColor,
	surfaceDim: (self: MaterialDynamicColors_private) -> DynamicColor,
	surfaceBright: (self: MaterialDynamicColors_private) -> DynamicColor,
	surfaceContainerLowest: (self: MaterialDynamicColors_private) -> DynamicColor,
	surfaceContainerLow: (self: MaterialDynamicColors_private) -> DynamicColor,
	surfaceContainer: (self: MaterialDynamicColors_private) -> DynamicColor,
	surfaceContainerHigh: (self: MaterialDynamicColors_private) -> DynamicColor,
	surfaceContainerHighest: (self: MaterialDynamicColors_private) -> DynamicColor,
	onSurface: (self: MaterialDynamicColors_private) -> DynamicColor,
	surfaceVariant: (self: MaterialDynamicColors_private) -> DynamicColor,
	onSurfaceVariant: (self: MaterialDynamicColors_private) -> DynamicColor,
	outline: (self: MaterialDynamicColors_private) -> DynamicColor,
	outlineVariant: (self: MaterialDynamicColors_private) -> DynamicColor,
	inverseSurface: (self: MaterialDynamicColors_private) -> DynamicColor,
	inverseOnSurface: (self: MaterialDynamicColors_private) -> DynamicColor,
	shadow: (self: MaterialDynamicColors_private) -> DynamicColor,
	scrim: (self: MaterialDynamicColors_private) -> DynamicColor,
	surfaceTint: (self: MaterialDynamicColors_private) -> DynamicColor,
	primary: (self: MaterialDynamicColors_private) -> DynamicColor,
	primaryDim: (self: MaterialDynamicColors_private) -> DynamicColor | nil,
	onPrimary: (self: MaterialDynamicColors_private) -> DynamicColor,
	primaryContainer: (self: MaterialDynamicColors_private) -> DynamicColor,
	onPrimaryContainer: (self: MaterialDynamicColors_private) -> DynamicColor,
	inversePrimary: (self: MaterialDynamicColors_private) -> DynamicColor,
	primaryFixed: (self: MaterialDynamicColors_private) -> DynamicColor,
	primaryFixedDim: (self: MaterialDynamicColors_private) -> DynamicColor,
	onPrimaryFixed: (self: MaterialDynamicColors_private) -> DynamicColor,
	onPrimaryFixedVariant: (self: MaterialDynamicColors_private) -> DynamicColor,
	secondary: (self: MaterialDynamicColors_private) -> DynamicColor,
	secondaryDim: (self: MaterialDynamicColors_private) -> DynamicColor | nil,
	onSecondary: (self: MaterialDynamicColors_private) -> DynamicColor,
	secondaryContainer: (self: MaterialDynamicColors_private) -> DynamicColor,
	onSecondaryContainer: (self: MaterialDynamicColors_private) -> DynamicColor,
	secondaryFixed: (self: MaterialDynamicColors_private) -> DynamicColor,
	secondaryFixedDim: (self: MaterialDynamicColors_private) -> DynamicColor,
	onSecondaryFixed: (self: MaterialDynamicColors_private) -> DynamicColor,
	onSecondaryFixedVariant: (self: MaterialDynamicColors_private) -> DynamicColor,
	tertiary: (self: MaterialDynamicColors_private) -> DynamicColor,
	tertiaryDim: (self: MaterialDynamicColors_private) -> DynamicColor | nil,
	onTertiary: (self: MaterialDynamicColors_private) -> DynamicColor,
	tertiaryContainer: (self: MaterialDynamicColors_private) -> DynamicColor,
	onTertiaryContainer: (self: MaterialDynamicColors_private) -> DynamicColor,
	tertiaryFixed: (self: MaterialDynamicColors_private) -> DynamicColor,
	tertiaryFixedDim: (self: MaterialDynamicColors_private) -> DynamicColor,
	onTertiaryFixed: (self: MaterialDynamicColors_private) -> DynamicColor,
	onTertiaryFixedVariant: (self: MaterialDynamicColors_private) -> DynamicColor,
	error_: (self: MaterialDynamicColors_private) -> DynamicColor,
	errorDim: (self: MaterialDynamicColors_private) -> DynamicColor | nil,
	onError: (self: MaterialDynamicColors_private) -> DynamicColor,
	errorContainer: (self: MaterialDynamicColors_private) -> DynamicColor,
	onErrorContainer: (self: MaterialDynamicColors_private) -> DynamicColor,
	allColors: Array<DynamicColor>,
}
type MaterialDynamicColors_statics = { new: () -> MaterialDynamicColors }
local MaterialDynamicColors = {} :: MaterialDynamicColors & MaterialDynamicColors_statics
local MaterialDynamicColors_private =
	MaterialDynamicColors :: MaterialDynamicColors_private & MaterialDynamicColors_statics;
(MaterialDynamicColors :: any).__index = MaterialDynamicColors
MaterialDynamicColors.contentAccentToneDelta = 15.0

MaterialDynamicColors_private.colorSpec = ColorSpecDelegateImpl2025.new()
function MaterialDynamicColors_private.new(): MaterialDynamicColors
	local self = setmetatable({}, MaterialDynamicColors)
	self.allColors = Array.filter({
		self:background(),
		self:onBackground(),
		self:surface(),
		self:surfaceDim(),
		self:surfaceBright(),
		self:surfaceContainerLowest(),
		self:surfaceContainerLow(),
		self:surfaceContainer(),
		self:surfaceContainerHigh(),
		self:surfaceContainerHighest(),
		self:onSurface(),
		self:onSurfaceVariant(),
		self:outline(),
		self:outlineVariant(),
		self:inverseSurface(),
		self:inverseOnSurface(),
		self:primary(),
		self:primaryDim(),
		self:onPrimary(),
		self:primaryContainer(),
		self:onPrimaryContainer(),
		self:primaryFixed(),
		self:primaryFixedDim(),
		self:onPrimaryFixed(),
		self:onPrimaryFixedVariant(),
		self:inversePrimary(),
		self:secondary(),
		self:secondaryDim(),
		self:onSecondary(),
		self:secondaryContainer(),
		self:onSecondaryContainer(),
		self:secondaryFixed(),
		self:secondaryFixedDim(),
		self:onSecondaryFixed(),
		self:onSecondaryFixedVariant(),
		self:tertiary(),
		self:tertiaryDim(),
		self:onTertiary(),
		self:tertiaryContainer(),
		self:onTertiaryContainer(),
		self:tertiaryFixed(),
		self:tertiaryFixedDim(),
		self:onTertiaryFixed(),
		self:onTertiaryFixedVariant(),
		self:error_(),
		self:errorDim(),
		self:onError(),
		self:errorContainer(),
		self:onErrorContainer(),
	}, function(c)
		return c ~= nil
	end)
	return (self :: any) :: MaterialDynamicColors
end
function MaterialDynamicColors_private:highestSurface(s: DynamicScheme): DynamicColor
	return MaterialDynamicColors.colorSpec:highestSurface(s)
end
function MaterialDynamicColors_private:primaryPaletteKeyColor(): DynamicColor
	return MaterialDynamicColors.colorSpec:primaryPaletteKeyColor()
end
function MaterialDynamicColors_private:secondaryPaletteKeyColor(): DynamicColor
	return MaterialDynamicColors.colorSpec:secondaryPaletteKeyColor()
end
function MaterialDynamicColors_private:tertiaryPaletteKeyColor(): DynamicColor
	return MaterialDynamicColors.colorSpec:tertiaryPaletteKeyColor()
end
function MaterialDynamicColors_private:neutralPaletteKeyColor(): DynamicColor
	return MaterialDynamicColors.colorSpec:neutralPaletteKeyColor()
end
function MaterialDynamicColors_private:neutralVariantPaletteKeyColor(): DynamicColor
	return MaterialDynamicColors.colorSpec:neutralVariantPaletteKeyColor()
end
function MaterialDynamicColors_private:errorPaletteKeyColor(): DynamicColor
	return MaterialDynamicColors.colorSpec:errorPaletteKeyColor()
end
function MaterialDynamicColors_private:background(): DynamicColor
	return MaterialDynamicColors.colorSpec:background()
end
function MaterialDynamicColors_private:onBackground(): DynamicColor
	return MaterialDynamicColors.colorSpec:onBackground()
end
function MaterialDynamicColors_private:surface(): DynamicColor
	return MaterialDynamicColors.colorSpec:surface()
end
function MaterialDynamicColors_private:surfaceDim(): DynamicColor
	return MaterialDynamicColors.colorSpec:surfaceDim()
end
function MaterialDynamicColors_private:surfaceBright(): DynamicColor
	return MaterialDynamicColors.colorSpec:surfaceBright()
end
function MaterialDynamicColors_private:surfaceContainerLowest(): DynamicColor
	return MaterialDynamicColors.colorSpec:surfaceContainerLowest()
end
function MaterialDynamicColors_private:surfaceContainerLow(): DynamicColor
	return MaterialDynamicColors.colorSpec:surfaceContainerLow()
end
function MaterialDynamicColors_private:surfaceContainer(): DynamicColor
	return MaterialDynamicColors.colorSpec:surfaceContainer()
end
function MaterialDynamicColors_private:surfaceContainerHigh(): DynamicColor
	return MaterialDynamicColors.colorSpec:surfaceContainerHigh()
end
function MaterialDynamicColors_private:surfaceContainerHighest(): DynamicColor
	return MaterialDynamicColors.colorSpec:surfaceContainerHighest()
end
function MaterialDynamicColors_private:onSurface(): DynamicColor
	return MaterialDynamicColors.colorSpec:onSurface()
end
function MaterialDynamicColors_private:surfaceVariant(): DynamicColor
	return MaterialDynamicColors.colorSpec:surfaceVariant()
end
function MaterialDynamicColors_private:onSurfaceVariant(): DynamicColor
	return MaterialDynamicColors.colorSpec:onSurfaceVariant()
end
function MaterialDynamicColors_private:outline(): DynamicColor
	return MaterialDynamicColors.colorSpec:outline()
end
function MaterialDynamicColors_private:outlineVariant(): DynamicColor
	return MaterialDynamicColors.colorSpec:outlineVariant()
end
function MaterialDynamicColors_private:inverseSurface(): DynamicColor
	return MaterialDynamicColors.colorSpec:inverseSurface()
end
function MaterialDynamicColors_private:inverseOnSurface(): DynamicColor
	return MaterialDynamicColors.colorSpec:inverseOnSurface()
end
function MaterialDynamicColors_private:shadow(): DynamicColor
	return MaterialDynamicColors.colorSpec:shadow()
end
function MaterialDynamicColors_private:scrim(): DynamicColor
	return MaterialDynamicColors.colorSpec:scrim()
end
function MaterialDynamicColors_private:surfaceTint(): DynamicColor
	return MaterialDynamicColors.colorSpec:surfaceTint()
end
function MaterialDynamicColors_private:primary(): DynamicColor
	return MaterialDynamicColors.colorSpec:primary()
end
function MaterialDynamicColors_private:primaryDim(): DynamicColor | nil
	return MaterialDynamicColors.colorSpec:primaryDim()
end
function MaterialDynamicColors_private:onPrimary(): DynamicColor
	return MaterialDynamicColors.colorSpec:onPrimary()
end
function MaterialDynamicColors_private:primaryContainer(): DynamicColor
	return MaterialDynamicColors.colorSpec:primaryContainer()
end
function MaterialDynamicColors_private:onPrimaryContainer(): DynamicColor
	return MaterialDynamicColors.colorSpec:onPrimaryContainer()
end
function MaterialDynamicColors_private:inversePrimary(): DynamicColor
	return MaterialDynamicColors.colorSpec:inversePrimary()
end
function MaterialDynamicColors_private:primaryFixed(): DynamicColor
	return MaterialDynamicColors.colorSpec:primaryFixed()
end
function MaterialDynamicColors_private:primaryFixedDim(): DynamicColor
	return MaterialDynamicColors.colorSpec:primaryFixedDim()
end
function MaterialDynamicColors_private:onPrimaryFixed(): DynamicColor
	return MaterialDynamicColors.colorSpec:onPrimaryFixed()
end
function MaterialDynamicColors_private:onPrimaryFixedVariant(): DynamicColor
	return MaterialDynamicColors.colorSpec:onPrimaryFixedVariant()
end
function MaterialDynamicColors_private:secondary(): DynamicColor
	return MaterialDynamicColors.colorSpec:secondary()
end
function MaterialDynamicColors_private:secondaryDim(): DynamicColor | nil
	return MaterialDynamicColors.colorSpec:secondaryDim()
end
function MaterialDynamicColors_private:onSecondary(): DynamicColor
	return MaterialDynamicColors.colorSpec:onSecondary()
end
function MaterialDynamicColors_private:secondaryContainer(): DynamicColor
	return MaterialDynamicColors.colorSpec:secondaryContainer()
end
function MaterialDynamicColors_private:onSecondaryContainer(): DynamicColor
	return MaterialDynamicColors.colorSpec:onSecondaryContainer()
end
function MaterialDynamicColors_private:secondaryFixed(): DynamicColor
	return MaterialDynamicColors.colorSpec:secondaryFixed()
end
function MaterialDynamicColors_private:secondaryFixedDim(): DynamicColor
	return MaterialDynamicColors.colorSpec:secondaryFixedDim()
end
function MaterialDynamicColors_private:onSecondaryFixed(): DynamicColor
	return MaterialDynamicColors.colorSpec:onSecondaryFixed()
end
function MaterialDynamicColors_private:onSecondaryFixedVariant(): DynamicColor
	return MaterialDynamicColors.colorSpec:onSecondaryFixedVariant()
end
function MaterialDynamicColors_private:tertiary(): DynamicColor
	return MaterialDynamicColors.colorSpec:tertiary()
end
function MaterialDynamicColors_private:tertiaryDim(): DynamicColor | nil
	return MaterialDynamicColors.colorSpec:tertiaryDim()
end
function MaterialDynamicColors_private:onTertiary(): DynamicColor
	return MaterialDynamicColors.colorSpec:onTertiary()
end
function MaterialDynamicColors_private:tertiaryContainer(): DynamicColor
	return MaterialDynamicColors.colorSpec:tertiaryContainer()
end
function MaterialDynamicColors_private:onTertiaryContainer(): DynamicColor
	return MaterialDynamicColors.colorSpec:onTertiaryContainer()
end
function MaterialDynamicColors_private:tertiaryFixed(): DynamicColor
	return MaterialDynamicColors.colorSpec:tertiaryFixed()
end
function MaterialDynamicColors_private:tertiaryFixedDim(): DynamicColor
	return MaterialDynamicColors.colorSpec:tertiaryFixedDim()
end
function MaterialDynamicColors_private:onTertiaryFixed(): DynamicColor
	return MaterialDynamicColors.colorSpec:onTertiaryFixed()
end
function MaterialDynamicColors_private:onTertiaryFixedVariant(): DynamicColor
	return MaterialDynamicColors.colorSpec:onTertiaryFixedVariant()
end
function MaterialDynamicColors_private:error_(): DynamicColor
	return MaterialDynamicColors.colorSpec:error_()
end
function MaterialDynamicColors_private:errorDim(): DynamicColor | nil
	return MaterialDynamicColors.colorSpec:errorDim()
end
function MaterialDynamicColors_private:onError(): DynamicColor
	return MaterialDynamicColors.colorSpec:onError()
end
function MaterialDynamicColors_private:errorContainer(): DynamicColor
	return MaterialDynamicColors.colorSpec:errorContainer()
end
function MaterialDynamicColors_private:onErrorContainer(): DynamicColor
	return MaterialDynamicColors.colorSpec:onErrorContainer()
end
function MaterialDynamicColors_private.highestSurface(s: DynamicScheme): DynamicColor
	return MaterialDynamicColors.colorSpec:highestSurface(s)
end

MaterialDynamicColors.primaryPaletteKeyColor =
	MaterialDynamicColors.colorSpec:primaryPaletteKeyColor()
MaterialDynamicColors.secondaryPaletteKeyColor =
	MaterialDynamicColors.colorSpec:secondaryPaletteKeyColor()
MaterialDynamicColors.tertiaryPaletteKeyColor =
	MaterialDynamicColors.colorSpec:tertiaryPaletteKeyColor()
MaterialDynamicColors.neutralPaletteKeyColor =
	MaterialDynamicColors.colorSpec:neutralPaletteKeyColor()
MaterialDynamicColors.neutralVariantPaletteKeyColor =
	MaterialDynamicColors.colorSpec:neutralVariantPaletteKeyColor()
MaterialDynamicColors.background = MaterialDynamicColors.colorSpec:background()
MaterialDynamicColors.onBackground = MaterialDynamicColors.colorSpec:onBackground()
MaterialDynamicColors.surface = MaterialDynamicColors.colorSpec:surface()
MaterialDynamicColors.surfaceDim = MaterialDynamicColors.colorSpec:surfaceDim()
MaterialDynamicColors.surfaceBright = MaterialDynamicColors.colorSpec:surfaceBright()
MaterialDynamicColors.surfaceContainerLowest =
	MaterialDynamicColors.colorSpec:surfaceContainerLowest()
MaterialDynamicColors.surfaceContainerLow = MaterialDynamicColors.colorSpec:surfaceContainerLow()
MaterialDynamicColors.surfaceContainer = MaterialDynamicColors.colorSpec:surfaceContainer()
MaterialDynamicColors.surfaceContainerHigh = MaterialDynamicColors.colorSpec:surfaceContainerHigh()
MaterialDynamicColors.surfaceContainerHighest =
	MaterialDynamicColors.colorSpec:surfaceContainerHighest()
MaterialDynamicColors.onSurface = MaterialDynamicColors.colorSpec:onSurface()
MaterialDynamicColors.surfaceVariant = MaterialDynamicColors.colorSpec:surfaceVariant()
MaterialDynamicColors.onSurfaceVariant = MaterialDynamicColors.colorSpec:onSurfaceVariant()
MaterialDynamicColors.inverseSurface = MaterialDynamicColors.colorSpec:inverseSurface()
MaterialDynamicColors.inverseOnSurface = MaterialDynamicColors.colorSpec:inverseOnSurface()
MaterialDynamicColors.outline = MaterialDynamicColors.colorSpec:outline()
MaterialDynamicColors.outlineVariant = MaterialDynamicColors.colorSpec:outlineVariant()
MaterialDynamicColors.shadow = MaterialDynamicColors.colorSpec:shadow()
MaterialDynamicColors.scrim = MaterialDynamicColors.colorSpec:scrim()
MaterialDynamicColors.surfaceTint = MaterialDynamicColors.colorSpec:surfaceTint()
MaterialDynamicColors.primary = MaterialDynamicColors.colorSpec:primary()
MaterialDynamicColors.onPrimary = MaterialDynamicColors.colorSpec:onPrimary()
MaterialDynamicColors.primaryContainer = MaterialDynamicColors.colorSpec:primaryContainer()
MaterialDynamicColors.onPrimaryContainer = MaterialDynamicColors.colorSpec:onPrimaryContainer()
MaterialDynamicColors.inversePrimary = MaterialDynamicColors.colorSpec:inversePrimary()
MaterialDynamicColors.secondary = MaterialDynamicColors.colorSpec:secondary()
MaterialDynamicColors.onSecondary = MaterialDynamicColors.colorSpec:onSecondary()
MaterialDynamicColors.secondaryContainer = MaterialDynamicColors.colorSpec:secondaryContainer()
MaterialDynamicColors.onSecondaryContainer = MaterialDynamicColors.colorSpec:onSecondaryContainer()
MaterialDynamicColors.tertiary = MaterialDynamicColors.colorSpec:tertiary()
MaterialDynamicColors.onTertiary = MaterialDynamicColors.colorSpec:onTertiary()
MaterialDynamicColors.tertiaryContainer = MaterialDynamicColors.colorSpec:tertiaryContainer()
MaterialDynamicColors.onTertiaryContainer = MaterialDynamicColors.colorSpec:onTertiaryContainer()
MaterialDynamicColors.error_ = MaterialDynamicColors.colorSpec:error_()
MaterialDynamicColors.onError = MaterialDynamicColors.colorSpec:onError()
MaterialDynamicColors.errorContainer = MaterialDynamicColors.colorSpec:errorContainer()
MaterialDynamicColors.onErrorContainer = MaterialDynamicColors.colorSpec:onErrorContainer()
MaterialDynamicColors.primaryFixed = MaterialDynamicColors.colorSpec:primaryFixed()
MaterialDynamicColors.primaryFixedDim = MaterialDynamicColors.colorSpec:primaryFixedDim()
MaterialDynamicColors.onPrimaryFixed = MaterialDynamicColors.colorSpec:onPrimaryFixed()
MaterialDynamicColors.onPrimaryFixedVariant =
	MaterialDynamicColors.colorSpec:onPrimaryFixedVariant()
MaterialDynamicColors.secondaryFixed = MaterialDynamicColors.colorSpec:secondaryFixed()
MaterialDynamicColors.secondaryFixedDim = MaterialDynamicColors.colorSpec:secondaryFixedDim()
MaterialDynamicColors.onSecondaryFixed = MaterialDynamicColors.colorSpec:onSecondaryFixed()
MaterialDynamicColors.onSecondaryFixedVariant =
	MaterialDynamicColors.colorSpec:onSecondaryFixedVariant()
MaterialDynamicColors.tertiaryFixed = MaterialDynamicColors.colorSpec:tertiaryFixed()
MaterialDynamicColors.tertiaryFixedDim = MaterialDynamicColors.colorSpec:tertiaryFixedDim()
MaterialDynamicColors.onTertiaryFixed = MaterialDynamicColors.colorSpec:onTertiaryFixed()
MaterialDynamicColors.onTertiaryFixedVariant =
	MaterialDynamicColors.colorSpec:onTertiaryFixedVariant()

exports.MaterialDynamicColors = MaterialDynamicColors
return exports
