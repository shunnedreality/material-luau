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
local Boolean = LuauPolyfill.Boolean
local exports = {}
local Hct = require(script.Parent.Parent.hct["hct"]).Hct
local TonalPalette = require(script.Parent["tonal_palette"]).TonalPalette
--[[*
 * @deprecated Use {@link DynamicScheme} for color scheme generation.
 * Use {@link CorePalettes} for core palettes container class.
 ]]
export type CorePaletteColors = {
	primary: number,
	secondary: number?,
	tertiary: number?,
	neutral: number?,
	neutralVariant: number?,
	error: number?,
}
--[[*
 * An intermediate concept between the key color for a UI theme, and a full
 * color scheme. 5 sets of tones are generated, all except one use the same hue
 * as the key color, and all vary in chroma.
 *
 * @deprecated Use {@link DynamicScheme} for color scheme generation.
 * Use {@link CorePalettes} for core palettes container class.
 ]]
export type CorePalette = {
	a1: TonalPalette,
	a2: TonalPalette,
	a3: TonalPalette,
	n1: TonalPalette,
	n2: TonalPalette,
	error_: TonalPalette,
	--[[*
   * @param argb ARGB representation of a color
   *
   * @deprecated Use {@link DynamicScheme} for color scheme generation.
   * Use {@link CorePalettes} for core palettes container class.
   ]]
}
type CorePalette_private = { --
	-- *** PUBLIC ***
	--
	a1: TonalPalette,
	a2: TonalPalette,
	a3: TonalPalette,
	n1: TonalPalette,
	n2: TonalPalette,
	error_: TonalPalette,
}

type CorePalette_statics = { new: (argb: number, isContent: boolean) -> CorePalette }
local CorePalette = {} :: CorePalette & CorePalette_statics
local CorePalette_private = CorePalette :: CorePalette_private & CorePalette_statics;
(CorePalette :: any).__index = CorePalette
function CorePalette_private.new(argb: number, isContent: boolean): CorePalette
	local self = setmetatable({}, CorePalette)
	local hct = Hct.fromInt(argb)
	local hue = hct:hue()
	local chroma = hct:chroma()

	if Boolean.toJSBoolean(isContent) then
		self.a1 = TonalPalette.fromHueAndChroma(hue, chroma)
		self.a2 = TonalPalette.fromHueAndChroma(hue, chroma / 3)
		self.a3 = TonalPalette.fromHueAndChroma(hue + 60, chroma / 2)
		self.n1 = TonalPalette.fromHueAndChroma(hue, math.min(chroma / 12, 4))
		self.n2 = TonalPalette.fromHueAndChroma(hue, math.min(chroma / 6, 8))
	else
		self.a1 = TonalPalette.fromHueAndChroma(hue, math.max(48, chroma))
		self.a2 = TonalPalette.fromHueAndChroma(hue, 16)
		self.a3 = TonalPalette.fromHueAndChroma(hue + 60, 24)
		self.n1 = TonalPalette.fromHueAndChroma(hue, 4)
		self.n2 = TonalPalette.fromHueAndChroma(hue, 8)
	end
	self.error = TonalPalette.fromHueAndChroma(25, 84)
	return (self :: any) :: CorePalette
end
function CorePalette_private.of(argb: number): CorePalette
	return CorePalette.new(argb, false)
end
function CorePalette_private.contentOf(argb: number): CorePalette
	return CorePalette.new(argb, true)
end
function CorePalette_private.fromColors(colors: CorePaletteColors): CorePalette
	return CorePalette:createPaletteFromColors(false, colors)
end
function CorePalette_private.contentFromColors(colors: CorePaletteColors): CorePalette
	return CorePalette:createPaletteFromColors(true, colors)
end
function CorePalette_private.createPaletteFromColors(content: boolean, colors: CorePaletteColors)
	local palette = CorePalette.new(colors.primary, content)
	if Boolean.toJSBoolean(colors.secondary) then
		local p = CorePalette.new(colors.secondary, content)
		palette.a2 = p.a1
	end
	if Boolean.toJSBoolean(colors.tertiary) then
		local p = CorePalette.new(colors.tertiary, content)
		palette.a3 = p.a1
	end
	if Boolean.toJSBoolean(colors.error) then
		local p = CorePalette.new(colors.error, content)
		palette.error = p.a1
	end
	if Boolean.toJSBoolean(colors.neutral) then
		local p = CorePalette.new(colors.neutral, content)
		palette.n1 = p.n1
	end
	if Boolean.toJSBoolean(colors.neutralVariant) then
		local p = CorePalette.new(colors.neutralVariant, content)
		palette.n2 = p.n2
	end
	return palette
end
exports.CorePalette = CorePalette
return exports
