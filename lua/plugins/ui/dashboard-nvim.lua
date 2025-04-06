return
{
    'nvimdev/dashboard-nvim',
    enabled = true,
    dependencies =
    {
        {'nvim-tree/nvim-web-devicons'},
    },
    event = 'VimEnter',

    config = function()
        require('dashboard').setup({
            theme = 'hyper',
            config =
            {
                week_header = {
                    enable = false,
                },
                shortcut = {


                },
            },
            hide = {
                statusline,       -- hide statusline default is true
                winbar           -- hide winbar
            },


        })--setup
    end,
}
