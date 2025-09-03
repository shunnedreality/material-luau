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
local Boolean = LuauPolyfill.Boolean
local Map = LuauPolyfill.Map
type Array<T> = LuauPolyfill.Array<T>
require(Packages.jasmine)
local Contrast = require(script.Parent.Parent.contrast["contrast"]).Contrast
local ContrastCurve = require(script.Parent.Parent.dynamiccolor["contrast_curve"]).ContrastCurve
local MaterialDynamicColors =
	require(script.Parent.Parent.dynamiccolor["material_dynamic_colors"]).MaterialDynamicColors
local Hct = require(script.Parent.Parent.hct["hct"]).Hct
local SchemeContent = require(script.Parent.Parent.scheme["scheme_content"]).SchemeContent
local SchemeExpressive =
	require(script.Parent.Parent.scheme["scheme_expressive"]).SchemeExpressive
local SchemeFidelity = require(script.Parent.Parent.scheme["scheme_fidelity"]).SchemeFidelity
local SchemeMonochrome =
	require(script.Parent.Parent.scheme["scheme_monochrome"]).SchemeMonochrome
local SchemeNeutral = require(script.Parent.Parent.scheme["scheme_neutral"]).SchemeNeutral
local SchemeTonalSpot = require(script.Parent.Parent.scheme["scheme_tonal_spot"]).SchemeTonalSpot
local SchemeVibrant = require(script.Parent.Parent.scheme["scheme_vibrant"]).SchemeVibrant
local colorUtils = require(script.Parent.Parent.utils["color_utils"])
local DynamicScheme = require(script.Parent["dynamic_scheme"]).DynamicScheme
local seedColors = {
	Hct.fromInt(0xFFFF0000),
	Hct.fromInt(0xFFFFFF00),
	Hct.fromInt(0xFF00FF00),
	Hct.fromInt(0xFF0000FF),
}
type Pair = { fgName: string, bgName: string }
type Pair_statics = { new: (fgName: string, bgName: string) -> Pair }
local Pair = {} :: Pair & Pair_statics;
(Pair :: any).__index = Pair
function Pair.new(fgName: string, bgName: string): Pair
	local self = setmetatable({}, Pair)
	self.fgName = fgName
	self.bgName = bgName
	return (self :: any) :: Pair
