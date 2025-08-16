---@return table
local function layout()
    local function button(sc, txt, keybind, keybind_opts, opts)
        local def_opts = {
            cursor = 3,
            align_shortcut = "right",
            hl_shortcut = "AlphaButtonShortcut",
            hl = "AlphaButton",
            width = 40,
            position = "center",
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

    local splash = {
        ["default1"] = {
            [[███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
            [[████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
            [[██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
            [[██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
            [[██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
            [[╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        },
        ["default2"] = {
            [[                               __                ]],
            [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
            [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
            [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
            [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
            [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
        },
        ["pika"] = {
            [[        ▀████▀▄▄              ▄█]],
            [[          █▀    ▀▀▄▄▄▄▄    ▄▄▀▀█]],
            [[  ▄        █          ▀▀▀▀▄  ▄▀ ]],
            [[ ▄▀ ▀▄      ▀▄              ▀▄▀ ]],
            [[▄▀    █     █▀   ▄█▀▄      ▄█   ]],
            [[▀▄     ▀▄  █     ▀██▀     ██▄█  ]],
            [[ ▀▄    ▄▀ █   ▄██▄   ▄  ▄  ▀▀ █ ]],
            [[  █  ▄▀  █    ▀██▀    ▀▀ ▀▀  ▄▀ ]],
            [[ █   █  █      ▄▄           ▄▀  ]],
        }
    }

    local function date()
        return os.date(" %H:%M:%S -  %d/%m/%Y")
    end

    ---@return string
    local function system()
        local v = vim.version()
        local plugins = #vim.tbl_keys(require("lazy").plugins())
        local platform = vim.fn.has("win32") == 1 and "" or ""
        local parts = {
            "󰂖",
            plugins,
            "|",
            "",
            v.major .. "." .. v.minor .. "." .. v.patch,
            "|",
            platform,
        }
        return table.concat(parts, " ")
    end

    ---@return table
    local function menu()
        --conf path
        local nvim_conf_path = vim.fn.stdpath("config")
        local nvim_conf_init = nvim_conf_path.."/init.lua"

        return {
            button("n", " New file", "<Cmd>enew<CR>"),
            button("r", "󰈢 Recently opened files", "<cmd>FzfLua oldfiles<CR>"),
            button("f", " File browser"),
            button("s", " Open session", "<Cmd>LoadGlobalSession<CR>"),
            button("c", " Config", function()vim.cmd("e "..nvim_conf_init) vim.cmd("cd "..nvim_conf_path) end),
            button("p", "󰂖 Plugins", "<Cmd>Lazy<CR>"), --󰂖 🧩

            button("q", "⎋ Quit", "<Cmd>qa!<CR>"), --󰅚
        }
        --  dashboard.button("c", " " .. "Config",  function()vim.cmd("e "..nvim_conf_init) vim.cmd("cd "..nvim_conf_path) end),

    end

    ---@return table
    --local function mru()
    --    local result = {}
    --    for _, filename in ipairs(vim.v.oldfiles) do
    --        if vim.loop.fs_stat(filename) then
    --            local icon, hl = require("nvim-web-devicons").get_icon(filename, vim.fn.fnamemodify(filename, ":e"))
    --            local filename_short = string.sub(vim.fn.fnamemodify(filename, ":t"), 1, 30)
    --            table.insert(
    --                result,
    --                button(
    --                    tostring(#result + 1),
    --                    string.format("%s  %s", icon, filename_short),
    --                    string.format("<Cmd>e %s<CR>", filename),
    --                    nil,
    --                    { hl = { { hl, 0, 3 }, { "Normal", 5, #filename_short + 5 } } }
    --                )
    --            )
    --            if #result == 9 then break end
    --        end
    --    end
    --    return result
    --end

    ---@return table
    local function fortune()
        return require("alpha.fortune")()
    end

    math.randomseed(os.time())
    local header_color = "AlphaCol" .. math.random(11)

    local splash_keys = vim.tbl_keys(splash)
    local rand_key = splash_keys[math.random(#splash_keys)]

    return {
        { type = "padding", val = 1 },
        {
            type = "text",
            val  = splash[rand_key],
            opts = { hl = header_color, position = "center" },
        },
        { type = "padding", val = 1 },
        {
            type = "text",
            val  = date ,
            opts = { hl = header_color, position = "center" }
        },
        {
            type = "text",
            val  = system ,
            opts = { hl = header_color, position = "center" }
        },
        { type = "padding", val = 1 },
        {
            type = "group",
            val  = menu,
            opts = { spacing = 1 }
        },
        --{ type = "padding", val = 1 },
        --{
        --    type = "group",
        --    val  = mru,
        --    opts = { spacing = 0 }
        --},
        --{ type = "padding", val = 1 },
        {
            type = "text",
            val  = fortune,
            opts = { hl = "AlphaQuote", position = "center" }
        },
    }
end

return
{
    "goolord/alpha-nvim",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = "VimEnter",

    config = function()
        local alpha     = require('alpha')
        local dashboard = require('alpha.themes.dashboard')
        local fortune   = require("alpha.fortune")

        require("alpha").setup {
            layout = layout(),
            opts = {
                --margin = 0,
            },
        }
    end,
}
