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
            vim.bo.modifiable       and
            vim.bo.buftype    == "" and
            vim.bo.buflisted        and
            not vim.bo.readonly
        then
            local ok, err = pcall(vim.cmd, "TrimCurrBufferTrailSpaces")
            if not ok then vim.notify("Trim failed: " .. err, vim.log.levels.WARN) end
        end
    end
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

-- TODO Disable confirmation for terminal buffers
--vim.api.nvim_create_autocmd("TermOpen", {
--    group = "UserAutoCmds",
--    pattern = "*",
--    callback = function()
--        vim.opt_local.confirm = false  -- Disable the confirm prompt for terminal buffers
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
            local bufnr = vim.api.nvim_get_current_buf()
            local ft = vim.bo.filetype

            if
                vim.bo[bufnr].buftype   == ""  and
                vim.bo[bufnr].modifiable       and
                vim.fn.buflisted(bufnr) == 1   and
                not ft:match("help")           and
                not ft:match("oil")
            then
                vim.cmd("startinsert")
            else
                vim.cmd("stopinsert")
            end
        end, 10)
    end,
})


