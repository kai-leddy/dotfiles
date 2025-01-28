local settings = require("settings")
local icons = require("icons")
local colors = require("colors")

local vpn = sbar.add("item", {
	position = "q",
	icon = {
		string = icons.vpn,
		font = {
			size = 19,
		},
		color = colors.blue,
		padding_right = settings.padding.small,
	},
	label = { color = colors.blue },
	updates = true, -- always poll for updates, even when not drawing
	update_freq = 10, -- TODO:setup event from Hammerspoon script instead of polling
})

local function update()
	-- get status of each config, using config name to mean connected and "..." to mean connecting
	-- NOTE: we have to keep doing `configuration idx` with Tunnelblick, as the named key form of lookup is broken, so we can only looj up by index
	sbar.exec(
		[[
			osascript -e 'tell application "Tunnelblick"
				repeat with idx from 1 to (count (configurations as list))
					if state of configuration idx is "CONNECTED" then
						return name of configuration idx
					else if state of configuration idx is not "EXITING" then
						return "..."
					end if
				end repeat
			end tell'
		]],
		function(status)
			if status == "" then
				vpn:set({
					drawing = false,
					label = "...",
				})
			else
				local first_word = status:match("(%w+)(.*)")
				vpn:set({
					drawing = true,
					label = first_word,
				})
			end
		end
	)
end

vpn:subscribe({ "routine", "forced" }, update)
