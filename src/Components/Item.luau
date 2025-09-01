--!nonstrict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local Fusion = require(MaterialRoblox.Parent.Fusion);
local ItemTokens = require(MaterialRoblox.Tokens.Item);
local Ripple = require(MaterialRoblox.Components.Ripple);
local showComputed = require(MaterialRoblox.Utils.ShowComputed);
local Icon = require(MaterialRoblox.Components.Icon);

local OnEvent = Fusion.OnEvent;
local Children = Fusion.Children;

local function Item(
    scope: Fusion.Scope,
    props: {
        icon: string?,
        label: string,
        trailing: string?,
        onClick: () -> ()?
    }
)
    local Tokens = ItemTokens();

    return scope:New("ImageButton") {
        Size = UDim2.new(1, 0, 0, 48),
        ImageTransparency = 1,
        BackgroundTransparency = 1,

        [OnEvent "MouseButton1Click"] = props.onClick,

        [Children] = {
            Ripple(scope, {
                borderRadius = UDim.new(0, 0)
            }),

            scope:New("Frame") {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                [Children] = {
                    scope:New("UIPadding") {
                        PaddingLeft = UDim.new(0, 12),
                        PaddingRight = UDim.new(0, 12)
                    },

                    scope:New("UIListLayout") {
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, 12),
                        VerticalAlignment = Enum.VerticalAlignment.Center
                    },

                    showComputed(scope, props.icon, function()
                        return Icon(scope, {
                            icon = props.icon
                        })
                    end),

                    scope:New("TextLabel") {
                        Size = UDim2.fromScale(0, 1);
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Text = props.label,
                        FontFace = Tokens.labelFont.font,
                        TextSize = Tokens.labelFont.fontSize,
                        TextColor3 = Tokens.labelColor,

                        [Children] = {
                            scope:New("UIFlexItem") {
                                FlexMode = Enum.UIFlexMode.Fill
                            }
                        }
                    },

                    showComputed(scope, props.trailing, function()
                        return scope:New("TextLabel") {
                            Size = UDim2.fromOffset(0, 0),
                            AutomaticSize = Enum.AutomaticSize.XY,
                            BackgroundTransparency = 1,
                            FontFace = Tokens.labelFont.font,
                            TextSize = Tokens.labelFont.fontSize,
                            TextColor3 = Tokens.trailingLabelColor,
                            Text = props.trailing
                        }
                    end)
                }
            },
        }
    }
end

return Item