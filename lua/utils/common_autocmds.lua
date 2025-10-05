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



-- ## [Navigation]
----------------------------------------------------------------------
vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost"}, {
    group = "UserAutoCmds",
    callback = function()
        if vim.bo.filetype == "quickfix" then return end

        local gmarks = vim.fn.getmarklist()
        local lmarks = vim.fn.getmarklist(0)
        local marks = vim.list_extend(gmarks, lmarks)

        local items = {}

        for _, mark in ipairs(marks) do
            local pos = mark.pos
            if pos[2] > 0 then
                table.insert(items,
                {
                    filename = vim.api.nvim_buf_get_name(0),
                    lnum = pos[2],
                    col = pos[3],
                    text = "Mark: " .. mark.mark,
                })
            end
        end

        vim.fn.setloclist(0, items)
    end,
})



-- ## [Editing]
----------------------------------------------------------------------
-- Prevent cursor left offsetting when going from insert to normal mode and back to insert
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

            if ft == "help"
            or ft == "oil"
            then vim.cmd("stopinsert") return end

            if bt == "terminal" then vim.cmd("startinsert") return end

            -- ((bt == "" and vbuf.buflisted and vbuf.modifiable)
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
            -- vim.cmd("e none")
            -- vim.api.nvim_set_option_value("buftype", "nofile", {buf=0})
            -- vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
            -- vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})
            -- vim.api.nvim_set_option_value("modifiable", false, {buf=0})

            -- vim.opt_local.statuscolumn = ""
            -- vim.opt_local.signcolumn   = "no"
            -- vim.opt_local.number       = false
            -- vim.opt_local.foldcolumn   = "0"

            vim.cmd("Alpha")
            vim.cmd("stopinsert")
            -- vim.defer_fn(function()
            --     if vim.bo.filetype ~= "alpha" then
            --     end
            -- end, 5)
        end
    end,
})



