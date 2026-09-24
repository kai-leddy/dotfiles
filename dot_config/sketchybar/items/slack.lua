local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local slack = sbar.add("item", {
	position = "q",
	icon = {
		string = icons.slack,
		font = {
			style = "Regular",
			size = 22.0,
		},
		padding_right = settings.padding.small,
		color = colors.base,
	},
	label = { color = colors.base },
	background = { color = colors.pink },
	drawing = false,
	updates = true, -- update even if currently not drawing
	update_freq = 300, -- update every 5 mins
})

local function update(callback)
	sbar.exec([[ lsappinfo info Slack -all | rg '"StatusLabel"=\{ "label"="(.*)" \}' -o -r '$1' ]], function(count)
		local trimmed = count:match("^%s*(.-)%s*$") -- Trim whitespace
		local c = (trimmed ~= "") and tonumber(trimmed) or 0
		if c == 0 then
			slack:set({ drawing = false })
		else
			slack:set({ drawing = true, label = { string = c } })
		end
		if type(callback) == "function" then
			callback(c)
		end
	end)
end

local function click()
	update(function(c)
		if c ~= 0 then
			sbar.exec("open -a Slack")
		end
	end)
end

slack:subscribe({ "routine", "forced" }, update)
slack:subscribe({ "mouse.clicked" }, click)
