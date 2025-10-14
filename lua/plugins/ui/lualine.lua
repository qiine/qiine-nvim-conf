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
                    statusline = {"alpha"},
                    winbar = {},
                },
                disabled_buftypes = {
                    winbar = {},
                },
                ignore_focus = {"help", "neo-tree", "trouble", "fzf-lua"},
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
                    -- {
                    --     function() return " 📂" end,
                    --     on_click=function() vim.cmd("echo '"..vim.fn.getcwd().."'") end,
                    --     padding=0,
                    --     color = { bg = 'NONE'},
                    -- },

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

                            vim.cmd("term")
                            vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
                            vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})
                            local lines = vim.fn.line('$')
                            local new_height = math.floor(lines / 2)+3
                            vim.cmd('resize ' .. new_height)
                        end,
                        left_padding = 1,
                        --color = { fg = '#0c0c0c'},
                    },
                    { --cmd win
                        function() return '⌨' end, --🖵
                        on_click = function()
                            if vim.bo.filetype == "vim" then
                                vim.api.nvim_input('<esc>:quit<cr>')
                            else
                                vim.api.nvim_input('<esc>q:')
                            end
                        end,
                        padding = 0,
                        color = { fg = '#545454'},
                    },
                },--line c

                lualine_x =
                {
                    { --curr writing lang
                        function ()
                            local langs = vim.opt.spelllang:get()
                            return table.concat(langs, ",")
                        end
                    },

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
                                icon = '󰅴'
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
                            local fpath       = vim.fn.expand("%:")
                            local fname       = vim.fn.expand("%:t")
                            local fstat       = vim.uv.fs_stat(fpath)
                            local freadonly   = fstat and (not vim.uv.fs_access(fpath, "w"))
                            local fprivileged = fstat and fstat.uid == 0
                            local fexec       = vim.fn.executable(fpath) == 1

                            if fname == "" then fname = "[noname]" end

                            local fondisk_ic = ""
                            if not fstat then fondisk_ic = '[!]' end

                            local fpriviledged_ic = ""
                            if fprivileged then fpriviledged_ic = "🛡️" end

                            local freadonly_ic = "🔒"
                            if not freadonly then freadonly_ic = "" end

                            local fexec_ic = "▶"
                            if not fexec then fexec_ic = "" end

                            local finfo = {
                                fpriviledged_ic,
                                freadonly_ic,
                                fexec_ic,
                                fname,
                                fondisk_ic,
                            }

                            return table.concat(finfo, "")
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

                    {
                        -- --"os"
                        -- function()
                        --     if     vim.fn.has("win32")   == 1 then return ""
                        --     elseif vim.fn.has("macunix") == 1 then return ""
                        --     elseif vim.fn.has("unix")    == 1 then return ""
                        --     else                                   return "OS"
                        --     end
                        -- end,
                        -- padding = 0,
                        -- color={fg = "#1f1f1f", bg = '#e6e6e6'},
                    }
                },
            },

            winbar =
            {
                --lualine_a = {},
                --lualine_b = {},
                --lualine_z = {},
            },


        })--setup
    end,
}



