local M = {}

local query = vim.treesitter.query.parse(
	"go",
	[[
    (short_var_declaration
      left: (expression_list (identifier) @target))
    (assignment_statement
      left: (expression_list (identifier) @target))
  ]]
)

function M.rename_visual_assignment()
	local bufnr = vim.api.nvim_get_current_buf()
	if vim.bo[bufnr].filetype ~= "go" then
		vim.notify("Visual assignment rename is only available for Go", vim.log.levels.WARN)
		return
	end

	local start = vim.api.nvim_buf_get_mark(bufnr, "<")
	local finish = vim.api.nvim_buf_get_mark(bufnr, ">")
	local start_row, start_col = start[1] - 1, start[2]
	local finish_row, finish_col = finish[1] - 1, finish[2]
	local root = vim.treesitter.get_parser(bufnr, "go"):parse()[1]:root()
	local target

	for _, node in query:iter_captures(root, bufnr, start_row, finish_row + 1) do
		local row, col, end_row, end_col = node:range()
		local inside = (row > start_row or col >= start_col) and (end_row < finish_row or end_col <= finish_col + 1)
		if inside and (not target or row < target.row or (row == target.row and col > target.col)) then
			target = { row = row, col = col }
		end
	end

	if not target then
		vim.notify("No Go assignment found in the selection", vim.log.levels.WARN)
		return
	end

	vim.api.nvim_win_set_cursor(0, { target.row + 1, target.col })
	vim.lsp.buf.rename()
end

return M
