
-- # keymaps


vim.keymap.set({"i","n","v"}, "<S-M-a>", function()
    vim.cmd("vs")
    vim.cmd("vert res +11")

    vim.cmd("silent term piwrap")

    vim.cmd("startinsert")
end)

vim.keymap.set({"i","n","v","t"}, "<M-C-S-A>", function()
    vim.cmd("tabnew")

    vim.cmd("silent term piwrap")

    vim.cmd("startinsert")
end)

-- vim.keymap.set({"i","n","v","t"}, "<S-Space>a", "<cmd>CodeCompanionChat toggle<CR>")


vim.keymap.set("v", "<S-Space>ae", function() require("codecompanion").prompt("explain") end)
vim.keymap.set("v", "<S-Space>af", function() require("codecompanion").prompt("fix") end)

