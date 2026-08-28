local M = {
	lite = vim.env.VEYA_NVIM_LITE == "1",
	coding_dir = vim.fs.normalize(vim.fn.expand(vim.env.VEYA_CODING_DIR or "~/coding")),
}

return M
