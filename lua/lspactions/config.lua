local M = {}

M.input = {
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

M.select = {
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
