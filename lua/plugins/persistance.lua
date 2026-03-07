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
				local argc = vim.fn.argc()
				local arg = vim.fn.argv(0)

				if argc == 0 then
					require("persistence").load()
				elseif argc == 1 and vim.fn.isdirectory(arg) == 1 then
					vim.defer_fn(function()
						require("persistence").load()
					end, 10)
				end
			end,
		})
	end,
}
