return
{
    "luukvbaal/statuscol.nvim",
    enabled = true,
    desc = "Customize gutter line",

    config = function()
        local builtin = require('statuscol.builtin')
        require("statuscol").setup({
            ft_ignore = { "favorizer", "aerial", "codecompanion", "OverseerOutput" },
            bt_ignore = { "help" },

            relculright = true,

            segments = {
                {
                    sign = {
                        namespace = {"gitsigns"},
                        maxwidth = 1, colwidth = 1,
                    },
                    click = "v:lua.ScSa",
                },
                {
                    sign = {
                        namespace = {"diagnostic"},
                        maxwidth = 1, colwidth = 1,
                        wrap = false,
                        auto = false,
                    },
                    click = "v:lua.ScSa"
                },
                {
                    -- line numbers
                    text = {builtin.lnumfunc},
                    click = 'v:lua.ScLa',
                },
                {
                    text = {builtin.foldfunc},
                    click = 'v:lua.ScFa',
                },
            },
        })
    end
}
