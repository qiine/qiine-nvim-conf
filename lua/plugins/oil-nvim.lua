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
                buflisted = false, 
                bufhidden = "hide" --"hide", "wipe"
            },
            cleanup_delay_ms = 1000000000, --auto delete oil hidden buffers, false to turn this off

            columns = {
                "icon",
                --"permissions",
                "size",
                "mtime",
            },

            view_options = {
                show_hidden = true,
            },
            win_options = {
                wrap = false,
                signcolumn = "yes:2",
                cursorcolumn = true,
                foldcolumn = "0",
                spell = true,
                list = false,
                conceallevel = 3,
                concealcursor = "nvic",
            },
            preview_win = {
                update_on_cursor_moved = true,
                -- How to open the preview window "load"|"scratch"|"fast_scratch"
                preview_method = "fast_scratch",
                -- A function that returns true to disable preview on a file e.g. to avoid lag
                disable_preview = function(filename)
                    return false
                end,
                -- Window-local options to use for preview window buffers
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
                ["<MiddleMouse>"] = {"actions.select_tab"},
                
                ["q"] = { function() vim.cmd("Neotree close") require("oil").close() end, mode="n" },
                ["<F5>"] = "actions.refresh",
                ["gx"] = "actions.open_external",

                ["-"] = { "actions.parent", mode = "n" },
                ["`"] = { "actions.cd", mode = "n" },
                ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },

                ["gs"] = { "actions.change_sort", mode = "n" },
                ["gp"] = "actions.preview",
                ["gh"] = { "actions.toggle_hidden", mode = "n" },
            },
        })

        --Quick open to new tab
        vim.keymap.set({ "i", "n", "v" }, "*-", function()
            vim.cmd("stopinsert")

            --local fp = vim.fn.expand("%:p")
            --local fd = fp:match("^(.*)/")
            --vim.cmd('cd ' .. fd) --ensure proper path
            
            local oil = require("oil")
            local util = require("oil.util")
            oil.open()
            util.run_after_load(0, function()
                vim.cmd("stopinsert")
                --oil.open_preview() 
            end)

            --vim.cmd("Neotree") 
            --vim.cmd("wincmd p")
        end)
        vim.keymap.set({"i","n","v"}, "<C-o>", "<esc><cmd>Oil --float<CR>")

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

