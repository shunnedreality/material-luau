--!strict

local MaterialRoblox = script.Parent.Parent;

local DefaultTheme = require(MaterialRoblox.Utils.DefaultTheme);
local Fusion = require(MaterialRoblox.Parent.Fusion);

local Contextual = Fusion.Contextual;

local Theme = Contextual(DefaultTheme);

return Theme;