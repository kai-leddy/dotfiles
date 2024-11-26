local wezterm = require("wezterm")
local M = {}

---@param table_name string
---@param keys table[]
---@return table?
function M.extend_key_table(table_name, keys)
	local tbl = nil
	if wezterm.gui then
		tbl = wezterm.gui.default_key_tables()[table_name]
		if tbl then
			for _, key in ipairs(keys) do
				table.insert(tbl, key)
			end
		else
			wezterm.log_error("Key table '" .. table_name .. "' does not exist.")
		end
	else
		wezterm.log_error("WezTerm GUI is not available.")
	end
	return tbl
end

return M
