return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },

    config = function()
        require("conform").setup({
            formatters_by_ft = {
                --Conform will run multiple
                --formatters sequentially
                --def available
                --formatters
                lua = { "stylua", lsp_format = "fallback" },
                python = { "isort", "black" },
                rust = { "rustfmt", lsp_format = "fallback" },
                javascript = {
                    "prettierd",
                    "prettier",
                    stop_after_first = true,
                },
                mardown = { "prettier" },
                yaml = { "prettier" },
            },

            format_on_save = false,
        })

        vim.api.nvim_create_user_command("FormatBuffer", function(args)
            local range = nil
            if args.count ~= -1 then
                local end_line = vim.api.nvim_buf_get_lines(
                    0,
                    args.line2 - 1,
                    args.line2,
                    true
                )[1]
                range = {
                    start = { args.line1, 0 },
                    ["end"] = { args.line2, end_line:len() },
                }
            end
            require("conform").format({
                async = true,
                lsp_format = "fallback",
                range = range,
            })
        end, {})

        vim.api.nvim_create_user_command("FormatSelected", function(args)
            local range = nil
            if args.count ~= -1 then
                local end_line = vim.api.nvim_buf_get_lines(
                    0,
                    args.line2 - 1,
                    args.line2,
                    true
                )[1]
                range = {
                    start = { args.line1, 0 },
                    ["end"] = { args.line2, end_line:len() },
                }
            end
            require("conform").format({
                async = true,
                lsp_format = "fallback",
                range = range,
            })
            vim.cmd("normal! gv")
        end, { range = true })
    end,
}
