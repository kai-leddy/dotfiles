local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local github = sbar.add("item", {
	position = "q",
	icon = {
		string = icons.github,
		font = {
			style = "Regular",
			size = 22.0,
		},
		padding_right = settings.padding.small,
		color = colors.base,
	},
	label = { color = colors.base },
	background = { color = colors.mauve },
	drawing = false,
	updates = true, -- update even if currently not drawing
	update_freq = 300, -- update every 5 mins
})

local function update(callback)
	sbar.exec(
		[[
      export GH_TOKEN=$(security find-generic-password -w -a $LOGNAME -s github-cli-key)
      gh api notifications | jq 'length'
    ]],
		function(count)
			local c = tonumber(count)
			if c == 0 then
				github:set({ drawing = false })
			else
				github:set({ drawing = true, label = { string = c } })
			end
			if type(callback) == "function" then
				callback(c)
			end
		end
	)
end

local function click()
	update(function(c)
		if c ~= 0 then
			sbar.exec("open https://github.com/notifications")
		end
	end)
end

github:subscribe({ "routine", "forced" }, update)
github:subscribe({ "mouse.clicked" }, click)
