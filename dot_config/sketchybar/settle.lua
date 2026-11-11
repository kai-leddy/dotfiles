--- A shared "wait until things stop changing, then refresh once" bus.
--- @module settle
---
--- After a wake, an unlock or a display reconfiguration (DisplayLink docks
--- are bad for this), macOS sends a burst of events: several display_change
--- events, system_woke, wifi_change, ... Every item that subscribed to one of
--- them used to react immediately and on its own, so the same few seconds saw
--- many duplicate refreshes, each spawning shell commands, while WindowServer
--- was already saturated.
---
--- Items subscribe through here instead:
---
---   settle.subscribe({ "display_change", "system_woke" }, function(env) ... end,
---     { delay = 0.5, name = "my item" })
---
--- All events share one quiet window (settings.settle.wait seconds after the
--- last event, capped at settings.settle.max_wait for a continuous storm). When
--- it closes, each handler runs at most once, however many of its events (or
--- how many times one event) arrived. `env.SENDER` is the last matching event
--- and `env.EVENTS` is the set of every event seen in the burst.
---
--- `opts.delay` staggers the handlers after the window closes, so the heavy
--- ones don't all spawn processes in the same instant.
---
--- Not for anything the user is waiting on (clicks, workspace switches): those
--- should stay on plain item subscriptions.

local debounce = require("debounce")
local settings = require("settings")

local cfg = settings.settle
local log_path = "/tmp/sketchybar-settle.log"

local M = {}

local function log(message)
	if not cfg.debug then
		return
	end
	local file = io.open(log_path, "a")
	if file then
		file:write(os.date("%H:%M:%S "), message, "\n")
		file:close()
	end
end

if cfg.debug then
	local file = io.open(log_path, "w")
	if file then
		file:close()
	end
end

-- Distributed notifications macOS posts when the screen is locked/unlocked.
sbar.add("event", "screen_locked", "com.apple.screenIsLocked")
sbar.add("event", "screen_unlocked", "com.apple.screenIsUnlocked")

-- Must be an item that receives events even though it draws nothing.
local bus = sbar.add("item", "settle.bus", { drawing = false, updates = true })

local handlers = {}
local subscribed = {}
local pending = {}

local flush = debounce.trailing(cfg.wait, function()
	local seen = pending
	pending = {}

	local names = {}
	for event in pairs(seen) do
		table.insert(names, event)
	end
	table.sort(names)
	log("settled after: " .. table.concat(names, ", "))

	for _, handler in ipairs(handlers) do
		local hit = nil
		for _, event in ipairs(handler.events) do
			if seen[event] then
				hit = event
			end
		end
		if hit then
			log(string.format("  run %s (+%.2fs)", handler.name, handler.delay))
			sbar.delay(handler.delay, function()
				handler.fn({ SENDER = hit, EVENTS = seen })
			end)
		end
	end
end, { max_wait = cfg.max_wait })

local function on_event(env)
	pending[env.SENDER] = true
	flush()
end

--- @param events string|string[] sketchybar events to react to
--- @param fn fun(env: {SENDER: string, EVENTS: table<string, boolean>})
--- @param opts? { delay?: number, name?: string } delay: seconds after the window closes
function M.subscribe(events, fn, opts)
	opts = opts or {}
	if type(events) == "string" then
		events = { events }
	end
	table.insert(handlers, {
		events = events,
		fn = fn,
		delay = opts.delay or 0,
		name = opts.name or ("handler " .. (#handlers + 1)),
	})
	for _, event in ipairs(events) do
		if not subscribed[event] then
			subscribed[event] = true
			bus:subscribe(event, on_event)
		end
	end
end

-- Debug only: log every raw arrival of the events this is about, on a separate
-- item so it can't interfere with the real subscriptions above. Shows how
-- many events one unlock really produces (and whether screen_unlocked fires).
if cfg.debug then
	local probe = sbar.add("item", "settle.probe", { drawing = false, updates = true })
	probe:subscribe({
		"display_change",
		"display_added",
		"display_removed",
		"system_woke",
		"system_will_sleep",
		"wifi_change",
		"screen_locked",
		"screen_unlocked",
	}, function(env)
		log("event " .. tostring(env.SENDER))
	end)
end

return M
