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
		picker = { enabled = false },
		notifier = { enabled = true },
		quickfile = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = false },
		statuscolumn = { enabled = true },
		words = { enabled = true },
		gitbrowse = { enabled = true },
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
	},
}
