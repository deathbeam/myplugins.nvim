local M = {
    config = {
        max_size = 1024 * 1024,
    },
}

function M.setup(config)
    M.config = vim.tbl_deep_extend('force', M.config, config or {})
    local group = vim.api.nvim_create_augroup('myplugins-bigfile', { clear = true })

    vim.api.nvim_create_autocmd('BufReadPre', {
        group = group,
        pattern = '*',
        desc = 'myplugins: Disable features for large files',
        callback = function(args)
            local bufnr = args.buf
            local size = vim.fn.getfsize(vim.fn.expand('%'))

            if size < M.config.max_size then
                return
            end

            vim.api.nvim_buf_set_var(bufnr, 'bigfile_disable', 1)

            -- Disable treesitter indent
            local ok, ts_configs = pcall(require, 'nvim-treesitter.configs')
            if ok and ts_configs then
                local indent = ts_configs.get_module('indent')
                if indent then
                    indent.disable = function()
                        return vim.api.nvim_buf_get_var(bufnr, 'bigfile_disable') == 1
                    end
                end
            end

            -- Disable autoindent
            vim.bo.indentexpr = ''
            vim.bo.autoindent = false
            vim.bo.smartindent = false
            -- Disable folding
            vim.opt_local.foldmethod = 'manual'
            vim.opt_local.foldexpr = '0'
            -- Disable statuscolumn
            vim.opt_local.statuscolumn = ''
            -- Disable search highlight
            vim.opt_local.hlsearch = false
            -- Disable line wrapping
            vim.opt_local.wrap = false
            -- Disable cursorline
            vim.opt_local.cursorline = false
            -- Disable swapfile
            vim.opt_local.swapfile = false
            -- Disable spell checking
            vim.opt_local.spell = false
        end,
    })
end

return M
