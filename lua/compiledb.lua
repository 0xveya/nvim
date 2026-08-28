local M = {}
local jobs = {}
local shapes = {}

local function module_shape(bufnr)
	local directives = {}
	for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
		local directive = line:match("^%s*(export%s+module%s+.-;)")
			or line:match("^%s*(module%s+.-;)")
			or line:match("^%s*(export%s+import%s+.-;)")
			or line:match("^%s*(import%s+.-;)")
		if directive then
			table.insert(directives, (directive:gsub("%s+", " ")))
		end
	end
	return table.concat(directives, "\n")
end

function M.setup()
	local group = vim.api.nvim_create_augroup("user-cppm-compiledb", { clear = true })

	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
		desc = "Remember C++ module dependencies",
		group = group,
		pattern = "*.cppm",
		callback = function(event)
			shapes[event.buf] = module_shape(event.buf)
		end,
	})

	vim.api.nvim_create_autocmd("BufDelete", {
		group = group,
		callback = function(event)
			shapes[event.buf] = nil
		end,
	})

	vim.api.nvim_create_autocmd("BufWritePost", {
		desc = "Rebuild the XMake compilation database after changing C++ module dependencies",
		group = group,
		pattern = "*.cppm",
		callback = function(event)
			local root = vim.fs.root(event.buf, "xmake.lua")
			local shape = module_shape(event.buf)
			if not root or jobs[root] or shapes[event.buf] == shape then
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
				shapes[event.buf] = shape

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

			vim.system({ "clangd", "--check=" .. event.file, "--compile-commands-dir=" .. root }, {
				cwd = root,
				text = true,
			}, function(result)
				vim.schedule(function()
					if result.code ~= 0 then
						jobs[root] = nil
						vim.notify("Not regenerating: clangd found C++ errors", vim.log.levels.WARN, {
							title = "compile_commands.json",
						})
						return
					end
					run(1)
				end)
			end)
		end,
	})
end

return M
