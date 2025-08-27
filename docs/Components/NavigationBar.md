# Navigation Bar
Navigation bars let people switch between UI views on smaller devices

[Material Design 3 Documentation](https://m3.material.io/styles/icons)

![Icons example](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmalnqdza-02.png?alt=media&token=a7e4f1a8-0547-42b2-81d1-c4346b1915db)

## API
```typescript
NavigationBar(
	scope: Fusion.Scope,
	props: {
		renderTabs: () -> { Instance }
	}
)
```

## Usage
```lua
local MaterialRoblox = require(MaterialRoblox);


MaterialRoblox.Components.NavigationBar(scope, {
    renderTabs = function()
		return {
			MaterialRoblox.Components.NavigationTab(scope, {
				label = "Home",
				icon = "home"
			}),
			MaterialRoblox.Components.NavigationTab(scope, {
				label = "Store",
				icon = "shop"
			})
		}
	end,
})
```