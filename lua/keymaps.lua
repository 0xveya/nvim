vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<leader>pv", vim.cmd.Oil)

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.api.nvim_set_keymap("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.keymap.set("n", "<leader>r", ":RunCode<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>rf", ":RunFile<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>rft", ":RunFile tab<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>rp", ":RunProject<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>rc", ":RunClose<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>crf", ":CRFiletype<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>crp", ":CRProjects<CR>", { noremap = true, silent = false })
vim.api.nvim_create_user_command("W", "w", {})
vim.keymap.set("n", "<leader>rp", ":wa<CR>:!uv pip install -e .<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-A-h>", ":split<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-A-v>", ":vsplit<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>")
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>")
vim.keymap.set("n", "<leader>42", ":Stdheader<CR>")

vim.keymap.set("x", "<leader>y", function()
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
end, { desc = "Smart rename last variable in visual selection (ignores strings)" })

local map = vim.keymap.set

map("n", "<leader>ga", "<cmd>GoCodeAction<CR>", { desc = "Go Code Action" })
map("n", "<leader>grg", "<cmd>GoRename<CR>", { desc = "LSP Rename (Go)" })
map("n", "<leader>gi", "<cmd>GoIfErr<CR>", { desc = "Add if err" })
map("n", "<leader>gc", "<cmd>GoCmt<CR>", { desc = "Generate Comment" })

map("n", "<leader>gj", "<cmd>GoAddTag json<CR>", { desc = "Add JSON tags" })
map("n", "<leader>gy", "<cmd>GoAddTag yaml<CR>", { desc = "Add YAML tags" })

map("n", "<leader>gq", "<cmd>GoAlt<CR>", { desc = "Switch to Test/Implementation file" })
map("n", "<leader>gq", "<cmd>GoAlt<CR>", { desc = "Switch to Test/Implementation file" })
map("n", "<leader>cl", vim.lsp.codelens.run, { desc = "Run Code Lens" })
map("n", "<leader>k", "<cmd>qa<CR>", { desc = "quit erm" })
