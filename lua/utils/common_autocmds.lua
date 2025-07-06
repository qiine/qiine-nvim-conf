----------------------------------------------------------------------
-- User autocmds --
----------------------------------------------------------------------

local utils = require("utils.utils")

local v    = vim
local vcmd = vim.cmd
local vap  = vim.api
local vfn  = vim.fn
-----------------------------------

--Why use augroup?
--Without an augroup, every time Neovim config is reloaded, a new autocommand is created.
--The augroup ensures old autocommand are removed before adding new
vim.api.nvim_create_augroup('UserAutoCmds', { clear = true })



--[File]--------------------------------------------------
--TODO Auto save all buff if manually saved at least once
--vim.api.nvim_create_autocmd('TabLeave', {



--[Editing]--------------------------------------------------
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
            vim.bo.buftype == "" and
            vim.bo.modifiable and
            not vim.bo.readonly
        then
            vim.cmd("TrimCurrBufferTrailSpaces")
        end
    end
})


--TODO prevent closing tab if unsaved buffs
local function check_unsaved_buffers()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local bufnr = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_get_option(bufnr, 'modified') then
            return true
        end
    end
    return false
end
vim.api.nvim_create_autocmd('TabLeave', {
    group = 'UserAutoCmds',
    pattern = '*',
    callback = function ()
        --print(check_unsaved_buffers)
        --if check_unsaved_buffers() then
        --    local choice = vim.fn.confirm("unsaved changes, save before closing?", "&Yes\n&No\n&Cancel", 3)
        --    if choice == 1 then
        --        vim.cmd('wall') --save all buffs
        --        vim.cmd('tabclose')
        --        return
        --    elseif choice == 2 then
        --        vim.cmd('tabclose!')
        --        return
        --    else
        --        print("Tab close cancelled")
        --        return
        --    end
        --else
        --    vim.cmd('tabclose') --No unsaved buffs closing
        --end
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

-- TODO Disable confirmation for terminal buffers
--vim.api.nvim_create_autocmd("TermOpen", {
--    group = "UserAutoCmds",
--    pattern = "*",
--    callback = function()
--        vim.opt_local.confirm = false  -- Disable the confirm prompt for terminal buffers
--    end,
--})




--[View]--------------------------------------------------
--highlight yanked text
vim.api.nvim_create_augroup("highlight_yank", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    group = "highlight_yank",
    pattern = "*",
    callback = function()
        --TODO IncSearch confilct with C-f
        --vim.highlight.on_yank({higroup='IncSearch', timeout = 200 })
        (vim.hl or vim.highlight).on_yank()
    end,
})

--Auto disable any search highlight on enter insert
vim.api.nvim_create_autocmd('InsertEnter', {
    group = "UserAutoCmds",
    pattern = '*.*',
    callback = function()
        vim.defer_fn(function()
        vim.cmd('nohlsearch')
        end, 1) --slight dealay otherwise won't work? (milliseconds)
    end,
})



--[Buffers]--------------------------------------------------
--Smart enter Auto Insert when appropriate
vim.api.nvim_create_autocmd({"BufEnter", "BufRead", "BufNewFile"}, {
    group = "UserAutoCmds",
    pattern = "*",
    callback = function()
        if not vim.g.autostartinsert then return end

        local buftype = vim.bo.buftype
        local ft = vim.bo.filetype
        ft = string.lower(ft)

        if
            ft == "oil" or
            utils.string_contains(ft, "dashboard") or
            utils.string_contains(ft, "alpha") or
            utils.string_contains(ft, "neo") or
            utils.string_contains(ft, "trouble")
        then vim.cmd("stopinsert") return end

        if buftype == "" then vim.cmd("startinsert") end
    end,
})


vim.api.nvim_create_autocmd({ "CmdwinEnter" }, {
    callback = function()
        vim.keymap.set("n", "<esc>", ":quit<CR>", { buffer = true })
    end,
})



