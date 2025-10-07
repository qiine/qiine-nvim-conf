
-- [.md]
----------------------------------------------------------------------
local lsnip = require("luasnip")


vim.opt_local.spell = true


-- [Gutter]
vim.opt_local.signcolumn = "no"

-- Numbers
vim.opt_local.number = false

-- folds
vim.opt_local.foldcolumn = "1"
vim.opt_local.foldenable = true


-- [Format]
--Tab
vim.opt_local.shiftwidth  = 2 --Number of spaces to use for indentation
vim.opt_local.tabstop     = 2
vim.opt_local.softtabstop = 2 --Number of spaces to use for pressing TAB in insert mode


-- [Keymaps]
vim.keymap.set({"i","n","v"}, "<C-S-n>h", function()
    lsnip.try_insert_snippet("heading")
end)

vim.keymap.set({"i","n","v"}, "<C-S-n>cb", function()
    lsnip.try_insert_snippet("codeblock")
end)

vim.keymap.set({"i","n","v"}, "<C-S-n>tb", function()
    lsnip.try_insert_snippet("pipetable")
end)

-- Insert task
vim.keymap.set({"i","n","v"}, "<C-S-n>t", function()
    lsnip.try_insert_snippet("task")
end)

