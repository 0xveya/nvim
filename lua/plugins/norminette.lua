return {
	{
		"0xveya/dogshitnorm.nvim",
		ft = { "c", "cpp", "make" },
		dependencies = {
			"42Paris/42header",
		},
		opts = {
			cmd = { "uv", "tool", "run", "norminette" },
			args = { "--no-colors" },

			keybinding = "<leader>cn",
			lint_on_save = true,

			auto_header_guard = true,
			guard_keybinding = "<leader>ch",

			auto_makefile = true,
			makefile_keybinding = "<leader>cm",
			auto_sync_makefile = true,
			makesync_keybinding = "<leader>cu",

			active_dirs = {
				"~/coding/42",
			},
		},
	},
}
