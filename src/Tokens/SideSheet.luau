--!strict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local Theming = require(MaterialRoblox.Utils.Theming);

local function getTokens()
	local theme = Theming:now();

	return {
		scrimColor = Color3.new(0, 0, 0),
		scrimTransparency = 1 - .32,
		containerColor = theme.color.surfaceContainerLow,
        headlineText = theme.typography.title.large,
        cornerRadius = UDim.new(0, 16),
        outline = theme.color.outline
	}
end

return getTokens