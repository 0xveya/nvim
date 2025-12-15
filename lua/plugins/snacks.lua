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
				-- i need to fix this kekw
				{ section = "terminal", cmd = "blahaj -s", hl = "header", padding = 1, indent = 8 },
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
	},
}
