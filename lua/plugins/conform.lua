local function in_42_dir(bufnr)
	local lazy = require("lazy.core.config")
	local plugin = lazy.plugins["dogshitnorm.nvim"]
	local dirs = plugin and plugin.opts and plugin.opts.active_dirs or {}
	local path = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))

	for _, dir in ipairs(dirs) do
		dir = vim.fs.normalize(vim.fn.expand(dir))
		if path == dir or vim.startswith(path, dir .. "/") then
			return true
		end
	end
	return false
end

local function c_formatters(bufnr)
	if in_42_dir(bufnr) then
		return { "norm42_fix" }
	end
	return { "clang-format" }
end

local prettier = vim.fn.resolve(vim.fn.exepath("prettier"))
local prettier_root = prettier ~= "" and vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(prettier))) or nil

local astro_plugin = prettier_root and vim.fs.joinpath(prettier_root, "prettier-plugin-astro", "dist", "index.js")
	or "prettier-plugin-astro"

return {
	{
		"stevearc/conform.nvim",

		opts = {
			notify_on_error = false,

			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},

			formatters_by_ft = {
				lua = { "stylua" },

				astro = { "prettier_astro" },
				css = { "prettier" },
				scss = { "prettier" },
				less = { "prettier" },
				html = { "prettier" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },

				python = function(bufnr)
					if in_42_dir(bufnr) then
						return { "ruff_format_42" }
					end
					return { "ruff_format" }
				end,

				c = c_formatters,
				cpp = { "clang-format" },

				go = { "goimports" },
				powershell = { "ps_formatter" },
				sql = { "sleek" },
			},

			formatters = {
				ruff_format_42 = {
					command = "ruff",
					args = { "format", "--config", vim.fn.expand("~/.config/ruff/pyproject-42.toml"), "-" },
					stdin = true,
				},
				norm42_fix = {
					command = "python3",
					args = {
						vim.fs.joinpath(vim.fn.stdpath("config"), "scripts", "norm42_fix.py"),
						"$FILENAME",
					},
					stdin = true,
				},
			},
		},

		config = function(_, opts)
			require("conform").setup(opts)
		end,
	},
}
