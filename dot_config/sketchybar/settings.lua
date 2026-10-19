-- One gap size for everything around the pills: screen top to pill, screen
-- side to pill, pill to pill, and pill to the window below. If you change it,
-- update the gaps in ~/.config/aerospace/aerospace.toml (the comment there has
-- the formulas) and run `aerospace reload-config`.
local gap = 8
-- Pill height on both bars.
local item_height = 26

return {
	-- "single": everything on one bar, on every display.
	-- "dual": context + on/off toggles on the main bar (every display), and
	--         cpu/mem/wifi/bluetooth/battery/volume on a second "statsbar"
	--         under it, on the built-in display only.
	-- After switching, also swap the outer.top line in
	-- ~/.config/aerospace/aerospace.toml and run `aerospace reload-config`.
	layout = "single",

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
		-- The stats bar (layout = "dual") is the same height and overlaps the
		-- main bar by `gap`, so the gap between the two rows is also `gap`.
		height = item_height + 2 * gap,
		-- Every item gets half the gap as padding on each side, so neighbouring
		-- pills end up `gap` apart. The bar adds the other half at the screen
		-- edges.
		item_padding = gap / 2,
	},
}
