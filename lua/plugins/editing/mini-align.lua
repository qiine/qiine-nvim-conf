return
{
    "echasnovski/mini.align",
    version = "*",

    config = function()
        require("mini.align").setup({
            -- Module mappings. Use `''` (empty string) to disable one.
            mappings = {
                start = "ga",
                start_with_preview = "â",
            },
        })
    end,
}
