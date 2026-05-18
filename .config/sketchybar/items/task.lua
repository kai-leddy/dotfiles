-- Taskwarrior SketchyBar Item

local sbar = require("sketchybar")
local colors = require("colors")
local icons = require("icons")
local utils = require("utils")

local task_active_command = "task limit:1 active"
local task_next_command = "task limit:1 next"

local task = sbar.add("item", {
	position = "right",
	label = {
		color = colors.text,
	},
	background = {
		color = colors.base,
	},
	update_freq = 15,
	display = 1, -- updated dynamically: internal + vertical monitors
})

local task_short = sbar.add("item", {
	position = "right",
	label = {
		color = colors.text,
	},
	background = {
		color = colors.base,
	},
	update_freq = 15,
	display = "2,3,4,5", -- updated dynamically: horizontal external monitors only
})

local task_id = nil

local function get_task(callback)
	sbar.exec(task_active_command, function(output)
		local id = output:match("(%d+)")
		if id then
			task_id = id
			callback()
		else
			sbar.exec(task_next_command, function(next_output)
				local next_id = next_output:match("(%d+)")
				if next_id then
					task_id = next_id
					callback()
				else
					callback()
				end
			end)
		end
	end)
end

local function update_task_widget()
	get_task(function()
		if not task_id then
			task:set({ drawing = false })
			task_short:set({ drawing = false })
			return
		end
		sbar.exec("task _get " .. task_id .. ".description", function(desc_output)
			local description = desc_output:match("(.+)")
			if description then
				local desc_short = description:sub(1, 12) .. "..."
				if #description > 64 then
					description = description:sub(1, 64) .. "..."
				end
				task:set({ label = { string = description } })
				task_short:set({ label = { string = desc_short } })
			end
		end)
		sbar.exec("task _get " .. task_id .. ".start", function(start_output)
			local started = start_output:match("(%S+)")
			if started then
				task:set({
					icon = { string = icons.task_active, color = colors.green },
					label = { color = colors.text },
				})
				task_short:set({
					icon = { string = icons.task_active, color = colors.green },
					label = { color = colors.text },
				})
			else
				task:set({
					icon = { string = icons.task_next, color = colors.yellow },
					label = { color = colors.subtext0 },
				})
				task_short:set({
					icon = { string = icons.task_next, color = colors.yellow },
					label = { color = colors.subtext0 },
				})
			end
		end)
	end)
end

local function click()
	if not task_id then
		return
	end
	sbar.exec("task _get " .. task_id .. ".start", function(start_output)
		local started = start_output:match("(%S+)")
		if started then
			sbar.exec("task " .. task_id .. " done", function()
				update_task_widget()
			end)
		else
			sbar.exec("task " .. task_id .. " start", function()
				update_task_widget()
			end)
		end
	end)
end

local function update_display_assignments()
	utils.get_display_lengths(function(displays)
		task_short:set({ display = table.concat(displays.short, ",") })
		task:set({ display = #displays.long > 0 and table.concat(displays.long, ",") or "99" })
	end)
end

update_display_assignments()

task:subscribe({ "routine", "forced" }, update_task_widget)
task_short:subscribe({ "routine", "forced" }, update_task_widget)
task:subscribe({ "mouse.clicked" }, click)
task_short:subscribe({ "mouse.clicked" }, click)
task:subscribe({ "display_change" }, update_display_assignments)
task_short:subscribe({ "display_change" }, update_display_assignments)
