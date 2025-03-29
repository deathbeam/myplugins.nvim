local M = {
    selected_env = nil,
    http_window = nil,
    http_buffer = nil,
    ns_id = vim.api.nvim_create_namespace('HttpClient'),
    status_mark_id = nil,
}

local function ensure_buffer()
    if M.http_buffer and vim.api.nvim_buf_is_valid(M.http_buffer) then
        return
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].syntax = 'http_stat'
    vim.bo[buf].modifiable = false
    M.http_buffer = buf
end

local function set_status(status, col)
    -- Remove previous mark if exists
    if M.status_mark_id then
        vim.api.nvim_buf_del_extmark(M.http_buffer, M.ns_id, M.status_mark_id)
    end

    if not status then
        return
    end

    -- Parse multiline status
    local status_lines = vim.split(status, '\n')
    local virt_lines = {}
    for _, line in ipairs(status_lines) do
        table.insert(virt_lines, { { ' ' .. line .. ' ', col } })
    end

    local line_count = vim.api.nvim_buf_line_count(M.http_buffer)

    -- Create extmark with virtual lines at the top of the buffer
    M.status_mark_id = vim.api.nvim_buf_set_extmark(M.http_buffer, M.ns_id, line_count - 1, 0, {
        virt_lines = virt_lines,
        virt_lines_above = true,
        virt_lines_leftcol = false,
        priority = 200,
        right_gravity = false,
        undo_restore = true,
    })
end

local function exec(file, line)
    local cmd = {
        'httpyac',
        file,
        '--no-color',
    }

    if line then
        table.insert(cmd, '-l')
        table.insert(cmd, line)
    end

    if M.selected_env then
        table.insert(cmd, '-e')
        table.insert(cmd, M.selected_env)
    end

    -- Open and clear the window
    M.open()
    vim.bo[M.http_buffer].modifiable = true
    vim.api.nvim_buf_set_lines(M.http_buffer, 0, -1, false, {})
    vim.bo[M.http_buffer].modifiable = false

    set_status('PROCESSING', 'DiffText')

    vim.system(
        cmd,
        {
            text = true,
            stdout = vim.schedule_wrap(function(_, data)
                if not data then
                    return
                end

                local lines = vim.split(data, '\n')
                local line_count = vim.api.nvim_buf_line_count(M.http_buffer)
                vim.bo[M.http_buffer].modifiable = true
                vim.api.nvim_buf_set_lines(M.http_buffer, line_count, line_count, false, lines)
                vim.bo[M.http_buffer].modifiable = false
            end),
        },
        vim.schedule_wrap(function(obj)
            if obj.code ~= 0 then
                set_status('ERROR', 'DiffDelete')
            else
                set_status('DONE', 'DiffAdd')
            end
        end)
    )
end

function M.open()
    if M.http_window and vim.api.nvim_win_is_valid(M.http_window) then
        vim.api.nvim_set_current_win(M.http_window)
        return
    end

    ensure_buffer()
    vim.cmd('botright vsplit')
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, M.http_buffer)
    M.http_window = win
end

function M.close()
    if M.http_window and vim.api.nvim_win_is_valid(M.http_window) then
        vim.api.nvim_win_close(M.http_window, true)
        M.http_window = nil
    end
end

function M.toggle()
    if M.http_window and vim.api.nvim_win_is_valid(M.http_window) then
        M.close()
    else
        M.open()
    end
end

function M.run_all()
    local file = vim.fn.expand('%:p')
    exec(file, nil)
end

function M.run()
    local file = vim.fn.expand('%:p')
    local line = vim.fn.line('.')
    exec(file, line)
end

function M.select_env()
    local current_file = vim.fn.expand('%:p')
    local current_dir = vim.fn.fnamemodify(current_file, ':h')
    local filename = current_dir .. '/http-client.env.json'
    local env_file = io.open(filename, 'r')

    if not env_file then
        vim.notify('Environment file not found: ' .. filename, vim.log.levels.ERROR)
        return
    end

    local content = env_file:read('*all')
    env_file:close()

    local env_data = vim.json.decode(content)
    if not env_data then
        vim.notify('Failed to parse environment file', vim.log.levels.ERROR)
        return
    end

    local envs = vim.tbl_keys(env_data)
    table.sort(envs)

    vim.ui.select(envs, {
        prompt = 'Select environment> ',
    }, function(choice)
        if choice then
            M.selected_env = choice
        end
    end)
end

return M
