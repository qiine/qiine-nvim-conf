return
{
    "alex-popov-tech/store.nvim",
    enbaled = false,
    --event = "UIEnter",

    dependencies = {
        --"OXY2DEV/markview.nvim", -- optional, for pretty readme preview / help window
    },

    cmd = "Store",
    condif = function ()
        require("store").setup( {
            --width = 0.97,
            --height = 0.97,
            proportions = {
                    list = 0.3,     -- 30% for repository list
                    preview = 0.70,  -- 70% for preview pane
                },
        })
    end
}
