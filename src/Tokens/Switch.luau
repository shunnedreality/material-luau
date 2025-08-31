--!strict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local Theming = require(MaterialRoblox.Utils.Theming);

local function getTokens()
	local theme = Theming:now();

	return {
		trackColorUnselected = theme.color.surfaceContainerHighest,
        trackColorSelected = theme.color.primary,
        handleColorUnselected = theme.color.outline,
        handleColorSelected = theme.color.onPrimary,
        handleUnselectedSize = 16,
        handleSelectedSize = 24,
        containerHeight = 32,
        containerWidth = 52,
        handlePressedSize = 28,
        trackUnselectedOutlineColor = theme.color.outline,
        handleUnselectedHoverColor = theme.color.onSurfaceVariant,
        handleSelectedHoverColor = theme.color.primaryContainer,
        stateLayerColor = theme.color.onSurface,
        stateLayerTransparency = 1 - 0.08
	}
end

return getTokens