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

nmap("[d", vim.diagnostic.goto_prev, "Go to previous [D]iagnostic message")
nmap("]d", vim.diagnostic.goto_next, "Go to next [D]iagnostic message")
nmap("<leader>e", vim.diagnostic.open_float, "Show diagnostic [E]rror messages")
nmap("<leader>q", vim.diagnostic.setloclist, "Open diagnostic [Q]uickfix list")

tmap("<Esc><Esc>", "<C-\\><C-n>", "Exit terminal mode")

nmap("<C-h>", "<C-w><C-h>", "Move focus to the left window")
nmap("<C-l>", "<C-w><C-l>", "Move focus to the right window")
nmap("<C-j>", "<C-w><C-j>", "Move focus to the lower window")
nmap("<C-k>", "<C-w><C-k>", "Move focus to the upper window")

nmap("<C-d>", "<C-d>zz")
nmap("<C-u>", "<C-u>zz")

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("user-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

nmap("<leader>r", "<cmd>RunCode<CR>", nil, { silent = false })
nmap("<leader>rf", "<cmd>RunFile<CR>", nil, { silent = false })
nmap("<leader>rft", "<cmd>RunFile tab<CR>", nil, { silent = false })
nmap("<leader>rp", "<cmd>RunProject<CR>", nil, { silent = false })
nmap("<leader>rc", "<cmd>RunClose<CR>", nil, { silent = false })
nmap("<leader>crf", "<cmd>CRFiletype<CR>", nil, { silent = false })
nmap("<leader>crp", "<cmd>CRProjects<CR>", nil, { silent = false })
vim.api.nvim_create_user_command("W", "w", {})
nmap("<leader>ri", "<cmd>wa<CR><cmd>!uv pip install -e .<CR>", "Install editable package")

nmap("<C-A-h>", "<cmd>split<CR>")
nmap("<C-A-v>", "<cmd>vsplit<CR>")

nmap("<M-j>", "<cmd>cnext<CR>")
nmap("<M-k>", "<cmd>cprev<CR>")
nmap("<leader>42", "<cmd>Stdheader<CR>")

xmap("<leader>y", function()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)

	vim.schedule(function()
		local start_pos = vim.fn.getpos("'<")
		local first_line = vim.fn.getline(start_pos[2])

		local lhs = string.match(first_line, "^(.-)%s*[:]?=")

		if not lhs then
			print("Could not detect an assignment (:= or =) on the first line.")
			return
		end

		local target_var = string.match(lhs, "([%w_]+)%s*$")

		if not target_var then
			print("Could not find a valid variable to rename.")
			return
		end

		vim.ui.input({ prompt = "Rename exact word '" .. target_var .. "' to: " }, function(new_name)
			if new_name and new_name ~= "" then
				local cmd = string.format(
					[['<,'>s/".\{-}"\|`.\{-}`\|\<%s\>/\=submatch(0)[0] == '"' || submatch(0)[0] == '`' ? submatch(0) : '%s'/ge]],
					target_var,
					new_name
				)
				vim.cmd(cmd)
				print(" Successfully renamed '" .. target_var .. "' to '" .. new_name .. "'")
			end
		end)
	end)
end, "Smart rename last variable in visual selection (ignores strings)")

nmap("<leader>ga", "<cmd>GoCodeAction<CR>", "Go Code Action")
nmap("<leader>grg", "<cmd>GoRename<CR>", "LSP Rename (Go)")
nmap("<leader>gi", "<cmd>GoIfErr<CR>", "Add if err")
nmap("<leader>gc", "<cmd>GoCmt<CR>", "Generate Comment")

nmap("<leader>gj", "<cmd>GoAddTag json<CR>", "Add JSON tags")
nmap("<leader>gy", "<cmd>GoAddTag yaml<CR>", "Add YAML tags")

nmap("<leader>gq", "<cmd>GoAlt<CR>", "Switch to Test/Implementation file")
nmap("<leader>cl", vim.lsp.codelens.run, "Run Code Lens")
nmap("<leader>k", "<cmd>qa<CR>", "quit erm")
