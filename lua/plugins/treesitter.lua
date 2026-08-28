return {
	{
		"romus204/tree-sitter-manager.nvim",
		lazy = false,
		config = function()
			local languages = {
				"astro",
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
				"nix",
				"query",
				"svelte",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
			}
			if require("profile").lite then
				languages = { "c", "lua", "query", "vim", "vimdoc" }
			end
			require("tree-sitter-manager").setup({
				ensure_installed = languages,
				auto_install = false,
			})
		end,
	},
}
