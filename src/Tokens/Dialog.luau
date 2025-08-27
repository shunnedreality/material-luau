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
		containerColor = theme.color.surfaceContainerHigh,
		cornerRadius = UDim.new(0, 28),
		headlineText = theme.typography.headline.small,
		bodyText = theme.typography.body.large,
		headlineColor = theme.color.onSurface,
		bodyColor = theme.color.onSurfaceVariant
	}
end

return getTokens