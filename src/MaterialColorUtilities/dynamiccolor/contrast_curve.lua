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
local exports = {}
local math_ = require(script.Parent.Parent.utils["math_utils"])
--[[*
 * A class containing a value that changes with the contrast level.
 *
 * Usually represents the contrast requirements for a dynamic color on its
 * background. The four values correspond to values for contrast levels -1.0,
 * 0.0, 0.5, and 1.0, respectively.
 ]]
export type ContrastCurve = { --[[*
   * Returns the value at a given contrast level.
   *
   * @param contrastLevel The contrast level. 0.0 is the default (normal); -1.0
   *     is the lowest; 1.0 is the highest.
   * @return The value. For contrast ratios, a number between 1.0 and 21.0.
   ]]
	get: (self: ContrastCurve, contrastLevel: number) -> number,
}
type ContrastCurve_statics = {
	new: (low: number, normal: number, medium: number, high: number) -> ContrastCurve,
}
local ContrastCurve = {} :: ContrastCurve & ContrastCurve_statics;
(ContrastCurve :: any).__index = ContrastCurve
--[[*
   * Creates a `ContrastCurve` object.
   *
   * @param low Value for contrast level -1.0
   * @param normal Value for contrast level 0.0
   * @param medium Value for contrast level 0.5
   * @param high Value for contrast level 1.0
   ]]
function ContrastCurve.new(low: number, normal: number, medium: number, high: number): ContrastCurve
	local self = setmetatable({}, ContrastCurve)
	self.low = low
	self.normal = normal
	self.medium = medium
	self.high = high
	return (self :: any) :: ContrastCurve
end
function ContrastCurve:get(contrastLevel: number): number
	if
		contrastLevel
		<= -1.0 --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]]
	then
		return self.low
	elseif
		contrastLevel
		< 0.0 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
	then
		return math_:lerp(self.low, self.normal, (contrastLevel - -1) / 1)
	elseif
		contrastLevel
		< 0.5 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
	then
		return math_:lerp(self.normal, self.medium, (contrastLevel - 0) / 0.5)
	elseif
		contrastLevel
		< 1.0 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
	then
		return math_:lerp(self.medium, self.high, (contrastLevel - 0.5) / 0.5)
	else
		return self.high
	end
end
exports.ContrastCurve = ContrastCurve
return exports
