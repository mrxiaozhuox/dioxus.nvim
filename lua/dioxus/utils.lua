local M = {}

M.get_current_buffer_path = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local filepath = vim.api.nvim_buf_get_name(bufnr)
	if filepath == "" then
		return nil
	end
	if vim.fn.filereadable(filepath) == 0 then
		return nil
	end

	return filepath
end

return M
