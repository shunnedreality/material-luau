--!strict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local Theming = require(MaterialRoblox.Utils.Theming);

local function getTokens()
	local theme = Theming:now();

	return {
		labelText = theme.typography.label.large,
		tonalTextColor = theme.color.onSecondaryContainer,
		textTextColor = theme.color.primary,
		outlinedTextColor = theme.color.primary,
		filledTextColor = theme.color.onPrimary,
		tonalBackgroundColor = theme.color.secondaryContainer,
		filledBackgroundColor = theme.color.primary,
		textBackgroundTransparency = 1,
		outlinedBackgroundTransparency = 1,
		outlinedStrokeColor = theme.color.outline,
		height = 40;
		paddingLeft = 16,
		paddingRight = 16,
		shape = UDim.new(1, 0)
	}
end

return getTokens