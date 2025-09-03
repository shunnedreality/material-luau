# ProvideMaterial

Provides a MaterialTheme

## Example
```lua
local MaterialTheme = {
    color = ColorBuilder(hex, mode),
    typography = MaterialTypography(fontId)
}

--This will be styled using the default theme
MaterialRoblox.Components.TextButton(...);

local ThemedButton = MaterialRoblox.Utils.ProvideMaterial(MaterialTheme, MaterialRoblox.Components.TextButton);

ThemedButton(scope, {
    ...
})
```