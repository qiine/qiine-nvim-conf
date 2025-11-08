----------------------------------------------------------------------
-- [Edit] --
----------------------------------------------------------------------

local utils = require("utils.utils")
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



-- ## [File]
----------------------------------------------------------------------
-- Smart autosave
vim.g.autosave_enabled = true

---@return boolean
local function file_was_saved_manually(path)
    if vim.fn.filereadable(path) == 1 then
        --A file can be readable but fs_stat can still fail in some case:
        -- - Race condition: file was deleted after the readable check.
        -- - Permissions issues.
        -- - Path is a symlink to a broken target.
        local stat = vim.uv.fs_stat(path)

        if stat then
            local mtime = os.date("*t", stat.mtime.sec)
            local now   = os.date("*t")

            local was_saved_manually = mtime.year  == now.year  and
                                       mtime.month == now.month and
                                       mtime.day   == now.day
            return was_saved_manually
        else
            return false
        end
    else
        return false
    end
end

local function save_buffers()
    for _, buf in ipairs(v.api.nvim_list_bufs()) do
        local bufname = v.api.nvim_buf_get_name(buf)

        if v.api.nvim_buf_is_loaded(buf) and v.fn.filereadable(bufname) == 1 then
            --nvim_buf_call Ensure proper bufs info
            v.api.nvim_buf_call(buf, function()
                if v.bo.modifiable and not v.bo.readonly and v.bo.buftype == "" then
                    if file_was_saved_manually then
                        v.cmd("silent! write") --we can safely write
                        --print("autosaved: " .. bufname)
                    end
                end
            end)
        end
    end
end

local timer_autosave = vim.loop.new_timer()
timer_autosave:start(420000, 420000, vim.schedule_wrap(function ()
    if vim.g.autosave_enabled then
        save_buffers()
    else
        timer_autosave:stop()
        timer_autosave:close()
    end
end))

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
            local ok, err = pcall(vim.cmd, "TrimTrailSpacesBuffer")
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


