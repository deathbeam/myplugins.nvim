local M = {
    config = {
        session_dir = vim.fn.stdpath('data') .. '/sessions/',
        dirs = {
            vim.fn.expand('~/git'),
        },
    },
}

local function get_session_file()
    if not vim.g.should_save_session then
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
    M.config = vim.tbl_deep_extend('force', M.config, config or {})

    local group = vim.api.nvim_create_augroup('myplugins-session', { clear = true })

    vim.api.nvim_create_autocmd('VimLeavePre', {
        group = group,
        desc = 'myplugins: Save session on exit',
        callback = function()
            local session_file = get_session_file()
            if session_file then
                vim.notify('Saving session...', vim.log.levels.INFO)
                vim.cmd('mksession! ' .. session_file)
            end
        end,
    })

    vim.api.nvim_create_autocmd('VimEnter', {
        group = group,
        desc = 'myplugins: Restore session on enter',
        callback = function()
            vim.g.should_save_session = vim.fn.argc() == 0
                and #vim.v.argv <= 2
                and not vim.tbl_isempty(vim.api.nvim_list_uis())

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

return M
