local colors = require("colors")
local icons = require("icons")

local pending = false
local colima = sbar.add("item", {
	position = "left",
	icon = {
		string = icons.docker,
		color = colors.overlay0,
	},
	label = { drawing = false },
	background = { color = colors.surface0 },
	update_freq = 30,
})

local function update_colima()
	if pending then
		return
	end

	sbar.exec("if colima status >/dev/null 2>&1; then printf running; else printf stopped; fi", function(status)
		local running = status:match("running") ~= nil
		colima:set({
			icon = { string = icons.docker, color = running and colors.blue or colors.overlay0 },
		})
	end)
end

local function toggle_colima()
	if pending then
		return
	end

	pending = true
	colima:set({ icon = { string = icons.docker, color = colors.yellow } })
	sbar.exec("if colima status >/dev/null 2>&1; then colima stop; else colima start; fi", function()
		pending = false
		update_colima()
	end)
end

colima:subscribe({ "routine", "forced" }, update_colima)
colima:subscribe("mouse.clicked", toggle_colima)

return colima
