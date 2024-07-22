local logger = hs.logger.new("Tunnelblick")

local function toggleVPN(connection_name)
	local code, output, descriptor = hs.osascript.applescript(string.format(
		[[
      tell application "Tunnelblick"
        set configName to "%s"
        set currentState to state of first configuration where name = configName
        if currentState is "CONNECTED" then
          disconnect configName
        else
          connect configName
        end if
      end tell
      ]],
		connection_name
	))
	logger.df("Tunnelblick Applescript Output: Code: %s  Output: %s Descriptor: %s", code, output, descriptor)
end

return toggleVPN
