-- Items for the main bar (every display).
--
-- settings.layout = "single": everything below is loaded here.
-- settings.layout = "dual":   the system and hardware pills are skipped here
--                             and loaded by the separate "statsbar" instance
--                             instead (items/stats.lua, built-in display only).
--
-- Order matters within each position: left items stack left-to-right, right
-- items stack right-to-left (the first one added sits furthest right).

local pill_group = require("pill_group")
local groups = require("items.groups")
local dual = require("settings").layout == "dual"

require("items.aerospace")

-- Right, from the screen edge inwards
require("items.datetime")
if not dual then
	pill_group.merge("right", groups.hardware)
end
require("items.task")

-- Left of the notch
require("items.mail")
require("items.github")
require("items.slack")
require("items.meeting")

-- Left, from the screen edge inwards
if not dual then
	pill_group.merge("left", groups.system)
end
pill_group.merge("left", groups.toggles)

-- TODO: change mem and cpu to show some graphs
