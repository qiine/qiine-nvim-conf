return
{
    "catppuccin/nvim",
    priority = 1000,
    
    config = function()
        require("catppuccin").setup({
            color_overrides = {
                all = {
                --text = "#ffffff",
                },
                latte = {
                base = "#FBF1C7",
                mantle = "#F9EBAF",
                --crust = "#474747",
                },
            }
        })
    end,
}
