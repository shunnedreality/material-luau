--!strict

local function getDisplayWidth()
	return workspace.CurrentCamera.ViewportSize.X
end

local function onDisplayChange(
	callback: () -> ()
)
	return workspace.CurrentCamera.Changed:Connect(function(
		property: string
	)
		if property == "ViewportSize" then
			callback()
		end
	end)
end

return {
	getDisplayWidth = getDisplayWidth,
	onDisplayChange = onDisplayChange
}