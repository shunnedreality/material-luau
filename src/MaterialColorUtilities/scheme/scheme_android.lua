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
local Object = LuauPolyfill.Object
local exports = {}
local CorePalette = require(script.Parent.Parent.palettes["core_palette"]).CorePalette
--[[*
 * Represents an Android 12 color scheme, a mapping of color roles to colors.
 ]]
export type SchemeAndroid = {
	colorAccentPrimary: (self: SchemeAndroid) -> number,
	colorAccentPrimaryVariant: (self: SchemeAndroid) -> number,
	colorAccentSecondary: (self: SchemeAndroid) -> number,
	colorAccentSecondaryVariant: (self: SchemeAndroid) -> number,
	colorAccentTertiary: (self: SchemeAndroid) -> number,
	colorAccentTertiaryVariant: (self: SchemeAndroid) -> number,
	textColorPrimary: (self: SchemeAndroid) -> number,
	textColorSecondary: (self: SchemeAndroid) -> number,
	textColorTertiary: (self: SchemeAndroid) -> number,
	textColorPrimaryInverse: (self: SchemeAndroid) -> number,
	textColorSecondaryInverse: (self: SchemeAndroid) -> number,
	textColorTertiaryInverse: (self: SchemeAndroid) -> number,
	colorBackground: (self: SchemeAndroid) -> number,
	colorBackgroundFloating: (self: SchemeAndroid) -> number,
	colorSurface: (self: SchemeAndroid) -> number,
	colorSurfaceVariant: (self: SchemeAndroid) -> number,
	colorSurfaceHighlight: (self: SchemeAndroid) -> number,
	surfaceHeader: (self: SchemeAndroid) -> number,
	underSurface: (self: SchemeAndroid) -> number,
	offState: (self: SchemeAndroid) -> number,
	accentSurface: (self: SchemeAndroid) -> number,
	textPrimaryOnAccent: (self: SchemeAndroid) -> number,
	textSecondaryOnAccent: (self: SchemeAndroid) -> number,
	volumeBackground: (self: SchemeAndroid) -> number,
	scrim: (self: SchemeAndroid) -> number,
	--[[*
   * @param argb ARGB representation of a color.
   * @return Light Material color scheme, based on the color's hue.
   ]]
	toJSON: (self: SchemeAndroid) -> any,
}
type SchemeAndroid_private = { --
	-- *** PUBLIC ***
	--
	colorAccentPrimary: (self: SchemeAndroid_private) -> number,
	colorAccentPrimaryVariant: (self: SchemeAndroid_private) -> number,
	colorAccentSecondary: (self: SchemeAndroid_private) -> number,
	colorAccentSecondaryVariant: (self: SchemeAndroid_private) -> number,
	colorAccentTertiary: (self: SchemeAndroid_private) -> number,
	colorAccentTertiaryVariant: (self: SchemeAndroid_private) -> number,
	textColorPrimary: (self: SchemeAndroid_private) -> number,
	textColorSecondary: (self: SchemeAndroid_private) -> number,
	textColorTertiary: (self: SchemeAndroid_private) -> number,
	textColorPrimaryInverse: (self: SchemeAndroid_private) -> number,
	textColorSecondaryInverse: (self: SchemeAndroid_private) -> number,
	textColorTertiaryInverse: (self: SchemeAndroid_private) -> number,
	colorBackground: (self: SchemeAndroid_private) -> number,
	colorBackgroundFloating: (self: SchemeAndroid_private) -> number,
	colorSurface: (self: SchemeAndroid_private) -> number,
	colorSurfaceVariant: (self: SchemeAndroid_private) -> number,
	colorSurfaceHighlight: (self: SchemeAndroid_private) -> number,
	surfaceHeader: (self: SchemeAndroid_private) -> number,
	underSurface: (self: SchemeAndroid_private) -> number,
	offState: (self: SchemeAndroid_private) -> number,
	accentSurface: (self: SchemeAndroid_private) -> number,
	textPrimaryOnAccent: (self: SchemeAndroid_private) -> number,
	textSecondaryOnAccent: (self: SchemeAndroid_private) -> number,
	volumeBackground: (self: SchemeAndroid_private) -> number,
	scrim: (self: SchemeAndroid_private) -> number,
	toJSON: (self: SchemeAndroid_private) -> any,
	--
	-- *** PRIVATE ***
	--
	props: {
		colorAccentPrimary: number,
		colorAccentPrimaryVariant: number,
		colorAccentSecondary: number,
		colorAccentSecondaryVariant: number,
		colorAccentTertiary: number,
		colorAccentTertiaryVariant: number,
		textColorPrimary: number,
		textColorSecondary: number,
		textColorTertiary: number,
		textColorPrimaryInverse: number,
		textColorSecondaryInverse: number,
		textColorTertiaryInverse: number,
		colorBackground: number,
		colorBackgroundFloating: number,
		colorSurface: number,
		colorSurfaceVariant: number,
		colorSurfaceHighlight: number,
		surfaceHeader: number,
		underSurface: number,
		offState: number,
		accentSurface: number,
		textPrimaryOnAccent: number,
		textSecondaryOnAccent: number,
		volumeBackground: number,
		scrim: number,
	},
}
type SchemeAndroid_statics = {
	new: (
		props: {
			colorAccentPrimary: number,
			colorAccentPrimaryVariant: number,
			colorAccentSecondary: number,
			colorAccentSecondaryVariant: number,
			colorAccentTertiary: number,
			colorAccentTertiaryVariant: number,
			textColorPrimary: number,
			textColorSecondary: number,
			textColorTertiary: number,
			textColorPrimaryInverse: number,
			textColorSecondaryInverse: number,
			textColorTertiaryInverse: number,
			colorBackground: number,
			colorBackgroundFloating: number,
			colorSurface: number,
			colorSurfaceVariant: number,
			colorSurfaceHighlight: number,
			surfaceHeader: number,
			underSurface: number,
			offState: number,
			accentSurface: number,
			textPrimaryOnAccent: number,
			textSecondaryOnAccent: number,
			volumeBackground: number,
			scrim: number,
		}
	) -> SchemeAndroid,
}
local SchemeAndroid = {} :: SchemeAndroid & SchemeAndroid_statics
local SchemeAndroid_private = SchemeAndroid :: SchemeAndroid_private & SchemeAndroid_statics;
(SchemeAndroid :: any).__index = SchemeAndroid
function SchemeAndroid_private.new(props: {
	colorAccentPrimary: number,
	colorAccentPrimaryVariant: number,
	colorAccentSecondary: number,
	colorAccentSecondaryVariant: number,
	colorAccentTertiary: number,
	colorAccentTertiaryVariant: number,
	textColorPrimary: number,
	textColorSecondary: number,
	textColorTertiary: number,
	textColorPrimaryInverse: number,
	textColorSecondaryInverse: number,
	textColorTertiaryInverse: number,
	colorBackground: number,
	colorBackgroundFloating: number,
	colorSurface: number,
	colorSurfaceVariant: number,
	colorSurfaceHighlight: number,
	surfaceHeader: number,
	underSurface: number,
	offState: number,
	accentSurface: number,
	textPrimaryOnAccent: number,
	textSecondaryOnAccent: number,
	volumeBackground: number,
	scrim: number,
}): SchemeAndroid
	local self = setmetatable({}, SchemeAndroid)
	self.props = props
	return (self :: any) :: SchemeAndroid
