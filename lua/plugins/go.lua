return {
	{
		"ray-x/go.nvim",
		dependencies = {
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		ft = { "go", "gomod" },
		build = ':lua require("go.install").update_all_sync()',
		opts = {
			lsp_keymaps = false,
			verbose = false,
			lsp_codelens = false,
			lsp_cfg = {
				settings = {
					gopls = {
						gofumpt = true,
						staticcheck = true,
						usePlaceholders = true,
						completeUnimported = true,
						analyses = {
							ST1000 = false,
							unusedparams = true,
							unusedwrite = true,
							nilness = true,
						},
					},
				},
			},
			goimports = "gopls",
			gofmt = "gofumpt",
			lsp_gofumpt = true,
			lsp_on_attach = true,
			dap_debug = true,
		},
		config = function(_, opts)
			require("go").setup(opts)

			local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", { clear = true })
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*.go",
				callback = function()
					vim.lsp.buf.format({ async = false })
				end,
				group = format_sync_grp,
			})
		end,
	},
}
