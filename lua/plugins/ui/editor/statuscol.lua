return
{
    "luukvbaal/statuscol.nvim",
    enabled = true,
    desc = "customize gutter line",

    config = function()
        local builtin = require('statuscol.builtin')
        require("statuscol").setup({
            ft_ignore = { "nofile", "favorizer" },
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
                    text = {builtin.lnumfunc},    --line numbers
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
