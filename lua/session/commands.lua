
-- # Commands


local ses = require("session")

vim.api.nvim_create_user_command("SessionSave", function()
    ses.save()
    print("Global session saved.")
end, {})

vim.api.nvim_create_user_command("SessionLoad", function()
    ses.load()
end, {})

vim.api.nvim_create_user_command("SessionEdit", function()
    vim.cmd("e "..ses.globalses_path)
end, {})

vim.api.nvim_create_user_command("SessionClear", function()
    vim.fn.delete(ses.globalses_path)
    print("Global session file cleared")
end, {})


