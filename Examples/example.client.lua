local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ScreenGui = script.Parent;

local Fusion = require(ReplicatedStorage.Packages.Fusion);
local MaterialRoblox = require(ReplicatedStorage.Packages.MaterialRoblox);

local Scope = Fusion.scoped(Fusion);

local dialogOpen = Scope:Value(false);
local bannerOpen = Scope:Value(false);
local sideSheetOpen = Scope:Value(false);

local ThemedTextButton = MaterialRoblox.Utils.ProvideMaterial({
	color = MaterialRoblox.Utils.MaterialColorUtilities.default:light(Color3.fromHex("#008000"))
}, MaterialRoblox.Components.TextButton);

local Example = Scope:New("ScrollingFrame") {
	Parent = ScreenGui,
	Size = UDim2.fromScale(1, 1),
	CanvasSize = UDim2.fromScale(1, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,

	[Fusion.Children] = {
		Scope:New("UIListLayout") {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8)
		},

		MaterialRoblox.Components.Banner(Scope, {
			body = "Couldn't connect to the internet.",
			open = bannerOpen,
			actions = {
				{
					label = "Dismiss",
					onClick = function()
						bannerOpen:set(false)
					end,
				}
			}
		}),

		MaterialRoblox.Components.TextButton(Scope, {
			text = "Open dialog",
			variant = "filled",
			onClick = function()
				dialogOpen:set(true)
			end,
		}),

		MaterialRoblox.Components.NavigationBar(Scope, {
			renderTabs = function()
				return {
					MaterialRoblox.Components.NavigationTab(Scope, {
						icon = "home",
						label = "Home"
					}),
					MaterialRoblox.Components.NavigationTab(Scope, {
						icon = "shopping_bag",
						label = "Store"
					})
				}
			end,
		}),

		MaterialRoblox.Components.TextButton(Scope, {
			text = "Open banner",
			variant = "filled",
			onClick = function()
				bannerOpen:set(true)
			end,
		}),

		MaterialRoblox.Components.Tabs(Scope, {
			renderTabs = function()
				return {
					MaterialRoblox.Components.TabItem(Scope, {
						icon = "library_music",
						label = "Music"
					}),
					MaterialRoblox.Components.TabItem(Scope, {
						icon = "video_library",
						label = "Videos"
					})
				}
			end,
		}),

		MaterialRoblox.Components.Icon(Scope, {
			icon = "account_circle",
			fill = true
		}),

		MaterialRoblox.Components.TextButton(Scope, {
			variant = "tonal",
			text = "Add item to cart"
		}),

		MaterialRoblox.Components.Switch(Scope, {
			active = Scope:Value(false)
		}),

		MaterialRoblox.Components.TextButton(Scope, {
			text = "Open side sheet",
			onClick = function()
				sideSheetOpen:set(true)
			end,
		}),
		
		ThemedTextButton(Scope, {
			text = "Themed text button",
			variant = "tonal"
		})
	}
}

local Button = ThemedTextButton(Scope, {
	text = "Open menu",
	variant = "tonal",
})

Button.Parent = Example;

local Menu = MaterialRoblox.Components.Menu(Scope, {
	attachTo = Button,
	
	[Fusion.Children] = {
		MaterialRoblox.Components.Item(Scope, {
			label = "Profile",
		}),
		MaterialRoblox.Components.Item(Scope, {
			label = "Settings"
		})
	}
})

Menu.Parent = ScreenGui;

MaterialRoblox.Components.Dialog(Scope, {
	headline = "Dialog example",
	body = "Dialog body",
	open = dialogOpen,
	buttons = {
		{
			label = "OK",
			onClick = function()
				dialogOpen:set(false)
			end				
		}
	}
}).Parent = ScreenGui;

MaterialRoblox.Components.SideSheet(Scope, {
	open = sideSheetOpen,
	headline = "Submit feedback",

	[Fusion.Children] = {
		
	}
}).Parent = ScreenGui

