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
local Boolean = LuauPolyfill.Boolean
local Error = LuauPolyfill.Error
local Math = LuauPolyfill.Math
type Array<T> = LuauPolyfill.Array<T>
local exports = {}
local utils = require(script.Parent.Parent.utils["color_utils"])
local QuantizerMap = require(script.Parent["quantizer_map"]).QuantizerMap
local INDEX_BITS = 5
local SIDE_LENGTH = 33 -- ((1 << INDEX_INDEX_BITS) + 1)
local TOTAL_SIZE = 35937 -- SIDE_LENGTH * SIDE_LENGTH * SIDE_LENGTH
local directions = { RED = "red", GREEN = "green", BLUE = "blue" }
--[[*
 * An image quantizer that divides the image's pixels into clusters by
 * recursively cutting an RGB cube, based on the weight of pixels in each area
 * of the cube.
 *
 * The algorithm was described by Xiaolin Wu in Graphic Gems II, published in
 * 1991.
 ]]
export type QuantizerWu = { --[[*
   * @param pixels Colors in ARGB format.
   * @param maxColors The number of colors to divide the image into. A lower
   *     number of colors may be returned.
   * @return Colors in ARGB format.
   ]]
	quantize: (self: QuantizerWu, pixels: Array<number>, maxColors: number) -> Array<number>,
}
type QuantizerWu_private = { --
	-- *** PUBLIC ***
	--
	quantize: (
		self: QuantizerWu_private,
		pixels: Array<number>,
		maxColors: number
	) -> Array<number>,
	--
	-- *** PRIVATE ***
	--
	weights: Array<number>,
	momentsR: Array<number>,
	momentsG: Array<number>,
	momentsB: Array<number>,
	moments: Array<number>,
	cubes: Array<Box>,
	constructHistogram: (self: QuantizerWu_private, pixels: Array<number>) -> any,
	computeMoments: (self: QuantizerWu_private) -> any,
	createBoxes: (self: QuantizerWu_private, maxColors: number) -> CreateBoxesResult,
	createResult: (self: QuantizerWu_private, colorCount: number) -> Array<number>,
	variance: (self: QuantizerWu_private, cube: Box) -> any,
	cut: (self: QuantizerWu_private, one: Box, two: Box) -> any,
	maximize: (
		self: QuantizerWu_private,
		cube: Box,
		direction: string,
		first: number,
		last: number,
		wholeR: number,
		wholeG: number,
		wholeB: number,
		wholeW: number
	) -> any,
	volume: (self: QuantizerWu_private, cube: Box, moment: Array<number>) -> any,
	bottom: (self: QuantizerWu_private, cube: Box, direction: string, moment: Array<number>) -> any,
	top: (
		self: QuantizerWu_private,
		cube: Box,
		direction: string,
		position: number,
		moment: Array<number>
	) -> any,
	getIndex: (self: QuantizerWu_private, r: number, g: number, b: number) -> number,
}
type QuantizerWu_statics = {
	new: (
		weights_: Array<number>?,
		momentsR_: Array<number>?,
		momentsG_: Array<number>?,
		momentsB_: Array<number>?,
		moments_: Array<number>?,
		cubes_: Array<Box>?
	) -> QuantizerWu,
}
local QuantizerWu = {} :: QuantizerWu & QuantizerWu_statics
local QuantizerWu_private = QuantizerWu :: QuantizerWu_private & QuantizerWu_statics;
(QuantizerWu :: any).__index = QuantizerWu
function QuantizerWu_private.new(
	weights_: Array<number>?,
	momentsR_: Array<number>?,
	momentsG_: Array<number>?,
	momentsB_: Array<number>?,
	moments_: Array<number>?,
	cubes_: Array<Box>?
): QuantizerWu
	local self = setmetatable({}, QuantizerWu)
	local weights: Array<number> = if weights_ ~= nil then weights_ else {}
	local momentsR: Array<number> = if momentsR_ ~= nil then momentsR_ else {}
	local momentsG: Array<number> = if momentsG_ ~= nil then momentsG_ else {}
	local momentsB: Array<number> = if momentsB_ ~= nil then momentsB_ else {}
	local moments: Array<number> = if moments_ ~= nil then moments_ else {}
	local cubes: Array<Box> = if cubes_ ~= nil then cubes_ else {}
	self.weights = weights
	self.momentsR = momentsR
	self.momentsG = momentsG
	self.momentsB = momentsB
	self.moments = moments
	self.cubes = cubes
	return (self :: any) :: QuantizerWu
