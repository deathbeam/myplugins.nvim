local M = {
    config = {
        session_dir = vim.fn.stdpath('data') .. '/sessions/',
        dirs = {
            vim.fn.expand('~/git'),
        },
    },
}

local utils = require('myplugins.utils')

local function get_session_file()
    if vim.fn.argc() > 0 or vim.tbl_isempty(vim.api.nvim_list_uis()) then
        return nil
    end

    local cwd = vim.fn.getcwd()
    vim.notify('Checking session for directory: ' .. cwd, vim.log.levels.DEBUG)

    -- Check if current directory is in allowed_dirs
    local is_allowed = false
    for _, dir in ipairs(M.config.dirs) do
        if string.match(cwd, '^' .. dir) then
            is_allowed = true
            break
        end
    end

    if not is_allowed then
        return nil
    end

    vim.fn.mkdir(M.config.session_dir, 'p')
    return M.config.session_dir .. cwd:gsub('/', '_') .. '.vim'
end

function M.setup(config)
    config = utils.cfg(M.config, config)

    utils.au('VimLeavePre', {
        desc = 'myplugins: Save session on exit',
        callback = function()
            local session_file = get_session_file()
            if session_file then
                vim.notify('Saving session...', vim.log.levels.INFO)
                vim.cmd('mksession! ' .. session_file)
            end
        end,
    })

    utils.au('VimEnter', {
        desc = 'myplugins: Restore session on enter',
        callback = function()
            local session_file = get_session_file()
            if session_file and vim.fn.filereadable(session_file) == 1 then
                vim.notify('Loading session...', vim.log.levels.INFO)
                vim.cmd('silent! source ' .. session_file)
                vim.cmd('silent! doautoall BufRead')
                vim.cmd('silent! doautoall FileType')
                vim.cmd('silent! doautoall BufEnter')
            end
        end,
    })
end
