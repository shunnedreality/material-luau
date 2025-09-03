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
local Boolean = LuauPolyfill.Boolean
local exports = {}
require(Packages.jasmine)
local hexFromArgb = require(script.Parent["string_utils"]).hexFromArgb
error("not implemented") --[[ ROBLOX TODO: Unhandled node for type: TSModuleDeclaration ]] --[[ declare global {
  namespace jasmine {
    interface Matchers<T> {
      matchesColor(expected: number): boolean;
    }
  }
} ]]
--[[*
 * Exports a matcher called `matchesColor` that takes two numbers, and logs
 * the equivalent hex codes on failure.
 *
 * To use, add to your test file:
 *  beforeEach(() => {
 *    jasmine.addMatchers(customMatchers);
 *  });
 *
 * Then it can be used as a standard matcher:
 *  expect(scheme.onSurface).matchesColor(0xff000000);
 ]]
--[[*
 * Exports a matcher called `matchesColor` that takes two numbers, and logs
 * the equivalent hex codes on failure.
 *
 * To use, add to your test file:
 *  beforeEach(() => {
 *    jasmine.addMatchers(customMatchers);
 *  });
 *
 * Then it can be used as a standard matcher:
 *  expect(scheme.onSurface).matchesColor(0xff000000);
 ]]
local customMatchers: jasmine_CustomMatcherFactories = {
	matchesColor = function(
		self,
		util: jasmine_MatchersUtil,
		customEqualityTesters: any --[[ ROBLOX TODO: Unhandled node for type: TSTypeOperator ]] --[[ readonly jasmine.CustomEqualityTester[] ]]
	)
		return {
			compare = function(self, actual: number, expected: number)
				local pass = util:equals(actual, expected)
				return {
					pass = pass,
					message = ("Expected color %s to %s match: %s"):format(
						tostring(hexFromArgb(actual)),
						if Boolean.toJSBoolean(pass) then "NOT" else "",
						tostring(hexFromArgb(expected))
					),
				}
			end,
		}
	end,
}
exports.customMatchers = customMatchers
return exports