end
function QuantizerWu_private:quantize(pixels: Array<number>, maxColors: number): Array<number>
	self:constructHistogram(pixels)
	self:computeMoments()
	local createBoxesResult = self:createBoxes(maxColors)
	local results = self:createResult(createBoxesResult.resultCount)
	return results
end
function QuantizerWu_private:constructHistogram(pixels: Array<number>)
	self.weights = Array.from({ length = TOTAL_SIZE }):fill(0)
	self.momentsR = Array.from({ length = TOTAL_SIZE }):fill(0)
	self.momentsG = Array.from({ length = TOTAL_SIZE }):fill(0)
	self.momentsB = Array.from({ length = TOTAL_SIZE }):fill(0)
	self.moments = Array.from({ length = TOTAL_SIZE }):fill(0)
	local countByColor = QuantizerMap:quantize(pixels)
	for _, ref in countByColor:entries() do
		local pixel, count = table.unpack(ref, 1, 2)
		local red = utils:redFromArgb(pixel)
		local green = utils:greenFromArgb(pixel)
		local blue = utils:blueFromArgb(pixel)
		local bitsToRemove = 8 - INDEX_BITS
		local iR = bit32.arshift(red, bitsToRemove) --[[ ROBLOX CHECK: `bit32.arshift` clamps arguments and result to [0,2^32 - 1] ]]
			+ 1
		local iG = bit32.arshift(green, bitsToRemove) --[[ ROBLOX CHECK: `bit32.arshift` clamps arguments and result to [0,2^32 - 1] ]]
			+ 1
		local iB = bit32.arshift(blue, bitsToRemove) --[[ ROBLOX CHECK: `bit32.arshift` clamps arguments and result to [0,2^32 - 1] ]]
			+ 1
		local index = self:getIndex(iR, iG, iB)
		self.weights[tostring(index)] = (
			if self.weights[tostring(index)] ~= nil then self.weights[tostring(index)] else 0
		) + count
		self.momentsR[tostring(index)] += count * red
		self.momentsG[tostring(index)] += count * green
		self.momentsB[tostring(index)] += count * blue
		self.moments[tostring(index)] += count * (red * red + green * green + blue * blue)
	end
end
function QuantizerWu_private:computeMoments()
	do
		local r = 1
		while
			r
			< SIDE_LENGTH --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		do
			local area = Array.from({ length = SIDE_LENGTH }):fill(0)
			local areaR = Array.from({ length = SIDE_LENGTH }):fill(0)
			local areaG = Array.from({ length = SIDE_LENGTH }):fill(0)
			local areaB = Array.from({ length = SIDE_LENGTH }):fill(0)
			local area2 = Array.from({ length = SIDE_LENGTH }):fill(0.0)
			do
				local g = 1
				while
					g
					< SIDE_LENGTH --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
				do
					local line = 0
					local lineR = 0
					local lineG = 0
					local lineB = 0
					local line2 = 0.0
					do
						local b = 1
						while
							b
							< SIDE_LENGTH --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
						do
							local index = self:getIndex(r, g, b)
							line += self.weights[tostring(index)]
							lineR += self.momentsR[tostring(index)]
							lineG += self.momentsG[tostring(index)]
							lineB += self.momentsB[tostring(index)]
							line2 += self.moments[tostring(index)]
							area[tostring(b)] += line
							areaR[tostring(b)] += lineR
							areaG[tostring(b)] += lineG
							areaB[tostring(b)] += lineB
							area2[tostring(b)] += line2
							local previousIndex = self:getIndex(r - 1, g, b)
							self.weights[tostring(index)] = self.weights[tostring(previousIndex)]
								+ area[tostring(b)]
							self.momentsR[tostring(index)] = self.momentsR[tostring(previousIndex)]
								+ areaR[tostring(b)]
							self.momentsG[tostring(index)] = self.momentsG[tostring(previousIndex)]
								+ areaG[tostring(b)]
							self.momentsB[tostring(index)] = self.momentsB[tostring(previousIndex)]
								+ areaB[tostring(b)]
							self.moments[tostring(index)] = self.moments[tostring(previousIndex)]
								+ area2[tostring(b)]
							b += 1
						end
					end
					g += 1
				end
			end
			r += 1
		end
	end
