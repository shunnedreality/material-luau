-- ROBLOX NOTE: no upstream
--[[*
 * @license
 * Copyright 2022 Google LLC
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
local Packages = script.Parent.Parent.Parent; --[[ ROBLOX comment: must define Packages module ]]
local LuauPolyfill = require(Packages.LuauPolyfill);
local Array = LuauPolyfill.Array;
local Boolean = LuauPolyfill.Boolean;
local Error = LuauPolyfill.Error;
local Map = LuauPolyfill.Map;
local Math = LuauPolyfill.Math;
local exports = {};
local Contrast = require(script.Parent.Parent.contrast["contrast"]).Contrast;
local Hct = require(script.Parent.Parent.hct["hct"]).Hct;
local tonal_paletteModule = require(script.Parent.Parent.palettes.tonal_palette);
type TonalPalette = tonal_paletteModule.TonalPalette
local math_ = require(script.Parent.Parent.utils["math_utils"]);
--[[local ContrastCurve = require(script.Parent["contrast_curve"]).ContrastCurve;
local DynamicScheme = require(script.Parent["dynamic_scheme"]).DynamicScheme;
local ToneDeltaPair = require(script.Parent["tone_delta_pair"]).ToneDeltaPair;]]

type DynamicColor_statics = { new: (name:string, palette:(scheme:DynamicScheme) -> TonalPalette, tone:(scheme:DynamicScheme) -> number, isBackground:boolean, chromaMultiplier:((scheme:DynamicScheme) -> number)?, background:((scheme:DynamicScheme) -> DynamicColor
| nil)?, secondBackground:((scheme:DynamicScheme) -> DynamicColor
| nil)?, contrastCurve:((scheme:DynamicScheme) -> ContrastCurve
| nil)?, toneDeltaPair:((scheme:DynamicScheme) -> ToneDeltaPair
| nil)?) -> DynamicColor, }
local DynamicColor = {} :: DynamicColor & DynamicColor_statics;
local DynamicColor_private = DynamicColor :: DynamicColor_private & DynamicColor_statics;
(DynamicColor :: any).__index = DynamicColor;

--[[*
 * @param name The name of the dynamic color. Defaults to empty.
 * @param palette Function that provides a TonalPalette given DynamicScheme. A
 *     TonalPalette is defined by a hue and chroma, so this replaces the need to
 *     specify hue/chroma. By providing a tonal palette, when contrast
 *     adjustments are made, intended chroma can be preserved.
 * @param tone Function that provides a tone given DynamicScheme. When not
 *     provided, the tone is same as the background tone or 50, when no
 *     background is provided.
 * @param chromaMultiplier A factor that multiplies the chroma for this color.
 *     Default to 1.
 * @param isBackground Whether this dynamic color is a background, with some
 *     other color as the foreground. Defaults to false.
 * @param background The background of the dynamic color (as a function of a
 *     `DynamicScheme`), if it exists.
 * @param secondBackground A second background of the dynamic color (as a
 *     function of a `DynamicScheme`), if it exists.
 * @param contrastCurve A `ContrastCurve` object specifying how its contrast
 *     against its background should behave in various contrast levels options.
 *     Must used together with `background`. When not provided or resolved as
 *     undefined, the contrast curve is calculated based on other constraints.
 * @param toneDeltaPair A `ToneDeltaPair` object specifying a tone delta
 *     constraint between two colors. One of them must be the color being
 *     constructed. When not provided or resolved as undefined, the tone is
 *     calculated based on other constraints.
 ]]
type FromPaletteOptions = { name: string?,
palette: (scheme:DynamicScheme) -> TonalPalette,
tone: ((scheme:DynamicScheme) -> number)?,
chromaMultiplier: ((scheme:DynamicScheme) -> number)?,
isBackground: boolean?,
background: ((scheme:DynamicScheme) -> DynamicColor
| nil)?,
secondBackground: ((scheme:DynamicScheme) -> DynamicColor
| nil)?,
contrastCurve: ((scheme:DynamicScheme) -> ContrastCurve
| nil)?,
toneDeltaPair: ((scheme:DynamicScheme) -> ToneDeltaPair
| nil)?, }
--[[*
 * A delegate that provides the HCT and tone of a DynamicColor.
 *
 * This is used to allow different implementations of the color calculation
 * logic for different spec versions.
 ]]
type ColorCalculationDelegate = { getHct: (self:ColorCalculationDelegate, scheme:DynamicScheme, color:DynamicColor) -> Hct,
getTone: (self:ColorCalculationDelegate, scheme:DynamicScheme, color:DynamicColor) -> number, }
local function validateExtendedColor(originalColor: DynamicColor,specVersion: SpecVersion,extendedColor: DynamicColor)
   print(originalColor);
   print(extendedColor);
if originalColor.name ~= extendedColor.name then
error(Error.new(("Attempting to extend color %s with color %s of different name for spec version %s."):format(tostring(originalColor.name), tostring(extendedColor.name), tostring(specVersion))));
end
if originalColor.isBackground ~= extendedColor.isBackground then
error(Error.new(("Attempting to extend color %s as a %s with color %s as a %s for spec version %s."):format(tostring(originalColor.name), if Boolean.toJSBoolean(originalColor.isBackground)
then "background"
else "foreground", tostring(extendedColor.name), if Boolean.toJSBoolean(extendedColor.isBackground)
then "background"
else "foreground", tostring(specVersion))));
end
end
--[[*
 * Returns a new DynamicColor that is the same as the original color, but with
 * the extended dynamic color's constraints for the given spec version.
 *
 * @param originlColor The original color.
 * @param specVersion The spec version to extend.
 * @param extendedColor The color with the values to extend.
 ]]
local function extendSpecVersion(originlColor: DynamicColor,specVersion: SpecVersion,extendedColor: DynamicColor): DynamicColor
--validateExtendedColor(originlColor, specVersion, extendedColor);
return DynamicColor:fromPalette({
name = originlColor.name,
palette = function(s)
return if s.specVersion == specVersion
then extendedColor:palette(s)
else originlColor:palette(s);
end,
tone = function(s)
return if s.specVersion == specVersion
then extendedColor:tone(s)
else originlColor:tone(s);
end,
isBackground = originlColor.isBackground,
chromaMultiplier = function(s)
local chromaMultiplier = if s.specVersion == specVersion
then extendedColor.chromaMultiplier
else originlColor.chromaMultiplier;
return if chromaMultiplier ~= nil
then chromaMultiplier(s)
else 1;
end,
background = function(s)
local background = if s.specVersion == specVersion
then extendedColor.background
else originlColor.background;
return if background ~= nil
then background(s)
else nil;
end,
secondBackground = function(s)
local secondBackground = if s.specVersion == specVersion
then extendedColor.secondBackground
else originlColor.secondBackground;
return if secondBackground ~= nil
then secondBackground(s)
else nil;
end,
contrastCurve = function(s)
local contrastCurve = if s.specVersion == specVersion
then extendedColor.contrastCurve
else originlColor.contrastCurve;
return if contrastCurve ~= nil
then contrastCurve(s)
else nil;
end,
toneDeltaPair = function(s)
local toneDeltaPair = if s.specVersion == specVersion
then extendedColor.toneDeltaPair
else originlColor.toneDeltaPair;
return if toneDeltaPair ~= nil
then toneDeltaPair(s)
else nil;
end}
);
end
exports.extendSpecVersion = extendSpecVersion;
--[[*
 * A color that adjusts itself based on UI state provided by DynamicScheme.
 *
 * Colors without backgrounds do not change tone when contrast changes. Colors
 * with backgrounds become closer to their background as contrast lowers, and
 * further when contrast increases.
 *
 * Prefer static constructors. They require either a hexcode, a palette and
 * tone, or a hue and chroma. Optionally, they can provide a background
 * DynamicColor.
 ]]
export type DynamicColor = { --[[*
   * Returns a deep copy of this DynamicColor.
   ]]
clone: (self:DynamicColor) -> DynamicColor,
--[[*
   * Clears the cache of HCT values for this color. For testing or debugging
   * purposes.
   ]]
clearCache: (self:DynamicColor) -> any,
--[[*
   * Returns a ARGB integer (i.e. a hex code).
   *
   * @param scheme Defines the conditions of the user interface, for example,
   *     whether or not it is dark mode or light mode, and what the desired
   *     contrast level is.
   ]]
getArgb: (self:DynamicColor, scheme:DynamicScheme) -> number,
--[[*
   * Returns a color, expressed in the HCT color space, that this
   * DynamicColor is under the conditions in scheme.
   *
   * @param scheme Defines the conditions of the user interface, for example,
   *     whether or not it is dark mode or light mode, and what the desired
   *     contrast level is.
   ]]
getHct: (self:DynamicColor, scheme:DynamicScheme) -> Hct,
--[[*
   * Returns a tone, T in the HCT color space, that this DynamicColor is under
   * the conditions in scheme.
   *
   * @param scheme Defines the conditions of the user interface, for example,
   *     whether or not it is dark mode or light mode, and what the desired
   *     contrast level is.
   ]]
getTone: (self:DynamicColor, scheme:DynamicScheme) -> number,
--[[*
   * Given a background tone, finds a foreground tone, while ensuring they reach
   * a contrast ratio that is as close to [ratio] as possible.
   *
   * @param bgTone Tone in HCT. Range is 0 to 100, undefined behavior when it
   *     falls outside that range.
   * @param ratio The contrast ratio desired between bgTone and the return
   *     value.
   ]] };
type DynamicColor_private = { --
-- *** PUBLIC *** 
--
clone: (self:DynamicColor_private) -> DynamicColor,
clearCache: (self:DynamicColor_private) -> any,
getArgb: (self:DynamicColor_private, scheme:DynamicScheme) -> number,
getHct: (self:DynamicColor_private, scheme:DynamicScheme) -> Hct,
getTone: (self:DynamicColor_private, scheme:DynamicScheme) -> number,
--
-- *** PRIVATE *** 
--
hctCache: any,
--[[*
   * Create a DynamicColor defined by a TonalPalette and HCT tone.
   *
   * @param args Functions with DynamicScheme as input. Must provide a palette
   *     and tone. May provide a background DynamicColor and ToneDeltaPair.
   ]] }
--[[*
   * The base constructor for DynamicColor.
   *
   * _Strongly_ prefer using one of the convenience constructors. This class is
   * arguably too flexible to ensure it can support any scenario. Functional
   * arguments allow  overriding without risks that come with subclasses.
   *
   * For example, the default behavior of adjust tone at max contrast
   * to be at a 7.0 ratio with its background is principled and
   * matches accessibility guidance. That does not mean it's the desired
   * approach for _every_ design system, and every color pairing,
   * always, in every case.
   *
   * @param name The name of the dynamic color. Defaults to empty.
   * @param palette Function that provides a TonalPalette given DynamicScheme. A
   *     TonalPalette is defined by a hue and chroma, so this replaces the need
   *     to specify hue/chroma. By providing a tonal palette, when contrast
   *     adjustments are made, intended chroma can be preserved.
   * @param tone Function that provides a tone, given a DynamicScheme.
   * @param isBackground Whether this dynamic color is a background, with some
   *     other color as the foreground. Defaults to false.
   * @param chromaMultiplier A factor that multiplies the chroma for this color.
   * @param background The background of the dynamic color (as a function of a
   *     `DynamicScheme`), if it exists.
   * @param secondBackground A second background of the dynamic color (as a
   *     function of a `DynamicScheme`), if it exists.
   * @param contrastCurve A `ContrastCurve` object specifying how its contrast
   *     against its background should behave in various contrast levels
   *     options.
   * @param toneDeltaPair A `ToneDeltaPair` object specifying a tone delta
   *     constraint between two colors. One of them must be the color being
   *     constructed.
   ]]
function DynamicColor_private.new(name: string,palette: (scheme:DynamicScheme) -> TonalPalette,tone: (scheme:DynamicScheme) -> number,isBackground: boolean,chromaMultiplier: ((scheme:DynamicScheme) -> number)?,background: ((scheme:DynamicScheme) -> DynamicColor
| nil)?,secondBackground: ((scheme:DynamicScheme) -> DynamicColor
| nil)?,contrastCurve: ((scheme:DynamicScheme) -> ContrastCurve
| nil)?,toneDeltaPair: ((scheme:DynamicScheme) -> ToneDeltaPair
| nil)?): DynamicColor
local self = setmetatable({}, DynamicColor);
self.name = name;
self.palette = palette;
self.tone = tone;
self.isBackground = isBackground;
self.chromaMultiplier = chromaMultiplier;
self.background = background;
self.secondBackground = secondBackground;
self.contrastCurve = contrastCurve;
self.toneDeltaPair = toneDeltaPair;
self.hctCache = Map.new();
if Boolean.toJSBoolean(not Boolean.toJSBoolean(background) and secondBackground) then
error(Error.new(("Color %s has secondBackground"):format(tostring(name)) .. "defined, but background is not defined."));
end
if Boolean.toJSBoolean(not Boolean.toJSBoolean(background) and contrastCurve) then
error(Error.new(("Color %s has contrastCurve"):format(tostring(name)) .. "defined, but background is not defined."));
end
if Boolean.toJSBoolean(if Boolean.toJSBoolean(background)
then not Boolean.toJSBoolean(contrastCurve)
else background) then
error(Error.new(("Color %s has background"):format(tostring(name)) .. "defined, but contrastCurve is not defined."));
end
return (self :: any) :: DynamicColor;
end
function DynamicColor_private.fromPalette(args: FromPaletteOptions): DynamicColor
return DynamicColor.new(if args.name ~= nil
then args.name
else "", args.palette, if args.tone ~= nil
then args.tone
else DynamicColor:getInitialToneFromBackground(args.background), if args.isBackground ~= nil
then args.isBackground
else false, args.chromaMultiplier, args.background, args.secondBackground, args.contrastCurve, args.toneDeltaPair);
end
function DynamicColor_private.getInitialToneFromBackground(background: ((scheme:DynamicScheme) -> DynamicColor
| nil)?): (scheme:DynamicScheme) -> number
if background == nil then
return function(s)
return 50;
end;
end
return function(s)
return if Boolean.toJSBoolean(background(s))
then (background(s) :: any):getTone(s)
else 50;
end;
end
function DynamicColor_private:clone(): DynamicColor
return DynamicColor:fromPalette({name = self.name, palette = self.palette, tone = self.tone, isBackground = self.isBackground, chromaMultiplier = self.chromaMultiplier, background = self.background, secondBackground = self.secondBackground, contrastCurve = self.contrastCurve, toneDeltaPair = self.toneDeltaPair});
end
function DynamicColor_private:clearCache()
self.hctCache:clear();
end
function DynamicColor_private:getArgb(scheme: DynamicScheme): number
return self:getHct(scheme):toInt();
end
function DynamicColor_private:getHct(scheme: DynamicScheme): Hct
local cachedAnswer = self.hctCache:get(scheme);
if cachedAnswer ~= nil --[[ ROBLOX CHECK: loose inequality used upstream ]] then
return cachedAnswer;
end
local answer = getSpec(scheme.specVersion):getHct(scheme, self);
if self.hctCache.size > 4 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]] then
self.hctCache:clear();
end
self.hctCache:set(scheme, answer);
return answer;
end
function DynamicColor_private:getTone(scheme: DynamicScheme): number
return getSpec(scheme.specVersion):getTone(scheme, self);
end
function DynamicColor_private.foregroundTone(bgTone: number,ratio: number): number
local lighterTone = Contrast:lighterUnsafe(bgTone, ratio);
local darkerTone = Contrast:darkerUnsafe(bgTone, ratio);
local lighterRatio = Contrast:ratioOfTones(lighterTone, bgTone);
local darkerRatio = Contrast:ratioOfTones(darkerTone, bgTone);
local preferLighter = DynamicColor:tonePrefersLightForeground(bgTone);
if Boolean.toJSBoolean(preferLighter) then
-- This handles an edge case where the initial contrast ratio is high
-- (ex. 13.0), and the ratio passed to the function is that high
-- ratio, and both the lighter and darker ratio fails to pass that
-- ratio.
--
-- This was observed with Tonal Spot's On Primary Container turning
-- black momentarily between high and max contrast in light mode. PC's
-- standard tone was T90, OPC's was T10, it was light mode, and the
-- contrast value was 0.6568521221032331.
local negligibleDifference = math.abs(lighterRatio - darkerRatio) < 0.1 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]] and lighterRatio < ratio --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]] and darkerRatio < ratio --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]];
return if Boolean.toJSBoolean(lighterRatio >= ratio --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]] or lighterRatio >= darkerRatio --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]] or negligibleDifference)
then lighterTone
else darkerTone;
else
return if darkerRatio >= ratio --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]] or darkerRatio >= lighterRatio --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
then darkerTone
else lighterTone;
end
end
function DynamicColor_private.tonePrefersLightForeground(tone: number): boolean
return Math.round(tone) --[[ ROBLOX NOTE: Math.round is currently not supported by the Luau Math polyfill, please add your own implementation or file a ticket on the same ]] < 60.0 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]];
end
function DynamicColor_private.toneAllowsLightForeground(tone: number): boolean
return Math.round(tone) --[[ ROBLOX NOTE: Math.round is currently not supported by the Luau Math polyfill, please add your own implementation or file a ticket on the same ]] <= 49.0 --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]];
end
function DynamicColor_private.enableLightForeground(tone: number): number
if Boolean.toJSBoolean((function()
local ref = DynamicColor:tonePrefersLightForeground(tone);
return if Boolean.toJSBoolean(ref)
then not Boolean.toJSBoolean(DynamicColor:toneAllowsLightForeground(tone))
else ref;
end)()) then
return 49.0;
end
return tone;
end
exports.DynamicColor = DynamicColor;
--[[*
 * A delegate for the color calculation of a DynamicScheme in the 2021 spec.
 ]]
