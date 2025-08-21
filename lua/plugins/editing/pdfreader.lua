return
{
    "r-pletnev/pdfreader.nvim",
    enabled = false,
    lazy   = false,
    dependencies = {
        "folke/snacks.nvim", -- image rendering
        --"nvim-telescope/telescope.nvim", -- pickers
    },

    config = function()
        require("pdfreader").setup()
    end,
}
