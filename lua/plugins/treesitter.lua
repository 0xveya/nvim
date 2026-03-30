-- Register the local gleep parser (built from ~/coding/gleepSitter)
-- parser/gleep.so is loaded via runtimepath; queries live in queries/gleep/.
vim.filetype.add({ extension = { gleep = "gleep" } })
vim.opt.runtimepath:prepend(vim.fn.expand("~/coding/gleepSitter"))

return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			-- Register gleep as a known parser so nvim-treesitter won't complain
			local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
			parser_config.gleep = {
				install_info = {
					url = vim.fn.expand("~/coding/gleepSitter"),
					files = { "src/parser.c" },
				},
				filetype = "gleep",
			}

			---@diagnostic disable-next-line: missing-fields
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "bash", "c", "html", "lua", "markdown", "vim", "vimdoc" },
				auto_install = true,
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},
}
