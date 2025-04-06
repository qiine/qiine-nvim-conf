return
{
    --Add vertical lines to code blocks
    "lukas-reineke/indent-blankline.nvim",
    enabled = true,
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config

    config = function()
        require("ibl").setup({
            scope = {
                enabled = true,
                --show_start = true,
                --show_end = true,
                --injected_languages = true,
                --show_exact_scope = false,
            },
            --include = {
            --    node_type = {
            --        ["typescript"] = {
            --            "unary_expression",
            --            "expression_statement",
            --            "return_statement",
            --            "open_tag",
            --            "key",
            --            "array",
            --            "object",
            --            "lexical_declaration",
            --            "switch_statement",
            --            "switch_case",
            --            "switch_body",
            --            "switch_default"
            --        }
            --    }
            --},

            exclude = {
                filetypes = {
                    "log", "txt", "md",
                    "dashboard",--nvim dashboard
                },
                buftypes = { "terminal", "nofile" }
            }
        })--setup
    end--config
}
