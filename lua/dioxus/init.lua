local M = {}

M.default_opts = {
	cli_path = nil,
	format = {
		split_line_attributes = false,
	},
}

local translate = require("dioxus.translate")
local format = require("dioxus.format")
local check = require("dioxus.check")

-- configure
M.setup = function(opts)
	M.opts = vim.tbl_deep_extend("force", M.default_opts, opts or {})

	local cli = require("dioxus.cli")
	if M.opts.cli_path then
		cli.dx_path = M.opts.cli_path
	end

	format.setup(M.opts.format)

	if not cli.check_dx_cli() then
		vim.notify("dx (dioxus-cli) not found.\n" .. "Install with: cargo install dioxus-cli", vim.log.levels.ERROR)
	end
end

M.setup_commands = function()
	vim.api.nvim_create_user_command("DxTranslateInline", function()
		translate.translate_selection()
	end, { range = true, desc = "Translate selected HTML to rsx" })

	vim.api.nvim_create_user_command("DxTranslatePrompt", function()
		translate.translate_prompt()
	end, { desc = "Translate HTML to rsx via input prompt" })

	vim.api.nvim_create_user_command("DxFormatInline", function()
		format.format_selection()
	end, { range = true, desc = "Format selected rsx block" })
	vim.api.nvim_create_user_command("DxFormatBuffer", function()
		format.format_buffer()
	end, { range = true, desc = "Format .rs file which include rsx block" })
	vim.api.nvim_create_user_command("DxCheckBuffer", function()
		check.check_buffer()
	end, { range = true, desc = "Check dioxus code" })
end

-- inital
M.setup()
M.setup_commands()

return M
