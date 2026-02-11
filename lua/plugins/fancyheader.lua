return {
	"Stefanistkuhl/fancy-header.nvim",
	ft = { "c", "cpp", "h" },

	opts = {
		colors = {
			box = { fg = "#6e6a86" },
			filename = { fg = "#f6c177", bold = true },
			author = { fg = "#9ccfd8" },
			date = { fg = "#c4a7e7" },

			logo_42 = { start = "#eb6f92", end_ = "#31748f" },
		},
	},

	keys = {
		{ "<leader>4h", "<cmd>HeaderToggle<cr>", desc = "Toggle 42 Header" },
	},
}
