return
{
    "folke/zen-mode.nvim",

    opts = {
        window = {
            --width = .87, -- width will be 85% of the editor width
            --height = function()
            --    return vim.api.nvim_win_get_height(0) - 1
            --end,
            options = {
                signcolumn = "no", -- disable signcolumn
                number = false,    -- disable number column
                -- relativenumber = false, -- disable relative numbers
                -- cursorline  = false,     -- disable cursorline
                -- cursorcolumn = false,   -- disable cursor column
                foldcolumn = "0", -- disable fold column
                -- list = false,  -- disable whitespace characters
            },
        },
        plugins = {
            -- disable some global vim options (vim.o...)
            -- comment the lines to not apply the options
            options = {
                enabled = true,
                ruler   = false, -- disables the ruler text in the cmd line area
                showcmd = false, -- disables the command in the last line of the screen
                -- you may turn on/off statusline in zen mode by setting 'laststatus'
                -- statusline will be shown only if 'laststatus' == 3
                laststatus = 0, -- turn off the statusline in zen mode
            },
            gitsigns = { enabled = false }, -- disables git signs
            -- this will change the font size on wezterm when in zen mode
            -- See alse also the Plugins/Wezterm section in this projects README
            wezterm = {
                enabled = true,
                -- can be either an absolute font size or the number of incremental steps
                font = "+7", -- (10% increase per step)
            },
        },
        -- callback where you can add custom code when the Zen window opens
        on_open = function(win)
            vim.o.winbar = ""
        end,
        -- callback where you can add custom code when the Zen window closes
        on_close = function()
        end,
    }
}
