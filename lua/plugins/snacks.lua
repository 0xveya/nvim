return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		bigfile = { enabled = true },
		dashboard = {
			enabled = true,
			formats = {
				key = function(item)
					return { { "[", hl = "special" }, { item.key, hl = "key" }, { "]", hl = "special" } }
				end,
			},
			sections = {
				{
					section = "terminal",
					cmd = "blahaj -s -c trans",
					hl = "header",
					padding = 2,
					indent = 0,
					height = 17,
					width = 80,
				},
				{ title = "MRU", padding = 1 },
				{ section = "recent_files", limit = 8, padding = 1 },
				{ title = "Sessions", padding = 1 },
				{ section = "projects", padding = 1 },
				{ section = "keys" },
			},
		},
		explorer = { enabled = false },
		indent = { enabled = true },
		input = { enabled = true },
		picker = {
			enabled = true,
			ui_select = true,
		},
		notifier = { enabled = true },
		quickfile = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = false },
		statuscolumn = { enabled = true },
		words = { enabled = true },
		gitbrowse = { enabled = true },
		git = { enabled = true },
		lazygit = { enabled = true, opts = {
			git = {
				overrideGpg = true,
			},
		} },
	},
	keys = {
		{
			"<leader>go",
			function()
				Snacks.gitbrowse()
			end,
			desc = "open origin",
		},
		{
			"<leader>gf",
			function()
				Snacks.gitbrowse({ what = "file" })
			end,
			desc = "doenst work on codeberg kekw",
		},
		{
			"<leader>lg",
			function()
				Snacks.lazygit()
			end,
			desc = "doenst work on codeberg kekw",
		},
		{
			"<leader>sh",
			function()
				Snacks.picker.help()
			end,
			desc = "[S]earch [H]elp",
		},
		{
			"<leader>sk",
			function()
				Snacks.picker.keymaps()
			end,
			desc = "[S]earch [K]eymaps",
		},
		{
			"<leader>sm",
			function()
				Snacks.picker.smart()
			end,
			desc = "Smart Find Files",
		},
		{
			"<leader>sf",
			function()
				Snacks.picker.files({ hidden = true, ignored = true })
			end,
			desc = "[S]earch [F]iles",
		},
		{
			"<leader>ss",
			function()
				Snacks.picker.pickers()
			end,
			desc = "[S]earch [S]elect Picker",
		},
		{
			"<leader>sw",
			function()
				Snacks.picker.grep_word()
			end,
			desc = "[S]earch current [W]ord",
		},
		{
			"<leader>sg",
			function()
				Snacks.picker.grep()
			end,
			desc = "[S]earch by [G]rep",
		},
		{
			"<leader>sd",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "[S]earch [D]iagnostics",
		},
		{
			"<leader>srn",
			function()
				Snacks.picker.resume()
			end,
			desc = "[S]earch [R]esume",
		},
		{
			"<leader>s.",
			function()
				Snacks.picker.recent()
			end,
			desc = '[S]earch Recent Files ("." for repeat)',
		},
		{
			"<leader><leader>",
			function()
				Snacks.picker.buffers()
			end,
			desc = "[ ] Find existing buffers",
		},

		{
			"<leader>sr",
			function()
				Snacks.picker.lsp_references()
			end,
			desc = "[S]earch [R]eferences",
		},

		{
			"<leader>/",
			function()
				Snacks.picker.lines({ layout = { preset = "vscode" } })
			end,
			desc = "[/] Fuzzily search in current buffer",
		},
		{
			"<leader>s/",
			function()
				Snacks.picker.grep({ buffers = true })
			end,
			desc = "[S]earch [/] in Open Files",
		},
		{
			"<leader>sn",
			function()
				Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "[S]earch [N]eovim files",
		},
		{
			"<leader>gB",
			function()
				Snacks.picker.git_branches()
			end,
			desc = "Git Branches",
		},
		{
			"<leader>gl",
			function()
				Snacks.picker.git_log()
			end,
			desc = "Git Log",
		},
		{
			"<leader>gL",
			function()
				Snacks.picker.git_log_line()
			end,
			desc = "Git Log Line",
		},
		{
			"<leader>gs",
			function()
				Snacks.picker.git_status()
			end,
			desc = "Git Status",
		},
		{
			"<leader>gS",
			function()
				Snacks.picker.git_stash()
			end,
			desc = "Git Stash",
		},
		{
			"<leader>gd",
			function()
				Snacks.picker.git_diff()
			end,
			desc = "Git Diff (Hunks)",
		},
		{
			"<leader>gf",
			function()
				Snacks.picker.git_log_file()
			end,
			desc = "Git Log File",
		},
	},
}
