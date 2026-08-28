vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.env.PATH = vim.env.HOME .. "/.local/share/mise/shims:" .. vim.env.PATH

require("options")
require("keymaps")
require("autocmds")
require("compiledb").setup()
require("diagnostics")
require("lazy-bootstrap")
require("lazy-plugins")

if not require("profile").lite then
	require("mistral_fix").setup({
		agent_id = "ag:a1053bd4:20251014:i-love-spelling:814f38c9",
	})
end

vim.o.autowriteall = true
