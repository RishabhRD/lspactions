local M = {}

M.rename = {
  keymaps = {
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
  },
}

M.codeaction = {
  keymaps = {
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
  },
}

return M
