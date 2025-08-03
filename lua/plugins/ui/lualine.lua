return
{
    'nvim-lualine/lualine.nvim',
    enabled = true,
    event = {"VimEnter", "BufReadPost", "BufNewFile"},
    dependencies = { 'nvim-tree/nvim-web-devicons' },

    config = function()
        --local utils = require("utils.utils")
        require("lualine").setup({
            options = {
                theme = 'auto',
                icons_enabled = true,
                globalstatus = true,
                component_separators = {left = "", right = ""},
                section_separators = {left = "", right = ""},

                disabled_filetypes = {
                    statusline = {},
                    winbar = {},
                },
                disabled_buftypes = {
                    winbar = {"terminal", "neo-tree", "fzf-lua"},
                },
                ignore_focus = {"help", "nofile", "", "neo-tree", "trouble", "fzf-lua"},
            },

            sections =
            {
                lualine_a = {
                    {
                        function () --mode
                            local m = vim.api.nvim_get_mode().mode
                            local mode_alias={
                                ['no']='O',['nov']='O-v',['noV']='O-Line',['no\22']='O-Block',
                                ['n']='N',['niI']='Ni',['niR']='N',['niV']='N',['nt']='N',['ntT']='N',
                                ['v']='V',['vs']='Vs',['V']='V-LINE',['Vs']='V-LINE',['\22']='V-BLOCK',['\22s']='V-BLOCK',
                                ['s']='S',['S']='S-LINE',['\19']='S-BLOCK',
                                ['i']='I',['ic']='Ic',['ix']='Ix',
                                ['r']='r',['R']='R',['Rc']='Rc',['Rx']='Rx',['Rv']='V-R',['Rvc']='V-R',['Rvx']='V-R',
                                ['c']='CMD',['cv']='EX',['ce']='EX',
                                ['rm']='MORE',['r?']='CONFIRM',
                                ['!']='SHELL',['t']='TERMINAL'
                            }
                            local ma = mode_alias[m]
                            if ma then m=ma end
                            return ""..m.."" --▕ |｜ ⊣⊢ ⋅ ⦁ ⫞⊦
                        end,
                        on_click = function()
                            local m = vim.fn.mode()
                            if m ~= 'n' then vim.api.nvim_input('<ESC>') end
                        end,
                        separator={right=''},   --
                        padding={left=1, right=1},
                    }
                },

                lualine_b =
                {
                    {
                        function() return " 📂" end,
                        on_click=function() vim.cmd("echo '"..vim.fn.getcwd().."'") end,
                        padding=0,
                        color = { bg = 'NONE'},
                    },

                    {
                        "branch", -- git ""
                        on_click = function() vim.cmd(":term lazygit") end,
                        padding={left=1, right=1},
                        color = { bg = 'NONE'},
                    },
                    {function() return "|" end, padding=0, color={fg='#a8a7a7', bg="NONE"}},
                },

                lualine_c = {
                    {
                        "diagnostics",
                        sections = { 'error', 'warn', "hint"},
                        always_visible = true,
                        on_click = function() vim.cmd("Trouble diagnostics toggle focus=true filter.buf=0") end,
                        padding=1,
                    },
                    {function() return "|" end, padding = 0, color={fg='#a8a7a7'}},
                    {--term
                        function() return ' ' end, --[] 💻   🖳
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
                        --color = { fg = '#0c0c0c'},
                    },
                    { --cmdwin
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
                    {--select count
                        function()
                            local m = vim.fn.mode()
                            local icon = ""
                            local function selectioncount()
                                local mode = vim.fn.mode()
                                local pos1 = vim.fn.getpos("v")
                                local pos2 = vim.fn.getpos(".")

                                local l1, c1 = pos1[2], pos1[3]
                                local l2, c2 = pos2[2], pos2[3]

                                -- Normalize positions
                                if l2 < l1 or (l1 == l2 and c2 < c1) then
                                    l1, l2 = l2, l1
                                    c1, c2 = c2, c1
                                end

                                if mode == "v" then
                                    if l1 == l2 then
                                        return c2 - c1 + 1
                                    else
                                        local lines = vim.api.nvim_buf_get_lines(0, l1 - 1, l2, false)
                                        local count = #lines[1] - c1 + 1
                                        for i = 2, #lines - 1 do
                                            count = count + #lines[i]
                                        end
                                        count = count + c2
                                        return count
                                    end
                                elseif mode == "V" then
                                    return math.abs(l2 - l1) + 1
                                elseif mode == "" then -- blockwise visual
                                    return string.format('%dx%d', math.abs(l2 - l1) + 1, math.abs(c2 - c1) + 1)
                                else
                                    return ''
                                end
                            end

                            if m == "v" or m == "V" or m == "\22" then
                                icon = '<>'
                                return icon  .. selectioncount()
                            else
                                return icon
                            end
                        end,
                        padding={left=0,right=1},
                    },
                    {'location', padding=0},
                    {--line count
                        function()
                            local lines = vim.api.nvim_buf_line_count(0)
                            return lines..'L'
                        end,
                        padding={left=1,right=0},
                    },
                    {function() return "|" end, padding = 0, color={fg='#a8a7a7'}},
                    {--filesize
                        function()
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
                            local buft
                            if vim.bo.buftype == "" then
                                buft = "regular"
                            else
                                buft = vim.bo.buftype
                            end

                            local bufmodif
                            if vim.bo.modifiable then
                                bufmodif = ""  -- 🪶 🖋
                            else
                                bufmodif = "🚫"
                            end

                            return "" .. buft .. bufmodif
                        end,
                        on_click = function()
                            local output = vim.fn.execute("ls")
                            vim.notify(output, vim.log.levels.INFO, { title = "Buffers" })
                        end,
                        color={gui = 'none'},
                        padding={left=0,right=0},
                        separator={left="▐"}
                    },
                },

                lualine_z =
                {
                    {   --filename
                        function()
                            local file_path = vim.api.nvim_buf_get_name(0)

                            --local file_name = vim.fn.expand("%:t")
                            local file_name = vim.fn.fnamemodify(file_path, ":t")

                            --local file_type = "." .. vim.bo.filetype
                            --local file_type = "." .. vim.fn.expand("%:e")
                            --if file_type == "." then file_type = "[.notype]" end

                            --file properties
                            local file_ondisk   = vim.fn.filereadable(file_path) == 1
                            local file_readonly = vim.bo.readonly
                            local file_exec     = vim.fn.executable(file_path) == 1

                            if file_name == "" then file_name = "[noname]" end

                            local file_ondisk_symbol = ""
                            if file_ondisk then
                                file_ondisk_symbol = ""
                            else
                                file_ondisk_symbol = '[!file]'
                            end

                            local file_readonly_icon = "🔒"
                            if not file_readonly then file_readonly_icon = "" end

                            local file_exec_icon = "▶"
                            if not file_exec then file_exec_icon = "" end

                            return file_readonly_icon..file_exec_icon..file_name..file_ondisk_symbol
                        end,
                        color={gui = 'none'},
                        padding={left=0,right=0},
                        separator={left="▐"}
                    },

                    --{--Get curr LSP
                    --    function()
                    --        local clients = vim.lsp.get_active_clients({ bufnr = 0 })
                    --        if #clients == 0 then
                    --            return "ⓘ NoLSP"
                    --    end
                    --    local names = {}
                    --    for _, client in ipairs(clients) do
                    --        table.insert(names, client.name)
                    --    end
                    --        return "{"..table.concat(names, ", ").."}"
                    --    end,

                    --    on_click = function()
                    --        local clients = vim.lsp.get_active_clients({ bufnr = 0 })
                    --        if #clients == 0 then
                    --            print("No active LSP clients")
                    --            return
                    --        end
                    --        local client = clients[1] -- Assuming only one client
                    --        local root_dir = client.config.root_dir
                    --        print("LSP root dir: " .. root_dir)
                    --    end,
                    --    padding = 0,
                    --    --separator={left=''},
                    --},--Get curr LSP
                    --{
                    --    'lsp_status',
                    --    icon = '', -- f013
                    --    symbols = {
                    --        spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
                    --        done = '',
                    --        -- Delimiter inserted between LSP names:
                    --        separator = ' ',
                    --    },
                    --    -- List of LSP names to ignore (e.g., `null-ls`):
                    --    ignore_lsp = {},
                    --},

                    {
                        "filetype",
                        icon_only = true,
                        on_click = function()
                            local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })

                            if #clients == 0 then return "ⓘ NoLSP" end
                            local names = {}
                            for _, client in ipairs(clients) do
                                table.insert(names, client.name)
                            end
                            print("LSPs: "..table.concat(names, ", "))
                        end,

                        padding = 0
                    },
                },
            },

            winbar =
            {
                lualine_a ={
                    {
                        function() --toggle neotree
                            return " ⇥ "
                        end,
                        on_click=function() vim.cmd("Neotree toggle") end,
                        right_padding = 1,
                        color = { fg = "#5c5c5c", bg = 'NONE'},
                    },
                },
                lualine_b = {
                    {
                        function() --path
                            local cf = vim.fn.expand("%:p")
                            local dir = vim.fn.fnamemodify(cf, ":h")
                            local home = vim.fn.expand("~")
                            local short = vim.fn.substitute(dir, "^" .. vim.fn.escape(home, "\\") .. "/", "~/", "")
                            local fancy = short:gsub("/", "🮥 ") --› > 〉  › ›

                            return "📁│"..fancy..""  --/.
                        end,
                        --separator={right=''},
                        color = { fg = "#737373", bg = 'NONE'},
                    },

                },

                lualine_z =
                {
                    {
                        function () --add to favorite
                            return "☆" --☆ ★
                        end,
                        on_click=function() vim.cmd("echo'fav!'") end,
                        padding=0,
                        color = { fg = "#5c5c5c", bg = 'NONE'},
                    },

                    {
                        function() --burger
                          return "≡"
                        end,
                        color = { fg = "#5c5c5c", bg = 'NONE'},
                    }
                },

            },


        })--setup
    end,
}



