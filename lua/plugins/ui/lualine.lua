
return
{
    'nvim-lualine/lualine.nvim',
    enabled = true,
    event = {"VimEnter", "BufReadPost", "BufNewFile"},
    dependencies = { 'nvim-tree/nvim-web-devicons' },

    config = function()
        vim.opt.cmdheight = 1
        require("lualine").setup({
            options = {
                theme = 'auto',
                icons_enabled = true,
                globalstatus = true,
                component_separators = {left = "", right = ""},
                section_separators = {left = "", right = ""},

                disabled_filetypes = {"Outline"}
            },

            sections =
            {
                lualine_a = {
                    {
                        function ()
                            local m = vim.api.nvim_get_mode().mode
                            return m
                        end,
                        --'mode',
                        map ={  ['n']  = 'NOR',},
                        on_click = function()
                            local m = vim.fn.mode()
                            if m ~= 'n' then vim.api.nvim_input('<ESC>') end
                        end,
                        separator={right=''},
                        right_padding=1,
                    }
                },

                lualine_b =
                {
                    {
                        function() return " 📂" end,
                        on_click=function() vim.cmd("echo '"..vim.fn.getcwd().."'") end,
                        --right_padding=0,
                        padding=0,
                    },

                    {"branch", left_padding = 0, right_padding=0},
                    {--lazgit
                        function() return ' ' end,
                        on_click = function() vim.cmd(":term lazygit") end,
                        padding = 0,
                    },
                },

                lualine_c = {
                    {
                        "diagnostics",
                        sections = { 'error', 'warn', "hint"},
                        always_visible = true,
                        on_click = function() vim.cmd("Trouble diagnostics toggle focus=true filter.buf=0") end,
                        right_padding=0,
                    },
                    {function() return "|" end, padding = 0, color={fg='#a8a7a7'}},
                    {--term
                        function() return '🖳' end, --[]💻
                        on_click = function()
                            vim.cmd('below split')
                            --local cwd = vim.fn.getcwd()
                            --local excwd = vim.fn.expand(cwd)
                            vim.cmd("term")

                            local lines = vim.fn.line('$')
                            local new_height = math.floor(lines / 2)
                            vim.cmd('resize ' .. new_height)
                        end,
                        left_padding = 1,
                        color = { fg = '#0c0c0c'},
                    },
                    { --cmd return
                        function() return '⌨' end, --🖵
                        on_click = function()
                        if vim.bo.filetype == "vim" then
                            vim.api.nvim_input('<esc>:quit<cr>') else vim.api.nvim_input('<esc>q:') end
                        end,
                        padding = 0,
                        color = { fg = '#545454'},
                    },
                },--line c

                lualine_x =
                {
                    {
                        function()
                            local m = vim.fn.mode()
                            if m == "v" or m == "V" then return'<>'
                            else return ""
                            end
                        end,
                        padding=0,
                    },
                    {"selectioncount", left_padding=1, right_padding=0},
                    {'location', padding=0},
                    {
                        function() --line count
                            local lines = vim.api.nvim_buf_line_count(0)
                            return lines..'L'
                        end,
                        padding=1,
                    },
                    {
                        function() --fsize
                            local file_size_bytes = vim.fn.getfsize(vim.fn.expand("%:p"))

                            local function human_readable_size(bytes)
                                local units = { "B", "KB", "MB", "GB", "TB" }
                                local i = 1
                                while bytes >= 1024 and i < #units do
                                    bytes = bytes / 1024
                                    i = i + 1
                                end
                                return string.format("%.1f%s", bytes, units[i])
                            end

                            local file_size_human = human_readable_size(file_size_bytes)
                            return file_size_human
                        end,
                        padding=0,
                    },
                },

                lualine_y = {
                    {--curr buftype
                        function()
                            local buft = vim.bo.buftype
                            if buft == "" then buft = "regular" end
                            return ""..buft--.."|"
                        end,
                        padding=0,
                        separator={left=''},
                    },
                },

                lualine_z =
                {
                    {--Get curr LSP
                        function()
                            local clients = vim.lsp.get_active_clients({ bufnr = 0 })
                            if #clients == 0 then
                                return "ⓘ NoLSP"
                        end
                        local names = {}
                        for _, client in ipairs(clients) do
                            table.insert(names, client.name)
                        end
                            return "{"..table.concat(names, ", ").."}"
                        end,

                        on_click = function()
                            local clients = vim.lsp.get_active_clients({ bufnr = 0 })
                            if #clients == 0 then
                                print("No active LSP clients")
                                return
                            end
                            local client = clients[1] -- Assuming only one client
                            local root_dir = client.config.root_dir
                            print("LSP root dir: " .. root_dir)
                        end,
                        padding = 0,
                        separator={left=''},
                    },--Get curr LSP
                    --{
                    --    'lsp_status',
                    --    icon = '', -- f013
                    --    symbols = {
                    --    -- Standard unicode symbols to cycle through for LSP progress:
                    --    spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
                    --    -- Standard unicode symbol for when LSP is done:
                    --    done = '✓',
                    --    -- Delimiter inserted between LSP names:
                    --    separator = ' ',
                    --    },
                    --    -- List of LSP names to ignore (e.g., `null-ls`):
                    --    ignore_lsp = {},
                    --    separator={left=''},
                    --},
                    {
                        function()
                            local ft = vim.bo.filetype
                            if ft == "" then ft = "nofile" end
                            return " ."..ft
                        end,
                        padding=0,
                    },
                    {"filetype", icon_only = true, padding = 0},
                },
            },

            winbar =
            {
                lualine_a =
                {
                    {
                        function()
                            local dir = vim.fn.fnamemodify(vim.fn.expand('%:h'), ':~:.')
                            return dir.."/"
                        end,
                        icon = '',
                        separator={right=''},
                        bg ="#000000",
                    },
                },

            },


        })--setup
    end,
}



