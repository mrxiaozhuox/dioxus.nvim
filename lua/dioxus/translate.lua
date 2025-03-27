local M = {}

local cli = require("dioxus.cli")

-- translate selected html into rsx
M.translate_selection = function()
	local start_buf, start_row, start_col, _ = unpack(vim.fn.getpos("'<"))
	local _, end_row, end_col, _ = unpack(vim.fn.getpos("'>"))

	local lines = vim.fn.getline(start_row, end_row)

	local content = type(lines) == "table" and table.concat(lines, "\n") or tostring(lines)

	local output = cli.execute("translate --raw " .. vim.fn.shellescape(content))
	if not output then
		return
	end

	local end_line_text = vim.api.nvim_buf_get_lines(start_buf, end_row - 1, end_row, false)[1] or ""
	local actual_end_col = math.min(end_col, #end_line_text)

	local output_lines = {}
	for line in string.gmatch(output, "[^\r\n]+") do
		table.insert(output_lines, line)
	end

	if #output_lines == 0 then
		output_lines = { "" }
	end

	vim.api.nvim_buf_set_text(start_buf, start_row - 1, start_col - 1, end_row - 1, actual_end_col, output_lines)
end

-- translate html by input
M.translate_prompt = function()
	local content = vim.fn.input("HTML Content")
	if content == "" then
		return
	end

	local output = cli.execute("translate --raw " .. vim.fn.shellescape(content))
	if not output then
		return
	end

	-- insert content into buffer
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row, col = cursor[1] - 1, cursor[2]

	local lines = {}
	for line in output:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end

	vim.api.nvim_buf_set_text(bufnr, row, col, row, col, lines)
end

return M
