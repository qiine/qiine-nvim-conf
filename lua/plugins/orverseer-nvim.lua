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

            -- templates = {
            --     vim.fn.stdpath("config") .. "/overseer/tasks",
            -- },

            keymaps = {
                ["<M-q>"] = {
                    "keymap.run_action",
                    opts = { action = "open output in quickfix" },
                    desc = "Open task output in the quickfix",
                },
            },
        })

    end
}
