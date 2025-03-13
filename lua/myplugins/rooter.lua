local M = {
    config = {
        dirs = {
            '.git/',
            '_darcs/',
            '.hg/',
            '.bzr/',
            '.svn/',
            '.editorconfig',
            '.venv/',
            'node_modules/',
            'Makefile',
            'CMakeLists.txt',
            '.pylintrc',
            'requirements.txt',
            'setup.py',
            'pyproject.toml',
            'package.json',
            'Cargo.toml',
            'go.mod',
            'mvnw',
            'gradlew',
        },
    },
}

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
    M.config = vim.tbl_deep_extend('force', M.config, config or {})

    local group = vim.api.nvim_create_augroup('myplugins-rooter', { clear = true })

    vim.api.nvim_create_autocmd({ 'VimEnter', 'BufEnter' }, {
        group = group,
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
