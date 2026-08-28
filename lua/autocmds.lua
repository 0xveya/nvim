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

local compiledb_jobs = {}

vim.api.nvim_create_autocmd("BufWritePost", {
	desc = "Rebuild the XMake compilation database after changing a C++ module",
	group = group("user-cppm-compiledb", { clear = true }),
	pattern = "*.cppm",
	callback = function(event)
		local root = vim.fs.root(event.buf, "xmake.lua")
		if not root or compiledb_jobs[root] then
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

		compiledb_jobs[root] = true

		local function finish(result)
			compiledb_jobs[root] = nil
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