end
function QuantizerWu_private:createBoxes(maxColors: number): CreateBoxesResult
	self.cubes = Array.map(Array.from({ length = maxColors }):fill(0), function()
		return Box.new()
	end) --[[ ROBLOX CHECK: check if 'Array.from<number>({
      length: maxColors
    }).fill(0)' is an Array ]]
	local volumeVariance = Array.from({ length = maxColors }):fill(0.0)
	self.cubes[
		1 --[[ ROBLOX adaptation: added 1 to array index ]]
	].r0 = 0
	self.cubes[
		1 --[[ ROBLOX adaptation: added 1 to array index ]]
	].g0 = 0
	self.cubes[
		1 --[[ ROBLOX adaptation: added 1 to array index ]]
	].b0 = 0
	self.cubes[
		1 --[[ ROBLOX adaptation: added 1 to array index ]]
	].r1 = SIDE_LENGTH - 1
	self.cubes[
		1 --[[ ROBLOX adaptation: added 1 to array index ]]
	].g1 = SIDE_LENGTH - 1
	self.cubes[
		1 --[[ ROBLOX adaptation: added 1 to array index ]]
	].b1 = SIDE_LENGTH - 1
	local generatedColorCount = maxColors
	local next_ = 0
	do
		local i = 1
		while
			i
			< maxColors --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		do
			if
				Boolean.toJSBoolean(self:cut(self.cubes[tostring(next_)], self.cubes[tostring(i)]))
			then
				volumeVariance[tostring(next_)] = if self.cubes[tostring(next_)].vol
						> 1 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
					then self:variance(self.cubes[tostring(next_)])
					else 0.0
				volumeVariance[tostring(i)] = if self.cubes[tostring(i)].vol
						> 1 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
					then self:variance(self.cubes[tostring(i)])
					else 0.0
			else
				volumeVariance[tostring(next_)] = 0.0
				i -= 1
			end
			next_ = 0
			local temp = volumeVariance[
				1 --[[ ROBLOX adaptation: added 1 to array index ]]
			]
			do
				local j = 1
				while
					j
					<= i --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]]
				do
					if
						volumeVariance[tostring(j)]
						> temp --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
					then
						temp = volumeVariance[tostring(j)]
						next_ = j
					end
					j += 1
				end
			end
			if
				temp
				<= 0.0 --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]]
			then
				generatedColorCount = i + 1
				break
			end
			i += 1
		end
	end
	return CreateBoxesResult.new(maxColors, generatedColorCount)
end
function QuantizerWu_private:createResult(colorCount: number): Array<number>
	local colors: Array<number> = {}
	do
		local i = 0
		while
			i
			< colorCount --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		do
			local cube = self.cubes[tostring(i)]
			local weight = self:volume(cube, self.weights)
			if
				weight
				> 0 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
			then
				local r = Math.round(self:volume(cube, self.momentsR) / weight) --[[ ROBLOX NOTE: Math.round is currently not supported by the Luau Math polyfill, please add your own implementation or file a ticket on the same ]]
				local g = Math.round(self:volume(cube, self.momentsG) / weight) --[[ ROBLOX NOTE: Math.round is currently not supported by the Luau Math polyfill, please add your own implementation or file a ticket on the same ]]
				local b = Math.round(self:volume(cube, self.momentsB) / weight) --[[ ROBLOX NOTE: Math.round is currently not supported by the Luau Math polyfill, please add your own implementation or file a ticket on the same ]]
				local color = bit32.bor(
					bit32.bor(
						bit32.bor(
							bit32.lshift(255, 24), --[[ ROBLOX CHECK: `bit32.lshift` clamps arguments and result to [0,2^32 - 1] ]]
							bit32.lshift(
								bit32.band(r, 0x0ff), --[[ ROBLOX CHECK: `bit32.band` clamps arguments and result to [0,2^32 - 1] ]]
								16
							) --[[ ROBLOX CHECK: `bit32.lshift` clamps arguments and result to [0,2^32 - 1] ]]
						), --[[ ROBLOX CHECK: `bit32.bor` clamps arguments and result to [0,2^32 - 1] ]]
						bit32.lshift(
							bit32.band(g, 0x0ff), --[[ ROBLOX CHECK: `bit32.band` clamps arguments and result to [0,2^32 - 1] ]]
							8
						) --[[ ROBLOX CHECK: `bit32.lshift` clamps arguments and result to [0,2^32 - 1] ]]
					), --[[ ROBLOX CHECK: `bit32.bor` clamps arguments and result to [0,2^32 - 1] ]]
					bit32.band(b, 0x0ff) --[[ ROBLOX CHECK: `bit32.band` clamps arguments and result to [0,2^32 - 1] ]]
				) --[[ ROBLOX CHECK: `bit32.bor` clamps arguments and result to [0,2^32 - 1] ]]
				table.insert(colors, color) --[[ ROBLOX CHECK: check if 'colors' is an Array ]]
			end
			i += 1
		end
	end
	return colors
