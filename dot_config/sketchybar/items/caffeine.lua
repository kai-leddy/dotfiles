local colors = require("colors")
local icons = require("icons")

-- Keeps the Mac awake (no idle/system/display sleep) via `caffeinate -isd`,
-- run detached in the background so it survives independently of
-- sketchybar. Styled to match items/colima.lua (icon-only, surface0
-- background, no border, peach/coffee-toned when active), grouped with
-- the other icon-only tool/status widgets. Click to toggle on/off.

local pending = false
local caffeine = sbar.add("item", {
	position = "left",
	icon = {
		string = icons.coffee,
		color = colors.overlay0,
	},
	label = { drawing = false },
	background = { color = colors.surface0 },
	update_freq = 30,
})

local function update_caffeine()
	if pending then
		return
	end

	sbar.exec("pgrep -f 'caffeinate -isd' >/dev/null 2>&1 && printf running || printf stopped", function(status)
		local running = status:match("running") ~= nil
		caffeine:set({
			icon = { color = running and colors.peach or colors.overlay0 },
		})
	end)
end

local function toggle_caffeine()
	if pending then
		return
	end

	pending = true
	caffeine:set({ icon = { color = colors.yellow } })
	sbar.exec(
		"if pgrep -f 'caffeinate -isd' >/dev/null 2>&1; then pkill -f 'caffeinate -isd'; else nohup caffeinate -isd >/dev/null 2>&1 & fi",
		function()
			pending = false
			update_caffeine()
		end
	)
end

caffeine:subscribe({ "routine", "forced" }, update_caffeine)
caffeine:subscribe("mouse.clicked", toggle_caffeine)

return caffeine
