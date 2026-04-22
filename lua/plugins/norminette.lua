return {
	{
		"0xveya/dogshitnorm.nvim",
		dir = "/home/veya/coding/dogshitnorm",
		ft = { "c", "cpp", "make" },
		opts = {
			cmd = { "uv", "tool", "run", "norminette" },
			args = { "--no-colors" },

			keybinding = "<leader>cn",
			lint_on_save = true,

			auto_42_header = true,
			update_42_header = true,
			auto_header_guard = true,
			header_keybinding = "<leader>42",
			header_style_enabled = true,
			header_style_keybinding = "<leader>4h",
			header_colors = {
				box = { fg = "#6e6a86" },
				filename = { fg = "#f6c177", bold = true },
				author = { fg = "#9ccfd8" },
				date = { fg = "#c4a7e7" },
				logo_42 = { start = "#eb6f92", end_ = "#31748f" },
			},
			guard_keybinding = "<leader>ch",
			auto_sort_prototypes = true,
			line_count_enabled = true,
			header_line_number_offset = true,
			header_hide_enabled = false,
			line_count_keybinding = "<leader>Fc",
			line_count_formatter = function(count)
				local icon = "🤓"
				if count > 25 then
					icon = "⚠️"
				end
				return icon .. " " .. count
			end,
			line_saver_diagnostics = true,

			auto_makefile = true,
			makefile_keybinding = "<leader>cm",
			auto_sync_makefile = true,
			makesync_keybinding = "<leader>cu",
			makefile_exclude_dirs = { ".git", ".jj", "tests", "test", "build", "libft" },
			makefile_optional_libs = {
				{
					key = "libft",
					dirs = { "libft" },
					dir_var = "LIBFT_DIR",
					lib_var = "LIBFT",
					archive = "libft.a",
				},
				{
					key = "printf",
					dirs = { "ft_printf", "libprintf", "libftprintf" },
					dir_var = "PRINTF_DIR",
					lib_var = "PRINTF",
					archives = {
						ft_printf = "libftprintf.a",
						libprintf = "libftprintf.a",
						libftprintf = "libftprintf.a",
					},
				},
			},

			active_dirs = {
				"~/coding/42",
			},
		},
	},
}
