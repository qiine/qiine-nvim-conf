return
{
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },

    config = function()
        local fzfl = require("fzf-lua")
        require('fzf-lua').register_ui_select()
        require("fzf-lua").setup({
            defaults = {
                actions = {
                    ["esc"] = "",  --restore esc to normal mode (now quit with C-w)
                },

            },

            winopts = {
                title_pos    = "center",
                border       = "rounded", --single
                height       = 0.75,         -- window height
                width        = 1,            -- window width
                row          = 0.50,         -- window row position (0=top, 1=bottom)
                col          = 0.51,         -- window col position (0=left, 1=right)
                backdrop     = 100,  --opacity
                preview = {
                    --hidden = "hidden",
                    border = "border",
                    layout = "horizontal",
                    horizontal = "right:47%",
                },
            },
            fzf_opts = {
                ["--layout"] = "default",  -- default, reverse
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
                ]],
                case_mode = 'smart',
                actions = {
                    ['default'] = require('fzf-lua.actions').file_edit, --allow open multiples
                }
            },

            keymap = {
                ----f4 toggle prev
                --fzf = {
                --    ["tab"] = function() require("fzf-lua").builtin({
                --        winopts = {
                --            --preview = {hidden = true}
                --        }
                --    }) end,
                --},
            }
        })

        --find files in currdir
        vim.keymap.set({"i","n","v","t"}, "<M-f>c", function()
            require("fzf-lua").files({})
        end, {silent=true, desc="Fuzzy find dir in cwd"})

        --find files in project
        vim.keymap.set({"i","n","v","t"}, "<C-S-f>", function()
            require("fzf-lua").files({
                cwd = require("fzf-lua.path").git_root({}),
            })
        end, {silent=true, desc="Fuzzy find file in project" })

        --find files in home
        vim.keymap.set({"i","n","v","t"}, "<M-f>", function()
            require("fzf-lua").files({ cwd="~", })
        end, { silent=true, desc="Fuzzy find file in HOME"})

        --find recent files
        vim.keymap.set({"i","n","v","t"}, "<M-f>r", function()
            require("fzf-lua").oldfiles({ })
        end, {silent=true, desc="Fuzzy find recent files"})


        --find files in notes
        vim.keymap.set({"i","n","v","t"}, "<F49>", function()   --<M-F1>
            local home = vim.fn.expand("~")
            require("fzf-lua").files({
                cwd = "~/Personal/KnowledgeBase/Notes/"
            })
        end)

        --find selected files in notes
        vim.keymap.set("v", "<F49>", function()   --<M-F1>
            vim.cmd('norm! "zy')
            local txt = vim.trim(vim.fn.getreg("z"))
            require("fzf-lua").files({
                cwd = "~/Personal/KnowledgeBase/Notes/",
                fzf_opts = {
                    ['--query'] = txt,
                },
            })
        end)



        --grep curr dir
        vim.keymap.set({"i","n","v","t"}, "<M-f><S-g>", function()
            require("fzf-lua").live_grep({})
        end, { silent = true, desc = "grep" })

        --grep curr project
        vim.keymap.set({"i","n","v","t"}, "<C-S-g>", function()
            require("fzf-lua").live_grep({
                cwd = require("fzf-lua.path").git_root({}),
            })
        end, { noremap = true, silent = true, desc = "live grep project" })

        --grep curr project for selected
        vim.keymap.set("v", "<C-S-g>", function()
            require("fzf-lua").grep_visual({
                cwd = require("fzf-lua.path").git_root({})
            })
        end, {noremap=true, silent=true, desc="live grep selected in project"})

        --grep in home
        vim.keymap.set({"i","n","v","t"}, "<M-f>g", function()
            require("fzf-lua").live_grep({ cwd = "~" })
        end, { silent = true, desc = "Live grep in home" })

        --grep in notes
        vim.keymap.set({"i","n","t"}, "<F13>", function()   --<S-F1>
            require("fzf-lua").live_grep({
                cwd = "~/Personal/KnowledgeBase/Notes/"
            })
        end)

        --grep in help for selected
        vim.keymap.set("v", "<F13>", function()   --<S-F1>
            require("fzf-lua").grep_visual({
                cwd = "~/Personal/KnowledgeBase/Notes/"
            })
        end)

        --fuzzy cd
        fzfl.fuzzy_cd = function()
            fzfl.fzf_exec("fdfind . --type d", {     --or fd
                prompt = "cd ",
                cwd = "/",
                actions = {
                    ["default"] = function(selected)
                        if selected and #selected > 0 then
                            --local root = vim.fn.expand("~").."/"
                            --vim.cmd("cd " .. root .. selected[1])
                            vim.cmd("cd " .. "/" .. selected[1])
                        end
                    end,
                },
            })
        end

        vim.keymap.set({"i","n","v","t"}, "<M-f>d", function() fzfl.fuzzy_cd() end,
        {silent=true, desc = "Fuzzy cd to directory"})


        --find proj
        --TODO find project using .git
        --https://www.reddit.com/r/neovim/comments/1hhiidm/a_few_nice_fzflua_configurations_now_that_lazyvim/
        fzfl.projects = function()
            fzfl.fzf_exec("fdfind '.git$' -t d -d 20 -a -HI | xargs -I{} dirname {}", {
                cwd = "~/Personal/",
                actions = {
                    ["default"] = function(selected)
                        if selected and #selected > 0 then
                            vim.cmd("cd " .. selected[1])
                            print("Changed directory to: " .. selected[1])
                        end
                    end
                },
            })
        end

        vim.keymap.set({"i","n","v","t"}, "<M-f>p", function() fzfl.projects() end,
        {silent=true, desc="Fuzzy cd to git projects"})


        --search ft and set it
        vim.keymap.set({"i","n","v"}, "<M-f>t", function()
            require("fzf-lua").filetypes({})
        end, {silent = true, desc = "search and set filetypes" })

        --search builtins
        vim.keymap.set({"i","n","v","t"}, "<M-f>b", function()
            require("fzf-lua").builtin({})
        end, {silent = true, desc = "Search builtins" })

    end --config
}
