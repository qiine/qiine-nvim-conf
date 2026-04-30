---@return table
local function dashlayout()

    ---@return table
    local function button(sc, txt, keybind, keybind_opts, opts)
        local def_opts = {
            cursor   = 2,
            position = "center",
            width    = 45,
            align_shortcut = "right",
            hl_shortcut = "AlphaButtonShortcut",
            hl          = "AlphaButton",
        }

        opts = opts and vim.tbl_extend("force", def_opts, opts) or def_opts
        opts.shortcut = sc

        local sc_ = sc:gsub("%s", ""):gsub("SPC", "<Leader>")
        local on_press = function()
            local key = vim.api.nvim_replace_termcodes(keybind or sc_ .. "<Ignore>", true, false, true)
            vim.api.nvim_feedkeys(key, "t", false)
        end
        if keybind then
            keybind_opts = keybind_opts or { noremap = true, silent = true, nowait = true }
            opts.keymap = { "n", sc_, keybind, keybind_opts }
        end

        return { type = "button", val = txt, on_press = on_press, opts = opts }
    end

    local splasharts = {
        ["default1"] =
        {
            [[                                                  ]],
            [[███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
            [[████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
            [[██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
            [[██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
            [[██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
            [[╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        },
        ["default2"] =
        {
            [[                               __                ]],
            [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
            [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
            [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
            [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
            [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
        },
        ["default3"] =
        {
            [[                __                ]],
            [[  ___   __  __ /\_\    ___ ___    ]],
            [[/' _ `\/\ \/\ \\/\ \ /' __` __`\  ]],
            [[/\ \/\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
            [[\ \_\ \_\ \___/  \ \_\ \_\ \_\ \_\]],
            [[ \/_/\/_/\/__/    \/_/\/_/\/_/\/_/]],
        },
        -- ["default4"] =
        -- {
        --     [[      ████ ██████           █████      ██                    ]],
        --     [[     ███████████             █████                            ]],
        --     [[     █████████ ███████████████████ ███   ███████████  ]],
        --     [[    █████████  ███    █████████████ █████ ██████████████  ]],
        --     [[   █████████ ██████████ █████████ █████ █████ ████ █████  ]],
        --     [[ ███████████ ███    ███ █████████ █████ █████ ████ █████ ]],
        --     [[██████  █████████████████████ ████ █████ █████ ████ ██████]],
        -- },
        ["doomsmall"] =
        {
            [[ ━━━━━━   ━━━━━━  ━━━━━━   ━   ━━ ]],
            [[┃|  _   V   _   ┃┃   _   V  \/  |┃]],
            [[┃┃ ┃ ┃  ┃  | ┃  ┃┃  ┃ |  ┃      ┃┃]],
            [[┃┃ ┃ ┃  ┃   \|  ┃┃  |/   ┃ ┃\/┃ ┃┃]],
            [[┃┃ ┃/   |       ┃┃       ┃ ┃  ┃ ┃┃]],
            [[┃┃     / \     /  \     / \┃  ┃ ┃┃]],
            [[┃┃   /     \ /      \ /       ┃ ┃┃]],
            [[|_ /                            ┗|]],
            [[           N E O V I M            ]],
        },
        ["pika"] =
        {
            [[        ▀████▀▄▄  N E O V I M ▄█]],
            [[          █▀    ▀▀▄▄▄▄▄    ▄▄▀▀█]],
            [[  ▄        █          ▀▀▀▀▄  ▄▀ ]],
            [[ ▄▀ ▀▄      ▀▄              ▀▄▀ ]],
            [[▄▀    █     █▀   ▄█▀▄      ▄█   ]],
            [[▀▄     ▀▄  █     ▀██▀     ██▄█  ]],
            [[ ▀▄    ▄▀ █   ▄██▄   ▄  ▄  ▀▀ █ ]],
            [[  █  ▄▀  █    ▀██▀    ▀▀ ▀▀  ▄▀ ]],
        },
        --["oddish"] =
        --{
        --    [[             █░░█▒▒█             ]],
        --    [[     █░░░░░█░░░█▒░░░▒█ █░░░░░█   ]],
        --    [[   █░░░█░░█░░░█░░░░▓███░░░░░▒████]],
        --    [[    █░░░░█░█░▒█▒▒▒░▓█▒████░░░░░█ ]],
        --    [[      █░░▒▒▒█▒▒▒▒▒███▒▒▒▒░░░░█   ]],
        --    [[        ██▒▒▒█▒▒██▓▒▒▒▒▒▒██      ]],
        --    [[         █▒▒▒▒▒▒▒▒▒▓▓█           ]],
        --    [[        █▒▓▒▒▒▒▒▓▒▒▓▓▓█          ]],
        --    [[       █▒▒▒▒▓▓▓▒▒▒▒▓▓▓▓█         ]],
        --    [[      ███▒▒▒▒▒▒▓▓▓▓▓▓▓█          ]],
        --    [[     █▒▒▒▓▓█▓▓▓▓▓▓▓███           ]],
        --    [[      █▓▓▓▓▓█    ██▓██           ]],
        --    [[         ███    █▓▓▓▓▓█  NEOVIM  ]],
        --},
        -- ["floppy"] =
        -- {
        --     [[┏━━━━━━━━━━━━━━━━━┓]],
        --     [[┃▘ : --------- : ▝┃]],
        --     [[┃  : -NEOVIM-- :  ┃]],
        --     [[┃  : --------- :  ┃]],
        --     [[┃  :▁▁▁▁▁▁▁▁▁▁▁:  ┃]],
        --     [[┃    ▁▁▁▁▁▁▁▁▁    ┃]],
        --     [[┃   ┃ __      ┃   ┃]],
        --     [[┃   ┃┃  ┃     ┃   ┃]],
        --     [[\▁▁▁||▁▁|▁▁▁▁▁|▁▁▁┃]],
        -- },
        --["n"] =
        --{
        --    [[  ▄▄         ▄]],
        --    [[▄▀███▄     ▄██]],
        --    [[██▄▀███▄   ███]],
        --    [[███  ▀███▄ ███]],
        --    [[███    ▀███▄▀█]],
        --    [[███      ▀███▀]],
        --    [[▀██       ▀█▀ ]],
        --    [[  ▀           ]],
        --},
    }

    --light (─ │ ┌ ┐ └ ┘ ┬ ┴ ├ ┤ ┼ …)
    --heavy (━ ┃ ┏ ┓ ┗ ┛ ┳ ┻ ┣ ┫ ╋ …)
    --double (═ ║ ╔ ╗ ╚ ╝ ╦ ╩ ╠ ╣ ╬ …)

    local function splash()
        local splash_keys = vim.tbl_keys(splasharts)
        local rand_key = splash_keys[math.random(#splash_keys)]

        return splasharts[rand_key]
    end

    local function set_wipe_dashboard()
        vim.bo.buflisted = false
        vim.bo.bufhidden = "wipe"
    end

    local function get_date()
        return os.date(" %H:%M:%S -  %a %d/%m/%Y")
    end

    ---@return string
    local function get_system()
        local function get_platform_icon()
            if     vim.fn.has("win32")   == 1 then return ""
            elseif vim.fn.has("macunix") == 1 then return ""
            elseif vim.fn.has("unix")    == 1 then return ""
            else                                   return "OS"
            end
        end

        local function get_distro_info()
            if vim.fn.has("unix") == 0 then return nil end

            local resdistr = vim.system({"grep", "VENDOR_NAME", "/etc/os-release"}, {text=true}):wait()
            local resdistr_ver = vim.system({"grep", "VERSION_ID", "/etc/os-release"}, {text=true}):wait()

            local distroinfo = vim.trim(tostring(resdistr.stdout)).." "..vim.trim(tostring(resdistr_ver.stdout))

            distroinfo = string.gsub(distroinfo, 'VENDOR_NAME=', "")
            distroinfo = string.gsub(distroinfo, 'VERSION_ID=', "")
            distroinfo = string.gsub(distroinfo, '"', "")

            return distroinfo
        end

        local vv = vim.version()

        local pluginfos = require("lazy").stats()
        local plugloadtime = math.floor(pluginfos.startuptime * 100 + 0.5) / 100

        local parts = {
            "", " ", vv.major.."."..vv.minor.."."..vv.patch,
            " | ",
            "󰏗 ", pluginfos.loaded, "/", pluginfos.count, " ", plugloadtime, "ms",
            " | ",
            get_platform_icon(), " ", get_distro_info(),
        }
        return table.concat(parts, "")
    end

    ---@return table
    local function menu()
        return {
            button("n", " New file", function() set_wipe_dashboard() vim.cmd("enew | FzfLua filetypes") end),
            button("f", "★ Fav files", "<Cmd>FzfLua favorites<CR>"),
            button("r", "󰈢 Recent files", function() set_wipe_dashboard() vim.cmd("enew | FzfLua oldfiles") end),
            button("p", " Projects",     "<Cmd>FzfLua projects<CR>"),
            button("o", "󰅌 Org",     "<Cmd>PlanOverviewOpen<CR>"),
            -- button("b", " File browser", function() set_wipe_dashboard() vim.cmd("Oil") end),
            button("s", " Load session", function() set_wipe_dashboard() vim.cmd("SessionLoad") end),
        }
    end


    ---@return table
    local function fortune()
        local rng = math.random(10)
        if rng > 3 then return require("alpha.fortune")()
        else            return {}
        end
    end

    return {
        { type = "padding", val = 1 },
        {
            val  = splash(),
            type = "text",
            opts = { position = "center" },
        },
        {
            val  = "────────────────────────────────────────",
            --val  = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
            type = "text",
            opts = { position = "center" },
        },

        --{ type = "padding", val = 1 }, --
        {
            val  = get_system(),
            type = "text",
            opts = { position = "center" }
        },
        {
            val  = get_date(),
            type = "text",
            opts = { position = "center" }
        },

        {type = "padding", val = 1 }, --
        {
            val  = menu(),
            type = "group",
            opts = { spacing = 0 }
        },

        {type = "padding", val = 1 }, --
        {   --options
            val  = {
                button("c", " Config", function() set_wipe_dashboard(); vim.cmd("CdNvimStdpathConfig") vim.cmd("e ./init.lua") end),
                button("e", "󰏗 Plugins", "<Cmd>Lazy<CR>"), -- 󰂖 🧩 󱁤
            },
            type = "group",
            opts = { spacing = 0 }
        },


        {type = "padding", val = 2 }, --
        {   --Exit
            val  = {button("q", " Exit", "<Cmd>qa!<CR>")}, --󰅚  ⎋
            type = "group",
            opts = { spacing = 0 }
        },

        {
            val  = fortune(),
            type = "text",
            opts = { hl = "AlphaQuote", position = "center" }
        },
        --{ type = "padding", val = 1 }, --
        --{
        --    val  = mru,
        --    type = "group",
        --    opts = { spacing = 0 }
        --},
        --{ type = "padding", val = 1 },
    }
end


return
{
    "goolord/alpha-nvim",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    enabled = true,
    -- event = "VimEnter",

    config = function()
        local alpha = require('alpha')

        require("alpha").setup {
            layout = dashlayout(),
            opts = {
                autostart = true,
            },
        }

        -- vim.api.nvim_create_autocmd("User", {
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("Alpha-nvim", { clear = true }),
            pattern = "alpha",
            callback = function()
                vim.cmd("norm! gg")

                vim.opt_local.buflisted      = true
                -- vim.opt_local.bufhidden      = ''
                vim.opt_local.statuscolumn   = ""
                vim.opt_local.signcolumn     = "no"
                vim.opt_local.number         = false
                vim.opt_local.relativenumber = false
                vim.opt_local.foldcolumn     = "0"
                vim.opt_local.modifiable     = false

                vim.keymap.set({"i","n","v"}, "<M-n>", "<cmd>News<CR>", {buffer=true})

                require("alpha").setup { layout = dashlayout()}
            end,
        })

    end,
}

----refs
----https://github.com/dtr2300/nvim/blob/main/lua/config/plugins/alpha.lua


