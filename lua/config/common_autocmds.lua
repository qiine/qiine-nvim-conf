----------------------------------
-- User autocmds --
-----------------------------------

local utils = require("utils.utils")

local vcmd = vim.cmd
local vap = vim.api
local vfn = vim.fn
-----------------------------------

--Why use augroup?
--Without an augroup, every time Neovim config is reloaded, a new autocommand is created.
--The augroup ensures old autocommand are removed before adding new
vim.api.nvim_create_augroup('UserAutoCmds', { clear = true })


-- vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"},
-- {
--     group = "UserAutoCmds",
--
--     callback = function()
--
--     local line, col = unpack(vim.api.nvim_win_get_cursor(0))
--     local current_line = vim.api.nvim_get_current_line()
--
--     --Ensure `col` is within valid range
--     if col < 1 or col > #current_line then
--         return
--     end
--
--     -- Check both left and right of cursor
--     local char_left = current_line:sub(col - 1, col - 1)
--     local char_right = current_line:sub(col, col)
--
--     -- Clear previous matches
--     vim.fn.matchdelete(99)
--
--     -- Check if either side of the cursor is a bracket
--     if char_left:match("[{}%[%]()]") or char_right:match("[{}%[%]()]") then
--         vim.fn.matchadd("MatchParen", vim.fn.matchadd("MatchParen", [[{}\[\]()<>]] ) -- Fix pattern
--         else
--             vim.cmd("match none") -- Remove highlight if not inside brackets
--         end
--     end,
-- })

--Prevent normal mode cursor left offseting
vim.api.nvim_create_autocmd("InsertLeave", {
    group = "UserAutoCmds",
    pattern = "*",
    callback = function()
        vim.cmd("normal! `^")
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

--TODO Auto save all buff if manually saved at least once
--vim.api.nvim_create_autocmd('TabLeave', {


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
        print(check_unsaved_buffers)
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

--default save loc and name
--TODO create unique name each time
vim.api.nvim_create_autocmd('BufWriteCmd', {
    group = "UserAutoCmds",

    pattern = '[No Name]',
    callback = function()
        local default_path = vim.fn.expand('~/Desktop')
        local default_filename = 'new_text.txt'

        if vim.fn.bufname('%') == '' then
            vim.cmd('file ' .. default_path .. '/' .. default_filename)
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

-- TODO Disable confirmation for terminal buffers
--vim.api.nvim_create_autocmd("TermOpen", {
--    group = "UserAutoCmds",
--    pattern = "*",
--    callback = function()
--        vim.opt_local.confirm = false  -- Disable the confirm prompt for terminal buffers
--    end,
--})

--highlight yanked text
vim.api.nvim_create_augroup("highlight_yank", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    group = "highlight_yank",
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({higroup='IncSearch', timeout = 200 })
    end,
})

---TODO highlight pastae text
--vim.api.nvim_create_augroup("highlight_yank_paste", { clear = true })
--vim.api.nvim_create_autocmd("TextChanged", {
--    group = "highlight_yank_paste",
--    pattern = "*",
--    callback = function()
--        vim.highlight.on_yank({higroup='IncSearch', timeout = 200 })
--        print("woow yanking")
--    end,
--})
--

-- Auto go into normal mode when Neotree gains focus
vim.api.nvim_create_autocmd("BufEnter", {
    group = "UserAutoCmds",
    pattern = "*",
    callback = function()
        if vim.bo.filetype == "neo-tree" then
            vap.nvim_feedkeys(vap.nvim_replace_termcodes("<Esc>", true, true, true), "n", true)
        end
    end
})

--[Buffers]
--Smart Auto start in Insert mode when appropriate
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        if not vim.g.buffenter_startinsert then return end
        
        local buftype = vim.bo.buftype
        local ft = vim.bo.filetype
        if buftype == "" and ft ~= "oil" then --Regular buffers have an empty 'buftype'
            vim.cmd("startinsert")
        end
    end,
})

