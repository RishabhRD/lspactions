local util = require "lspactions.util"
local popup = require "popup"

local function create_win(prompt, bufnr)
  local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  local width = 30
  local height = 1
  local line, col = util.get_cursor_pos(height)
  local win_id, win = popup.create(bufnr, {
    highlight = "LspActionsInputHighlight",
    title = prompt,
    line = line,
    col = col,
    width = width,
    height = height,
    borderchars = borderchars,
  })

  vim.api.nvim_win_set_option(
    win.border.win_id,
    "winhl",
    "Normal:LspActionsInputBorderHighlight"
  )
  vim.api.nvim_win_set_option(win_id, "wrap", false)
  return win_id
end

local function set_mappings(keymaps, buf, on_confirm)
  local function close()
    if vim.fn.mode() == "i" then
      vim.cmd [[stopinsert]]
    end
    vim.api.nvim_buf_delete(buf, { force = true })
    on_confirm(nil)
  end

  local function apply_action()
    local new_name = vim.fn.getline "."
    if vim.fn.mode() == "i" then
      vim.cmd [[stopinsert]]
    end
    vim.api.nvim_buf_delete(buf, { force = true })
    on_confirm(new_name)
  end

  local quit_key_tbl = keymaps.quit
  local exec_key_tbl = keymaps.exec
  for _, k in ipairs(quit_key_tbl.n) do
    vim.keymap.set("n", k, close, { buffer = buf })
  end
  for _, k in ipairs(quit_key_tbl.i) do
    vim.keymap.set("i", k, close, { buffer = buf })
  end

  for _, k in ipairs(exec_key_tbl.n) do
    vim.keymap.set("n", k, apply_action, { buffer = buf })
  end
  for _, k in ipairs(exec_key_tbl.i) do
    vim.keymap.set("i", k, apply_action, { buffer = buf })
  end
end

local function create_ui(opts, on_confirm)
  local bufnr = vim.api.nvim_create_buf(false, false)
  create_win(opts.prompt, bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { opts.default })
  vim.fn.feedkeys "A"
  set_mappings(opts.keymaps, bufnr, on_confirm)
end

local function input(opts, on_confirm)
  vim.validate {
    on_confirm = { on_confirm, "function", false },
  }
  opts = opts or {}
  opts.prompt = opts.prompt or "Input"
  opts.keymaps = opts.keymaps or require("lspactions.config").input.keymaps
  opts.default = opts.default or ""
  create_ui(opts, on_confirm)
end

return input
