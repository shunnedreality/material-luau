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

MaterialRoblox.Utils.ProvideMaterial(MaterialTheme, function()
    --This will be styled using the given theme, as well as any children or other elements in this function
    MaterialRoblox.Components.TextButton(...);
end)
```