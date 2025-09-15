return
{
    "hat0uma/csvview.nvim",
    event = "BufEnter",
    -- cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },

    config = function ()
        require("csvview").setup({
            parser = {
                delimiter = {
                    ft = {
                        csv = "|",
                        tsv = "\t",
                    },
                comments = { "#", "//" } },
            },

            view = {
                spacing = 0,
                display_mode = "border",
                header_lnum = 1, -- true
                sticky_header = {
                    enabled   = true,
                    separator = "─",
                },
            },

            keymaps = {
                -- Text objects for selecting fields
                textobject_field_inner = { "if", mode = { "o", "x" } },
                textobject_field_outer = { "af", mode = { "o", "x" } },

                -- Excel-like navigation:
                jump_next_field_end = { "<Tab>", mode = { "i", "n", "v" } },
                jump_prev_field_end = { "<S-Tab>", mode = { "i", "n", "v" } },
                jump_next_row = { "<Enter>", mode = { "i", "n", "v" } },
                jump_prev_row = { "<S-Enter>", mode = { "i", "n", "v" } },
            },
        })

        -- highlight header row
        vim.api.nvim_set_hl(0, "CsvViewHeaderLine", { fg = "#595959", bg = "#D1D1D1", bold = false })

        vim.api.nvim_create_autocmd("BufEnter", {
            group = "UserAutoCmds",
            pattern = { "*.csv", "*.tsv" },
            callback = function()
                vim.cmd("CsvViewEnable")
            end,
        })
    end
}
