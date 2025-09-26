return
{
    'nvim-treesitter/nvim-treesitter',
    enabled = true,
    event = "BufEnter",
    version = false,
    build = ':TSUpdate',

    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
        "OXY2DEV/markview.nvim", --markview need to be loaded before nvim-treesitter!
    },

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

        textobjects = {
            select = {
                enable = true,

                -- Automatically jump forward to textobj, similar to targets.vim
                lookahead = true,

                keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ["if"] = "@function.inner",
                    ["af"] = "@function.outer",
                    ["ii"] = "@conditional.outer",
                    ["ai"] = "@conditional.inner",
                    ["il"] = "@loop.inner",
                    ["al"] = "@loop.outer",
                    -- ["ic"] = "@comment.inner",
                    -- ["ac"] = "@comment.outer",
                },
            },
        },

    },

    config = function(_, opts)
        require('nvim-treesitter.configs').setup(opts)
    end

}
