local util = require("lspactions.util")
local max = util.max
local popup = require "popup"

local function create_win(bufnr, num_ele, width, title)
  local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  if width + 2 > vim.o.columns then
    width = vim.o.columns - 4
  end
  local height = num_ele
  if num_ele > 10 then
    num_ele = 10
  end
  local line, col = util.get_cursor_pos(height)
  local win_id, win = popup.create(bufnr, {
    highlight = "LspActionsSelectWindow",
    title = title,
    line = line,
    col = col,
    width = width,
    height = height,
    borderchars = borderchars,
    cursorline = true,
  })

  vim.api.nvim_win_set_option(win_id, "number", true)
  vim.api.nvim_win_set_option(win_id, "wrap", false)

  vim.api.nvim_win_set_option(
    win.border.win_id,
    "winhl",
    "Normal:LspActionsSelectBorder"
  )
  return win_id
end

local function select(items, opts, on_choice)
  opts = opts or {}
  opts.prompt = opts.prompt or "Select one of"
  opts.format_item = opts.format_item or tostring
  local keymaps = opts.keymaps or require("lspactions.config").select.keymaps
  local extract_title = opts.format_item
  local data_tbl = {}
  local width = 0
  for idx, d in ipairs(items) do
    local title = extract_title(d)
    data_tbl[idx] = title
    width = max(width, #title)
  end
  width = width + 4
  local bufnr = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, data_tbl)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  create_win(bufnr, #items, width, opts.prompt)

  local function close()
    vim.api.nvim_buf_delete(bufnr, { force = true })
    on_choice(nil)
  end

  local function apply_selection()
    local idx = vim.fn.line "."
    vim.api.nvim_buf_delete(bufnr, { force = true })
    on_choice(items[idx])
  end

  local function apply_idx_selection(idx)
    return function()
      vim.api.nvim_buf_delete(bufnr, { force = true })
      on_choice(items[idx])
    end
  end

  local function set_mappings()
    local quit_key_tbl = keymaps.quit
    local exec_key_tbl = keymaps.exec

    for _, k in ipairs(quit_key_tbl.n) do
      vim.keymap.set("n", k, close, { buffer = bufnr })
    end

    for _, k in ipairs(exec_key_tbl.n) do
      vim.keymap.set("n", k, apply_selection, { buffer = bufnr })
    end

    for i = 1, #items, 1 do
      vim.keymap.set("n", string.format("%d", i), apply_idx_selection(i), { buffer = bufnr })
    end
  end

  set_mappings()
end

return select
