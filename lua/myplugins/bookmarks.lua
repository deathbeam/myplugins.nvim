local M = {
    config = {
        name = 'Bookmarks', -- Name of the quickfix list
    },
}

local function ensure_quickfix_list()
    local max_nr = vim.fn.getqflist({ nr = '$' }).nr

    for i = 1, max_nr do
        local qf = vim.fn.getqflist({ nr = i, all = 1 })
        if qf.title == M.config.name then
            return qf.id
        end
    end

    vim.fn.setqflist({}, ' ', { title = M.config.name })
    return vim.fn.getqflist({ id = 0 }).id
end

local function toggle_quickfix_item(entry)
    local id = ensure_quickfix_list()

    local qf_list = vim.fn.getqflist({ id = id, items = 1 }).items
    local found_idx = nil
    for i, item in ipairs(qf_list) do
        if
            item.bufnr
            and item.bufnr == entry.bufnr
            and (entry.text == nil or (item.lnum == entry.lnum and item.text == entry.text))
        then
            found_idx = i
            break
        end
    end

    if found_idx then
        table.remove(qf_list, found_idx)
        vim.fn.setqflist({}, 'r', {
            id = id,
            items = qf_list,
            title = M.config.name,
        })
        return
    end

    vim.fn.setqflist({}, 'a', {
        id = id,
        title = M.config.name,
        items = { entry },
    })
end

function M.toggle_file()
    local current_buf = vim.api.nvim_get_current_buf()
    toggle_quickfix_item({
        bufnr = current_buf,
        lnum = 1,
        col = 1,
    })
end

function M.toggle_line()
    local current_buf = vim.api.nvim_get_current_buf()
    local current_line_num = vim.fn.line('.')
    local current_line = vim.fn.getline('.')
    toggle_quickfix_item({
        bufnr = current_buf,
        lnum = current_line_num,
        col = 1,
        text = current_line,
    })
end

function M.load()
    local quickfix_id = ensure_quickfix_list()
    local cur_id = vim.fn.getqflist({ id = 0 }).id
    local rel_change = cur_id - quickfix_id
    if rel_change > 0 then
        vim.cmd('colder ' .. rel_change)
    elseif rel_change < 0 then
        vim.cmd('cnewer ' .. -rel_change)
    end
end

function M.clear()
    local quickfix_id = ensure_quickfix_list()
    vim.fn.setqflist({}, ' ', { id = quickfix_id })
end

return M
