return
{
    "alex-popov-tech/store.nvim",
        dependencies = {
            --"OXY2DEV/markview.nvim", -- optional, for pretty readme preview / help window
        },
        cmd = "Store",
        keys = {
            --{ "<leader>s", "<cmd>Store<cr>", desc = "Open Plugin Store" },
        },
        opts = {
            width = 0.97,
            height = 0.97,
            proportions = {
                list = 0.4,     -- 30% for repository list
                preview = 0.60,  -- 70% for preview pane
            },
        },
}
