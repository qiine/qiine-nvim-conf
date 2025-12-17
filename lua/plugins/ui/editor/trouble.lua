return {
    "folke/trouble.nvim",
    enabled = true,
    event = "UIEnter",

    dependencies = { "nvim-tree/nvim-web-devicons" },

    config = function()
        require("trouble").setup({
            -- focus = false,
            warn_no_results = false,
            open_no_results = true,
            auto_preview    = false,
            follow    = false,
            auto_jump = false,
            restore   = false,

            keys = {
                r = "refresh",
                R = "toggle_refresh",
                q = "close",
                ["<C-CR>"] = "jump_close",
                ["<Tab>"] = {
                    action = function()
                        require("trouble").next()
                        require("trouble").preview()
                    end,
                },
                ["<S-Tab>"] = {
                    action = function()
                        require("trouble").prev()
                        require("trouble").preview()
                    end,
                },
                ["<CR>"] = "preview",
                ["<M-z>"] = "fold_toggle",
                ["<M-S-z>"] = "fold_toggle_recursive",
                -- ["<M-q>"] = "quickfix",
                s = { -- example of a custom action that toggles the severity
                    action = function(view)
                        local f = view:get_filter("severity")
                        local severity = ((f and f.filter.severity or 0) + 1) % 5
                        view:filter({ severity = severity }, {
                            id = "severity",
                            template = "{hl:Title}Filter:{hl} {severity}",
                            del = severity == 0,
                        })
                    end,
                    desc = "Toggle Severity Filter",
                },
            }
        })
    end,
}
