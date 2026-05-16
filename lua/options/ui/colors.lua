
-- # Colors


-- ## [Colorscheme]

--newpaper
--kanagawa
--e-ink
--github_light_high_contrast
--local colorscheme = 'tokyonight'
--colorscheme tokyonight
--colorscheme tokyonight-night
--colorscheme tokyonight-storm
--colorscheme tokyonight-day


local col = "dayfox"

-- Smart theme picking

vim.api.nvim_create_autocmd("UIEnter", {
    callback = function()

        vim.schedule(function()
            vim.cmd("colorscheme "..col)

            local ui = vim.api.nvim_list_uis()[1]

            if not ui.rgb then
                -- vim.opt.termguicolors = false
                vim.cmd("colorscheme ron")
            end
        end)
    end
})


-- ## Wins
-- Make float win same bg reg win
vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })

-- Define a highlight group for URLs
vim.api.nvim_set_hl(0, "MyUrl", { fg = "#6aafc1", bold = true })


--[Bufferline]--------------------------------------------------
--no bold tab bar title
--vim.api.nvim_set_hl(0, "BufferCurrent", { bold = false })
--vim.api.nvim_set_hl(0, "BufferCurrentMod", { bold = false })
--
--vim.api.nvim_set_hl(0, "BufferVisible", { bold = false })
--vim.api.nvim_set_hl(0, "BufferVisibleMod", { bold = false })
--
--vim.api.nvim_set_hl(0, "BufferInactive", { bold = false })
--vim.api.nvim_set_hl(0, "BufferInactiveMod", { bold = false })






-- [Gutter]
----------------------------------------------------------------------
--vim.api.nvim_set_hl(0, "FoldColumn", { fg = "#ff8800", bg = "NONE" })



--ghost
vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { fg = "#999999", bg = "NONE"})


-- vim.api.nvim_create_autocmd("TermOpen", {
--     callback = function()
--         local win = vim.api.nvim_get_current_win()
    --
--         vim.api.nvim_set_hl(0, "TermBlack", { bg = "#333333" })
--
--         vim.api.nvim_set_option_value("winhighlight", "Normal:TermBlack", {win=win})
--     end,
-- })