end
function SchemeAndroid_private:colorAccentPrimary(): number
	return self.props.colorAccentPrimary
end
function SchemeAndroid_private:colorAccentPrimaryVariant(): number
	return self.props.colorAccentPrimaryVariant
end
function SchemeAndroid_private:colorAccentSecondary(): number
	return self.props.colorAccentSecondary
end
function SchemeAndroid_private:colorAccentSecondaryVariant(): number
	return self.props.colorAccentSecondaryVariant
end
function SchemeAndroid_private:colorAccentTertiary(): number
	return self.props.colorAccentTertiary
end
function SchemeAndroid_private:colorAccentTertiaryVariant(): number
	return self.props.colorAccentTertiaryVariant
end
function SchemeAndroid_private:textColorPrimary(): number
	return self.props.textColorPrimary
end
function SchemeAndroid_private:textColorSecondary(): number
	return self.props.textColorSecondary
end
function SchemeAndroid_private:textColorTertiary(): number
	return self.props.textColorTertiary
end
function SchemeAndroid_private:textColorPrimaryInverse(): number
	return self.props.textColorPrimaryInverse
end
function SchemeAndroid_private:textColorSecondaryInverse(): number
	return self.props.textColorSecondaryInverse
end
function SchemeAndroid_private:textColorTertiaryInverse(): number
	return self.props.textColorTertiaryInverse
end
function SchemeAndroid_private:colorBackground(): number
	return self.props.colorBackground
end
function SchemeAndroid_private:colorBackgroundFloating(): number
	return self.props.colorBackgroundFloating
end
function SchemeAndroid_private:colorSurface(): number
	return self.props.colorSurface
end
function SchemeAndroid_private:colorSurfaceVariant(): number
	return self.props.colorSurfaceVariant
end
function SchemeAndroid_private:colorSurfaceHighlight(): number
	return self.props.colorSurfaceHighlight
