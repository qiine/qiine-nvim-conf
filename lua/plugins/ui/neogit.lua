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
            disable_signs = false,
            disable_context_highlighting = true,
            disable_hint = true,

            status = {
                recent_commit_count = 50,
                mode_text = {
                    M = "M",
                    N = "N",
                    A = "A",
                    D = "D",
                    C = "C",
                    U = "U",
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
            signs = {
                --     { CLOSED, OPENED }
                hunk    = { " >", " ⌄" },
                item    = { ">", "⌄" },
                section = { ">", "⌄" },
            },

            sections = {
                recent = {
                    folded = false,
                    hidden = false,
                },
            },

            graph_style = "unicode", -- ascii

            integrations = { diffview = true }, -- adds integration with diffview.nvim

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
