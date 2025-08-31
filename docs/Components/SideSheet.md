# Side sheet
Side sheets show secondary content anchored to the side of the screen

[Material Design 3 Documentation](https://m3.material.io/components/side-sheets)

!!! note

    Only modal side sheets are supported.

![Side sheet example](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flw8ygm30-3.png?alt=media&token=34b2374c-ed3b-4827-ac92-6c6e6edf6444)

## API
```typescript
SideSheet(
	scope: Fusion.Scope,
	props: {
		headline: Fusion.UsedAs<string>,
        [Fusion.Children]: { Instance },
		open: Fusion.Value<boolean>,
        inset: Fusion.UsedAs<boolean>?
	}
)
```

## Usage
```lua
local MaterialRoblox = require(MaterialRoblox);


MaterialRoblox.Components.SideSheet(scope, {
    open = true,
    inset = true,
    headline = "Provide feedback",

    [Fusion.Children] = {
        ...
    }
})
```