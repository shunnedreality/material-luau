# Icon buttons
Icon buttons help people take minor actions with one tap

[Material Design 3 Documentation](https://m3.material.io/components/icon-buttons)

!!! note

    Only plain icon buttons are supported.

![Side sheet example](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0c1j2b9-5.png?alt=media&token=244efcd1-5b55-496d-a4bb-9bc97593fbd9)

## API
```typescript
IconButton(
	scope: Fusion.Scope,
	props: {
		icon: Fusion.UsedAs<string>,
        onClick: () -> ()?
	}
)
```

## Usage
```lua
local MaterialRoblox = require(MaterialRoblox);


MaterialRoblox.Components.IconButton(scope, {
    icon = "favorites",
    onClick = function()
        addToFavorites();
    end
})
```