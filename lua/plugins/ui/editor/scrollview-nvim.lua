return
{
    'dstein64/nvim-scrollview',
    enabled = true,

    config = function()
        require("scrollview").setup({
            excluded_filetypes = {},
            --signs_on_startup = {"search", "diagnostics" }, --"cursor"
            signs_on_startup = {},
            diagnostics_severities = {vim.diagnostic.severity.ERROR},
        })
        vim.g.scrollview_signs_scrollbar_overlap = 'over'
        vim.g.scrollview_signs_max_per_row = 1

    end,

}
