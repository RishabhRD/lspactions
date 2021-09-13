# [WIP] lspactions

This plugin contains solutions to lsp actions that are not so good to handle
with:
- default lsp handler
- telescope

Instead of adding all possible lsp-handlers like nvim-lsputils, I am aiming
to add some that doesn't have good solution present already.

## Dependencies

- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [popup.nvim](https://github.com/nvim-lua/popup.nvim)
- [astronauta.nvim](https://github.com/nvim-lua/astronauta.nvim) ... for lua keymaps (I don't want to write it again)

## Current handlers

### rename

``nnoremap <leader>ar require'lspactions.rename'``

It doesn't have any of problem that neovim's prompt buffer have that means
prompt has old name as initial text and user can seamlessly edit the text
inside prompt.


