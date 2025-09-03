--!strict
--[[
	Copyright 2024 shunnedreality. This code is licensed under the MIT license.
]]

local GuiService = game:GetService("GuiService");
local TweenService = game:GetService("TweenService");

local MaterialRoblox = script.Parent.Parent;

local Fusion = require("../../Fusion");
local RippleTokens = require(MaterialRoblox.Tokens.Ripple);

local RIPPLE_IMAGE_ID = "rbxassetid://18741562417";
local PRESS_GROW_MS = .8;
local MINIMUM_PRESS_MS = .225;
local INITIAL_ORIGIN_SCALE = 0.2;
local PADDING = 10;
local SOFT_EDGE_MINIMUM_SIZE = 75;
local SOFT_EDGE_CONTAINER_RATIO = 0.35;

local Children = Fusion.Children;
local OnEvent = Fusion.OnEvent;
local Out = Fusion.Out;

local function endPressAnimation(
	scope: Fusion.Scope,
	currentAnimation: Fusion.Value<nil | Tween>,
	renderRootState: Fusion.Value<nil | CanvasGroup>
)
	local growAnimation = scope.peek(currentAnimation);
	local renderRoot = scope.peek(renderRootState) :: CanvasGroup;
	local surface = renderRoot:FindFirstChild("Surface") :: ImageLabel;

	task.wait(MINIMUM_PRESS_MS);

	if scope.peek(currentAnimation) == growAnimation then
		currentAnimation:set(TweenService:Create(
			surface,
			TweenInfo.new(.375),
			{
				ImageTransparency = 1
			}
		));
		
		(scope.peek(currentAnimation) :: Tween):Play();
	end
end

local function shouldTakeInset(
	renderRoot: GuiObject
)
	local screenGui = renderRoot:FindFirstAncestorOfClass("ScreenGui") :: ScreenGui;
	
	if screenGui then
		return screenGui.IgnoreGuiInset
	else
		return false
	end
end

local function determineRipplePosition(
	scope: Fusion.Scope,
	renderRoot: CanvasGroup,
	x: number,
	y: number
)
	local takeAwayInset = shouldTakeInset(renderRoot);
	
	local endPosition = {
		X = 0.5,
		Y = 0.5,
	};

	local _startPosition = Vector2.new(x, y) - renderRoot.AbsolutePosition;

	local startPosition = {
		X = _startPosition.X,
		Y = _startPosition.Y - (takeAwayInset and GuiService.TopbarInset.Height or 0)
	}

	return startPosition, endPosition;
end

local function determineRippleSize(
	scope: Fusion.Scope,
	renderRoot: CanvasGroup
)
	local height, width = renderRoot.AbsoluteSize.Y, renderRoot.AbsoluteSize.X;
	local maxDim = math.max(height, width);
	local softEdgeSize = math.max(
		SOFT_EDGE_CONTAINER_RATIO * maxDim,
		SOFT_EDGE_MINIMUM_SIZE
	);

	local initialSize = math.floor(maxDim * INITIAL_ORIGIN_SCALE);
	local hypotenuse = math.sqrt(width^2 + height^2);
	local maxRadius = hypotenuse + PADDING;

	local scale = (maxRadius + softEdgeSize) / initialSize;

	return initialSize, scale
end

local function startPressAnimation(
	scope: Fusion.Scope,
	currentAnimation: Fusion.Value<nil | Tween>,
	renderRootState: Fusion.Value<CanvasGroup | nil>,
	x: number,
	y: number
)	
	local Tokens = RippleTokens();
	
	local renderRoot = scope.peek(renderRootState) :: CanvasGroup;
	local surface = renderRoot:FindFirstChild("Surface") :: ImageLabel;

	local initialSize, scale = determineRippleSize(scope, renderRoot);
	local startPosition, endPosition = determineRipplePosition(scope, renderRoot, x, y);
	
	if scope.peek(currentAnimation) then
		(scope.peek(currentAnimation) :: Tween):Cancel();
	end

	surface.Size = UDim2.fromOffset(initialSize, initialSize);
	surface.Position = UDim2.fromOffset(startPosition.X, startPosition.Y);
	surface.ImageTransparency = Tokens.pressedTransparency;

	local Tween = TweenService:Create(
		surface,
		--[[TweenInfo.new(PRESS_GROW_MS, Enum.EasingStyle.Circular, 
			Enum.EasingDirection.Out),]]
		TweenInfo.new(PRESS_GROW_MS, Enum.EasingStyle.Exponential, 
			Enum.EasingDirection.Out),
		{
			Size = UDim2.fromOffset(initialSize * scale, initialSize * scale),
			Position = UDim2.fromScale(endPosition.X, endPosition.Y);
		}
	);

	Tween:Play();

	currentAnimation:set(Tween);
end

local function Ripple(
	scope: Fusion.Scope,
	props: {
		borderRadius: UDim
	}?
)
	local Tokens = RippleTokens();
	
	local isHovering = scope:Value(false);
	local currentAnimation: Fusion.Value<nil | Tween> = scope:Value(nil);
	local renderRoot: Fusion.Value<nil | CanvasGroup> = scope:Value(nil);

	return scope:New("Folder") {
		[Children] = {
			scope:New("CanvasGroup") {
				ClipsDescendants = true,
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Tokens.hoverColor,
				BackgroundTransparency = scope:Computed(function(
					use: Fusion.Use
				)
					if use(isHovering) then
						return Tokens.hoverTransparency
					else
						return 1
					end
				end),

				[OnEvent "InputBegan"] = function(
					input: InputObject
				)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						isHovering:set(true)
					elseif input.UserInputType == Enum.UserInputType.Touch or 
						input.UserInputType == Enum.UserInputType.MouseButton1 then
						startPressAnimation(
							scope, 
							currentAnimation, 
							renderRoot, 
							input.Position.X,
							input.Position.Y
						);
					end
				end,
				
				[OnEvent "InputEnded"] = function(
					input: InputObject
				)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						isHovering:set(false)
					elseif input.UserInputType == Enum.UserInputType.Touch or 
						input.UserInputType == Enum.UserInputType.MouseButton1 then
						endPressAnimation(scope, currentAnimation, renderRoot);
					end
				end,
				
				[Children] = {
					scope:New("UICorner") {
						CornerRadius = props and props.borderRadius or UDim.new(1, 0)
					},

					scope:New("ImageLabel") {
						Size = UDim2.fromOffset(0, 0),
						Image = RIPPLE_IMAGE_ID,
						Name = "Surface",
						BackgroundTransparency = 1,
						ImageTransparency = 1,
						ImageColor3 = Tokens.pressedColor,
						AnchorPoint = Vector2.new(.5, .5),

						[Out "Parent"] = renderRoot,

						[Children] = {
							scope:New("UICorner") {
								CornerRadius = props and props.borderRadius or UDim.new(1, 0)
							}
						}
					}
				}
			}
		}
	}
end

return Ripple