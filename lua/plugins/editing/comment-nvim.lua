return
{
    'numToStr/Comment.nvim',
    enabled = true,
    desc ="allow comment padding control, doesn't comment blank",

    config = function()
        require('Comment').setup({
            padding = false,
            mappings = { basic = true, extra = false },
            ignore = '^$',
            -- extra = {
            --     above = ' ',
            --     below = ' ',
            --     eol = ' ',
            -- },

        })
    end,

}

