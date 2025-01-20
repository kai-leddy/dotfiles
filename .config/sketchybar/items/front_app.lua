local icons = require("icons")

local front_app = sbar.add("item", {
	icon = {
		string = icons.chevron_right,
	},
})

front_app:subscribe("front_app_switched", function(env)
	front_app:set({
		label = {
			string = env.INFO,
		},
	})
end)