type ColorCalculationDelegateImpl2021 = { getHct: (self:ColorCalculationDelegateImpl2021, scheme:DynamicScheme, color:DynamicColor) -> Hct,
getTone: (self:ColorCalculationDelegateImpl2021, scheme:DynamicScheme, color:DynamicColor) -> number, }
type ColorCalculationDelegateImpl2021_statics = { new: () -> ColorCalculationDelegateImpl2021, }
local ColorCalculationDelegateImpl2021 = {} :: ColorCalculationDelegateImpl2021 & ColorCalculationDelegateImpl2021_statics;
(ColorCalculationDelegateImpl2021 :: any).__index = ColorCalculationDelegateImpl2021;
function ColorCalculationDelegateImpl2021.new(): ColorCalculationDelegateImpl2021
local self = setmetatable({}, ColorCalculationDelegateImpl2021);
return (self :: any) :: ColorCalculationDelegateImpl2021;
end
function ColorCalculationDelegateImpl2021:getHct(scheme: DynamicScheme,color: DynamicColor): Hct
local tone = color:getTone(scheme);
local palette = color:palette(scheme);
return palette:getHct(tone);
end
function ColorCalculationDelegateImpl2021:getTone(scheme: DynamicScheme,color: DynamicColor): number
local decreasingContrast = scheme.contrastLevel < 0 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]];
local toneDeltaPair = if Boolean.toJSBoolean(color.toneDeltaPair)
then color:toneDeltaPair(scheme)
else nil;
-- Case 1: dual foreground, pair of colors with delta constraint.
if Boolean.toJSBoolean(toneDeltaPair) then
local roleA = toneDeltaPair.roleA;
local roleB = toneDeltaPair.roleB;
local delta = toneDeltaPair.delta;
local polarity = toneDeltaPair.polarity;
local stayTogether = toneDeltaPair.stayTogether;
local aIsNearer = polarity == "nearer" or polarity == "lighter" and not Boolean.toJSBoolean(scheme.isDark) or polarity == "darker" and scheme.isDark;
local nearer = if Boolean.toJSBoolean(aIsNearer)
then roleA
else roleB;
local farther = if Boolean.toJSBoolean(aIsNearer)
then roleB
else roleA;
local amNearer = color.name == nearer.name;
local expansionDir = if Boolean.toJSBoolean(scheme.isDark)
then 1
else -1;
local nTone = nearer:tone(scheme);
local fTone = farther:tone(scheme);
-- 1st round: solve to min for each, if background and contrast curve
-- are defined.
if Boolean.toJSBoolean((function()
local ref = if Boolean.toJSBoolean(color.background)
then nearer.contrastCurve
else color.background;
return if Boolean.toJSBoolean(ref)
then farther.contrastCurve
else ref;
end)()) then
local bg = color:background(scheme);
local nContrastCurve = nearer:contrastCurve(scheme);
local fContrastCurve = farther:contrastCurve(scheme);
if Boolean.toJSBoolean((function()
local ref = if Boolean.toJSBoolean(bg)
then nContrastCurve
else bg;
return if Boolean.toJSBoolean(ref)
then fContrastCurve
else ref;
end)()) then
local bgTone = bg:getTone(scheme);
local nContrast = nContrastCurve:get(scheme.contrastLevel);
local fContrast = fContrastCurve:get(scheme.contrastLevel);
-- If a color is good enough, it is not adjusted.
-- Initial and adjusted tones for `nearer`
if Contrast:ratioOfTones(bgTone, nTone) < nContrast --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]] then
nTone = DynamicColor:foregroundTone(bgTone, nContrast);
end
-- Initial and adjusted tones for `farther`
if Contrast:ratioOfTones(bgTone, fTone) < fContrast --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]] then
fTone = DynamicColor:foregroundTone(bgTone, fContrast);
end
if Boolean.toJSBoolean(decreasingContrast) then
-- If decreasing contrast, adjust color to the "bare minimum"
-- that satisfies contrast.
nTone = DynamicColor:foregroundTone(bgTone, nContrast);
fTone = DynamicColor:foregroundTone(bgTone, fContrast);
end
end
end
if (fTone - nTone) * expansionDir < delta --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]] then
-- 2nd round: expand farther to match delta, if contrast is not
-- satisfied.
fTone = math_:clampDouble(0, 100, nTone + delta * expansionDir);
if (fTone - nTone) * expansionDir >= delta --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]] then
-- Good! Tones now satisfy the constraint; no change needed.
else
-- 3rd round: contract nearer to match delta.
nTone = math_:clampDouble(0, 100, fTone - delta * expansionDir);
end
end
-- Avoids the 50-59 awkward zone.
if 50 <= nTone --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]] and nTone < 60 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]] then
-- If `nearer` is in the awkward zone, move it away, together with
-- `farther`.
if expansionDir > 0 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]] then
nTone = 60;
fTone = math.max(fTone, nTone + delta * expansionDir);
else
nTone = 49;
fTone = math.min(fTone, nTone + delta * expansionDir);
end
elseif 50 <= fTone --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]] and fTone < 60 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]] then
if Boolean.toJSBoolean(stayTogether) then
-- Fixes both, to avoid two colors on opposite sides of the "awkward
-- zone".
if expansionDir > 0 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]] then
nTone = 60;
fTone = math.max(fTone, nTone + delta * expansionDir);
else
nTone = 49;
fTone = math.min(fTone, nTone + delta * expansionDir);
end
else
-- Not required to stay together; fixes just one.
if expansionDir > 0 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]] then
fTone = 60;
else
fTone = 49;
end
end
end
-- Returns `nTone` if this color is `nearer`, otherwise `fTone`.
return if Boolean.toJSBoolean(amNearer)
then nTone
else fTone;
else
-- Case 2: No contrast pair; just solve for itself.
local answer = color:tone(scheme);
if color.background == nil --[[ ROBLOX CHECK: loose equality used upstream ]] or color:background(scheme) == nil or color.contrastCurve == nil --[[ ROBLOX CHECK: loose equality used upstream ]] or color:contrastCurve(scheme) == nil then
return answer; -- No adjustment for colors with no background.
end
local bgTone = (color:background(scheme) :: any):getTone(scheme);
local desiredRatio = (color:contrastCurve(scheme) :: any):get(scheme.contrastLevel);
if Contrast:ratioOfTones(bgTone, answer) >= desiredRatio --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]] then
-- Don't "improve" what's good enough.
else
-- Rough improvement.
answer = DynamicColor:foregroundTone(bgTone, desiredRatio);
end
if Boolean.toJSBoolean(decreasingContrast) then
answer = DynamicColor:foregroundTone(bgTone, desiredRatio);
end
if Boolean.toJSBoolean((function()
local ref = if Boolean.toJSBoolean(color.isBackground)
then 50 <= answer --[[ ROBLOX CHECK: operator '<=' works only if either both arguments are strings or both are a number ]]
else color.isBackground;
return if Boolean.toJSBoolean(ref)
then answer < 60 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
else ref;
end)()) then
-- Must adjust
if Contrast:ratioOfTones(49, bgTone) >= desiredRatio --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]] then
answer = 49;
else
answer = 60;
end
end
if color.secondBackground == nil --[[ ROBLOX CHECK: loose equality used upstream ]] or color:secondBackground(scheme) == nil then
return answer;
end
-- Case 3: Adjust for dual backgrounds.
local bg1, bg2 = table.unpack({color.background, color.secondBackground}, 1, 2);
local bgTone1, bgTone2 = table.unpack({(bg1(scheme) :: any):getTone(scheme), (bg2(scheme) :: any):getTone(scheme)}, 1, 2);
local upper, lower = table.unpack({math.max(bgTone1, bgTone2), math.min(bgTone1, bgTone2)}, 1, 2);
if Contrast:ratioOfTones(upper, answer) >= desiredRatio --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]] and Contrast:ratioOfTones(lower, answer) >= desiredRatio --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]] then
return answer;
end
-- The darkest light tone that satisfies the desired ratio,
-- or -1 if such ratio cannot be reached.
local lightOption = Contrast:lighter(upper, desiredRatio);
-- The lightest dark tone that satisfies the desired ratio,
-- or -1 if such ratio cannot be reached.
local darkOption = Contrast:darker(lower, desiredRatio);
-- Tones suitable for the foreground.
local availables = {};
if lightOption ~= -1 then
table.insert(availables, lightOption) --[[ ROBLOX CHECK: check if 'availables' is an Array ]];
end
if darkOption ~= -1 then
table.insert(availables, darkOption) --[[ ROBLOX CHECK: check if 'availables' is an Array ]];
end
local ref = DynamicColor:tonePrefersLightForeground(bgTone1);
local prefersLight = Boolean.toJSBoolean(ref) and ref or DynamicColor:tonePrefersLightForeground(bgTone2);
if Boolean.toJSBoolean(prefersLight) then
return if lightOption < 0 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
then 100
else lightOption;
end
if availables.length == 1 then
return availables[1 --[[ ROBLOX adaptation: added 1 to array index ]]];
end
return if darkOption < 0 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
then 0
else darkOption;
end
end
--[[*
 * A delegate for the color calculation of a DynamicScheme in the 2025 spec.
 ]]
