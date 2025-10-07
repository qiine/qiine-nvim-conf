return
{
    "hedyhli/outline.nvim",
    enabled = false,

    config = function()
        vim.keymap.set("n", "<C-S-b>", "<cmd>Outline<CR>", {desc="Toggle Outline" })

        require("outline").setup {

            -- symbols = {
            --     -- Filter by kinds (string) for symbols in the outline.
            --     -- Possible kinds are the Keys in the icons table below.
            --     -- A filter list is a string[] with an optional exclude (boolean) field.
            --     -- The symbols.filter option takes either a filter list or ft:filterList
            --     -- key-value pairs.
            --     -- Put  exclude=true  in the string list to filter by excluding the list of
            --     -- kinds instead.
            --     -- Include all except String and Constant:
            --     --   filter = { 'String', 'Constant', exclude = true }
            --     -- Only include Package, Module, and Function:
            --     --   filter = { 'Package', 'Module', 'Function' }
            --     -- See more examples below.
            --     filter = nil,
        }
    end,
}
