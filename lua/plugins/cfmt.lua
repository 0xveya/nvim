return {
	"cacharle/c_formatter_42.vim",
	config = function()
		vim.api.nvim_create_augroup("c_42", { clear = true })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = "c_42",
			pattern = { "*.c", "*.cpp" },
			callback = function()
				vim.cmd("CFormatter42")
			end,
		})
	end,
}
