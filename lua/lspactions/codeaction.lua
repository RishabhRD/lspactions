local nnoremap = vim.keymap.nnoremap
local keymaps = require("lspactions.config").codeaction.keymaps
local popup = require "popup"
local util = require "lspactions.util"
local max = util.max

local function create_win(bufnr, num_ele, width)
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
    highlight = "LspActionsCodeActionWindow",
    title = "Code Actions",
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
    "Normal:LspActionsCodeActionBorder"
  )
  return win_id
end

local function close(bufnr)
  return function()
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

local function apply_action_idx(bufnr, actions, idx)
  return function()
    close(bufnr)()
    local action = actions[idx]
    if action.edit or type(action.command) == "table" then
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit)
      end
      if type(action.command) == "table" then
        vim.lsp.buf.execute_command(action.command)
      end
    else
      vim.lsp.buf.execute_command(action)
    end
  end
end

local function apply_action(bufnr, actions)
  return function()
    local idx = vim.fn.line "."
    apply_action_idx(bufnr, actions, idx)()
  end
end

local function set_mappings(buf, result)
  local quit_key_tbl = keymaps.quit
  local exec_key_tbl = keymaps.exec
  for _, k in ipairs(quit_key_tbl.n) do
    nnoremap { k, close(buf), buffer = buf }
  end

  for _, k in ipairs(exec_key_tbl.n) do
    nnoremap { k, apply_action(buf, result), buffer = buf }
  end

  for i = 1, #result, 1 do
    nnoremap {
      string.format("%d", i),
      apply_action_idx(buf, result, i),
      buffer = buf,
    }
  end
end

local function code_action_handler(err, result, _, config)
  config = config or {}
  if err then
    vim.notify(err)
    return
  end
  if config.transform then
    result = config.transform(result)
  end
  if result == nil or vim.tbl_isempty(result) then
    vim.notify("No codeactions available", vim.log.levels.INFO)
    return
  end
  local data = {}
  local width = 0
  for _, d in ipairs(result) do
    table.insert(data, d.title)
    width = max(width, #d.title)
  end
  width = width + 4
  local bufnr = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, data)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  create_win(bufnr, #result, width)
  set_mappings(bufnr, result)
end

return code_action_handler
