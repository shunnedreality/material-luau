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
local Packages = script.Parent
local LuauPolyfill = require(Packages.LuauPolyfill)
local Object = LuauPolyfill.Object
local exports = {}
Object.assign(exports, require(script.blend["blend"]))
Object.assign(exports, require(script.contrast["contrast"]))
Object.assign(exports, require(script.dislike["dislike_analyzer"]))
Object.assign(exports, require(script.dynamiccolor["dynamic_color"]))
Object.assign(exports, require(script.dynamiccolor["dynamic_scheme"]))
Object.assign(exports, require(script.dynamiccolor["material_dynamic_colors"]))
Object.assign(exports, require(script.dynamiccolor["variant"]))
Object.assign(exports, require(script.hct["cam16"]))
Object.assign(exports, require(script.hct["hct"]))
Object.assign(exports, require(script.hct["viewing_conditions"]))
Object.assign(exports, require(script.palettes["core_palette"]))
Object.assign(exports, require(script.palettes["tonal_palette"]))
Object.assign(exports, require(script.quantize["quantizer_celebi"]))
Object.assign(exports, require(script.quantize["quantizer_map"]))
Object.assign(exports, require(script.quantize["quantizer_wsmeans"]))
Object.assign(exports, require(script.quantize["quantizer_wu"]))
Object.assign(exports, require(script.scheme["scheme"]))
Object.assign(exports, require(script.scheme["scheme_android"]))
Object.assign(exports, require(script.scheme["scheme_content"]))
Object.assign(exports, require(script.scheme["scheme_expressive"]))
Object.assign(exports, require(script.scheme["scheme_fidelity"]))
Object.assign(exports, require(script.scheme["scheme_fruit_salad"]))
Object.assign(exports, require(script.scheme["scheme_monochrome"]))
Object.assign(exports, require(script.scheme["scheme_neutral"]))
Object.assign(exports, require(script.scheme["scheme_rainbow"]))
Object.assign(exports, require(script.scheme["scheme_tonal_spot"]))
Object.assign(exports, require(script.scheme["scheme_vibrant"]))
Object.assign(exports, require(script.score["score"]))
Object.assign(exports, require(script.temperature["temperature_cache"]))
Object.assign(exports, require(script.utils["color_utils"]))
Object.assign(exports, require(script.utils["math_utils"]))
Object.assign(exports, require(script.utils["string_utils"]))
Object.assign(exports, require(script.utils["image_utils"]))
Object.assign(exports, require(script.utils["theme_utils"]))

return exports
