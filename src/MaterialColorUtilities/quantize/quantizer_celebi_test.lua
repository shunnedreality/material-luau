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
local QuantizerCelebi = require(script.Parent["quantizer_celebi"]).QuantizerCelebi
local RED = 0xffff0000
local GREEN = 0xff00ff00
local BLUE = 0xff0000ff
describe("QuantizerCelebi", function()
	it("1R", function()
		local answer = QuantizerCelebi:quantize({ RED }, 128)
		expect(answer.size).toBe(1)
		expect(answer:get(RED)).toBe(1)
	end)
	it("1G", function()
		local answer = QuantizerCelebi:quantize({ GREEN }, 128)
		expect(answer.size).toBe(1)
		expect(answer:get(GREEN)).toBe(1)
	end)
	it("1B", function()
		local answer = QuantizerCelebi:quantize({ BLUE }, 128)
		expect(answer.size).toBe(1)
		expect(answer:get(BLUE)).toBe(1)
	end)
	it("5B", function()
		local answer = QuantizerCelebi:quantize({ BLUE, BLUE, BLUE, BLUE, BLUE }, 128)
		expect(answer.size).toBe(1)
		expect(answer:get(BLUE)).toBe(5)
	end)
	it("2R 3G", function()
		local answer = QuantizerCelebi:quantize({ RED, RED, GREEN, GREEN, GREEN }, 128)
		expect(answer.size).toBe(2)
		expect(answer:get(RED)).toBe(2)
		expect(answer:get(GREEN)).toBe(3)
	end)
	it("1R 1G 1B", function()
		local answer = QuantizerCelebi:quantize({ RED, GREEN, BLUE }, 128)
		expect(answer.size).toBe(3)
		expect(answer:get(RED)).toBe(1)
		expect(answer:get(GREEN)).toBe(1)
		expect(answer:get(BLUE)).toBe(1)
	end)
end)
