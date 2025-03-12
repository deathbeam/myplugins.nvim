local group = vim.api.nvim_create_augroup('NeoVimRc', { clear = true })

local M = {}

function M.au(event, opts)
    opts['group'] = group
    return vim.api.nvim_create_autocmd(event, opts)
end

function M.cfg(left, right)
    return vim.tbl_deep_extend('force', left, right or {})
end

return M
