local M = {}

local lastlnum = nil

function M.setup()
    local group = vim.api.nvim_create_augroup('myplugins-diagnostics', { clear = true })

    -- Store original DiagnosticUnnecessary colors to reuse
    vim.api.nvim_create_autocmd('ColorScheme', {
        group = group,
        callback = function()
            local orig_hl = vim.api.nvim_get_hl(0, { name = 'DiagnosticUnnecessary' })
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.api.nvim_set_hl(0, 'DiagnosticUnnecessaryOverride', orig_hl)
            vim.api.nvim_set_hl(0, 'DiagnosticUnnecessary', {})
        end,
    })

    vim.api.nvim_create_autocmd('CursorHold', {
        group = group,
        desc = 'Show diagnostics',
        callback = function()
            if vim.api.nvim_get_mode().mode ~= 'n' then
                return
            end

            for _, win in ipairs(vim.api.nvim_list_wins()) do
                local config = vim.api.nvim_win_get_config(win)
                if config.relative ~= '' and not config.hide then
                    local buf = vim.api.nvim_win_get_buf(win)
                    if buf and vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
                        return
                    end
                end
            end

            vim.diagnostic.open_float()
        end,
    })

    vim.api.nvim_create_autocmd({ 'DiagnosticChanged', 'CursorMoved' }, {
        group = group,
        callback = function(args)
            local ns = vim.api.nvim_create_namespace('diagnostic_unnecessary_hl_override')
            local bufnr = args.buf

            local lnum = vim.fn.line('.') - 1
            if lnum == lastlnum then
                -- Skip if cursor hasn't moved vertically
                return
            end
            lastlnum = lnum

            -- Clear previous highlights
            vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

            -- Apply highlights to all unnecessary diagnostics except ones under cursor
            vim.iter(vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.HINT }))
                :filter(function(diagnostic)
                    return diagnostic._tags and diagnostic._tags.unnecessary
                end)
                :filter(function(diagnostic)
                    return lnum < diagnostic.lnum or lnum > diagnostic.end_lnum
                end)
                :each(function(diagnostic)
                    vim.api.nvim_buf_set_extmark(bufnr, ns, diagnostic.lnum, diagnostic.col, {
                        hl_group = 'DiagnosticUnnecessaryOverride',
                        end_line = diagnostic.end_lnum,
                        end_col = diagnostic.end_col,
                        priority = 200,
                        strict = false,
                    })
                end)
        end,
    })
end

return M
