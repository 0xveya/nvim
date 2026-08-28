local function map(mode, lhs, rhs, desc, opts)
	opts = opts or {}
	if desc then
		opts.desc = desc
	end
	if opts.silent == nil then
		opts.silent = true
	end
	vim.keymap.set(mode, lhs, rhs, opts)
end

local function nmap(lhs, rhs, desc, opts)
	map("n", lhs, rhs, desc, opts)
end

local function xmap(lhs, rhs, desc, opts)
	map("x", lhs, rhs, desc, opts)
end

local function tmap(lhs, rhs, desc, opts)
	map("t", lhs, rhs, desc, opts)
end

vim.opt.hlsearch = true
nmap("<Esc>", "<cmd>nohlsearch<CR>")

nmap("<leader>pv", vim.cmd.Oil)

nmap("[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, "Go to previous [D]iagnostic message")
nmap("]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, "Go to next [D]iagnostic message")
nmap("<leader>e", vim.diagnostic.open_float, "Show diagnostic [E]rror messages")
nmap("<leader>q", vim.diagnostic.setloclist, "Open diagnostic [Q]uickfix list")

tmap("<Esc><Esc>", "<C-\\><C-n>", "Exit terminal mode")

nmap("<C-h>", "<C-w><C-h>", "Move focus to the left window")
nmap("<C-l>", "<C-w><C-l>", "Move focus to the right window")
nmap("<C-j>", "<C-w><C-j>", "Move focus to the lower window")
nmap("<C-k>", "<C-w><C-k>", "Move focus to the upper window")

nmap("<C-d>", "<C-d>zz")
nmap("<C-u>", "<C-u>zz")

vim.api.nvim_create_user_command("W", "w", {})
nmap("<leader>ri", "<cmd>wa<CR><cmd>!uv pip install -e .<CR>", "Install editable package")

nmap("<C-A-h>", "<cmd>split<CR>")
nmap("<C-A-v>", "<cmd>vsplit<CR>")

nmap("<M-j>", "<cmd>cnext<CR>")
nmap("<M-k>", "<cmd>cprev<CR>")

if not require("profile").lite then
	xmap("<leader>y", require("go_rename").rename_visual_assignment, "Rename the selected Go assignment")
	nmap("<leader>ga", "<cmd>GoCodeAction<CR>", "Go Code Action")
	nmap("<leader>grg", "<cmd>GoRename<CR>", "LSP Rename (Go)")
	nmap("<leader>gi", "<cmd>GoIfErr<CR>", "Add if err")
	nmap("<leader>gc", "<cmd>GoCmt<CR>", "Generate Comment")
	nmap("<leader>gj", "<cmd>GoAddTag json<CR>", "Add JSON tags")
	nmap("<leader>gy", "<cmd>GoAddTag yaml<CR>", "Add YAML tags")
	nmap("<leader>gq", "<cmd>GoAlt<CR>", "Switch to Test/Implementation file")
end
nmap("<leader>cl", vim.lsp.codelens.run, "Run Code Lens")
nmap("<leader>k", "<cmd>qa<CR>", "quit erm")
