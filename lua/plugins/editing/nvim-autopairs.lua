return
{
    'windwp/nvim-autopairs',
    enabled = true,

    event = "InsertEnter",
    config = function()
        require("nvim-autopairs").setup({
            enable_afterquote = true,
            map_cr = false,
            map_bs = true,
        })
    end,

}
