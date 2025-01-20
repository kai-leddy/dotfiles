-- Require the sketchybar module
sbar = require("sketchybar")

-- Bundle the entire initial configuration into a single message to sketchybar
-- This improves startup times drastically, try removing both the begin and end
-- config calls to see the difference -- yeah..
sbar.begin_config()

require("bar")
require("default")
require("items")

-- TODO: add an item for AeroSpace workspaces

sbar.hotload(true)
sbar.end_config()

-- Run the event loop of the sketchybar module (without this there will be no
-- callback functions executed in the lua module)
sbar.event_loop()
