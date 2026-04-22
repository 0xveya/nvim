return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "j-hui/fidget.nvim", opts = {} },
		},
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			local function exe(name)
				local path = vim.fn.exepath(name)
				if path ~= "" then
					return path
				end
				return nil
			end

			local function with_capabilities(config)
				return vim.tbl_deep_extend("force", {}, config, {
					capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {}),
				})
			end

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
								vim.api.nvim_clear_autocmds({
									group = "user-lsp-highlight",
									buffer = event2.buf,
								})
							end,
						})
					end

					if client and client:supports_method("textDocument/inlayHint") then
						vim.keymap.set("n", "<leader>th", function()
							local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
							vim.lsp.inlay_hint.enable(not enabled, { bufnr = event.buf })
						end, { buffer = event.buf, desc = "[T]oggle Inlay [H]ints" })
					end

					if client and client:supports_method("textDocument/codeLens") then
						pcall(function()
							vim.lsp.codelens.enable(true, { bufnr = event.buf })
						end)
					end
				end,
			})

			local servers = {
				clangd = {
					cmd = { exe("clangd"), "--header-insertion=iwyu", "--offset-encoding=utf-8" },
					filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
					root_markers = {
						"compile_commands.json",
						"compile_flags.txt",
						".clangd",
						".git",
						".jj",
					},
				},

				lua_ls = {
					cmd = { exe("lua-language-server") },
					filetypes = { "lua" },
					root_markers = {
						".luarc.json",
						".luarc.jsonc",
						".luacheckrc",
						".stylua.toml",
						"stylua.toml",
						"selene.toml",
						"selene.yml",
						".git",
						".jj",
					},
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

				yamlls = {
					cmd = { exe("yaml-language-server"), "--stdio" },
					filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
					root_markers = { ".git", ".jj" },
					settings = {
						yaml = {
							validate = true,
							format = { enable = true },
							hover = true,
							completion = true,
							schemaStore = {
								enable = true,
							},
						},
					},
				},

				taplo = {
					cmd = { exe("taplo"), "lsp", "stdio" },
					filetypes = { "toml" },
					root_markers = {
						"taplo.toml",
						".taplo.toml",
						"pyproject.toml",
						"Cargo.toml",
						".git",
						".jj",
					},
				},

				basedpyright = {
					cmd = { exe("basedpyright-langserver"), "--stdio" },
					filetypes = { "python" },
					root_markers = {
						"pyproject.toml",
						"setup.py",
						"setup.cfg",
						"requirements.txt",
						"Pipfile",
						"pyrightconfig.json",
						".git",
						".jj",
					},
					settings = {
						basedpyright = {
							disableLanguageServices = true,
							analysis = {
								diagnosticMode = "openFilesOnly",
							},
						},
					},
				},

				ty = {
					cmd = { exe("ty"), "server" },
					filetypes = { "python" },
					root_markers = {
						"pyproject.toml",
						"setup.py",
						"setup.cfg",
						"requirements.txt",
						".git",
						".jj",
					},
					settings = {
						ty = {
							diagnosticMode = "off",
						},
					},
				},

				tinymist = {
					cmd = { exe("tinymist") },
					filetypes = { "typst" },
					root_markers = { "typst.toml", ".git", ".jj" },
					settings = {
						tinymist = {
							lint = {
								enabled = true,
								when = "onSave",
							},
						},
					},
				},

				zls = {
					cmd = { exe("zls") },
					filetypes = { "zig", "zir" },
					root_markers = { "build.zig", "build.zig.zon", ".git", ".jj" },
					settings = {
						zls = {
							zig_exe_path = exe("zig"),
							enable_inlay_hints = true,
							enable_snippets = true,
							warn_style = true,
							enable_build_on_save = true,
							build_on_save_step = "check",
						},
					},
				},
			}

			for server_name, server in pairs(servers) do
				if server.cmd and (not server.cmd[1] or server.cmd[1] == "") then
					vim.notify("Skipping " .. server_name .. ": missing executable", vim.log.levels.WARN)
				else
					vim.lsp.config(server_name, with_capabilities(server))
					vim.lsp.enable(server_name)
				end
			end
		end,
	},
}
