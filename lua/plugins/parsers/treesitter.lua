return
{
    "nvim-treesitter/nvim-treesitter",
    enabled = true,
    build = ":TSUpdate",
    dependencies = {
        "windwp/nvim-ts-autotag",
        "nvim-treesitter/nvim-treesitter-textobjects",
    },

    config = function()
                     
        local treesitter = require("nvim-treesitter.configs")

        treesitter.setup({

            --Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,
                      
            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
            auto_install = true,

            ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
            -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },

            indent = { enable = false },
        
            autotag =
            {
                --list of parser names, or "all" (the listed parsers MUST always be installed)
                ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
                enable = true,
            },

            ensure_installed =
            {
                "json",
                "jsonc",
                "javascript",
                "typescript",
                "tsx",
                "python",
                "yaml",
                "toml",
                "html",
                "css",
                "markdown",
                "markdown_inline",
                "bash",
                "lua",
                "vim",
                "dockerfile",
                "gitignore",
                "c",
                "rust",
            },

            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = false,
                },
            },

            context_commentstring = {
                enable = true,
                enable_autocmd = false,
            },
        })

    end,--setup
}
