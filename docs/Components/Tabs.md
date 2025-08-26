# `MaterialRoblox.Components.Tabs`
### Tabs organize content across different screens and views
[Material Design 3 Documentation](https://m3.material.io/components/tabs/overview)

![Tabs example](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm2k0hhto-1.png?alt=media&token=faff99ee-2899-443c-af57-12c65d59fbff)

## API
```typescript
Tabs(
	scope: Fusion.Scope,
	props: {
		renderTabs: () -> { Instance }
	}
)
```

## Usage
```lua
local MaterialRoblox = require(MaterialRoblox);

MaterialRoblox.Components.Tabs(scope, {
    renderTabs = function()
		return {
			MaterialRoblox.Components.TabItem(scope, {
				label = "Video",
				icon = "video"
			}),
			MaterialRoblox.Components.TabItem(scope, {
				label = "Photos",
				icon = "photo"
			})
		}
	end,
})
```