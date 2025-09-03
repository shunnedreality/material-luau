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
local Object = LuauPolyfill.Object
type Array<T> = LuauPolyfill.Array<T>
local Promise = require(Packages.Promise)
local RegExp = require(Packages.RegExp)
local exports = {}
local Blend = require(script.Parent.Parent.blend["blend"]).Blend
local CorePalette = require(script.Parent.Parent.palettes["core_palette"]).CorePalette
local TonalPalette = require(script.Parent.Parent.palettes["tonal_palette"]).TonalPalette
local Scheme = require(script.Parent.Parent.scheme["scheme"]).Scheme
local sourceColorFromImage = require(script.Parent["image_utils"]).sourceColorFromImage
local hexFromArgb = require(script.Parent["string_utils"]).hexFromArgb
--[[*
 * Custom color used to pair with a theme
 ]]
export type CustomColor = { value: number, name: string, blend: boolean }
--[[*
 * Color group
 ]]
export type ColorGroup = {
	color: number,
	onColor: number,
	colorContainer: number,
	onColorContainer: number,
}
--[[*
 * Custom Color Group
 ]]
export type CustomColorGroup = {
	color: CustomColor,
	value: number,
	light: ColorGroup,
	dark: ColorGroup,
}
--[[*
 * Theme
 ]]
export type Theme = {
	source: number,
	schemes: { light: Scheme, dark: Scheme },
	palettes: {
		primary: TonalPalette,
		secondary: TonalPalette,
		tertiary: TonalPalette,
		neutral: TonalPalette,
		neutralVariant: TonalPalette,
		error: TonalPalette,
	},
	customColors: Array<CustomColorGroup>,
}
--[[*
 * Generate a theme from a source color
 *
 * @param source Source color
 * @param customColors Array of custom colors
 * @return Theme object
 ]]
local function themeFromSourceColor(source: number, customColors_: Array<CustomColor>?): Theme
	local customColors: Array<CustomColor> = if customColors_ ~= nil then customColors_ else {}
	local palette = CorePalette.of(source)
	return {
		source = source,
		schemes = { light = Scheme.light(source), dark = Scheme.dark(source) },
		palettes = {
			primary = palette.a1,
			secondary = palette.a2,
			tertiary = palette.a3,
			neutral = palette.n1,
			neutralVariant = palette.n2,
			error = palette.error,
		},
		customColors = Array.map(customColors, function(c)
			return customColor(source, c)
		end),--[[ ROBLOX CHECK: check if 'customColors' is an Array ]]
	}
end
exports.themeFromSourceColor = themeFromSourceColor
--[[*
 * Generate a theme from an image source
 *
 * @param image Image element
 * @param customColors Array of custom colors
 * @return Theme object
 ]]
local function themeFromImage(image: HTMLImageElement, customColors_: Array<CustomColor>?)
	local customColors: Array<CustomColor> = if customColors_ ~= nil then customColors_ else {}
	return Promise.resolve():andThen(function()
		local source = sourceColorFromImage(image):expect()
		return themeFromSourceColor(source, customColors)
	end)
end
exports.themeFromImage = themeFromImage
--[[*
 * Generate custom color group from source and target color
 *
 * @param source Source color
 * @param color Custom color
 * @return Custom color group
 *
 * @link https://m3.material.io/styles/color/the-color-system/color-roles
 ]]
local function customColor(source: number, color: CustomColor): CustomColorGroup
	local value = color.value
	local from = value
	local to = source
	if Boolean.toJSBoolean(color.blend) then
		value = Blend:harmonize(from, to)
	end
	local palette = CorePalette.of(value)
	local tones = palette.a1
	return {
		color = color,
		value = value,
		light = {
			color = tones:tone(40),
			onColor = tones:tone(100),
			colorContainer = tones:tone(90),
			onColorContainer = tones:tone(10),
		},
		dark = {
			color = tones:tone(80),
			onColor = tones:tone(20),
			colorContainer = tones:tone(30),
			onColorContainer = tones:tone(90),
		},
	}
end
exports.customColor = customColor
--[[*
 * Apply a theme to an element
 *
 * @param theme Theme object
 * @param options Options
 ]]
local function applyTheme(
	theme: Theme,
	options: {
		dark: boolean?,
		target: HTMLElement?,
		brightnessSuffix: boolean?,
		paletteTones: Array<number>?,
	}?
)
	local ref = if typeof(options) == "table" then options.target else nil
	local target = Boolean.toJSBoolean(ref) and ref or document.body
	local ref = if typeof(options) == "table" then options.dark else nil
	local isDark = if ref ~= nil then ref else false
	local scheme = if Boolean.toJSBoolean(isDark) then theme.schemes.dark else theme.schemes.light
	setSchemeProperties(target, scheme)
	if
		Boolean.toJSBoolean(if typeof(options) == "table" then options.brightnessSuffix else nil)
	then
		setSchemeProperties(target, theme.schemes.dark, "-dark")
		setSchemeProperties(target, theme.schemes.light, "-light")
	end
	if Boolean.toJSBoolean(if typeof(options) == "table" then options.paletteTones else nil) then
		local ref = if typeof(options) == "table" then options.paletteTones else nil
		local tones = if ref ~= nil then ref else {}
		for _, ref in Object.entries(theme.palettes) do
			local key, palette = table.unpack(ref, 1, 2)
			local paletteKey = key:replace(
				RegExp("([a-z])([A-Z])", "g"), --[[ ROBLOX NOTE: global flag is not implemented yet ]]
				"$1-$2"
			):toLowerCase()
			for _, tone in tones do
				local token = ("--md-ref-palette-%s-%s%s"):format(
					tostring(paletteKey),
					tostring(paletteKey),
					tostring(tone)
				)
				local color = hexFromArgb(palette:tone(tone))
				target.style:setProperty(token, color)
			end
		end
	end
end
exports.applyTheme = applyTheme
local function setSchemeProperties(target: HTMLElement, scheme: Scheme, suffix_: string?)
	local suffix: string = if suffix_ ~= nil then suffix_ else ""
	for _, ref in Object.entries(scheme:toJSON()) do
		local key, value = table.unpack(ref, 1, 2)
		local token = key:replace(
			RegExp("([a-z])([A-Z])", "g"), --[[ ROBLOX NOTE: global flag is not implemented yet ]]
			"$1-$2"
		):toLowerCase()
		local color = hexFromArgb(value)
		target.style:setProperty(
			("--md-sys-color-%s%s"):format(tostring(token), tostring(suffix)),
			color
		)
	end
end
return exports
