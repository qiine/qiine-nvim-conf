
local jrn = require("org.journal")

-- Open journal
vim.keymap.set({"i","n","v","t"}, "<M-S-F6>", function()
    jrn.open()
end)

vim.keymap.set({"i","n","v","t"}, "<S-Space>j", function()
    jrn.open()
end)

vim.keymap.set({"i","n","v","t"}, "<S-Space>oj", function()
    jrn.open()
end)

