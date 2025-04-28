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
	updates = true, -- always check for updates, even when not drawing
	update_freq = 300, -- update every 5 minutes
})

local function update(trigger)
	-- start by setting the pending state
	vpn:set({
		drawing = trigger == "vpn_change",
		label = "...",
	})
	-- get status of each config, using config name to mean connected and "..." to mean connecting
	-- NOTE: we have to keep doing `configuration idx` with Tunnelblick, as the named key form of lookup is broken, so we can only look up by index
	sbar.exec(
		[[
			osascript -e '
      set status to "..."
      tell application "Tunnelblick"
        repeat until (status is not "...")
          delay 1
          set status to ""
          repeat with idx from 1 to (count (configurations as list))
            if state of configuration idx is "CONNECTED" then
              set status to name of configuration idx
            else if state of configuration idx is not "EXITING" then
              set status to "..."
            end if
          end repeat
        end repeat
      end tell
      return status
			'
		]],
		function(status)
			if status:match("^%s*$") then
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

vpn:subscribe({ "forced", "routine" }, update)
vpn:subscribe({ "vpn_change" }, function()
	update("vpn_change")
end)
