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

--- Detects the operating system name.
--- Returns the OS name from jit.os if available, otherwise executes 'uname -o',
--- or defaults to "Windows" if neither method succeeds.
--- @return string The operating system name
function M.getOSName()
	local osname
	-- ask LuaJIT first
	if jit then
		return jit.os
	end

	-- Unix, Linux variants
	local fh, err = assert(io.popen("uname -o 2>/dev/null", "r"))
	if fh then
		osname = fh:read()
	end

	return osname or "Windows"
end

return M
