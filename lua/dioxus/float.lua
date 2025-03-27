local M = {}

function M.create_float_window(title, content)
	-- 创建一个新的缓冲区
	local buf = vim.api.nvim_create_buf(false, true)

	-- 设置缓冲区内容
	if type(content) == "string" then
		content = vim.split(content, "\n")
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

	-- 计算窗口大小和位置
	local width = 100
	local height = #content
	local win_height = vim.o.lines
	local win_width = vim.o.columns
	local row = math.floor((win_height - height) / 2)
	local col = math.floor((win_width - width) / 2)

	-- 设置窗口选项
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

	-- 创建窗口
	local win = vim.api.nvim_open_win(buf, true, opts)

	-- 设置窗口选项
	vim.api.nvim_set_option_value("winblend", 10, { win = win })
	vim.api.nvim_set_option_value("cursorline", true, { win = win })

	-- 设置缓冲区选项-
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })

	-- 设置按 q 或 ESC 关闭窗口
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
	-- vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":close<CR>", { noremap = true, silent = true })

	return buf, win
end

return M
