local specs = { "tpope/vim-sleuth" }

for _, name in ipairs({
	"cmp",
	"conform",
	"gitsigns",
	"lspconfig",
	"mini",
	"norminette",
	"oil",
	"rose-pine",
	"snacks",
	"todo-comments",
	"treesitter",
}) do
	vim.list_extend(specs, require("plugins." .. name))
end

return specs
