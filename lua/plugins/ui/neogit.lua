return
{
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
            disable_signs = true,
            disable_context_highlighting = true,
            graph_style = "unicode", -- ascii
            integrations = { diffview = true }, -- adds integration with diffview.nvim
            disable_hint = true,

            status = {
                recent_commit_count = 50,
                mode_text = {
                    M = "M",
                    N = "new file",
                    A = "A",
                    D = "D",
                    C = "copied",
                    U = "updated",
                    R = "R",
                    DD = "unmerged",
                    AU = "unmerged",
                    UD = "unmerged",
                    UA = "unmerged",
                    DU = "unmerged",
                    AA = "unmerged",
                    UU = "unmerged",
                },
                mode_padding = 1,
            },

            -- Automatically show console if a command takes more than console_timeout milliseconds
            auto_show_console = false,

            mappings = {
                commit_editor = {
                    ["<C-S-CR>"] = "Submit",
                    ["<C-w>"] = "Abort",
                    ["<C-p>"] = "PrevMessage",
                    ["<C-n>"] = "NextMessage",
                },
                commit_editor_I = {
                    ["<C-S-CR>"] = "Submit",
                },
            },
        })
    end,

    -- require("neogit").action("commit", "commit", { "--verbose", "--all" })()

}
