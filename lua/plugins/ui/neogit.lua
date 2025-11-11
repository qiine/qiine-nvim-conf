return {
    "TimUntersberger/neogit",
    enabled = true,
    cmd = "Neogit",
    dependencies = {
        "nvim-lua/plenary.nvim",         -- required
        "sindrets/diffview.nvim",        -- optional - Diff integration

        -- Only one of these is needed.
        "ibhagwan/fzf-lua",              -- optional
    },

    config = function()
        require("neogit").setup({
            kind = "floating", -- tab, split
            floating = {
                relative = "editor",
                width = 0.85,
                height = 0.8,
                style = "minimal",
                border = "rounded",
            },
            -- signs = {
            --     -- { CLOSED, OPENED }
            --     section = { "", "" },
            --     item = { "", "" },
            --     hunk = { "", "" },
            -- },
            disable_context_highlighting = true,
            graph_style = "unicode", -- ascii
            integrations = { diffview = true }, -- adds integration with diffview.nvim
        })
    end,
}
