--!nocheck
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local Fusion = require(MaterialRoblox.Parent.Fusion);
local MenuTokens = require(MaterialRoblox.Tokens.Menu);
local showComputed = require(MaterialRoblox.Utils.ShowComputed);

local Children = Fusion.Children;
local OnEvent = Fusion.OnEvent;

local SCREEN_INSET = 16;
local MENU_TOTAL_VERTICAL_PADDING = 16;

local function getTargetPosition(
    attachTo: GuiButton,
    targetHeight: number
): ("up" | "down", Vector2)
    local absolutePosition = attachTo.AbsolutePosition;
    local absoluteSize = attachTo.AbsoluteSize;

    local screen = workspace.CurrentCamera.ViewportSize;

    local maxHeight = screen.Y - SCREEN_INSET;

    local X = math.max(SCREEN_INSET, math.min(screen.X - SCREEN_INSET, absolutePosition.X))
    local flipDownY = math.max(SCREEN_INSET, math.min(screen.Y - SCREEN_INSET, absolutePosition.Y + absoluteSize.Y));
    local flipUpY = math.max(SCREEN_INSET, math.min(screen.Y - SCREEN_INSET, absolutePosition.Y));

    if flipDownY + SCREEN_INSET + targetHeight > maxHeight then
        return "up", Vector2.new(X, flipUpY)
    else
        return "down", Vector2.new(X, flipDownY)
    end
end

local function Menu(
    scope: Fusion.Scope,
    props: {
        open: Fusion.Value<boolean>?,
        attachTo: GuiButton,
        [typeof(Children)]: { Instance }
    }
)
    local Tokens = MenuTokens();

    local open = props.open or scope:Value(false);
    local menuPostion = scope:Value(UDim2.fromOffset(0, 0));
    local menuAnchorPoint = scope:Value(Vector2.new(0, 0));
    local menuHeight = scope:Computed(function(
        use: Fusion.Use
    )
        local menuChildren = use(props[Children]);
        local height = 0;

        for _, child in menuChildren do
            height += child.AbsoluteSize.Y
        end

        return height + MENU_TOTAL_VERTICAL_PADDING
    end)

    table.insert(scope, props.attachTo.MouseButton1Click:Connect(function()
        open:set(true);

        local menuHeight = Fusion.peek(menuHeight);

        local flip, targetPostion = getTargetPosition(props.attachTo, menuHeight);

        menuPostion:set(UDim2.fromOffset(targetPostion.X, targetPostion.Y));

        if flip == "up" then
            menuAnchorPoint:set(Vector2.new(0, 1))
        else
            menuAnchorPoint:set(Vector2.new(0, 0))
        end
    end));

    return scope:New("Frame") {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,

        [Children] = {
            showComputed(scope, open, function()
                return scope:New("ImageButton") {
                    Modal = true,
                    BackgroundTransparency = 1,
                    ImageTransparency = 1,
                    Size = UDim2.fromScale(1, 1),

                    [OnEvent "MouseButton1Click"] = function()
                        open:set(false);
                    end
                }
            end),

            scope:New("CanvasGroup") {
                Size = scope:Computed(function(
                    use: Fusion.Use
                )
                    return UDim2.fromOffset(112, use(menuHeight))
                end),
                Position = menuPostion,
                BackgroundColor3 = Tokens.containerColor,
                AutomaticSize = Enum.AutomaticSize.X,
                AnchorPoint = menuAnchorPoint,
                ZIndex = 2,
                Visible = open,

                GroupTransparency = scope:Tween(
                    scope:Computed(function(
                        use: Fusion.Use
                    )
                        if use(open) then
                            return 0
                        else
                            return 1
                        end
                    end),
                    TweenInfo.new(.2)
                ),

                [Children] = {
                    scope:New("UISizeConstraint") {
                        MinSize = Vector2.new(112, 0),
                        MaxSize = Vector2.new(280, math.huge)
                    },

                    scope:New("UICorner") {
                        CornerRadius = Tokens.shape
                    },

                    scope:New("UIScale") {
                        Scale = scope:Spring(
                            scope:Computed(function(
                                use: Fusion.Use
                            )
                                if use(open) then
                                    return 1
                                else
                                    return .9
                                end
                            end),
                            50,
                            1
                        ),
                    },

                    scope:New("UIPadding") {
                        PaddingTop = Tokens.verticalPadding,
                        PaddingBottom = Tokens.verticalPadding
                    },

                    scope:New("UIListLayout") {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    },

                    scope:ForValues(props[Children], function(
                        _,
                        _,
                        value: GuiButton
                    )
                        return scope:Hydrate(value) {
                            [OnEvent "MouseButton1Click"] = function()
                                open:set(false)
                            end
                        }
                    end)
                }
            }
        }
    }
end

return Menu