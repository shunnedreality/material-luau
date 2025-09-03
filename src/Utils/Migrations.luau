--!strict

local function getPaletteFromTheme(
    theme,
    mode: "light" | "dark"
)
    return theme.schemes[mode].props
end

local function getPaletteFromThemeState(
    scope,
    theme,
    mode: "light" | "dark"
)
    return scope:Computed(function(
        use
    )
        return getPaletteFromTheme(theme, use(mode));
    end)
end

return {
    getPaletteFromTheme = getPaletteFromTheme,
    getPaletteFromThemeState = getPaletteFromThemeState,
}