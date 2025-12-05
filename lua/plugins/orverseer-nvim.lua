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

            task_win = {
                -- How much space to leave around the floating window
                padding = 1,
                border = nil,
                -- Set any window options here (e.g. winhighlight)
                win_opts = {},
            },

            -- templates = {
            --     vim.fn.stdpath("config") .. "/overseer/tasks",
            -- },

            -- custom template
            -- require('overseer').register_template({
                -- Template definition (see below)
                -- })

            keymaps = {
                ["d"] = { "keymap.run_action", opts = { action = "dispose" }, desc = "Dispose task" },
                ["<M-q>"] = {
                    "keymap.run_action",
                    opts = { action = "open output in quickfix" },
                    desc = "Open task output in the quickfix",
                },
            },
        })

        vim.api.nvim_create_user_command("OverseerRunNvimLua", function()
            require('overseer').run_task({name = "run nvimlua"}, function(task)
                if task then
                    require('overseer').open({ enter = false })
                end
            end)
        end, {})

    end
}
