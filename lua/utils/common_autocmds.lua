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



--## [File]
----------------------------------------------------------------------



--## [Editing]
----------------------------------------------------------------------
--Prevent cursor left offseting when going from insert to normal mode
vim.api.nvim_create_autocmd("InsertLeave", {
    group = "UserAutoCmds",
    pattern = "*",
    callback = function()
        vim.cmd("normal! `^")
    end,
})

--Auto Trim trail spaces in Curr Buffer on save
vim.api.nvim_create_autocmd("BufWritePre", {
    group = "UserAutoCmds",
    pattern = "*",
    callback = function()
        if vim.bo.filetype == "markdown" then return end
        if
            vim.bo.modifiable         and
            vim.bo.buftype      == "" and
            vim.bo.buflisted          and
            not vim.bo.readonly
        then
            local ok, err = pcall(vim.cmd, "TrimTrailSpacesBuffer")
            if not ok then vim.notify("Trim failed: " .. err, vim.log.levels.WARN) end
        end
    end
})

--allow some type of yanking to go to sys clip
vim.api.nvim_create_autocmd("TextYankPost", {
    group = "UserAutoCmds",
    pattern = "*",
    callback = function()
        local op = vim.v.operator
        if op == "y" or op == "d" then
            vim.fn.setreg("+", vim.fn.getreg('"'))
        end
    end,
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


--## [View]
----------------------------------------------------------------------
--highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    group = "UserAutoCmds",
    pattern = "*",
    callback = function()
        --TODO IncSearch confilct with C-f
        --vim.highlight.on_yank({higroup='IncSearch', timeout = 200 })
        --vim.highlight.on_yank({higroup='Visual', timeout = 200 })
        vim.hl.on_yank({higroup = "IncSearch", timeout = 100})
    end,
})

--vim.api.nvim_create_autocmd({"OperatorPending"}, {
--    pattern = "*",
--    callback = function()
--        -- Save clipboard before operator runs
--        print("vim.fn.getreg('+')")

--    end
--})

--no gutter for terms
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



--revert search highlight
vim.api.nvim_create_autocmd('InsertEnter', {
    group = "UserAutoCmds",
    pattern = '*',
    callback = function()
        vim.defer_fn(function()
            if vim.v.hlsearch == 1 then
                vim.cmd('nohlsearch')
                --vim.api.nvim_feedkeys("\27", "n", false)
                --vim.cmd('startinsert')
            end
        end, 1)
    end,
})



--## [Buffers]
----------------------------------------------------------------------
--Smart enter Auto Insert when appropriate
vim.api.nvim_create_autocmd({"BufEnter"}, {
    group = "UserAutoCmds",
    pattern = "*",
    callback = function()
        if not vim.g.autostartinsert then return end

        vim.defer_fn(function() --delay to ensure correct buf properties detect
            local vbuf = vim.bo[vim.api.nvim_get_current_buf()]
            local ft   = vbuf.filetype
            local bt   = vbuf.buftype

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


