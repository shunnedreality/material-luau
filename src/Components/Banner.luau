--!nonstrict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local Fusion = require(MaterialRoblox.Parent.Fusion);
local BannerTokens = require(MaterialRoblox.Tokens.Banner);
local TextButton = require(MaterialRoblox.Components.TextButton);

local Children = Fusion.Children;
local Out = Fusion.Out;

local function showComputed(
	scope: Fusion.Scope,
	value: Fusion.Value<any?>,
	createObject: () -> Instance
)
	local object: nil | Instance;

	return scope:Computed(function(
		use: Fusion.Use
	)
		if use(value) then
			if object then
				return object
			else
				object = createObject();

				return object;
			end
		end
	end)
end

local function Banner(
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
	local Tokens = BannerTokens();

	local BannerAbsoluteSize = scope:Value(Vector2.new(0, 0));

	return scope:New("Frame") {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = scope:Computed(function(
			use: Fusion.Use
		)
			return UDim2.new(1, 0, 0, use(BannerAbsoluteSize).Y)
		end),
		ClipsDescendants = true,

		[Children] = {
			scope:New("Frame") {
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Tokens.containerColor,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				AnchorPoint = Vector2.new(0, 1),

				[Out "AbsoluteSize"] = BannerAbsoluteSize,

				Position = scope:Tween(
					scope:Computed(function(
						use: Fusion.Use
					)
						if use(props.open) then
							return UDim2.fromScale(0, 1)
						else
							return UDim2.fromScale(0, 0)
						end
					end),
					TweenInfo.new(.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				),
				
				[Children] = {
					scope:New("UIPadding") {
						PaddingLeft = UDim.new(0, 16),
						PaddingRight = UDim.new(0, 8),
						PaddingTop = UDim.new(0, 16),
						PaddingBottom = UDim.new(0, 8)
					},

					scope:New("UIListLayout") {
						FillDirection = Enum.FillDirection.Horizontal,
						Wraps = true,
						SortOrder = Enum.SortOrder.LayoutOrder,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Bottom,
						VerticalFlex = Enum.UIFlexAlignment.Fill
					},

					scope:New("Frame") {
						Size = UDim2.fromScale(0, 0),
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,

						[Children] = {
							scope:New("UIListLayout") {
								FillDirection = Enum.FillDirection.Vertical,
								SortOrder = Enum.SortOrder.LayoutOrder,
								HorizontalAlignment = Enum.HorizontalAlignment.Left,
								VerticalAlignment = Enum.VerticalAlignment.Top,
								Padding = UDim.new(0, 2)
							},

							scope:New("UIPadding") {
								PaddingRight = UDim.new(0, 8),
								PaddingBottom = UDim.new(0, 8)
							},

							showComputed(scope, props.title, function()
								return scope:New("TextLabel") {
									Text = props.title,
									TextSize = Tokens.labelFontSize,
									FontFace = Tokens.titleFont,
									Size = UDim2.fromScale(0, 0),
									BackgroundTransparency = 1,
									AutomaticSize = Enum.AutomaticSize.XY,
									TextWrapped = true,
									TextColor3 = Tokens.titleColor,
									TextXAlignment = Enum.TextXAlignment.Left
								}
							end),

							scope:New("TextLabel") {
								Text = props.body,
								TextSize = Tokens.labelFontSize,
								FontFace = Tokens.bodyFont,
								Size = UDim2.fromScale(0, 0),
								BackgroundTransparency = 1,
								AutomaticSize = Enum.AutomaticSize.XY,
								TextWrapped = true,
								TextTruncate = Enum.TextTruncate.AtEnd,
								TextColor3 = Tokens.bodyColor,
								TextXAlignment = Enum.TextXAlignment.Left
							}
						}
					},

					scope:New("Frame") {
						Size = UDim2.fromScale(0, 1),
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,

						[Children] = {
							scope:New("UIFlexItem") {
								FlexMode = Enum.UIFlexMode.Fill
							},

							scope:New("UIListLayout") {
								FillDirection = Enum.FillDirection.Horizontal,
								SortOrder = Enum.SortOrder.LayoutOrder,
								HorizontalAlignment = Enum.HorizontalAlignment.Right,
								VerticalAlignment = Enum.VerticalAlignment.Bottom,
								VerticalFlex = Enum.UIFlexAlignment.SpaceBetween
							},

							scope:ForValues(props.actions, function(
								_,
								_,
								button
							)
								return TextButton(scope, {
									variant = "text",
									text = button.label,
									onClick = button.onClick
								})
							end)
						}
					}
				}
			}
		}
	}
end

return Banner