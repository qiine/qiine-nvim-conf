return {
    "willothy/flatten.nvim",
    enabled = false,
    lazy = false,
    priority = 1001,
    -- config = true,
    opts = {
        nest_if_no_args = true,
        nest_if_cmds = true,
        window = {
            open = "curretn", -- alternate tab smart
            focus = "first"  -- "first" | "last"
        },

        hooks = {
            should_block = function(argv)
                if vim.b.wintype == "overview_task" then return true end
                return false
            end,
        },
    }
    -- or pass configuration with
    -- opts = {  }
    -- Ensure that it runs first to minimize delay when opening file from terminal
}
