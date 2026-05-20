return {
	{
		"romus204/tree-sitter-manager.nvim",
		lazy = false,
		config = function()
			require("tree-sitter-manager").setup({
				ensure_installed = {
					"bash",
					"c",
					"css",
					"go",
					"gomod",
					"gosum",
					"gowork",
					"html",
					"javascript",
					"lua",
					"markdown",
					"markdown_inline",
					"query",
					"svelte",
					"typescript",
					"vim",
					"vimdoc",
					"yaml",
					"nix",
				},
				auto_install = false,
			})
		end,
	},
}
