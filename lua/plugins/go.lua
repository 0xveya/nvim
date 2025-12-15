return {
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			if not opts.servers then
				opts.servers = {}
			end
			opts.servers.gopls = {
				settings = {
					gopls = {
						formatting = {
							organizeImports = true,
						},
						analyses = {
							unusedparams = true,
							unusedwrite = true,
						},
						codeActions = {
							unusedparams = true,
						},
						completeUnimported = true,
						gofumpt = true,
						staticcheck = true,
						usePlaceholders = true,
					},
				},
			}
			return opts
		end,
	},
}
