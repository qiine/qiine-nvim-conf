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

            -- lsp_file_methods = {
            --     enabled = true,
            --     timeout_ms = 1000,
            --     autosave_changes = true,
            -- },

            use_default_keymaps = false,
            keymaps = {
                ["<CR>"] = {
                    callback = function()
                        vim.cmd("norm! \27")
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
                    mode = {"i","n","v"},
                },
                ["<2-LeftMouse>"] = {
                    callback = function()
                        vim.cmd("norm! \27")
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
                    mode = {"i","n","v"},
                },
                ["<S-CR>"] = { "actions.select", opts = { tab = true } }, --open in newtab don't close curr
                ["gx"] = "actions.open_external",

                ["<C-w>"] = { "actions.close", mode = {"i","n","v"}, },
                ["<C-e>"] = { "actions.close", mode = {"i","n","v"}, },

                ["<C-Home>"] = {
                    callback = function()
                        require("oil.actions").parent.callback()
                        require("oil.actions").cd.callback()
                    end,
                    mode = {"i","n","v"},
                },
                ["<C-End>"] = {
                    callback = function()
                        require("oil").select({}, function() -- select curr
                            require("oil.actions").cd.callback()
                        end)
                    end,
                    mode = {"i","n","v"}
                },

                ["n"] = {
                    function()
                        vim.cmd("norm! o")
                        vim.api.nvim_put({ "new_file.txt" }, "", false, true)
                        vim.cmd("norm! 0vt.")
                    end,
                    desc = "New file",
                },
                ["N"] = {
                    function()
                        vim.cmd("norm! o")
                        vim.api.nvim_put({ "new_folder/" }, "", false, true)
                        vim.cmd("norm! 0v$")
                    end,
                    desc = "New dir",
                },
                ["<F2>"] = { function() vim.cmd('norm! "_ciw');vim.cmd("startinsert") end, mode = {"i","n"} },
                ["<Del>"] = { function() vim.cmd('norm! "_dd') end, mode = "n" },

                ["<C-s>"] = { "\27<Cmd>w<cr>", mode = {"i","n","v"} },

                ["qf"] = { "actions.add_to_qflist", mode = "n" },

                ["gs"] = { "actions.change_sort", mode = "n" },
                ["gp"] = "actions.preview",
                ["gh"] = { "actions.toggle_hidden", mode = "n" },
                ["<F5>"] = "actions.refresh",

                ["?"] = { "actions.show_help", mode = "n" },
            },
        })


        -- For git signs
        require("oil-git-status").setup()
    end,
}

