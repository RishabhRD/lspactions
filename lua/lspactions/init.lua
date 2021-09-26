local response_to_list = require'lspactions.location_util'.response_to_list
local M = {}


M.codeaction = require "lspactions.codeaction"
M.rename = require "lspactions.rename"
M.references = response_to_list(vim.lsp.util.locations_to_items, "references")
M.definition = response_to_list(vim.lsp.util.locations_to_items, "definition")
M.declaration = response_to_list(vim.lsp.util.locations_to_items, "declaration")
M.implementation = response_to_list(
  vim.lsp.util.locations_to_items,
  "implementation"
)

return M
