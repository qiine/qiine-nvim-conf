
-- text --

local lsnip = require("luasnip")



--view
vim.opt_local.signcolumn = "no"
vim.opt_local.number = false

-- folds
vim.api.nvim_set_hl(0, "Folded", { link = "Normal" })

--edits
vim.opt_local.spell = true


-- format
vim.o.shiftwidth  = 2    -- Number of spaces to use for indentation
vim.o.tabstop     = 2    -- Show a tab as this number of spaces
vim.o.softtabstop = 2    -- Number of spaces to use when pressing TAB

-- vim.opt_local.formatoptions:append("a") -- auto reformat paragraphs while typing
vim.opt_local.formatoptions:append("t") -- auto-wrap text at textwidth


-- [keymaps]
-- Insert task
vim.keymap.set({"i","n","x"}, "<C-S-n>t", function()
  lsnip.insert_snippet("task")
end, {buffer = true})



