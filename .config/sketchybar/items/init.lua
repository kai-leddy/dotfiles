require("items.front_app")
require("items.calendar")
require("items.volume")
require("items.battery")
require("items.vpn")

-- TODO: Replace this vomit with actual bar items that look nice
sbar.add("alias", "AeroSpace", { label = { drawing = false }, icon = { drawing = false }, position = "e" })

-- TODO: add an item for AeroSpace workspaces
-- # # TODO: add some CPU, mem, etc monitors, perhaps with a graph over time
-- # # TODO: add some more icons for status of Bluetooth, VPN, WiFi, etc
-- # # TODO: add some indicators for number of Slack messages, emails, PRs to review, etc
