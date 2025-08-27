--!nocheck
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local MaterialRoblox = script.Parent.Parent;

local DialogTokens = require(MaterialRoblox.Tokens.Dialog);
local TextButton = require(MaterialRoblox.Components.TextButton);
local Fusion = require(MaterialRoblox.Parent.Fusion);
local Display = require(MaterialRoblox.Utils.Display);
local Fade = require(MaterialRoblox.Utils.Fade);

local Children = Fusion.Children;
local Out = Fusion.Out;

local function DialogElement(
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
	local Tokens = DialogTokens();
	
	local screenWidth = scope:Value(Display.getDisplayWidth());
	local currentGui: Fusion.Value<Frame | nil> = scope:Value(nil)
	
	table.insert(scope, Display.onDisplayChange(function()
		screenWidth:set(Display.getDisplayWidth());
	end));
	
	--Run after GUI has been defined
	scope:Observer(currentGui):onChange(function()
		Fade.FadeOut(scope.peek(currentGui), 0)
		scope:Observer(props.open):onChange(function()
			if scope.peek(props.open) then
				Fade.FadeIn(scope.peek(currentGui), .3)
			else
				Fade.FadeOut(scope.peek(currentGui), .3)
			end
		end)
	end)
	
	return scope:New("Frame") {
		Name = "Scrim",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Tokens.scrimColor,
		BackgroundTransparency = scope:Tween(
			scope:Computed(function(
				use: Fusion.Use
			)
				if use(props.open) then
					return Tokens.scrimTransparency
				else
					return 1
				end
			end),
			TweenInfo.new(.1)
		),
		
		[Children] = {
			scope:New("Frame") {
				AnchorPoint = Vector2.new(.5, .5),
				Position = UDim2.fromScale(.5, .5),
				AutomaticSize = Enum.AutomaticSize.XY,
				Size = UDim2.fromScale(0, 0),
				BackgroundColor3 = Tokens.containerColor,

				[Children] = {
					scope:New("UICorner") {
						[Out "Parent"] = currentGui,
						CornerRadius = Tokens.cornerRadius
					},

					scope:New("UIScale") {
						Scale = scope:Tween(
							scope:Computed(function(
								use: Fusion.Use
							)
								return if use(props.open) then 1 else .8
							end),
							TweenInfo.new(
								.3, 
								Enum.EasingStyle.Exponential, 
								Enum.EasingDirection.Out
							)
						)
					},

					scope:New("UISizeConstraint") {
						MaxSize = scope:Computed(function(
							use: Fusion.Use
						)
							return Vector2.new(
								math.min(560, (use(screenWidth) - 48)),
								math.min(560, (use(screenWidth) - 48))
							);
						end)
					},

					scope:New("UIPadding") {
						PaddingBottom = UDim.new(0, 16),
						PaddingTop = UDim.new(0, 24),
						PaddingLeft = UDim.new(0, 24),
						PaddingRight = UDim.new(0, 16)
					},

					scope:New("UIListLayout") {
						Padding = UDim.new(0, 16),
						SortOrder = Enum.SortOrder.LayoutOrder
					},

					scope:New("TextLabel") {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, -8, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = props.headline,
						FontFace = Tokens.headlineText.font,
						TextSize = Tokens.headlineText.fontSize,
						TextColor3 = Tokens.headlineColor,
						TextWrapped = true,
						LayoutOrder = 0
					},

					scope:New("TextLabel") {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, -8, 0, 0),
						TextXAlignment = Enum.TextXAlignment.Left,
						AutomaticSize = Enum.AutomaticSize.Y,
						Text = props.body,
						FontFace = Tokens.bodyText.font,
						TextSize = Tokens.bodyText.fontSize,
						TextColor3 = Tokens.bodyColor,
						TextWrapped = true,
						TextTruncate = Enum.TextTruncate.AtEnd,
						LayoutOrder = 1
					},

					scope:New("Frame") {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 40),
						LayoutOrder = 2,

						[Children] = {
							scope:New("UIListLayout") {
								--Padding = UDim.new(0, 8),
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Right
							},

							scope:ForValues(props.buttons, function(
								use: Fusion.Use,
								scope: Fusion.Scope,
								button: {
									label: string,
									onClick: () -> ()
								}
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
	};
end

return DialogElement