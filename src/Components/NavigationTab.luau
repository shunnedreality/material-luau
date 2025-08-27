--!nonstrict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local NavigationTabTokens = require(MaterialRoblox.Tokens.NavigationTab);
local Fusion = require(MaterialRoblox.Parent.Fusion);
local NavigationBarState = require(MaterialRoblox.Utils.NavigationBarState);
local Ripple = require(MaterialRoblox.Components.Ripple);
local Icon = require(MaterialRoblox.Components.Icon)

local Children = Fusion.Children;
local OnEvent = Fusion.OnEvent;

local function NavigationTab(
	scope: Fusion.Scope,
	props: {
		label: string,
		icon: string
	}
)
	local Tokens = NavigationTabTokens();
	
	local state = NavigationBarState.NavigationBarState:now();
	assert(state ~= NavigationBarState.NOT_A_STATE, "Must run in renderTabs() context!");
	
	local thisIndex = state.incrementalIndex;
	local activeIndex = state.activeIndex;
	
	state.incrementalIndex += 1;

	return scope:New("ImageButton") {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0, 1);
		ImageTransparency = 1;
		
		[OnEvent "MouseButton1Click"] = function()
			activeIndex:set(thisIndex);
		end,
		
		[Children] = {
			Ripple(scope, {
				borderRadius = UDim.new(0, 0)	
			}),
			
			scope:New("Frame") {
				BackgroundColor3 = Tokens.indicatorColor,
				BackgroundTransparency = scope:Tween(
					scope:Computed(function(
						use: Fusion.Use
					)
						if use(activeIndex) == thisIndex then
							return 0
						else
							return 1
						end
					end),
					TweenInfo.new(.1)
				),
				Size = scope:Spring(
					scope:Computed(function(
						use: Fusion.Use
					)
						if use(activeIndex) == thisIndex then
							return UDim2.fromOffset(56, 32)
						else
							return UDim2.fromOffset(0, 32)
						end
					end),
					25,
					.9
				),
				
				[Children] = {
					scope:New("UICorner") {
						CornerRadius = UDim.new(0, 16)
					},
					
					scope:Hydrate(
						Icon(scope, {
							icon = props.icon
						})
					) {
						ImageColor3 = scope:Tween(
							scope:Computed(function(
								use: Fusion.Use
							)
								if use(activeIndex) == thisIndex then
									return Tokens.activeIconColor
								else
									return Tokens.inactiveIconColor
								end
							end),
							TweenInfo.new(.1)
						),
						Position = UDim2.fromScale(.5, .5),
						AnchorPoint = Vector2.new(.5, .5)
					}
				}
			},
			
			scope:New("TextLabel") {
				Text = props.label,
				FontFace = Tokens.labelFont.font,
				TextSize = Tokens.labelFont.fontSize,
				TextColor3 = scope:Tween(
					scope:Computed(function(
						use: Fusion.Use
					)
						if use(activeIndex) == thisIndex then
							return Tokens.activeLabelColor
						else
							return Tokens.inactiveLabelColor
						end
					end),
					TweenInfo.new(.1)
				),
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(0, 0),
				AutomaticSize = Enum.AutomaticSize.XY
			},
			
			scope:New("UIListLayout") {
				Padding = UDim.new(0, 4),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}
		}
	}
end

return NavigationTab