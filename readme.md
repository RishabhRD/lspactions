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
- [astronauta.nvim](https://github.com/tjdevries/astronauta.nvim) ... for lua keymaps (I don't want to write it)

## Current handlers

### rename

```vim
nnoremap <leader>ar :lua require'lspactions.rename'()<CR>
```

It doesn't have any of problem that neovim's prompt buffer have that means
prompt has old name as initial text and user can seamlessly edit the text
inside prompt.

### codeaction

```lua
vim.lsp.handlers["textDocument/codeAction"] = require'lspactions.codeaction'
vim.cmd [[ nnoremap <leader>af :lua vim.lsp.buf.code_action()<CR> ]]
```

Floating menu for codeaction. You can scroll same as normal vim movements.
Press enter to select the action. Or like: press 4 to select action 4.
