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
local Packages = script.Parent.Parent.Parent; --[[ ROBLOX comment: must define Packages module ]]
local LuauPolyfill = require(Packages.LuauPolyfill);
local Error = LuauPolyfill.Error;
local exports = {};
local Hct = require(script.Parent.Parent.hct["hct"]).Hct;
local TonalPalette = require(script.Parent.Parent.palettes["tonal_palette"]).TonalPalette;

local dynamic_colorModule = require(script.Parent.dynamic_color);
type DynamicColor = dynamic_colorModule.DynamicColor
local dynamic_schemeModule = require(script.Parent.dynamic_scheme);
local DynamicScheme = dynamic_schemeModule.DynamicScheme;
local Platform = dynamic_schemeModule.Platform;
local Variant = require(script.Parent["variant"]).Variant;
export type SpecVersion = "2021"
| "2025";
--[[*
 * A delegate that provides the dynamic color constraints for
 * MaterialDynamicColors.
 *
 * This is used to allow for different color constraints for different spec
 * versions.
 ]]
export type ColorSpecDelegate = { primaryPaletteKeyColor: --//////////////////////////////////////////////////////////////
-- Main Palettes                                              //
--//////////////////////////////////////////////////////////////
(self:ColorSpecDelegate) -> DynamicColor,
secondaryPaletteKeyColor: (self:ColorSpecDelegate) -> DynamicColor,
tertiaryPaletteKeyColor: (self:ColorSpecDelegate) -> DynamicColor,
neutralPaletteKeyColor: (self:ColorSpecDelegate) -> DynamicColor,
neutralVariantPaletteKeyColor: (self:ColorSpecDelegate) -> DynamicColor,
errorPaletteKeyColor: (self:ColorSpecDelegate) -> DynamicColor,
--//////////////////////////////////////////////////////////////
-- Surfaces [S]                                               //
--//////////////////////////////////////////////////////////////,
background: (self:ColorSpecDelegate) -> DynamicColor,
onBackground: (self:ColorSpecDelegate) -> DynamicColor,
surface: (self:ColorSpecDelegate) -> DynamicColor,
surfaceDim: (self:ColorSpecDelegate) -> DynamicColor,
surfaceBright: (self:ColorSpecDelegate) -> DynamicColor,
surfaceContainerLowest: (self:ColorSpecDelegate) -> DynamicColor,
surfaceContainerLow: (self:ColorSpecDelegate) -> DynamicColor,
surfaceContainer: (self:ColorSpecDelegate) -> DynamicColor,
surfaceContainerHigh: (self:ColorSpecDelegate) -> DynamicColor,
surfaceContainerHighest: (self:ColorSpecDelegate) -> DynamicColor,
onSurface: (self:ColorSpecDelegate) -> DynamicColor,
surfaceVariant: (self:ColorSpecDelegate) -> DynamicColor,
onSurfaceVariant: (self:ColorSpecDelegate) -> DynamicColor,
inverseSurface: (self:ColorSpecDelegate) -> DynamicColor,
inverseOnSurface: (self:ColorSpecDelegate) -> DynamicColor,
outline: (self:ColorSpecDelegate) -> DynamicColor,
outlineVariant: (self:ColorSpecDelegate) -> DynamicColor,
shadow: (self:ColorSpecDelegate) -> DynamicColor,
scrim: (self:ColorSpecDelegate) -> DynamicColor,
surfaceTint: (self:ColorSpecDelegate) -> DynamicColor,
--//////////////////////////////////////////////////////////////
-- Primaries [P]                                              //
--//////////////////////////////////////////////////////////////,
primary: (self:ColorSpecDelegate) -> DynamicColor,
primaryDim: (self:ColorSpecDelegate) -> DynamicColor
| nil,
onPrimary: (self:ColorSpecDelegate) -> DynamicColor,
primaryContainer: (self:ColorSpecDelegate) -> DynamicColor,
onPrimaryContainer: (self:ColorSpecDelegate) -> DynamicColor,
inversePrimary: (self:ColorSpecDelegate) -> DynamicColor,
--//////////////////////////////////////////////////////////////
-- Secondaries [Q]                                            //
--//////////////////////////////////////////////////////////////,
secondary: (self:ColorSpecDelegate) -> DynamicColor,
secondaryDim: (self:ColorSpecDelegate) -> DynamicColor
| nil,
onSecondary: (self:ColorSpecDelegate) -> DynamicColor,
secondaryContainer: (self:ColorSpecDelegate) -> DynamicColor,
onSecondaryContainer: (self:ColorSpecDelegate) -> DynamicColor,
--//////////////////////////////////////////////////////////////
-- Tertiaries [T]                                             //
--//////////////////////////////////////////////////////////////,
tertiary: (self:ColorSpecDelegate) -> DynamicColor,
tertiaryDim: (self:ColorSpecDelegate) -> DynamicColor
| nil,
onTertiary: (self:ColorSpecDelegate) -> DynamicColor,
tertiaryContainer: (self:ColorSpecDelegate) -> DynamicColor,
onTertiaryContainer: (self:ColorSpecDelegate) -> DynamicColor,
--//////////////////////////////////////////////////////////////
-- Errors [E]                                                 //
--//////////////////////////////////////////////////////////////,
error_: (self:ColorSpecDelegate) -> DynamicColor,
errorDim: (self:ColorSpecDelegate) -> DynamicColor
| nil,
onError: (self:ColorSpecDelegate) -> DynamicColor,
errorContainer: (self:ColorSpecDelegate) -> DynamicColor,
onErrorContainer: (self:ColorSpecDelegate) -> DynamicColor,
--//////////////////////////////////////////////////////////////
-- Primary Fixed Colors [PF]                                  //
--//////////////////////////////////////////////////////////////,
primaryFixed: (self:ColorSpecDelegate) -> DynamicColor,
primaryFixedDim: (self:ColorSpecDelegate) -> DynamicColor,
onPrimaryFixed: (self:ColorSpecDelegate) -> DynamicColor,
onPrimaryFixedVariant: (self:ColorSpecDelegate) -> DynamicColor,
--//////////////////////////////////////////////////////////////
-- Secondary Fixed Colors [QF]                                //
--//////////////////////////////////////////////////////////////,
secondaryFixed: (self:ColorSpecDelegate) -> DynamicColor,
secondaryFixedDim: (self:ColorSpecDelegate) -> DynamicColor,
onSecondaryFixed: (self:ColorSpecDelegate) -> DynamicColor,
onSecondaryFixedVariant: (self:ColorSpecDelegate) -> DynamicColor,
--//////////////////////////////////////////////////////////////
-- Tertiary Fixed Colors [TF]                                 //
--//////////////////////////////////////////////////////////////,
tertiaryFixed: (self:ColorSpecDelegate) -> DynamicColor,
tertiaryFixedDim: (self:ColorSpecDelegate) -> DynamicColor,
onTertiaryFixed: (self:ColorSpecDelegate) -> DynamicColor,
onTertiaryFixedVariant: (self:ColorSpecDelegate) -> DynamicColor,
--//////////////////////////////////////////////////////////////
-- Other                                                      //
--//////////////////////////////////////////////////////////////,
highestSurface: (s:DynamicScheme) -> DynamicColor, };
--[[*
 * Returns the ColorSpecDelegate for the given spec version.
 ]]
local function getSpec(specVersion: SpecVersion): ColorSpecDelegate
local condition_ = specVersion;
if condition_ == "2021" then
    return require(script.Parent["color_spec_2021"]).ColorSpecDelegateImpl2021.new();
elseif condition_ == "2025" then
    return require(script.Parent["color_spec_2025"]).ColorSpecDelegateImpl2025.new();
else
error(Error.new(("Unsupported spec version: %s"):format(tostring(specVersion))));
end
end
exports.getSpec = getSpec;
return exports;