end
local colors = {
	MaterialDynamicColors.background,
	MaterialDynamicColors.onBackground,
	MaterialDynamicColors.surface,
	MaterialDynamicColors.surfaceDim,
	MaterialDynamicColors.surfaceBright,
	MaterialDynamicColors.surfaceContainerLowest,
	MaterialDynamicColors.surfaceContainerLow,
	MaterialDynamicColors.surfaceContainer,
	MaterialDynamicColors.surfaceContainerHigh,
	MaterialDynamicColors.surfaceContainerHighest,
	MaterialDynamicColors.onSurface,
	MaterialDynamicColors.surfaceVariant,
	MaterialDynamicColors.onSurfaceVariant,
	MaterialDynamicColors.inverseSurface,
	MaterialDynamicColors.inverseOnSurface,
	MaterialDynamicColors.outline,
	MaterialDynamicColors.outlineVariant,
	MaterialDynamicColors.shadow,
	MaterialDynamicColors.scrim,
	MaterialDynamicColors.surfaceTint,
	MaterialDynamicColors.primary,
	MaterialDynamicColors.onPrimary,
	MaterialDynamicColors.primaryContainer,
	MaterialDynamicColors.onPrimaryContainer,
	MaterialDynamicColors.inversePrimary,
	MaterialDynamicColors.secondary,
	MaterialDynamicColors.onSecondary,
	MaterialDynamicColors.secondaryContainer,
	MaterialDynamicColors.onSecondaryContainer,
	MaterialDynamicColors.tertiary,
	MaterialDynamicColors.onTertiary,
	MaterialDynamicColors.tertiaryContainer,
	MaterialDynamicColors.onTertiaryContainer,
	MaterialDynamicColors.error,
	MaterialDynamicColors.onError,
	MaterialDynamicColors.errorContainer,
	MaterialDynamicColors.onErrorContainer,
	MaterialDynamicColors.primaryFixed,
	MaterialDynamicColors.primaryFixedDim,
	MaterialDynamicColors.onPrimaryFixed,
	MaterialDynamicColors.onPrimaryFixedVariant,
	MaterialDynamicColors.secondaryFixed,
	MaterialDynamicColors.secondaryFixedDim,
	MaterialDynamicColors.onSecondaryFixed,
	MaterialDynamicColors.onSecondaryFixedVariant,
	MaterialDynamicColors.tertiaryFixed,
	MaterialDynamicColors.tertiaryFixedDim,
	MaterialDynamicColors.onTertiaryFixed,
	MaterialDynamicColors.onTertiaryFixedVariant,
}
local colorByName = Map.new(Array.map(colors, function(color)
	return { color.name, color }
end) --[[ ROBLOX CHECK: check if 'colors' is an Array ]])
local textSurfacePairs = {
	Pair.new("on_primary", "primary"),
	Pair.new("on_primary_container", "primary_container"),
	Pair.new("on_secondary", "secondary"),
	Pair.new("on_secondary_container", "secondary_container"),
	Pair.new("on_tertiary", "tertiary"),
	Pair.new("on_tertiary_container", "tertiary_container"),
	Pair.new("on_error", "error"),
	Pair.new("on_error_container", "error_container"),
	Pair.new("on_background", "background"),
	Pair.new("on_surface_variant", "surface_bright"),
	Pair.new("on_surface_variant", "surface_dim"),
}
local function getMinRequirement(curve: ContrastCurve, level: number): number
	if
		level
		>= 1 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
	then
		return curve.high
	end
	if
		level
		>= 0.5 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
	then
		return curve.medium
	end
	if
		level
		>= 0 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
	then
		return curve.normal
	end
	return curve.low
end
local function getPairs(
	resp: boolean,
	fores: Array<string>,
	backs: Array<string>
): Array<Array<string>>
	local ans = {}
	if Boolean.toJSBoolean(resp) then
		do
			local i = 0
			while
				i
				< fores.length --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
			do
				table.insert(ans, { fores[tostring(i)], backs[tostring(i)] }) --[[ ROBLOX CHECK: check if 'ans' is an Array ]]
				i += 1
			end
		end
	else
		for _, f in fores do
			for _, b in backs do
				table.insert(ans, { f, b }) --[[ ROBLOX CHECK: check if 'ans' is an Array ]]
			end
		end
	end
	return ans
end
local schemes: Array<DynamicScheme> = {}
for _, color in seedColors do
	for _, contrastLevel in { -1.0, -0.75, -0.5, -0.25, 0.0, 0.25, 0.5, 0.75, 1.0 } do
		for _, isDark in { false, true } do
			for _, scheme in
				{
					SchemeContent.new(color, isDark, contrastLevel),
					SchemeExpressive.new(color, isDark, contrastLevel),
					SchemeFidelity.new(color, isDark, contrastLevel),
					SchemeMonochrome.new(color, isDark, contrastLevel),
					SchemeNeutral.new(color, isDark, contrastLevel),
					SchemeTonalSpot.new(color, isDark, contrastLevel),
					SchemeVibrant.new(color, isDark, contrastLevel),
				}
			do
				table.insert(schemes, scheme) --[[ ROBLOX CHECK: check if 'schemes' is an Array ]]
			end
		end
	end
