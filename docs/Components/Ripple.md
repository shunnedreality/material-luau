# `MaterialRoblox.Components.Ripple`
### A ripple overlay signifies a pressed state
[Material Design 3 Documentation](https://m3.material.io/foundations/interaction/states/applying-states#c3690714-b741-492d-97b0-5fc1960e43e6)

![Ripple example](https://material-web.dev/components/images/ripple/hero.gif)

## API
```typescript
Ripple(
	scope: Fusion.Scope,
	props: {
		borderRadius: UDim
	}?
)
```

## Usage
```lua
local MaterialRoblox = require(MaterialRoblox);

MaterialRoblox.Components.Ripple(scope, {
    borderRadius = UDim.new(1, 0)
})
```