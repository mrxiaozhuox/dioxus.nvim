local M = {}

function M.create_float_window(title, content)
	-- add buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- set content
	if type(content) == "string" then
		content = vim.split(content, "\n")
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

	-- window size & location
	local width = 100
	local height = math.min(#content, vim.o.lines - 10)
	local win_height = vim.o.lines
	local win_width = vim.o.columns
	local row = math.floor((win_height - height) / 2)
	local col = math.floor((win_width - width) / 2)

	-- window option
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = title,
		title_pos = "center",
	}

	local win = vim.api.nvim_open_win(buf, true, opts)

	vim.api.nvim_set_option_value("winblend", 10, { win = win })
	vim.api.nvim_set_option_value("cursorline", true, { win = win })

	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })

	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })

	return buf, win
end

return M
