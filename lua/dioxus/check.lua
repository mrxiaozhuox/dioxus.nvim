local M = {}

local cli = require("dioxus.cli")
local utils = require("dioxus.utils")
local float = require("dioxus.float")

-- dioxus-cli check file
M.check_buffer = function()
	local buffer_path = utils.get_current_buffer_path()

	if not buffer_path then
		vim.notify("Cannot check unnamed buffer", vim.log.levels.ERROR)
		return
	end

	if not cli.check_dx_cli() then
		vim.notify("dx (dioxus-cli) not found. Please install it first.", vim.log.levels.ERROR)
		return
	end

	local dx_cli = cli.dx_path or "dx"
	local command = dx_cli .. " check --file " .. vim.fn.shellescape(buffer_path) .. " --json-output"

	local output = vim.fn.system(command)

	local content = ""
	local lines = vim.split(output, "\n")
	for _, line in ipairs(lines) do
		local success, value = pcall(vim.json.decode, line)
		if success then
			vim.notify(vim.inspect(value), vim.log.levels.INFO)
			local temp = value.message or value.error or ""
			content = content .. temp .. "\n"
		end
	end

	content = content:gsub("\27%[[%d;]+m", "")

	float.create_float_window("Dioxus Check # Buffer", content)
end

return M
