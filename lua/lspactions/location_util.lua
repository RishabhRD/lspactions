local jump = require("lspactions.util").jump
local M = {}

--[[
-- config accepts {
--   open_list : bool,
--   jump_to_list : bool,
--   jump_to_result : bool,
--   loclist : bool,
--   always_qf : bool
-- }
--]]
function M.response_to_list(map_result, entity)
  local function qf_handle(result, ctx, config)
    if config.jump_to_result then
      jump(result[1])
    end
    if config.loclist then
      vim.fn.setloclist(0, {}, " ", {
        title = "Language Server",
        items = map_result(result, ctx.bufnr),
      })
      if config.open_list then
        local win = vim.api.nvim_get_current_win()
        vim.api.nvim_command "lopen"
        if not config.jump_to_list then
          vim.api.nvim_set_current_win(win)
        end
      end
    else
      vim.fn.setqflist({}, " ", {
        title = "Language Server",
        items = map_result(result, ctx.bufnr),
      })
      if config.open_list then
        local win = vim.api.nvim_get_current_win()
        vim.api.nvim_command "copen"
        if not config.jump_to_list then
          vim.api.nvim_set_current_win(win)
        end
      end
    end
  end
  return function(_, result, ctx, config)
    config = config
      or {
        open_list = true,
        jump_to_result = true,
        jump_to_list = false,
        loclist = false,
        always_qf = false,
      }
    if not result or vim.tbl_isempty(result) then
      vim.notify(string.format("No %s found", entity))
    elseif not config.always_qf and #result == 1 then
      jump(result[1])
    else
      qf_handle(result, ctx, config)
    end
  end
end

return M
