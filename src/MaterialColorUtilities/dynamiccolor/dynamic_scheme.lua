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
local Boolean = LuauPolyfill.Boolean
local Error = LuauPolyfill.Error
type Array<T> = LuauPolyfill.Array<T>
local exports = {}
local DislikeAnalyzer = require(script.Parent.Parent.dislike["dislike_analyzer"]).DislikeAnalyzer
local Hct = require(script.Parent.Parent.hct["hct"]).Hct
local TonalPalette = require(script.Parent.Parent.palettes["tonal_palette"]).TonalPalette
local TemperatureCache =
	require(script.Parent.Parent.temperature["temperature_cache"]).TemperatureCache
local math_ = require(script.Parent.Parent.utils["math_utils"])
--local DynamicColor = require(script.Parent["dynamic_color"]).DynamicColor
local MaterialDynamicColors =
	require(script.Parent["material_dynamic_colors"]).MaterialDynamicColors
local Variant = require(script.Parent["variant"]).Variant
--[[*
 * The platform on which this scheme is intended to be used. Only used in the
 * 2025 spec.
 ]]
export type Platform = "phone" | "watch"
--[[*
 * @param sourceColorArgb The source color of the theme as an ARGB 32-bit
 *     integer.
 * @param variant The variant, or style, of the theme.
 * @param contrastLevel Value from -1 to 1. -1 represents minimum contrast, 0
 *     represents standard (i.e. the design as spec'd), and 1 represents maximum
 *     contrast.
 * @param isDark Whether the scheme is in dark mode or light mode.
 * @param platform The platform on which this scheme is intended to be used.
 * @param specVersion The version of the design spec that this scheme is based
 *     on.
 * @param primaryPalette Given a tone, produces a color. Hue and chroma of the
 *     color are specified in the design specification of the variant. Usually
 *     colorful.
 * @param secondaryPalette Given a tone, produces a color. Hue and chroma of the
 *     color are specified in the design specification of the variant. Usually
 *     less colorful.
 * @param tertiaryPalette Given a tone, produces a color. Hue and chroma of the
 *     color are specified in the design specification of the variant. Usually a
 *     different hue from primary and colorful.
 * @param neutralPalette Given a tone, produces a color. Hue and chroma of the
 *     color are specified in the design specification of the variant. Usually
 *     not colorful at all, intended for background & surface colors.
 * @param neutralVariantPalette Given a tone, produces a color. Hue and chroma
 *     of the color are specified in the design specification of the variant.
 *     Usually not colorful, but slightly more colorful than Neutral. Intended
 *     for backgrounds & surfaces.
 ]]
type DynamicSchemeOptions = {
	sourceColorHct: Hct,
	variant: Variant,
	contrastLevel: number,
	isDark: boolean,
	platform: Platform?,
	specVersion: SpecVersion?,
	primaryPalette: TonalPalette?,
	secondaryPalette: TonalPalette?,
	tertiaryPalette: TonalPalette?,
	neutralPalette: TonalPalette?,
	neutralVariantPalette: TonalPalette?,
	errorPalette: TonalPalette?,
}
--[[*
 * A delegate that provides the palettes of a DynamicScheme.
 *
 * This is used to allow different implementations of the palette calculation
 * logic for different spec versions.
 ]]
type DynamicSchemePalettesDelegate = {
	getPrimaryPalette: (
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getSecondaryPalette: (
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getTertiaryPalette: (
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getNeutralPalette: (
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getNeutralVariantPalette: (
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getErrorPalette: (
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette | nil,
}
--[[*
 * Constructed by a set of values representing the current UI state (such as
 * whether or not its dark theme, what the theme style is, etc.), and
 * provides a set of TonalPalettes that can create colors that fit in
 * with the theme style. Used by DynamicColor to resolve into a color.
 ]]
export type DynamicScheme = { --[[*
   * The source color of the theme as an HCT color.
   ]]
	sourceColorHct: Hct,
	--[[* The source color of the theme as an ARGB 32-bit integer. ]]
	sourceColorArgb: number,
	--[[* The variant, or style, of the theme. ]]
	variant: Variant,
	--[[*
   * Value from -1 to 1. -1 represents minimum contrast. 0 represents standard
   * (i.e. the design as spec'd), and 1 represents maximum contrast.
   ]]
	contrastLevel: number,
	--[[* Whether the scheme is in dark mode or light mode. ]]
	isDark: boolean,
	--[[* The platform on which this scheme is intended to be used. ]]
	platform: Platform,
	--[[* The version of the design spec that this scheme is based on. ]]
	specVersion: SpecVersion,
	--[[*
   * Given a tone, produces a color. Hue and chroma of the
   * color are specified in the design specification of the variant. Usually
   * colorful.
   ]]
	primaryPalette: TonalPalette,
	--[[*
   * Given a tone, produces a color. Hue and chroma of
   * the color are specified in the design specification of the variant. Usually
   * less colorful.
   ]]
	secondaryPalette: TonalPalette,
	--[[*
   * Given a tone, produces a color. Hue and chroma of
   * the color are specified in the design specification of the variant. Usually
   * a different hue from primary and colorful.
   ]]
	tertiaryPalette: TonalPalette,
	--[[*
   * Given a tone, produces a color. Hue and chroma of the
   * color are specified in the design specification of the variant. Usually not
   * colorful at all, intended for background & surface colors.
   ]]
	neutralPalette: TonalPalette,
	--[[*
   * Given a tone, produces a color. Hue and chroma
   * of the color are specified in the design specification of the variant.
   * Usually not colorful, but slightly more colorful than Neutral. Intended for
   * backgrounds & surfaces.
   ]]
	neutralVariantPalette: TonalPalette,
	--[[*
   * Given a tone, produces a reddish, colorful, color.
   ]]
	errorPalette: TonalPalette,
	colors: MaterialDynamicColors,
	toString: (self: DynamicScheme) -> string,
	--[[*
   * Returns a new hue based on a piecewise function and input color hue.
   *
   * For example, for the following function:
   * result = 26 if 0 <= hue < 101
   * result = 39 if 101 <= hue < 210
   * result = 28 if 210 <= hue < 360
   *
   * call the function as:
   *
   * const hueBreakpoints = [0, 101, 210, 360];
   * const hues = [26, 39, 28];
   * const result = scheme.piecewise(hue, hueBreakpoints, hues);
   *
   * @param sourceColorHct The input value.
   * @param hueBreakpoints The breakpoints, in sorted order. No default lower or
   *     upper bounds are assumed.
   * @param hues The hues that should be applied when source color's hue is >=
   *     the same index in hueBrakpoints array, and < the hue at the next index
   *     in hueBrakpoints array. Otherwise, the source color's hue is returned.
   ]]
	getArgb: (self: DynamicScheme, dynamicColor: DynamicColor) -> number,
	getHct: (self: DynamicScheme, dynamicColor: DynamicColor) -> Hct,
	-- Palette key colors
	primaryPaletteKeyColor: (self: DynamicScheme) -> number,
	secondaryPaletteKeyColor: (self: DynamicScheme) -> number,
	tertiaryPaletteKeyColor: (self: DynamicScheme) -> number,
	neutralPaletteKeyColor: (self: DynamicScheme) -> number,
	neutralVariantPaletteKeyColor: (self: DynamicScheme) -> number,
	errorPaletteKeyColor: (self: DynamicScheme) -> number,
	-- Surface colors
	background: (self: DynamicScheme) -> number,
	onBackground: (self: DynamicScheme) -> number,
	surface: (self: DynamicScheme) -> number,
	surfaceDim: (self: DynamicScheme) -> number,
	surfaceBright: (self: DynamicScheme) -> number,
	surfaceContainerLowest: (self: DynamicScheme) -> number,
	surfaceContainerLow: (self: DynamicScheme) -> number,
	surfaceContainer: (self: DynamicScheme) -> number,
	surfaceContainerHigh: (self: DynamicScheme) -> number,
	surfaceContainerHighest: (self: DynamicScheme) -> number,
	onSurface: (self: DynamicScheme) -> number,
	surfaceVariant: (self: DynamicScheme) -> number,
	onSurfaceVariant: (self: DynamicScheme) -> number,
	inverseSurface: (self: DynamicScheme) -> number,
	inverseOnSurface: (self: DynamicScheme) -> number,
	outline: (self: DynamicScheme) -> number,
	outlineVariant: (self: DynamicScheme) -> number,
	shadow: (self: DynamicScheme) -> number,
	scrim: (self: DynamicScheme) -> number,
	surfaceTint: (self: DynamicScheme) -> number,
	-- Primary colors
	primary: (self: DynamicScheme) -> number,
	primaryDim: (self: DynamicScheme) -> number,
	onPrimary: (self: DynamicScheme) -> number,
	primaryContainer: (self: DynamicScheme) -> number,
	onPrimaryContainer: (self: DynamicScheme) -> number,
	primaryFixed: (self: DynamicScheme) -> number,
	primaryFixedDim: (self: DynamicScheme) -> number,
	onPrimaryFixed: (self: DynamicScheme) -> number,
	onPrimaryFixedVariant: (self: DynamicScheme) -> number,
	inversePrimary: (self: DynamicScheme) -> number,
	-- Secondary colors
	secondary: (self: DynamicScheme) -> number,
	secondaryDim: (self: DynamicScheme) -> number,
	onSecondary: (self: DynamicScheme) -> number,
	secondaryContainer: (self: DynamicScheme) -> number,
	onSecondaryContainer: (self: DynamicScheme) -> number,
	secondaryFixed: (self: DynamicScheme) -> number,
	secondaryFixedDim: (self: DynamicScheme) -> number,
	onSecondaryFixed: (self: DynamicScheme) -> number,
	onSecondaryFixedVariant: (self: DynamicScheme) -> number,
	-- Tertiary colors
	tertiary: (self: DynamicScheme) -> number,
	tertiaryDim: (self: DynamicScheme) -> number,
	onTertiary: (self: DynamicScheme) -> number,
	tertiaryContainer: (self: DynamicScheme) -> number,
	onTertiaryContainer: (self: DynamicScheme) -> number,
	tertiaryFixed: (self: DynamicScheme) -> number,
	tertiaryFixedDim: (self: DynamicScheme) -> number,
	onTertiaryFixed: (self: DynamicScheme) -> number,
	onTertiaryFixedVariant: (self: DynamicScheme) -> number,
	-- Error colors
	error_: (self: DynamicScheme) -> number,
	errorDim: (self: DynamicScheme) -> number,
	onError: (self: DynamicScheme) -> number,
	errorContainer: (self: DynamicScheme) -> number,
	onErrorContainer: (self: DynamicScheme) -> number,
}
type DynamicScheme_statics = { new: (args: DynamicSchemeOptions) -> DynamicScheme }
local DynamicScheme = {} :: DynamicScheme & DynamicScheme_statics;
(DynamicScheme :: any).__index = DynamicScheme
DynamicScheme.DEFAULT_SPEC_VERSION = "2021"
DynamicScheme.DEFAULT_PLATFORM = "phone"
function DynamicScheme.new(args: DynamicSchemeOptions): DynamicScheme
	local self = setmetatable({}, DynamicScheme)
	self.sourceColorArgb = args.sourceColorHct:toInt()
	self.variant = args.variant
	self.contrastLevel = args.contrastLevel
	self.isDark = args.isDark
	self.platform = if args.platform ~= nil then args.platform else "phone"
	self.specVersion = if args.specVersion ~= nil then args.specVersion else "2021"
	self.sourceColorHct = args.sourceColorHct
	self.primaryPalette = if args.primaryPalette ~= nil
		then args.primaryPalette
		else getSpec(self.specVersion):getPrimaryPalette(
			self.variant,
			args.sourceColorHct,
			self.isDark,
			self.platform,
			self.contrastLevel
		)
	self.secondaryPalette = if args.secondaryPalette ~= nil
		then args.secondaryPalette
		else getSpec(self.specVersion):getSecondaryPalette(
			self.variant,
			args.sourceColorHct,
			self.isDark,
			self.platform,
			self.contrastLevel
		)
	self.tertiaryPalette = if args.tertiaryPalette ~= nil
		then args.tertiaryPalette
		else getSpec(self.specVersion):getTertiaryPalette(
			self.variant,
			args.sourceColorHct,
			self.isDark,
			self.platform,
			self.contrastLevel
		)
	self.neutralPalette = if args.neutralPalette ~= nil
		then args.neutralPalette
		else getSpec(self.specVersion):getNeutralPalette(
			self.variant,
			args.sourceColorHct,
			self.isDark,
			self.platform,
			self.contrastLevel
		)
	self.neutralVariantPalette = if args.neutralVariantPalette ~= nil
		then args.neutralVariantPalette
		else getSpec(self.specVersion):getNeutralVariantPalette(
			self.variant,
			args.sourceColorHct,
			self.isDark,
			self.platform,
			self.contrastLevel
		)
	local ref = if args.errorPalette ~= nil
		then args.errorPalette
		else getSpec(self.specVersion):getErrorPalette(
			self.variant,
			args.sourceColorHct,
			self.isDark,
			self.platform,
			self.contrastLevel
		)
	self.errorPalette = if ref ~= nil then ref else TonalPalette:fromHueAndChroma(25.0, 84.0)
	self.colors = MaterialDynamicColors.new()
	return (self :: any) :: DynamicScheme
end
function DynamicScheme:toString(): string
	return "Scheme: "
		.. ("variant=%s, "):format(tostring(Variant[tostring(self.variant)]))
		.. ("mode=%s, "):format(if Boolean.toJSBoolean(self.isDark) then "dark" else "light")
		.. ("platform=%s, "):format(tostring(self.platform))
		.. ("contrastLevel=%s, "):format(tostring(self.contrastLevel:toFixed(1)))
		.. ("seed=%s, "):format(tostring(tostring(self.sourceColorHct)))
		.. ("specVersion=%s"):format(tostring(self.specVersion))
end
function DynamicScheme.getPiecewiseHue(
	sourceColorHct: Hct,
	hueBreakpoints: Array<number>,
	hues: Array<number>
): number
	local size = math.min(hueBreakpoints.length - 1, hues.length)
	local sourceHue = sourceColorHct.hue
	do
		local i = 0
		while
			i
			< size --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		do
			if
				sourceHue >= hueBreakpoints[tostring(i)] --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
				and sourceHue < hueBreakpoints[tostring(i + 1)] --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
			then
				return math_:sanitizeDegreesDouble(hues[tostring(i)])
			end
			i += 1
		end
	end
	-- No condition matched, return the source hue.
	return sourceHue
end
function DynamicScheme.getRotatedHue(
	sourceColorHct: Hct,
	hueBreakpoints: Array<number>,
	rotations: Array<number>
): number
	local rotation = DynamicScheme:getPiecewiseHue(sourceColorHct, hueBreakpoints, rotations)
	if
		math.min(hueBreakpoints.length - 1, rotations.length)
		<= 0 --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]]
	then
		-- No condition matched, return the source hue.
		rotation = 0
	end
	return math_:sanitizeDegreesDouble(sourceColorHct.hue + rotation)
end
function DynamicScheme:getArgb(dynamicColor: DynamicColor): number
	return dynamicColor:getArgb(self)
end
function DynamicScheme:getHct(dynamicColor: DynamicColor): Hct
	return dynamicColor:getHct(self)
end
function DynamicScheme:primaryPaletteKeyColor(): number
	return self:getArgb(self.colors:primaryPaletteKeyColor())
end
function DynamicScheme:secondaryPaletteKeyColor(): number
	return self:getArgb(self.colors:secondaryPaletteKeyColor())
end
function DynamicScheme:tertiaryPaletteKeyColor(): number
	return self:getArgb(self.colors:tertiaryPaletteKeyColor())
end
function DynamicScheme:neutralPaletteKeyColor(): number
	return self:getArgb(self.colors:neutralPaletteKeyColor())
end
function DynamicScheme:neutralVariantPaletteKeyColor(): number
	return self:getArgb(self.colors:neutralVariantPaletteKeyColor())
end
function DynamicScheme:errorPaletteKeyColor(): number
	return self:getArgb(self.colors:errorPaletteKeyColor())
end
function DynamicScheme:background(): number
	return self:getArgb(self.colors:background())
end
function DynamicScheme:onBackground(): number
	return self:getArgb(self.colors:onBackground())
end
function DynamicScheme:surface(): number
	return self:getArgb(self.colors:surface())
end
function DynamicScheme:surfaceDim(): number
	return self:getArgb(self.colors:surfaceDim())
end
function DynamicScheme:surfaceBright(): number
	return self:getArgb(self.colors:surfaceBright())
end
function DynamicScheme:surfaceContainerLowest(): number
	return self:getArgb(self.colors:surfaceContainerLowest())
end
function DynamicScheme:surfaceContainerLow(): number
	return self:getArgb(self.colors:surfaceContainerLow())
end
function DynamicScheme:surfaceContainer(): number
	return self:getArgb(self.colors:surfaceContainer())
end
function DynamicScheme:surfaceContainerHigh(): number
	return self:getArgb(self.colors:surfaceContainerHigh())
end
function DynamicScheme:surfaceContainerHighest(): number
	return self:getArgb(self.colors:surfaceContainerHighest())
end
function DynamicScheme:onSurface(): number
	return self:getArgb(self.colors:onSurface())
end
function DynamicScheme:surfaceVariant(): number
	return self:getArgb(self.colors:surfaceVariant())
end
function DynamicScheme:onSurfaceVariant(): number
	return self:getArgb(self.colors:onSurfaceVariant())
end
function DynamicScheme:inverseSurface(): number
	return self:getArgb(self.colors:inverseSurface())
end
function DynamicScheme:inverseOnSurface(): number
	return self:getArgb(self.colors:inverseOnSurface())
end
function DynamicScheme:outline(): number
	return self:getArgb(self.colors:outline())
end
function DynamicScheme:outlineVariant(): number
	return self:getArgb(self.colors:outlineVariant())
end
function DynamicScheme:shadow(): number
	return self:getArgb(self.colors:shadow())
end
function DynamicScheme:scrim(): number
	return self:getArgb(self.colors:scrim())
end
function DynamicScheme:surfaceTint(): number
	return self:getArgb(self.colors:surfaceTint())
end
function DynamicScheme:primary(): number
	return self:getArgb(self.colors:primary())
end
function DynamicScheme:primaryDim(): number
	local primaryDim = self.colors:primaryDim()
	if primaryDim == nil then
		error(Error.new("`primaryDim` color is undefined prior to 2025 spec."))
	end
	return self:getArgb(primaryDim)
end
function DynamicScheme:onPrimary(): number
	return self:getArgb(self.colors:onPrimary())
end
function DynamicScheme:primaryContainer(): number
	return self:getArgb(self.colors:primaryContainer())
end
function DynamicScheme:onPrimaryContainer(): number
	return self:getArgb(self.colors:onPrimaryContainer())
end
function DynamicScheme:primaryFixed(): number
	return self:getArgb(self.colors:primaryFixed())
end
function DynamicScheme:primaryFixedDim(): number
	return self:getArgb(self.colors:primaryFixedDim())
end
function DynamicScheme:onPrimaryFixed(): number
	return self:getArgb(self.colors:onPrimaryFixed())
end
function DynamicScheme:onPrimaryFixedVariant(): number
	return self:getArgb(self.colors:onPrimaryFixedVariant())
end
function DynamicScheme:inversePrimary(): number
	return self:getArgb(self.colors:inversePrimary())
end
function DynamicScheme:secondary(): number
	return self:getArgb(self.colors:secondary())
end
function DynamicScheme:secondaryDim(): number
	local secondaryDim = self.colors:secondaryDim()
	if secondaryDim == nil then
		error(Error.new("`secondaryDim` color is undefined prior to 2025 spec."))
	end
	return self:getArgb(secondaryDim)
end
function DynamicScheme:onSecondary(): number
	return self:getArgb(self.colors:onSecondary())
end
function DynamicScheme:secondaryContainer(): number
	return self:getArgb(self.colors:secondaryContainer())
end
function DynamicScheme:onSecondaryContainer(): number
	return self:getArgb(self.colors:onSecondaryContainer())
end
function DynamicScheme:secondaryFixed(): number
	return self:getArgb(self.colors:secondaryFixed())
end
function DynamicScheme:secondaryFixedDim(): number
	return self:getArgb(self.colors:secondaryFixedDim())
end
function DynamicScheme:onSecondaryFixed(): number
	return self:getArgb(self.colors:onSecondaryFixed())
end
function DynamicScheme:onSecondaryFixedVariant(): number
	return self:getArgb(self.colors:onSecondaryFixedVariant())
end
function DynamicScheme:tertiary(): number
	return self:getArgb(self.colors:tertiary())
end
function DynamicScheme:tertiaryDim(): number
	local tertiaryDim = self.colors:tertiaryDim()
	if tertiaryDim == nil then
		error(Error.new("`tertiaryDim` color is undefined prior to 2025 spec."))
	end
	return self:getArgb(tertiaryDim)
end
function DynamicScheme:onTertiary(): number
	return self:getArgb(self.colors:onTertiary())
end
function DynamicScheme:tertiaryContainer(): number
	return self:getArgb(self.colors:tertiaryContainer())
end
function DynamicScheme:onTertiaryContainer(): number
	return self:getArgb(self.colors:onTertiaryContainer())
end
function DynamicScheme:tertiaryFixed(): number
	return self:getArgb(self.colors:tertiaryFixed())
end
function DynamicScheme:tertiaryFixedDim(): number
	return self:getArgb(self.colors:tertiaryFixedDim())
end
function DynamicScheme:onTertiaryFixed(): number
	return self:getArgb(self.colors:onTertiaryFixed())
end
function DynamicScheme:onTertiaryFixedVariant(): number
	return self:getArgb(self.colors:onTertiaryFixedVariant())
end
function DynamicScheme:error_(): number
	return self:getArgb(self.colors:error_())
end
function DynamicScheme:errorDim(): number
	local errorDim = self.colors:errorDim()
	if errorDim == nil then
		error(Error.new("`errorDim` color is undefined prior to 2025 spec."))
	end
	return self:getArgb(errorDim)
end
function DynamicScheme:onError(): number
	return self:getArgb(self.colors:onError())
end
function DynamicScheme:errorContainer(): number
	return self:getArgb(self.colors:errorContainer())
end
function DynamicScheme:onErrorContainer(): number
	return self:getArgb(self.colors:onErrorContainer())
end
exports.DynamicScheme = DynamicScheme
--[[*
 * A delegate for the palettes of a DynamicScheme in the 2021 spec.
 ]]
type DynamicSchemePalettesDelegateImpl2021 = { --////////////////////////////////////////////////////////////////
	-- Scheme Palettes                                              //
	--////////////////////////////////////////////////////////////////
	getPrimaryPalette: (
		self: DynamicSchemePalettesDelegateImpl2021,
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getSecondaryPalette: (
		self: DynamicSchemePalettesDelegateImpl2021,
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getTertiaryPalette: (
		self: DynamicSchemePalettesDelegateImpl2021,
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getNeutralPalette: (
		self: DynamicSchemePalettesDelegateImpl2021,
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getNeutralVariantPalette: (
		self: DynamicSchemePalettesDelegateImpl2021,
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getErrorPalette: (
		self: DynamicSchemePalettesDelegateImpl2021,
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette | nil,
}
type DynamicSchemePalettesDelegateImpl2021_statics = {
	new: () -> DynamicSchemePalettesDelegateImpl2021,
}
local DynamicSchemePalettesDelegateImpl2021 =
	{} :: DynamicSchemePalettesDelegateImpl2021 & DynamicSchemePalettesDelegateImpl2021_statics;
(DynamicSchemePalettesDelegateImpl2021 :: any).__index = DynamicSchemePalettesDelegateImpl2021
function DynamicSchemePalettesDelegateImpl2021.new(): DynamicSchemePalettesDelegateImpl2021
	local self = setmetatable({}, DynamicSchemePalettesDelegateImpl2021)
	return (self :: any) :: DynamicSchemePalettesDelegateImpl2021
end
function DynamicSchemePalettesDelegateImpl2021:getPrimaryPalette(
	variant: Variant,
	sourceColorHct: Hct,
	isDark: boolean,
	platform: Platform,
	contrastLevel: number
): TonalPalette
	local condition_ = variant
	if condition_ == Variant.CONTENT or condition_ == Variant.FIDELITY then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, sourceColorHct.chroma)
	elseif condition_ == Variant.FRUIT_SALAD then
		return TonalPalette:fromHueAndChroma(
			math_:sanitizeDegreesDouble(sourceColorHct.hue - 50.0),
			48.0
		)
	elseif condition_ == Variant.MONOCHROME then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 0.0)
	elseif condition_ == Variant.NEUTRAL then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 12.0)
	elseif condition_ == Variant.RAINBOW then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 48.0)
	elseif condition_ == Variant.TONAL_SPOT then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 36.0)
	elseif condition_ == Variant.EXPRESSIVE then
		return TonalPalette:fromHueAndChroma(
			math_:sanitizeDegreesDouble(sourceColorHct.hue + 240),
			40
		)
	elseif condition_ == Variant.VIBRANT then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 200.0)
	else
		error(Error.new(("Unsupported variant: %s"):format(tostring(variant))))
	end
end
function DynamicSchemePalettesDelegateImpl2021:getSecondaryPalette(
	variant: Variant,
	sourceColorHct: Hct,
	isDark: boolean,
	platform: Platform,
	contrastLevel: number
): TonalPalette
	local condition_ = variant
	if condition_ == Variant.CONTENT or condition_ == Variant.FIDELITY then
		return TonalPalette:fromHueAndChroma(
			sourceColorHct.hue,
			math.max(sourceColorHct.chroma - 32.0, sourceColorHct.chroma * 0.5)
		)
	elseif condition_ == Variant.FRUIT_SALAD then
		return TonalPalette:fromHueAndChroma(
			math_:sanitizeDegreesDouble(sourceColorHct.hue - 50.0),
			36.0
		)
	elseif condition_ == Variant.MONOCHROME then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 0.0)
	elseif condition_ == Variant.NEUTRAL then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 8.0)
	elseif condition_ == Variant.RAINBOW then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 16.0)
	elseif condition_ == Variant.TONAL_SPOT then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 16.0)
	elseif condition_ == Variant.EXPRESSIVE then
		return TonalPalette:fromHueAndChroma(
			DynamicScheme:getRotatedHue(
				sourceColorHct,
				{ 0, 21, 51, 121, 151, 191, 271, 321, 360 },
				{ 45, 95, 45, 20, 45, 90, 45, 45, 45 }
			),
			24.0
		)
	elseif condition_ == Variant.VIBRANT then
		return TonalPalette:fromHueAndChroma(
			DynamicScheme:getRotatedHue(
				sourceColorHct,
				{ 0, 41, 61, 101, 131, 181, 251, 301, 360 },
				{ 18, 15, 10, 12, 15, 18, 15, 12, 12 }
			),
			24.0
		)
	else
		error(Error.new(("Unsupported variant: %s"):format(tostring(variant))))
	end
end
function DynamicSchemePalettesDelegateImpl2021:getTertiaryPalette(
	variant: Variant,
	sourceColorHct: Hct,
	isDark: boolean,
	platform: Platform,
	contrastLevel: number
): TonalPalette
	local condition_ = variant
	if condition_ == Variant.CONTENT then
		return TonalPalette:fromHct(
			DislikeAnalyzer:fixIfDisliked(
				TemperatureCache.new(sourceColorHct)
					:analogous(--[[ count= ]] 3, --[[ divisions= ]] 6)[
					3 --[[ ROBLOX adaptation: added 1 to array index ]]
				]
			)
		)
	elseif condition_ == Variant.FIDELITY then
		return TonalPalette:fromHct(
			DislikeAnalyzer:fixIfDisliked(TemperatureCache.new(sourceColorHct).complement)
		)
	elseif condition_ == Variant.FRUIT_SALAD then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 36.0)
	elseif condition_ == Variant.MONOCHROME then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 0.0)
	elseif condition_ == Variant.NEUTRAL then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 16.0)
	elseif condition_ == Variant.RAINBOW or condition_ == Variant.TONAL_SPOT then
		return TonalPalette:fromHueAndChroma(
			math_:sanitizeDegreesDouble(sourceColorHct.hue + 60.0),
			24.0
		)
	elseif condition_ == Variant.EXPRESSIVE then
		return TonalPalette:fromHueAndChroma(
			DynamicScheme:getRotatedHue(
				sourceColorHct,
				{ 0, 21, 51, 121, 151, 191, 271, 321, 360 },
				{ 120, 120, 20, 45, 20, 15, 20, 120, 120 }
			),
			32.0
		)
	elseif condition_ == Variant.VIBRANT then
		return TonalPalette:fromHueAndChroma(
			DynamicScheme:getRotatedHue(
				sourceColorHct,
				{ 0, 41, 61, 101, 131, 181, 251, 301, 360 },
				{ 35, 30, 20, 25, 30, 35, 30, 25, 25 }
			),
			32.0
		)
	else
		error(Error.new(("Unsupported variant: %s"):format(tostring(variant))))
	end
