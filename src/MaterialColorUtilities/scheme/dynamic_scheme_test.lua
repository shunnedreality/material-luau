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
local Array = LuauPolyfill.Array
require(Packages.jasmine)
local DynamicScheme = require(script.Parent.Parent.dynamiccolor["dynamic_scheme"]).DynamicScheme
local Hct = require(script.Parent.Parent.hct["hct"]).Hct
describe("dynamic scheme test", function()
	it("0 length input", function()
		local hue = DynamicScheme:getRotatedHue(
			Array.from(Hct, 43, 16, 16), --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
			{},
			{}
		)
		expect(hue).toBeCloseTo(43, 0.4)
	end)
	it("1 length input no rotation", function()
		local hue = DynamicScheme:getRotatedHue(
			Array.from(Hct, 43, 16, 16), --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
			{ 0 },
			{ 0 }
		)
		expect(hue).toBeCloseTo(43, 0.4)
	end)
	it("input length mismatch asserts", function()
		local hue = DynamicScheme:getRotatedHue(
			Array.from(Hct, 43, 16, 16), --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
			{ 0 },
			{ 0, 1 }
		)
		expect(hue).toBeCloseTo(43, 0.4)
	end)
	it("on boundary rotation correct", function()
		local hue = DynamicScheme:getRotatedHue(
			Array.from(Hct, 43, 16, 16), --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
			{ 0, 42, 360 },
			{ 0, 15, 0 }
		)
		expect(hue).toBeCloseTo(43 + 15, 0.4)
	end)
	it("rotation result larger than 360 degrees wraps", function()
		local hue = DynamicScheme:getRotatedHue(
			Array.from(Hct, 43, 16, 16), --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
			{ 0, 42, 360 },
			{ 0, 480, 0 }
		)
		expect(hue).toBeCloseTo(163, 0.4)
	end)
end)
