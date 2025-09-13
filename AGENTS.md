# Agent Guidelines for kickstart.nvim

## Tech Stack
- **Neovim Lua configuration** based on kickstart.nvim template
- **Plugin manager**: lazy.nvim
- **LSP**: nvim-lspconfig with Mason for auto-installation
- **Completion**: blink.cmp with LuaSnip for snippets
- **File finding**: telescope.nvim with fzf-native

## Build/Lint/Test Commands
- **Format Lua code**: `stylua .` (uses `.stylua.toml` config)
- **Check formatting**: `stylua --check .`
- **Plugin management**: `:Lazy` (update with `:Lazy update`)
- **LSP management**: `:Mason` (install LSPs/formatters)
- **Health check**: `:checkhealth` (diagnose issues)

## Code Style Guidelines
- **Indentation**: 2 spaces (enforced by .stylua.toml)
- **Line width**: 160 characters max
- **Quote style**: Auto-prefer single quotes
- **Function calls**: No parentheses for single string/table args
- **Comments**: Use `--` for single line, `--[[]]` for blocks
- **Variable naming**: snake_case for locals, PascalCase for modules
- **Imports**: Use `local module = require('module')` at file top
- **Plugin config**: Use `opts = {}` for simple setup, `config = function()` for complex
- **Keymaps**: Use descriptive `desc` field, group related maps with `which-key`

## Error Handling
- Use `pcall()` for optional plugin loading
- Check capabilities before using LSP features
- Validate existence before accessing vim options/functions