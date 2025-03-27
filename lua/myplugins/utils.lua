local M = {}

function M.entry()
    return { timer = nil, cancel = nil }
end

function M.debounce(entry, ms, func)
    if not entry then
        return
    end

    M.stop(entry)
    entry.timer = vim.uv.new_timer()
    entry.timer:start(
        ms,
        0,
        vim.schedule_wrap(function()
            entry.cancel = func()
        end)
    )
end

function M.stop(entry)
    if not entry then
        return
    end

    if entry.timer then
        entry.timer:close()
        entry.timer:stop()
        entry.timer = nil
    end

    if entry.cancel then
        entry.cancel()
        entry.cancel = nil
    end
end

return M
