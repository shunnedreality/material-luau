--!nonstrict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local TabsToken = require(MaterialRoblox.Tokens.Tabs);
local Fusion = require(MaterialRoblox.Parent.Fusion);
local TabState = require(MaterialRoblox.Utils.TabState);

local Children = Fusion.Children;

local function Tabs(
	scope: Fusion.Scope,
	props: {
		renderTabs: () -> { Instance }
	}
)
	local Tokens = TabsToken();
	
	local tabChildren = TabState.TabState:is({
		activeIndex = scope:Value(1),
		incrementalIndex = 1,
		tabs = {}
	}):during(props.renderTabs);

	assert(#tabChildren > 1, "Tabs must be more than 1.")

	return scope:New("Frame") {
		Size = UDim2.new(1, 0, 0, 64),
		BackgroundColor3 = Tokens.containerColor,
		BorderSizePixel = 0,
		ClipsDescendants = true,

		[Children] = {
			scope:New("UIListLayout") {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				HorizontalFlex = Enum.UIFlexAlignment.Fill
			},

			table.unpack(tabChildren);
		}
	}
end

return Tabs