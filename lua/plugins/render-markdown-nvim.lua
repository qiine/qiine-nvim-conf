return
{
    'MeanderingProgrammer/render-markdown.nvim',
    enabled = true,
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons

    config = function()
        require('render-markdown').setup({
            --preset = "obsidian",
            file_types = {"markdown"},

            render_modes = { "i", 'n', 'v', 'c', 't' },
            win_options = {
                concealcursor = {
                    --default = vim.o.concealcursor,
                    rendered = "nvic"
                }
            },

            heading = {
                --icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
                icons = { '|', '•|>', '•|-', '•|_', '•|.', '•|..' },
                width = "block"
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
                right_pad = 1,
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
                },
            },
            code = {
                width = "block"
            }
        })
    end
}
