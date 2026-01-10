return
{
    "3rd/image.nvim",
    enabled = true,
    commit = "21909e3eb03bc738cce497f45602bf157b396672", -- see https://github.com/3rd/image.nvim/issues/292
    build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239

    config = function()
        require("image").setup({
            backend = "kitty", -- ueberzug,kitty,sixel
            kitty_method = "normal",
            processor = "magick_cli", -- or "magick_rock"

            integrations = {
                markdown = {
                    enabled = true,
                    clear_in_insert_mode = false,
                    download_remote_images = false,
                    only_render_image_at_cursor = false,
                    floating_windows = true, -- if true, images will be rendered in floating markdown windows
                    filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
                },
            },

            max_height = nil,
            max_width = nil,
            max_height_window_percentage = math.huge, -- this is necessary for a good experience
            max_width_window_percentage = math.huge,
            -- max_height_window_percentage = 100,
            -- max_width_window_percentage = 100,
            scale_factor = 1.0,

            hijack_file_patterns = {
                "*.png",
                "*.jpg", "*.jpeg",
                -- "*.gif",
                -- "*.webp",
                -- "*.avif"
            }, -- render image files as images when opened

            window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
            window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "snacks_notif", "scrollview", "scrollview_sign" },
            editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
        })
    end
}
