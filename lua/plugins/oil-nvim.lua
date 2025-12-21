return
{
    "stevearc/oil.nvim",
    enabled = true,
    -- event = "UIEnter",

    dependencies = {
        "refractalize/oil-git-status.nvim",
    },

    config = function()
        local oil = require("oil")

        oil.setup({
            default_file_explorer = false,

            delete_to_trash = true,
            prompt_save_on_select_new_entry = true,
            skip_confirm_for_simple_edits   = true,
            watch_for_changes = true,

            buf_options = {
                buflisted = false,
                bufhidden = "hide" --"hide", "wipe" -- warn! wipe destroy oil reg data
            },
            cleanup_delay_ms = 2000, --auto delete oil hidden buffers, false to turn this off

            columns = {
                "icon",
                --"permissions",
                -- "size",
                -- "mtime",
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

            lsp_file_methods = {
                enabled = true,
                timeout_ms = 1000,
                autosave_changes = false,
            },

            use_default_keymaps = false,
            keymaps = {
                ["<CR>"] = { mode = {"i","n","v"},
                    desc = "Open entry, and cd if directory",
                    callback = function()
                        vim.cmd("norm! \27")

                        local entry = oil.get_cursor_entry()
                        if entry and entry.type == "directory" then
                            oil.select({}, function()
                                require("oil.actions").cd.callback({silent=true})
                            end)
                        else
                            require("oil.actions").select.callback()
                        end
                    end,
                },
                ["<2-LeftMouse>"] = { mode={"n","i","v"},
                    desc = "Open entry, and cd if directory",
                    callback = function()
                        vim.cmd("norm! \27")

                        local entry = oil.get_cursor_entry()
                        if entry and entry.type == "directory" then
                            oil.select({}, function()
                                require("oil.actions").cd.callback({silent=true})
                            end)
                        else
                            require("oil.actions").select.callback()
                        end
                    end,
                },
                ["<S-CR>"] = { "actions.select", opts = { tab = true } }, --open in newtab don't close curr
                ["gx"] = "actions.open_external",

                -- nav
                ["<Up>"] = {
                    mode = "n", -- cd upward if on "/."
                    callback = function()
                        local line = vim.api.nvim_win_get_cursor(0)[1]
                        if line == 1 then
                            require("oil.actions").parent.callback()
                            require("oil.actions").cd.callback({silent=true})
                        else
                            local upkey = vim.api.nvim_replace_termcodes("<Up>", true, true, true)
                            vim.api.nvim_feedkeys(upkey, "n", false)
                        end
                    end,
                },
                ["<C-Home>"] = {
                    mode = {"i","n","v"}, -- cd upward
                    callback = function()
                        require("oil.actions").parent.callback()
                        require("oil.actions").cd.callback({silent=true})
                    end,
                },
                ["<C-End>"] = {
                    mode = {"i","n","v"}, -- cd previous visited dir
                    callback = function()
                        oil.select({}, function() -- select curr
                            require("oil.actions").cd.callback({silent=true})
                        end)
                    end,
                },

                ["<M-Home>"] = {
                    mode = {"i","n","v"},
                    desc = "cd to project root",
                    callback = function()
                        local rootdir = vim.fs.dirname(vim.fs.find({ ".git", "Makefile", "package.json" }, { upward = true })[1])
                        if rootdir then
                            vim.cmd("cd "..rootdir)
                            oil.open(rootdir, nil, function()
                                vim.cmd("pwd")
                            end)
                        else
                            vim.notify("No project root found", vim.log.levels.WARN)
                        end
                    end,
                },
                ["<M-S-Home>"] = {
                    mode = {"i","n","v"},
                    desc = "cd to home",
                    callback = function()
                        vim.cmd("cd ")
                        oil.open(vim.fn.getcwd(), nil, function()
                            vim.cmd("pwd")
                        end)
                    end,
                },
                ["<M-C-S-Home>"] = { mode = {"i","n","v"},
                    desc = "cd root",
                    callback = function()
                        vim.cmd("cd /")
                        oil.open(vim.fn.getcwd(), nil, function()
                            vim.cmd("pwd")
                        end)
                    end,
                },

                ["<C-S-n>"] = { mode = {"i","n", "v" },
                    desc = "New file",
                    function()
                        vim.cmd("norm! o".."new_file.txt")
                        vim.cmd("stopinsert")
                        vim.cmd("norm! 0vt.")
                    end,
                },
                ["<C-S-n>d"] = { mode = { "i", "n", "v" },
                    desc = "New dir",
                    function()
                        vim.cmd("norm! o".."new_dir/")
                        vim.cmd("stopinsert")
                        vim.cmd("norm! 0vt/")
                    end,
                },

                ["<C-c>"] = { function() vim.cmd('norm! yy') end, mode = {"i","n"} },
                ["<C-x>"] = { function() vim.cmd('norm! dd') end, mode = {"i","n"} },
                ["<C-v>"] = { function() vim.cmd('norm! p') end, mode = {"i","n"} },
                -- rename
                ["<F2>"] = { function() vim.cmd('stopinsert | norm! viw') end, mode = {"i","n"} },
                ["<Del>"] = { function() vim.cmd('norm! "_dd') end, mode = "n" },

                -- save
                ["<C-s>"] = { "\27<Cmd>w<cr>", mode = {"i","n","v"} },

                ["gp"] = { "actions.preview", mode={"i","n","v"} },
                ["gs"] = { "actions.change_sort", mode = {"i","n"} },
                ["gh"] = { "actions.toggle_hidden", mode = {"i","n"} },
                ["<F5>"] = { mode = { "n", "i", "v" },
                    function()
                        oil.open(vim.fn.getcwd())
                        print("oil refreshed")
                    end
                },

                ["qf"] = { "actions.add_to_qflist", mode = {"i","n"} },

                ["?"] = { "actions.show_help", mode={"i","n","v"} },

                -- Exit oil
                ["<C-e>"] = { "<Cmd>bwipeout<CR>", mode = {"i","n","v"}, },
            },
        })

        vim.api.nvim_create_autocmd('User', {
            group = "UserAutoCmds",
            pattern = 'OilEnter',
            callback = function(params)
                vim.cmd("stopinsert")
                vim.keymap.set("n", "dd", function() return "dd" end, {expr=true, buffer=params.buf}) -- ensure orig dd is unmapped
                vim.keymap.set("n", "yy", function() return "yy" end, {expr=true, buffer=params.buf}) -- ensure orig dd is unmapped
            end,
        })

        -- Allow to accept with <CR>
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "oil_preview",
            callback = function(params)
                vim.keymap.set("n", "<CR>", "o", {buffer=params.buf, remap=true, nowait=true})
            end,
        })

        -- For git signs
        -- require("oil-git-status").setup()
    end,
}

