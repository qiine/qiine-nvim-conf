----------------------------------------------------------------------
-- User autocmds --
----------------------------------------------------------------------

local utils = require("utils.utils")

local v = vim
-----------------------------------

--Why use augroup?
--Without an augroup, every time Neovim config is reloaded, a new autocommand is created.
--The augroup ensures old autocommand are removed before adding new
vim.api.nvim_create_augroup('UserAutoCmds', { clear = true })



-- ## [File]
----------------------------------------------------------------------



-- ## [Editing]
----------------------------------------------------------------------
-- Prevent cursor left offsetting when going from insert to normal mode
vim.api.nvim_create_autocmd("InsertLeave", {
    group = "UserAutoCmds",
    command = "norm! `^",
})


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
-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    group = "UserAutoCmds",
    pattern = "*",
    callback = function()
        vim.hl.on_yank({higroup = 'IncSearch', timeout = 200})
    end,
})


-- No gutter for terms
vim.api.nvim_create_autocmd('TermOpen', {
    group    = 'UserAutoCmds',
    pattern  = '*',
    callback = function()
        vim.opt_local.statuscolumn   = ""
        vim.opt_local.signcolumn     = "no"
        vim.opt_local.number         = false
        vim.opt_local.relativenumber = false
        vim.opt_local.foldcolumn     = "0"
    end,
})

vim.api.nvim_create_autocmd('DirChanged', {
    group = 'UserAutoCmds',
    callback = function()
        print(vim.fn.getcwd())
    end,
})



-- ## [Buffers]
----------------------------------------------------------------------
-- Smart enter Auto Insert when appropriate
vim.api.nvim_create_autocmd({"BufEnter"}, {
    group = "UserAutoCmds",
    pattern = "*",
    callback = function()
        if not vim.g.autostartinsert then return end

        vim.defer_fn(function() --delay to ensure correct buf properties detect
            local vbuf = vim.bo[vim.api.nvim_get_current_buf()]
            local ft   = vim.bo.filetype
            local bt   = vim.bo.buftype

            if
                ((bt == "" and vbuf.buflisted and vbuf.modifiable)
                or bt == "terminal") and

                not ft:match("help") and
                not ft:match("oil")
            then
                vim.cmd("startinsert")
            else
                vim.cmd("stopinsert")
            end
        end, 5)
    end,
})

-- override last buffer
vim.api.nvim_create_autocmd('BufDelete', {
    group = 'UserAutoCmds',
    pattern = '*',
    callback = function()
        local bufs = vim.tbl_filter(function(buf)
            return vim.api.nvim_buf_is_loaded(buf)
            and vim.bo[buf].buflisted
        end, vim.api.nvim_list_bufs())

        if #bufs == 1 and vim.api.nvim_buf_get_name(bufs[1]) == "" then
            vim.cmd("e none")
            vim.api.nvim_set_option_value("buftype", "nofile", {buf=0})
            vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
            vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})
            vim.api.nvim_set_option_value("modifiable", false, {buf=0})

            vim.opt_local.statuscolumn = ""
            vim.opt_local.signcolumn   = "no"
            vim.opt_local.number       = false
            vim.opt_local.foldcolumn   = "0"
            -- vim.cmd("Alpha")
        end
    end,
})



