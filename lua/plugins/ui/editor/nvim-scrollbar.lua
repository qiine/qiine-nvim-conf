return {
    "petertriho/nvim-scrollbar",
    enabled = false,
    desc = "Add a scrollbar to the left",

    -- sadly non clickable

    config = function()
        require("scrollbar").setup({
            show = true,
            handle = {
                text = " ",
                blend = 30, -- Integer between 0 and 100. 0 for fully opaque and 100 to full transparent. Defaults to 30.
                color = "grey",
                color_nr = nil, -- cterm
                highlight = "CursorColumn",
                hide_if_all_visible = false, -- Hides handle if all lines are visible
            },
            handlers = {
                cursor = true,
                diagnostic = true,
                gitsigns = false, -- Requires gitsigns
                handle = true,
                search = false, -- Requires hlslens
                ale = false, -- Requires ALE
            },
        })
    end
}
