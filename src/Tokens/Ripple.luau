--!strict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local Theming = require(MaterialRoblox.Utils.Theming);

local function getTokens()
	local theme = Theming:now();

	return {
		hoverColor = theme.color.onSurface,
		hoverTransparency = 1 - 0.08,
		pressedColor = theme.color.onSurface,
		pressedTransparency = 1 - 0.12
	}
end

return getTokens