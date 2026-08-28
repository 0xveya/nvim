local gns3util_root = vim.fs.normalize(vim.fn.expand("~/coding/gns3util"))
local publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]

vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
	if result and result.uri and result.diagnostics then
		local path = vim.fs.normalize(vim.uri_to_fname(result.uri))
		if vim.startswith(path, gns3util_root) then
			result.diagnostics = vim.tbl_filter(function(diagnostic)
				local message = diagnostic.message
				return not (message and message:match("comment on exported") and message:match("should be of the form"))
			end, result.diagnostics)
		end
	end

	return publish_diagnostics(err, result, ctx, config)
end
