return
{
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    enabled = false,
    dependencies = {
        "nvim-lua/popup.nvim",
        "nvim-lua/plenary.nvim",
        --"nvim-telescope/telescope-ui-select.nvim",
        "nvim-telescope/telescope-media-files.nvim",
    },

    config = function()
        local builtin = require('telescope.builtin')
        local act = require("telescope.actions")

        vim.api.nvim_set_hl(0, "TelescopeNormal", {bg = "none"})

        require('telescope').setup{
            defaults = {
                layout_strategy = "horizontal",
                layout_config = {
                    width = 0.7,
                    height = 0.9,
                    preview_width = 30.0,
                    preview_cutoff = 100,
                    prompt_position = "bottom",
                },
                path_display = {"smart"},
                sorting_strategy = "descending",
                file_ignore_patterns = {
                    "node_modules", ".git", ".venv", ".cache",
                },
                hidden = true, --show hidden files
                mappings = {
                    n = {
                        ["q"] = act.close,
                    },
                    i = { },
                },
            },
            pickers = {
                builtin = {
                    previewer = false,
                    layout_config = {
                        width = 0.35,
                        height = 0.8,
                    },
                },
                --find_files = {
                --    previewer = true,
                --    hidden = true,
                --    find_command = {
                --        'fdfind',
                --        '--type', 'f',
                --        '--no-follow',
                --        '--max-depth', '30',
                --        '--max-results', '100000'
                --    },
                --},
                live_grep = {
                    previewer = true,
                    hidden = true,
                },
                colorscheme = {
                    enable_preview = true,
                },
            },

            extensions =
            {
                --["ui-select"] = {
                --    require("telescope.themes").get_dropdown {
                --        -- even more opts
                --    }
                --},

                ["media_files"] = {
                  -- filetypes whitelist
                  -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
                  filetypes = {"png", "webp", "jpg", "jpeg"},
                  -- find command (defaults to `fd`)
                  find_cmd = "rg"
                }
            },
        }--setup

        -- To get ui-select loaded and working with telescope, you need to call
        -- load_extension, somewhere after setup function:
        --require("telescope").load_extension("ui-select")

        vim.keymap.set({"i","n","v"}, '<M-f>b', builtin.builtin, {desc = 'Telescope search builtins'})

        --find files in proj
        vim.keymap.set(
            {"i","n","v"},
            '<C-S-f>',
            function()
                local p = vim.fn.getcwd()
                builtin.find_files({
                    cwd = p,
                    previewer = true,
                    prompt_title = 'Find Files in cwd: '..p,
                })
            end,
            {desc = 'Telescope find files in cwd'}
        )
        vim.keymap.set(
            {"i","n","v"},
            '<M-f>',
            function()
                local p = vim.fn.expand("~")
                --builtin.find_files({
                --    cwd = p,
                --    prompt_title = 'Find Files in: ' .. p,
                --})
                builtin.find_files({
                    prompt_title = 'Find Files in: ' .. p,
                    find_command = {
                        'rg',
                        '--files',
                        --'--hidden',
                        --"-g", '!Trash',
                        --"-g", '!node_modules',
                        --"-g", "!.git",
                        p
                    },
                })
            end,
            {desc = 'Telescope find files in home'}
        )

        --grep in proj
        vim.keymap.set({"i","n","v"}, '<M-f>g',
            function()
                local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
                local p = vim.fn.getcwd()
                builtin.live_grep({
                    cwd = git_root,
                    prompt_title = 'Grep in: ' .. git_root,
                })
            end,
            {desc='Telescope live grep'}
        )

        vim.keymap.set({"i","n","v"}, '<M-b>', builtin.buffers, {desc='Telescope buffers'})
        vim.keymap.set({"i","n","v"}, '<M-f>o', builtin.vim_options, {desc='Telescope vim opts'})

    end,--config
}--return
