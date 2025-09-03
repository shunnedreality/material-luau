-- ROBLOX NOTE: no upstream
--[[*
 * @license
 * Copyright 2023 Google LLC
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
local Math = LuauPolyfill.Math
local exports = {}
local Hct = require(script.Parent.Parent.hct["hct"]).Hct
-- material_color_utilities is designed to have a consistent API across
-- platforms and modular components that can be moved around easily. Using a
-- class as a namespace facilitates this.
--
-- tslint:disable:class-as-namespace
--[[*
 * Check and/or fix universally disliked colors.
 * Color science studies of color preference indicate universal distaste for
 * dark yellow-greens, and also show this is correlated to distate for
 * biological waste and rotting food.
 *
 * See Palmer and Schloss, 2010 or Schloss and Palmer's Chapter 21 in Handbook
 * of Color Psychology (2015).
 ]]
export type DislikeAnalyzer = {}
type DislikeAnalyzer_statics = { new: () -> DislikeAnalyzer }
local DislikeAnalyzer = {} :: DislikeAnalyzer & DislikeAnalyzer_statics;
(DislikeAnalyzer :: any).__index = DislikeAnalyzer
function DislikeAnalyzer.new(): DislikeAnalyzer
	local self = setmetatable({}, DislikeAnalyzer)
	return (self :: any) :: DislikeAnalyzer
end
function DislikeAnalyzer.isDisliked(hct: Hct): boolean
	local huePasses = Math.round(hct.hue) --[[ ROBLOX NOTE: Math.round is currently not supported by the Luau Math polyfill, please add your own implementation or file a ticket on the same ]]
			>= 90.0 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
		and Math.round(hct.hue) --[[ ROBLOX NOTE: Math.round is currently not supported by the Luau Math polyfill, please add your own implementation or file a ticket on the same ]]
			<= 111.0 --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]]
	local chromaPasses = Math.round(hct.chroma) --[[ ROBLOX NOTE: Math.round is currently not supported by the Luau Math polyfill, please add your own implementation or file a ticket on the same ]]
		> 16.0 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
	local tonePasses = Math.round(hct.tone) --[[ ROBLOX NOTE: Math.round is currently not supported by the Luau Math polyfill, please add your own implementation or file a ticket on the same ]]
		< 65.0 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
	local ref = if Boolean.toJSBoolean(huePasses) then chromaPasses else huePasses
	return if Boolean.toJSBoolean(ref) then tonePasses else ref
end
function DislikeAnalyzer.fixIfDisliked(hct: Hct): Hct
	if Boolean.toJSBoolean(DislikeAnalyzer:isDisliked(hct)) then
		return Array.from(Hct, hct.hue, hct.chroma, 70.0) --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
	end
	return hct
end
exports.DislikeAnalyzer = DislikeAnalyzer
return exports
