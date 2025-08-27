local module = {}

local TweenService = game:GetService("TweenService")

local function GetProperty(Object)
	if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
		return "TextTransparency"
	elseif Object:IsA("ViewportFrame") or Object:IsA("ImageButton") or Object:IsA("ImageLabel") then
		return "ImageTransparency"
	elseif Object:IsA("Frame") then
		return "BackgroundTransparency"
	elseif Object:IsA("ScrollingFrame") then
		return "ScrollBarImageTransparency"
	end

    return;
end

function module.FadeIn(Object, FadeTime)
	local TI = TweenInfo.new(FadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local Table = Object:GetDescendants()
	Table[#Table + 1] = Object
	for i,v in pairs(Table) do
		local Property = GetProperty(v)

		if Property then
			if v:FindFirstChild("DefaultTransparencyValue") then
				TweenService:Create(v, TI, {[Property] = v:FindFirstChild("DefaultTransparencyValue").Value}):Play()
			else
				local DefaultTransparencyValue = Instance.new("NumberValue")
				DefaultTransparencyValue.Name = "DefaultTransparencyValue"
				DefaultTransparencyValue.Value = v[Property]
				DefaultTransparencyValue.Parent = v

				v[Property] = 1
				TweenService:Create(v, TI, {[Property] = v:FindFirstChild("DefaultTransparencyValue").Value}):Play()
			end
		end
		Property = nil
	end
	TI = nil
	Table = nil
end

function module.FadeOut(Object, FadeTime)
	local TI = TweenInfo.new(FadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local Table = Object:GetDescendants()
	Table[#Table + 1] = Object
	for i,v in pairs(Table) do
		local Property = GetProperty(v)

		if Property then
			if v:FindFirstChild("DefaultTransparencyValue") then
				TweenService:Create(v, TI, {[Property] = 1}):Play()
			else
				local DefaultTransparencyValue = Instance.new("NumberValue")
				DefaultTransparencyValue.Name = "DefaultTransparencyValue"
				DefaultTransparencyValue.Value = v[Property]
				DefaultTransparencyValue.Parent = v
				TweenService:Create(v, TI, {[Property] = 1}):Play()
			end
		end
		Property = nil
	end
	TI = nil
	Table = nil
end

return module