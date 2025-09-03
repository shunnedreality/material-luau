-- ROBLOX NOTE: no upstream
--[[*
 * @license
 * Copyright 2024 Google LLC
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
local exports = {}
local TonalPalette = require(script.Parent["tonal_palette"]).TonalPalette
--[[*
 * Comprises foundational palettes to build a color scheme. Generated from a
 * source color, these palettes will then be part of a [DynamicScheme] together
 * with appearance preferences.
 ]]
export type CorePalettes = {
	primary: TonalPalette,
	secondary: TonalPalette,
	tertiary: TonalPalette,
	neutral: TonalPalette,
	neutralVariant: TonalPalette,
}
type CorePalettes_statics = {
	new: (
		primary: TonalPalette,
		secondary: TonalPalette,
		tertiary: TonalPalette,
		neutral: TonalPalette,
		neutralVariant: TonalPalette
	) -> CorePalettes,
}
local CorePalettes = {} :: CorePalettes & CorePalettes_statics;
(CorePalettes :: any).__index = CorePalettes
function CorePalettes.new(
	primary: TonalPalette,
	secondary: TonalPalette,
	tertiary: TonalPalette,
	neutral: TonalPalette,
	neutralVariant: TonalPalette
): CorePalettes
	local self = setmetatable({}, CorePalettes)
	self.primary = primary
	self.secondary = secondary
	self.tertiary = tertiary
	self.neutral = neutral
	self.neutralVariant = neutralVariant
	return (self :: any) :: CorePalettes
end
exports.CorePalettes = CorePalettes
return exports
