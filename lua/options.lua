vim.opt.number = true
vim.wo.relativenumber = true
vim.opt.winborder = "rounded"
vim.g.clipboard = "osc52"
vim.opt.sessionoptions =
	{ "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds", "localoptions" }

vim.filetype.add({
	extension = {
		sh = "bash",
	},
})
-- You can also add relative line numbers, for help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = "unnamedplus"

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace in the editor.
--  See :help 'list'
--  and :help 'listchars'
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

local minishell_dir = vim.fs.normalize(vim.fn.expand("~/Downloads/minishell"))
local current_dir = vim.fs.normalize(vim.fn.getcwd())

if current_dir == minishell_dir or vim.startswith(current_dir, minishell_dir .. "/") then
	vim.g.user42 = "flaltens"
	vim.g.mail42 = "flaltens@student.42vienna.com"
else
	vim.g.user42 = "sfurst"
	vim.g.mail42 = "sfurst@student.42vienna.com"
end

-- vim: ts=2 sts=2 sw=2 et
