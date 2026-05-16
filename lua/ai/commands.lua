
local ed = require("ed")
local ai = require("ai")


vim.api.nvim_create_user_command("AIPrompt", function()
    ai.prompt_intr()
end, {})


