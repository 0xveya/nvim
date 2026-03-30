return {
	{
		"stevearc/conform.nvim",
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				return {
					timeout_ms = 500,
					lsp_fallback = true,
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				powershell = { "ps_formatter" },
				go = { "goimports" },
				c = { "c_formatter_42" },
				-- cpp = { "c_formatter_42" },
				sql = { "sleek" },
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
		config = function(_, opts)
			require("conform").setup(opts)
		end,
	},
}