end
function DynamicSchemePalettesDelegateImpl2021:getNeutralPalette(
	variant: Variant,
	sourceColorHct: Hct,
	isDark: boolean,
	platform: Platform,
	contrastLevel: number
): TonalPalette
	local condition_ = variant
	if condition_ == Variant.CONTENT or condition_ == Variant.FIDELITY then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, sourceColorHct.chroma / 8.0)
	elseif condition_ == Variant.FRUIT_SALAD then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 10.0)
	elseif condition_ == Variant.MONOCHROME then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 0.0)
	elseif condition_ == Variant.NEUTRAL then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 2.0)
	elseif condition_ == Variant.RAINBOW then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 0.0)
	elseif condition_ == Variant.TONAL_SPOT then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 6.0)
	elseif condition_ == Variant.EXPRESSIVE then
		return TonalPalette:fromHueAndChroma(
			math_:sanitizeDegreesDouble(sourceColorHct.hue + 15),
			8
		)
	elseif condition_ == Variant.VIBRANT then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 10)
	else
		error(Error.new(("Unsupported variant: %s"):format(tostring(variant))))
	end
end
function DynamicSchemePalettesDelegateImpl2021:getNeutralVariantPalette(
	variant: Variant,
	sourceColorHct: Hct,
	isDark: boolean,
	platform: Platform,
	contrastLevel: number
): TonalPalette
	local condition_ = variant
	if condition_ == Variant.CONTENT then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, sourceColorHct.chroma / 8.0 + 4.0)
	elseif condition_ == Variant.FIDELITY then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, sourceColorHct.chroma / 8.0 + 4.0)
	elseif condition_ == Variant.FRUIT_SALAD then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 16.0)
	elseif condition_ == Variant.MONOCHROME then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 0.0)
	elseif condition_ == Variant.NEUTRAL then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 2.0)
	elseif condition_ == Variant.RAINBOW then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 0.0)
	elseif condition_ == Variant.TONAL_SPOT then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 8.0)
	elseif condition_ == Variant.EXPRESSIVE then
		return TonalPalette:fromHueAndChroma(
			math_:sanitizeDegreesDouble(sourceColorHct.hue + 15),
			12
		)
	elseif condition_ == Variant.VIBRANT then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 12)
	else
		error(Error.new(("Unsupported variant: %s"):format(tostring(variant))))
	end
