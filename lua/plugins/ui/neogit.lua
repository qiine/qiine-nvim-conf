return {
    "TimUntersberger/neogit",
    enabled = false,
    cmd = "Neogit",

    config = function()
        require("neogit").setup({
            kind = "tab", -- opens neogit in a split
            signs = {
                -- { CLOSED, OPENED }
                section = { "", "" },
                item = { "", "" },
                hunk = { "", "" },
            },
            integrations = { diffview = true }, -- adds integration with diffview.nvim
        })
    end,
}
