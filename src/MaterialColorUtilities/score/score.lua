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
local Math = LuauPolyfill.Math
local Object = LuauPolyfill.Object
type Array<T> = LuauPolyfill.Array<T>
type Map<T, U> = LuauPolyfill.Map<T, U>
local exports = {}
local Hct = require(script.Parent.Parent.hct["hct"]).Hct
local math_ = require(script.Parent.Parent.utils["math_utils"])
--[[*
 * Default options for ranking colors based on usage counts.
 * desired: is the max count of the colors returned.
 * fallbackColorARGB: Is the default color that should be used if no
 *                    other colors are suitable.
 * filter: controls if the resulting colors should be filtered to not include
 *         hues that are not used often enough, and colors that are effectively
 *         grayscale.
 ]]
type ScoreOptions = { desired: number?, fallbackColorARGB: number?, filter: boolean? }
local SCORE_OPTION_DEFAULTS = {
	desired = 4,
	-- 4 colors matches what Android wallpaper picker.
	fallbackColorARGB = 0xff4285f4,
	-- Google Blue.
	filter = true, -- Avoid unsuitable colors.
}
local function compare(a: { hct: Hct, score: number }, b: { hct: Hct, score: number }): number
	if
		a.score
		> b.score --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
	then
		return -1
	elseif
		a.score
		< b.score --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
	then
		return 1
	end
	return 0
end
--[[*
 *  Given a large set of colors, remove colors that are unsuitable for a UI
 *  theme, and rank the rest based on suitability.
 *
 *  Enables use of a high cluster count for image quantization, thus ensuring
 *  colors aren't muddied, while curating the high cluster count to a much
 *  smaller number of appropriate choices.
 ]]
export type Score = {}
type Score_private = {}
type Score_statics = { new: () -> Score }
local Score = {} :: Score & Score_statics
local Score_private = Score :: Score_private & Score_statics;
(Score :: any).__index = Score
Score_private.TARGET_CHROMA = 48.0
Score_private.WEIGHT_PROPORTION = 0.7
Score_private.WEIGHT_CHROMA_ABOVE = 0.3
Score_private.WEIGHT_CHROMA_BELOW = 0.1
Score_private.CUTOFF_CHROMA = 5.0
Score_private.CUTOFF_EXCITED_PROPORTION = 0.01
function Score_private.new(): Score
	local self = setmetatable({}, Score)
	return (self :: any) :: Score
end
--[[*
   * Given a map with keys of colors and values of how often the color appears,
   * rank the colors based on suitability for being used for a UI theme.
   *
   * @param colorsToPopulation map with keys of colors and values of how often
   *     the color appears, usually from a source image.
   * @param {ScoreOptions} options optional parameters.
   * @return Colors sorted by suitability for a UI theme. The most suitable
   *     color is the first item, the least suitable is the last. There will
   *     always be at least one color returned. If all the input colors
   *     were not suitable for a theme, a default fallback color will be
   *     provided, Google Blue.
   ]]
function Score_private.score(
	colorsToPopulation: Map<number, number>,
	options: ScoreOptions?
): Array<number>
	local desired, fallbackColorARGB, filter
	do
		local ref = Object.assign({}, SCORE_OPTION_DEFAULTS, options)
		desired, fallbackColorARGB, filter = ref.desired, ref.fallbackColorARGB, ref.filter
	end
	-- Get the HCT color for each Argb value, while finding the per hue count and
	-- total count.
	local colorsHct: Array<Hct> = {}
	local huePopulation = Array.new(360):fill(0)
	local populationSum = 0
	for _, ref in colorsToPopulation:entries() do
		local argb, population = table.unpack(ref, 1, 2)
		local hct = Hct.fromInt(argb)
		table.insert(colorsHct, hct) --[[ ROBLOX CHECK: check if 'colorsHct' is an Array ]]
		local hue = math.floor(hct.hue)
		huePopulation[tostring(hue)] += population
		populationSum += population
	end
	-- Hues with more usage in neighboring 30 degree slice get a larger number.
	local hueExcitedProportions = Array.new(360):fill(0.0)
	do
		local hue = 0
		while
			hue
			< 360 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		do
			local proportion = huePopulation[tostring(hue)] / populationSum
			do
				local i = hue - 14
				while
					i
					< hue + 16 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
				do
					local neighborHue = math_:sanitizeDegreesInt(i)
					hueExcitedProportions[tostring(neighborHue)] += proportion
					i += 1
				end
			end
			hue += 1
		end
	end
	-- Scores each HCT color based on usage and chroma, while optionally
	-- filtering out values that do not have enough chroma or usage.
	local scoredHct = Array.new()
	for _, hct in colorsHct do
		local hue = math_:sanitizeDegreesInt(
			Math.round(hct.hue) --[[ ROBLOX NOTE: Math.round is currently not supported by the Luau Math polyfill, please add your own implementation or file a ticket on the same ]]
		)
		local proportion = hueExcitedProportions[tostring(hue)]
		if
			Boolean.toJSBoolean(if Boolean.toJSBoolean(filter)
				then hct.chroma < Score.CUTOFF_CHROMA --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
					or proportion <= Score.CUTOFF_EXCITED_PROPORTION --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]]
				else filter)
		then
			continue
		end
		local proportionScore = proportion * 100.0 * Score.WEIGHT_PROPORTION
		local chromaWeight = if hct.chroma
				< Score.TARGET_CHROMA --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
			then Score.WEIGHT_CHROMA_BELOW
			else Score.WEIGHT_CHROMA_ABOVE
		local chromaScore = (hct.chroma - Score.TARGET_CHROMA) * chromaWeight
		local score = proportionScore + chromaScore
		table.insert(scoredHct, { hct = hct, score = score }) --[[ ROBLOX CHECK: check if 'scoredHct' is an Array ]]
	end
	-- Sorted so that colors with higher scores come first.
	Array.sort(scoredHct, compare) --[[ ROBLOX CHECK: check if 'scoredHct' is an Array ]]
	-- Iterates through potential hue differences in degrees in order to select
	-- the colors with the largest distribution of hues possible. Starting at
	-- 90 degrees(maximum difference for 4 colors) then decreasing down to a
	-- 15 degree minimum.
	local chosenColors: Array<Hct> = {}
	do
		local function _loop(differenceDegrees)
			chosenColors.length = 0
			for _, ref in scoredHct do
				local hct = ref.hct
				local duplicateHue = Array.find(chosenColors, function(chosenHct)
					return math_:differenceDegrees(hct.hue, chosenHct.hue) < differenceDegrees --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
				end) --[[ ROBLOX CHECK: check if 'chosenColors' is an Array ]]
				if not Boolean.toJSBoolean(duplicateHue) then
					table.insert(chosenColors, hct) --[[ ROBLOX CHECK: check if 'chosenColors' is an Array ]]
				end
				if
					chosenColors.length
					>= desired --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
				then
					break;
				end
			end
			if
				chosenColors.length
				>= desired --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
			then
				return
			end
		end
		local differenceDegrees = 90
		while
			differenceDegrees
			>= 15 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
		do
			_loop(differenceDegrees)
			differenceDegrees -= 1
		end
	end
	local colors: Array<number> = {}
	if chosenColors.length == 0 then
		table.insert(colors, fallbackColorARGB) --[[ ROBLOX CHECK: check if 'colors' is an Array ]]
	end
	for _, chosenHct in chosenColors do
		table.insert(colors, chosenHct:toInt()) --[[ ROBLOX CHECK: check if 'colors' is an Array ]]
	end
	return colors
end
exports.Score = Score
return exports
