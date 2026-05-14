
-- # Commands


local sess = require("session")

vim.api.nvim_create_user_command("SessionSave", function()
    sess.save()
    print("Global session saved.")
end, {})

vim.api.nvim_create_user_command("SessionLoad", function()
    sess.load()
end, {})

vim.api.nvim_create_user_command("SessionEdit", function()
    vim.cmd("e "..sess.globalsess_path)
end, {})

vim.api.nvim_create_user_command("SessionClear", function()
    vim.fn.delete(sess.globalsess_path)
    print("Global session file cleared")
end, {})


