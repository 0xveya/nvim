return {
	{
		"lervag/vimtex",
		init = function()
			vim.g.vimtex_quickfix_open_on_warning = 0
			vim.g.vimtex_view_method = "zathura"
			vim.g.vimtex_view_general_viewer = "zathura"
			vim.g.vimtex_quickfix_ignore_filters = {
				"Underfull",
				"Overfull",
				"geometry Warning",
			}
		end,
	},
}
