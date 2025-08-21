return
{
    "RRethy/vim-illuminate",
    enabled = true,
    event = "BufEnter",
    desc = "Highlight similar words",

    config = function()
        require('illuminate').configure({
            providers = {
                --'lsp',
                'treesitter',
                --'regex',
            },

            under_cursor = false, --on hover word

             -- modes_allowlist: modes to illuminate, this is overridden by modes_denylist
             -- See `:help mode()` for possible values
            modes_allowlist = {"v"},
            --modes_denylist = {"V"},
        })
    end
}
