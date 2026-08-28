local M = {}
local jobs = {}

function M.setup()
	vim.api.nvim_create_autocmd("BufWritePost", {
		desc = "Rebuild the XMake compilation database after changing a C++ module",
		group = vim.api.nvim_create_augroup("user-cppm-compiledb", { clear = true }),
		pattern = "*.cppm",
		callback = function(event)
			local root = vim.fs.root(event.buf, "xmake.lua")
			if not root or jobs[root] then
				return
			end

			local commands
			if vim.fn.executable("mise") == 1 and vim.uv.fs_stat(vim.fs.joinpath(root, "mise.toml")) then
				commands = { { "mise", "run", "compiledb" } }
			else
				commands = {
					{ "xmake", "build", "-a", "-y" },
					{ "xmake", "project", "-k", "compile_commands", "--lsp=clangd" },
				}
			end

			jobs[root] = true

			local function finish(result)
				jobs[root] = nil
				if result.code ~= 0 then
					local output = vim.trim(result.stderr ~= "" and result.stderr or result.stdout)
					vim.notify(output, vim.log.levels.ERROR, { title = "compile_commands.json" })
					return
				end

				local clangd = vim.lsp.get_clients({ bufnr = event.buf, name = "clangd" })[1]
				if clangd and vim.api.nvim_buf_is_valid(event.buf) then
					vim.api.nvim_buf_call(event.buf, function()
						vim.api.nvim_cmd({ cmd = "lsp", args = { "restart", "clangd" } }, {})
					end)
				end
				vim.notify("Regenerated compile_commands.json", vim.log.levels.INFO)
			end

			local function run(index)
				vim.system(commands[index], { cwd = root, text = true }, function(result)
					vim.schedule(function()
						if result.code == 0 and commands[index + 1] then
							run(index + 1)
						else
							finish(result)
						end
					end)
				end)
			end

			run(1)
		end,
	})
end

return M
