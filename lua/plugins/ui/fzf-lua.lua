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
                width        = 1,            -- window width
                row          = 0.50,            -- window row position (0=top, 1=bottom)
                col          = 0.51,            -- window col position (0=left, 1=right)
                backdrop     = 100, --opacity
                preview = {
                    --hidden = "hidden",
                    border = "border",
                    layout = "horizontal",
                    horizontal = "right:47%",
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
                    -g '!*.log' \
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
                fzf = {
                    ["tab"] = function() require("fzf-lua").builtin({
                        winopts = {
                            --preview = {hidden = true}
                        }
                    }) end,

                }
            }
        })

        --find files in currdir
        vim.keymap.set({"i","n","v"}, "<M-f>d", function()
            require("fzf-lua").files({})
        end, { silent = true, desc = "Fuzzy find dir in cwd" })

        --find files in project
        vim.keymap.set({"i","n","v"}, "<C-S-f>", function()
            local path = require("fzf-lua.path")
            require("fzf-lua").files({
                cwd = path.git_root({}),
            })
        end, { silent = true, desc = "Fuzzy find file" })

        --find files
        vim.keymap.set({"i","n","v"}, "<M-f>", function()
            require("fzf-lua").files({
                cwd="~",
            })
        end, { silent = true, desc = "Fuzzy find file" })


        --grep curr dir
        vim.keymap.set({"i","n","v"}, "<M-f><S-g>", function()
            require("fzf-lua").live_grep({})
        end, { silent = true, desc = "" })

        --grep curr project
        vim.keymap.set({"i","n","v"}, "<C-S-g>", function()
            local path = require("fzf-lua.path")
            require("fzf-lua").live_grep({
                cwd = path.git_root({}),
            })
        end, { noremap = true, silent = true, desc = "live grep project" })

        --grep
        vim.keymap.set({"i","n","v"}, "<M-f>g", function()
            require("fzf-lua").live_grep({
                cwd = "~"
            })
        end, { silent = true, desc = "Live grep" })



        --fuzzy cd]
        vim.keymap.set({"i","n","v"}, "<M-f>c", function()
            require("fzf-lua").files({
                cmd = "fdfind --type d",
            })
            --require("fzf-lua").fzf_exec(
        --    "fd --type d",
        --    {
            --    prompt = "Change dir > ",
            --        actions = {
                --         ["default"] = function(selected)
                    --                vim.cmd("cd " .. selected[1])
                    --            end
                    --        },
                    --})]
        end, { silent = true, desc = "Fuzzy cd to dir under ~" })

        --search ft
        vim.keymap.set({"i","n","v"}, "<M-f>t", function()
            require("fzf-lua").filetypes({})
        end, { silent = true, desc = "search and set filetypes" })


        --search buffers
        vim.keymap.set({"i","n","v"}, "<M-f>b", function()
            require("fzf-lua").buffers({})
        end, { silent = true, desc = "" })


        --search builtins
        vim.keymap.set({"i","n","v"}, "<M-f>f", function()
            require("fzf-lua").builtin({})
        end, { silent = true, desc = "Search builtins" })


    end
}
