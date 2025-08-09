local M = {
    config = {
        debounce_delay = 100,
    },
}

local utils = require('myplugins.utils')
local methods = vim.lsp.protocol.Methods

function M.setup(config)
    M.config = vim.tbl_deep_extend('force', M.config, config or {})

    local group = vim.api.nvim_create_augroup('myplugins-lspdocs', { clear = true })
    local entry = utils.entry()

    vim.api.nvim_create_autocmd('CompleteChanged', {
        group = group,
        desc = 'Auto show LSP documentation',
        callback = function(args)
            if not string.find(vim.o.completeopt, 'popup') then
                return
            end

            if not vim.v.event or not vim.v.event.completed_item then
                return
            end

            local cur_item = vim.v.event.completed_item
            local cur_info = vim.fn.complete_info()
            local selected = cur_info.selected

            utils.debounce(entry, M.config.debounce_delay, function()
                local completion_item = vim.tbl_get(cur_item or {}, 'user_data', 'nvim', 'lsp', 'completion_item')
                if not completion_item then
                    return
                end

                local _, cancel = vim.lsp.buf_request(
                    args.buf,
                    methods.completionItem_resolve,
                    completion_item,
                    vim.schedule_wrap(function(err, item)
                        if err or not item then
                            return
                        end

                        local docs = vim.tbl_get(item, 'documentation', 'value')
                        if not docs or #docs == 0 then
                            return
                        end

                        local wininfo = vim.api.nvim__complete_set(selected, { info = docs })
                        if not wininfo.winid or not wininfo.bufnr then
                            return
                        end

                        vim.api.nvim_win_set_config(wininfo.winid, {
                            ---@diagnostic disable-next-line: assign-type-mismatch
                            border = vim.o.winborder,
                            focusable = false,
                        })

                        vim.treesitter.start(wininfo.bufnr, 'markdown')
                        vim.wo[wininfo.winid].conceallevel = 3
                        vim.wo[wininfo.winid].concealcursor = 'niv'
                    end),
                    function() end
                )

                return cancel
            end)
        end,
    })
end

return M