end
describe("DynamicColor", function()
	-- Parametric test, ensuring that dynamic schemes respect contrast
	-- between text-surface pairs.
	it("generates colors respecting contrast", function()
		for _, scheme in schemes do
			for _, pair in textSurfacePairs do
				-- Expect that each text-surface pair has a
				-- minimum contrast of 4.5 (unreduced contrast), or 3.0
				-- (reduced contrast).
				local fgName = pair.fgName
				local bgName = pair.bgName
				local foregroundTone = (colorByName:get(fgName) :: any):getHct(scheme).tone
				local backgroundTone = (colorByName:get(bgName) :: any):getHct(scheme).tone
				local contrast = Contrast:ratioOfTones(foregroundTone, backgroundTone)
				local minimumRequirement = if scheme.contrastLevel
						>= 0.0 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
					then 4.5
					else 3.0
				if
					contrast
					< minimumRequirement --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
				then
					fail(
						("%s on %s is %s, needed %s"):format(
							tostring(fgName),
							tostring(bgName),
							tostring(contrast),
							tostring(minimumRequirement)
						)
					)
				end
			end
		end
	end)
	it("constraint conformance test", function()
		--[[
      Tone delta pair:
      [A, B, delta, "lighter"] = A is lighter than B by delta
      [A, B, delta, "darker"] = A is darker than B by delta
      [A, B, delta, "farther"] = A is farther (from + surfaces) than B by delta
                              = [A, B, delta, "darker"] in light
                              = [A, B, delta, "lighter"] in dark
      [A, B, delta, "nearer"] = A is nearer (to + surfaces) than B by delta
                              = [A, B, delta, "lighter"] in light
                              = [A, B, delta, "darker"] in dark
    ]]
		local limitingSurfaces = { "surface_dim", "surface_bright" }
		local constraints = {
			-- Contrast constraints, as defined in the spec.
			--
			-- If "respectively" is set to true, the constraint is tested against
			-- every pair of __corresponding__ foreground and background;
			-- otherwise, the constraint is tested against every possible pair
			-- of foreground and background.
			--
			-- In other words, if "respectively" is true, "fore" and "back" must
			-- have equal length N, and there will be N comparisons.
			-- If "respectively" is false, "fore" has length M, and "back" has length
			-- N, then there will be (M * N) comparisons.
			--
			-- Surface contrast constraints.
			{
				kind = "Contrast",
				values = ContrastCurve.new(4.5, 7, 11, 21),
				fore = { "on_surface" },
				back = limitingSurfaces,
			},
			{
				kind = "Contrast",
				values = ContrastCurve.new(3, 4.5, 7, 11),
				fore = { "on_surface_variant" },
				back = limitingSurfaces,
			},
			{
				kind = "Contrast",
				values = ContrastCurve.new(3, 4.5, 7, 7),
				fore = { "primary", "secondary", "tertiary", "error" },
				back = limitingSurfaces,
			},
			{
				kind = "Contrast",
				values = ContrastCurve.new(1.5, 3, 4.5, 7),
				fore = { "outline" },
				back = limitingSurfaces,
			},
			{
				kind = "Contrast",
				values = ContrastCurve.new(0, 0, 3, 4.5),
				fore = {
					"primary_container",
					"primary_fixed",
					"primary_fixed_dim",
					"secondary_container",
					"secondary_fixed",
					"secondary_fixed_dim",
					"tertiary_container",
					"tertiary_fixed",
					"tertiary_fixed_dim",
					"error_container",
					"outline_variant",
				},
				back = limitingSurfaces,
			},
			{
				kind = "Contrast",
				values = ContrastCurve.new(4.5, 7, 11, 21),
				fore = { "inverse_on_surface" },
				back = { "inverse_surface" },
			},
			{
				kind = "Contrast",
				values = ContrastCurve.new(3, 4.5, 7, 7),
				fore = { "inverse_primary" },
				back = { "inverse_surface" },
			},
			-- Accent contrast constraints.
			{
				kind = "Contrast",
				respectively = true,
				values = ContrastCurve.new(4.5, 7, 11, 21),
				fore = { "on_primary", "on_secondary", "on_tertiary", "on_error" },
				back = { "primary", "secondary", "tertiary", "error" },
			},
			{
				kind = "Contrast",
				respectively = true,
				values = ContrastCurve.new(3, 4.5, 7, 11),
				fore = {
					"on_primary_container",
					"on_secondary_container",
					"on_tertiary_container",
					"on_error_container",
				},
				back = {
					"primary_container",
					"secondary_container",
					"tertiary_container",
					"error_container",
				},
			},
			{
				kind = "Contrast",
				values = ContrastCurve.new(4.5, 7, 11, 21),
				fore = { "on_primary_fixed" },
				back = { "primary_fixed", "primary_fixed_dim" },
			},
			{
				kind = "Contrast",
				values = ContrastCurve.new(4.5, 7, 11, 21),
				fore = { "on_secondary_fixed" },
				back = { "secondary_fixed", "secondary_fixed_dim" },
			},
			{
				kind = "Contrast",
				values = ContrastCurve.new(4.5, 7, 11, 21),
				fore = { "on_tertiary_fixed" },
				back = { "tertiary_fixed", "tertiary_fixed_dim" },
			},
			{
				kind = "Contrast",
				values = ContrastCurve.new(3, 4.5, 7, 11),
				fore = { "on_primary_fixed_variant" },
				back = { "primary_fixed", "primary_fixed_dim" },
			},
			{
				kind = "Contrast",
				values = ContrastCurve.new(3, 4.5, 7, 11),
				fore = { "on_secondary_fixed_variant" },
				back = { "secondary_fixed", "secondary_fixed_dim" },
			},
			{
				kind = "Contrast",
				values = ContrastCurve.new(3, 4.5, 7, 11),
				fore = { "on_tertiary_fixed_variant" },
				back = { "tertiary_fixed", "tertiary_fixed_dim" },
			},
			-- Delta constraints.
			{
				kind = "Delta",
				delta = 10,
				respectively = true,
				fore = { "primary", "secondary", "tertiary", "error" },
				back = {
					"primary_container",
					"secondary_container",
					"tertiary_container",
					"error_container",
				},
				polarity = "farther",
			},
			{
				kind = "Delta",
				delta = 10,
				respectively = true,
				fore = { "primary_fixed_dim", "secondary_fixed_dim", "tertiary_fixed_dim" },
				back = { "primary_fixed", "secondary_fixed", "tertiary_fixed" },
				polarity = "darker",
			},
			-- Background constraints.
			{
				kind = "Background",
				objects = {
					"background",
					"error",
					"error_container",
					"primary",
					"primary_container",
					"primary_fixed",
					"primary_fixed_dim",
					"secondary",
					"secondary_container",
					"secondary_fixed",
					"secondary_fixed_dim",
					"surface",
					"surface_bright",
					"surface_container",
					"surface_container_high",
					"surface_container_highest",
					"surface_container_low",
					"surface_container_lowest",
					"surface_dim",
					"surface_tint",
					"surface_variant",
					"tertiary",
					"tertiary_container",
					"tertiary_fixed",
					"tertiary_fixed_dim",
				},
			},
		}
		for _, scheme in schemes do
			local prec = 2
			local resolvedColors = Map.new(Array.map(colors, function(color)
				return { color.name, color:getArgb(scheme) }
			end) --[[ ROBLOX CHECK: check if 'colors' is an Array ]])
			for _, cstr in constraints do
				if cstr.kind == "Contrast" then
					local contrastTolerance = 0.05
					local minRequirement =
						getMinRequirement(cstr.values :: any, scheme.contrastLevel)
					local respectively = if cstr.respectively ~= nil
						then cstr.respectively
						else false
					local pairs_ = getPairs(respectively, cstr.fore :: any, cstr.back :: any)
					-- Check each pair
					for _, pair in pairs_ do
						local fore, back = table.unpack(pair, 1, 2)
						local ftone = colorutils.lstarFromArgb(resolvedColors:get(fore) :: any)
						local btone = colorutils.lstarFromArgb(resolvedColors:get(back) :: any)
						local contrast = Contrast:ratioOfTones(ftone, btone)
						-- It's failing only if:
						--     A minimum requirement of 4.5 or lower is not reached
						--     A minimum requirement of >4.5 is not reached, while
						--     some colors are not B or White yet.
						local failing = if minRequirement
								<= 4.5 --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]]
							then contrast
								< minRequirement - contrastTolerance --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
							else ftone ~= 0
								and btone ~= 0
								and ftone ~= 100
								and btone ~= 100
								and contrast < minRequirement - contrastTolerance --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
						if
							contrast < minRequirement - contrastTolerance --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
							and minRequirement <= 4.5 --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]]
						then
							-- Real fail.
							fail(
								("Contrast %s %s %s %s %s %s "):format(
									tostring(fore),
									tostring(ftone:toFixed(prec)),
									tostring(back),
									tostring(btone:toFixed(prec)),
									tostring(contrast:toFixed(prec)),
									tostring(minRequirement)
								)
							)
						end
						if
							Boolean.toJSBoolean(if Boolean.toJSBoolean(failing)
								then minRequirement
									> 4.5 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]]
								else failing)
						then
							fail(
								("Contrast(stretch-goal) %s %s %s %s %s %s "):format(
									tostring(fore),
									tostring(ftone:toFixed(prec)),
									tostring(back),
									tostring(btone:toFixed(prec)),
									tostring(contrast:toFixed(prec)),
									tostring(minRequirement)
								)
							)
						end
					end
				elseif cstr.kind == "Delta" then
					-- Verifies that the two colors satisfy the required
					-- tone delta constraint.
					local respectively = if cstr.respectively ~= nil
						then cstr.respectively
						else false
					local pairs_ = getPairs(respectively, cstr.fore :: any, cstr.back :: any)
					local polarity = cstr.polarity
					expect(
						polarity == "nearer"
							or polarity == "farther"
							or polarity == "lighter"
							or polarity == "darker"
					).toBeTrue()
					for _, pair in pairs_ do
						local fore, back = table.unpack(pair, 1, 2)
						local ftone = colorutils.lstarFromArgb(resolvedColors:get(fore) :: any)
						local btone = colorutils.lstarFromArgb(resolvedColors:get(back) :: any)
						local isLighter = polarity == "lighter"
							or polarity == "nearer" and not Boolean.toJSBoolean(scheme.isDark)
							or polarity == "farther" and scheme.isDark
						local observedDelta = if Boolean.toJSBoolean(isLighter)
							then ftone - btone
							else btone - ftone
						if
							observedDelta
							< cstr.delta :: any - 0.5 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]] --[[ lenient ]]
						then
							-- Failing
							fail(
								("Delta %s %s %s %s %s %s"):format(
									tostring(fore),
									tostring(ftone:toFixed(prec)),
									tostring(back),
									tostring(btone:toFixed(prec)),
									tostring(observedDelta:toFixed(prec)),
									tostring(cstr.delta)
								)
							)
						end
					end
				elseif cstr.kind == "Background" then
					-- Verifies that none of the background tones are in the
					-- "awkward zone" from 50 to 60.
					for _, bg in cstr.objects :: any do
						local bgtone = colorutils.lstarFromArgb(resolvedColors:get(bg) :: any)
						if
							bgtone >= 50.5 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
							and bgtone < 59.5 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]] --[[ lenient ]] --[[ lenient ]]
						then
							-- Failing
							fail(
								("Background %s %s"):format(
									tostring(bg),
									tostring(bgtone:toFixed(prec))
								)
							)
						end
					end
				else
					fail(("Bad constraint kind = %s"):format(tostring(cstr.kind)))
				end
			end
		end
	end)
end)
