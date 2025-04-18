return
{
    "L3MON4D3/LuaSnip",
    lazy = true,

    dependencies = { "rafamadriz/friendly-snippets", lazy = true },

    config = function()
        require("luasnip").setup()

    end
}


