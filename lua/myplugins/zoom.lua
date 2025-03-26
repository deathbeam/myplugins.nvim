local M = {}

local state = {
    zoom_tab = nil,
}

function M.toggle()
    if state.zoom_tab then
        if vim.api.nvim_tabpage_is_valid(state.zoom_tab) then
            vim.cmd('tabclose ' .. vim.api.nvim_tabpage_get_number(state.zoom_tab))
        end
        state.zoom_tab = nil
    else
        -- No need to zoom if there's only one window
        local wins = vim.api.nvim_tabpage_list_wins(0)
        if #wins <= 1 then
            return
        end

        -- Save current buffer, window info, and view
        local buf = vim.api.nvim_get_current_buf()
        local view = vim.fn.winsaveview()

        -- Create a new tab with the current buffer
        vim.cmd.tabnew()
        vim.api.nvim_win_set_buf(0, buf)
        vim.fn.winrestview(view)

        -- Store the tab handle for later
        state.zoom_tab = vim.api.nvim_get_current_tabpage()
    end
end

function M.setup()
    -- Reset zoom state when the tab is closed
    vim.api.nvim_create_autocmd('TabClosed', {
        callback = function(args)
            local tab = tonumber(args.file)
            if state.zoom_tab and tab == state.zoom_tab then
                state.zoom_tab = nil
            end
        end,
    })

    -- Auto-cancel zoom when changing tabs
    vim.api.nvim_create_autocmd('TabEnter', {
        callback = function()
            local tab = vim.api.nvim_get_current_tabpage()
            if state.zoom_tab and tab ~= state.zoom_tab then
                M.toggle()
            end
        end,
    })
end

return M
