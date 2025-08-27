--!strict

local function makeFont(fontFamily: number, weight: Enum.FontWeight)
	return Font.fromId(fontFamily, weight)
end

local function FontBuilder(fontFamily: number)
	local FontTheme = {
		display = {
			large = {
				font = makeFont(fontFamily, Enum.FontWeight.Regular),
				fontSize = 57,
			},
			medium = {
				font = makeFont(fontFamily, Enum.FontWeight.Regular),
				fontSize = 45,
			},
			small = {
				font = makeFont(fontFamily, Enum.FontWeight.Regular),
				fontSize = 36,
			},
		},
		headline = {
			large = {
				font = makeFont(fontFamily, Enum.FontWeight.Regular),
				fontSize = 32,
			},
			medium = {
				font = makeFont(fontFamily, Enum.FontWeight.Regular),
				fontSize = 28,
			},
			small = {
				font = makeFont(fontFamily, Enum.FontWeight.Regular),
				fontSize = 24,
			},
		},
		title = {
			large = {
				font = makeFont(fontFamily, Enum.FontWeight.Regular),
				fontSize = 22,
			},
			medium = {
				font = makeFont(fontFamily, Enum.FontWeight.Medium),
				fontSize = 16,
			},
			small = {
				font = makeFont(fontFamily, Enum.FontWeight.Medium),
				fontSize = 14,
			},
		},
		label = {
			large = {
				font = makeFont(fontFamily, Enum.FontWeight.Medium),
				fontSize = 14,
			},
			medium = {
				font = makeFont(fontFamily, Enum.FontWeight.Medium),
				fontSize = 12,
			},
			small = {
				font = makeFont(fontFamily, Enum.FontWeight.Medium),
				fontSize = 11,
			},
		},
		body = {
			large = {
				font = makeFont(fontFamily, Enum.FontWeight.Medium),
				fontSize = 16,
			},
			medium = {
				font = makeFont(fontFamily, Enum.FontWeight.Regular),
				fontSize = 14,
			},
			small = {
				font = makeFont(fontFamily, Enum.FontWeight.Regular),
				fontSize = 12,
			},
		},
	}

	return FontTheme
end

return FontBuilder