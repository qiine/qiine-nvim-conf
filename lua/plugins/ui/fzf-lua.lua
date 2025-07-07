return
{
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },

    config = function()
        require('fzf-lua').register_ui_select()
        require("fzf-lua").setup({
            defaults = {
                actions = {
                    ["esc"] = ""  --restore esc to normal mode (now quit with C-w)
                },
            },

            winopts = {
                title_pos    = "center",
                border       = "rounded",  --single
                height       = 0.75,            -- window height
                width        = 0.98,            -- window width
                row          = 0.50,            -- window row position (0=top, 1=bottom)
                col          = 0.51,            -- window col position (0=left, 1=right)
                backdrop     = 100, --opacity
                preview = {
                    --hidden = "hidden",
                    border = "border",
                    layout = "horizontal",
                    horizontal = "right:45%",
                },
            },
            fzf_opts = {
                ["--layout"] = "default",  --reverse

            },

            files = {
                cmd = [[
                    rg --files --hidden \
                    -g 'Downloads/**' \
                    -g '/**' \
                    -g '!.git/**' \
                    -g '!.npm/**' \
                    -g '!.local/share/**' \
                    -g '!.local/share/Trash/**' \
                    -g '!.local/share/nvim/undo/**' \
                    -g '!cache/**' \
                    -g '!.var/**' \
                    -g '!.cache/**' \
                    -g '!node_modules/**' \
                    -g '!.mozilla/**' \
                    -g '!.cargo/**' \
                    -g '!*/steam-runtime-sniper/**' \
                    -g '!**/containers/**'
                ]]
            },

            keymap = {
                --f4 toggle prev
            }
        })

        --find files
        vim.keymap.set({"i","n","v"}, "<M-f>", function()
            require("fzf-lua").files({
                cwd="~",
            })
        end, { silent = true, desc = "Fuzzy find file" })

        --find files in project
        vim.keymap.set({"i","n","v"}, "<C-S-f>", function()
            local path = require("fzf-lua.path")
            require("fzf-lua").files({
                cwd = path.git_root({}),
            })
        end, { silent = true, desc = "Fuzzy find file" })

        --find files in project
        vim.keymap.set({"i","n","v"}, "<C-S-f>", function()
            local path = require("fzf-lua.path")
            require("fzf-lua").files({
                cwd = path.git_root({}),
            })
        end, { silent = true, desc = "Fuzzy find file" })


        --grep curr dir
        vim.keymap.set({"i","n","v"}, "<M-f><S-g>", function()
            --local path = require("fzf-lua.path")

            require("fzf-lua").live_grep({
                --cwd = path.git_cwd({}),
            })
        end, { silent = true, desc = "Live grep" })

        --grep curr project
        vim.keymap.set({"i","n","v"}, "<C-S-g>", function()
            local path = require("fzf-lua.path")
            require("fzf-lua").live_grep({
                cwd = path.git_root({}),
            })
        end, { noremap = true, silent = true, desc = "Live grep" })

        --grep root
        vim.keymap.set({"i","n","v"}, "<M-f>g", function()
            require("fzf-lua").live_grep({
                --cmd = "git grep -i --line-number --column --color=always",
                cwd = "~"
            })
        end, { silent = true, desc = "Live grep" })


        --search builtins
        vim.keymap.set({"i","n","v"}, "<M-f>b", function()
            require("fzf-lua").builtin({
                winopts = { preview = {} }
            })
        end, { silent = true, desc = "Live grep" })


    end
}
