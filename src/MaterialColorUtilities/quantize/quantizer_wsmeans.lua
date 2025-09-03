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
local Map = LuauPolyfill.Map
type Array<T> = LuauPolyfill.Array<T>
type Map<T, U> = LuauPolyfill.Map<T, U>
local exports = {}
local LabPointProvider = require(script.Parent["lab_point_provider"]).LabPointProvider
local MAX_ITERATIONS = 10
local MIN_MOVEMENT_DISTANCE = 3.0
--[[*
 * An image quantizer that improves on the speed of a standard K-Means algorithm
 * by implementing several optimizations, including deduping identical pixels
 * and a triangle inequality rule that reduces the number of comparisons needed
 * to identify which cluster a point should be moved to.
 *
 * Wsmeans stands for Weighted Square Means.
 *
 * This algorithm was designed by M. Emre Celebi, and was found in their 2011
 * paper, Improving the Performance of K-Means for Color Quantization.
 * https://arxiv.org/abs/1101.0395
 ]]
-- material_color_utilities is designed to have a consistent API across
-- platforms and modular components that can be moved around easily. Using a
-- class as a namespace facilitates this.
--
-- tslint:disable-next-line:class-as-namespace
export type QuantizerWsmeans = {}
type QuantizerWsmeans_statics = { new: () -> QuantizerWsmeans }
local QuantizerWsmeans = {} :: QuantizerWsmeans & QuantizerWsmeans_statics;
(QuantizerWsmeans :: any).__index = QuantizerWsmeans
function QuantizerWsmeans.new(): QuantizerWsmeans
	local self = setmetatable({}, QuantizerWsmeans)
	return (self :: any) :: QuantizerWsmeans
