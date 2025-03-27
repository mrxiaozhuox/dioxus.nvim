local M = {}

-- check dioxus cli
M.check_dx_cli = function()
	if vim.fn.executable("dx") == 1 then
		return true
	end

	-- check other possible path
	local common_paths = {
		-- Unix-liks
		vim.env.HOME .. "/.cargo/bin/dx",
		"/usr/local/bin/dx",
		"/usr/bin/dx",
		-- Windows
		vim.env.USERPROFILE .. "\\.cargo\\bin\\dx.exe",
	}

	for _, path in ipairs(common_paths) do
		if vim.fn.executable(path) == 1 then
			M.dx_path = path
			return true
		end
	end

	return false
end

M.execute = function(args)
	if not M.check_dx_cli() then
		vim.notify("dx (dioxus-cli) not found. Please install it first.", vim.log.levels.ERROR)
		return nil
	end

	local cli = M.dx_path or "dx"
	local command = cli .. " " .. args

	local result = vim.fn.system(command)
	if vim.v.shell_error ~= 0 then
		vim.notify("[dx] failed: " .. result, vim.log.levels.ERROR)
		return nil
	end

	return result
end

return M
