return
{
    "lukas-reineke/indent-blankline.nvim",
    enabled = true,

    config = function()
        require("ibl").setup({
            scope = {
                enabled = true,
                --show_start = true,
                --show_end = true,
                --injected_languages = true,
                show_exact_scope = false,
            },
            indent = {
               char = "▏", --"▏"  "│" `▕`   dotted:"┊"
            },
            exclude = {
                filetypes = {
                    "log", "txt", "md",
                    "dashboard", "alpha",
                    "help",
                },
                buftypes = { "terminal", "nofile" }
            },
        })--setup

        local hooks = require "ibl.hooks"
        hooks.register(
            hooks.type.WHITESPACE,
            hooks.builtin.hide_first_space_indent_level
        )

    end--config
}

