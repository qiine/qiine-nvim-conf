return
{
    "stevearc/oil.nvim",
    dependencies = {
        "refractalize/oil-git-status.nvim",
    },

    config = function()
        require("oil").setup({
            delete_to_trash = true,

            --View
            prompt_save_on_select_new_entry = true,
            skip_confirm_for_simple_edits = true,

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
                spell = true,
            },
            win_options = {
                --wrap          = false,
                signcolumn    = "yes:2",
                cursorcolumn = false,
                foldcolumn = "0",
                spell = false,
                list = false,
                conceallevel = 3,
                concealcursor = "nvic",
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

                ["<CR>"] = { function() vim.cmd("Neotree close") require("oil").select() end, mode="n" },
                ["<2-LeftMouse>"] = {"actions.select", mode = "n"},
                ["<S-CR>"] = { "actions.select", opts = { tab = true } }, --open in newtab don't close curr

                ["q"] = { function() vim.cmd("Neotree close") require("oil").close() end, mode="n" },
                ["<F5>"] = "actions.refresh",
                ["gx"] = "actions.open_external",

                ["-"] = { "actions.parent", mode = "n" },
                ["`"] = { "actions.cd", mode = "n" },
                ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },

                ["gs"] = { "actions.change_sort", mode = "n" },
                ["gp"] = "actions.preview",
                ["gh"] = { "actions.toggle_hidden", mode = "n" },

                ["n"] = {
                    function()
                        vim.cmd("normal! o")
                        vim.cmd("startinsert")
                        vim.api.nvim_put({ "new_file.txt" }, "", false, true)
                        vim.cmd("normal! 0")
                        vim.cmd("normal! v$")
                    end
                },
                ["N"] = {
                    function()
                        vim.cmd("normal! o")
                        vim.cmd("startinsert")
                        vim.api.nvim_put({ "new_folder/" }, "", false, true)
                        vim.cmd("normal! 0")
                        vim.cmd("normal! v$")
                    end
                },
                ["<Del>"] = { function() vim.cmd("normal! dd") end, mode = "n" },
                ["<F2>"] = { function() vim.cmd("normal! cc") vim.cmd("startinsert") end, mode = "n" },
            },
        })

        --Quick open
        vim.keymap.set({ "i", "n", "v" }, "*-", function()
            if vim.bo.filetype == "oil" then return end

            vim.cmd("stopinsert")

            local fp = vim.fn.expand("%:p")
            local fd = fp:match("^(.*)/")
            if not fd then fd = vim.fn.expand("~") end --fallback
            vim.cmd('cd ' .. fd) --ensure proper path

            local oil = require("oil")
            local util = require("oil.util")
            oil.open()
            util.run_after_load(0, function()
                vim.cmd("stopinsert")
                --oil.open_preview()
            end)

            --if vim.bo.filetype ~= "" then
            vim.cmd("bp")
            vim.cmd("bd")

            --vim.cmd("Neotree")
            --vim.cmd("wincmd p")
        end)
        --vim.keymap.set({"i","n","v"}, "<C-o>", "<esc><cmd>Oil --float<CR>")

        --Close Neotree in this context
        vim.api.nvim_create_autocmd('BufDelete', {
            pattern = '*oil*',
            callback = function()
                vim.cmd("Neotree close")
            end,
        })

        --For git signs
        require("oil-git-status").setup()
    end,
}

