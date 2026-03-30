vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.winborder = "rounded"

require("options")

require("keymaps")

require("lazy-bootstrap")

require("lazy-plugins")

vim.g.clipboard = "osc52"

require("mistral_fix").setup({
	agent_id = "ag:a1053bd4:20251014:i-love-spelling:814f38c9",
})

vim.o.autowriteall = true

vim.cmd([[colorscheme rose-pine]])

local function CleanShaDaTmp()
	local shada_dir = vim.fn.stdpath("state") .. "/shada"
	local pattern = shada_dir .. "/main.shada.tmp.*"

	for _, file in ipairs(vim.fn.glob(pattern, false, true)) do
		os.remove(file)
	end
end

vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = CleanShaDaTmp,
})

vim.g.dbs = {
	{
		name = "wrapped",
		url = "duckdb:~/coding/uuhcordWrapped/data/wrapped.duckdb?access_mode=READ_ONLY",
	},
}

vim.keymap.set("v", "<leader>q", function()
	local dbs = vim.g.dbs or {}
	local choices = {}
	local db_map = {}

	for _, db in ipairs(dbs) do
		table.insert(choices, db.name)
		db_map[db.name] = db.url
	end

	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)

	vim.ui.select(choices, { prompt = "Select database: " }, function(choice)
		if choice then
			vim.schedule(function()
				vim.cmd("'<,'>DB " .. db_map[choice])
			end)
		end
	end)
end, { noremap = true })

vim.keymap.set("n", "<leader>db", function()
	local dbs = vim.g.dbs or {}
	local choices = {}
	local db_map = {}

	for _, db in ipairs(dbs) do
		table.insert(choices, db.name)
		db_map[db.name] = db.url
	end

	vim.ui.select(choices, { prompt = "Select DB for completion: " }, function(choice)
		if choice then
			vim.api.nvim_buf_set_var(0, "db", db_map[choice])
			print("Attached DB: " .. choice)
		end
	end)
end)
vim.g.vim_dadbod_completion_schemas = 1
vim.api.nvim_create_autocmd("BufEnter", {
	group = vim.api.nvim_create_augroup("coding42", { clear = true }),
	pattern = { vim.fn.expand("~/coding/42/*.c"), vim.fn.expand("~/coding/42/*.h") },
	command = "Stdheader",
})

vim.g.omni_sql_no_default_maps = 1
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds", "localoptions" }
vim.env.PATH = vim.env.HOME .. "/.local/share/mise/shims:" .. vim.env.PATH
