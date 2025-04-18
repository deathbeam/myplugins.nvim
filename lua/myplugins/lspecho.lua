local M = {
    config = {
        echo = true, -- Echo progress messages, if set to false you can use .message() to get the current message
        decay = 3000, -- Message decay time in milliseconds
        interval = 100, -- Minimum time between echo updates in milliseconds
        attach_log = false, -- Attach to logMessage and showMessage
    },
}

local series = {}
local last_message = ''
local last_echo = 0
local timer = vim.uv.new_timer()

local function clear()
    timer:stop()
    timer:start(
        M.config.decay,
        0,
        vim.schedule_wrap(function()
            last_message = ''
            if M.config.echo then
                vim.cmd.redraw()
                vim.api.nvim_echo({ { '' } }, false, {})
            end
        end)
    )
end

local function log(msg)
    local client = msg.client or ''
    local title = msg.title or ''
    local message = msg.message or ''
    local percentage = msg.percentage or 0
    local history = msg.history or false

    local out = ''
    if client ~= '' then
        out = out .. '[' .. client .. ']'
    end

    if percentage > 0 then
        out = out .. ' [' .. percentage .. '%]'
    end

    if title ~= '' then
        out = out .. ' ' .. title
    end

    if message ~= '' then
        if title ~= '' and vim.startswith(message, title) then
            message = string.sub(message, string.len(title) + 1)
        end

        message = message:gsub('%s*%d+%%', '')
        message = message:gsub('^%s*-', '')
        message = vim.trim(message)
        if message ~= '' then
            if title ~= '' then
                out = out .. ' - ' .. message
            else
                out = out .. ' ' .. message
            end
        end
    end

    out = out:gsub('\n', ' ')
    last_message = out
    if M.config.echo then
        local current_time = vim.uv.now()
        if current_time - last_echo >= M.config.interval or history then
            vim.cmd.redraw()
            vim.api.nvim_echo({ { string.sub(out, 1, vim.v.echospace) } }, history, {})
            last_echo = current_time
        end
    end
end

local function lsp_progress(err, progress, ctx)
    if err then
        return
    end

    local client = vim.lsp.get_client_by_id(ctx.client_id)
    local client_name = client and client.name or ''
    local token = progress.token
    local value = progress.value

    if value.kind == 'begin' then
        series[token] = {
            client = client_name,
            title = value.title or '',
            message = value.message or '',
            percentage = value.percentage or 0,
        }

        local cur = series[token]
        log({
            client = cur.client,
            title = cur.title,
            message = cur.message .. ' - Starting',
            percentage = cur.percentage,
        })
    elseif value.kind == 'report' then
        local cur = series[token]
        log({
            client = client_name or (cur and cur.client),
            title = value.title or (cur and cur.title),
            message = value.message or (cur and cur.message),
            percentage = value.percentage or (cur and cur.percentage),
        })
    elseif value.kind == 'end' then
        local cur = series[token]
        local msg = value.message or (cur and cur.message)
        msg = msg and msg .. ' - Done' or 'Done'
        log({
            client = client_name or (cur and cur.client),
            title = value.title or (cur and cur.title),
            message = msg,
        })
        series[token] = nil
        clear()
    end
end

local function lsp_log(err, message, ctx)
    if err then
        return
    end

    local client = vim.lsp.get_client_by_id(ctx.client_id)
    local client_name = client and client.name or ''
    local msg = message.message or ''
    log({
        client = client_name,
        message = msg,
        history = true,
    })
end

function M.message()
    return last_message
end

function M.setup(config)
    M.config = vim.tbl_deep_extend('force', M.config, config or {})

    if M.config.attach_log then
        vim.lsp.handlers['window/logMessage'] = function(...)
            lsp_log(...)
        end
        vim.lsp.handlers['window/showMessage'] = function(...)
            lsp_log(...)
        end
    end

    local old_handler = vim.lsp.handlers['$/progress']
    vim.lsp.handlers['$/progress'] = function(...)
        if old_handler then
            old_handler(...)
        end
        lsp_progress(...)
    end
end

return M
