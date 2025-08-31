--!strict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local Fusion = require(MaterialRoblox.Parent.Fusion);

local function showComputed(
	scope: Fusion.Scope,
	value: Fusion.Value<any?>,
	createObject: () -> Instance
)
	local object: nil | Instance;

	return scope:Computed(function(
		use: Fusion.Use
	)
		if use(value) then
			if object then
				return object
			else
				object = createObject();

				return object;
			end
		end
	end)
end

return showComputed