# TextButton
Buttons prompt most actions in a UI

[Material Design 3 Documentation](https://m3.material.io/components/buttons/overview)

![TextButton example](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gleigh-26.png?alt=media&token=f6c42433-0e5d-4d96-b76e-58abe238f037)

## API
```typescript
TextButton(
	scope: Fusion.Scope,
	props: {
		onClick: () -> ()?,
		text: Fusion.UsedAs<string>,
		variant: Fusion.UsedAs<"tonal" | "outlined" | "filled" | "text">,
	}?
)
```

## Usage
```lua
local MaterialRoblox = require(MaterialRoblox);

MaterialRoblox.Components.TextButton(scope, {
    text = "Add to cart",
    onClick = addToCart
})
```