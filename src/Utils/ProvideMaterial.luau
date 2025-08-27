--!strict

local MaterialRoblox = script.Parent.Parent;

local Theming = require(MaterialRoblox.Utils.Theming);

local function provideMaterial(
	theme
)
	return function(...)
		return Theming:is(theme):during(...)
	end
end

return provideMaterial