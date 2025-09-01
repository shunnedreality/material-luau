--!strict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local Theming = require(MaterialRoblox.Utils.Theming);

local function getTokens()
	local theme = Theming:now();

	return {
		labelColor = theme.color.onSurface,
        labelFont = theme.typography.label.large,
        trailingLabelColor = theme.color.onSurfaceVariant
	}
end

return getTokens