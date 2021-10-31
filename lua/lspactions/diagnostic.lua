local M = {}

local function severity_lsp_to_vim(severity)
  if type(severity) == 'string' then
    severity = vim.lsp.protocol.DiagnosticSeverity[severity]
  end
  return severity
end

function M.show_position_diagnostics(opts, buf_nr, position)
  opts = opts or {}
  opts.scope = "cursor"
  opts.pos = position
  if opts.severity then
    opts.severity = severity_lsp_to_vim(opts.severity)
  elseif opts.severity_limit then
    opts.severity = {min=severity_lsp_to_vim(opts.severity_limit)}
  end
  return vim.diagnostic.open_float(buf_nr, opts)
end

function M.show_line_diagnostics(opts, buf_nr, line_nr, client_id)
  opts = opts or {}
  opts.scope = "line"
  opts.pos = line_nr
  if client_id then
    opts.namespace = M.get_namespace(client_id)
  end
  return vim.diagnostic.open_float(buf_nr, opts)
end

function M.goto_next(opts)
  if opts then
    if opts.severity then
      opts.severity = severity_lsp_to_vim(opts.severity)
    elseif opts.severity_limit then
      opts.severity = {min=severity_lsp_to_vim(opts.severity_limit)}
    end
  end
  return vim.diagnostic.goto_next(opts)
end

function M.goto_prev(opts)
  if opts then
    if opts.severity then
      opts.severity = severity_lsp_to_vim(opts.severity)
    elseif opts.severity_limit then
      opts.severity = {min=severity_lsp_to_vim(opts.severity_limit)}
    end
  end
  return vim.diagnostic.goto_prev(opts)
end

function M.set_qflist(opts)
  opts = opts or {}
  if opts.severity then
    opts.severity = severity_lsp_to_vim(opts.severity)
  elseif opts.severity_limit then
    opts.severity = {min=severity_lsp_to_vim(opts.severity_limit)}
  end
  if opts.client_id then
    opts.client_id = nil
    opts.namespace = M.get_namespace(opts.client_id)
  end
  local workspace = vim.F.if_nil(opts.workspace, true)
  opts.bufnr = not workspace and 0
  return vim.diagnostic.setqflist(opts)
end

function M.set_loclist(opts)
  opts = opts or {}
  if opts.severity then
    opts.severity = severity_lsp_to_vim(opts.severity)
  elseif opts.severity_limit then
    opts.severity = {min=severity_lsp_to_vim(opts.severity_limit)}
  end
  if opts.client_id then
    opts.client_id = nil
    opts.namespace = M.get_namespace(opts.client_id)
  end
  local workspace = vim.F.if_nil(opts.workspace, false)
  opts.bufnr = not workspace and 0
  return vim.diagnostic.setloclist(opts)
end

return M
