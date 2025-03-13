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

## Plugins

### bigfile
Automatically disable stuff for large files

### bufcomplete
LSP + treesitter autocompletion

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

### cmdcomplete
> ![WARNING] Requires neovim 0.11.0+

Command-line autocompletion

### diagnostics
Automatically show diagnostic popup on cursor hover and disable `DiagnosticUnnecessary` highlighting for code under cursor.

### difftool
`DiffTool <left> <right>` command for integration with `git difftool` and `git difftool --dir-diff`.

Add this to your `gitconfig`:

```ini
[diff]
    tool = nvim_difftool

[difftool "nvim_difftool"]
    cmd = nvim -c \"DiffTool $LOCAL $REMOTE\"
```

### lspecho
Echo LSP progress to cmdline

### rooter
Automatically changes working directory to project root.

### session
Automatically saves and restores session in predefined folders (default ~/git)

### signature
Automatically show function signature on cursor hover in insert mode.

### undotree
Undo tree visualization for `fzf-lua`.

Usage:

```lua
vim.keymap.set('n', '<leader>fu', require('myplugins.undotree').show)
```

### wiki
Simple wiki/note-taking functionality using `fzf-lua`.

Usage:

```lua
local wiki = require('myplugins.wiki')
vim.keymap.set('n', '<leader>wt', wiki.today)
vim.keymap.set('n', '<leader>wd', wiki.list_diary)
vim.keymap.set('n', '<leader>ww', wiki.list_wiki)
vim.keymap.set('n', '<leader>wn', wiki.new)
```
