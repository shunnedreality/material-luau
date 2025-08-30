--!strict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local Theming = require(MaterialRoblox.Utils.Theming);

local function getTokens()
	local theme = Theming:now();

	return {
		containerColor = theme.color.surfaceContainerHigh,
        titleColor = theme.color.onSurface,
        bodyColor = theme.color.onSurfaceVariant,
        labelFontSize = theme.typography.body.large.fontSize,
        titleFont = theme.typography.expressiveFont,
        bodyFont = theme.typography.body.large.font
	}
end

return getTokens