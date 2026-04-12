-- Neovim 0.12 + markdown preview in snacks picker can crash in Tree-sitter's
-- conceal path. Keep conceal for normal markdown buffers, but disable it in the
-- picker preview window.
if vim.w.snacks_picker_preview then
	vim.opt_local.conceallevel = 0
else
	vim.opt_local.conceallevel = 2
end
