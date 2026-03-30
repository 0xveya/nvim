return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("gd", function()
						Snacks.picker.lsp_definitions()
					end, "[G]oto [D]efinition")
					map("gr", function()
						Snacks.picker.lsp_references()
					end, "[G]oto [R]eferences")
					map("gI", function()
						Snacks.picker.lsp_implementations()
					end, "[G]oto [I]mplementation")
					map("<leader>D", function()
						Snacks.picker.lsp_type_definitions()
					end, "Type [D]efinition")
					map("<leader>ds", function()
						Snacks.picker.lsp_symbols()
					end, "[D]ocument [S]ymbols")
					map("<leader>ws", function()
						Snacks.picker.lsp_workspace_symbols()
					end, "[W]orkspace [S]ymbols")

					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

					map("K", vim.lsp.buf.hover, "Hover Documentation")
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					local client = vim.lsp.get_client_by_id(event.data.client_id)

					if client and client:supports_method("textDocument/documentHighlight") then
						local highlight_augroup = vim.api.nvim_create_augroup("user-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("user-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "user-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					if client and client:supports_method("textDocument/inlayHint") then
						pcall(function()
							vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
						end)

						vim.keymap.set("n", "<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, { buffer = event.buf, desc = "[T]oggle Inlay [H]ints" })
					end

					if client and client:supports_method("textDocument/codeLens") then
						pcall(function()
							vim.lsp.codelens.enable(true, { bufnr = event.buf })
						end)
					end
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			local servers = {
				clangd = {
					cmd = { "clangd", "--header-insertion=iwyu", "--compile-commands-dir=." },
					root_dir = require("lspconfig.util").root_pattern(".clangd", ".git"),
					capabilities = {
						offsetEncoding = "utf-8",
					},
					on_new_config = function(new_config, new_root_dir)
						-- Add the include path relative to the project root
						table.insert(new_config.cmd, "-I" .. new_root_dir .. "/ex00/include")
					end,
				},
				lua_ls = {
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							workspace = {
								checkThirdParty = false,
								library = vim.api.nvim_get_runtime_file("", true),
							},
						},
					},
				},
				powershell_es = {
					settings = {
						powershell = {
							codeFormatting = {
								Preset = "Stroustrup",
							},
						},
					},
				},
				tinymist = {
					settings = {
						tinymist = {
							lint = {
								enabled = true,
								when = "onSave",
							},
						},
					},
					filetypes = { "typst" },
				},
				zls = {
					cmd = { "zls" },
					filetypes = { "zig", "zir" },
					root_dir = require("lspconfig.util").root_pattern("zls.json", "build.zig", ".git"),
					settings = {
						zls = {
							enable_inlay_hints = true,
							enable_snippets = true,
							warn_style = true,
							publish_diagnostics = true,
						},
					},
				},
			}

			require("mason").setup()

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua",
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						local opts = vim.tbl_deep_extend("force", {}, server, {
							capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {}),
						})

						require("lspconfig")[server_name].setup(opts)
					end,
				},
			})
		end,
	},
}
