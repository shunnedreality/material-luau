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
require(Packages.jasmine)
local Contrast = require(script.Parent["contrast"]).Contrast
describe("contrast", function()
	it("ratioOfTones_outOfBoundsInput", function()
		expect(21.0).toBeCloseTo(Contrast:ratioOfTones(-10.0, 110.0), 0.001)
	end)
	it("lighter_impossibleRatioErrors", function()
		expect(-1.0).toBeCloseTo(Contrast:lighter(90.0, 10.0), 0.001)
	end)
	it("lighter_outOfBoundsInputAboveErrors", function()
		expect(-1.0).toBeCloseTo(Contrast:lighter(110.0, 2.0), 0.001)
	end)
	it("lighter_outOfBoundsInputBelowErrors", function()
		expect(-1.0).toBeCloseTo(Contrast:lighter(-10.0, 2.0), 0.001)
	end)
	it("lighterUnsafe_returnsMaxTone", function()
		expect(100).toBeCloseTo(Contrast:lighterUnsafe(100.0, 2.0), 0.001)
	end)
	it("darker_impossibleRatioErrors", function()
		expect(-1.0).toBeCloseTo(Contrast:darker(10.0, 20.0), 0.001)
	end)
	it("darker_outOfBoundsInputAboveErrors", function()
		expect(-1.0).toBeCloseTo(Contrast:darker(110.0, 2.0), 0.001)
	end)
	it("darker_outOfBoundsInputBelowErrors", function()
		expect(-1.0).toBeCloseTo(Contrast:darker(-10.0, 2.0), 0.001)
	end)
	it("darkerUnsafe_returnsMinTone", function()
		expect(0.0).toBeCloseTo(Contrast:darkerUnsafe(0.0, 2.0), 0.001)
	end)
end)
