# Dialog
Banners display prominent messages and related optional actions

[Material Design 2 Documentation](https://m2.material.io/components/dialogs)

!!! note

    While Banners are commonly used by Google in Material Design 3, there is no updated documentation.

![Dialog example](https://media.discordapp.net/attachments/1076197552904491108/1253747422983753789/Screenshot_2024-06-21_at_9.24.31_AM.png?ex=68b325c7&is=68b1d447&hm=aca150eb7cfd656fdc3a28b07e0bbfefa5a50d29de37012a872028a187a2c0c4&=&width=1266&height=1110)

## API
```typescript
Banner(
	scope: Fusion.Scope,
	props: {
		open: Fusion.UsedAs<boolean>,
		title: Fusion.UsedAs<string>?,
		body: Fusion.UsedAs<string>,
		actions: Fusion.UsedAs<{
			{ 
				label: string,
				onClick: () -> ()
			}	
		}>,
	}
)
```

## Usage
```lua
local MaterialRoblox = require(MaterialRoblox);


MaterialRoblox.Components.Banner(scope, {
    body = "You're browsing offline",
    actions = {
        {
            label = "Dismiss",
            onClick = function()
                return
            end
        }
    },
    open = true
})
```