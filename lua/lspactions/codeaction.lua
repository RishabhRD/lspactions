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

local function codeaction_idx_handler(buf, result, idx, handler)
  return function()
    handler(result[idx])
    close(buf)()
  end
end

local function codeaction_selected_handler(buf, result, handler)
  return function()
    local idx = vim.fn.line "."
    codeaction_idx_handler(buf, result, idx, handler)()
  end
end

local function set_mappings(buf, result, handler)
  local quit_key_tbl = keymaps.quit
  local exec_key_tbl = keymaps.exec
  for _, k in ipairs(quit_key_tbl.n) do
    nnoremap { k, close(buf), buffer = buf }
  end

  for _, k in ipairs(exec_key_tbl.n) do
    nnoremap { k, codeaction_selected_handler(buf, result, handler), buffer = buf }
  end

  for i = 1, #result, 1 do
    nnoremap {
      string.format("%d", i),
      codeaction_idx_handler(buf, result, i, handler),
      buffer = buf,
    }
  end
end

local function select(results, extract_title, handler)
  local data_tbl = {}
  local width = 0
  for idx, d in ipairs(results) do
    local title = extract_title(d)
    data_tbl[idx] = title
    width = max(width, #title)
  end
  width = width + 4
  local bufnr = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, data_tbl)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  create_win(bufnr, #results, width)
  set_mappings(bufnr, results, handler)
end

local function code_action_handler(_, results, ctx, config)
  config = config or {}
  if config.transform then
    results = config.transform(results)
  end
  local action_tuples = {}
  for client_id, result in pairs(results) do
    for _, action in pairs(result.result or {}) do
      table.insert(action_tuples, { client_id, action })
    end
  end
  if #action_tuples == 0 then
    vim.notify("No code actions available", vim.log.levels.INFO)
    return
  end

  ---@private
  local function apply_action(action, client)
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit)
    end
    if action.command then
      local command = type(action.command) == "table" and action.command
        or action
      local fn = vim.lsp.commands[command.command]
      if fn then
        local enriched_ctx = vim.deepcopy(ctx)
        enriched_ctx.client_id = client.id
        fn(command, ctx)
      else
        vim.lsp.buf.execute_command(command)
      end
    end
  end

  ---@private
  local function on_user_choice(action_tuple)
    if not action_tuple then
      return
    end
    -- textDocument/codeAction can return either Command[] or CodeAction[]
    --
    -- CodeAction
    --  ...
    --  edit?: WorkspaceEdit    -- <- must be applied before command
    --  command?: Command
    --
    -- Command:
    --  title: string
    --  command: string
    --  arguments?: any[]
    --
    local client = vim.lsp.get_client_by_id(action_tuple[1])
    local action = action_tuple[2]
    if
      not action.edit
      and client
      and type(client.resolved_capabilities.code_action) == "table"
      and client.resolved_capabilities.code_action.resolveProvider
    then
      client.request(
        "codeAction/resolve",
        action,
        function(err, resolved_action)
          if err then
            vim.notify(err.code .. ": " .. err.message, vim.log.levels.ERROR)
            return
          end
          apply_action(resolved_action, client)
        end
      )
    else
      apply_action(action, client)
    end
  end

  select(action_tuples, function(action_tuple)
    local title = action_tuple[2].title:gsub("\r\n", "\\r\\n")
    return title:gsub("\n", "\\n")
  end, on_user_choice)
end

local function code_action_request(params)
  local bufnr = vim.api.nvim_get_current_buf()
  local method = "textDocument/codeAction"
  vim.lsp.buf_request_all(bufnr, method, params, function(results)
    vim.lsp.handlers[method](
      nil,
      results,
      { bufnr = bufnr, method = method, params = params }
    )
  end)
end

local function codeaction(context)
  vim.validate { context = { context, "t", true } }
  context = context or {}
  if not context.diagnostics then
    context.diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
  end
  local params = vim.lsp.util.make_range_params()
  params.context = context
  code_action_request(params)
end

local function range_codeaction(context, start_pos, end_pos)
  vim.validate { context = { context, 't', true } }
  context = context or {}
  if not context.diagnostics then
    context.diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
  end
  local params = vim.lsp.util.make_given_range_params(start_pos, end_pos)
  params.context = context
  code_action_request(params)
end


return {
  code_action = codeaction,
  range_code_action = range_codeaction,
  code_action_handler = code_action_handler
}
