return {
	"0xveya/go-mono-repo",
	opts = {
		persist = true,
		keymaps = {
			pick_scope = "<leader>ngl",
			narrow = "<leader>ngn",
			clear_narrow = "<leader>ngN",
		},
		override = {
			enabled = true,
			files = "<leader>ff",
			grep = "<leader>fg",
			symbols = "<leader>fs",
			handlers = "<leader>fh",
		},
	},
}
