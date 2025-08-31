# ProvideMaterial

Provides a MaterialTheme

## Example
```lua
local MaterialTheme = {
    color = MaterialColorUtilities.default:light(Color3.new(...)),
    typography = MaterialTypography(fontId)
}

--This will be styled using the default theme
MaterialRoblox.Components.TextButton(...);

local ThemedButton = MaterialRoblox.Utils.ProvideMaterial(MaterialTheme, MaterialRoblox.Components.TextButton);

ThemedButton(scope, {
    ...
})
```