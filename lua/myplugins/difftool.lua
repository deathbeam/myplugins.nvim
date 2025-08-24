local M = {
    config = {
        rename = {
            detect = true, -- whether to detect renames, can be slow on large directories so disable if needed
            similarity = 0.5, -- minimum similarity for rename detection
            max_size = 1024 * 1024, -- maximum file size for rename detection
        },
        highlight = {
            A = 'DiffAdd', -- Added
            D = 'DiffDelete', -- Deleted
            M = 'DiffText', -- Modified
            R = 'DiffChange', -- Renamed
        },
    },
}

local layout = {
    left_win = nil,
    right_win = nil,
}

-- helper to calculate file similarity
local function calculate_similarity(file1, file2)
    local size1 = vim.fn.getfsize(file1)
    local size2 = vim.fn.getfsize(file2)

    -- skip empty files or files with vastly different sizes
    if size1 <= 0 or size2 <= 0 or size1 / size2 > 2 or size2 / size1 > 2 then
        return 0
    end

    -- skip large files
    if size1 >= M.config.rename.max_size or size2 >= M.config.rename.max_size then
        return 0
    end

    -- Safely read files
    local ok1, content1 = pcall(vim.fn.readfile, file1)
    local ok2, content2 = pcall(vim.fn.readfile, file2)
    if not ok1 or not ok2 then
        return 0
    end

    -- count matching lines
    local common_lines = 0
    local total_lines = math.max(#content1, #content2)
    if total_lines == 0 then
        return 0
    end

    -- build frequency map of non-empty lines
    local seen = {}
    for _, line in ipairs(content1) do
        if #line > 0 then
            seen[line] = (seen[line] or 0) + 1
        end
    end

    -- count matching lines
    for _, line in ipairs(content2) do
        if #line > 0 and seen[line] and seen[line] > 0 then
            seen[line] = seen[line] - 1
            common_lines = common_lines + 1
        end
    end

    return common_lines / total_lines
end

-- Set up a consistent layout with two diff windows
local function setup_layout(with_qf)
    if
        layout.left_win
        and vim.api.nvim_win_is_valid(layout.left_win)
        and layout.right_win
        and vim.api.nvim_win_is_valid(layout.right_win)
    then
        return false
    end

    vim.cmd.only()

    -- Save current window as left window
    layout.left_win = vim.api.nvim_get_current_win()

    -- Create right window
    vim.cmd.vsplit()
    layout.right_win = vim.api.nvim_get_current_win()

    -- Create quickfix window
    if with_qf then
        vim.cmd('botright copen')
    end
end

-- Edit a file in a specific window
local function edit_in(winnr, file)
    vim.api.nvim_win_call(winnr, function()
        local current = vim.fs.abspath(vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(winnr)))

        -- Check if the current buffer is already the target file
        if current == (file and vim.fs.abspath(file) or '') then
            return
        end

        -- Read the file into the buffer
        vim.cmd.edit(vim.fn.fnameescape(file))
    end)
end

-- Diff two files
local function diff_files(left_file, right_file, with_qf)
    setup_layout(with_qf)

    edit_in(layout.left_win, left_file)
    edit_in(layout.right_win, right_file)

    vim.cmd('diffoff!')
    vim.api.nvim_win_call(layout.left_win, vim.cmd.diffthis)
    vim.api.nvim_win_call(layout.right_win, vim.cmd.diffthis)
end

