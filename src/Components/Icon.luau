--!nonstrict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local Fusion = require(MaterialRoblox.Parent.Fusion);
local Icons = require(MaterialRoblox.Utils.Icons);

local function Icon(
	scope: Fusion.Scope,
	props: {
		icon: Fusion.UsedAs<string>,
		fill: Fusion.UsedAs<boolean>?
	}
)	
	return scope:New("ImageLabel") {
		Size = UDim2.fromOffset(24, 24),
		Image = scope:Computed(function(
			use: Fusion.Use
		)
			return Icons
				[use(props.fill or false) and "filled" or "outlined"]
				[props.icon];
		end),
		BackgroundTransparency = 1
	}
end

return Icon;