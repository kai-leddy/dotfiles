-- Small line graphs for the bar: an icon, then a plot on a faint track that
-- marks the full 0..1 range. No numbers; warnings show as colour.
--
-- Each graph is two items, because sketchybar sizes a graph from its item's
-- background, and that background spans the icon too:
--   <name>.icon  the icon (an ordinary item)
--   <name>       the graph: background = the track
--
-- Sketchybar draws the plot shifted up by its line width, so the track is
-- shifted up to match.
--
-- Direction: sketchybar's graph is a ring buffer you can only push onto, and
-- for items on the left of the bar it draws the newest point at the left edge
-- (only right and q items get newest-on-the-right; see `rtl` in sketchybar's
-- graph.c). So the history is kept here instead, and every draw re-pushes the
-- whole series (exactly `width` values, so the buffer wraps right round). For
-- a left item sketchybar draws buffer[width-1], buffer[width-2] ... buffer[1]
-- from left to right (buffer[0] is only the line's start point), so the
-- buffer has to hold { oldest, newest, ..., oldest }. SbarLua's push sends a
-- table's values in reverse (checked with `sketchybar --query`), so the table
-- pushed is { oldest, ..., newest, oldest }.
--
-- Only valid for position = "left" items.

local colors = require("colors")
local settings = require("settings")
local pill_group = require("pill_group")

local M = {}

local line_width = 1
local track_color = colors.with_alpha(colors.crust, 0.45)

-- Adds the two items. opts: icon (string), color, width (graph points),
-- update_freq, drawing. Returns a stat:
--   stat.icon, stat.graph   the items (subscribe/push on stat.graph)
--   stat.items              both, for pill_group.merge
--   stat:set({ color, icon_color, drawing })
function M.add(name, opts)
	local b = settings.bar
	local drawing = opts.drawing ~= false

	local icon = sbar.add("item", name .. ".icon", {
		position = "left",
		drawing = drawing,
		icon = { string = opts.icon, color = opts.color },
		label = { drawing = false },
	})

	local graph = sbar.add("graph", name, opts.width or b.graph_width, {
		position = "left",
		drawing = drawing,
		padding_left = 0,
		padding_right = pill_group.inner_padding, -- gap before the separator
		icon = { drawing = false, padding_left = 0, padding_right = 0 },
		label = { drawing = false, padding_left = 0, padding_right = 0 },
		graph = {
			color = opts.color,
			fill_color = colors.with_alpha(opts.color, 0.3),
			line_width = line_width,
		},
		background = {
			drawing = true,
			color = track_color,
			height = b.graph_height,
			corner_radius = 2,
			y_offset = line_width,
		},
		update_freq = opts.update_freq,
		updates = opts.updates,
	})

	local stat = { icon = icon, graph = graph, items = { icon, graph }, is_stat = true }

	function stat:set(props)
		if props.drawing ~= nil then
			for _, item in ipairs(self.items) do
				item:set({ drawing = props.drawing })
			end
		end
		if props.color then
			icon:set({ icon = { color = props.icon_color or props.color } })
			graph:set({ graph = { color = props.color, fill_color = colors.with_alpha(props.color, 0.3) } })
		end
	end

	return stat
end

-- values: oldest to newest, 0..1, any length. Missing older points are filled
-- with `pad` (default: the oldest value, or 0).
function M.draw(item, width, values, pad)
	local n = width - 1
	local points = {}
	for i = 1, n do
		points[i] = values[#values - n + i] or pad or values[1] or 0
	end

	table.insert(points, points[1])
	item:push(points)
end

-- A rolling history of the last `width - 1` samples, drawn on each add.
function M.rolling(item, width)
	local values = {}
	return {
		add = function(value)
			table.insert(values, math.min(1, math.max(0, value)))
			if #values > width - 1 then
				table.remove(values, 1)
			end
			M.draw(item, width, values, 0)
		end,
	}
end

return M
