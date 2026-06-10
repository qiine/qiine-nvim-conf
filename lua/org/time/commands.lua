
-- # time cmd

local time = require("org.time")

-- Insert current date and time
vim.api.nvim_create_user_command("Now", function()
    vim.api.nvim_put({ time.now() }, "c", false, false)
end, {})



