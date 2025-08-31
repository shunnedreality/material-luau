--!strict

local function makeFont(fontFamily: number, weight: Enum.FontWeight)
	return Font.fromId(fontFamily, weight)
end

local function FontBuilder(fontFamily: number)
	local FontTheme = {
		expressiveFont = makeFont(fontFamily, Enum.FontWeight.Bold),
		display = {
			large = {
				font = makeFont(fontFamily, Enum.FontWeight.Regular),
				fontSize = 58,
			},
			medium = {
				font = makeFont(fontFamily, Enum.FontWeight.Regular),
				fontSize = 46,
			},
			small = {
				font = makeFont(fontFamily, Enum.FontWeight.Regular),
				fontSize = 37,
			},
		},
		headline = {
			large = {
				font = makeFont(fontFamily, Enum.FontWeight.Regular),
				fontSize = 33,
			},
			medium = {
				font = makeFont(fontFamily, Enum.FontWeight.Regular),
				fontSize = 29,
			},
			small = {
				font = makeFont(fontFamily, Enum.FontWeight.Regular),
				fontSize = 25,
			},
		},
		title = {
			large = {
				font = makeFont(fontFamily, Enum.FontWeight.Regular),
				fontSize = 23,
			},
			medium = {
				font = makeFont(fontFamily, Enum.FontWeight.Medium),
				fontSize = 17,
			},
			small = {
				font = makeFont(fontFamily, Enum.FontWeight.Medium),
				fontSize = 15,
			},
		},
		label = {
			large = {
				font = makeFont(fontFamily, Enum.FontWeight.Medium),
				fontSize = 15,
			},
			medium = {
				font = makeFont(fontFamily, Enum.FontWeight.Medium),
				fontSize = 13,
			},
			small = {
				font = makeFont(fontFamily, Enum.FontWeight.Medium),
				fontSize = 12,
			},
		},
		body = {
			large = {
				font = makeFont(fontFamily, Enum.FontWeight.Medium),
				fontSize = 17,
			},
			medium = {
				font = makeFont(fontFamily, Enum.FontWeight.Regular),
				fontSize = 15,
			},
			small = {
				font = makeFont(fontFamily, Enum.FontWeight.Regular),
				fontSize = 13,
			},
		},
	}

	return FontTheme
end

return FontBuilder