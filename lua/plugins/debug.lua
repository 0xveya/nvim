return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"williamboman/mason.nvim",
		"jay-babu/mason-nvim-dap.nvim",
		"leoluz/nvim-dap-go",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		require("mason-nvim-dap").setup({
			automatic_setup = true,
			handlers = {},
			ensure_installed = { "delve" },
		})

		dapui.setup({
			icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
			controls = {
				icons = {
					pause = "⏸",
					play = "▶",
					step_into = "⏎",
					step_over = "⏭",
					step_out = "⏮",
					step_back = "b",
					run_last = "▶▶",
					terminate = "⏹",
					disconnect = "⏏",
				},
			},
			layouts = {
				{
					elements = { "scopes", "breakpoints", "stacks", "watches" },
					size = 40,
					position = "left",
				},
				{
					elements = { "repl" },
					size = 10,
					position = "bottom",
				},
			},
		})

		dap.listeners.after.event_initialized["dapui_config"] = function()
			vim.defer_fn(function()
				dapui.open({ reset = true })
			end, 50)
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		-- Basic debugging keymaps
		vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
		vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
		vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
		vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
		vim.keymap.set("n", "<F9>", dapui.toggle, { desc = "Debug: Toggle UI" })
		vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
		vim.keymap.set("n", "<leader>B", function()
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end, { desc = "Debug: Set Breakpoint" })

		local function shellwords(str)
			local args, i, n = {}, 1, #str
			while i <= n do
				while i <= n and str:sub(i, i):match("%s") do
					i = i + 1
				end
				if i > n then
					break
				end
				local c = str:sub(i, i)
				local quote = (c == '"' or c == "'") and c or nil
				local arg = ""
				if quote then
					i = i + 1
					while i <= n do
						local ch = str:sub(i, i)
						if ch == "\\" and quote == '"' and i < n then
							i = i + 1
							ch = str:sub(i, i)
							arg = arg .. ch
							i = i + 1
						elseif ch == quote then
							i = i + 1
							break
						else
							arg = arg .. ch
							i = i + 1
						end
					end
				else
					while i <= n and not str:sub(i, i):match("%s") do
						arg = arg .. str:sub(i, i)
						i = i + 1
					end
				end
				table.insert(args, arg)
			end
			return args
		end

		require("dap-go").setup({
			delve = {
				detached = false,
			},
		})

		dap.configurations.go = {
			{
				type = "go",
				name = "Debug (module root)",
				request = "launch",
				mode = "debug",
				program = "${workspaceFolder}",
				cwd = "${workspaceFolder}",
				console = "integratedTerminal",
			},
			{
				type = "go",
				name = "Debug (module root) with args",
				request = "launch",
				mode = "debug",
				program = "${workspaceFolder}",
				cwd = "${workspaceFolder}",
				console = "integratedTerminal",
				args = function()
					local input = vim.fn.input("Args: ")
					return shellwords(input)
				end,
			},
			{
				type = "go",
				name = "Debug (current dir) with args",
				request = "launch",
				mode = "debug",
				program = ".",
				cwd = "${fileDirname}",
				console = "integratedTerminal",
				args = function()
					local input = vim.fn.input("Args: ")
					return shellwords(input)
				end,
			},
		}
	end,
}
