local function apply_highlights()
	vim.api.nvim_set_hl(0, "Type", { fg = "#c4a7e7" })
	vim.api.nvim_set_hl(0, "@type", { fg = "#c4a7e7" })
	vim.api.nvim_set_hl(0, "@function", { fg = "#ebbcba" })
	vim.api.nvim_set_hl(0, "@constant.macro", { fg = "#d47a9f" })
	vim.api.nvim_set_hl(0, "@function.macro", { fg = "#d47a9f" })
end

return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("rose-pine")
			apply_highlights()
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("user-theme-highlights", { clear = true }),
				callback = apply_highlights,
			})
		end,
	},
}
