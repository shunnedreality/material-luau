--!strict

local MaterialRoblox = script.Parent.Parent;

local Fusion = require(MaterialRoblox.Parent.Fusion);

local NOT_A_STATE = {};

type NOT_A_STATE = typeof(NOT_A_STATE);

local TabState: Fusion.Contextual<NOT_A_STATE | {
	activeIndex: Fusion.Value<number>,
	incrementalIndex: number,
	tabs: {
		[number]: {
			indicatorPosition: Fusion.Value<UDim2>,
			indicatorWidth: Fusion.Value<number>,
			indicatorAbsolutePosition: Fusion.Value<Vector2>,
			indicatorAnimation: Fusion.Value<TweenInfo>,
			tabAbsolutePosition: Fusion.Value<Vector2>,
			tabAbsoluteSize: Fusion.Value<Vector2>
		}
	}
}> = Fusion.Contextual(NOT_A_STATE);

return {
	NOT_A_STATE = NOT_A_STATE,
	TabState = TabState
}