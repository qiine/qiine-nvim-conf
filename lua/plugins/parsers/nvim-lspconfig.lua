return
{
    "neovim/nvim-lspconfig",
    enabled = true,

    dependencies = {"saghen/blink.cmp"},

    config = function()
        local lspconfig    = require('lspconfig')
        local capabilities = require("blink.cmp").get_lsp_capabilities()
    end
}

