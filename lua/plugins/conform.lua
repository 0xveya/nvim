return {
	{
		"stevearc/conform.nvim",
		opts = {
			notify_on_error = false,
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
			formatters_by_ft = {
				lua = { "stylua" },
				powershell = { "ps_formatter" },
				go = { "goimports" },
				c = { "c_formatter_42" },
				cpp = { "c_formatter_42" },
			},
			formatters = {
				ps_formatter = {
					command = "ps-formatter",
					stdin = true,
				},
				c_formatter_42 = {
					command = "c_formatter_42",
					stdin = true,
				},
			},
		},
	},
}
