local settings = require("settings")
local colors = require("colors")
local app_icons = require("app_icons")

local query_workspaces =
	"aerospace list-workspaces --all --format '%{workspace}%{monitor-appkit-nsscreen-screens-id}' --json"

local root = sbar.add("item", {
	icon = {
		drawing = false,
	},
	label = {
		drawing = false,
	},
	background = {
		drawing = false,
	},
})

local workspaces = {}

local function withWindows(f)
	local open_windows = {}
	local get_windows = "aerospace list-windows --monitor all --format '%{workspace}%{app-name}' --json"
	local query_visible_workspaces =
		"aerospace list-workspaces --visible --monitor all --format '%{workspace}%{monitor-appkit-nsscreen-screens-id}' --json"
	local get_focus_workspaces = "aerospace list-workspaces --focused"
	sbar.exec(get_windows, function(workspace_and_windows)
		for _, entry in ipairs(workspace_and_windows) do
			local workspace_index = entry.workspace
			local app = entry["app-name"]
			if open_windows[workspace_index] == nil then
				open_windows[workspace_index] = {}
			end
			table.insert(open_windows[workspace_index], app)
		end
		sbar.exec(get_focus_workspaces, function(focused_workspaces)
			sbar.exec(query_visible_workspaces, function(visible_workspaces)
				local args = {
					open_windows = open_windows,
					focused_workspaces = focused_workspaces,
					visible_workspaces = visible_workspaces,
				}
				f(args)
			end)
		end)
	end)
end

local function updateWindow(workspace_index, args)
	local open_windows = args.open_windows[workspace_index]
	local focused_workspaces = args.focused_workspaces
	local visible_workspaces = args.visible_workspaces

	if open_windows == nil then
		open_windows = {}
	end

	local icon_line = ""
	local no_app = true
	for i, open_window in ipairs(open_windows) do
		no_app = false
		local app = open_window
		local lookup = app_icons[app]
		local icon = ((lookup == nil) and app_icons["Default"] or lookup)
		icon_line = icon_line .. icon .. " "
	end

	sbar.animate("tanh", 10, function()
		for i, visible_workspace in ipairs(visible_workspaces) do
			if no_app and workspace_index == visible_workspace["workspace"] then
				local monitor_id = visible_workspace["monitor-appkit-nsscreen-screens-id"]
				icon_line = " —"
				workspaces[workspace_index]:set({
					icon = { drawing = true },
					label = {
						string = icon_line,
						drawing = true,
					},
					background = { drawing = true },
					display = monitor_id,
					padding_left = settings.padding.small,
					padding_right = settings.padding.small,
				})
				return
			end
		end
		if no_app and workspace_index ~= focused_workspaces then
			workspaces[workspace_index]:set({
				icon = { drawing = false },
				label = { drawing = false },
				background = { drawing = false },
				padding_left = 0,
				padding_right = 0,
			})
			return
		end
		if no_app and workspace_index == focused_workspaces then
			icon_line = " —"
			workspaces[workspace_index]:set({
				icon = { drawing = true },
				label = {
					string = icon_line,
					drawing = true,
				},
				background = { drawing = true },
				padding_left = settings.padding.small,
				padding_right = settings.padding.small,
			})
		end

		workspaces[workspace_index]:set({
			icon = { drawing = true },
			label = { drawing = true, string = icon_line },
			background = { drawing = true },
			padding_left = settings.padding.small,
			padding_right = settings.padding.small,
		})
	end)
end

local function updateWindows()
	withWindows(function(args)
		for workspace_index, _ in pairs(workspaces) do
			updateWindow(workspace_index, args)
		end
	end)
end

local function updateWorkspaceMonitor()
	local workspace_monitor = {}
	sbar.exec(query_workspaces, function(workspaces_and_monitors)
		for _, entry in ipairs(workspaces_and_monitors) do
			local space_index = entry.workspace
			local monitor_id = math.floor(entry["monitor-appkit-nsscreen-screens-id"])
			workspace_monitor[space_index] = monitor_id
		end
		for workspace_index, _ in pairs(workspaces) do
			workspaces[workspace_index]:set({
				display = workspace_monitor[workspace_index],
			})
		end
	end)
end

sbar.exec(query_workspaces, function(workspaces_and_monitors)
	for _, entry in ipairs(workspaces_and_monitors) do
		local workspace_index = entry.workspace

		local workspace = sbar.add("item", {
			position = "e",
			icon = {
				color = colors.with_alpha(colors.base, 0.5),
				highlight_color = colors.base,
				drawing = false,
				string = workspace_index,
				font = {
					size = settings.font.size * 1.5,
				},
			},
			label = {
				color = colors.with_alpha(colors.base, 0.5),
				highlight_color = colors.base,
			},
			background = {
				color = colors.with_alpha(colors.sapphire, 0.5),
			},
			padding_left = settings.padding.small,
			padding_right = settings.padding.small,
		})

		workspaces[workspace_index] = workspace

		workspace:subscribe("aerospace_workspace_change", function(env)
			local focused_workspace = env.FOCUSED_WORKSPACE
			local is_focused = focused_workspace == workspace_index

			sbar.animate("tanh", 10, function()
				workspace:set({
					icon = { highlight = is_focused },
					label = { highlight = is_focused },
					background = {
						color = is_focused and colors.sapphire or colors.with_alpha(colors.sapphire, 0.5),
					},
				})
			end)
		end)
	end

	-- initial setup
	updateWindows()
	updateWorkspaceMonitor()

	root:subscribe("aerospace_focus_change", function()
		updateWindows()
	end)

	root:subscribe("display_change", function()
		updateWorkspaceMonitor()
		updateWindows()
	end)

	sbar.exec("aerospace list-workspaces --focused", function(focused_workspace)
		local focused = focused_workspace:match("^%s*(.-)%s*$")
		workspaces[focused]:set({
			icon = { highlight = true },
			label = { highlight = true },
			background = { color = colors.sapphire },
		})
	end)
end)
