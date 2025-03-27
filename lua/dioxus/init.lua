local M = {}

-- 默认配置
M.setup = function(opts)
	opts = opts or {}
	M.config = {}
end

-- convert selected html into rsx
M.convert_selection = function()
	-- get select range
	local ok, visual_marks = pcall(function()
		return {
			start = vim.fn.getpos("'<"),
			end_pos = vim.fn.getpos("'>"),
		}
	end)

	if not ok or not visual_marks then
		vim.notify("Only select mode", vim.log.levels.WARN)
		return
	end

	-- get content
	local start_line, start_col = visual_marks.start[2], visual_marks.start[3]
	local end_line, end_col = visual_marks.end_pos[2], visual_marks.end_pos[3]

	-- check content
	if start_line <= 0 or end_line <= 0 then
		return
	end

	-- content
	local bufnr = vim.api.nvim_get_current_buf()
	local lines

	if start_line == end_line then
		local line = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, start_line, false)[1]
		if not line then
			vim.notify("无法获取选中内容", vim.log.levels.ERROR)
			return
		end

		start_col = math.min(start_col, #line + 1)
		end_col = math.min(end_col, #line + 1)

		local selected_text = string.sub(line, start_col, end_col)
		lines = { selected_text }
	else
		lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
		if #lines > 0 then
			local first_line = lines[1]
			local last_line = lines[#lines]

			start_col = math.min(start_col, #first_line + 1)
			end_col = math.min(end_col, #last_line + 1)

			lines[1] = string.sub(first_line, start_col)
			lines[#lines] = string.sub(last_line, 1, end_col)
		end
	end

	local html_content = table.concat(lines, "\n")

	if html_content == "" then
		return
	end

	-- command
	local command = "dx translate --raw " .. vim.fn.shellescape(html_content)

	vim.fn.jobstart(command, {
		on_stdout = function(_, data)
			if not data or #data < 1 or (data[1] == "" and #data == 1) then
				return
			end

			local end_line_content = vim.api.nvim_buf_get_lines(bufnr, end_line - 1, end_line, false)[1] or ""
			local safe_end_col = math.min(end_col, #end_line_content + 1)

			local start_row = start_line - 1
			local start_column = start_col - 1
			local end_row = end_line - 1
			local end_column = safe_end_col - 1

			if start_row < 0 or start_column < 0 or end_row < 0 or end_column < 0 then
				return
			end

			if start_row == end_row and end_column < start_column then
				end_column = start_column
			end

			local success, err = pcall(function()
				vim.api.nvim_buf_set_text(bufnr, start_row, start_column, end_row, end_column, data)
			end)

			if success then
				vim.notify("rsx translate successful!", vim.log.levels.INFO)
			else
				local cursor = vim.api.nvim_win_get_cursor(0)
				pcall(vim.api.nvim_buf_set_text, bufnr, cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2], data)
			end
		end,
		on_stderr = function(_, data)
			if data and #data > 1 and data[1] ~= "" then
				local error_msg = table.concat(data, "\n")
				vim.notify("Error: " .. error_msg, vim.log.levels.ERROR)
			end
		end,
		on_exit = function(_, exit_code)
			if exit_code ~= 0 then
				vim.notify("Error: " .. exit_code, vim.log.levels.ERROR)
			end
		end,
	})
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
