# lspactions

lspactions provide handlers for various lsp actions. lspactions also provide
utility functions for exposing UI for other components. lspactions targets to
be highly extensible and customizable. It uses floating windows for handlers
**if it really improves workflow**(I am biased) otherwise try to provide
similar (but highy customizable) handlers to nvim's default handlers.

**lspactions require neovim nightly release**

Current lspactions handlers:
- codeaction (floating win)
- rename (floating win + robust prompt)
- references (customizable quickfix)
- definition (customizable quickfix)
- declaration (customizable quickfix)
- implementation (customizable quickfix)
- diagnostics (layer on vim.diagnostics)

Current UI exposing functions:
- select (floating win selector for items)
- input (floating prompt input)

document\_symbols and workspace\_symbols are good with telescope and hence
is not targetted. If you feel there is some better way to do the same, feel
free to make a PR.

## Dependencies

- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [popup.nvim](https://github.com/nvim-lua/popup.nvim)

## Installation

```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'RishabhRD/lspactions'
```

## Current UI exposing functions

### select

Floating menu for user to pick a single item from a collection of entries.

```lua
vim.ui.select = require'lspactions'.select
```

It has mostly same spec as vim.ui.select. Please refer ``:h vim.ui.select``

Additional to ``vim.ui.select``, select suppports following additional options:

- opts.keymaps : table

Sample table(Also default):
```lua
  opts.keymaps = {
    quit = {
      n = {
        "q",
        "<Esc>",
      },
    },
    exec = {
      n = {
        "<CR>",
      },
    },
  }
```



**NOTE:** For neovim 0.6, This configuration is enough for having floating codeaction. If you don't want
this selector to be global selector then you can use ``require'lspactions'.code_action``.

### input

Floating menu prompt for user to input some text. The prompt doesn't have any neovim
prompt buffer problems.

```lua
vim.ui.input = require'lspactions'.input
```

It has mostly same spec as vim.ui.input. Please refer ``:h vim.ui.input``
Addition to the options provided in ``vim.ui.input`` it supports following
additional options:

- opts.keymaps : table

Sample table(Also default):
```lua
  opts.keymaps = {
      quit = {
        i = {
          "<C-c>",
        },
        n = {
          "q",
          "<Esc>",
        },
      },
      exec = {
        i = {
          "<CR>",
        },
        n = {
          "<CR>",
        },
      },
  }
```

quit contains mappings for keys where we don't accept the current input and just want
to close the buffer.

exec contains mappings for keys where we accept the current input and have to act upon
it.


**NOTE:** For neovim 0.6 nightly, it is enough to have
``vim.ui.input = require'lspactions'.input`` for renaming functionality.
If user doesn't wish to use floating buffer input globally, then user can use
lspactions rename module.

## Current handlers

### rename

```vim
nnoremap <leader>ar :lua require'lspactions'.rename()<CR>
```

It doesn't have any of problem that neovim's prompt buffer have that means
prompt has old name as initial text and user can seamlessly edit the text
inside prompt.

![](https://user-images.githubusercontent.com/26287448/133168403-35d5c6e0-16ad-44ee-9d2e-e3d056016746.gif)

Customization:
```lua
require'lspactions'.rename(nil, {
    input = vim.ui.input, -- NOT lspactions default
    keymap = <keymap_table> -- sample shown in input section
})
```
input function has same specifications as ``vim.ui.input``. It describes how
user would input new name for the node.

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

### diagnostics

All the parameters presented in code of this section are optional.

```lua
local diag = require'lspactions'.diagnostics
```

#### show\_position\_diagnostics

```lua
diag.show_position_diagnostics(opts, bufnr, position)
```
  - opts : table with fields
    - severity : string with possible values: {ERROR, WARN, INFO, HINT}

#### show\_line\_diagnostics

```lua
diag.show_line_diagnostics(opts, bufnr, position)
```
  - opts : table with fields
    - severity : string with possible values: {ERROR, WARN, INFO, HINT}

#### goto\_next

```lua
diag.goto_next(opts)
```
  - opts : table with fields
    - severity : string with possible values: {ERROR, WARN, INFO, HINT}
    - wrap : bool (default true) Whether to loop around file or not
    - float: bool (default true) Whether to open floating window after jumping to next diagnostic


#### goto\_prev

```lua
diag.goto_prev(opts)
```
  - opts : table with fields
    - severity : string with possible values: {ERROR, WARN, INFO, HINT}
    - wrap : bool (default true) Whether to loop around file or not
    - float: bool (default true) Whether to open floating window after jumping to previous diagnostic


#### set\_qflist

```lua
diag.set_qflist(opts)
```
  - opts : table with fields
    - severity : string with possible values: {ERROR, WARN, INFO, HINT}
    - client\_id : Which client to diagnostics to display
#### set\_loclist

```lua
diag.set_loclist(opts)
```
  - opts : table with fields
    - severity : string with possible values: {ERROR, WARN, INFO, HINT}
    - client\_id : Which client to diagnostics to display


