return
{
    'romgrk/barbar.nvim',
    enabled = true,
    --version = '^1.0.0',
    dependencies =
    {
        --'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
        'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },

    config = function()
        require'bufferline'.setup {
            clickable = true,
            animation = false,
            no_name_title = "New tab",

            --Sets padding width with which to surround each tab
            maximum_padding = 1, minimum_padding = 0,

            -- Sets buffer name length.
            maximum_length = 15, minimum_length = 7,

            --offset tabs when opening sidebar
            sidebar_filetypes = {
                 ['neo-tree'] = {event = 'BufWinLeave', text = 'File Explorer', align = 'left'},
            },

            icons =
            {
                -- Use a preconfigured buffer appearance
                --preset = 'default',

                -- Other options for icons can be configured as needed
                buffer_number = false,

                filetype = {
                    -- Use `nvim-web-devicons` colors if set to true
                    enabled = true,
                    custom_colors = false,
                },
                button = '', --close button
                modified = {button = '🖬'}, --🖬💾
                pinned = {button = '', filenamefalse= true},

                separator = {left = '▎', right = '▕'}, --│ |
                separator_at_end = false, --Add additional separator at the end of the buffer list
                icon_separator_inactive = '',

                -- Configure icons based on buffer visibility
                --alternate = {filetype = {enabled = false}},
                --inactive = {button = '×'},
                visible = {modified = {buffer_number = false}},
            }
        }

    end,
}


