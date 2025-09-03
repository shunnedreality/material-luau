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
require(Packages.jasmine)
local Hct = require(script.Parent.Parent.hct["hct"]).Hct
local DislikeAnalyzer = require(script.Parent["dislike_analyzer"]).DislikeAnalyzer
describe("dislike analyzer", function()
	it("likes Monk Skin Tone Scale colors", function()
		-- From https://skintone.google#/get-started
		local monkSkinToneScaleColors = {
			0xfff6ede4,
			0xfff3e7db,
			0xfff7ead0,
			0xffeadaba,
			0xffd7bd96,
			0xffa07e56,
			0xff825c43,
			0xff604134,
			0xff3a312a,
			0xff292420,
		}
		for _, color in monkSkinToneScaleColors do
			expect(DislikeAnalyzer:isDisliked(Hct.fromInt(color))).toBeFalse()
		end
	end)
	it("dislikes bile colors", function()
		local unlikable = { 0xff95884B, 0xff716B40, 0xffB08E00, 0xff4C4308, 0xff464521 }
		for _, color in unlikable do
			expect(DislikeAnalyzer:isDisliked(Hct.fromInt(color))).toBeTrue()
		end
	end)
	it("makes bile colors likable", function()
		local unlikable = { 0xff95884B, 0xff716B40, 0xffB08E00, 0xff4C4308, 0xff464521 }
		for _, color in unlikable do
			local hct = Hct.fromInt(color)
			expect(DislikeAnalyzer:isDisliked(hct)).toBeTrue()
			local likable = DislikeAnalyzer:fixIfDisliked(hct)
			expect(DislikeAnalyzer:isDisliked(likable)).toBeFalse()
		end
	end)
	it("likes tone 67 colors", function()
		local color = Array.from(Hct, 100.0, 50.0, 67.0) --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
		expect(DislikeAnalyzer:isDisliked(color)).toBeFalse()
		expect(DislikeAnalyzer:fixIfDisliked(color):toInt()).toEqual(color:toInt())
	end)
end)
