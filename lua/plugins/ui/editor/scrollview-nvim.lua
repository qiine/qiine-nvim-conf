return
{
    'dstein64/nvim-scrollview',
    desc="make scrolling smoother",

    config = function()
        require("scrollview").setup({
             diagnostics_severities = {}
        })

    end,

}
