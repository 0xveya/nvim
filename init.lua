vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.winborder = "rounded"
vim.env.LUASNIP_OVERRIDE_LOGPATH = "/tmp"

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

vim.g.omni_sql_no_default_maps = 1
vim.opt.sessionoptions =
	{ "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds", "localoptions" }
vim.env.PATH = vim.env.HOME .. "/.local/share/mise/shims:" .. vim.env.PATH

local gns3util_root = vim.fs.normalize(vim.fn.expand("~/coding/gns3util"))

local old_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]

vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
	if result and result.uri then
		local path = vim.fs.normalize(vim.uri_to_fname(result.uri))

		if vim.startswith(path, gns3util_root) and result.diagnostics then
			result.diagnostics = vim.tbl_filter(function(d)
				return not (
					d.message
					and d.message:match("comment on exported")
					and d.message:match("should be of the form")
				)
			end, result.diagnostics)
		end
	end

	return old_handler(err, result, ctx, config)
end

vim.filetype.add({
	extension = {
		sh = "bash",
	},
})
