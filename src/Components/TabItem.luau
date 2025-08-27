--!nonstrict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local TextService = game:GetService("TextService");

local MaterialRoblox = script.Parent.Parent;

local TabsTokens = require(MaterialRoblox.Tokens.TabItem);
local Fusion = require(MaterialRoblox.Parent.Fusion);
local TabState = require(MaterialRoblox.Utils.TabState);
local Ripple = require(MaterialRoblox.Components.Ripple);
local Icon = require(MaterialRoblox.Components.Icon)

local Children = Fusion.Children;
local OnEvent = Fusion.OnEvent;
local Out = Fusion.Out;

local ICON_WIDTH = 24;
local INITIAL_ANIMATION = TweenInfo.new(
	0.5,
	Enum.EasingStyle.Circular,
	Enum.EasingDirection.InOut
);

local function setActiveTab(
	toIndex: number,
	TabStateNow
)
	local previousIndex = Fusion.peek(TabStateNow.activeIndex);
	
	if (previousIndex == toIndex) then
		return;
	end
	
	local previousTabIndicator = TabStateNow.tabs[previousIndex];
	local previousTabIndicatorAbsolutePosition: Vector2 = Fusion.peek(previousTabIndicator.indicatorAbsolutePosition);
	local previousTabIndicatorWidth = Fusion.peek(previousTabIndicator.indicatorWidth);
	local previousTabAbsoluteSize = Fusion.peek(previousTabIndicator.tabAbsoluteSize);
	local previousTabAbsolutePosition = Fusion.peek(previousTabIndicator.tabAbsolutePosition);
	local previousTabCenterAbsoluteX = previousTabAbsolutePosition.X + (previousTabAbsoluteSize.X / 2)
	
	local nextTabIndicator = assert(TabStateNow.tabs[toIndex]);
	local nextTabIndicatorAbsolutePosition: Vector2 = Fusion.peek(nextTabIndicator.indicatorAbsolutePosition);
	local nextTabIndicatorWidth = Fusion.peek(nextTabIndicator.indicatorWidth);
	local nextTabAbsolutePosition = Fusion.peek(nextTabIndicator.tabAbsolutePosition);
	local nextTabAbsoluteSize = Fusion.peek(nextTabIndicator.tabAbsoluteSize);	
	local nextTabCenterAbsoluteX = nextTabAbsolutePosition.X + (nextTabAbsoluteSize.X / 2)

	local startPositionOffset = previousTabCenterAbsoluteX - nextTabCenterAbsoluteX

	TabStateNow.activeIndex:set(toIndex);

	nextTabIndicator.indicatorAnimation:set(TweenInfo.new(0));

	nextTabIndicator.indicatorWidth:set(previousTabIndicatorWidth);
	nextTabIndicator.indicatorPosition:set(UDim2.new(0.5, startPositionOffset, 1, 4));

	nextTabIndicator.indicatorAnimation:set(INITIAL_ANIMATION);

	nextTabIndicator.indicatorWidth:set(nextTabIndicatorWidth);
	nextTabIndicator.indicatorPosition:set(UDim2.new(0.5, 0, 1, 4));
end

local function getInitialTabSize(
	text: string
)
	local Tokens = TabsTokens();
	
	local getTextBoundsParams = Instance.new("GetTextBoundsParams");

	getTextBoundsParams.Text = text;
	getTextBoundsParams.Font = Tokens.labelFont.font;
	getTextBoundsParams.Size = Tokens.labelFont.fontSize;

	return math.max(ICON_WIDTH, TextService:GetTextBoundsAsync(getTextBoundsParams).X);
end

local function TabItem(
	scope: Fusion.Scope,
	props: {
		label: string,
		icon: string
	}
)
	local Tokens = TabsTokens();

	local state = TabState.TabState:now();
	assert(state ~= TabState.NOT_A_STATE, "Must run in renderTabs() context!");

	local thisIndex = state.incrementalIndex;
	local activeIndex = state.activeIndex;	

	state.incrementalIndex += 1;

	local tabWidth = scope:Value(getInitialTabSize(props.label))
	
	local indicatorPosition = scope:Value(UDim2.new(0.5, 0, 1, 4));
	local indicatorAbsolutePosition = scope:Value(Vector2.new(0, 0));
	local indicatorAnimation = scope:Value(INITIAL_ANIMATION);
	local tabAbsolutePosition = scope:Value(Vector2.new(0, 0));
	local tabAbsoluteSize = scope:Value(Vector2.new(0, 0))
	
	local isActive = scope:Computed(function(
		use: Fusion.Use
	)
		return use(activeIndex) == thisIndex
	end)
	
	state.tabs[thisIndex] = {
		indicatorPosition = indicatorPosition,
		indicatorWidth = tabWidth,
		indicatorAbsolutePosition = indicatorAbsolutePosition,
		indicatorAnimation = indicatorAnimation,
		tabAbsoluteSize = tabAbsoluteSize,
		tabAbsolutePosition = tabAbsolutePosition
	}

	return scope:New("ImageButton") {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0, 1),
		ImageTransparency = 1,
		
		[Out "AbsolutePosition"] = tabAbsolutePosition,
		[Out "AbsoluteSize"] = tabAbsoluteSize,

		[OnEvent "MouseButton1Click"] = function()
			setActiveTab(thisIndex, state)
		end,

		[Children] = {
			Ripple(scope, {
				borderRadius = UDim.new(0, 0)	
			}),
			
			scope:New("Frame") {
				Size = scope:Tween(
					scope:Computed(function(
						use: Fusion.Use
					)
						return UDim2.fromOffset(use(tabWidth), 8)
					end),
					indicatorAnimation
				),
				[Out "AbsolutePosition"] = indicatorAbsolutePosition,
				Position = scope:Tween(indicatorPosition, indicatorAnimation),
				AnchorPoint = Vector2.new(.5, 1),
				BackgroundColor3 = Tokens.indicatorColor,
				Visible = isActive,
				
				[Children] = {
					scope:New("UICorner") {
						CornerRadius = UDim.new(1, 0)
					}
				}
			},

			scope:New("Frame") {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1);

				[Children] = {
					scope:New("UIListLayout") {
						Padding = UDim.new(0, 4),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center
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
								if use(isActive) then
									return Tokens.activeIconColor
								else
									return Tokens.inactiveIconColor
								end
							end),
							TweenInfo.new(.1)
						),
						Position = UDim2.fromScale(.5, .5),
						AnchorPoint = Vector2.new(.5, .5)
					},
					
					scope:New("TextLabel") {
						Text = props.label,
						FontFace = Tokens.labelFont.font,
						TextSize = Tokens.labelFont.fontSize,
						TextColor3 = scope:Tween(
							scope:Computed(function(
								use: Fusion.Use
							)
								if use(isActive) then
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
				}
			},
		}
	}
end

return TabItem