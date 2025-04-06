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
                lua = { "stylua",  lsp_format = "fallback"},
                python = { "isort", "black" },
                rust = { "rustfmt", lsp_format = "fallback" },
                javascript = { "prettierd", "prettier", stop_after_first = true },
                mardown = { "prettier" },
                yaml = { "prettier" },
            },

            format_on_save = false,
        })
    end,
}
