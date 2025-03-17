local M = {
    config = {
        session_dir = vim.fn.stdpath('data') .. '/sessions/',
        -- Directories where sessions are automatically saved
        dirs = {
            vim.fn.expand('~/git'),
        },
        -- Extra data to manage that is not normally saved in sessions
        extra = {
            quickfix = true, -- Save/load also quickfix lists
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

local function get_quickfix_lists()
    vim.cmd('cclose')
    local qf_data = {}
    local max_nr = vim.fn.getqflist({ nr = '$' }).nr

    for i = 1, max_nr do
        local qf = vim.fn.getqflist({ nr = i, items = 1, title = 1 })

        local items = vim.tbl_map(function(item)
            local filename = item.filename or ''
            if item.bufnr > 0 then
                filename = vim.api.nvim_buf_get_name(item.bufnr)
            end

            return {
                filename = filename,
                lnum = item.lnum,
                end_lnum = item.end_lnum,
                col = item.col,
                end_col = item.end_col,
                text = item.text,
                type = item.type,
                user_data = item.user_data,
            }
        end, qf.items)

        table.insert(qf_data, { title = qf.title, items = items })
    end

    return qf_data
end

local function set_quickfix_lists(qf_data)
    for i, list in ipairs(qf_data) do
        vim.fn.setqflist({}, (i == 1 and 'r' or ' '), {
            title = list.title,
            items = list.items,
        })
    end

    vim.notify('Quickfix lists loaded', vim.log.levels.DEBUG)
end

local function save_extra_data(session_file)
    session_file = session_file:gsub('%.vim$', '.json')

    local data = {}
    if M.config.extra.quickfix then
        local qf_data = get_quickfix_lists()
        if qf_data then
            data.quickfix = qf_data
        end
    end

    if vim.tbl_isempty(data) then
        return
    end

    local file = io.open(session_file, 'w')
    if file then
        file:write(vim.json.encode(data))
        file:close()
        vim.notify('Extra session data saved', vim.log.levels.DEBUG)
    end
end

local function load_extra_data(session_file)
    session_file = session_file:gsub('%.vim$', '.json')

    local file = io.open(session_file, 'r')
    if not file then
        return
    end
    local content = file:read('*all')
    file:close()
    local data = vim.json.decode(content)

    if M.config.extra.quickfix and data.quickfix then
        set_quickfix_lists(data.quickfix)
    end
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
                save_extra_data(session_file)
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
                load_extra_data(session_file)
                vim.cmd('silent! doautoall BufRead')
                vim.cmd('silent! doautoall FileType')
                vim.cmd('silent! doautoall BufEnter')
            end
        end,
    })
end

return M
