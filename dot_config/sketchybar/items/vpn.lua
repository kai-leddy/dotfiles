local icons = require("icons")
local colors = require("colors")

-- One widget for all three VPNs: Altium (FortiClient), Octopart (sshuttle) and
-- Tailscale. Only one can be up at a time (Hammerspoon enforces that, see
-- ~/.hammerspoon/vpns.lua), so the single icon shows which one it is by
-- colour and label:
--   grey            none
--   blue   ALT      Altium via FortiClient
--   peach  OCT      Octopart via sshuttle
--   mauve  TS       Tailscale
-- Yellow with the same label means that VPN is still connecting.
--
-- One-time setup for Octopart: sshuttle needs sudo for its firewall rules, and
-- Hammerspoon has no tty to prompt on, so allow it passwordlessly:
--   sshuttle --sudoers-no-modify                  # prints the rule
--   sudo visudo -f /etc/sudoers.d/sshuttle_auto   # paste it in
-- The rule pins the Homebrew Cellar path, so redo it after `brew upgrade sshuttle`.

local tailscale_bin = "/usr/local/bin/tailscale"
local sshuttle_pidfile = os.getenv("HOME") .. "/.cache/sshuttle/octopart.pid"

-- FortiClient registers itself as a macOS Network Extension VPN service, so
-- its state comes from `scutil --nc status`. It renames the service depending
-- on state ("FortiClient VPN Tunnel" when disconnected, "VPN" when connected),
-- so find it by bundle id.
local forticlient_status = [[
	id=$(/usr/sbin/scutil --nc list | /usr/bin/awk '/com.fortinet.forticlient.macos.vpn/ {print $3; exit}')
	[ -n "$id" ] && /usr/sbin/scutil --nc status "$id" 2>/dev/null | head -1
]]
local sshuttle_status = string.format('[ -f "%s" ] && kill -0 "$(cat "%s")" 2>/dev/null && echo up', sshuttle_pidfile, sshuttle_pidfile)

-- Checked in this order; the first one that isn't off wins.
local vpns = {
	{ name = "altium", label = "ALT", color = colors.blue },
	{ name = "octopart", label = "OCT", color = colors.peach },
	{ name = "tailscale", label = "TS", color = colors.mauve },
}

-- Styled to match items/colima.lua (surface0 background, no border), grouped
-- with the other tool/status widgets. Keeps a label (unlike the others) to show
-- which VPN is up.
local vpn = sbar.add("item", {
	position = "left",
	icon = {
		string = icons.vpn,
		color = colors.overlay0,
	},
	label = { drawing = false, color = colors.text },
	background = { color = colors.surface0 },
	updates = true, -- always check for updates, even when not drawing
	update_freq = 60,
})

local function render(states)
	for _, v in ipairs(vpns) do
		local state = states[v.name]
		if state == "up" then
			vpn:set({ icon = { color = v.color }, label = { drawing = true, string = v.label } })
			return
		elseif state == "pending" then
			vpn:set({ icon = { color = colors.yellow }, label = { drawing = true, string = v.label .. "…" } })
			return
		end
	end
	vpn:set({ icon = { color = colors.overlay0 }, label = { drawing = false } })
end

local function update()
	local states, remaining = {}, 3
	local function done(name, state)
		states[name] = state
		remaining = remaining - 1
		if remaining == 0 then
			render(states)
		end
	end

	sbar.exec(forticlient_status, function(out)
		out = tostring(out):match("^%s*(.-)%s*$")
		if out == "Connected" then
			done("altium", "up")
		elseif out == "Connecting" or out == "Reasserting" then
			done("altium", "pending")
		else
			done("altium", "off")
		end
	end)

	sbar.exec(sshuttle_status, function(out)
		done("octopart", tostring(out):match("up") and "up" or "off")
	end)

	-- sbar.exec parses JSON stdout into a Lua table automatically.
	sbar.exec(tailscale_bin .. " status --json 2>/dev/null", function(out)
		local backend = type(out) == "table" and out.BackendState or nil
		if backend == "Running" then
			done("tailscale", "up")
		elseif backend == "Starting" then
			done("tailscale", "pending")
		else
			done("tailscale", "off")
		end
	end)
end

vpn:subscribe({ "forced", "routine", "vpn_change" }, update)

return vpn
