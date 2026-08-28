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
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10

local minishell_dir = vim.fs.normalize(vim.fn.expand("~/Downloads/minishell"))
local current_dir = vim.fs.normalize(vim.fn.getcwd())

if vim.env.VEYA_42_USER and vim.env.VEYA_42_MAIL then
	vim.g.user42 = vim.env.VEYA_42_USER
	vim.g.mail42 = vim.env.VEYA_42_MAIL
elseif current_dir == minishell_dir or vim.startswith(current_dir, minishell_dir .. "/") then
	vim.g.user42 = "flaltens"
	vim.g.mail42 = "flaltens@student.42vienna.com"
else
	vim.g.user42 = "sfurst"
	vim.g.mail42 = "sfurst@student.42vienna.com"
end
