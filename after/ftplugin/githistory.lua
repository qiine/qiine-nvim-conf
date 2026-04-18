
-- githistory --


-- ## [Gutter]
----------------------------------------------------------------------
vim.opt_local.statuscolumn = ""
vim.opt_local.signcolumn   = "no"
vim.opt_local.number       = false

-- ### Folds
vim.opt_local.foldenable = false  -- Actual folds icons in gutter
vim.opt_local.foldcolumn = "1"
vim.opt_local.foldlevel = 0

vim.opt_local.foldmethod = 'expr' -- manual, expr
function _G.foldexpr_githist()
    local line = vim.fn.getline(vim.v.lnum)

    if line:match("^*") then return ">1" end
    -- if line:match("^| ") then return "2" end
    -- if line:match("^ ") then return "2" end

    return "="
end
vim.opt_local.foldexpr = "v:lua.foldexpr_githist()"

vim.cmd("norm! zM") -- force fold

-- vim.opt_local.foldtext = "v:lua.FoldedText()"
-- function FoldedText()
--     local line = vim.fn.getline(vim.v.foldstart)
--     return ""
-- end


vim.api.nvim_create_autocmd('BufWinEnter', {
    group = 'UserAutoCmds',
    pattern = '*',
    callback = function()
        vim.cmd("norm! gg0") -- ensure curso placed top left of buf
    end,
})

-- ## [Edits]
vim.opt_local.spell = false



-- [Keymaps]




