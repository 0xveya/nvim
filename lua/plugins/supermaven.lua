return {
	"supermaven-inc/supermaven-nvim",
	lazy = false,
	-- pinned: upstream has a bug where BufEnter isn't added to the augroup,
	-- causing handlers to accumulate and race against persistence session restore.
	-- The fix lives in ~/.config/nvim/patches/supermaven-nvim.patch.
	-- Re-apply manually: ~/.config/nvim/scripts/apply-nvim-patches.sh apply supermaven-nvim
	-- To update: unpin, :Lazy update supermaven-nvim, re-pin, run the script above.
	pin = true,
	build = function()
		local patch_script = vim.fn.stdpath("config") .. "/scripts/apply-nvim-patches.sh"
		local result = vim.fn.system({
			patch_script,
			"apply",
			"supermaven-nvim",
		})
		vim.notify(
			vim.trim(result),
			vim.v.shell_error == 0 and vim.log.levels.INFO or vim.log.levels.ERROR,
			{ title = "nvim patches" }
		)
	end,
	config = function()
		require("supermaven-nvim").setup({
			keymaps = {
				accept_suggestion = "<Tab>",
				clear_suggestion = "<C-]>",
				accept_word = "<C-j>",
			},
			-- keys = table means "only ignore that filetype", true = ignore it
			ignore_filetypes = { yaml = true, markdown = true, help = true },
			color = {
				suggestion_color = "#888888",
				cterm = 244,
			},
			log_level = "warn",
			disable_inline_completion = false,
			disable_keymaps = false,
		})

		-- After persistence.nvim restores the session on VimEnter (nested=true),
		-- it can leave SUPERMAVEN_DISABLED=1 if the previous session ended stopped.
		-- vim.schedule here ensures we run *after* all VimEnter callbacks (including
		-- persistence's session restore), so we reliably get a clean start.
		vim.api.nvim_create_autocmd("VimEnter", {
			once = true,
			callback = function()
				vim.schedule(function()
					local api = require("supermaven-nvim.api")
					if not api.is_running() then
						vim.g.SUPERMAVEN_DISABLED = 0
						api.start()
					end
				end)
			end,
		})

		local function supermaven_patch_status()
			local listener = vim.fn.stdpath("data")
				.. "/lazy/supermaven-nvim/lua/supermaven-nvim/document_listener.lua"
			if vim.fn.filereadable(listener) == 0 then
				return "patch: plugin file not found"
			end
			for _, line in ipairs(vim.fn.readfile(listener)) do
				if line:find("group = M.augroup", 1, true) then
					return "patch: applied (local Supermaven fix keeps BufEnter handlers in the augroup)"
				end
			end
			return "patch: missing (run scripts/apply-nvim-patches.sh apply supermaven-nvim)"
		end

		-- Override :SupermavenStatus to actually show something on screen.
		-- The upstream version writes to the log file only (log:trace), which is
		-- why running the command appears to do nothing.
		vim.api.nvim_create_user_command("SupermavenStatus", function()
			local api = require("supermaven-nvim.api")
			local running = api.is_running()
			vim.notify(
				table.concat({
					"Supermaven is " .. (running and "running ✓" or "NOT running ✗"),
					supermaven_patch_status(),
					"note: this config uses a patched Supermaven checkout; it helped with session restore/autocmd buildup.",
				}, "\n"),
				running and vim.log.levels.INFO or vim.log.levels.WARN,
				{ title = "Supermaven" }
			)
		end, { desc = "Show Supermaven status" })
	end,
}
