
-- # keymaps


vim.keymap.set({"i","n","v"}, "<S-M-a>", function()
    vim.cmd("vs | term")
    vim.cmd("vert res +10")

    vim.api.nvim_chan_send(vim.b.terminal_job_id, "piread\n")

    vim.cmd("startinsert")
end)

-- vim.keymap.set({"i","n","v","t"}, "<S-Space>a", "<cmd>CodeCompanionChat toggle<CR>")


vim.keymap.set("v", "<S-Space>ae", function() require("codecompanion").prompt("explain") end)
vim.keymap.set("v", "<S-Space>af", function() require("codecompanion").prompt("fix") end)

