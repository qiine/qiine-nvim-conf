return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    enabled = true,

    config = function()
        require("trouble").setup({
            warn_no_results = false, 
            open_no_results = true, 
        })
    end,
}
