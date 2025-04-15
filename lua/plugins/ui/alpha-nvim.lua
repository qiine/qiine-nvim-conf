return
{
    "goolord/alpha-nvim",
    dependencies = { 'nvim-tree/nvim-web-devicons' },

    config = function()
        local alpha = require('alpha')
        local dashboard = require('alpha.themes.dashboard')

        --math.randomseed(os.time())
        local banner =
        {
             [[                               __                ]],
             [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
             [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
             [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
             [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
             [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],

        }

        local function header()
            local datetime = os.date(" %d-%m-%Y   %H:%M:%S")
            return banner
        end
        dashboard.section.header.val = header()
        dashboard.section.header.opts.position = "center"

        dashboard.section.buttons.val = {
            dashboard.button("s", " " .. "Restore Session", [[<cmd> lua require("persistence").load() <cr>]]),
            dashboard.button( "e", " " .. "New file" , ":enew <BAR> startinsert <CR>"),
            dashboard.button("r", " " .. "Recent files",    [[<cmd> :Telescope oldfiles<CR>"]] ),
            dashboard.button("c", " " .. "Config",          "<cmd> lua LazyVim.pick.config_files()() <cr>"),
            dashboard.button( "q", "󰅚 ".. "Quit NVIM" , ":qa<CR>"),
        }

            local function footer()
            --local total_plugins = #vim.tbl_keys(packer_plugins)
            local version = vim.version()
            local nvim_version_info = "   v" .. version.major .. "." .. version.minor .. "." .. version.patch
            --local fortune = require("alpha.fortune")

            return nvim_version_info .."\n".. "test"
        end

        --Footer
        dashboard.section.footer.val = footer()
        dashboard.section.footer.opts.position = "center"

        dashboard.config.opts.noautocmd = true

        vim.cmd[[autocmd User AlphaReady echo 'ready']]

        alpha.setup(dashboard.config)
    end,
}
