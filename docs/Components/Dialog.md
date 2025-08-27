# Dialog
Dialogs provide important prompts in a user flow

[Material Design 3 Documentation](https://m3.material.io/components/dialogs)

![Dialog example](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfcqhr-03_do.png?alt=media&token=3655fc78-54b9-44f6-a239-d93670bb087e)

## API
```typescript
Dialog(
    scope: Fusion.Scope,
    props: {
		headline: Fusion.UsedAs<string>,
		body: Fusion.UsedAs<string>?,
		buttons: Fusion.UsedAs<{
			{ 
				label: string,
				onClick: () -> ()
			}	
		}>,
		open: Fusion.UsedAs<boolean>
	}
)
```

## Usage
```lua
local MaterialRoblox = require(MaterialRoblox);


MaterialRoblox.Components.Dialog(scope, {
    headline = "Delete selected images?",
    body = "Images will be permanently removed from your account forever",
    buttons = {
        {
            label = "Cancel",
            onClick = function()
                return
            end
        },
        {
            label = "Delete",
            onClick = function()
                return
            end
        }
    },
    open = true
})
```