
--[.csv]
----------------------------------------------------------------------
-- Unbind indent inc
vim.keymap.set({"i","n","v"}, "<Tab>", "", {buffer=true})

-- Unbind indent decrease
vim.keymap.set({"i","n","v"}, "<S-Tab>", "", {buffer=true})

-- Trigger csv
vim.cmd("CsvViewEnable")