end
function QuantizerWu_private:variance(cube: Box)
	local dr = self:volume(cube, self.momentsR)
	local dg = self:volume(cube, self.momentsG)
	local db = self:volume(cube, self.momentsB)
	local xx = self.moments[tostring(self:getIndex(cube.r1, cube.g1, cube.b1))]
		- self.moments[tostring(self:getIndex(cube.r1, cube.g1, cube.b0))]
		- self.moments[tostring(self:getIndex(cube.r1, cube.g0, cube.b1))]
		+ self.moments[tostring(self:getIndex(cube.r1, cube.g0, cube.b0))]
		- self.moments[tostring(self:getIndex(cube.r0, cube.g1, cube.b1))]
		+ self.moments[tostring(self:getIndex(cube.r0, cube.g1, cube.b0))]
		+ self.moments[tostring(self:getIndex(cube.r0, cube.g0, cube.b1))]
		- self.moments[tostring(self:getIndex(cube.r0, cube.g0, cube.b0))]
	local hypotenuse = dr * dr + dg * dg + db * db
	local volume = self:volume(cube, self.weights)
	return xx - hypotenuse / volume
end
function QuantizerWu_private:cut(one: Box, two: Box)
	local wholeR = self:volume(one, self.momentsR)
	local wholeG = self:volume(one, self.momentsG)
	local wholeB = self:volume(one, self.momentsB)
	local wholeW = self:volume(one, self.weights)
	local maxRResult =
		self:maximize(one, directions.RED, one.r0 + 1, one.r1, wholeR, wholeG, wholeB, wholeW)
	local maxGResult =
		self:maximize(one, directions.GREEN, one.g0 + 1, one.g1, wholeR, wholeG, wholeB, wholeW)
	local maxBResult =
		self:maximize(one, directions.BLUE, one.b0 + 1, one.b1, wholeR, wholeG, wholeB, wholeW)
	local direction
	local maxR = maxRResult.maximum
	local maxG = maxGResult.maximum
	local maxB = maxBResult.maximum
	if
		maxR >= maxG --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
		and maxR >= maxB --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
	then
		if
			maxRResult.cutLocation
			< 0 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		then
			return false
		end
		direction = directions.RED
	elseif
		maxG >= maxR --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
		and maxG >= maxB --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
	then
		direction = directions.GREEN
	else
		direction = directions.BLUE
	end
	two.r1 = one.r1
	two.g1 = one.g1
	two.b1 = one.b1
	local condition_ = direction
	if condition_ == directions.RED then
		one.r1 = maxRResult.cutLocation
		two.r0 = one.r1
		two.g0 = one.g0
		two.b0 = one.b0
	elseif condition_ == directions.GREEN then
		one.g1 = maxGResult.cutLocation
		two.r0 = one.r0
		two.g0 = one.g1
		two.b0 = one.b0
	elseif condition_ == directions.BLUE then
		one.b1 = maxBResult.cutLocation
		two.r0 = one.r0
		two.g0 = one.g0
		two.b0 = one.b1
	else
		error(Error.new("unexpected direction " .. tostring(direction)))
	end
	one.vol = (one.r1 - one.r0) * (one.g1 - one.g0) * (one.b1 - one.b0)
	two.vol = (two.r1 - two.r0) * (two.g1 - two.g0) * (two.b1 - two.b0)
	return true
