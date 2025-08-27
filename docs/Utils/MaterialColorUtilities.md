# MaterialColorUtilities

Provides a [Material Color](https://m3.material.io/styles/color/roles) theme. Refer to M3 guidance for colors

![Material Color example](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fly2ms4t2-1.png?alt=media&token=722d8f55-45a4-4340-98ad-9ae1aa71b7ae)

## Example
```lua
--Create a light color scheme: 
MaterialColorUtilities.default:light(Color3.new(0, 0, 0))
--Create a dark color scheme: 
MaterialColorUtilities.default:dark(Color3.new(0, 0, 0))
--Create a CustomColorGroup (a scheme extension based on one color): 
MaterialColorUtilities.CustomColorGroup:light(color3)
MaterialColorUtilities.CustomColorGroup:dark(color3
```