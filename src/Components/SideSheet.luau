--!nocheck
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local SideSheetTokens = require(MaterialRoblox.Tokens.SideSheet);
local Fusion = require(MaterialRoblox.Parent.Fusion);
local showComputed = require(MaterialRoblox.Utils.ShowComputed);
local IconButton = require(MaterialRoblox.Components.IconButton);

local Children = Fusion.Children;

local function SideSheet(
	scope: Fusion.Scope,
	props: {
		headline: Fusion.UsedAs<string>,
        [typeof(Children)]: { Instance },
		open: Fusion.Value<boolean>,
        inset: Fusion.UsedAs<boolean>?
	}
)
	local Tokens = SideSheetTokens();

    local function safeClose()
        Fusion.Safe({
            try = function()
                props.open:set(false)
            end,
            fallback = function()
                warn("You need to set SideSheet.open to a state.")
            end
        })
    end
	
	return scope:New("Frame") {
		Name = "Scrim",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Tokens.scrimColor,
		BackgroundTransparency = scope:Tween(
			scope:Computed(function(
				use: Fusion.Use
			)
				if use(props.open) then
					return Tokens.scrimTransparency
				else
					return 1
				end
			end),
			TweenInfo.new(.1)
		),
		
		[Children] = {
            showComputed(scope, props.inset or false, function()
                return scope:New("UIPadding") {
                    PaddingTop = UDim.new(0, 16),
                    PaddingRight = UDim.new(0, 16),
                    PaddingBottom = UDim.new(0, 16)
                }
            end),

			showComputed(scope, props.open, function()
				return scope:New("ImageButton") {
					Modal = true,
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					ImageTransparency = 1,
				}
			end),

			scope:New("Frame") {
				AnchorPoint = Vector2.new(1, .5),
				Position = scope:Spring(
                    scope:Computed(function(
                        use: Fusion.Use
                    )
                        if use(props.open) then
                            return UDim2.fromScale(1, .5)
                        else
                            if props.inset then
                                return UDim2.new(1, 400 + 16, 0.5, 0)
                            end

                            return UDim2.new(1, 400, 0.5, 0)
                        end
                    end),
                    25,
                    1
                ),
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromScale(0, 1),
				BackgroundColor3 = Tokens.containerColor,
				ZIndex = 2,

				[Children] = {
					scope:New("UICorner") {
						CornerRadius = Tokens.cornerRadius
					},

					scope:New("UISizeConstraint") {
						MaxSize = Vector2.new(
                            400,
                            math.huge
						),
                        MinSize = Vector2.new(
                            300,
                            0
                        )
					},

					scope:New("UIListLayout") {
						SortOrder = Enum.SortOrder.LayoutOrder,
					},

                    scope:New("Frame") {
                        Size = UDim2.fromScale(1, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,

                        [Children] = {
                            scope:New("UIPadding") {
                                PaddingLeft = UDim.new(0, 8),
                                PaddingTop = UDim.new(0, 16),
                                PaddingRight = UDim.new(0, 16),
                                PaddingBottom = UDim.new(0, 16)
                            },

                            scope:New("UIListLayout") {
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                Padding = UDim.new(0, 4),
                                VerticalFlex = Enum.UIFlexAlignment.Fill,
                                FillDirection = Enum.FillDirection.Horizontal
                            },

                            IconButton(scope, {
                                icon = "arrow_back",
                                onClick = function()
                                    safeClose();
                                end
                            }),

                            scope:New("TextLabel") {
                                BackgroundTransparency = 1,
                                Size = UDim2.new(1, -8, 0, 0),
                                AutomaticSize = Enum.AutomaticSize.Y,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Text = props.headline,
                                FontFace = Tokens.headlineText.font,
                                TextSize = Tokens.headlineText.fontSize,
                                TextColor3 = Tokens.headlineColor,
                                TextWrapped = true,
                                LayoutOrder = 0,

                                [Children] = {
                                    scope:New("UIFlexItem") {
                                        FlexMode = Enum.UIFlexMode.Fill
                                    }
                                }
                            },

                            IconButton(scope, {
                                icon = "close",
                                onClick = function()
                                    safeClose();
                                end
                            }),
                        }
                    },

                    scope:New("Frame") {
                        Size = UDim2.fromScale(1, 0),
                        BackgroundTransparency = 1,
                        
                        [Children] = {
                            scope:New("UIFlexItem") {
                                FlexMode = Enum.UIFlexMode.Fill
                            },

                            props[Fusion.Children]
                        }
                    }
				}
			}
		}
	};
end

return SideSheet