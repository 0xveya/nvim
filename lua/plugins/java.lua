return {
	"nvim-java/nvim-java",
	config = function()
		require("java").setup()
		vim.lsp.config("jdtls", {
			cmd = { "/home/veya/.local/bin/jdtls" },
		})
		vim.lsp.enable("jdtls")
	end,
}