-- Diff two directories
local function diff_directories(left_dir, right_dir)
    -- Create a map of all relative paths
    local all_paths = {}
    local left_only = {}
    local right_only = {}

    -- Helper to process files from a directory
    local function process_files(dir_path, is_left)
        local files = vim.fs.find(function()
            return true
        end, { limit = math.huge, path = dir_path, follow = false })

        for _, full_path in ipairs(files) do
            local rel_path = full_path:sub(#dir_path + 1)
            full_path = vim.fn.resolve(full_path)

            if vim.fn.isdirectory(full_path) == 0 then
                all_paths[rel_path] = all_paths[rel_path] or { left = nil, right = nil }

                if is_left then
                    all_paths[rel_path].left = full_path
                    if not all_paths[rel_path].right then
                        left_only[rel_path] = full_path
                    end
                else
                    all_paths[rel_path].right = full_path
                    if not all_paths[rel_path].left then
                        right_only[rel_path] = full_path
                    end
                end
            end
        end
    end

    -- Process both directories
    process_files(left_dir, true)
    process_files(right_dir, false)

    -- Detect possible renames
    local renamed = {}
    if M.config.rename.detect then
        for left_rel, left_path in pairs(left_only) do
            local best_match = { similarity = M.config.rename.similarity, path = nil }

            for right_rel, right_path in pairs(right_only) do
                local similarity = calculate_similarity(left_path, right_path)

                if similarity > best_match.similarity then
                    best_match = {
                        similarity = similarity,
                        path = right_path,
                        rel = right_rel,
                    }
                end
            end

            if best_match.path then
                renamed[left_rel] = best_match.rel
                all_paths[left_rel].right = best_match.path
                all_paths[best_match.rel] = nil
                left_only[left_rel] = nil
                right_only[best_match.rel] = nil
            end
        end
    end

    -- Convert to quickfix entries
    local qf_entries = {}
    for rel_path, files in pairs(all_paths) do
        local status = 'M' -- Modified (both files exist)
        if not files.left then
            status = 'A' -- Added (only in right)
            files.left = left_dir .. rel_path
        elseif not files.right then
            status = 'D' -- Deleted (only in left)
            files.right = right_dir .. rel_path
        elseif renamed[rel_path] then
            status = 'R' -- Renamed
        end

        table.insert(qf_entries, {
            filename = files.right,
            text = status,
            user_data = {
                diff = true,
                rel = rel_path,
                left = files.left,
                right = files.right,
            },
        })
    end

    -- Sort entries by filename for consistency
    table.sort(qf_entries, function(a, b)
        return a.user_data.rel < b.user_data.rel
    end)

    vim.fn.setqflist({}, 'r', {
        ---@diagnostic disable-next-line: assign-type-mismatch
        nr = '$',
        title = 'DiffTool',
        items = qf_entries,
        quickfixtextfunc = function(info)
            local items = vim.fn.getqflist({ id = info.id, items = 1 }).items
            local out = {}
            for item = info.start_idx, info.end_idx do
                local entry = items[item]
                table.insert(out, entry.text .. ' ' .. entry.user_data.rel)
            end
            return out
        end,
    })

    setup_layout(true)
    vim.cmd.cfirst()
end

-- Diff two files or directories
---@param left string
---@param right string
function M.diff(left, right)
    if not left or not right then
        vim.notify('Both arguments are required', vim.log.levels.ERROR)
        return
    end

    local group = vim.api.nvim_create_augroup('myplugins-difftool', { clear = true })
    local ns_id = vim.api.nvim_create_namespace('difftool_qf')

    vim.api.nvim_create_autocmd('BufWinEnter', {
        group = group,
        pattern = 'quickfix',
        callback = function(args)
            vim.api.nvim_buf_clear_namespace(args.buf, ns_id, 0, -1)
            local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)

            -- Map status codes to highlight groups
            for i, line in ipairs(lines) do
                local status = line:match('^(%a) ')
                local hl_group = M.config.highlight[status]

                if hl_group then
                    vim.hl.range(args.buf, ns_id, hl_group, { i - 1, 0 }, { i - 1, 1 })
                end
            end
        end,
    })

    vim.api.nvim_create_autocmd('BufWinEnter', {
        group = group,
        pattern = '*',
        callback = function(args)
            -- Get the current quickfix list info
            local qf_info = vim.fn.getqflist({ idx = 0, items = 1, size = 1 })
            if qf_info.size == 0 then
                return
            end

            -- Check if the entry is a diff entry
            local entry = qf_info.items[1]
            if not entry or not entry.user_data or not entry.user_data.diff or args.buf ~= entry.bufnr then
                return
            end

            vim.schedule(function()
                diff_files(entry.user_data.left, entry.user_data.right, true)
            end)
        end,
    })

    if vim.fn.isdirectory(left) == 1 and vim.fn.isdirectory(right) == 1 then
        diff_directories(left, right)
    elseif vim.fn.filereadable(left) == 1 and vim.fn.filereadable(right) == 1 then
        diff_files(left, right)
    else
        vim.notify('Both arguments must be files or directories', vim.log.levels.ERROR)
    end
end

function M.setup(config)
    M.config = vim.tbl_deep_extend('force', M.config, config or {})

    vim.api.nvim_create_user_command('DiffTool', function(opts)
        if #opts.fargs >= 2 then
            M.diff(opts.fargs[1], opts.fargs[2])
        else
            vim.notify('Usage: DiffTool <left> <right>', vim.log.levels.ERROR)
        end
    end, { nargs = '*', force = true })
end

return M
