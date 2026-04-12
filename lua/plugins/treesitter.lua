-- Register the local gleep parser (built from ~/coding/gleepSitter)
-- parser/gleep.so is loaded via runtimepath; queries live in queries/gleep/.
vim.filetype.add({ extension = { gleep = "gleep" } })
vim.opt.runtimepath:prepend(vim.fn.expand("~/coding/gleepSitter"))

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")
			local parsers = require("nvim-treesitter.parsers")

			parsers.gleep = {
				install_info = {
					url = vim.fn.expand("~/coding/gleepSitter"),
					files = { "src/parser.c" },
				},
				filetype = "gleep",
				tier = 3,
			}

			ts.setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})

			local wanted = {
				"bash",
				"c",
				"go",
				"gomod",
				"gosum",
				"gowork",
				"html",
				"lua",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
			}
			local installed = {}
			for _, lang in ipairs(ts.get_installed()) do
				installed[lang] = true
			end
			local missing = vim.tbl_filter(function(lang)
				return not installed[lang]
			end, wanted)
			if #missing > 0 then
				ts.install(missing)
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("veya-treesitter-start", { clear = true }),
				pattern = {
					"bash",
					"c",
					"go",
					"gomod",
					"gosum",
					"gowork",
					"gleep",
					"html",
					"lua",
					"markdown",
					"query",
					"vim",
					"vimdoc",
				},
				callback = function(ev)
					pcall(vim.treesitter.start, ev.buf)
				end,
			})
		end,
	},
}
