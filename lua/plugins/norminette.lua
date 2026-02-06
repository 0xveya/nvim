return {
	{
		"Stefanistkuhl/dogshitnorm.nvim",
		ft = { "c", "cpp" },

		opts = {
			cmd = { "uv", "tool", "run", "norminette" },

			args = { "--no-colors" },
			keybinding = "<leader>cn",
			lint_on_save = true,
		},
	},
}
