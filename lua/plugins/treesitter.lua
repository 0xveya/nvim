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
			local ts_runtime = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/runtime"
			if vim.fn.isdirectory(ts_runtime) == 1 then
				vim.opt.runtimepath:append(ts_runtime)
			end

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
				"css",
				"go",
				"gomod",
				"gosum",
				"gowork",
				"html",
				"javascript",
				"lua",
				"markdown",
				"markdown_inline",
				"query",
				"svelte",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
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
					"css",
					"go",
					"gomod",
					"gosum",
					"gowork",
					"gleep",
					"html",
					"javascript",
					"lua",
					"markdown",
					"query",
					"svelte",
					"typescript",
					"vim",
					"vimdoc",
					"yaml",
					"zig",
					"nu",
				},
				callback = function(ev)
					pcall(vim.treesitter.start, ev.buf)
				end,
			})
		end,
	},
}
