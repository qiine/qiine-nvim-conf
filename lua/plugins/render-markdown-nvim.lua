return
{
    'MeanderingProgrammer/render-markdown.nvim',
    enabled = true,
    event = "BufEnter",

    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'nvim-tree/nvim-web-devicons'
        -- if you prefer nvim-web-devicons
    },

    config = function()
        require('render-markdown').setup({

            file_types = {"markdown", "org", "norg", "codecompanion", "quarto", "rmd"},

            sign = {
                -- Turn on / off sign rendering.
                enabled = false,
            },

            --render_modes = { "i", 'n', 'v', "V", "\22", 'c', 't' },
            render_modes = true,
            win_options = {
                concealcursor = {
                    --default = vim.o.concealcursor,
                    --rendered = "nvic"
                }
            },
            anti_conceal = {
                -- This enables hiding any added text on the line the cursor is on.
                enabled = false,
                -- Modes to disable anti conceal feature.
                disabled_modes = false,
                -- Which elements to always show, ignoring anti conceal behavior. Values can either be
                -- booleans to fix the behavior or string lists representing modes where anti conceal
                -- behavior will be ignored. Valid values are:
                --   head_icon, head_background, head_border, code_language, code_background, code_border,
                --   dash, bullet, check_icon, check_scope, quote, table_border, callout, link, sign
                ignore = {
                    code_background = true,
                    sign = true,
                },
            },

            heading = {
                --icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
                icons = { '|', '|## ', '|### ', '|#### ', '|##### ', '|###### ' }, --|#|
                sign = false,
                width = "block",
                right_pad = 5,
            },
            bullet = {
                --icons = { '●', '○', '◆', '◇' },
                icons = { '•', '-', '•', '-' },
            },
            indent = {
                enabled = true,
                render_modes = false,
                per_level = 2,
                skip_level = 1,
                skip_heading = false,
                icon = '▎',
                highlight = 'RenderMarkdownIndent',
            },
            checkbox = {
                enabled = true,
                render_modes = false,
                bullet = true,
                right_pad = 0,
                position = "inline",

                unchecked = {
                    icon = '󰄱 ',
                    highlight = 'RenderMarkdownUnchecked',
                    scope_highlight = nil,
                },
                checked = {
                    icon = '󰱒 ',
                    highlight = 'RenderMarkdownChecked',
                    scope_highlight = nil,
                },
                custom = {
                    todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
                    checked_v = { raw = '[v]', rendered = '󰱒 ', highlight = 'RenderMarkdownCheckedV', scope_highlight = nil },
                },
            },
            quote = {
                --highlight = {
                --    'RenderMarkdownQuote1',
                --    'RenderMarkdownQuote2',
                --    'RenderMarkdownQuote3',
                --    'RenderMarkdownQuote4',
                --    'RenderMarkdownQuote5',
                --    'RenderMarkdownQuote6',
                --},
            },
            code = {
                sign = false,
                width = "block", -- full
                min_width = 80,  -- used when width is 'block'.
                left_pad = 2,
                right_pad = 2,
                border = 'thin',  -- none hide thin thick
            },
            pipe_table = {
                -- Pre configured settings largely for setting table border easier.
                -- | heavy  | use thicker border characters     |
                -- | double | use double line border characters |
                -- | round  | use round border corners          |
                -- | none   | does nothing                      |
                preset = 'round',
                -- Determines how the table as a whole is rendered.
                -- | none   | disables all rendering                                                  |
                -- | normal | applies the 'cell' style rendering to each row of the table             |
                -- | full   | normal + a top & bottom line that fill out the table when lengths match |
                style = 'normal',
                -- Determines how individual cells of a table are rendered.
                -- | overlay | writes completely over the table, removing conceal behavior and highlights |
                -- | raw     | replaces only the '|' characters in each row, leaving the cells unmodified |
                 --| padded  | raw + cells are padded to maximum visual width for each column             |
                -- | trimmed | padded except empty space is subtracted from visual width calculation      |
                cell = 'padded',
                padding = 0,
                border_virtual = true,
            }
        })
    end
}
