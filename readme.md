# [WIP] lspactions

lspactions provide handlers for various lsp actions. lspactions targets to
be highly extensible and customizable. It uses floating windows for handlers **if it
really improves workflow**(I am biased) otherwise try to provide similar (but highy customizable)
handlers to nvim's default handlers.

**lspactions require neovim 0.5.1 release**

Current lspactions handlers:
- codeaction (floating win)
- rename (floating win + robust prompt)
- references (customizable quickfix)
- definition (customizable quickfix)
- declaration (customizable quickfix)
- implementation (customizable quickfix)

document\_symbols and workspace\_symbols are good with telescope and hence
is not targetted. If you feel there is some better way to do the same, feel
free to make a PR.

## Dependencies

- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [popup.nvim](https://github.com/nvim-lua/popup.nvim)
- [astronauta.nvim](https://github.com/tjdevries/astronauta.nvim) ... for lua keymaps (I don't want to write it)

## Installation

```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'tjdevries/astronauta.nvim'
Plug 'RishabhRD/lspactions'
```

## Current handlers

### rename

```vim
nnoremap <leader>ar :lua require'lspactions'.rename()<CR>
```

It doesn't have any of problem that neovim's prompt buffer have that means
prompt has old name as initial text and user can seamlessly edit the text
inside prompt.

![](https://user-images.githubusercontent.com/26287448/133168403-35d5c6e0-16ad-44ee-9d2e-e3d056016746.gif)

### codeaction

```lua
vim.lsp.handlers["textDocument/codeAction"] = require'lspactions'.codeaction
vim.cmd [[ nnoremap <leader>af :lua require'lspactions'.code_action()<CR> ]]
vim.cmd [[ nnoremap <leader>af :lua require'lspactions'.range_code_action()<CR> ]]
```

Floating menu for codeaction. You can scroll same as normal vim movements.
Press enter to select the action. Or like: press 4 to select action 4.

Customization:
```lua
vim.lsp.handlers["textDocument/codeAction"] = vim.lsp.with(require'lspactions'.codeaction, {
    transform = function(result) return result end,
    ui_select = vim.ui.select, -- NOT lspactions default
})
```

ui\_select has same specifications as ``vim.ui.select`` has. It describes how
user would be prompted to select a code action from a list of codeactions.
So providing ``vim.ui.select`` would provide selection menu as vim's default
selection menu. And not overriding this option would give a floating list as
selection menu.

transform function accepts a function that takes result returned from
lsp-server (extended result if you are using nvim 0.6) as argument, and return
a new result by making some transformation on it. The transformation can be
anything like sorting, etc.

![](https://user-images.githubusercontent.com/26287448/133169313-1c2118e3-48b8-47bc-b457-6e3a2ac9bca1.gif)

### references
```lua
vim.lsp.handlers["textDocument/references"] = require'lspactions'.references
vim.cmd [[ nnoremap <leader>af :lua vim.lsp.buf.references()<CR> ]]
```

Similar to lsp references, but way more customizable.

Customization:
```lua
vim.lsp.handlers["textDocument/references"] = vim.lsp.with(require'lspactions'.references, {
  open_list = true,
  jump_to_result = true,
  jump_to_list = false,
  loclist = false,
  always_qf = false,
  transform = function(result) return result end
})
```

- loclist: use location list instead
- open\_list: to open quickfix/loclist list or not
- jump\_to\_result: jump to first result of operation in current window
- jump\_to\_list: make quickfix/loclist list current window
- always\_qf: open quickfix/loclist even if there is only one result
- transform: a function that accepts result returned from lsp-server, do
some transformation on it(maybe like sorting) and return the new result.

### definition
```lua
vim.lsp.handlers["textDocument/definition"] = require'lspactions'.definition
vim.cmd [[ nnoremap <leader>af :lua vim.lsp.buf.definition()<CR> ]]
```

Similar to lsp definition, but way more customizable.

Customization:
```lua
vim.lsp.handlers["textDocument/definition"] = vim.lsp.with(require'lspactions'.definition, {
  open_list = true,
  jump_to_result = true,
  jump_to_list = false,
  loclist = false,
  always_qf = false,
  transform = function(result) return result end
})
```

- loclist: use location list instead
- open\_list: to open quickfix/loclist list or not
- jump\_to\_result: jump to first result of operation in current window
- jump\_to\_list: make quickfix/loclist list current window
- always\_qf: open quickfix/loclist even if there is only one result
- transform: a function that accepts result returned from lsp-server, do
some transformation on it(maybe like sorting) and return the new result.

### declaration
```lua
vim.lsp.handlers["textDocument/declaration"] = require'lspactions'.declaration
vim.cmd [[ nnoremap <leader>af :lua vim.lsp.buf.declaration()<CR> ]]
```

Similar to lsp declaration, but way more customizable.

Customization:
```lua
vim.lsp.handlers["textDocument/declaration"] = vim.lsp.with(require'lspactions'.declaration, {
  open_list = true,
  jump_to_result = true,
  jump_to_list = false,
  loclist = false,
  always_qf = false,
  transform = function(result) return result end
})
```

- loclist: use location list instead
- open\_list: to open quickfix/loclist list or not
- jump\_to\_result: jump to first result of operation in current window
- jump\_to\_list: make quickfix/loclist list current window
- always\_qf: open quickfix/loclist even if there is only one result
- transform: a function that accepts result returned from lsp-server, do
some transformation on it(maybe like sorting) and return the new result.

### implementation
```lua
vim.lsp.handlers["textDocument/implementation"] = require'lspactions'.implementation
vim.cmd [[ nnoremap <leader>af :lua vim.lsp.buf.implementation()<CR> ]]
```

Similar to lsp implementation, but way more customizable.

Customization:
```lua
vim.lsp.handlers["textDocument/implementation"] = vim.lsp.with(require'lspactions'.implementation, {
  open_list = true,
  jump_to_result = true,
  jump_to_list = false,
  loclist = false,
  always_qf = false,
  transform = function(result) return result end
})
```

- loclist: use location list instead
- open\_list: to open quickfix/loclist list or not
- jump\_to\_result: jump to first result of operation in current window
- jump\_to\_list: make quickfix/loclist list current window
- always\_qf: open quickfix/loclist even if there is only one result
- transform: a function that accepts result returned from lsp-server, do
some transformation on it(maybe like sorting) and return the new result.
