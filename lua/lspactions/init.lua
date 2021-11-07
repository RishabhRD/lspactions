local response_to_list = require'lspactions.location_util'.response_to_list
local M = {}


M.code_action = require"lspactions.codeaction".code_action
M.range_code_action = require"lspactions.codeaction".range_code_action
M.codeaction = require "lspactions.codeaction".code_action_handler
M.rename = require "lspactions.rename"
M.references = response_to_list(vim.lsp.util.locations_to_items, "references")
M.definition = response_to_list(vim.lsp.util.locations_to_items, "definition")
M.declaration = response_to_list(vim.lsp.util.locations_to_items, "declaration")
M.implementation = response_to_list(
  vim.lsp.util.locations_to_items,
  "implementation"
)
M.diagnostic = require"lspactions.diagnostic"
M.select = require"lspactions.codeaction".select

return M
