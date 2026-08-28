local group = vim.api.nvim_create_augroup

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight yanked text",
	group = group("user-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
	desc = "Remove stale ShaDa temporary files",
	group = group("user-clean-shada", { clear = true }),
	callback = function()
		local shada_dir = vim.fs.joinpath(vim.fn.stdpath("state"), "shada")
		for _, file in ipairs(vim.fn.glob(shada_dir .. "/main.shada.tmp.*", false, true)) do
			vim.fs.rm(file)
		end
	end,
})
