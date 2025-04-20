return
{
    "neovim/nvim-lspconfig",
    enabled = true,
    dependencies=
    {
        "saghen/blink.cmp"
    },

    config = function()
        local lspconfig = require('lspconfig')
        local capabilities = require("blink.cmp").get_lsp_capabilities()

        local servers =
        {
            "lua_ls",
            "rust_analyzer",
            "clangd",
            "ts_ls",
            "html",
            "cssls",
            "jsonls",
            "yamlls",
            "bashls",
            "marksman",
            --"harper_ls",
        }

        --local installed_servers = require("mason-lspconfig").get_installed_servers()
        --
        --for _, server_name in ipairs(installed_servers) do
        --    require("lspconfig")[server_name].setup({
        --        capabilities = require("blink.cmp").get_lsp_capabilities(),
        --    })
        --end


        for _, server in ipairs(servers) do
            lspconfig[server].setup({ capabilities = capabilities })
        end

        lspconfig.lua_ls.setup {
            settings = {
                Lua = {
                    runtime = {
                        -- Tell the language server which version of Lua you're using
                        -- (most likely LuaJIT in the case of Neovim)
                        version = 'LuaJIT',
                    },
                    diagnostics = {
                        -- Get the language server to recognize the `vim` global
                        globals = {
                            'vim',
                            --'require'
                        },
                        disable = {},
                    },
                    workspace = {
                        --Make the server aware of Neovim runtime files
                        library = vim.api.nvim_get_runtime_file("", true),
                        checkThirdParty = false,
                    },
                    telemetry = { enable = false },
                },
            },
        }
    end,
}
