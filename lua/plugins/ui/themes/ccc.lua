    return
{
    "uga-rosa/ccc.nvim",
    --cond = function()
    --    return vim.fn.getenv("COLORTERM") == "truecolor" 
    --end,
    enabled = false,

    config = function()
        local ccc = require("ccc")
        local mapping = ccc.mapping
        ccc.setup({
            pickers = { disable = {} },
            highlighter = {
                auto_enable = true,
                highlight_mode = "bg",
                picker = true,
                update_insert = true,
                lsp = true,
                filetypes = {},
                excludes = {},
            },
            --recognize = {
            --    input = true,
            --    output = true,
            --},
        })
    end
}
--#450000
--#705300ff
 --#0000 
--#260000
