
-- # keymaps


vim.keymap.set({"i","n","v"}, "<S-M-a>", function()
    vim.cmd("vs | term")
    vim.cmd("vert res +10")

    vim.api.nvim_chan_send(vim.b.terminal_job_id, "piread\n")

    vim.cmd("startinsert")
end)

-- vim.keymap.set({"i","n","v","t"}, "<S-Space>a", "<cmd>CodeCompanionChat toggle<CR>")
vim.keymap.set({"i","n","v","t"}, "<M-w>va", "<cmd>CodeCompanionChat toggle<CR>")

-- open chat with agent and opencode
-- vim.keymap.set({"i","n","v","t"}, "<S-Space>a", "<cmd>CodeCompanionChat adapter=opencode<cr>", {})
-- vim.keymap.set({"i","n","v","t"}, "<S-Space>A", function()
--     local chat = require("codecompanion").last_chat()
--     if chat then
--         chat:change_adapter("opencode")
--     end
-- end)

vim.keymap.set({"i","n","v","t"}, "<S-Space>ax", "<cmd>CodeCompanionActions<CR>")

vim.keymap.set("v", "<S-Space>ae", function() require("codecompanion").prompt("explain") end)
vim.keymap.set("v", "<S-Space>af", function() require("codecompanion").prompt("fix") end)

-- Change model
vim.keymap.set({"i","n","v"}, "<leader>am", function()
    local chat = require("codecompanion").last_chat()
    if chat then
        chat:change_model({ model = "Qwen3.5-35B-A3B-UD-IQ4_NL" })
    end
end)

-- vim.keymap.set({"i","n","v"}, "<leader>as", function()
--     local config = require("codecompanion.config")
--     local current = config.display.chat.show_settings
--     config.display.chat.show_settings = not current

--     local chat = require("codecompanion").last_chat()
--     if chat then chat.ui:refresh() end
-- end)


