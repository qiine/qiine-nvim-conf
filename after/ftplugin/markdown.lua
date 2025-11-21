
-- Markdown --


local lsnip = require("luasnip")


vim.opt_local.spell = true


-- [Gutter]
vim.opt_local.signcolumn = "no"

-- Numbers
-- vim.opt_local.number = false

-- folds
vim.opt_local.foldcolumn = "1"
vim.opt_local.foldenable = true

vim.opt_local.foldmethod = "expr" -- indent, manual
function _G.foldexpr_md()
    local line = vim.fn.getline(vim.v.lnum)

    -- if line:match("^%s+") then
    --     return "s1"
    -- end

    if line:match("^##") then return ">1" end
    if line:match("^###") then return ">2" end
    if line:match("^####") then return ">3" end

    if line:match("^%*") then
        return "a1"
    end

    if line:match("^%``") then
        return "a1"
    end

    -- Default: inherit previous fold level
    return "="
end
vim.opt_local.foldexpr = "v:lua.foldexpr_md()"



-- [Format]
-- vim.opt.formatoptions:append("a") -- auto reformat paragraphs while typing
vim.opt_local.formatoptions:append("t") -- auto-wrap text at textwidth
vim.opt_local.formatoptions:append("n") -- Recognize numbered lists (1., 2., etc.) and format them properly.

-- Indentation
vim.opt_local.shiftwidth  = 2 --Number of spaces to use for indentation
vim.opt_local.tabstop     = 2
vim.opt_local.softtabstop = 2 --Number of spaces to use for pressing TAB in insert mode


-- [Keymaps]
vim.keymap.set({"i","n","x"}, "<C-S-n>h", function()
    lsnip.insert_snippet("heading")
end, {buffer = true})

vim.keymap.set({"i","n","x"}, "<C-S-n>cb", function()
    lsnip.insert_snippet("codeblock")
end, {buffer = true})

vim.keymap.set({"i","n","x"}, "<C-S-n>tb", function()
    lsnip.insert_snippet("pipetable")
end, {buffer = true})

-- Insert note
vim.keymap.set({"i","n","x"}, "<C-S-n>n", function()
    lsnip.insert_snippet("note")
end, {buffer=true})

-- Insert task
vim.keymap.set({"i","n","x"}, "<C-S-n>t", function()
    lsnip.insert_snippet("task")
end, {buffer = true})



