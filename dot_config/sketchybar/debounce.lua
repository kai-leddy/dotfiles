--- Small helpers for turning bursts of events into a single piece of work.
--- @module debounce
---
--- Both are built on `sbar.delay` (a one-shot run loop timer, fractional
--- seconds are fine), so they need the event loop to be running; they do
--- nothing useful when called before `sbar.event_loop()`.

local M = {}

--- Trailing-edge debounce: `fn` runs once, `wait` seconds after the last call.
--- Every call restarts the timer, so a burst of calls produces one run, with
--- the arguments of the last call.
---
--- `opts.max_wait` caps how long a continuous burst can postpone the run (like
--- lodash's maxWait), so a flapping event can't starve `fn` forever. It's
--- measured with os.time(), so it only has whole-second resolution.
---
--- @param wait number seconds of quiet before running
--- @param fn function
--- @param opts? { max_wait?: number }
--- @return function debounced
function M.trailing(wait, fn, opts)
	local max_wait = opts and opts.max_wait
	local generation = 0
	local first_call = nil
	local last_args = nil

	return function(...)
		last_args = table.pack(...)
		local now = os.time()
		first_call = first_call or now
		generation = generation + 1
		local mine = generation

		local delay = wait
		if max_wait then
			delay = math.max(0, math.min(wait, max_wait - (now - first_call)))
		end

		sbar.delay(delay, function()
			if mine ~= generation then
				return -- a later call superseded this timer
			end
			local args = last_args
			first_call, last_args = nil, nil
			fn(table.unpack(args, 1, args.n))
		end)
	end
end

--- Single-flight for async work: only one run is in progress at a time. Calls
--- made while a run is in progress are collapsed into exactly one more run,
--- started when the current one finishes (so it sees fresh state). Calls are
--- never queued up one-for-one.
---
--- `fn` receives a `done` callback and must call it when its async work has
--- finished (typically at the end of the innermost `sbar.exec` callback). If it
--- never does (a command that hangs, a callback that errors), the run is
--- released after `opts.timeout` seconds (default 15) so it can't wedge forever.
---
--- @param fn fun(done: fun())
--- @param opts? { timeout?: number }
--- @return function run
function M.single_flight(fn, opts)
	local timeout = (opts and opts.timeout) or 15
	local running = false
	local dirty = false

	local function start()
		running, dirty = true, false
		local finished = false

		local function done()
			if finished then
				return
			end
			finished = true
			running = false
			if dirty then
				start()
			end
		end

		sbar.delay(timeout, done)
		local ok, err = pcall(fn, done)
		if not ok then
			print("[debounce] single_flight error: " .. tostring(err))
			done()
		end
	end

	return function()
		if running then
			dirty = true
		else
			start()
		end
	end
end

return M
