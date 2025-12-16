return
{
    "stevearc/aerial.nvim",
    enabled = true,

    dependencies = {
        "nvim-tree/nvim-web-devicons"
    },

    opts = {
        -- This can be a filetype map (see :help aerial-filetype-map)
        backends = {
            ['_']  = {"lsp", "treesitter"}, -- "man"
            markdown = {"markdown", "treesitter"}, -- asciidoc
        },

        layout = {
            -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
            -- min_width and max_width can be a list of mixed types.
            -- max_width = {40, 0.22}, -- means "the lesser of 40 columns or 20% of total"
            max_width = 0.33,
            width     = nil,
            min_width = 20,

            default_direction = "prefer_right",

            --   edge   - open aerial at the far right/left of the editor
            --   window - open aerial to the right/left of the current window
            placement = "window",

            -- When the symbols change, resize the aerial window (within min/max constraints) to fit
            resize_to_content = false,

            -- Preserve window size equality with (:help CTRL-W_=)
            preserve_equality = false,

            -- key-value pairs of window-local options for aerial window (e.g. winhl)
            win_opts = {
                signcolumn    = "no",
                foldenable    = false,
                foldcolumn    = "0",
                number        = false,
                wrap          = false,
                spell         = false,
                -- conceallevel  = 3,
                -- concealcursor = "nvic",
                -- cursorcolumn  = false,
            },
        },

        -- This can be a filetype map (see :help aerial-filetype-map)
        -- To see all available values, see :help SymbolKind
        filter_kind = {
            -- "Array",
            "Boolean",
            -- "Class",
            "Constant",
            -- "Constructor",
            "Enum",
            -- "EnumMember",
            -- "Field",
            -- "Event",
            -- "File",
            "Function",
            -- "Interface",
            -- "Key",
            "Method",
            -- "Module",
            -- "Namespace",
            -- "Null",
            "Number",
            -- "Object",
            -- "Operator",
            -- "Package",
            -- "Property",
            "String",
            -- "Struct",
            -- "TypeParameter",
            "Variable",
        },

        -- Jump to symbol in source window when the cursor moves
        autojump = false,

        -- Automatically open aerial when entering supported buffers.
        -- This can be a function (see :help aerial-open-automatic)
        -- open_automatic = false,
        open_automatic = function(bufnr)
            -- return vim.bo.filetype == "markdown"
        end,

        close_automatic_events = {"switch_buffer", "unsupported" },

        on_attach = function(bufnr)
            -- require("aerial").tree_close_all() -- auto close folds
        end,

        show_guides = true,
        guides = {
            -- child sibling below it
            mid_item = "├─",
            -- child is the last in the list
            last_item = "└─",
            -- nested child guides to the right
            nested_top = "│ ",
            -- Raw indentation
            whitespace = "",
        },

        ignore = {
            -- Ignore unlisted buffers. See :help buflisted
            unlisted_buffers = true,

            -- Ignore diff windows (setting to false will allow aerial in diff windows)
            diff_windows = false,

            -- List of filetypes to ignore.
            filetypes = {},

            -- Ignored buftypes:
            -- false or nil - No buftypes are ignored.
            -- "special"    - All buffers other than normal, help and man page buffers are ignored.
            -- table        - A list of buftypes to ignore. See :help buftype for the
            --                possible values.
            -- function     - A function that returns true if the buffer should be
            --                ignored or false if it should not be ignored.
            --                Takes two arguments, `bufnr` and `buftype`.
            buftypes = "special",

            -- Ignored wintypes:
            -- false or nil - No wintypes are ignored.
            -- "special"    - All windows other than normal windows are ignored.
            -- table        - A list of wintypes to ignore. See :help win_gettype() for the
            --                possible values.
            -- function     - A function that returns true if the window should be
            --                ignored or false if it should not be ignored.
            --                Takes two arguments, `winid` and `wintype`.
            wintypes = "special",
        },

        -- Keymaps in aerial window. Can be any value that `vim.keymap.set` accepts OR a table of keymap
        -- options with a `callback` (e.g. { callback = function() ... end, desc = "", nowait = true })
        -- Additionally, if it is a string that matches "actions.<name>",
        -- it will use the mapping at require("aerial.actions").<name>
        -- Set to `false` to remove a keymap
        keymaps = {
            ["<CR>"] = "actions.select",
            ["<C-CR>"] = "actions.jump",
            ["<2-LeftMouse>"] = "actions.jump",
            ["<C-PageUp>"] = "actions.prev",
            ["<C-PageDown>"] = "actions.next",
            -- ["[["] = "actions.prev_up",
            -- ["]]"] = "actions.next_up",

            -- ["<C-Tab>"] = { mode = {"i","n","v"},
            --     desc = "next buf",
            --     callback = function()
            --         vim.cmd("bnext")
            --         -- vim.cmd("bp")
            --     end
            -- },

            ["q"] = "actions.close",

            -- tree items
            ["l"] = "actions.tree_open",
            ["zo"] = "actions.tree_open",
            ["L"] = "actions.tree_open_recursive",
            ["zO"] = "actions.tree_open_recursive",
            ["h"] = "actions.tree_close",
            ["zc"] = "actions.tree_close",
            ["H"] = "actions.tree_close_recursive",
            ["zC"] = "actions.tree_close_recursive",
            ["za"] = "actions.tree_toggle",
            ["O"] = "actions.tree_toggle_recursive",
            ["<M-z>"] = "actions.tree_toggle_recursive",

            -- folds
            ["zr"] = "actions.tree_increase_fold_level",
            ["zR"] = "actions.tree_open_all",
            ["zm"] = "actions.tree_decrease_fold_level",
            ["zM"] = "actions.tree_close_all",
            ["zx"] = "actions.tree_sync_folds",
            ["zX"] = "actions.tree_sync_folds",
        },

        vim.api.nvim_create_autocmd('FileType', {
            group = 'UserAutoCmds',
            pattern = 'aerial',
            callback = function()
                -- vim.cmd("norm! ggH") -- auto fold

                -- winfixbuf

                --- rename symbol
                vim.keymap.set("n", "r", function()
                    require("aerial").select()
                    vim.lsp.buf.rename()
                end, { buffer = true })
            end,
        })
    },

}

