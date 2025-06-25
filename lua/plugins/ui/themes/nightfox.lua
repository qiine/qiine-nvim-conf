return
{
    "EdenEast/nightfox.nvim",
    enabled = true,
    dependencies = {},

    config = function()

        local guttercol = "#e8e8e8"

        require('nightfox').setup({
            options =
            {
                transparent = false,     -- Disable setting background
                terminal_colors = true,  -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
                dim_inactive = false,    -- Non focused panes set to alternative background
                module_default = true,   -- Default enable value for modules

                styles = {   --Style to be applied to different syntax groups
                     -- Value is any valid attr-list value `:help attr-list`
                    comments = "italic",
                    conditionals = "NONE",
                    constants = "NONE",
                    functions = "bold",
                    keywords = "NONE",
                    numbers = "NONE",
  operators = "NONE",
                    strings = "NONE",
                    types = "NONE",
                    variables = "NONE",
                },

                inverse = {             -- Inverse highlight for different types
                    match_paren = false,
                    visual = false,
                    search = false,
                },
                modules =
                {             -- List of various plugins and additional options
                },
            },--options

            palettes = {
                all =
                {
                    bg1 = "#fafafa", --editor background
                },
            },

            specs = {},

            groups = {
                 all =
                {
                    Normal = {fg = "#1f1f1f"},
                    Comment = {fg = "#787878"},
                    Boolean = {fg = "#0d0d0d", style = "bold"},
                    MatchParen = {bg = "#d9d9d9", style = "bold"},

                    --Cursor = { bg = "#0d0d0d" },
                    CursorLine = { bg = "#f0f0f0" },

                    SignColumn = { bg = guttercol },
                    LineNr = { bg = guttercol },
                    --CursorLineNr = { bg = guttercol },

                    --Folded = { fg = "#dfdfdf", bg = "#dfdfdf" },
                    FoldColumn = { bg = guttercol },

                   --WinBar = {fg = "#dfdfdf", bg = trans and "NONE" or spec.bg1, style = "NONE" }, -- Window bar of current window.
                    --DropBarText = { bg = "#ffffff", fg = "#dddddd" },

                    --tabs
                    BufferTabpageFill = { bg = "#f0f0f0" },

                    BufferCurrent = {bg = "#f0f0f0", fg = "NONE"},
                    BufferCurrentIndex = {bg = "#f0f0f0"},
                    BufferCurrentMod = {bg = "#f0f0f0", style = "bold"},
                    BufferCurrentSign = {bg = "#f0f0f0"},
                    --BufferCurrentTarget = {bg = "NONE"},
                    --BufferTabpages = {bg = "NONE"},

                    --Adjust inactive tab color
                    BufferInactive = { bg = "#d9d9d9", fg = "#888888" },
                    BufferInactiveMod = { bg = "#d9d9d9", fg = "#ffaa00" },
                    BufferInactiveSign = { bg = "#d9d9d9", fg = "#ffaa00" },

                },
            },

            custom_highlights = {
                SignColumn = { bg = "#b2b2b2" },  --Background color for the sign column
            },

        })--setup
    end,--config
}




