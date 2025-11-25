local M = {}

M.default_opts = {
	split_line_attributes = false,
}

local cli = require("dioxus.cli")

M.setup = function(opts)
	M.opts = vim.tbl_deep_extend("force", {}, M.default_opts, opts or {})
end

M.format_buffer = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local content = table.concat(lines, "\n")

	local temp_file = vim.fn.tempname() .. ".rs"
	local file = io.open(temp_file, "w")
	if not file then
		vim.notify("Failed to create temporary file", vim.log.levels.ERROR)
		return
	end
	file:write(content)
	file:close()

	local command = "fmt --file " .. vim.fn.shellescape(temp_file)

	-- additonal args
	if M.opts and M.opts.split_line_attributes then
		command = command .. " --split-line-attributes"
	end

	local output = cli.execute(command)

	if not output then
		return
	end

	file = io.open(temp_file, "r")
	if not file then
		vim.notify("Failed to read formatted file", vim.log.levels.ERROR)
		os.remove(temp_file)
		return
	end

	local formatted_content = file:read("*all")
	file:close()
	os.remove(temp_file)

	if formatted_content == content then
		return
	end

	local formatted_lines = vim.split(formatted_content, "\n", { trimempty = true })

	local cursor_pos = vim.api.nvim_win_get_cursor(0)

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted_lines)

	vim.api.nvim_win_set_cursor(0, cursor_pos)
end

M.format_selection = function()
	local start_buf, start_row, start_col, _ = unpack(vim.fn.getpos("'<"))
	local _, end_row, end_col, _ = unpack(vim.fn.getpos("'>"))

	local lines = vim.fn.getline(start_row, end_row)

	local content = type(lines) == "table" and table.concat(lines, "\n") or tostring(lines)

	local command = "fmt --raw " .. vim.fn.shellescape(content)

	-- additonal args
	if M.opts and M.opts.split_line_attributes then
		command = command .. " --split-line-attributes"
	end

	local output = cli.execute(command)
	if not output then
		return
	end

	local end_line_text = vim.api.nvim_buf_get_lines(start_buf, end_row - 1, end_row, false)[1] or ""
	local actual_end_col = math.min(end_col, #end_line_text)

	local output_lines = vim.split(output, "\n", { trimempty = true })

	if #output_lines == 0 then
		output_lines = { "" }
	end

	vim.api.nvim_buf_set_text(start_buf, start_row - 1, start_col - 1, end_row - 1, actual_end_col, output_lines)
end

return M