end
function DynamicSchemePalettesDelegateImpl2021:getErrorPalette(
	variant: Variant,
	sourceColorHct: Hct,
	isDark: boolean,
	platform: Platform,
	contrastLevel: number
): TonalPalette | nil
	return nil
end
--[[*
 * A delegate for the palettes of a DynamicScheme in the 2025 spec.
 ]]
type DynamicSchemePalettesDelegateImpl2025 = DynamicSchemePalettesDelegateImpl2021 & { --////////////////////////////////////////////////////////////////
	-- Scheme Palettes                                              //
	--////////////////////////////////////////////////////////////////
	getPrimaryPalette: (
		self: DynamicSchemePalettesDelegateImpl2025,
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getSecondaryPalette: (
		self: DynamicSchemePalettesDelegateImpl2025,
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getTertiaryPalette: (
		self: DynamicSchemePalettesDelegateImpl2025,
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getNeutralPalette: (
		self: DynamicSchemePalettesDelegateImpl2025,
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getNeutralVariantPalette: (
		self: DynamicSchemePalettesDelegateImpl2025,
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getErrorPalette: (
		self: DynamicSchemePalettesDelegateImpl2025,
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette | nil,
}
type DynamicSchemePalettesDelegateImpl2025_private = DynamicSchemePalettesDelegateImpl2021 & { --
	-- *** PUBLIC ***
	--
	getPrimaryPalette: (
		self: DynamicSchemePalettesDelegateImpl2025_private,
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getSecondaryPalette: (
		self: DynamicSchemePalettesDelegateImpl2025_private,
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getTertiaryPalette: (
		self: DynamicSchemePalettesDelegateImpl2025_private,
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getNeutralPalette: (
		self: DynamicSchemePalettesDelegateImpl2025_private,
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getNeutralVariantPalette: (
		self: DynamicSchemePalettesDelegateImpl2025_private,
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette,
	getErrorPalette: (
		self: DynamicSchemePalettesDelegateImpl2025_private,
		variant: Variant,
		sourceColorHct: Hct,
		isDark: boolean,
		platform: Platform,
		contrastLevel: number
	) -> TonalPalette | nil,
}
type DynamicSchemePalettesDelegateImpl2025_statics = {
	new: () -> DynamicSchemePalettesDelegateImpl2025,
}
local DynamicSchemePalettesDelegateImpl2025 = (
	setmetatable({}, { __index = DynamicSchemePalettesDelegateImpl2021 }) :: any
) :: DynamicSchemePalettesDelegateImpl2025 & DynamicSchemePalettesDelegateImpl2025_statics
local DynamicSchemePalettesDelegateImpl2025_private =
	DynamicSchemePalettesDelegateImpl2025 :: DynamicSchemePalettesDelegateImpl2025_private & DynamicSchemePalettesDelegateImpl2025_statics;
(DynamicSchemePalettesDelegateImpl2025 :: any).__index = DynamicSchemePalettesDelegateImpl2025
function DynamicSchemePalettesDelegateImpl2025_private.new(): DynamicSchemePalettesDelegateImpl2025
	local self = setmetatable({}, DynamicSchemePalettesDelegateImpl2025) --[[ ROBLOX TODO: super constructor may be used ]]
	return (self :: any) :: DynamicSchemePalettesDelegateImpl2025
end
function DynamicSchemePalettesDelegateImpl2025_private:getPrimaryPalette(
	variant: Variant,
	sourceColorHct: Hct,
	isDark: boolean,
	platform: Platform,
	contrastLevel: number
): TonalPalette
	local condition_ = variant
	if condition_ == Variant.NEUTRAL then
		return TonalPalette:fromHueAndChroma(
			sourceColorHct.hue,
			if platform == "phone"
				then if Boolean.toJSBoolean(Hct:isBlue(sourceColorHct.hue)) then 12 else 8
				else if Boolean.toJSBoolean(Hct:isBlue(sourceColorHct.hue)) then 16 else 12
		)
	elseif condition_ == Variant.TONAL_SPOT then
		return TonalPalette:fromHueAndChroma(
			sourceColorHct.hue,
			if Boolean.toJSBoolean(platform == "phone" and isDark) then 26 else 32
		)
	elseif condition_ == Variant.EXPRESSIVE then
		return TonalPalette:fromHueAndChroma(
			sourceColorHct.hue,
			if platform == "phone" then if Boolean.toJSBoolean(isDark) then 36 else 48 else 40
		)
	elseif condition_ == Variant.VIBRANT then
		return TonalPalette:fromHueAndChroma(
			sourceColorHct.hue,
			if platform == "phone" then 74 else 56
		)
	else
		return (
			error("not implemented") --[[ ROBLOX TODO: Unhandled node for type: Super ]] --[[ super ]]
		):getPrimaryPalette(variant, sourceColorHct, isDark, platform, contrastLevel)
	end
end
function DynamicSchemePalettesDelegateImpl2025_private:getSecondaryPalette(
	variant: Variant,
	sourceColorHct: Hct,
	isDark: boolean,
	platform: Platform,
	contrastLevel: number
): TonalPalette
	local condition_ = variant
	if condition_ == Variant.NEUTRAL then
		return TonalPalette:fromHueAndChroma(
			sourceColorHct.hue,
			if platform == "phone"
				then if Boolean.toJSBoolean(Hct:isBlue(sourceColorHct.hue)) then 6 else 4
				else if Boolean.toJSBoolean(Hct:isBlue(sourceColorHct.hue)) then 10 else 6
		)
	elseif condition_ == Variant.TONAL_SPOT then
		return TonalPalette:fromHueAndChroma(sourceColorHct.hue, 16)
	elseif condition_ == Variant.EXPRESSIVE then
		return TonalPalette:fromHueAndChroma(
			DynamicScheme:getRotatedHue(
				sourceColorHct,
				{ 0, 105, 140, 204, 253, 278, 300, 333, 360 },
				{ -160, 155, -100, 96, -96, -156, -165, -160 }
			),
			if platform == "phone" then if Boolean.toJSBoolean(isDark) then 16 else 24 else 24
		)
	elseif condition_ == Variant.VIBRANT then
		return TonalPalette:fromHueAndChroma(
			DynamicScheme:getRotatedHue(
				sourceColorHct,
				{ 0, 38, 105, 140, 333, 360 },
				{ -14, 10, -14, 10, -14 }
			),
			if platform == "phone" then 56 else 36
		)
	else
		return (
			error("not implemented") --[[ ROBLOX TODO: Unhandled node for type: Super ]] --[[ super ]]
		):getSecondaryPalette(variant, sourceColorHct, isDark, platform, contrastLevel)
	end
end
function DynamicSchemePalettesDelegateImpl2025_private:getTertiaryPalette(
	variant: Variant,
	sourceColorHct: Hct,
	isDark: boolean,
	platform: Platform,
	contrastLevel: number
): TonalPalette
	local condition_ = variant
	if condition_ == Variant.NEUTRAL then
		return TonalPalette:fromHueAndChroma(
			DynamicScheme:getRotatedHue(
				sourceColorHct,
				{ 0, 38, 105, 161, 204, 278, 333, 360 },
				{ -32, 26, 10, -39, 24, -15, -32 }
			),
			if platform == "phone" then 20 else 36
		)
	elseif condition_ == Variant.TONAL_SPOT then
		return TonalPalette:fromHueAndChroma(
			DynamicScheme:getRotatedHue(
				sourceColorHct,
				{ 0, 20, 71, 161, 333, 360 },
				{ -40, 48, -32, 40, -32 }
			),
			if platform == "phone" then 28 else 32
		)
	elseif condition_ == Variant.EXPRESSIVE then
		return TonalPalette:fromHueAndChroma(
			DynamicScheme:getRotatedHue(
				sourceColorHct,
				{ 0, 105, 140, 204, 253, 278, 300, 333, 360 },
				{ -165, 160, -105, 101, -101, -160, -170, -165 }
			),
			48
		)
	elseif condition_ == Variant.VIBRANT then
		return TonalPalette:fromHueAndChroma(
			DynamicScheme:getRotatedHue(
				sourceColorHct,
				{ 0, 38, 71, 105, 140, 161, 253, 333, 360 },
				{ -72, 35, 24, -24, 62, 50, 62, -72 }
			),
			56
		)
	else
		return (
			error("not implemented") --[[ ROBLOX TODO: Unhandled node for type: Super ]] --[[ super ]]
		):getTertiaryPalette(variant, sourceColorHct, isDark, platform, contrastLevel)
	end
end
function DynamicSchemePalettesDelegateImpl2025_private.getExpressiveNeutralHue(
	sourceColorHct: Hct
): number
	local hue = DynamicScheme:getRotatedHue(
		sourceColorHct,
		{ 0, 71, 124, 253, 278, 300, 360 },
		{ 10, 0, 10, 0, 10, 0 }
	)
	return hue
end
function DynamicSchemePalettesDelegateImpl2025_private.getExpressiveNeutralChroma(
	sourceColorHct: Hct,
	isDark: boolean,
	platform: Platform
): number
	local neutralHue = DynamicSchemePalettesDelegateImpl2025:getExpressiveNeutralHue(sourceColorHct)
	return if platform == "phone"
		then if Boolean.toJSBoolean(isDark)
			then if Boolean.toJSBoolean(Hct:isYellow(neutralHue)) then 6 else 14
			else 18
		else 12
end
function DynamicSchemePalettesDelegateImpl2025_private.getVibrantNeutralHue(
	sourceColorHct: Hct
): number
	return DynamicScheme:getRotatedHue(
		sourceColorHct,
		{ 0, 38, 105, 140, 333, 360 },
		{ -14, 10, -14, 10, -14 }
	)
end
function DynamicSchemePalettesDelegateImpl2025_private.getVibrantNeutralChroma(
	sourceColorHct: Hct,
	platform: Platform
): number
	local neutralHue = DynamicSchemePalettesDelegateImpl2025:getVibrantNeutralHue(sourceColorHct)
	return if platform == "phone"
		then 28
		else if Boolean.toJSBoolean(Hct:isBlue(neutralHue)) then 28 else 20
end
function DynamicSchemePalettesDelegateImpl2025_private:getNeutralPalette(
	variant: Variant,
	sourceColorHct: Hct,
	isDark: boolean,
	platform: Platform,
	contrastLevel: number
): TonalPalette
	local condition_ = variant
	if condition_ == Variant.NEUTRAL then
		return TonalPalette:fromHueAndChroma(
			sourceColorHct.hue,
			if platform == "phone" then 1.4 else 6
		)
	elseif condition_ == Variant.TONAL_SPOT then
		return TonalPalette:fromHueAndChroma(
			sourceColorHct.hue,
			if platform == "phone" then 5 else 10
		)
	elseif condition_ == Variant.EXPRESSIVE then
		return TonalPalette:fromHueAndChroma(
			DynamicSchemePalettesDelegateImpl2025:getExpressiveNeutralHue(sourceColorHct),
			DynamicSchemePalettesDelegateImpl2025:getExpressiveNeutralChroma(
				sourceColorHct,
				isDark,
				platform
			)
		)
	elseif condition_ == Variant.VIBRANT then
		return TonalPalette:fromHueAndChroma(
			DynamicSchemePalettesDelegateImpl2025:getVibrantNeutralHue(sourceColorHct),
			DynamicSchemePalettesDelegateImpl2025:getVibrantNeutralChroma(sourceColorHct, platform)
		)
	else
		return (
			error("not implemented") --[[ ROBLOX TODO: Unhandled node for type: Super ]] --[[ super ]]
		):getNeutralPalette(variant, sourceColorHct, isDark, platform, contrastLevel)
	end
end
function DynamicSchemePalettesDelegateImpl2025_private:getNeutralVariantPalette(
	variant: Variant,
	sourceColorHct: Hct,
	isDark: boolean,
	platform: Platform,
	contrastLevel: number
): TonalPalette
	local condition_ = variant
	if condition_ == Variant.NEUTRAL then
		return TonalPalette:fromHueAndChroma(
			sourceColorHct.hue,
			(if platform == "phone" then 1.4 else 6) * 2.2
		)
	elseif condition_ == Variant.TONAL_SPOT then
		return TonalPalette:fromHueAndChroma(
			sourceColorHct.hue,
			(if platform == "phone" then 5 else 10) * 1.7
		)
	elseif condition_ == Variant.EXPRESSIVE then
		local expressiveNeutralHue =
			DynamicSchemePalettesDelegateImpl2025:getExpressiveNeutralHue(sourceColorHct)
		local expressiveNeutralChroma =
			DynamicSchemePalettesDelegateImpl2025:getExpressiveNeutralChroma(
				sourceColorHct,
				isDark,
				platform
			)
		return TonalPalette:fromHueAndChroma(
			expressiveNeutralHue,
			expressiveNeutralChroma
				* (
					if expressiveNeutralHue >= 105 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
							and expressiveNeutralHue < 125 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
						then 1.6
						else 2.3
				)
		)
	elseif condition_ == Variant.VIBRANT then
		local vibrantNeutralHue =
			DynamicSchemePalettesDelegateImpl2025:getVibrantNeutralHue(sourceColorHct)
		local vibrantNeutralChroma =
			DynamicSchemePalettesDelegateImpl2025:getVibrantNeutralChroma(sourceColorHct, platform)
		return TonalPalette:fromHueAndChroma(vibrantNeutralHue, vibrantNeutralChroma * 1.29)
	else
		return (
			error("not implemented") --[[ ROBLOX TODO: Unhandled node for type: Super ]] --[[ super ]]
		):getNeutralVariantPalette(variant, sourceColorHct, isDark, platform, contrastLevel)
	end
end
function DynamicSchemePalettesDelegateImpl2025_private:getErrorPalette(
	variant: Variant,
	sourceColorHct: Hct,
	isDark: boolean,
	platform: Platform,
	contrastLevel: number
): TonalPalette | nil
	local errorHue = DynamicScheme:getPiecewiseHue(
		sourceColorHct,
		{ 0, 3, 13, 23, 33, 43, 153, 273, 360 },
		{ 12, 22, 32, 12, 22, 32, 22, 12 }
	)
	local condition_ = variant
	if condition_ == Variant.NEUTRAL then
		return TonalPalette:fromHueAndChroma(errorHue, if platform == "phone" then 50 else 40)
	elseif condition_ == Variant.TONAL_SPOT then
		return TonalPalette:fromHueAndChroma(errorHue, if platform == "phone" then 60 else 48)
	elseif condition_ == Variant.EXPRESSIVE then
		return TonalPalette:fromHueAndChroma(errorHue, if platform == "phone" then 64 else 48)
	elseif condition_ == Variant.VIBRANT then
		return TonalPalette:fromHueAndChroma(errorHue, if platform == "phone" then 80 else 60)
	else
		return (
			error("not implemented") --[[ ROBLOX TODO: Unhandled node for type: Super ]] --[[ super ]]
		):getErrorPalette(variant, sourceColorHct, isDark, platform, contrastLevel)
	end
end
local spec2021 = DynamicSchemePalettesDelegateImpl2021.new()
local spec2025 = DynamicSchemePalettesDelegateImpl2025.new()
--[[*
 * Returns the DynamicSchemePalettesDelegate for the given spec version.
 ]]
local function getSpec(specVersion: SpecVersion): DynamicSchemePalettesDelegate
	return if specVersion == "2025" then spec2025 else spec2021
end
return exports
