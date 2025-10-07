return
{
    "nvim-neo-tree/neo-tree.nvim",
    --branch = "v3.x",
    enabled = true,
    event = "UIEnter",

    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
    },

    config = function()
        require("neo-tree").setup({
            source_selector = {
                winbar = false,
                show_scrolled_off_parent_node = true,
                padding = { left = 0, right = 0 },
                sources = {
                    { source = 'filesystem', display_name = '  Files' }, --      
                    { source = 'buffers', display_name = '  Buffers' }, --      
                    { source = 'git_status', display_name = ' 󰊢 Git' }, -- 󰊢      
                    { source = 'document_symbols', display_name = 'Outliner' }, -- 󰊢      
                },
            },
            sources = { "filesystem", "buffers", "git_status", "document_symbols" },

            default_component_configs = {
                container = {
                    enable_character_fade = false,
                    width = "100%",
                    right_padding = 0,
                },
                indent = {
                    indent_size = 2,
                    padding = 0,
                    with_markers = true,
                    indent_marker = "┃", --│
                    last_indent_marker = "┗", --└
                    highlight = "NeoTreeIndentMarker",

                    -- expander config, needed for nesting files
                    with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
                    expander_collapsed = "",
                    expander_expanded = "",
                    expander_highlight = "NeoTreeExpander",
                },
            },

            window = {
                position = "left", --left, right, top, bottom, float, current
                width = 26, -- applies to left and right positions
                height = 15, -- applies to top and bottom positions
                auto_expand_width = false, -- expand the window when file exceeds the window width. does not work with position = "float"
            },

            filesystem = {
                use_libuv_file_watcher = true, -- Auto-refresh
                bind_to_cwd = true,  -- Enable 2-way binding between Neovim's cwd and Neo-tree's root
                cwd_target = {
                    sidebar = "global",   --"global", "tab"
                    current = "global"
                },
                hijack_netrw = false,

                filtered_items = {
                    visible           = true, -- when true, they will just be displayed differently than normal items
                    show_hidden_count = true, --show number of hidden items in each folder as the last entry
                    hide_dotfiles     = true,
                    hide_gitignored   = true,
                    hide_hidden       = false, --only works on Windows for hidden files/directories
                    hide_by_name = {
                        ".DS_Store",
                        --"node_modules",
                    },
                },

                window = {
                    --Detect project root using LSP or common markers (.git)
                    --follow_current_file = true, --Auto-open curr file's dir
                    --use_libuv_file_watcher = true, --os Auto-refresh on files change
                    mappings = {
                        ["<Mouse-Left>"] = "open",
                        ["H"] = "toggle_hidden",
                        ["P"] = {
                            "toggle_preview",
                            config = {
                                use_float = false,
                                use_image_nvim = true,
                                -- title = 'Neo-tree Preview',
                            },
                        },
                        ["<Del>"] = {"delete", config = {confirm = false}},
                        ["<F2>"] = "rename",
                        ["N"] = "add_directory",
                        ["n"] = {
                            "add",
                            -- some commands may take optional config options, see `:h neo-tree-mappings` for details
                            config = {
                            show_path = "none", --"none", "relative", "absolute"
                            }
                        },
                        ["<C-b>"] = "close_window",
                    },
                },
            },--filesytem

            document_symbols = {
                follow_cursor = false,
                window = {
                    mappings = {
                        ['/'] = 'noop',
                        ['F'] = 'filter',
                    },
                },
            },

            event_handlers = {
                {
                    event = 'neo_tree_window_after_open',
                    handler = function(args)
                        --needed because they waste column space
                        --vim.wo[args.winid].statuscolumn = ""
                        --vim.wo[args.winid].signcolumn   = "no"
                        --vim.wo[args.winid].number       = false
                        --vim.wo[args.winid].foldcolumn   = "0"
                        vim.opt_local.statuscolumn = ""
                        vim.opt_local.signcolumn   = "no"
                        vim.opt_local.number       = false
                        vim.opt_local.foldcolumn   = "0"
                    end
                },
            },
        })--setup

        vim.keymap.set({"i","n","v","t"}, "<C-b>",
            "<cmd>Neotre toggle<cr>",
        {noremap=true})
    end,
}
