return {
    "folke/trouble.nvim",
    enabled = true,
    event = "UIEnter",

    dependencies = { "nvim-tree/nvim-web-devicons" },

    config = function()
        require("trouble").setup({
            warn_no_results = false,
            open_no_results = true,
        })
    end,
}
