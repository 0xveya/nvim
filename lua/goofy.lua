local M = {}

function M.find(path)
	return vim.fs.find(".goofy", { path = path, upward = true })[1]
end

function M.args(path)
	local file = M.find(path)
	return file and { "--ignore-file", file } or {}
end

return M
