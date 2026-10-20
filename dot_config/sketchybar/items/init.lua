-- Order matters within each position: left items stack left-to-right, right
-- items stack right-to-left (the first one added sits furthest right).

local pill_group = require("pill_group")
local groups = require("items.groups")

require("items.aerospace")

-- Right, from the screen edge inwards
require("items.datetime")
pill_group.merge("right", groups.hardware)
require("items.task")

-- Left of the notch
require("items.mail")
require("items.github")
require("items.slack")
require("items.meeting")

-- Left, from the screen edge inwards
pill_group.merge("left", groups.system)
require("items.ai")
pill_group.merge("left", groups.toggles)
