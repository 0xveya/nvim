return {
	"mfussenegger/nvim-dap",

	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
	},

	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		dapui.setup({
			icons = {
				expanded = "▾",
				collapsed = "▸",
				current_frame = "*",
			},

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
					elements = {
						"scopes",
						"breakpoints",
						"stacks",
						"watches",
					},
					size = 40,
					position = "left",
				},
				{
					elements = {
						"repl",
					},
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

		vim.keymap.set("n", "<F5>", dap.continue, {
			desc = "Debug: Start / Continue",
		})

		vim.keymap.set("n", "<F1>", dap.step_into, {
			desc = "Debug: Step Into",
		})

		vim.keymap.set("n", "<F2>", dap.step_over, {
			desc = "Debug: Step Over",
		})

		vim.keymap.set("n", "<F3>", dap.step_out, {
			desc = "Debug: Step Out",
		})

		vim.keymap.set("n", "<F9>", dapui.toggle, {
			desc = "Debug: Toggle UI",
		})

		vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, {
			desc = "Debug: Toggle Breakpoint",
		})

		vim.keymap.set("n", "<leader>B", function()
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end, {
			desc = "Debug: Conditional Breakpoint",
		})

		vim.keymap.set("n", "<leader>dr", dap.repl.open, {
			desc = "Debug: Open REPL",
		})

		vim.keymap.set("n", "<leader>dt", dap.terminate, {
			desc = "Debug: Terminate",
		})

		vim.keymap.set("n", "<leader>dl", dap.run_last, {
			desc = "Debug: Run Last",
		})

		local codelldb = vim.fn.exepath("codelldb")

		if codelldb == "" then
			vim.notify("codelldb not found in PATH", vim.log.levels.ERROR)
			return
		end

		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = codelldb,
				args = {
					"--port",
					"${port}",
				},
			},
		}

		dap.configurations.c = {
			{
				name = "Debug minishell",
				type = "codelldb",
				request = "launch",
				program = "${workspaceFolder}/minishell",
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				terminal = "external",
			},

			{
				name = "Debug arbitrary executable",
				type = "codelldb",
				request = "launch",

				program = function()
					return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
				end,

				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				terminal = "external",
			},

			{
				name = "Debug arbitrary executable with args",
				type = "codelldb",
				request = "launch",

				program = function()
					return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
				end,

				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				terminal = "external",

				args = function()
					local input = vim.fn.input("Args: ")

					if input == "" then
						return nil
					end

					return vim.split(input, " ", {
						trimempty = true,
					})
				end,
			},
		}

		dap.configurations.cpp = dap.configurations.c
	end,
}
