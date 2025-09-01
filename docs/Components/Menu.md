# Menu
Menus display a list of choices on a temporary surface

[Material Design 3 Documentation](https://m3.material.io/components/menus)

![Menu example](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp04ejo-3.png?alt=media&token=268ec2e9-04a5-438c-88f0-02a867e81e6c)

## API
```typescript
Menu(
    scope: Fusion.Scope,
    props: {
        open: Fusion.Value<boolean>?,
        attachTo: GuiButton,
        [typeof(Children)]: { Instance }
    }
)
```

## Usage
```lua
local MaterialRoblox = require(MaterialRoblox);

local Button = MaterialRoblox.Components.TextButton(Scope, {
	text = "Open menu",
	variant = "tonal"
})

MaterialRoblox.Components.Menu(scope, {
	attachTo = Button,
	
	[Fusion.Children] = {
		MaterialRoblox.Components.Item(scope, {
			label = "Revert",
		}),
		MaterialRoblox.Components.Item(scope, {
			icon = "settings",
			label = "Settings",
		}),
        MaterialRoblox.Components.Item(scope, {
			label = "Send Feedback",
		}),
        MaterialRoblox.Components.Item(scope, {
			label = "Help",
		}),
	}
})
```