end
function QuantizerWu_private:maximize(
	cube: Box,
	direction: string,
	first: number,
	last: number,
	wholeR: number,
	wholeG: number,
	wholeB: number,
	wholeW: number
)
	local bottomR = self:bottom(cube, direction, self.momentsR)
	local bottomG = self:bottom(cube, direction, self.momentsG)
	local bottomB = self:bottom(cube, direction, self.momentsB)
	local bottomW = self:bottom(cube, direction, self.weights)
	local max = 0.0
	local cut = -1
	local halfR = 0
	local halfG = 0
	local halfB = 0
	local halfW = 0
	do
		local i = first
		while
			i
			< last --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		do
			halfR = bottomR + self:top(cube, direction, i, self.momentsR)
			halfG = bottomG + self:top(cube, direction, i, self.momentsG)
			halfB = bottomB + self:top(cube, direction, i, self.momentsB)
			halfW = bottomW + self:top(cube, direction, i, self.weights)
			if halfW == 0 then
				i += 1
				continue
			end
			local tempNumerator = (halfR * halfR + halfG * halfG + halfB * halfB) * 1.0
			local tempDenominator = halfW * 1.0
			local temp = tempNumerator / tempDenominator
			halfR = wholeR - halfR
			halfG = wholeG - halfG
			halfB = wholeB - halfB
			halfW = wholeW - halfW
			if halfW == 0 then
				i += 1
				continue
			end
			tempNumerator = (halfR * halfR + halfG * halfG + halfB * halfB) * 1.0
			tempDenominator = halfW * 1.0
			temp += tempNumerator / tempDenominator
			if
				temp
				> max --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
			then
				max = temp
				cut = i
			end
			i += 1
		end
	end
	return MaximizeResult.new(cut, max)
end
function QuantizerWu_private:volume(cube: Box, moment: Array<number>)
	return moment[tostring(self:getIndex(cube.r1, cube.g1, cube.b1))]
		- moment[tostring(self:getIndex(cube.r1, cube.g1, cube.b0))]
		- moment[tostring(self:getIndex(cube.r1, cube.g0, cube.b1))]
		+ moment[tostring(self:getIndex(cube.r1, cube.g0, cube.b0))]
		- moment[tostring(self:getIndex(cube.r0, cube.g1, cube.b1))]
		+ moment[tostring(self:getIndex(cube.r0, cube.g1, cube.b0))]
		+ moment[tostring(self:getIndex(cube.r0, cube.g0, cube.b1))]
		- moment[tostring(self:getIndex(cube.r0, cube.g0, cube.b0))]
end
function QuantizerWu_private:bottom(cube: Box, direction: string, moment: Array<number>)
	local condition_ = direction
	if condition_ == directions.RED then
		return -moment[tostring(self:getIndex(cube.r0, cube.g1, cube.b1))]
			+ moment[tostring(self:getIndex(cube.r0, cube.g1, cube.b0))]
			+ moment[tostring(self:getIndex(cube.r0, cube.g0, cube.b1))]
			- moment[tostring(self:getIndex(cube.r0, cube.g0, cube.b0))]
	elseif condition_ == directions.GREEN then
		return -moment[tostring(self:getIndex(cube.r1, cube.g0, cube.b1))]
			+ moment[tostring(self:getIndex(cube.r1, cube.g0, cube.b0))]
			+ moment[tostring(self:getIndex(cube.r0, cube.g0, cube.b1))]
			- moment[tostring(self:getIndex(cube.r0, cube.g0, cube.b0))]
	elseif condition_ == directions.BLUE then
		return -moment[tostring(self:getIndex(cube.r1, cube.g1, cube.b0))]
			+ moment[tostring(self:getIndex(cube.r1, cube.g0, cube.b0))]
			+ moment[tostring(self:getIndex(cube.r0, cube.g1, cube.b0))]
			- moment[tostring(self:getIndex(cube.r0, cube.g0, cube.b0))]
	else
		error(Error.new("unexpected direction $direction"))
	end
end
function QuantizerWu_private:top(
	cube: Box,
	direction: string,
	position: number,
	moment: Array<number>
)
	local condition_ = direction
	if condition_ == directions.RED then
		return moment[tostring(self:getIndex(position, cube.g1, cube.b1))]
			- moment[tostring(self:getIndex(position, cube.g1, cube.b0))]
			- moment[tostring(self:getIndex(position, cube.g0, cube.b1))]
			+ moment[tostring(self:getIndex(position, cube.g0, cube.b0))]
	elseif condition_ == directions.GREEN then
		return moment[tostring(self:getIndex(cube.r1, position, cube.b1))]
			- moment[tostring(self:getIndex(cube.r1, position, cube.b0))]
			- moment[tostring(self:getIndex(cube.r0, position, cube.b1))]
			+ moment[tostring(self:getIndex(cube.r0, position, cube.b0))]
	elseif condition_ == directions.BLUE then
		return moment[tostring(self:getIndex(cube.r1, cube.g1, position))]
			- moment[tostring(self:getIndex(cube.r1, cube.g0, position))]
			- moment[tostring(self:getIndex(cube.r0, cube.g1, position))]
			+ moment[tostring(self:getIndex(cube.r0, cube.g0, position))]
	else
		error(Error.new("unexpected direction $direction"))
	end
