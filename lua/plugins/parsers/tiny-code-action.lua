return
{
    "rachartier/tiny-code-action.nvim",
    dependencies = { "nvim-lua/plenary.nvim",},
    event = "LspAttach",

    config = function()
        require("tiny-code-action").setup({
            backend = "vim",
            picker = {
                "buffer",
                opts = {
                    auto_preview = true,
                    winborder = "rounded", --"single", "rounded", "solid", etc.)
                    position = "center",   --cursor
                    keymaps = {
                        close = "<esc>",
                    }
                },
            },
        })
    end
}


