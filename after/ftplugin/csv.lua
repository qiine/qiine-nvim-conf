
--[.csv]
----------------------------------------------------------------------
-- Unbind indent inc
vim.keymap.set({"i","n","v"}, "<Tab>", "", {buffer=true})

-- Unbind indent decrease
vim.keymap.set({"i","n","v"}, "<S-Tab>", "", {buffer=true})

-- Clear line
vim.keymap.set({"i","n","v"}, "<S-BS>", function()
    local crs_pos = vim.api.nvim_win_get_cursor(0)[1]
    vim.cmd("silent! "..crs_pos..[[s/[^|]\+//g]])
    vim.cmd("noh")
end, {buffer=true})

-- Trigger csv
vim.cmd("CsvViewEnable")

