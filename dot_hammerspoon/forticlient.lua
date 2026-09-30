local logger = hs.logger.new("FortiClient")

-- FortiClient has no CLI for connecting VPN tunnels on macOS (`epctrl` only
-- handles EMS registration) and `scutil --nc start` can't pick which of its
-- several tunnels to bring up. It does register itself as a macOS Network
-- Extension VPN service though, so `scutil --nc` works for status and for
-- disconnecting. Connecting is done by pressing the tunnel's "Connect" button
-- in the FortiClient window through the accessibility API (which also kicks
-- off the SSO login in the browser).
--
-- NOTE: FortiClient renames the service depending on state ("FortiClient VPN
-- Tunnel" when disconnected, just "VPN" when connected), so look it up by its
-- bundle id and address it by UUID rather than by name.
local scutil = "/usr/sbin/scutil"
local bundle_id = "com.fortinet.forticlient.macos.vpn"

-- The tunnel (as named in the FortiClient window) that M.connect() brings up.
local tunnel_name = "EMEA - Katowice (Altium)"

local M = {}

-- Returns the service UUID, or nil if FortiClient's VPN service isn't installed.
local function serviceId()
	local output = hs.execute(string.format("%s --nc list | /usr/bin/awk '/%s/ {print $3; exit}'", scutil, bundle_id))
	output = (output or ""):gsub("%s+$", "")
	if output == "" then
		return nil
	end
	return output
end

-- Returns scutil's connection state: "Connected", "Connecting", "Disconnecting",
-- "Disconnected", "Reasserting" or "Invalid" (service not found).
function M.status()
	local id = serviceId()
	if not id then
		return "Invalid"
	end
	local output = hs.execute(string.format('%s --nc status "%s" 2>/dev/null | head -1', scutil, id))
	return ((output or ""):gsub("%s+$", ""))
end

-- True if the tunnel is up or on its way up.
function M.isActive()
	local status = M.status()
	return status == "Connected" or status == "Connecting" or status == "Reasserting"
end

-- Walks the accessibility tree in document order and returns the first
-- "Connect" button that follows the text element naming the tunnel. (Each
-- tunnel card is: name text, status group, Connect button, ...)
local function findConnectButton(root)
	local seen_tunnel = false
	local result

	local function walk(element, depth)
		if result or depth > 40 then
			return
		end
		local role = element:attributeValue("AXRole")
		if role == "AXStaticText" and element:attributeValue("AXValue") == tunnel_name then
			seen_tunnel = true
		elseif seen_tunnel and role == "AXButton" and element:attributeValue("AXTitle") == "Connect" then
			result = element
			return
		end
		for _, child in ipairs(element:attributeValue("AXChildren") or {}) do
			walk(child, depth + 1)
			if result then
				return
			end
		end
	end

	walk(root, 0)
	return result
end

local function pressConnect()
	local app = hs.application.get("FortiClient")
	if not app then
		return false
	end
	local ax = hs.axuielement.applicationElement(app)
	if not ax then
		return false
	end
	-- Electron only builds its web accessibility tree when asked to.
	ax:setAttributeValue("AXManualAccessibility", true)

	local window = ax:attributeValue("AXFocusedWindow") or (ax:attributeValue("AXWindows") or {})[1]
	if not window then
		return false
	end
	local button = findConnectButton(window)
	if not button then
		return false
	end
	logger.df("Pressing Connect for %s", tunnel_name)
	button:performAction("AXPress")
	return true
end

local connect_timer

function M.connect()
	-- fabricagent://vpn makes FortiClient open its window on the VPN tab (and
	-- launches it if it isn't running).
	hs.urlevent.openURL("fabricagent://vpn")

	-- The window and its accessibility tree take a moment to appear.
	local attempts = 0
	if connect_timer then
		connect_timer:stop()
	end
	connect_timer = hs.timer.doEvery(0.5, function(timer)
		attempts = attempts + 1
		local ok, pressed = pcall(pressConnect)
		if not ok then
			logger.ef("pressConnect failed: %s", pressed)
		end
		if (ok and pressed) or attempts >= 30 then
			if not (ok and pressed) then
				logger.e("Gave up looking for the Connect button; is the tunnel name right?")
			end
			timer:stop()
		end
	end)
end

function M.disconnect()
	local id = serviceId()
	if not id then
		return
	end
	local output, ok = hs.execute(string.format('%s --nc stop "%s" 2>&1', scutil, id))
	logger.df("scutil stop: ok=%s output=%s", ok, output)
end

function M.toggle()
	if M.isActive() then
		M.disconnect()
	else
		M.connect()
	end
end

return M
