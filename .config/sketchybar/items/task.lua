-- Taskwarrior SketchyBar Item

local sbar = require("sketchybar")
local colors = require("colors")
local icons = require("icons")

local task_active_command = "task +work limit:1 active"
local task_next_command = "task +work limit:1 next"

local task_widget = sbar.add("item", {
	position = "right",
	label = {
		color = colors.text,
	},
	update_freq = 15,
})

local task_id = nil

local function get_task(callback)
	local state = nil
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
			task_widget:set({ drawing = false })
			return
		end
		sbar.exec("task _get " .. task_id .. ".description", function(desc_output)
			local description = desc_output:match("(.+)")
			if description then
				if #description > 30 then
					description = description:sub(1, 27) .. "..."
				end
				task_widget:set({ label = { string = description } })
			end
		end)
		sbar.exec("task _get " .. task_id .. ".start", function(start_output)
			local started = start_output:match("(%S+)")
			if started then
				task_widget:set({
					icon = { string = icons.task_active, color = colors.green },
					label = { color = colors.text },
				})
			else
				task_widget:set({
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

task_widget:subscribe({ "routine", "forced" }, update_task_widget)
task_widget:subscribe({ "mouse.clicked" }, click)

