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
local exports = {}
--[[*
 * A color system built using CAM16 hue and chroma, and L* from
 * L*a*b*.
 *
 * Using L* creates a link between the color system, contrast, and thus
 * accessibility. Contrast ratio depends on relative luminance, or Y in the XYZ
 * color space. L*, or perceptual luminance can be calculated from Y.
 *
 * Unlike Y, L* is linear to human perception, allowing trivial creation of
 * accurate color tones.
 *
 * Unlike contrast ratio, measuring contrast in L* is linear, and simple to
 * calculate. A difference of 40 in HCT tone guarantees a contrast ratio >= 3.0,
 * and a difference of 50 guarantees a contrast ratio >= 4.5.
 ]]
local utils = require(script.Parent.Parent.utils["color_utils"])
local Cam16 = require(script.Parent["cam16"]).Cam16
local HctSolver = require(script.Parent["hct_solver"]).HctSolver
local ViewingConditions = require(script.Parent["viewing_conditions"]).ViewingConditions
--[[*
 * HCT, hue, chroma, and tone. A color system that provides a perceptually
 * accurate color measurement system that can also accurately render what colors
 * will appear as in different lighting environments.
 ]]
export type Hct = { --[[*
   * @param hue 0 <= hue < 360; invalid values are corrected.
   * @param chroma 0 <= chroma < ?; Informally, colorfulness. The color
   *     returned may be lower than the requested chroma. Chroma has a different
   *     maximum for any given hue and tone.
   * @param tone 0 <= tone <= 100; invalid values are corrected.
   * @return HCT representation of a color in default viewing conditions.
   ]]
	internalHue: number,
	internalChroma: number,
	internalTone: number,
	toInt: (self: Hct) -> number,
	--[[*
   * A number, in degrees, representing ex. red, orange, yellow, etc.
   * Ranges from 0 <= hue < 360.
   ]]
	hue: (self: Hct) -> number,
	--[[*
   * @param newHue 0 <= newHue < 360; invalid values are corrected.
   * Chroma may decrease because chroma has a different maximum for any given
   * hue and tone.
   ]]
	hue: (self: Hct, newHue: number) -> any,
	chroma: (self: Hct) -> number,
	--[[*
   * @param newChroma 0 <= newChroma < ?
   * Chroma may decrease because chroma has a different maximum for any given
   * hue and tone.
   ]]
	chroma: (self: Hct, newChroma: number) -> any,
	--[[* Lightness. Ranges from 0 to 100. ]]
	tone: (self: Hct) -> number,
	--[[*
   * @param newTone 0 <= newTone <= 100; invalid valids are corrected.
   * Chroma may decrease because chroma has a different maximum for any given
   * hue and tone.
   ]]
	tone: (self: Hct, newTone: number) -> any,
	--[[* Sets a property of the Hct object. ]]
	setValue: (self: Hct, propertyName: string, value: number) -> any,
	toString: (self: Hct) -> string,
	--[[*
   * Translates a color into different [ViewingConditions].
   *
   * Colors change appearance. They look different with lights on versus off,
   * the same color, as in hex code, on white looks different when on black.
   * This is called color relativity, most famously explicated by Josef Albers
   * in Interaction of Color.
   *
   * In color science, color appearance models can account for this and
   * calculate the appearance of a color in different settings. HCT is based on
   * CAM16, a color appearance model, and uses it to make these calculations.
   *
   * See [ViewingConditions.make] for parameters affecting color appearance.
   ]]
	inViewingConditions: (self: Hct, vc: ViewingConditions) -> Hct,
}
type Hct_private = { --
	-- *** PUBLIC ***
	--
	internalHue: number,
	internalChroma: number,
	internalTone: number,
	toInt: (self: Hct_private) -> number,
	hue: (self: Hct_private) -> number,
	hue: (self: Hct_private, newHue: number) -> any,
	chroma: (self: Hct_private) -> number,
	chroma: (self: Hct_private, newChroma: number) -> any,
	tone: (self: Hct_private) -> number,
	tone: (self: Hct_private, newTone: number) -> any,
	setValue: (self: Hct_private, propertyName: string, value: number) -> any,
	toString: (self: Hct_private) -> string,
	inViewingConditions: (self: Hct_private, vc: ViewingConditions) -> Hct,
	--
	-- *** PRIVATE ***
	--
	argb: number,
	setInternalState: (self: Hct_private, argb: number) -> any,
}
type Hct_statics = { new: (argb: number) -> Hct }
local Hct = {} :: Hct & Hct_statics
local Hct_private = Hct :: Hct_private & Hct_statics;
(Hct :: any).__index = Hct
function Hct_private.new(argb: number): Hct
	local self = setmetatable({}, Hct)
	self.argb = argb
	local cam = Cam16.fromInt(argb)
	self.internalHue = cam.hue
	self.internalChroma = cam.chroma
	self.internalTone = utils.lstarFromArgb(argb)
	self.argb = argb
	return (self :: any) :: Hct
