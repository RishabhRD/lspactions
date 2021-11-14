local validate = vim.validate
local util = vim.lsp.util

local function request(method, params, handler)
  validate {
    method = { method, "s" },
    handler = { handler, "f", true },
  }
  return vim.lsp.buf_request(0, method, params, handler)
end

local function execute_command(command)
  validate {
    command = { command.command, "s" },
    arguments = { command.arguments, "t", true },
  }
  request("workspace/executeCommand", command)
end

local function on_code_action_results(_, results, ctx, config)
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

  local function apply_action(action, client)
    if action.edit then
      util.apply_workspace_edit(action.edit)
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
        execute_command(command)
      end
    end
  end

  local function on_user_choice(action_tuple)
    if not action_tuple then
      return
    end
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

  local select = config.ui_select or require'lspactions.select'

  select(action_tuples, {
    prompt = "Code actions",
    format_item = function(action_tuple)
      local title = action_tuple[2].title:gsub("\r\n", "\\r\\n")
      return title:gsub("\n", "\\n")
    end,
  }, on_user_choice)
end

local function code_action_request(params)
  local bufnr = vim.api.nvim_get_current_buf()
  local method = "textDocument/codeAction"
  local handler_func = vim.lsp.handlers[method] or on_code_action_results
  vim.lsp.buf_request_all(bufnr, method, params, function(results)
    handler_func(
      nil,
      results,
      { bufnr = bufnr, method = method, params = params }
    )
  end)
end

local function code_action(context)
  validate { context = { context, "t", true } }
  context = context or {}
  if not context.diagnostics then
    context.diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
  end
  local params = util.make_range_params()
  params.context = context
  code_action_request(params)
end

local function range_code_action(context, start_pos, end_pos)
  validate { context = { context, "t", true } }
  context = context or {}
  if not context.diagnostics then
    context.diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
  end
  local params = util.make_given_range_params(start_pos, end_pos)
  params.context = context
  code_action_request(params)
end

return {
  code_action = code_action,
  range_code_action = range_code_action,
  code_action_handler = on_code_action_results,
}
