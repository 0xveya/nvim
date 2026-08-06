local function get_42_dirs()
	local ok, lazy_config = pcall(require, "lazy.core.config")
	if not ok then
		return {}
	end

	local plugin = lazy_config.plugins["dogshitnorm.nvim"]
	if not plugin or not plugin.opts then
		return {}
	end

	return plugin.opts.active_dirs or {}
end

local function in_active_dirs(bufnr)
	local file = vim.api.nvim_buf_get_name(bufnr)
	local path = vim.fn.fnamemodify(file, ":p")

	for _, dir in ipairs(get_42_dirs()) do
		local expanded = vim.fn.expand(dir)
		if path:match("^" .. vim.pesc(expanded)) then
			return true
		end
	end

	return false
end

local prettier_executable = vim.fn.resolve(vim.fn.exepath("prettier"))
local prettier_node_modules = prettier_executable ~= ""
		and vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(prettier_executable)))
	or nil
local prettier_astro_plugin = prettier_node_modules
		and vim.fs.joinpath(prettier_node_modules, "prettier-plugin-astro", "dist", "index.js")
	or "prettier-plugin-astro"

return {
	{
		"stevearc/conform.nvim",
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				return {
					timeout_ms = 500,
					lsp_fallback = true,
				}
			end,
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
					if in_active_dirs(bufnr) then
						return {
							"ruff_format_42",
						}
					end
					return { "ruff_format" }
				end,
				powershell = { "ps_formatter" },
				go = { "goimports" },

				c = function(bufnr)
					if in_active_dirs(bufnr) then
						return { "c_formatter_42" }
					end
					return { "clang-format" }
				end,

				cpp = function(bufnr)
					if in_active_dirs(bufnr) then
						return { "c_formatter_42" }
					end
					return { "clang-format" }
				end,

				sql = { "sleek" },
			},
			formatters = {
				prettier_astro = {
					command = "prettier",
					args = {
						"--plugin=" .. prettier_astro_plugin,
						"--stdin-filepath",
						"$FILENAME",
					},
					stdin = true,
				},
				ps_formatter = {
					command = "ps-formatter",
					stdin = true,
				},
				c_formatter_42 = {
					command = "c_formatter_42",
					stdin = true,
				},
				ruff_format = {
					command = "ruff",
					args = { "format", "-" },
					stdin = true,
				},

				ruff_format_42 = {
					command = "ruff",
					args = { "format", "--config", vim.fn.expand("~/.config/ruff/pyproject-42.toml"), "-" },
					stdin = true,
				},
			},
		},
		config = function(_, opts)
			require("conform").setup(opts)
		end,
	},
}
