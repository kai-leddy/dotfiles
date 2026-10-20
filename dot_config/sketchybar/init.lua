-- A reload starts a fresh config process, but the old one doesn't always exit:
-- it and its forked helpers (event loop, hotload watcher) keep running timers
-- and handlers against items that no longer exist, and extra watchers mean
-- extra reloads. So stop every config process except this one: older ones
-- sketchybar started (with their children), and children of earlier ones that
-- were left behind under launchd. ($$ is the shell, its parent is this lua
-- process, and that one's parent is sketchybar.)
os.execute([[
self=$(ps -o ppid= -p $$ | tr -d ' ')
bar=$(ps -o ppid= -p "$self" | tr -d ' ')
for pid in $(pgrep -P "$bar" -f 'lua .*sketchybarrc'); do
	[ "$pid" != "$self" ] && kill $(pgrep -P "$pid") "$pid" 2>/dev/null
done
for pid in $(pgrep -P 1 -f 'lua .*sketchybarrc'); do
	kill "$pid"
done
]])

-- Require the sketchybar module
sbar = require("sketchybar")

-- Bundle the entire initial configuration into a single message to sketchybar
-- This improves startup times drastically, try removing both the begin and end
-- config calls to see the difference -- yeah..
sbar.begin_config()

require("bar")
require("default")
require("items")

sbar.hotload(true)
sbar.end_config()

-- Run the event loop of the sketchybar module (without this there will be no
-- callback functions executed in the lua module)
sbar.event_loop()
