
-- gitmessage --


local lsnip = require("luasnip")


-- Auto insert
vim.cmd("startinsert")


-- Gutter
vim.opt_local.statuscolumn = ""
vim.opt_local.signcolumn   = "no"
vim.opt_local.number       = false

vim.opt_local.foldcolumn = "0"
vim.opt_local.foldenable = false  -- Actual folds icons in gutter


-- Edits
vim.opt_local.spell = true
vim.opt.formatoptions:append("t") -- auto wrap

vim.keymap.set("ia", "fe",  "feat:", {buffer=true})
vim.keymap.set("ia", "ch",  "chore:", {buffer=true})

-- vim.keymap.set({"i","n","v"}, "<C-S-n>h", function()
--     lsnip.insert_snippet("heading")
-- end, {buffer = true})

