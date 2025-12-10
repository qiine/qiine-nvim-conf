----------------------------------------------------------------------
-- [Edit] --
----------------------------------------------------------------------

local utils = require("utils")
local fs    = require("fs")
local bufrs = require("bufrs")

local v = vim


-- ## [General]
----------------------------------------------------------------------
-- Backspace behaviour
vim.opt.backspace = { "indent", "eol", "start" }
--"indent" -- Allows Backspace to delete auto-indent.
--"eol   " -- Allows Backspace to delete past line breaks.
--"start"  -- Allows Backspace at the start of insert mode.

vim.o.nrformats = "bin,hex,alpha"
-- This defines what bases Vim will consider for numbers when using the
-- CTRL-A and CTRL-X commands for adding to and subtracting from a number

-- Avoid insert when relevant
vim.api.nvim_create_autocmd('BufEnter', {
    group   = 'UserAutoCmds',
    callback = function()
        vim.defer_fn(function()
            if vim.bo.filetype == "alpha" then
                if not vim.o.modifiable then vim.cmd('stopinsert') end
            end
        end, 1)
    end,
})

-- Prevent cursor left offsetting when alterning insert/normal/insert.. (only with i)
vim.api.nvim_create_autocmd("InsertLeave", {
    group = "UserAutoCmds",
    command = "norm! `^",
})

-- go to last loc when opening a Buffer
vim.api.nvim_create_autocmd("BufReadPost", {
    group = "UserAutoCmds",
    callback = function()
        if vim.bo.buftype == "" then
            local mark = vim.api.nvim_buf_get_mark(0, '"')
            local lcount = vim.api.nvim_buf_line_count(0)
            if mark[1] > 0 and mark[1] <= lcount then
                pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
        end
    end,
    desc = "go to last loc when opening a Buffer",
})



-- ## [File]
----------------------------------------------------------------------
-- Smart autosave
vim.g.autosave_enabled = true
vim.g.autosave_delay = 500000

if vim.g.autosave_enabled then
    local timer_autosave = vim.uv.new_timer()
    timer_autosave:start(vim.g.autosave_delay, vim.g.autosave_delay, vim.schedule_wrap(function()
        if vim.g.autosave_enabled then
            bufrs.save_buffers()
        else
            timer_autosave:stop()
            timer_autosave:close()
        end
    end))
end

-- Pre-process file before saving
-- Auto Trim trail spaces in Curr Buffer on save
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
            local ok, err = pcall( function() vim.cmd("TrimTrailSpacesBuffer") end)
            if not ok then vim.notify("Trim failed: " .. err, vim.log.levels.WARN) end
        end
    end
})




-- ## [Undo]
----------------------------------------------------------------------
vim.o.undolevels = 2000

-- Persistent undo
vim.o.undofile = true

local undodir = vim.fn.stdpath("data") .. "/undo"

if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end

vim.o.undodir = undodir

--autoclean undofiles for deleted files
--for name, _ in vim.fs.dir(undodir) do
--    local undo_path = undodir .. "/" .. name
--    local real_path = name:gsub("%%", "/")

--    if not vim.fn.filereadable(real_path) or vim.fn.isdirectory(real_path) == 1 then
--        os.remove(undo_path)
--    end
--end



-- ## [Formatting]
----------------------------------------------------------------------
vim.o.textwidth = 80

-- Visual only wraping
vim.o.wrap        = false --word wrap off by default
vim.o.breakindent = true --wrapped lines conserve whole block identation

-- vim.o.commentstring = "-- %s"


-- ### Indentation
vim.o.expandtab   = true -- Use spaces instead of tabs

vim.o.shiftwidth  = 4    -- Number of spaces to use for indentation
vim.o.tabstop     = 4    -- Show a tab as this number of spaces
vim.o.softtabstop = 4    -- Number of spaces to use when pressing TAB

vim.o.shiftround  = true -- always aligns to a multiple of "shiftwidth". Prevents "misaligned" indents.

vim.o.autoindent  = true -- keep indent of prev line when making a new one
vim.o.smartindent = true -- simple syntax-aware indent on top of autoindent for certain langs.
-- vim.opt.copyindent = true
-- vim.opt.indentkeys = "0{,0},0),0],:,0#,!^F,o,O,e"
-- A list of keys that, when typed in Insert mode, cause reindenting of
-- the current line. Only happens if 'indentexpr' isn't empty.


-- Will hold all users formats opts
-- View current formatoptions with:
-- ':set verbose=1 formatoptions?'
local formopts =
{
    -- Text Wrapping
    -- "t", Auto-wrap text using textwidth (for non-comments).
    -- "w", Auto-wrap lines in insert mode, even without spaces.
    -- "v", Don't auto-wrap lines in visual mode.

    -- Paragraph & Line Formatting
    -- "a", -- Auto-format paragraphs as you type (very aggressive).
    "l", -- on joins, Don’t break long lines in insert mode.
    -- "n", -- Recognize numbered lists (1., 2., etc.) and format them properly.
    -- "2", -- Use a two-space indent for paragraph continuation.

    -- Comments
    "c", -- Auto-wrap comments using textwidth.
    "r", -- Continue comments when pressing <Enter> in insert mode.
    -- "o", -- Continue comments when opening a new line with o or O.
    "q", -- Allow gq to format comments.
    "j", -- Remove comment leaders when joining lines with J.
    "b", -- No automatic formatting in block comments.
}
vim.o.formatoptions = table.concat(formopts)

-- hack bypass ftplugin/lua.vim settings
vim.api.nvim_create_autocmd("FileType", {
    group = "UserAutoCmds",
    command = "set formatoptions-=o",
})



