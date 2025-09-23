return
{
    "kylechui/nvim-surround",
    enabled = true,
    -- version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",

    config = function()
        require("nvim-surround").setup({
            keymaps = {
                insert = nil, --"<C-g>s",
                insert_line = nil, --"<C-g>S",
                normal = "ys",
                normal_cur  = "yss",
                normal_line = "yS",
                normal_cur_line = "ySS",
                visual = "S",
                visual_line = "gS",
                delete = "ds",
                change = "cs",
                change_line = "cS",
            },
        })
    end
}
