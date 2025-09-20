return
{
    "williamboman/mason.nvim",
    enabled = true,
    dependencies = {
        "neovim/nvim-lspconfig",
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },

    config = function()
        require("mason").setup()

        require("mason-lspconfig").setup({
            ensure_installed =
            {
                "lua_ls",
                "rust_analyzer",
                "clangd",
                "ts_ls",
                --"html-lsp",
                --"cssls",
                --"jsonls",
                "yamlls",
                "bashls",
                "marksman",
                --"harper_ls",
            },
        })

        require("mason-tool-installer")

        -- Auto-install additional tools (optional)
        require("mason-tool-installer").setup({
            ensure_installed = {
                "prettier",
                "stylua",
                "eslint_d",
            },
        })



    end,
}
