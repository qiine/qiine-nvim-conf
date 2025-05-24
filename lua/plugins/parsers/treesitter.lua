return
{
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    version = false,
    build = ':TSUpdate',

    opts = {
        ensure_installed = {
            'bash',

            'c',
            'cpp',

            'rust',

            'fish',
            'gitcommit',
            'graphql',
            'html',
            'java',

            'javascript',
            'typescript',
            'tsx',

            'json',
            'json5',
            'jsonc',

            'lua',
            'markdown',
            'markdown_inline',

            'python',
            'query',
            'yaml',
            'regex',
            'rasi',
            'scss',
            'toml',
            'vim',
            'vimdoc',
        },
        highlight = { enable = true },
        incremental_selection = {
            enable = false,
            keymaps = {
                init_selection = '<cr>',
                node_incremental = '<cr>',
                scope_incremental = false,
                node_decremental = '<bs>',
            },
        },
        indent = {
            enable = false,
            -- Treesitter unindents Yaml lists for some reason.
            disable = { 'yaml' },
        },
    },
    config = function(_, opts)
        require('nvim-treesitter.configs').setup(opts)
    end
}
