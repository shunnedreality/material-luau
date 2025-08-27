--!nocheck
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local TextService = game:GetService("TextService");

local MaterialRoblox = script.Parent.Parent;

local TextButtonTokens = require(MaterialRoblox.Tokens.TextButton);
local Ripple = require(MaterialRoblox.Components.Ripple);
local Fusion = require(MaterialRoblox.Parent.Fusion);

local Children = Fusion.Children;
local OnEvent = Fusion.OnEvent;

local function getPropFromVariant(
	scope: Fusion.Scope,
	variant: Fusion.UsedAs<"tonal" | "outlined" | "filled" | "text">,
	addOn: string
)
	local Tokens = TextButtonTokens();
	
	return scope:Computed(function(
		use: Fusion.Use
	)
		return Tokens[use(variant) .. addOn]
	end)
end

local function TextButton(
	scope: Fusion.Scope,
	props: {
		onClick: () -> ()?,
		text: Fusion.UsedAs<string>,
		variant: Fusion.UsedAs<"tonal" | "outlined" | "filled" | "text">?,
	}?
)
	local Tokens = TextButtonTokens();
	
	props = props or {};
	props.onClick = props.onClick or function() end;
	props.variant = props.variant or "text";
	props.text = props.text or "Hello world!";

	local textChangeCount = scope:Value(0);
	
	local width = scope:Computed(function(
		use: Fusion.Use
	)
		local getTextBoundsParams = Instance.new("GetTextBoundsParams");

		getTextBoundsParams.Text = use(props.text);
		getTextBoundsParams.Font = Tokens.labelText.font;
		getTextBoundsParams.Size = Tokens.labelText.fontSize;

		return TextService:GetTextBoundsAsync(getTextBoundsParams).X +
			Tokens.paddingLeft + Tokens.paddingRight;
	end)
	
	scope:Observer(props.text):onChange(function()
		textChangeCount:set(scope.peek(textChangeCount) + 1);
	end)
	
	return scope:New("TextButton") {
		Text = props.text,
		Size = scope:Tween(scope:Computed(function(
			use: Fusion.Use
		)
			return UDim2.fromOffset(use(width), Tokens.height)
		end), scope:Computed(function(
			use: Fusion.Use
		)	
			if use(textChangeCount) == 0 then
				return TweenInfo.new(0)
			else
				return TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
			end
		end)),
		AutoButtonColor = false,
		
		TextColor3 = getPropFromVariant(scope, props.variant, "TextColor");
		BackgroundColor3 = getPropFromVariant(scope, props.variant, "BackgroundColor");
		BackgroundTransparency = getPropFromVariant(scope, props.variant, "BackgroundTransparency");
		TextSize = Tokens.labelText.fontSize,
		FontFace = Tokens.labelText.font,
		
		[OnEvent "MouseButton1Click"] = props.onClick,
		
		[Children] = {
			Ripple(scope, {
				borderRadius = Tokens.shape
			}),
			
			scope:New("UICorner") {
				CornerRadius = Tokens.shape
			},
			
			scope:Computed(function(
				use: Fusion.Use
			)
				if use(props.variant) == "outlined" then
					return scope:New("UIStroke") {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = Tokens.outlinedStrokeColor,
						Thickness = 1
					}
				end
			end)
		}
	}
end

return TextButton;