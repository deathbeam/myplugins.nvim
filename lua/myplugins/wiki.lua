local M = {
    config = {
        dir = vim.fn.expand('~/vimwiki'),
    },
}

local fzf = require('fzf-lua')

-- Open today's diary entry
function M.today()
    local today = os.date('%Y-%m-%d')
    local file = M.config.dir .. '/diary/' .. today .. '.md'
    vim.cmd('edit ' .. file)
end

-- List diary entries using fzf-lua
function M.list_diary()
    fzf.files({
        prompt = 'Diary > ',
        cwd = M.config.dir .. '/diary',
        raw_cmd = 'ls -1 | sort -r', -- Sort by date
        file_ignore_patterns = {
            '^[^0-9].*', -- Only show date-formatted files
        },
    })
end

-- List wiki entries using fzf-lua
function M.list_wiki()
    fzf.files({
        prompt = 'Wiki > ',
        cwd = M.config.dir,
        file_ignore_patterns = {
            'diary/.*', -- Exclude diary directory
        },
    })
end

-- Create new wiki entry
function M.new(title)
    if not title then
        title = vim.fn.input('Wiki title: ')
    end
    if title ~= '' then
        local filename = title:gsub(' ', '_') .. '.md'
        vim.cmd.edit(M.config.dir .. '/' .. filename)
    end
end

function M.setup(config)
    M.config = vim.tbl_deep_extend('force', M.config, config or {})
end

return M
