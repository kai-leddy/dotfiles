local logger = hs.logger.new("Tunnelblick")

local M = {}

function M.toggle(connection_name)
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

-- Disconnects every currently connected/connecting Tunnelblick configuration.
-- Used to keep Tunnelblick and Tailscale mutually exclusive, since both try
-- to own the default route/DNS and fight each other if both are up.
function M.disconnectAll()
	local code, output, descriptor = hs.osascript.applescript([[
      tell application "Tunnelblick"
        repeat with idx from 1 to (count (configurations as list))
          if state of configuration idx is not "EXITING" and state of configuration idx is not "" then
            if not (state of configuration idx is "CONNECTED") and not (state of configuration idx is "CONNECTING") then
              -- leave fully disconnected configs alone
            else
              disconnect (name of configuration idx)
            end if
          end if
        end repeat
      end tell
      ]])
	logger.df("Tunnelblick disconnectAll Output: Code: %s  Output: %s Descriptor: %s", code, output, descriptor)
end

-- Backwards-compatible callable module (existing callers do `toggleVPN(name)`)
return setmetatable(M, {
	__call = function(_, connection_name)
		M.toggle(connection_name)
	end,
})
