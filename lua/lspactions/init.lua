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

return M
