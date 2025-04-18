return
{
    'numToStr/Comment.nvim',
    enabled = true,

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