end
function Hct_private.from(hue: number, chroma: number, tone: number)
	return Hct.new(HctSolver.solveToInt(hue, chroma, tone))
end
function Hct_private.fromInt(argb: number)
	return Hct.new(argb)
end
function Hct_private:toInt(): number
	return self.argb
end
function Hct_private:hue(): number
	return self.internalHue
end
function Hct_private:hue(newHue: number)
	if not newHue then
		return self.internalHue
	end
	self:setInternalState(HctSolver.solveToInt(newHue, self.internalChroma, self.internalTone))
end
function Hct_private:chroma(): number
	return self.internalChroma
end
function Hct_private:chroma(newChroma: number)
	if not newChroma then
		return self.internalChroma;
	end

	self:setInternalState(HctSolver.solveToInt(self.internalHue, newChroma, self.internalTone))
end
function Hct_private:tone(): number
	return self.internalTone
end
function Hct_private:tone(newTone: number)
	self:setInternalState(HctSolver.solveToInt(self.internalHue, self.internalChroma, newTone))
end
function Hct_private:setValue(propertyName: string, value: number)
	(self :: any)[tostring(propertyName)] = value
end
function Hct_private:toString(): string
	return ("HCT(%s, %s, %s)"):format(
		tostring(self.hue:toFixed(0)),
		tostring(self.chroma:toFixed(0)),
		tostring(self.tone:toFixed(0))
	)
end
function Hct_private.isBlue(hue: number): boolean
	return hue >= 250 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
		and hue < 270 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
end
function Hct_private.isYellow(hue: number): boolean
	return hue >= 105 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
		and hue < 125 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
end
function Hct_private.isCyan(hue: number): boolean
	return hue >= 170 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
		and hue < 207 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
end
function Hct_private:setInternalState(argb: number)
	local cam = Cam16.fromInt(argb)
	self.internalHue = cam.hue
	self.internalChroma = cam.chroma
	self.internalTone = utils.lstarFromArgb(argb)
	self.argb = argb
end
function Hct_private:inViewingConditions(vc: ViewingConditions): Hct
	-- 1. Use CAM16 to find XYZ coordinates of color in specified VC.
	local cam = Cam16.fromInt(self:toInt())
	local viewedInVc = cam:xyzInViewingConditions(vc)
	-- 2. Create CAM16 of those XYZ coordinates in default VC.
	local recastInVc = Cam16:fromXyzInViewingConditions(
		viewedInVc[
			1 --[[ ROBLOX adaptation: added 1 to array index ]]
		],
		viewedInVc[
			2 --[[ ROBLOX adaptation: added 1 to array index ]]
		],
		viewedInVc[
			3 --[[ ROBLOX adaptation: added 1 to array index ]]
		],
		ViewingConditions:make()
	)
	-- 3. Create HCT from:
	-- - CAM16 using default VC with XYZ coordinates in specified VC.
	-- - L* converted from Y in XYZ coordinates in specified VC.
	local recastHct = Array.from(
		Hct,
		recastInVc.hue,
		recastInVc.chroma,
		utils.lstarFromY(viewedInVc[
			2 --[[ ROBLOX adaptation: added 1 to array index ]]
		])
	) --[[ ROBLOX CHECK: check if 'Hct' is an Array ]]
	return recastHct
end
exports.Hct = Hct;
return exports
