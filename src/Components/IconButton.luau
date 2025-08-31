--!nonstrict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local Fusion = require(MaterialRoblox.Parent.Fusion);
local Icon = require(MaterialRoblox.Components.Icon);
local Ripple = require(MaterialRoblox.Components.Ripple);

local OnEvent = Fusion.OnEvent;
local Children = Fusion.Children;

local function IconButton(
	scope: Fusion.Scope,
	props: {
		icon: Fusion.UsedAs<string>,
        onClick: () -> ()?
	}
)	
	return scope:New("ImageButton") {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(40, 40),
        ImageTransparency = 1,

        [OnEvent "MouseButton1Click"] = props.onClick,

        [Children] = {
            Ripple(scope),

            scope:Hydrate(Icon(scope, {
                icon = props.icon
            })) {
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5)
            }
        }
    }
end

return IconButton;