end
function QuantizerWu_private:getIndex(r: number, g: number, b: number): number
	return bit32.lshift(r, INDEX_BITS * 2) --[[ ROBLOX CHECK: `bit32.lshift` clamps arguments and result to [0,2^32 - 1] ]]
		+ bit32.lshift(r, INDEX_BITS + 1) --[[ ROBLOX CHECK: `bit32.lshift` clamps arguments and result to [0,2^32 - 1] ]]
		+ r
		+ bit32.lshift(g, INDEX_BITS) --[[ ROBLOX CHECK: `bit32.lshift` clamps arguments and result to [0,2^32 - 1] ]]
		+ g
		+ b
end
exports.QuantizerWu = QuantizerWu
--[[*
 * Keeps track of the state of each box created as the Wu  quantization
 * algorithm progresses through dividing the image's pixels as plotted in RGB.
 ]]
type Box = { r0: number, r1: number, g0: number, g1: number, b0: number, b1: number, vol: number }
type Box_statics = {
	new: (
		r0_: number?,
		r1_: number?,
		g0_: number?,
		g1_: number?,
		b0_: number?,
		b1_: number?,
		vol_: number?
	) -> Box,
}
local Box = {} :: Box & Box_statics;
(Box :: any).__index = Box
function Box.new(
	r0_: number?,
	r1_: number?,
	g0_: number?,
	g1_: number?,
	b0_: number?,
	b1_: number?,
	vol_: number?
): Box
	local self = setmetatable({}, Box)
	local r0: number = if r0_ ~= nil then r0_ else 0
	local r1: number = if r1_ ~= nil then r1_ else 0
	local g0: number = if g0_ ~= nil then g0_ else 0
	local g1: number = if g1_ ~= nil then g1_ else 0
	local b0: number = if b0_ ~= nil then b0_ else 0
	local b1: number = if b1_ ~= nil then b1_ else 0
	local vol: number = if vol_ ~= nil then vol_ else 0
	self.r0 = r0
	self.r1 = r1
	self.g0 = g0
	self.g1 = g1
	self.b0 = b0
	self.b1 = b1
	self.vol = vol
	return (self :: any) :: Box
end
--[[*
 * Represents final result of Wu algorithm.
 ]]
type CreateBoxesResult = { requestedCount: number, resultCount: number }
type CreateBoxesResult_statics = {
	new: (requestedCount: number, resultCount: number) -> CreateBoxesResult,
}
local CreateBoxesResult = {} :: CreateBoxesResult & CreateBoxesResult_statics;
(CreateBoxesResult :: any).__index = CreateBoxesResult
--[[*
   * @param requestedCount how many colors the caller asked to be returned from
   *     quantization.
   * @param resultCount the actual number of colors achieved from quantization.
   *     May be lower than the requested count.
   ]]
function CreateBoxesResult.new(requestedCount: number, resultCount: number): CreateBoxesResult
	local self = setmetatable({}, CreateBoxesResult)
	self.requestedCount = requestedCount
	self.resultCount = resultCount
	return (self :: any) :: CreateBoxesResult
end
--[[*
 * Represents the result of calculating where to cut an existing box in such
 * a way to maximize variance between the two new boxes created by a cut.
 ]]
type MaximizeResult = { cutLocation: number, maximum: number }
type MaximizeResult_statics = { new: (cutLocation: number, maximum: number) -> MaximizeResult }
local MaximizeResult = {} :: MaximizeResult & MaximizeResult_statics;
(MaximizeResult :: any).__index = MaximizeResult
function MaximizeResult.new(cutLocation: number, maximum: number): MaximizeResult
	local self = setmetatable({}, MaximizeResult)
	self.cutLocation = cutLocation
	self.maximum = maximum
	return (self :: any) :: MaximizeResult
end
return exports
