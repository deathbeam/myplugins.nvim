local M = {
    config = {
        dirs = {
            '.git',
            '.git/',
            '_darcs/',
            '.hg/',
            '.bzr/',
            '.svn/',
            '.editorconfig',
            'Makefile',
            '.pylintrc',
            'requirements.txt',
            'setup.py',
            'package.json',
            'mvnw',
            'gradlew',
        },
    },
}

local utils = require('config.utils')

local root_cache = {}
local function find_root(markers)
    local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    local bufdirname = vim.fn.fnamemodify(bufname, ':p:h'):gsub('oil://', '')
    if root_cache[bufdirname] then
        return root_cache[bufdirname]
    end

    local root_dir = vim.fs.root(bufdirname, markers)
    if root_dir then
        root_cache[bufdirname] = root_dir
        return root_dir
    end
    return nil
end

function M.setup(config)
    M.config = utils.cfg(M.config, config)

    utils.au({ 'VimEnter', 'BufEnter' }, {
        desc = 'myplugins: Set current directory to project root',
        pattern = '*',
        nested = true,
        callback = function(args)
            local root_dir = find_root(M.config.dirs)
            if root_dir then
                vim.api.nvim_set_current_dir(root_dir)
                if args.buf then
                    vim.b.workspace_folder = root_dir
                end
            end
        end,
    })
end

return M
