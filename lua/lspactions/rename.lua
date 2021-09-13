local nnoremap = vim.keymap.nnoremap
local inoremap = vim.keymap.inoremap
local keymaps = require("lspactions").rename.keymaps
local popup = require "popup"
local util = require "lspactions.util"

local function request(method, params, handler)
  vim.validate {
    method = { method, "s" },
    handler = { handler, "f", true },
  }
  return vim.lsp.buf_request(0, method, params, handler)
end

local function create_win(bufnr)
  local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  local width = 30
  local height = 1
  local line, col = util.get_cursor_pos(height)
  local win_id, win = popup.create(bufnr, {
    highlight = "LspActionsRenameWindow",
    title = "Rename",
    line = line,
    col = col,
    width = width,
    height = height,
    borderchars = borderchars,
  })

  vim.api.nvim_win_set_option(
    win.border.win_id,
    "winhl",
    "Normal:LspActionsRenameBorder"
  )
  return win_id
end

local function lsp_rename(new_name)
  local params = vim.lsp.util.make_position_params()
  local current_name = vim.fn.expand "<cword>"
  if not (new_name and #new_name > 0) or new_name == current_name then
    return
  end
  params.newName = new_name
  vim.lsp.buf_request(0, "textDocument/rename", params)
end

local function close(bufnr)
  return function()
    if vim.fn.mode() == "i" then
      vim.cmd [[stopinsert]]
    end
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

local function do_rename(bufnr)
  return function()
    local new_name = vim.fn.getline "."
    close(bufnr)()
    lsp_rename(new_name)
  end
end

local function set_mappings(buf)
  local quit_key_tbl = keymaps.quit
  local exec_key_tbl = keymaps.exec
  for _, k in ipairs(quit_key_tbl.n) do
    nnoremap { k, close(buf), buffer = buf }
  end
  for _, k in ipairs(quit_key_tbl.i) do
    inoremap { k, close(buf), buffer = buf }
  end

  for _, k in ipairs(exec_key_tbl.n) do
    nnoremap { k, do_rename(buf), buffer = buf }
  end
  for _, k in ipairs(exec_key_tbl.i) do
    inoremap { k, do_rename(buf), buffer = buf }
  end
end

local function rename_ui(old_name)
  local bufnr = vim.api.nvim_create_buf(false, false)
  create_win(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { old_name })
  vim.fn.feedkeys "A"
  set_mappings(bufnr)
end

local function rename(new_name)
  local active, msg = util.check_lsp_active()
  local params = vim.lsp.util.make_position_params()
  if not active then
    print(msg)
    return
  end
  if new_name == nil then
    local function prepare_rename(err, result)
      if err == nil and result == nil then
        vim.notify("nothing to rename", vim.log.levels.INFO)
        return
      end
      if result and result.placeholder then
        rename_ui(result.placeholder)
      elseif
        result
        and result.start
        and result["end"]
        and result.start.line == result["end"].line
      then
        local line = vim.fn.getline(result.start.line + 1)
        local start_char = result.start.character + 1
        local end_char = result["end"].character
        rename_ui(string.sub(line, start_char, end_char))
      else
        rename_ui(vim.fn.expand "<cword>")
      end
    end
    request("textDocument/prepareRename", params, prepare_rename)
  else
    lsp_rename(new_name)
  end
end

return rename
