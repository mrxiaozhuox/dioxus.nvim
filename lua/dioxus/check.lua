local M = {}

local cli = require("dioxus.cli")
local utils = require("dioxus.utils")

-- dioxus-cli check file
M.check_buffer = function()
	local buffer_path = utils.get_current_buffer_path()

	if not buffer_path then
		vim.notify("Cannot check unnamed buffer", vim.log.levels.ERROR)
		return
	end

	local command = "check --file " .. vim.fn.shellescape(buffer_path) .. "--json-output"
	local output = cli.execute(command)
	if not output then
		return
	end

	vim.notify(output, vim.log.levels.INFO)
end

return M
