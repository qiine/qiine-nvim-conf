return
{
    "luukvbaal/statuscol.nvim",
    enabled = true,
    desc = "customize gutter line",

    config = function()
        local builtin = require('statuscol.builtin')
        require("statuscol").setup({
                ft_ignore = nil,       -- Lua table with 'filetype' values for which 'statuscolumn' will be unset
                bt_ignore = {"help"},       -- Lua table with 'buftype' values for which 'statuscolumn' will be unset
                segments =
                {
                    {
                        text = { "%s" }, -- Signs (git, diagnostics)
                        click = "v:lua.ScSa",
                        --sign = { name = { "Diagnostic" }, maxwidth = 1, auto = false },
                        --click = "v:lua.ScSa"
                    },
                    {
                        text = { builtin.lnumfunc, ' '}, --line numbers
                        condition = { true, builtin.not_empty },
                        click = 'v:lua.ScLa',
                    },
                    {
                        text = { builtin.foldfunc },
                        click = 'v:lua.ScFa',
                    },
                    --{
                    --    sign = { name = { ".*" }, maxwidth = 1, colwidth = 1, auto = false },
                    --    click = "v:lua.ScSa"
                    --},
                },
        })
    end,
}
        --
        --       , click = "v:lua.ScSa" },
        --{ sign = { name = { ".*" }, maxwidth = 1, colwidth = 1, auto = true }, click = "v:lua.ScSa" }, } })]]
        --



