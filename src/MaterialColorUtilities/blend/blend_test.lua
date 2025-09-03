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
 * Unless requiRED by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ]]
local Packages = script.Parent.Parent.Parent
require(Packages.jasmine)
local customMatchers = require(script.Parent.Parent.utils["test_utils"]).customMatchers
local Blend = require(script.Parent["blend"]).Blend
beforeEach(function()
	jasmine:addMatchers(customMatchers)
end)
local RED = 0xffff0000
local BLUE = 0xff0000ff
local GREEN = 0xff00ff00
local YELLOW = 0xffffff00
describe("harmonize", function()
	it("redToBlue", function()
		local answer = Blend:harmonize(RED, BLUE)
		expect(answer).matchesColor(0xffFB0057)
	end)
	it("redToGreen", function()
		local answer = Blend:harmonize(RED, GREEN)
		expect(answer).matchesColor(0xffD85600)
	end)
	it("redToYellow", function()
		local answer = Blend:harmonize(RED, YELLOW)
		expect(answer).matchesColor(0xffD85600)
	end)
	it("blueToGreen", function()
		local answer = Blend:harmonize(BLUE, GREEN)
		expect(answer).matchesColor(0xff0047A3)
	end)
	it("blueToRed", function()
		local answer = Blend:harmonize(BLUE, RED)
		expect(answer).matchesColor(0xff5700DC)
	end)
	it("blueToYellow", function()
		local answer = Blend:harmonize(BLUE, YELLOW)
		expect(answer).matchesColor(0xff0047A3)
	end)
	it("greenToBlue", function()
		local answer = Blend:harmonize(GREEN, BLUE)
		expect(answer).matchesColor(0xff00FC94)
	end)
	it("greenToRed", function()
		local answer = Blend:harmonize(GREEN, RED)
		expect(answer).matchesColor(0xffB1F000)
	end)
	it("greenToYellow", function()
		local answer = Blend:harmonize(GREEN, YELLOW)
		expect(answer).matchesColor(0xffB1F000)
	end)
	it("yellowToBlue", function()
		local answer = Blend:harmonize(YELLOW, BLUE)
		expect(answer).matchesColor(0xffEBFFBA)
	end)
	it("yellowToGreen", function()
		local answer = Blend:harmonize(YELLOW, GREEN)
		expect(answer).matchesColor(0xffEBFFBA)
	end)
	it("yellowToRed", function()
		local answer = Blend:harmonize(YELLOW, RED)
		expect(answer).matchesColor(0xffFFF6E3)
	end)
end)
