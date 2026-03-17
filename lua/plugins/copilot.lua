return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			local suggestion = require("copilot.suggestion")

			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = true,
					debounce = 0,
					keymap = {
						accept = false,
						accept_word = false,
						accept_line = false,
						next = "<M-]>",
						prev = "<M-[>",
						dismiss = "<M-f>",
					},
				},
				panel = { enabled = false },
				filetypes = {
					yaml = false,
					markdown = false,
					help = false,
					["."] = false,
				},
			})

			vim.keymap.set("i", "<Tab>", function()
				if suggestion.is_visible() then
					suggestion.accept()
				else
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
				end
			end, { desc = "Copilot Accept or Tab", silent = true })
		end,
	},
}
