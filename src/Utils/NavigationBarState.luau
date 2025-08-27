--!strict

local MaterialRoblox = script.Parent.Parent;

local Fusion = require(MaterialRoblox.Parent.Fusion);

local NOT_A_STATE = {};

type NOT_A_STATE = typeof(NOT_A_STATE);

local NavigationBarState: Fusion.Contextual<NOT_A_STATE | {
	activeIndex: Fusion.Value<number>,
	incrementalIndex: number	
}> = Fusion.Contextual(NOT_A_STATE);

return {
	NOT_A_STATE = NOT_A_STATE,
	NavigationBarState = NavigationBarState
}