local logger = hs.logger.new("sshuttle")

-- Octopart's VPN is an sshuttle tunnel through the octopart-vpc host (an SSM
-- session proxied over ssh, see ~/.ssh/config), equivalent to running:
--
--   sshuttle -r octopart-vpc 10.1.0.0/16 --dns
--
-- It runs as a daemon (-D) so it survives Hammerspoon reloads, and the pidfile
-- is both the on/off state and how we stop it.
--
-- sshuttle sudo's to install its firewall rules, and a Hammerspoon-launched
-- process has no tty to type a password into. So this needs the passwordless
-- sudoers rule from `sshuttle --sudoers-no-modify` (see the setup note in
-- ~/.config/sketchybar/items/octopart.lua). Without it, connecting just fails
-- and the reason is logged here.
local host = "octopart-vpc"
local subnets = "10.1.0.0/16"

local state_dir = os.getenv("HOME") .. "/.cache/sshuttle"
local pidfile = state_dir .. "/octopart.pid"
local logfile = state_dir .. "/octopart.log"
local aws_profile = "octopart-prod"

-- How long to wait after launching before deciding the tunnel failed to come
-- up. sshuttle daemonises (writes the pidfile) only once it has connected.
local connect_timeout = 25

-- Hammerspoon's PATH is minimal; sshuttle's ProxyCommand needs aws and
-- session-manager-plugin from Homebrew. AWS_PROFILE is the one that can see
-- the octopart-vpc instance.
local env = "PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin AWS_PROFILE=octopart-prod"

local M = {}

-- Returns the daemon's pid if it is running, otherwise nil.
local function pid()
	local output = hs.execute(string.format('[ -f "%s" ] && p=$(cat "%s") && kill -0 "$p" 2>/dev/null && echo "$p"', pidfile, pidfile))
	output = (output or ""):gsub("%s+$", "")
	return output ~= "" and output or nil
end

function M.isActive()
	return pid() ~= nil
end

local connect_task
local check_task
local login_task
local fail_timer

local function alert(message)
	logger.e(message)
	hs.alert.show(message, { textSize = 18 }, hs.screen.mainScreen(), 8)
	require("sketchybar").sendEvent("vpn_change")
end

local function launch()
	hs.execute(string.format('mkdir -p "%s" && rm -f "%s"', state_dir, pidfile))
	local command =
		string.format("%s exec sshuttle -D --pidfile '%s' -r %s %s --dns >'%s' 2>&1", env, pidfile, host, subnets, logfile)
	connect_task = hs.task.new("/bin/bash", function(code)
		logger.df("sshuttle launcher exited: code=%s (see %s)", code, logfile)
	end, { "-c", command })
	connect_task:start()

	-- If the tunnel isn't up after a while, say so and why.
	if fail_timer then
		fail_timer:stop()
	end
	fail_timer = hs.timer.doAfter(connect_timeout, function()
		if M.isActive() then
			return
		end
		local tail = hs.execute(string.format("tail -n 3 '%s' 2>/dev/null", logfile)) or ""
		alert("Octopart VPN failed to connect\n" .. tail:gsub("%s+$", ""))
	end)
end

-- Runs `aws sso login` (opens the browser) and carries on connecting once it
-- succeeds. Only one login at a time, so mashing the hotkey doesn't open a
-- pile of browser tabs.
local function login_then_launch()
	if login_task and login_task:isRunning() then
		return
	end
	logger.i("AWS SSO session expired, running aws sso login for " .. aws_profile)
	login_task = hs.task.new("/bin/bash", function(code, _, stderr)
		require("sketchybar").sendEvent("vpn_change")
		if code ~= 0 then
			alert("AWS SSO login failed for " .. aws_profile .. "\n" .. (stderr or ""):gsub("%s+$", ""))
			return
		end
		if not M.isActive() then
			launch()
		end
	end, { "-c", string.format("%s exec aws sso login --profile %s", env, aws_profile) })
	login_task:start()
end

function M.connect()
	if M.isActive() then
		return
	end
	-- An expired AWS SSO session is the usual reason this fails, and sshuttle
	-- daemonises silently, so check it up front and log in automatically.
	local command = string.format(
		"%s aws sts get-caller-identity --cli-connect-timeout 5 --cli-read-timeout 5 >/dev/null 2>&1",
		env
	)
	check_task = hs.task.new("/bin/bash", function(code)
		if code ~= 0 then
			login_then_launch()
			return
		end
		launch()
	end, { "-c", command })
	check_task:start()
end

-- Stops the daemon and waits (briefly) for it to remove its firewall rules, so
-- whichever VPN comes up next doesn't race the teardown.
function M.disconnect()
	local p = pid()
	if not p then
		return
	end
	local output, ok = hs.execute(
		string.format('kill %s; for i in $(seq 1 50); do kill -0 %s 2>/dev/null || break; sleep 0.1; done; rm -f "%s"', p, p, pidfile)
	)
	logger.df("sshuttle stop: ok=%s output=%s", ok, output)
end

function M.toggle()
	if M.isActive() then
		M.disconnect()
	else
		M.connect()
	end
end

return M