end
function QuantizerWsmeans.quantize(
	inputPixels: Array<number>,
	startingClusters: Array<number>,
	maxColors: number
): Map<number, number>
	local pixelToCount = Map.new()
	local points = Array.new()
	local pixels = Array.new()
	local pointProvider = LabPointProvider.new()
	local pointCount = 0
	do
		local i = 0
		while
			i
			< inputPixels.length --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		do
			local inputPixel = inputPixels[tostring(i)]
			local pixelCount = pixelToCount:get(inputPixel)
			if pixelCount == nil then
				pointCount += 1
				table.insert(points, pointProvider:fromInt(inputPixel)) --[[ ROBLOX CHECK: check if 'points' is an Array ]]
				table.insert(pixels, inputPixel) --[[ ROBLOX CHECK: check if 'pixels' is an Array ]]
				pixelToCount:set(inputPixel, 1)
			else
				pixelToCount:set(inputPixel, pixelCount + 1)
			end
			i += 1
		end
	end
	local counts = Array.new()
	do
		local i = 0
		while
			i
			< pointCount --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		do
			local pixel = pixels[tostring(i)]
			local count = pixelToCount:get(pixel)
			if count ~= nil then
				counts[tostring(i)] = count
			end
			i += 1
		end
	end
	local clusterCount = math.min(maxColors, pointCount)
	if
		startingClusters.length
		> 0 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
	then
		clusterCount = math.min(clusterCount, startingClusters.length)
	end
	local clusters = Array.new()
	do
		local i = 0
		while
			i
			< startingClusters.length --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		do
			table.insert(clusters, pointProvider:fromInt(startingClusters[tostring(i)])) --[[ ROBLOX CHECK: check if 'clusters' is an Array ]]
			i += 1
		end
	end
	local additionalClustersNeeded = clusterCount - clusters.length
	if
		startingClusters.length == 0
		and additionalClustersNeeded > 0 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
	then
		do
			local i = 0
			while
				i
				< additionalClustersNeeded --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
			do
				local l = math.random() * 100.0
				local a = math.random() * (100.0 - -100.0 + 1) + -100
				local b = math.random() * (100.0 - -100.0 + 1) + -100
				table.insert(clusters, Array.new(l, a, b)) --[[ ROBLOX CHECK: check if 'clusters' is an Array ]]
				i += 1
			end
		end
	end
	local clusterIndices = Array.new()
	do
		local i = 0
		while
			i
			< pointCount --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		do
			table.insert(clusterIndices, math.floor(math.random() * clusterCount)) --[[ ROBLOX CHECK: check if 'clusterIndices' is an Array ]]
			i += 1
		end
	end
	local indexMatrix = Array.new()
	do
		local i = 0
		while
			i
			< clusterCount --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		do
			table.insert(indexMatrix, Array.new()) --[[ ROBLOX CHECK: check if 'indexMatrix' is an Array ]]
			do
				local j = 0
				while
					j
					< clusterCount --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
				do
					table.insert(indexMatrix[tostring(i)], 0) --[[ ROBLOX CHECK: check if 'indexMatrix[i]' is an Array ]]
					j += 1
				end
			end
			i += 1
		end
	end
	local distanceToIndexMatrix = Array.new()
	do
		local i = 0
		while
			i
			< clusterCount --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		do
			table.insert(distanceToIndexMatrix, Array.new()) --[[ ROBLOX CHECK: check if 'distanceToIndexMatrix' is an Array ]]
			do
				local j = 0
				while
					j
					< clusterCount --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
				do
					table.insert(distanceToIndexMatrix[tostring(i)], DistanceAndIndex.new()) --[[ ROBLOX CHECK: check if 'distanceToIndexMatrix[i]' is an Array ]]
					j += 1
				end
			end
			i += 1
		end
	end
	local pixelCountSums = Array.new()
	do
		local i = 0
		while
			i
			< clusterCount --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		do
			table.insert(pixelCountSums, 0) --[[ ROBLOX CHECK: check if 'pixelCountSums' is an Array ]]
			i += 1
		end
	end
	do
		local iteration = 0
		while
			iteration
			< MAX_ITERATIONS --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		do
			do
				local i = 0
				while
					i
					< clusterCount --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
				do
					do
						local j = i + 1
						while
							j
							< clusterCount --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
						do
							local distance =
								pointProvider:distance(clusters[tostring(i)], clusters[tostring(j)])
							distanceToIndexMatrix[tostring(j)][tostring(i)].distance = distance
							distanceToIndexMatrix[tostring(j)][tostring(i)].index = i
							distanceToIndexMatrix[tostring(i)][tostring(j)].distance = distance
							distanceToIndexMatrix[tostring(i)][tostring(j)].index = j
							j += 1
						end
					end
					Array.sort(distanceToIndexMatrix[tostring(i)]) --[[ ROBLOX CHECK: check if 'distanceToIndexMatrix[i]' is an Array ]]
					do
						local j = 0
						while
							j
							< clusterCount --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
						do
							indexMatrix[tostring(i)][tostring(j)] =
								distanceToIndexMatrix[tostring(i)][tostring(j)].index
							j += 1
						end
					end
					i += 1
				end
			end
			local pointsMoved = 0
			do
				local i = 0
				while
					i
					< pointCount --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
				do
					local point = points[tostring(i)]
					local previousClusterIndex = clusterIndices[tostring(i)]
					local previousCluster = clusters[tostring(previousClusterIndex)]
					local previousDistance = pointProvider:distance(point, previousCluster)
					local minimumDistance = previousDistance
					local newClusterIndex = -1
					do
						local j = 0
						while
							j
							< clusterCount --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
						do
							if
								distanceToIndexMatrix[tostring(previousClusterIndex)][tostring(j)].distance
								>= 4 * previousDistance --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
							then
								j += 1
								continue
							end
							local distance = pointProvider:distance(point, clusters[tostring(j)])
							if
								distance
								< minimumDistance --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
							then
								minimumDistance = distance
								newClusterIndex = j
							end
							j += 1
						end
					end
					if newClusterIndex ~= -1 then
						local distanceChange =
							math.abs(math.sqrt(minimumDistance) - math.sqrt(previousDistance))
						if
							distanceChange
							> MIN_MOVEMENT_DISTANCE --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
						then
							pointsMoved += 1
							clusterIndices[tostring(i)] = newClusterIndex
						end
					end
					i += 1
				end
			end
			if pointsMoved == 0 and iteration ~= 0 then
				break
			end
			local componentASums = Array.new(clusterCount):fill(0)
			local componentBSums = Array.new(clusterCount):fill(0)
			local componentCSums = Array.new(clusterCount):fill(0)
			do
				local i = 0
				while
					i
					< clusterCount --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
				do
					pixelCountSums[tostring(i)] = 0
					i += 1
				end
			end
			do
				local i = 0
				while
					i
					< pointCount --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
				do
					local clusterIndex = clusterIndices[tostring(i)]
					local point = points[tostring(i)]
					local count = counts[tostring(i)]
					pixelCountSums[tostring(clusterIndex)] += count
					componentASums[tostring(clusterIndex)] += point[
						1 --[[ ROBLOX adaptation: added 1 to array index ]]
					] * count
					componentBSums[tostring(clusterIndex)] += point[
						2 --[[ ROBLOX adaptation: added 1 to array index ]]
					] * count
					componentCSums[tostring(clusterIndex)] += point[
						3 --[[ ROBLOX adaptation: added 1 to array index ]]
					] * count
					i += 1
				end
			end
			do
				local i = 0
				while
					i
					< clusterCount --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
				do
					local count = pixelCountSums[tostring(i)]
					if count == 0 then
						clusters[tostring(i)] = { 0.0, 0.0, 0.0 }
						i += 1
						continue
					end
					local a = componentASums[tostring(i)] / count
					local b = componentBSums[tostring(i)] / count
					local c = componentCSums[tostring(i)] / count
					clusters[tostring(i)] = { a, b, c }
					i += 1
				end
			end
			iteration += 1
		end
	end
	local argbToPopulation = Map.new()
	do
		local i = 0
		while
			i
			< clusterCount --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
		do
			local count = pixelCountSums[tostring(i)]
			if count == 0 then
				i += 1
				continue
			end
			local possibleNewCluster = pointProvider:toInt(clusters[tostring(i)])
			if Boolean.toJSBoolean(argbToPopulation:has(possibleNewCluster)) then
				i += 1
				continue
			end
			argbToPopulation:set(possibleNewCluster, count)
			i += 1
		end
	end
	return argbToPopulation
end
exports.QuantizerWsmeans = QuantizerWsmeans
--[[*
 *  A wrapper for maintaining a table of distances between K-Means clusters.
 ]]
type DistanceAndIndex = { distance: number, index: number }
type DistanceAndIndex_statics = { new: () -> DistanceAndIndex }
local DistanceAndIndex = {} :: DistanceAndIndex & DistanceAndIndex_statics;
(DistanceAndIndex :: any).__index = DistanceAndIndex
function DistanceAndIndex.new(): DistanceAndIndex
	local self = setmetatable({}, DistanceAndIndex)
	self.distance = -1
	self.index = -1
	return (self :: any) :: DistanceAndIndex
end
return exports
