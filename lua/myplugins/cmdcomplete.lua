local M = {}

function M.setup()
    if vim.fn.has('nvim-0.11.0') == 0 then
        return
    end

    local group = vim.api.nvim_create_augroup('myplugins-cmdcomplete', { clear = true })

    vim.opt.wildmode = 'noselect:lastused,full'
    vim.keymap.set('c', '<Up>', '<End><C-U><Up>', { silent = true })
    vim.keymap.set('c', '<Down>', '<End><C-U><Down>', { silent = true })

    vim.api.nvim_create_autocmd('CmdlineChanged', {
        group = group,
        desc = 'Auto show command line completion',
        pattern = ':',
        callback = function()
            vim.fn.wildtrigger()
        end,
    })
end

return M
