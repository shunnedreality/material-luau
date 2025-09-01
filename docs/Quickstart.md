# Installing MaterialRoblox

Download MaterialRoblox from the [Releases page on Github](https://github.com/shunnedreality/material-roblox/releases).
Alternatively, download using wally (`shunnedreality/material-roblox`)

# Using MaterialRoblox

Import the module, then each component or utility is accessible by indexing `MaterialRoblox.Components` or `MaterialRoblox.Utils`.

```lua
local MaterialRoblox = require(Packages.MaterialRoblox);

MaterialRoblox.Components.Icon {
    icon = "home"
}
```

[Example code](https://github.com/shunnedreality/material-roblox/tree/main/Examples/example.client.lua)