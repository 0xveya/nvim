local goofy = require("goofy")

local function new_visible_files_cache()
	return setmetatable({}, {
		__index = function(cache, directory)
			local command = {
				"fd",
				"--max-depth",
				"1",
				"--min-depth",
				"1",
				"--hidden",
				"--no-require-git",
				"--strip-cwd-prefix",
			}
			vim.list_extend(command, goofy.args(directory))
			local result = vim.system(command, { cwd = directory, text = true }):wait()
			local visible = result.code == 0 and {} or false
			if visible then
				for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
					visible[line:gsub("/$", "")] = true
				end
			end
			rawset(cache, directory, visible)
			return visible
		end,
	})
end

local visible_files = new_visible_files_cache()

return {
	{
		"stevearc/oil.nvim",
		dependencies = { "echasnovski/mini.nvim" },
		config = function(_, opts)
			local refresh = require("oil.actions").refresh
			local refresh_callback = refresh.callback
			refresh.callback = function(...)
				visible_files = new_visible_files_cache()
				refresh_callback(...)
			end
			require("oil").setup(opts)
		end,
		opts = {
			default_file_explorer = true,
			columns = {
				"icon",
			},
			buf_options = {
				buflisted = false,
				bufhidden = "hide",
			},
			win_options = {
				wrap = false,
				signcolumn = "no",
				cursorcolumn = false,
				foldcolumn = "0",
				spell = false,
				list = false,
				conceallevel = 3,
				concealcursor = "nvic",
			},
			delete_to_trash = false,
			skip_confirm_for_simple_edits = false,
			prompt_save_on_select_new_entry = true,
			cleanup_delay_ms = 2000,
			lsp_file_methods = {
				timeout_ms = 1000,
				autosave_changes = false,
			},
			constrain_cursor = "editable",
			experimental_watch_for_changes = false,
			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-s>"] = "actions.select_vsplit",
				["<C-h>"] = "actions.select_split",
				["<C-t>"] = "actions.select_tab",
				["<C-p>"] = "actions.preview",
				["<C-x>"] = "actions.close",
				["<C-l>"] = "actions.refresh",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["`"] = "actions.cd",
				["~"] = "actions.tcd",
				["gs"] = "actions.change_sort",
				["gx"] = "actions.open_external",
				["g."] = "actions.toggle_hidden",
				["g\\"] = "actions.toggle_trash",
			},
			use_default_keymaps = false,
			view_options = {
				show_hidden = false,
				is_hidden_file = function(name, bufnr)
					if vim.startswith(name, ".") then
						return true
					end
					local directory = require("oil").get_current_dir(bufnr)
					local visible = directory and visible_files[directory]
					return visible and not visible[name] or false
				end,
				is_always_hidden = function(_, _)
					return false
				end,
				natural_order = true,
				sort = {
					{ "type", "asc" },
					{ "name", "asc" },
				},
			},
			extra_scp_args = {},
			git = {
				add = function(_)
					return false
				end,
				mv = function(_, _)
					return false
				end,
				rm = function(_)
					return false
				end,
			},
			float = {
				padding = 2,
				max_width = 0,
				max_height = 0,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
				override = function(conf)
					return conf
				end,
			},
			preview = {
				max_width = 0.9,
				min_width = { 40, 0.4 },
				width = nil,
				max_height = 0.9,
				min_height = { 5, 0.1 },
				height = nil,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
				update_on_cursor_moved = true,
			},
			progress = {
				max_width = 0.9,
				min_width = { 40, 0.4 },
				width = nil,
				max_height = { 10, 0.9 },
				min_height = { 5, 0.1 },
				height = nil,
				border = "rounded",
				minimized_border = "none",
				win_options = {
					winblend = 0,
				},
			},
			ssh = {
				border = "rounded",
			},
			keymaps_help = {
				border = "rounded",
			},
		},
	},
}
