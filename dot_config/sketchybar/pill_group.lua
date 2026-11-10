-- Merges several items into one pill, with thin separators between them.
--
--   local pill_group = require("pill_group")
--   pill_group.merge("right", { "items.wifi", "items.bluetooth", "items.battery" })
--
-- Each module must `return` its item. Modules are listed in visual
-- left-to-right order; for right-hand groups they're added in reverse, because
-- sketchybar stacks right items right-to-left.
--
-- The members lose their own pill (background goes transparent, so an item
-- can still light up its own segment, e.g. cpu turning red) and a bracket
-- draws one shared pill behind them all.

local colors = require("colors")
local settings = require("settings")

local M = {}

-- Spacing inside merged pills. The gap between neighbouring icons (and between
-- an icon and its label) is the same as the gap between the outermost icon and
-- the pill's edge, i.e. M.edge_padding (the same 8 a standalone pill has):
--   * every member has inner_padding either side, which across the 2pt
--     separator makes up the gap between members;
--   * an empty item at each end of the bracket tops the edge up to edge_padding;
--   * a label sits edge_padding - inner_padding after its icon.
-- inner_padding * 2 + 2 (the separator) == edge_padding.
local edge_padding = settings.padding.big
local inner_padding = (edge_padding - 2) / 2
M.inner_padding = inner_padding
M.edge_padding = edge_padding

-- Empty item inside the bracket that pads the end of the pill out to
-- edge_padding. Width is what's missing after the end member's own padding.
function M.edge(position)
	return sbar.add("item", {
		position = position,
		padding_left = 0,
		padding_right = 0,
		width = edge_padding - inner_padding,
		icon = { drawing = false },
		label = { drawing = false },
		background = { drawing = false },
	})
end

-- A bracket's background covers its members' outer padding, so members get
-- no outer padding and these empty items supply the gap outside the pill
-- instead (the same item_padding every standalone pill has).
function M.spacer(position)
	return sbar.add("item", {
		position = position,
		padding_left = settings.bar.item_padding,
		padding_right = 0,
		icon = { drawing = false },
		label = { drawing = false },
		background = { drawing = false },
	})
end

function M.separator(position)
	return sbar.add("item", {
		position = position,
		padding_left = 0,
		padding_right = 0,
		icon = { drawing = false },
		label = {
			string = "│",
			color = colors.surface2,
			padding_left = 0,
			padding_right = 0,
		},
		background = { drawing = false },
	})
end

function M.bracket(members)
	return sbar.add("bracket", members, {
		-- Brackets otherwise take their first member's y_offset.
		y_offset = 0,
		background = {
			color = colors.surface0,
			height = settings.bar.item_height,
			corner_radius = 10,
		},
	})
end

-- Strips an item's own pill so it can sit inside a bracket.
function M.member(item)
	item:set({
		padding_left = 0,
		padding_right = 0,
		icon = { padding_left = inner_padding, padding_right = inner_padding },
		label = { padding_left = edge_padding - inner_padding, padding_right = inner_padding },
		background = { color = colors.transparent },
	})
	return item
end

function M.merge(position, modules)
	local order = {}
	for i, module in ipairs(modules) do
		order[position == "right" and (#modules - i + 1) or i] = module
	end

	M.spacer(position)
	local members = { M.edge(position).name }
	for i, module in ipairs(order) do
		if i > 1 then
			table.insert(members, M.separator(position).name)
		end
		local item = require(module)
		if item.is_stat then
			-- graph.lua stat: style the icon; the graph item is already set up.
			M.member(item.icon)
			for _, part in ipairs(item.items) do
				table.insert(members, part.name)
			end
		else
			table.insert(members, M.member(item).name)
		end
	end
	table.insert(members, M.edge(position).name)
	M.spacer(position)

	return M.bracket(members)
end

return M
