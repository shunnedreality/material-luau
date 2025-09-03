local MaterialRoblox = script.Parent.Parent;

local MaterialColorUtilities = require(MaterialRoblox.MaterialColorUtilities);
local Migrations = require(MaterialRoblox.Utils.Migrations);

local function ColorBuilder(
	fromHex: string,
	mode: "light" | "dark"
)
	return Migrations.getPaletteFromTheme(
		MaterialColorUtilities.themeFromSourceColor(
			MaterialColorUtilities.argbFromHex(fromHex)
		),
		mode
	);
end

return ColorBuilder;