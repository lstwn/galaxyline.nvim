local M = {}

function M.buffer_not_empty()
  if vim.fn.empty(vim.fn.expand('%:t')) ~= 1 then
    return true
  end
  return false
end

function M.is_git_workspace()
  local get_git_dir = require('galaxyline.provider_vcs').get_git_dir
  if vim.bo.buftype == 'terminal' then return false end
  local current_file = vim.fn.expand('%:p')
  local current_dir
  -- if file is a symlink
  if vim.fn.getftype(current_file) == 'link' then
    local real_file = vim.fn.resolve(current_file)
    current_dir = vim.fn.fnamemodify(real_file,':h')
  else
    current_dir = vim.fn.expand('%:p:h')
  end
  local result = get_git_dir(current_dir)
  if not result then return false end
  return true
end

function M.hide_in_width()
  local squeeze_width  = vim.fn.winwidth(0) / 2
  if squeeze_width > 50 then
    return true
  end
  return false
end

function M.has_active_lsp()
  local clients = vim.lsp.buf_get_clients()
  if next(clients) == nil then
    return false
  end
  return true
end

vim.api.nvim_exec(
[[
augroup is_current_window 
	autocmd!
	autocmd VimEnter,WinEnter * call setwinvar(winnr(), 'is_current', 1)
	autocmd WinLeave * call setwinvar(winnr(), 'is_current', 0)
augroup END
]], true)

function M.is_active_window()
    return vim.api.nvim_win_get_var(0, 'is_current') == 1
end

return M
