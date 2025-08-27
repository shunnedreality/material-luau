

--!strict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local Theming = require(MaterialRoblox.Utils.Theming);

local function getTokens()
	local theme = Theming:now();

	return {
		activeIconColor = theme.color.primary,
		inactiveIconColor = theme.color.onSurfaceVariant,
		activeLabelColor = theme.color.primary,
		inactiveLabelColor = theme.color.onSurfaceVariant,
		indicatorColor = theme.color.primary,
		labelFont = theme.typography.label.large
	}
end

return getTokens