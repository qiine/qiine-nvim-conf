return
{
    "lewis6991/gitsigns.nvim",
    enabled = true,
    event = "UIEnter",

    config = function ()
        require('gitsigns').setup {
            watch_gitdir = { follow_files = true },

            signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
            numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
            linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
            word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
            signs = {
                add          = { text = '│' },  -- │ ┃
                change       = { text = '├' },   --├ ┣
                delete       = { text = '×' },  -- _
                topdelete    = { text = '×' },  -- ‾
                changedelete = { text = '×' },  --◇ *∗¤× ∙               untracked    = { text = '¦' },
                untracked    = { text = '¦' },
            },

            signs_staged_enable = false,
            signs_staged = {
                add          = { text = '┃' },
                change       = { text = '┃' },
                delete       = { text = '┻' },
                topdelete    = { text = '┳' },
                changedelete = { text = '┣' },
                untracked    = { text = '¦' },
            },

            current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
                delay = 1000,
                ignore_whitespace = false,
                virt_text_priority = 100,
                use_focus = true,
            },
            current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
            preview_config  = {
                -- Options passed to nvim_open_win
                style    = 'minimal',
                relative = 'cursor',
                row = 0,
                col = 1
            },
            max_file_length = 40000, -- Disable if file is longer than this (in lines)
        }
    end
}
