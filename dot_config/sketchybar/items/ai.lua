-- One merged pill with the remaining quota of each AI provider:
--   Claude and Copilot as % left (helpers/ai_quota.sh can also report
--   OpenRouter and DeepInfra $ credit; add them to `providers` to show them).
-- The number turns yellow at 50% left or less and red under 15% (for credit,
-- under $5 and under $1).
--
-- Data comes from helpers/ai_quota.sh (same sources as the pi usage bar).
-- Providers it doesn't return (no credentials) are hidden. Values it could
-- only get second-hand (this session's last good reading, or failing that
-- pi's cache) are dimmed. Click the pill to refresh.

local colors = require("colors")
local icons = require("icons")
local pill_group = require("pill_group")

local script = (os.getenv("CONFIG_DIR") or (os.getenv("HOME") .. "/.config/sketchybar")) .. "/helpers/ai_quota.sh"

-- In visual left-to-right order.
local providers = {
	{ key = "claude", icon = icons.ai.claude, color = colors.peach },
	{ key = "copilot", icon = icons.ai.copilot, color = colors.lavender },
	-- { key = "openrouter", icon = icons.ai.openrouter, color = colors.blue },
	-- { key = "deepinfra", icon = icons.ai.deepinfra, color = colors.teal },
}

local keys = {}
for _, provider in ipairs(providers) do
	table.insert(keys, provider.key)
end
local command = script .. " " .. table.concat(keys, " ")

local function level_color(quota)
	local left = quota.remaining
	if quota.kind == "usd" then
		return left < 1 and colors.red or left < 5 and colors.yellow or colors.text
	end
	return left < 15 and colors.red or left <= 50 and colors.yellow or colors.text
end

-- Rounded down, so it never shows more than is actually left.
local function format(quota)
	local left = math.max(0, quota.remaining)
	if quota.kind == "usd" then
		if left >= 10 then
			return string.format("$%d", math.floor(left))
		end
		return string.format("$%.1f", math.floor(left * 10) / 10)
	end
	return string.format("%d%%", math.floor(left))
end

local poll = sbar.add("item", "ai.poll", {
	position = "left",
	drawing = false,
	updates = true,
	update_freq = 300,
})

local spacers = { pill_group.spacer("left") }
local members = {}
for i, provider in ipairs(providers) do
	if i > 1 then
		provider.separator = pill_group.separator("left")
		provider.separator:set({ drawing = false })
		table.insert(members, provider.separator.name)
	end
	provider.item = pill_group.member(sbar.add("item", "ai." .. provider.key, {
		position = "left",
		drawing = false,
		icon = { string = provider.icon, color = provider.color },
		label = { string = "…" },
	}))
	table.insert(members, provider.item.name)
end
table.insert(spacers, pill_group.spacer("left"))
for _, spacer in ipairs(spacers) do
	spacer:set({ drawing = false })
end
pill_group.bracket(members)

local function update()
	sbar.exec(command, function(quotas)
		if type(quotas) ~= "table" then
			return
		end
		local any = false
		for _, provider in ipairs(providers) do
			local quota = quotas[provider.key]
			local shown = type(quota) == "table" and type(quota.remaining) == "number"
			if provider.separator then
				provider.separator:set({ drawing = shown and any })
			end
			if shown then
				-- pi's cache can be days old (any pi session rewrites it from
				-- memory), so prefer this session's last good reading.
				if quota.stale and provider.last then
					quota.remaining = provider.last
				elseif not quota.stale then
					provider.last = quota.remaining
				end
				provider.item:set({
					drawing = true,
					icon = { color = quota.stale and colors.overlay0 or provider.color },
					label = {
						string = format(quota),
						color = quota.stale and colors.overlay0 or level_color(quota),
					},
				})
			else
				provider.item:set({ drawing = false })
			end
			any = any or shown
		end
		for _, spacer in ipairs(spacers) do
			spacer:set({ drawing = any })
		end
	end)
end

poll:subscribe({ "routine", "forced", "system_woke" }, update)
for _, provider in ipairs(providers) do
	provider.item:subscribe("mouse.clicked", update)
end
