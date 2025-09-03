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
local exports = {}
local SpecVersion = require(script.Parent.Parent.dynamiccolor["color_spec"]).SpecVersion
local dynamic_schemeModule = require(script.Parent.Parent.dynamiccolor.dynamic_scheme)
local DynamicScheme = dynamic_schemeModule.DynamicScheme
local Platform = dynamic_schemeModule.Platform
local Variant = require(script.Parent.Parent.dynamiccolor["variant"]).Variant
local Hct = require(script.Parent.Parent.hct["hct"]).Hct
--[[*
 * A Dynamic Color theme with low to medium colorfulness and a Tertiary
 * TonalPalette with a hue related to the source color.
 *
 * The default Material You theme on Android 12 and 13.
 ]]
export type SchemeTonalSpot = DynamicScheme & {}
type SchemeTonalSpot_statics = {
	new: (
		sourceColorHct: Hct,
		isDark: boolean,
		contrastLevel: number,
		specVersion_: SpecVersion?,
		platform_: Platform?
	) -> SchemeTonalSpot,
}
local SchemeTonalSpot = (
	setmetatable({}, { __index = DynamicScheme }) :: any
) :: SchemeTonalSpot & SchemeTonalSpot_statics;
(SchemeTonalSpot :: any).__index = SchemeTonalSpot
function SchemeTonalSpot.new(
	sourceColorHct: Hct,
	isDark: boolean,
	contrastLevel: number,
	specVersion_: SpecVersion?,
	platform_: Platform?
): SchemeTonalSpot
	local self = setmetatable({}, SchemeTonalSpot) --[[ ROBLOX TODO: super constructor may be used ]]
	local specVersion: SpecVersion = if specVersion_ ~= nil
		then specVersion_
		else DynamicScheme.DEFAULT_SPEC_VERSION
	local platform: Platform = if platform_ ~= nil
		then platform_
		else DynamicScheme.DEFAULT_PLATFORM;
	(error("not implemented") --[[ ROBLOX TODO: Unhandled node for type: Super ]] --[[ super ]])({
		sourceColorHct = sourceColorHct,
		variant = Variant.TONAL_SPOT,
		contrastLevel = contrastLevel,
		isDark = isDark,
		platform = platform,
		specVersion = specVersion,
	})
	return (self :: any) :: SchemeTonalSpot
end
exports.SchemeTonalSpot = SchemeTonalSpot
return exports
