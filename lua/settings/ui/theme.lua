

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

--smart theme picking
if vim.fn.getenv("COLORTERM") == "truecolor" then
    vim.cmd("colorscheme "..col)
else
    vim.cmd("colorscheme ron")
end



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






--[Gutter]--------------------------------------------------
--vim.api.nvim_set_hl(0, "FoldColumn", { fg = "#ff8800", bg = "NONE" })


vim.api.nvim_set_hl(0, "IncSearch", { fg = "NONE", bg = "#bfbfbf", bold = false })


--ghost
vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { fg = "#999999", bg = "NONE"})



--[Term]--------------------------------------------------
----Set term buf background col
--vim.api.nvim_set_hl(0, "BufTermBackground", {fg = "#e0e0e0", bg = fg})
--vim.api.nvim_create_autocmd("TermOpen",
--{
--    group = vim.api.nvim_create_augroup("_terminal", { clear = true }),
--    callback = function()
--        vim.opt_local.winhighlight = "Normal:BufTermBackground"
--    end
--})

