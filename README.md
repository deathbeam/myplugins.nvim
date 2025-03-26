# myplugins.nvim

A collection of plugins that were at some point sitting in my dotfiles.

## Usage

```lua
require('myplugins').setup {
    bigfile = {},
    bufcomplete = {
        border = 'single',
    },
    signature = {
        border = 'single',
    },
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
Bookmark files and lines using quickfix list.

### Default config
```lua
{
    name = 'Bookmarks', -- Name of the quickfix list
}
```

### Usage
Best used with `session` plugin with `extra.quickfix = true` to automatically save and load quickfix lists (including bookmarks).

```lua
local bookmarks = require('myplugins.bookmarks')
vim.keymap.set('n', '<leader>jj', bookmarks.toggle_file)
vim.keymap.set('n', '<leader>jl', bookmarks.toggle_line)
vim.keymap.set('n', '<leader>jk', bookmarks.load)
vim.keymap.set('n', '<leader>jx', bookmarks.clear)
vim.keymap.set('n', ']j', function()
    bookmarks.load()
    vim.cmd('silent! cnext')
end)
vim.keymap.set('n', '[j', function()
    bookmarks.load()
    vim.cmd('silent! cprevious')
end)
```

## bufcomplete
LSP + treesitter autocompletion

### Default config
```lua
{
    border = nil, -- Documentation border style
    entry_mapper = nil, -- Custom completion entry mapper
    debounce_delay = 100,
}
```

### Usage
For best completion experience:

```lua
vim.o.completeopt = 'menuone,noselect,noinsert,popup'
```

And you also ideally want to set the capabilities so Neovim will fetch documentation when resolving completion items:

```lua
-- Here we grab default Neovim capabilities and extend them with ones we want on top
local capabilities = vim.tbl_deep_extend('force', 
    vim.lsp.protocol.make_client_capabilities(), 
    require('autocomplete.capabilities')
)

-- Now set capabilities on your LSP servers
require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
    capabilities = capabilities
}
```

## cmdcomplete
Command-line autocompletion

> [!WARNING]
> Requires neovim 0.11.0+

## diagnostics
Automatically show diagnostic popup on cursor hover and disable `DiagnosticUnnecessary` highlighting for code under cursor.

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

## rooter
Automatically changes working directory to project root.

### Default config
```lua
{
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

## signature
Automatically show function signature on cursor hover in insert mode.

### Default config
```lua
{
    border = nil, -- Signature border style
    width = 80, -- Max width of signature window
    height = 25, -- Max height of signature window
    debounce_delay = 100,
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
