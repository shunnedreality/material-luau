--!strict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local NavigationBarTokens = require(MaterialRoblox.Tokens.NavigationBar);
local Fusion = require(MaterialRoblox.Parent.Fusion);
local NavigationBarState = require(MaterialRoblox.Utils.NavigationBarState);

local Children = Fusion.Children;

local function NavigationBar(
	scope: Fusion.Scope,
	props: {
		renderTabs: () -> { Instance }
	}
)
	local Tokens = NavigationBarTokens();
	
	local tabChildren = NavigationBarState.NavigationBarState:is({
		activeIndex = scope:Value(1),
		incrementalIndex = 1
	}):during(props.renderTabs);
	
	assert(5 >= #tabChildren and #tabChildren > 1, "Tabs must be less than or equal to 5 and more than 1.")
	
	return scope:New("Frame") {
		Size = UDim2.new(1, 0, 0, 58),
		BackgroundColor3 = Tokens.containerColor,
		BorderSizePixel = 0,
		
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

return NavigationBar