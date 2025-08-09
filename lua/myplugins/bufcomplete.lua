local M = {
    config = {
        entry_mapper = nil, -- Custom completion entry mapper
        debounce_delay = 100,
    },
}

local utils = require('myplugins.utils')
local methods = vim.lsp.protocol.Methods

local state = {
    entry = nil,
}

local function complete(prefix, cmp_start, items)
    if vim.fn.mode() ~= 'i' then
        return
    end

    items = vim.tbl_filter(function(item)
        return #prefix == 0 or #vim.fn.matchfuzzy({ item.word }, prefix) > 0
    end, items)

    if M.config.entry_mapper then
        items = vim.tbl_map(M.config.entry_mapper, items)
    end

    vim.fn.complete(cmp_start + 1, items)
end

local function complete_treesitter(bufnr, prefix, cmp_start)
    -- Check if treesitter is available
    local ok, parsers = pcall(require, 'nvim-treesitter.parsers')
    if not ok or not parsers.has_parser() then
        return
    end

    local locals = require('nvim-treesitter.locals')
    local defs = locals.get_definitions_lookup_table(bufnr)
    local ft = vim.bo[bufnr].filetype
    local items = {}

    for id, entry in pairs(defs) do
        local name = id:match('k_(.+)_%d+_%d+_%d+_%d+$')
        local node = entry.node
        local kind = entry.kind
        if node and kind then
            for _, k in ipairs(vim.lsp.protocol.CompletionItemKind) do
                if string.find(k:lower(), kind:lower()) then
                    kind = k
                    break
                end
            end

            local start_line_node, _, _ = node:start()
            local end_line_node, _, _ = node:end_()

            local full_text =
                vim.trim(vim.api.nvim_buf_get_lines(bufnr, start_line_node, end_line_node + 1, false)[1] or '')

            full_text = '```' .. ft .. '\n' .. full_text .. '\n```'
            items[#items + 1] = {
                word = name,
                kind = kind,
                info = full_text,
                icase = 1,
                dup = 0,
                empty = 0,
            }
        end
    end

    complete(prefix, cmp_start, items)
end

local function text_changed(args)
    if vim.fn.pumvisible() == 1 then
        return
    end

    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    if col == 0 or #line == 0 then
        return
    end

    local prefix, cmp_start = unpack(vim.fn.matchstrpos(line:sub(1, col), [[\k*$]]))

    utils.debounce(state.entry, M.config.debounce_delay, function()
        local clients = vim.lsp.get_clients({ bufnr = args.buf, method = methods.textDocument_completion })
        clients = vim.tbl_filter(function(client)
            return client and client.name ~= 'copilot'
        end, clients)

        if not vim.tbl_isempty(clients) and vim.lsp.completion then
            if vim.lsp.completion.trigger then
                vim.lsp.completion.trigger()
                return
            end
            if vim.lsp.completion.get then
                vim.lsp.completion.get()
                return
            end
        end

        complete_treesitter(args.buf, prefix, cmp_start)
    end)
end

function M.capabilities()
    return {
        textDocument = {
            completion = {
                completionItem = {
                    -- Fetch additional info for completion items
                    resolveSupport = {
                        properties = {
                            'documentation',
                            'detail',
                        },
                    },
                },
            },
        },
    }
end

function M.setup(config)
    M.config = vim.tbl_deep_extend('force', M.config, config or {})
    state.entry = utils.empty()

    local group = vim.api.nvim_create_augroup('myplugins-bufcomplete', { clear = true })

    vim.api.nvim_create_autocmd('TextChangedI', {
        group = group,
        desc = 'Auto show completion',
        callback = text_changed,
    })

    vim.api.nvim_create_autocmd('LspAttach', {
        group = group,
        desc = 'Attach completion events',
        callback = function(args)
            if not vim.lsp.completion or not vim.lsp.completion.enable then
                return
            end

            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if not client then
                return
            end
            if not client:supports_method(methods.textDocument_completion, args.buf) then
                return
            end

            vim.lsp.completion.enable(true, client.id, args.buf, {
                autotrigger = false,
                convert = function(item)
                    local entry = {
                        abbr = item.label,
                        kind = vim.lsp.protocol.CompletionItemKind[item.kind] or 'Unknown',
                        menu = item.detail or '',
                        icase = 1,
                        dup = 0,
                        empty = 0,
                    }

                    if M.config.entry_mapper then
                        return M.config.entry_mapper(entry)
                    end

                    return entry
                end,
            })
        end,
    })
end

return M
