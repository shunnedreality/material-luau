--!strict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local Theming = require(MaterialRoblox.Utils.Theming);

local function getTokens()
	local theme = Theming:now();

	return {
		shape = UDim.new(0, 4),
        verticalPadding = UDim.new(0, 8),
        containerColor = theme.color.surfaceContainer
	}
end

return getTokens