end
function SchemeAndroid_private:surfaceHeader(): number
	return self.props.surfaceHeader
end
function SchemeAndroid_private:underSurface(): number
	return self.props.underSurface
end
function SchemeAndroid_private:offState(): number
	return self.props.offState
end
function SchemeAndroid_private:accentSurface(): number
	return self.props.accentSurface
end
function SchemeAndroid_private:textPrimaryOnAccent(): number
	return self.props.textPrimaryOnAccent
end
function SchemeAndroid_private:textSecondaryOnAccent(): number
	return self.props.textSecondaryOnAccent
end
function SchemeAndroid_private:volumeBackground(): number
	return self.props.volumeBackground
end
function SchemeAndroid_private:scrim(): number
	return self.props.scrim
end
function SchemeAndroid_private.light(argb: number): SchemeAndroid
	local core = CorePalette.of(argb)
	return SchemeAndroid:lightFromCorePalette(core)
end
function SchemeAndroid_private.dark(argb: number): SchemeAndroid
	local core = CorePalette.of(argb)
	return SchemeAndroid:darkFromCorePalette(core)
end
function SchemeAndroid_private.lightContent(argb: number): SchemeAndroid
	local core = CorePalette:contentOf(argb)
	return SchemeAndroid:lightFromCorePalette(core)
end
function SchemeAndroid_private.darkContent(argb: number): SchemeAndroid
	local core = CorePalette:contentOf(argb)
	return SchemeAndroid:darkFromCorePalette(core)
end
function SchemeAndroid_private.lightFromCorePalette(core: CorePalette): SchemeAndroid
	return SchemeAndroid.new({
		colorAccentPrimary = core.a1:tone(90),
		colorAccentPrimaryVariant = core.a1:tone(40),
		colorAccentSecondary = core.a2:tone(90),
		colorAccentSecondaryVariant = core.a2:tone(40),
		colorAccentTertiary = core.a3:tone(90),
		colorAccentTertiaryVariant = core.a3:tone(40),
		textColorPrimary = core.n1:tone(10),
		textColorSecondary = core.n2:tone(30),
		textColorTertiary = core.n2:tone(50),
		textColorPrimaryInverse = core.n1:tone(95),
		textColorSecondaryInverse = core.n1:tone(80),
		textColorTertiaryInverse = core.n1:tone(60),
		colorBackground = core.n1:tone(95),
		colorBackgroundFloating = core.n1:tone(98),
		colorSurface = core.n1:tone(98),
		colorSurfaceVariant = core.n1:tone(90),
		colorSurfaceHighlight = core.n1:tone(100),
		surfaceHeader = core.n1:tone(90),
		underSurface = core.n1:tone(0),
		offState = core.n1:tone(20),
		accentSurface = core.a2:tone(95),
		textPrimaryOnAccent = core.n1:tone(10),
		textSecondaryOnAccent = core.n2:tone(30),
		volumeBackground = core.n1:tone(25),
		scrim = core.n1:tone(80),
	})
end
function SchemeAndroid_private.darkFromCorePalette(core: CorePalette): SchemeAndroid
	return SchemeAndroid.new({
		colorAccentPrimary = core.a1:tone(90),
		colorAccentPrimaryVariant = core.a1:tone(70),
		colorAccentSecondary = core.a2:tone(90),
		colorAccentSecondaryVariant = core.a2:tone(70),
		colorAccentTertiary = core.a3:tone(90),
		colorAccentTertiaryVariant = core.a3:tone(70),
		textColorPrimary = core.n1:tone(95),
		textColorSecondary = core.n2:tone(80),
		textColorTertiary = core.n2:tone(60),
		textColorPrimaryInverse = core.n1:tone(10),
		textColorSecondaryInverse = core.n1:tone(30),
		textColorTertiaryInverse = core.n1:tone(50),
		colorBackground = core.n1:tone(10),
		colorBackgroundFloating = core.n1:tone(10),
		colorSurface = core.n1:tone(20),
		colorSurfaceVariant = core.n1:tone(30),
		colorSurfaceHighlight = core.n1:tone(35),
		surfaceHeader = core.n1:tone(30),
		underSurface = core.n1:tone(0),
		offState = core.n1:tone(20),
		accentSurface = core.a2:tone(95),
		textPrimaryOnAccent = core.n1:tone(10),
		textSecondaryOnAccent = core.n2:tone(30),
		volumeBackground = core.n1:tone(25),
		scrim = core.n1:tone(80),
	})
end
function SchemeAndroid_private:toJSON()
	return Object.assign({}, self.props)
end
exports.SchemeAndroid = SchemeAndroid
return exports
