return
{
    "eero-lehtinen/oklch-color-picker.nvim",
    version = "*",
    --cond = function()
    --    return vim.fn.getenv("COLORTERM") == "truecolor" 
    --end,
    enabled = false,

    config = function() 
        local okcolpick = require("oklch-color-picker")
        okcolpick.setup({
           
        })
        
        vim.keymap.set("n", 'cw',  
            function ()
                okcolpick.pick_under_cursor({ fallback_open = {} })
            end,
        {noremap=true})
    end
}
--#9e9067
--#000
--#5c816f4f
