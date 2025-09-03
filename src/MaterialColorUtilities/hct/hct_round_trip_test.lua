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
require(Packages.jasmine)
local colorUtils = require(script.Parent.Parent.utils["color_utils"])
local Hct = require(script.Parent["hct"]).Hct
-- Testing 512 out of 16_777_216 colors.
describe("HCT roundtrip", function()
	it("preserves original color", function()
		do
			local r = 0
			while
				r
				< 296 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
			do
				do
					local g = 0
					while
						g
						< 296 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
					do
						do
							local b = 0
							while
								b
								< 296 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
							do
								local argb = colorUtils:argbFromRgb(
									math.min(255, r),
									math.min(255, g),
									math.min(255, b)
								)
								local hct = Hct.fromInt(argb)
								local reconstructed = Array
									.from(Hct, hct.hue, hct.chroma, hct.tone) --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
									:toInt()
								expect(reconstructed).toEqual(argb)
								b += 37
							end
						end
						g += 37
					end
				end
				r += 37
			end
		end
	end)
end)
