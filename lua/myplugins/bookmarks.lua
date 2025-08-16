local M = {}

local function mark_char(idx)
    local idxn = tonumber(idx)
    if idxn and idxn >= 1 and idxn <= 9 then
        return string.char(64 + idxn) -- 1->A, 2->B, ...
    end
    return idx
end

local function get_marks()
    local out = {}

    for i = 1, 9 do
        local char = mark_char(i)
        local mark_row, mark_col, mark_bufnr, mark_file = unpack(vim.api.nvim_get_mark(char, {}))
        if mark_bufnr ~= 0 then
            mark_file = vim.api.nvim_buf_get_name(mark_bufnr)
        end

        if mark_row ~= 0 then
            table.insert(out, {
                idx = i,
                char = char,
                bufnr = mark_bufnr,
                lnum = mark_row,
                col = mark_col,
                filename = mark_file or '',
                text = string.format(
                    '%d: %s:%d',
                    i,
                    mark_file ~= '' and vim.fn.fnamemodify(mark_file, ':t') or '[No Name]',
                    mark_row
                ),
            })
        end
    end

    return out
end

function M.toggle_mark(idx)
    local numidx = tonumber(idx)
    if not numidx or numidx < 1 or numidx > 9 then
        return
    end

    local char = mark_char(idx)
    local mark_row, mark_col, mark_bufnr = unpack(vim.api.nvim_get_mark(char, {}))
    local current_bufnr = vim.api.nvim_get_current_buf()
    local current_row, current_col = unpack(vim.api.nvim_win_get_cursor(0))

    if mark_row ~= 0 and mark_row == current_row and mark_bufnr == current_bufnr then
        vim.api.nvim_del_mark(char)
    else
        vim.cmd('mark ' .. char)
    end
end

function M.jump_to_mark(idx)
    local char = mark_char(idx)
    vim.fn.feedkeys("'" .. char, 'n')
end

function M.delete_buffer()
    for i = 1, 9 do
        local char = mark_char(i)
        local mark_row, mark_col, mark_bufnr = unpack(vim.api.nvim_get_mark(char, {}))
        local current_bufnr = vim.api.nvim_get_current_buf()
        if mark_row ~= 0 and mark_bufnr == current_bufnr then
            vim.api.nvim_del_mark(char)
        end
    end
end

function M.delete_all()
    for i = 1, 9 do
        local char = mark_char(i)
        vim.api.nvim_del_mark(char)
    end
end

function M.select()
    local items = get_marks()

    if #items == 0 then
        return
    end

    vim.ui.select(items, {
        prompt = 'Select bookmark:',
        format_item = function(item)
            return item.text
        end,
    }, function(choice)
        if choice then
            M.jump_to_mark(choice.idx)
        end
    end)
end

function M.quickfix()
    local qfl = vim.tbl_map(function(item)
        return {
            bufnr = item.bufnr,
            lnum = item.lnum,
            col = item.col,
            text = item.text,
            filename = item.filename,
        }
    end, get_marks())

    if #qfl == 0 then
        return
    end

    vim.fn.setqflist(qfl, 'r')
    vim.cmd('copen')
end

return M
