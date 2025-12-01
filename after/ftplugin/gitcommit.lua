
-- gitcommit --

local lsnip = require("luasnip")


-- ## Gutter
vim.opt_local.statuscolumn = ""
vim.opt_local.signcolumn   = "no"
vim.opt_local.number       = false

-- ### Folds
vim.opt_local.foldenable   = true  -- Actual folds icons in gutter
vim.opt_local.foldcolumn   = "1"

vim.opt_local.foldlevelstart = 0
vim.opt_local.foldlevel = 0

vim.opt_local.foldmethod = 'expr' -- manual, expr
function _G.foldexpr_gitcommit()
    local line = vim.fn.getline(vim.v.lnum)

    if line:match("^# Changes not staged for commit:") then return ">1" end
    if line:match("^# Untracked files:") then return ">1" end

    if line:match("^@@") then return ">1" end
    -- elseif line:match("^%+") or line:match("^%-") or line:match("^ ") then

    return "="
end
vim.opt_local.foldexpr = "v:lua.foldexpr_gitcommit()"


vim.api.nvim_create_autocmd('BufWinEnter', {
    group = 'UserAutoCmds',
    pattern = '*',
    callback = function()
        vim.cmd("norm! zM")
        vim.cmd("norm! gg0") -- ensure to top left of buff
    end,

})

-- ## [Edits]
-- Auto insert
vim.cmd("startinsert")

vim.opt_local.spell = true
vim.opt_local.formatoptions:append("t") -- auto wrap



-- [Keymaps]
-- Submit
vim.keymap.set({"i","n","v","c"}, "<C-S-CR>", "ZZ", {buffer=true})

-- Avoid mapping collisions in nested nvim inst
vim.keymap.set({"i","n","v","t"}, "<C-e>", "<Cmd>norm!$<CR>", {buffer=true})
vim.keymap.set({"i","n","v","t"}, "<C-a>", "<Cmd>norm!0<CR>", {buffer=true})

-- ### Quick snippets
vim.keymap.set({"i","n","x"}, "<C-S-n>f", function()
    lsnip.insert_snippet("feat")
end, {buffer = true})

vim.keymap.set({"i","n","x"}, "<C-S-n>ft", function()
    lsnip.insert_snippet("fix typo")
end, {buffer = true})

-- abbrev
vim.keymap.set("ia", "fe",  "feat:",  {buffer=true})
vim.keymap.set("ia", "ch",  "chore:", {buffer=true})

vim.keymap.set("ia", "upd", "update", {buffer=true})

vim.keymap.set({"i","n","v"}, "<C-S-n>h", function()
    lsnip.insert_snippet("heading")
end, {buffer = true})




