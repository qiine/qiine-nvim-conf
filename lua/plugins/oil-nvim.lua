return
{
    "stevearc/oil.nvim",
    enabled = true,
    event = "UIEnter",

    dependencies = {
        "refractalize/oil-git-status.nvim",
    },

    config = function()
        require("oil").setup({
            default_file_explorer = false,

            delete_to_trash = true,
            prompt_save_on_select_new_entry = true,
            skip_confirm_for_simple_edits = true,
            watch_for_changes = true,

            buf_options = {
                buflisted = true,
                bufhidden = "wipe" --"hide", "wipe"
            },
            cleanup_delay_ms = 1000000000, --auto delete oil hidden buffers, false to turn this off

            columns = {
                "icon",
                --"permissions",
                --"size",
                --"mtime",
            },
            view_options = {
                show_hidden = true,
                -- natural_order = "fast",
            },
            win_options = {
                signcolumn    = "yes:2",
                foldenable    = false,
                foldcolumn    = "0",
                number        = false,
                wrap          = false,
                spell         = true,
                list          = true,
                conceallevel  = 3,
                concealcursor = "nvic",
                cursorcolumn  = false,
            },
            preview_win = {
                update_on_cursor_moved = true,
                preview_method = "fast_scratch",    --load"|"scratch"|"fast_scratch"
                disable_preview = function(filename)
                    return false
                end,
                win_options = {},
            },
            float = {
                padding = 5,
            },

            git = {
                -- Return true to automatically git add/mv/rm files
                add = function(path) return true end,
                mv = function(src_path, dest_path) return true end,
                rm = function(path) return true end,
            },

            use_default_keymaps = false,
            keymaps = {
                ["?"] = { "actions.show_help", mode = "n" },

                ["<CR>"] = {
                    callback = function()
                        local oil = require("oil")
                        local entry = oil.get_cursor_entry()
                        if entry and entry.type == "directory" then
                            oil.select({}, function()
                                require("oil.actions").cd.callback()
                            end)
                        else
                            require("oil.actions").select.callback()
                        end
                    end,
                    desc = "Open entry, and cd if directory",
                    mode = "n",
                },
                ["<2-LeftMouse>"] = {
                    callback = function()
                        local oil = require("oil")
                        local entry = oil.get_cursor_entry()
                        if entry and entry.type == "directory" then
                            oil.select({}, function()
                                require("oil.actions").cd.callback()
                            end)
                        else
                            require("oil.actions").select.callback()
                        end
                    end,
                    desc = "Open entry, and cd if directory",
                    mode = "n",
                },
                ["<S-CR>"] = { "actions.select", opts = { tab = true } }, --open in newtab don't close curr

                ["q"] = { function() require("oil").close() end, mode="n" },
                ["<F5>"] = "actions.refresh",
                ["gx"] = "actions.open_external",

                ["-"] = { "actions.parent", mode = "n" },
                ["`"] = { "actions.cd",     mode = "n" },
                ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },

                ["gs"] = { "actions.change_sort", mode = "n" },
                ["gp"] = "actions.preview",
                ["gh"] = { "actions.toggle_hidden", mode = "n" },

                ["n"] = {
                    function()
                        vim.cmd("norm! o")
                        vim.cmd("startinsert")
                        vim.api.nvim_put({ "new_file.txt" }, "", false, true)
                        vim.cmd("norm! 0")
                        vim.cmd("norm! v$")
                    end
                },
                ["N"] = {
                    function()
                        vim.cmd("norm! o")
                        vim.cmd("startinsert")
                        vim.api.nvim_put({ "new_folder/" }, "", false, true)
                        vim.cmd("norm! 0")
                        vim.cmd("norm! v$")
                    end
                },
                ["<Del>"] = { function() vim.cmd("norm! dd") end, mode = "n" },
                ["<F2>"] = { function() vim.cmd("norm! cc") vim.cmd("startinsert") end, mode = "n" },
            },
        })

        -- Close Neotree in this context
        -- vim.api.nvim_create_autocmd('BufDelete', {
        --     group = 'UserAutoCmds',
        --     callback = function()
                -- if vim.bo.filetype == "oil" then
            --         vim.cmd("Neotree close")
            --     end
        --     end,
        -- })

        -- Follow cwd changes
        vim.api.nvim_create_autocmd('DirChanged', {
            group = 'UserAutoCmds',
            callback = function()
                if vim.bo.filetype == "oil" then
                    vim.defer_fn(function()
                        require("oil").open(vim.fn.getcwd())
                    end, 20)
                end
            end,
        })


        -- For git signs
        -- require("oil-git-status").setup()
    end,
}

