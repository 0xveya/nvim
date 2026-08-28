# nvim

My personal Neovim 0.12 config. Plugins are managed by
[lazy.nvim](https://github.com/folke/lazy.nvim) and install automatically on
first launch.

## Install

```sh
jj git clone git@github.com:0xveya/nvim.git ~/.config/nvim
nvim
```

Requires Neovim 0.12, JJ, Git, a Nerd Font, and the tools used by enabled language
support. The main external tools are `fd`, `clangd`, `lua-language-server`, `ty`,
`typescript-language-server`, `svelteserver`, `gopls`, `rust-analyzer`,
`stylua`, `clang-format`, `ruff`, `prettier`, and `codelldb`. Missing language
servers are skipped. `mise`, XMake, `uv`, `go`, `zls`, `gleam`, `tinymist`,
`taplo`, and `sqlc` support are optional.

The core UI uses Rose Pine, Snacks, Oil, Mini, Gitsigns, Treesitter, `nvim-cmp`,
LuaSnip, Conform, DAP, persistence.nvim, and Supermaven. Plugin specs
and their configuration live in `lua/plugins/`.

## Use

The leader key is Space. Useful starting points:

- `<leader>pv` opens Oil.
- `<leader>sf` finds files; `<leader>sg` greps; `<leader><leader>` lists buffers.
- `gd`, `gr`, `K`, `<leader>rn`, and `<leader>ca` provide LSP navigation and actions.
- `<C-Space>` opens completion and `<C-y>` accepts it.
- `<leader>grg` renames Go symbols; visual `<leader>y` renames the selected assignment target.
- `<leader>qs` restores a session.
- `<F5>` starts debugging and `<F9>` toggles the debugger UI.

Snacks and Oil respect nested `.gitignore`, `.ignore`, and `.fdignore` files,
including in JJ-only repositories. Oil hides ignored build artifacts by default;
press `g.` to show or hide them.

Put extra picker-only ignores in a project-root `.goofy` using Gitignore syntax.
These paths stay visible to version control but disappear from Snacks and Oil.

Saving a `*.cppm` file in an XMake project regenerates `compile_commands.json`
through `mise run compiledb` when available, then restarts `clangd`.
