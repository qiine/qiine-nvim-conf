return
{
    'windwp/nvim-autopairs',

    event = "InsertEnter",
    config = function()
        require("nvim-autopairs").setup({
            enable_afterquote = false,
            map_cr = false,
            map_bs = false,
        })
    end,

}
