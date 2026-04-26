return {
    'nvim-treesitter/nvim-treesitter',
    enabled = true,
    lazy = false,
    version = false,
    branch = "main",
    build = ':TSUpdate',

    dependencies = {
        "OXY2DEV/markview.nvim",  -- markview need to be loaded before nvim-treesitter!
    },

    opts = {
        install_dir = vim.fn.stdpath('data') .. '/site',

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
        require('nvim-treesitter').setup(opts)
        require('nvim-treesitter').install({
            'bash',
            'fish',

            'c',
            'cpp',
            'rust',

            'gitcommit',
            'graphql',

            'java',

            'javascript',
            'typescript',
            'tsx',

            'json',
            'json5',
            -- 'jsonc', -- TODO unsuported ?

            'lua',

            'python',

            'markdown',
            'markdown_inline',
            'html',

            'yaml',
            'toml',
            'query',
            'regex',
            'rasi',
            'scss',

            'vim',
            'vimdoc',

            "nix",
        })
    end,

}
