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

function M.connect()
	if M.isActive() then
		return
	end
	hs.execute(string.format('mkdir -p "%s" && rm -f "%s"', state_dir, pidfile))
	local command = string.format("%s exec sshuttle -D --pidfile '%s' -r %s %s --dns", env, pidfile, host, subnets)
	connect_task = hs.task.new("/bin/bash", function(code, stdout, stderr)
		logger.df("sshuttle launcher exited: code=%s stdout=%s stderr=%s", code, stdout, stderr)
	end, { "-c", command })
	connect_task:start()
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
