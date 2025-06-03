local function color_to_int(hex_string)
	-- Remove the leading '#'
	local hex_part = hex_string:sub(2)
	-- Prepend "ff" and convert to integer (base 16)
	return tonumber("ff" .. hex_part, 16)
end

return {
	-- Catppuccin Mocha theme colors
	rosewater = color_to_int("#f5e0dc"),
	flamingo = color_to_int("#f2cdcd"),
	pink = color_to_int("#f5c2e7"),
	mauve = color_to_int("#cba6f7"),
	red = color_to_int("#f38ba8"),
	maroon = color_to_int("#eba0ac"),
	peach = color_to_int("#fab387"),
	yellow = color_to_int("#f9e2af"),
	green = color_to_int("#a6e3a1"),
	teal = color_to_int("#94e2d5"),
	sky = color_to_int("#89dceb"),
	sapphire = color_to_int("#74c7ec"),
	blue = color_to_int("#89b4fa"),
	lavender = color_to_int("#b4befe"),
	text = color_to_int("#cdd6f4"),
	subtext1 = color_to_int("#bac2de"),
	subtext0 = color_to_int("#a6adc8"),
	overlay2 = color_to_int("#9399b2"),
	overlay1 = color_to_int("#7f849c"),
	overlay0 = color_to_int("#6c7086"),
	surface2 = color_to_int("#585b70"),
	surface1 = color_to_int("#45475a"),
	surface0 = color_to_int("#313244"),
	base = color_to_int("#1e1e2e"),
	mantle = color_to_int("#181825"),
	crust = color_to_int("#11111b"),

	transparent = 0x00000000, -- Fully transparent color
	color_to_int = color_to_int,

	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,
}
