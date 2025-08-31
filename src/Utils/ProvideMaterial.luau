--!strict

local MaterialRoblox = script.Parent.Parent;

local Theming = require(MaterialRoblox.Utils.Theming);
local DefaultTheme = require(MaterialRoblox.Utils.DefaultTheme);

local function provideMaterial(
	theme: any,
	callback: () -> ()
)
	return function(...)
		if not theme.color then
			theme.color = DefaultTheme.color
		end 

		if not theme.typography then
			theme.typography = DefaultTheme.typography
		end

		return Theming:is(theme):during(callback, ...)
	end
end

return provideMaterial