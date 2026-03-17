return {
	"folke/persistence.nvim",
	lazy = false,
	opts = {},
	config = function(_, opts)
		require("persistence").setup(opts)

		vim.keymap.set("n", "<leader>qs", function()
			require("persistence").load()
		end, { desc = "Restore Session" })
		vim.keymap.set("n", "<leader>ql", function()
			require("persistence").load({ last = true })
		end, { desc = "Restore Last Session" })
		vim.keymap.set("n", "<leader>qd", function()
			require("persistence").stop()
		end, { desc = "Don't Save Current Session" })

		vim.api.nvim_create_autocmd("VimEnter", {
			nested = true,
			callback = function()
				local arg = vim.fn.argv(0)
				if vim.fn.argc() == 0 or (vim.fn.argc() == 1 and vim.fn.isdirectory(arg) == 1) then
					require("persistence").load()
				end
			end,
		})
	end,
}
