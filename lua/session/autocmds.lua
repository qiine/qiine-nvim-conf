
-- # Autocmds


local ses = require("session")

vim.api.nvim_create_augroup('SessionGroup', { clear = true })

-- Smart auto save session
vim.api.nvim_create_autocmd({"VimLeavePre"}, {
    group = 'SessionGroup',
    pattern = '*',
    callback = function() ses.save() end,
})

