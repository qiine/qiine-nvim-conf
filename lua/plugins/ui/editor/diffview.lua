return
{
	'sindrets/diffview.nvim',
    enabled = false,

    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },

    config = function ()
        require("diffview").setup({
            view = {
                -- Configure the layout and behavior of different types of views.
                -- Available layouts:
                --  'diff1_plain'
                --    |'diff2_horizontal'
                --    |'diff2_vertical'
                --    |'diff3_horizontal'
                --    |'diff3_vertical'
                --    |'diff3_mixed'
                --    |'diff4_mixed'
                -- For more info, see |diffview-config-view.x.layout|.
                default = {
                    -- Config for changed files, and staged files in diff views.
                    layout = "diff2_horizontal",
                    disable_diagnostics = false,  -- Temporarily disable diagnostics for diff buffers while in the view.
                    winbar_info = false,          -- See |diffview-config-view.x.winbar_info|
            },

            },
            default_args = {    -- Default args prepended to the arg-list for the listed commands
                DiffviewOpen = {},
                DiffviewFileHistory = {},
            },

            hooks = { -- See':h diffview-config-hooks'
                view_opened = function()
                    require("diffview.actions").toggle_files()
                end,
            },
        })
    end
}
