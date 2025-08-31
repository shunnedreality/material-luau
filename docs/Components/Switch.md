# Switch
Switches toggle the selection of an item on or off

[Material Design 3 Documentation](https://m3.material.io/components/switch)

![Switch example](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwa9phy3-GM3-Components-Switch-1-v01.mp4?alt=media&token=87034bac-0c9d-4b3f-91e4-29c02c97964d)

## API
```typescript
Switch(
	scope: Fusion.Scope,
	props: {
		active: Fusion.Value<boolean>
	}
)
```

## Usage
```lua
local MaterialRoblox = require(MaterialRoblox);

MaterialRoblox.Components.Switch(scope, {
    active = scope:Value(false)
})
```