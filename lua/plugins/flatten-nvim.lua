return
{
    "willothy/flatten.nvim",
    enabled = false,
    lazy = false,
    priority = 1001,

    config = function()
        require("flatten").setup({
            window = {
                open = "tab", -- Opens files in a new tab
            },
            --nest_if_no_args = true,
        })
    end
}
