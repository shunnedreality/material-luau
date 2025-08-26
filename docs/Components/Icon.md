# `MaterialRoblox.Components.Icon`
### Icons are small symbols to easily identify actions and categories
[Material Design 3 Documentation](https://m3.material.io/styles/icons)

![Icons example](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fm3%2Fimages%2Fm0zqu7hk-GM3-Styles-Icons-GoogleSymbols-1-v01.mp4?alt=media&token=9c9fe13f-1378-4117-947d-02a776041d6c)

## API
```typescript
Icon(
    scope: Fusion.Scope,
	props: {
		icon: string,
		fill: Fusion.UsedAs<boolean>?
	}
)
```

## Usage
```lua
local MaterialRoblox = require(MaterialRoblox);


MaterialRoblox.Components.Icon(scope, {
    icon = "home",
    fill = true
})
```