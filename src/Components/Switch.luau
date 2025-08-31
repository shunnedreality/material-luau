--!nonstrict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local Fusion = require(MaterialRoblox.Parent.Fusion);
local SwitchTokens = require(MaterialRoblox.Tokens.Switch);
local showComputed = require(MaterialRoblox.Utils.ShowComputed);

local Children = Fusion.Children;
local OnEvent = Fusion.OnEvent;

local function Switch(
	scope: Fusion.Scope,
	props: {
		active: Fusion.Value<boolean>
	}
)	
	local Tokens = SwitchTokens();

    local isHovering = scope:Value(false);
    local isPressed = scope:Value(false);

    return scope:New("ImageButton") {
        Size = UDim2.fromOffset(Tokens.containerWidth, Tokens.containerHeight),
        BackgroundColor3 = scope:Tween(
            scope:Computed(function(
                use: Fusion.Use
            )
                if use(props.active) then
                    return Tokens.trackColorSelected
                else
                    return Tokens.trackColorUnselected
                end
            end),
            TweenInfo.new(0.1)
        ),
        ImageTransparency = 1,

        [OnEvent "InputBegan"] = function(
            input: InputObject
        )
            local inputType = input.UserInputType;

            if inputType == Enum.UserInputType.MouseMovement then
                isHovering:set(true)
            elseif inputType == Enum.UserInputType.MouseButton1 or 
                inputType == Enum.UserInputType.Touch then

                isPressed:set(true);
            end
        end,

        [OnEvent "InputEnded"] = function(
            input: InputObject
        )
            local inputType = input.UserInputType;

            if inputType == Enum.UserInputType.MouseMovement then
                isHovering:set(false)
            elseif inputType == Enum.UserInputType.MouseButton1 or 
                inputType == Enum.UserInputType.Touch then

                isPressed:set(false);
            end
        end,

        [OnEvent "MouseButton1Click"] = function()
            props.active:set(not Fusion.peek(props.active))
        end,

        [Children] = {
            scope:New("UICorner") {
                CornerRadius = UDim.new(1, 0)
            },

            scope:New("Frame") {
                Size = UDim2.fromOffset(40, 40),
                BackgroundColor3 = Tokens.stateLayerColor,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = scope:Spring(
                    scope:Computed(function(
                        use: Fusion.Use
                    )
                        if use(props.active) then
                            return UDim2.new(1, -16, 0.5, 0)
                        else
                            return UDim2.new(0, 16, 0.5, 0)
                        end
                    end),
                    25,
                    .9
                ),
                BackgroundTransparency = scope:Computed(function(
                    use: Fusion.Use
                )
                    if use(isHovering) then
                        return Tokens.stateLayerTransparency
                    else
                        return 1
                    end
                end),

                [Children] = {
                    scope:New("UICorner") {
                        CornerRadius = UDim.new(1, 0)
                    },

                    scope:New("Frame") {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = scope:Spring(
                            scope:Computed(function(
                                use: Fusion.Use
                            )
                                if use(isPressed) then
                                    return UDim2.fromOffset(Tokens.handlePressedSize, Tokens.handlePressedSize)
                                elseif use(props.active) then
                                    return UDim2.fromOffset(Tokens.handleSelectedSize, Tokens.handleSelectedSize)
                                else
                                    return UDim2.fromOffset(Tokens.handleUnselectedSize, Tokens.handleUnselectedSize)
                                end
                            end),
                            25,
                            .9
                        ),
                        BackgroundColor3 = scope:Computed(function(
                            use: Fusion.Use
                        )
                            local isActive = use(props.active);

                            if use(isHovering) then
                                if isActive then
                                    return Tokens.handleSelectedHoverColor
                                else
                                    return Tokens.handleUnselectedHoverColor
                                end
                            else
                                if isActive then
                                    return Tokens.handleColorSelected
                                else
                                    return Tokens.handleColorUnselected
                                end
                            end
                        end),

                        [Children] = {
                            scope:New("UICorner") {
                                CornerRadius = UDim.new(1, 0)
                            }
                        }
                    },
                }
            },

            showComputed(scope, scope:Computed(function(
                use: Fusion.Use
            )
                return not use(props.active)
            end), function()
                return scope:New("UIStroke") {
                    Thickness = 1.5,
                    Color = Tokens.trackUnselectedOutlineColor
                }
            end)
        }
    }
end

return Switch;