return {
	{
		"0xveya/dogshitnorm.nvim",
		ft = { "c", "cpp", "make" },

		opts = {
			cmd = { "uv", "tool", "run", "norminette" },

			args = { "--no-colors" },
			keybinding = "<leader>cn",
			lint_on_save = true,
			active_dirs = {
				"~/coding/42",
			},
		},
	},
}