type ColorCalculationDelegateImpl2025 = { getHct: (self:ColorCalculationDelegateImpl2025, scheme:DynamicScheme, color:DynamicColor) -> Hct,
getTone: (self:ColorCalculationDelegateImpl2025, scheme:DynamicScheme, color:DynamicColor) -> number, }
type ColorCalculationDelegateImpl2025_statics = { new: () -> ColorCalculationDelegateImpl2025, }
local ColorCalculationDelegateImpl2025 = {} :: ColorCalculationDelegateImpl2025 & ColorCalculationDelegateImpl2025_statics;
(ColorCalculationDelegateImpl2025 :: any).__index = ColorCalculationDelegateImpl2025;
function ColorCalculationDelegateImpl2025.new(): ColorCalculationDelegateImpl2025
local self = setmetatable({}, ColorCalculationDelegateImpl2025);
return (self :: any) :: ColorCalculationDelegateImpl2025;
end
function ColorCalculationDelegateImpl2025:getHct(scheme: DynamicScheme,color: DynamicColor): Hct
local palette = color:palette(scheme);
local tone = color:getTone(scheme);
local hue = palette.hue;
local chroma = palette.chroma * (if Boolean.toJSBoolean(color.chromaMultiplier)
then color:chromaMultiplier(scheme)
else 1);
return Array.from(Hct, hue, chroma, tone) --[[ ROBLOX CHECK: check if 'Hct' is an Array ]];
end
function ColorCalculationDelegateImpl2025:getTone(scheme: DynamicScheme,color: DynamicColor): number
local toneDeltaPair = if Boolean.toJSBoolean(color.toneDeltaPair)
then color:toneDeltaPair(scheme)
else nil;
-- Case 0: tone delta constraint.
if Boolean.toJSBoolean(toneDeltaPair) then
local roleA = toneDeltaPair.roleA;
local roleB = toneDeltaPair.roleB;
local polarity = toneDeltaPair.polarity;
local constraint = toneDeltaPair.constraint;
local absoluteDelta = if Boolean.toJSBoolean((function()
local ref = polarity == "darker" or polarity == "relative_lighter" and scheme.isDark;
return Boolean.toJSBoolean(ref) and ref or polarity == "relative_darker" and not Boolean.toJSBoolean(scheme.isDark);
end)())
then -toneDeltaPair.delta
else toneDeltaPair.delta;
local amRoleA = color.name == roleA.name;
local selfRole = if Boolean.toJSBoolean(amRoleA)
then roleA
else roleB;
local refRole = if Boolean.toJSBoolean(amRoleA)
then roleB
else roleA;
local selfTone = selfRole:tone(scheme);
local refTone = refRole:getTone(scheme);
local relativeDelta = absoluteDelta * (if Boolean.toJSBoolean(amRoleA)
then 1
else -1);
if constraint == "exact" then
selfTone = math_:clampDouble(0, 100, refTone + relativeDelta);
elseif constraint == "nearer" then
if relativeDelta > 0 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]] then
selfTone = math_:clampDouble(0, 100, math_:clampDouble(refTone, refTone + relativeDelta, selfTone));
else
selfTone = math_:clampDouble(0, 100, math_:clampDouble(refTone + relativeDelta, refTone, selfTone));
end
elseif constraint == "farther" then
if relativeDelta > 0 --[[ ROBLOX CHECK: operator '>' works only if either both arguments are strings or both are a number ]] then
selfTone = math_:clampDouble(refTone + relativeDelta, 100, selfTone);
else
selfTone = math_:clampDouble(0, refTone + relativeDelta, selfTone);
end
end
if Boolean.toJSBoolean(if Boolean.toJSBoolean(color.background)
then color.contrastCurve
else color.background) then
local background = color:background(scheme);
local contrastCurve = color:contrastCurve(scheme);
if Boolean.toJSBoolean(if Boolean.toJSBoolean(background)
then contrastCurve
else background) then
-- Adjust the tones for contrast, if background and contrast curve
-- are defined.
local bgTone = background:getTone(scheme);
local selfContrast = contrastCurve:get(scheme.contrastLevel);
selfTone = if Contrast:ratioOfTones(bgTone, selfTone) >= selfContrast --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]] and scheme.contrastLevel >= 0 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
then selfTone
else DynamicColor:foregroundTone(bgTone, selfContrast);
end
end
-- This can avoid the awkward tones for background colors including the
-- access fixed colors. Accent fixed dim colors should not be adjusted.
if Boolean.toJSBoolean(if Boolean.toJSBoolean(color.isBackground)
then not Boolean.toJSBoolean(color.name:endsWith("_fixed_dim"))
else color.isBackground) then
if selfTone >= 57 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]] then
selfTone = math_:clampDouble(65, 100, selfTone);
else
selfTone = math_:clampDouble(0, 49, selfTone);
end
end
return selfTone;
else
-- Case 1: No tone delta pair; just solve for itself.
local answer = color:tone(scheme);
if color.background == nil --[[ ROBLOX CHECK: loose equality used upstream ]] or color:background(scheme) == nil or color.contrastCurve == nil --[[ ROBLOX CHECK: loose equality used upstream ]] or color:contrastCurve(scheme) == nil then
return answer; -- No adjustment for colors with no background.
end
local bgTone = (color:background(scheme) :: any):getTone(scheme);
local desiredRatio = (color:contrastCurve(scheme) :: any):get(scheme.contrastLevel);
-- Recalculate the tone from desired contrast ratio if the current
-- contrast ratio is not enough or desired contrast level is decreasing
-- (<0).
answer = if Contrast:ratioOfTones(bgTone, answer) >= desiredRatio --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]] and scheme.contrastLevel >= 0 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]]
then answer
else DynamicColor:foregroundTone(bgTone, desiredRatio);
-- This can avoid the awkward tones for background colors including the
-- access fixed colors. Accent fixed dim colors should not be adjusted.
if Boolean.toJSBoolean(if Boolean.toJSBoolean(color.isBackground)
then not Boolean.toJSBoolean(color.name:endsWith("_fixed_dim"))
else color.isBackground) then
if answer >= 57 --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]] then
answer = math_:clampDouble(65, 100, answer);
else
answer = math_:clampDouble(0, 49, answer);
end
end
if color.secondBackground == nil --[[ ROBLOX CHECK: loose equality used upstream ]] or color:secondBackground(scheme) == nil then
return answer;
end
-- Case 2: Adjust for dual backgrounds.
local bg1, bg2 = table.unpack({color.background, color.secondBackground}, 1, 2);
local bgTone1, bgTone2 = table.unpack({(bg1(scheme) :: any):getTone(scheme), (bg2(scheme) :: any):getTone(scheme)}, 1, 2);
local upper, lower = table.unpack({math.max(bgTone1, bgTone2), math.min(bgTone1, bgTone2)}, 1, 2);
if Contrast:ratioOfTones(upper, answer) >= desiredRatio --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]] and Contrast:ratioOfTones(lower, answer) >= desiredRatio --[[ ROBLOX CHECK: operator '>=' works only if either both arguments are strings or both are a number ]] then
return answer;
end
-- The darkest light tone that satisfies the desired ratio,
-- or -1 if such ratio cannot be reached.
local lightOption = Contrast:lighter(upper, desiredRatio);
-- The lightest dark tone that satisfies the desired ratio,
-- or -1 if such ratio cannot be reached.
local darkOption = Contrast:darker(lower, desiredRatio);
-- Tones suitable for the foreground.
local availables = {};
if lightOption ~= -1 then
table.insert(availables, lightOption) --[[ ROBLOX CHECK: check if 'availables' is an Array ]];
end
if darkOption ~= -1 then
table.insert(availables, darkOption) --[[ ROBLOX CHECK: check if 'availables' is an Array ]];
end
local ref = DynamicColor:tonePrefersLightForeground(bgTone1);
local prefersLight = Boolean.toJSBoolean(ref) and ref or DynamicColor:tonePrefersLightForeground(bgTone2);
if Boolean.toJSBoolean(prefersLight) then
return if lightOption < 0 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
then 100
else lightOption;
end
if availables.length == 1 then
return availables[1 --[[ ROBLOX adaptation: added 1 to array index ]]];
end
return if darkOption < 0 --[[ ROBLOX CHECK: operator '<' works only if either both arguments are strings or both are a number ]]
then 0
else darkOption;
end
end
local spec2021 = ColorCalculationDelegateImpl2021.new();
local spec2025 = ColorCalculationDelegateImpl2025.new();
--[[*
 * Returns the ColorCalculationDelegate for the given spec version.
 ]]
local function getSpec(specVersion: SpecVersion): ColorCalculationDelegate
return if specVersion == "2025"
then spec2025
else spec2021;
end
return exports;
