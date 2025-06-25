return
{
    "OXY2DEV/markview.nvim",
    enabled = false,
    lazy = false,
    dependencies = { },

    config = function()
        local presets = require("markview.presets");

        require('markview').setup({
            render_modes = { 'n', 'c', 't' },
            markdown = {
                headings = presets.headings.slanted
            }
        })
    end

}
