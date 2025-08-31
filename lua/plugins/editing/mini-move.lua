return
{
    'nvim-mini/mini.move',
    version = false,

    config = function()
        require("mini.move").setup({
            mappings = {
                -- Move visual selection
                left  = '<C-S-Left>',
                right = '<C-S-Right>',
                down  = '<C-S-Down>',
                up    = '<C-S-Up>',

                -- Move current line in Normal mode
                line_left  = '',
                line_right = '',
                line_down  = '',
                line_up    = '',
            },

            options = {
                -- Auto reindent during move
                reindent_linewise = true,
            },
        })
    end
}
