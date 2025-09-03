# ColorBuilder

Provides a [Material Color](https://m3.material.io/styles/color/roles) theme. Refer to M3 guidance for colors

![Material Color example](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fly2ms4t2-1.png?alt=media&token=722d8f55-45a4-4340-98ad-9ae1aa71b7ae)

## Example
```lua
local hex = "#FFFFF";
local mode: "light" | "dark" = "light";
ColorBuilder(hex, mode);
```