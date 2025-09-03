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
require(Packages.jasmine)
local customMatchers = require(script.Parent.Parent.utils["test_utils"]).customMatchers
local SchemeAndroid = require(script.Parent["scheme_android"]).SchemeAndroid
beforeEach(function()
	jasmine:addMatchers(customMatchers)
end)
describe("android scheme", function()
	it("blue light scheme", function()
		local scheme = SchemeAndroid:light(0xff0000ff)
		expect(scheme.colorAccentPrimary).matchesColor(0xffe0e0ff)
	end)
	it("blue dark scheme", function()
		local scheme = SchemeAndroid:dark(0xff0000ff)
		expect(scheme.colorAccentPrimary).matchesColor(0xffe0e0ff)
	end)
	it("3rd party light scheme", function()
		local scheme = SchemeAndroid:light(0xff6750a4)
		expect(scheme.colorAccentPrimary).matchesColor(0xffe9ddff)
		expect(scheme.colorAccentSecondary).matchesColor(0xffe8def8)
		expect(scheme.colorAccentTertiary).matchesColor(0xffffd9e3)
		expect(scheme.colorSurface).matchesColor(0xfffdf8fd)
		expect(scheme.textColorPrimary).matchesColor(0xff1c1b1e)
	end)
	it("3rd party dark scheme", function()
		local scheme = SchemeAndroid:dark(0xff6750a4)
		expect(scheme.colorAccentPrimary).matchesColor(0xffe9ddff)
		expect(scheme.colorAccentSecondary).matchesColor(0xffe8def8)
		expect(scheme.colorAccentTertiary).matchesColor(0xffffd9e3)
		expect(scheme.colorSurface).matchesColor(0xff313033)
		expect(scheme.textColorPrimary).matchesColor(0xfff4eff4)
	end)
end)
