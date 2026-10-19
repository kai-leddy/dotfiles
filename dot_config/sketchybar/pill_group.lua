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

-- Space either side of each icon/label inside a merged pill.
local inner_padding = 6

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
		label = { padding_right = inner_padding },
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
	local members = {}
	for i, module in ipairs(order) do
		if i > 1 then
			table.insert(members, M.separator(position).name)
		end
		table.insert(members, M.member(require(module)).name)
	end
	M.spacer(position)

	return M.bracket(members)
end

return M
