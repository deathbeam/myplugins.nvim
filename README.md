# myplugins.nvim

A collection of plugins that were at some point sitting in my dotfiles.

## Usage

```lua
require('myplugins').setup {
    bigfile = {},
    bufcomplete = {},
    lspecho = {},
    lspsignature = {},
    zoom = {}
    -- Etc etc, format is <plugin_name> = { <plugin_configuration> }
}
```

## bigfile
Automatically disable stuff for large files

### Default config
```lua
{
    max_size = 1024 * 1024,
}
```

## bookmarks
Bookmark files using native marks.

### Usage

```lua
local bookmarks = require('myplugins.bookmarks')
vim.keymap.set('n', '<leader>mm', bookmarks.select, { desc = 'Bookmarks Select' })
vim.keymap.set('n', '<leader>mq', bookmarks.quickfix, { desc = 'Bookmarks Quickfix' })
vim.keymap.set('n', '<leader>md', bookmarks.delete_buffer, { desc = 'Bookmarks Delete Buffer' })
vim.keymap.set('n', '<leader>mD', bookmarks.delete_all, { desc = 'Bookmarks Delete All' })
vim.keymap.set('n', "'", function()
    bookmarks.jump_to_mark(vim.fn.getcharstr())
end, { desc = 'Bookmarks Jump to Mark' })
vim.keymap.set('n', 'm', function()
    bookmarks.toggle_mark(vim.fn.getcharstr())
end, { desc = 'Bookmarks Toggle Mark' })
```

## bufcomplete
LSP + treesitter autocompletion

> [!WARNING]
> Requires neovim 0.11.0+

### Default config
```lua
{
    entry_mapper = nil, -- Custom completion entry mapper
    debounce_delay = 100,
}
```

### Usage
For best completion experience:

```lua
vim.o.completeopt = 'menuone,noselect,noinsert,popup'
```

## cmdcomplete
Command-line autocompletion

> [!WARNING]
> Requires neovim 0.11.0+

## diagnostics
Automatically disable `DiagnosticUnnecessary` highlighting for code under cursor.

## difftool
`DiffTool <left> <right>` command for integration with `git difftool` and `git difftool --dir-diff`.

### Default config
```lua
{
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
}
```

### Usage
Add this to your `gitconfig`:

```ini
[diff]
    tool = nvim_difftool

[difftool "nvim_difftool"]
    cmd = nvim -c \"DiffTool $LOCAL $REMOTE\"
```

## httpyac
Simple plugin for running http files using [httpyac](https://httpyac.github.io/)

### Usage
```lua
local http = require('myplugins.httpyac')
vim.keymap.set('n', '<leader>ho', http.toggle)
vim.keymap.set('n', '<leader>hh', http.run)
vim.keymap.set('n', '<leader>hH', http.run_all)
vim.keymap.set('n', '<leader>he', http.select_env)
```

## lspdocs
Automatically show LSP documentation on completion item hover.

### Default config
```lua
{
    debounce_delay = 100,
}
```

## lspecho
Echo LSP progress to cmdline

### Default config
```lua
{
    echo = true, -- Echo progress messages, if set to false you can use .message() to get the current message
    decay = 3000, -- Message decay time in milliseconds
    interval = 100, -- Minimum time between echo updates in milliseconds
    attach_log = false, -- Attach to logMessage and showMessage
}
```

## lspsignature
Automatically show LSP function signature on cursor hover in insert mode.

### Default config
```lua
{
    debounce_delay = 100,
}
```

## rooter
Automatically changes working directory to project root.

### Default config
```lua
{
    dirs = {
        -- version control markers
        '.git/',
        '_darcs/',
        '.hg/',
        '.bzr/',
        '.svn/',
        -- exrc markers
        '.nvim.lua',
        '.nvimrc',
        '.exrc',
        -- generic root markers
        '.editorconfig',
        'Makefile',
        -- javascript
        'node_modules/',
        'package.json',
        -- python
        '.venv/',
        'pyproject.toml',
        '.pylintrc',
        'requirements.txt',
        'setup.py',
        -- c
        'CMakeLists.txt',
        -- rust
        'Cargo.toml',
        -- go
        'go.mod',
        -- java
        'mvnw',
        'gradlew',
    },
}
```

## session
Automatically saves and restores session in predefined folders (default ~/git)

### Default config
```lua
{
    session_dir = vim.fn.stdpath('data') .. '/sessions/',
    -- Directories where sessions are automatically saved
    dirs = {
        vim.fn.expand('~/git'),
    },
    -- Extra data to manage that is not normally saved in sessions
    extra = {
        quickfix = true, -- Save/load also quickfix lists
    }
}
```

## undotree
Undo tree visualization for `fzf-lua`.

### Usage
```lua
vim.keymap.set('n', '<leader>fu', require('myplugins.undotree').show)
```

## wiki
Simple wiki/note-taking functionality using `fzf-lua`.

### Default config
```lua
{
    dir = vim.fn.expand('~/vimwiki'),
}
```

### Usage
```lua
local wiki = require('myplugins.wiki')
vim.keymap.set('n', '<leader>wt', wiki.today)
vim.keymap.set('n', '<leader>wd', wiki.list_diary)
vim.keymap.set('n', '<leader>ww', wiki.list_wiki)
vim.keymap.set('n', '<leader>wn', wiki.new)
```

## zoom
Zoom in/out on the current window.

### Usage
```lua
local zoom = require('myplugins.zoom')
vim.keymap.set('n', '<leader>z', zoom.toggle)
```
