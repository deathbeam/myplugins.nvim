local M = {
    config = {
        debounce_delay = 100,
        echo = true, -- Show signature under cursor as echo
    },
}

local utils = require('myplugins.utils')
local methods = vim.lsp.protocol.Methods

function M.setup(config)
    M.config = vim.tbl_deep_extend('force', M.config, config or {})

    local group = vim.api.nvim_create_augroup('myplugins-lspsignature', { clear = true })
    local hover_entry = utils.entry()
    local echo_entry = utils.entry()

    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        group = group,
        desc = 'Echo LSP signature under cursor',
        callback = function(args)
            if not M.config.echo then
                return
            end

            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            if col == 0 or #line == 0 then
                return
            end

            local clients = vim.lsp.get_clients({ bufnr = args.buf, method = methods.textDocument_signatureHelp })
            if vim.tbl_isempty(clients) then
                return
            end
            local client = clients[1]

            local before_line = line:sub(1, col)
            local has_trigger_char = vim.iter(client.server_capabilities.signatureHelpProvider.triggerCharacters or {})
                :filter(function(c)
                    return string.find(before_line, '[' .. c .. ']') ~= nil
                end)
                :next() ~= nil

            if not has_trigger_char then
                return
            end

            utils.debounce(echo_entry, M.config.debounce_delay, function()
                vim.lsp.buf_request(
                    0,
                    methods.textDocument_signatureHelp,
                    vim.lsp.util.make_position_params(0, 'utf-8'),
                    function(err, result)
                        if err or not result or not result.signatures or #result.signatures == 0 then
                            vim.cmd.redraw()
                            vim.api.nvim_echo({ { '' } }, false, {})
                            return
                        end

                        local actSig = math.max(0, result.activeSignature or 0)
                        local sig = result.signatures[actSig + 1]
                        local sigLbl = sig.label
                        local params = sig.parameters
                        local actPar = sig.activeParameter or result.activeParameter or 0

                        local chunks = {}
                        if not params or #params == 0 or #params <= actPar then
                            table.insert(chunks, { sigLbl, 'Function' })
                        else
                            local s, sePrev = 1, nil
                            for i = 1, #params do
                                local parLbl = type(params[i].label) == 'string' and params[i].label
                                    or sigLbl:sub(params[i].label[1] + 1, params[i].label[2])
                                local ss, se = sigLbl:find(parLbl, s, true)
                                if i == 1 and ss and ss > 1 then
                                    table.insert(chunks, { sigLbl:sub(1, ss - 1), 'Function' })
                                elseif sePrev then
                                    table.insert(chunks, { sigLbl:sub(sePrev + 1, ss - 1), 'Function' })
                                end
                                table.insert(chunks, { parLbl, i - 1 == actPar and 'Identifier' or 'Function' })
                                if i == #params and se then
                                    table.insert(chunks, { sigLbl:sub(se + 1), 'Function' })
                                end
                                s = ss
                                sePrev = se
                            end
                        end

                        vim.cmd.redraw()
                        vim.api.nvim_echo(chunks, false, {})
                    end
                )
            end)
        end,
    })

    vim.api.nvim_create_autocmd({ 'CursorMovedI', 'InsertEnter' }, {
        group = group,
        desc = 'Auto show LSP signature help',
        callback = function(args)
            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            if col == 0 or #line == 0 then
                return
            end

            local clients = vim.lsp.get_clients({ bufnr = args.buf, method = methods.textDocument_signatureHelp })
            if vim.tbl_isempty(clients) then
                return
            end
            local client = clients[1]

            local before_line = line:sub(1, col)
            local has_trigger_char = vim.iter(client.server_capabilities.signatureHelpProvider.triggerCharacters or {})
                :filter(function(c)
                    return string.find(before_line, '[' .. c .. ']') ~= nil
                end)
                :next() ~= nil

            if not has_trigger_char then
                return
            end

            utils.debounce(hover_entry, M.config.debounce_delay, function()
                vim.lsp.buf.signature_help({
                    focusable = false,
                    close_events = { 'CursorMoved', 'CursorMovedI', 'BufLeave', 'BufWinLeave' },
                    anchor_bias = 'above',
                })
            end)
        end,
    })
end

return M
