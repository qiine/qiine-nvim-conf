return
{
    'stevearc/overseer.nvim',

    config = function()
        require('overseer').setup({
            output = {
                -- Use a terminal buffer to display output. If false, a normal buffer is used
                use_terminal = true,
                -- If true, don't clear the buffer when a task restarts
                preserve_output = false,
            },

            -- fwin
            task_win = {
                -- How much space to leave around the floating window
                padding = 0,
                border = nil,
                -- Set any window options here (e.g. winhighlight)
                win_opts = {},
            },

            task_list = {
                max_width = 0.20,
                width     = nil,
                min_width = 0.15,

                max_height = { 20, 0.2 },
                min_height = 9,
            },

            -- template path
            -- templates = {
            --     vim.fn.stdpath("config").."/tasks",
            -- },

            keymaps = {
                ["d"] = { "keymap.run_action", opts = { action = "dispose" }, desc = "Dispose task" },
                ["<M-q>"] = {
                    "keymap.run_action",
                    opts = { action = "open output in quickfix" },
                    desc = "Open task output in the quickfix",
                },
                -- ["c"] = {
                     -- clear all task
                -- },
            },


            -- custom template
            -- require('overseer').register_template({
            --     name = "run",
            --     builder = function()
            --         return {
            --             name = "run",
            --             cmd  = {},
            --             args = {},
            --             cwd  = vim.fn.getcwd()
            --         }
            --     end,
            --     condition = { filetype = { "lua", "bash", "python" }, },
            -- })

        })

        -- vim.api.nvim_create_user_command("OverseerRunNvimLua", function()
        --     require('overseer').run_task({name = "run nvimlua"}, function(task)
        --         if task then
        --             require('overseer').open({ enter = false })
        --         end
        --     end)
        -- end, {})

    end
}
