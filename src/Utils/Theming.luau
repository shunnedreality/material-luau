--!strict

local MaterialRoblox = script.Parent.Parent;

local MaterialColorUtilities = require(MaterialRoblox.MaterialColorUtilities);
local MaterialTypography = require(MaterialRoblox.Utils.MaterialTypography);
local Fusion = require(MaterialRoblox.Parent.Fusion);

local Contextual = Fusion.Contextual;

local Theme = Contextual({
	color = MaterialColorUtilities.default:light(Color3.new(0.258824, 0.521569, 0.956863)),
	typography = MaterialTypography(16658221428)
});

return Theme;