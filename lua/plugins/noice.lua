return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		cmdline = { enabled = true },
		messages = { enabled = false },
		popupmenu = { enabled = false },
		notify = { enabled = false },
		lsp = {
			progress = { enabled = true },
			hover = { enabled = true },
			signature = { enabled = true },
		},
		presets = { lsp_doc_border = true },
	},
	keys = {
		{
			"<c-f>",
			function()
				if not require("noice.lsp").scroll(4) then
					return "<c-f>"
				end
			end,
			silent = true,
			expr = true,
			desc = "Scroll Forward",
			mode = { "i", "n", "s" },
		},
		{
			"<c-b>",
			function()
				if not require("noice.lsp").scroll(-4) then
					return "<c-b>"
				end
			end,
			silent = true,
			expr = true,
			desc = "Scroll Backward",
			mode = { "i", "n", "s" },
		},
	},
	config = function(_, opts)
		require("noice").setup(opts)
	end,
}
