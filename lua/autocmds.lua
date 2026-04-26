----------------------------------------------------------------------
-- User autocmds --
----------------------------------------------------------------------

local utils = require("utils")

local v = vim
-----------------------------------

--Why use augroup?
--Without an augroup, every time Neovim config is reloaded, a new autocommand is created.
--The augroup ensures old autocommand are removed before adding new
vim.api.nvim_create_augroup('UserAutoCmds', { clear = true })



-- ## [File]
----------------------------------------------------------------------


-- ## [Navigation]
----------------------------------------------------------------------



-- ## [Editing]
----------------------------------------------------------------------
--local conf = vim.fn.stdpath('config')
---- TODO Autocommand to reload the configuration when any file in the config directory is saved
--vim.api.nvim_create_autocmd('BufWritePost', {
--    group = 'UserAutoCmds',
--    pattern = conf .. '/*',
--    callback = function()
--        local curfile = vim.fn.expand("%:p")
--
--        if curfile:find(conf, 1, true) then
--            vim.cmd('source ' .. conf .. '/init.lua')
--            vim.cmd("echo '-Config reloaded-'")
--        end
--    end,
--})


-- ## [View]
----------------------------------------------------------------------



-- ## [Buffers]
----------------------------------------------------------------------
vim.api.nvim_create_autocmd('TermOpen', {
    group   = 'UserAutoCmds',
    command = "startinsert",
})

vim.api.nvim_create_autocmd('BufEnter', {
    group   = 'UserAutoCmds',
    pattern = "/tmp/bash%-fc.*",
    callback = function()
        vim.keymap.set({"i","n","v","c"}, "<C-S-CR>", "ZZ", {buffer=true})
        vim.keymap.set({"i","n","v","c"}, "<M-Left>", "<Left>", {buffer=true})
    end
})





