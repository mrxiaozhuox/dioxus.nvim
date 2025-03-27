local M = {}

-- 默认配置
M.setup = function(opts)
	opts = opts or {}
	M.config = {}
end

-- convert selected html into rsx
M.convert_selection = function()
	local start_buf, start_row, start_col, _ = unpack(vim.fn.getpos("'<"))
	local _, end_row, end_col, _ = unpack(vim.fn.getpos("'>"))

	local lines = vim.fn.getline(start_row, end_row)

	local content = type(lines) == "table" and table.concat(lines, "\n") or tostring(lines)

	vim.notify(content, vim.log.levels.DEBUG)
	local command = "dx translate --raw " .. vim.fn.shellescape(content)

	local output = vim.fn.system(command)
	if vim.v.shell_error ~= 0 then
		vim.notify("Translate Failed: " .. output, vim.log.levels.ERROR)
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

	vim.notify(output, vim.log.levels.DEBUG)
end

-- convert html by input
M.convert_raw_html = function()
	local html = vim.fn.input("Input HTML")
	if html == "" then
		return
	end

	local command = "dx translate --raw " .. vim.fn.shellescape(html)

	local output = vim.fn.system(command)
	if vim.v.shell_error ~= 0 then
		vim.notify("Translate Failed: " .. output, vim.log.levels.ERROR)
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

M.setup_commands = function()
	vim.api.nvim_create_user_command("HtmlToDioxus", function()
		M.convert_selection()
	end, { range = true })

	vim.api.nvim_create_user_command("HtmlToDioxusRaw", function()
		M.convert_raw_html()
	end, {})
end

-- inital
M.setup()
M.setup_commands()

return M
