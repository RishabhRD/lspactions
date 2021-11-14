local input = require "lspactions.input"
local util = require "lspactions.util"

local function request(method, params, handler)
  vim.validate {
    method = { method, "s" },
    handler = { handler, "f", true },
  }
  return vim.lsp.buf_request(0, method, params, handler)
end


local function lsp_rename(new_name)
  if new_name == nil then return end
  local params = vim.lsp.util.make_position_params()
  local current_name = vim.fn.expand "<cword>"
  if not (new_name and #new_name > 0) or new_name == current_name then
    return
  end
  params.newName = new_name
  vim.lsp.buf_request(0, "textDocument/rename", params)
end

local function rename_ui(old_name)
  local opts = {}
  opts.prompt = "Rename"
  opts.default_reply = old_name
  input(opts, lsp_rename)
end

local function rename(new_name)
  local active, msg = util.check_lsp_active()
  local params = vim.lsp.util.make_position_params()
  if not active then
    vim.noftify(msg)
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
