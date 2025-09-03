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
local TemperatureCache = require(script.Parent["temperature_cache"]).TemperatureCache
describe("TemperatureCache", function()
	it("computes raw temperatures correctly", function()
		local blueTemp = TemperatureCache:rawTemperature(Hct.fromInt(0xff0000ff))
		expect(blueTemp).toBeCloseTo(-1.393, 3)
		local redTemp = TemperatureCache:rawTemperature(Hct.fromInt(0xffff0000))
		expect(redTemp).toBeCloseTo(2.351, 3)
		local greenTemp = TemperatureCache:rawTemperature(Hct.fromInt(0xff00ff00))
		expect(greenTemp).toBeCloseTo(-0.267, 3)
		local whiteTemp = TemperatureCache:rawTemperature(Hct.fromInt(0xffffffff))
		expect(whiteTemp).toBeCloseTo(-0.5, 3)
		local blackTemp = TemperatureCache:rawTemperature(Hct.fromInt(0xff000000))
		expect(blackTemp).toBeCloseTo(-0.5, 3)
	end)
	it("relative temperature", function()
		local blueTemp = TemperatureCache.new(Hct.fromInt(0xff0000ff)).inputRelativeTemperature
		expect(blueTemp).toBeCloseTo(0.0, 3)
		local redTemp = TemperatureCache.new(Hct.fromInt(0xffff0000)).inputRelativeTemperature
		expect(redTemp).toBeCloseTo(1.0, 3)
		local greenTemp = TemperatureCache.new(Hct.fromInt(0xff00ff00)).inputRelativeTemperature
		expect(greenTemp).toBeCloseTo(0.467, 3)
		local whiteTemp = TemperatureCache.new(Hct.fromInt(0xffffffff)).inputRelativeTemperature
		expect(whiteTemp).toBeCloseTo(0.5, 3)
		local blackTemp = TemperatureCache.new(Hct.fromInt(0xff000000)).inputRelativeTemperature
		expect(blackTemp).toBeCloseTo(0.5, 3)
	end)
	it("complement", function()
		local blueComplement = TemperatureCache.new(Hct.fromInt(0xff0000ff)).complement:toInt()
		expect(blueComplement).toBe(0xff9d0002)
		local redComplement = TemperatureCache.new(Hct.fromInt(0xffff0000)).complement:toInt()
		expect(redComplement).toBe(0xff007bfc)
		local greenComplement = TemperatureCache.new(Hct.fromInt(0xff00ff00)).complement:toInt()
		expect(greenComplement).toBe(0xffffd2c9)
		local whiteComplement = TemperatureCache.new(Hct.fromInt(0xffffffff)).complement:toInt()
		expect(whiteComplement).toBe(0xffffffff)
		local blackComplement = TemperatureCache.new(Hct.fromInt(0xff000000)).complement:toInt()
		expect(blackComplement).toBe(0xff000000)
	end)
	it("analogous", function()
		local blueAnalogous = Array.map(
			TemperatureCache.new(Hct.fromInt(0xff0000ff)):analogous(),
			function(e)
				return e:toInt()
			end
		) --[[ ROBLOX CHECK: check if 'new TemperatureCache(Hct.fromInt(0xff0000ff)).analogous()' is an Array ]]
		expect(blueAnalogous[
			1 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xff00590c)
		expect(blueAnalogous[
			2 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xff00564e)
		expect(blueAnalogous[
			3 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xff0000ff)
		expect(blueAnalogous[
			4 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xff6700cc)
		expect(blueAnalogous[
			5 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xff81009f)
		local redAnalogous = Array.map(
			TemperatureCache.new(Hct.fromInt(0xffff0000)):analogous(),
			function(e)
				return e:toInt()
			end
		) --[[ ROBLOX CHECK: check if 'new TemperatureCache(Hct.fromInt(0xffff0000)).analogous()' is an Array ]]
		expect(redAnalogous[
			1 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xfff60082)
		expect(redAnalogous[
			2 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xfffc004c)
		expect(redAnalogous[
			3 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xffff0000)
		expect(redAnalogous[
			4 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xffd95500)
		expect(redAnalogous[
			5 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xffaf7200)
		local greenAnalogous = Array.map(
			TemperatureCache.new(Hct.fromInt(0xff00ff00)):analogous(),
			function(e)
				return e:toInt()
			end
		) --[[ ROBLOX CHECK: check if 'new TemperatureCache(Hct.fromInt(0xff00ff00)).analogous()' is an Array ]]
		expect(greenAnalogous[
			1 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xffcee900)
		expect(greenAnalogous[
			2 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xff92f500)
		expect(greenAnalogous[
			3 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xff00ff00)
		expect(greenAnalogous[
			4 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xff00fd6f)
		expect(greenAnalogous[
			5 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xff00fab3)
		local blackAnalogous = Array.map(
			TemperatureCache.new(Hct.fromInt(0xff000000)):analogous(),
			function(e)
				return e:toInt()
			end
		) --[[ ROBLOX CHECK: check if 'new TemperatureCache(Hct.fromInt(0xff000000)).analogous()' is an Array ]]
		expect(blackAnalogous[
			1 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xff000000)
		expect(blackAnalogous[
			2 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xff000000)
		expect(blackAnalogous[
			3 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xff000000)
		expect(blackAnalogous[
			4 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xff000000)
		expect(blackAnalogous[
			5 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xff000000)
		local whiteAnalogous = Array.map(
			TemperatureCache.new(Hct.fromInt(0xffffffff)):analogous(),
			function(e)
				return e:toInt()
			end
		) --[[ ROBLOX CHECK: check if 'new TemperatureCache(Hct.fromInt(0xffffffff)).analogous()' is an Array ]]
		expect(whiteAnalogous[
			1 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xffffffff)
		expect(whiteAnalogous[
			2 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xffffffff)
		expect(whiteAnalogous[
			3 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xffffffff)
		expect(whiteAnalogous[
			4 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xffffffff)
		expect(whiteAnalogous[
			5 --[[ ROBLOX adaptation: added 1 to array index ]]
		]).toBe(0xffffffff)
	end)
end)
