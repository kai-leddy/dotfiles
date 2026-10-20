-- One gap size for everything around the pills: screen top to pill, screen
-- side to pill, pill to pill, and pill to the window below. If you change it,
-- update the gaps in ~/.config/aerospace/aerospace.toml (the comment there has
-- the formulas) and run `aerospace reload-config`.
local gap = 8
-- Pill height.
local item_height = 26

return {
	font = {
		family = "FantasqueSansM Nerd Font",
		style = "Bold",
		size = 16.0,
	},
	padding = { small = 4, big = 8, bigger = 12, biggest = 16 },
	bar = {
		gap = gap,
		item_height = item_height,
		-- Pills are vertically centred, so this leaves `gap` above and below.
		height = item_height + 2 * gap,
		-- Every item gets half the gap as padding on each side, so neighbouring
		-- pills end up `gap` apart. The bar adds the other half at the screen
		-- edges.
		item_padding = gap / 2,
		-- Line graphs inside the pills (graph.lua): plot width in points, and
		-- the height of the track behind it (0% at its bottom, 100% at its top).
		graph_width = 30,
		graph_height = 14,
	},
}
