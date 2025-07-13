--------------------------------------------------
-- Edit --
--------------------------------------------------

local utils = require("utils.utils")
local v = vim


--## [General]
----------------------------------------------------------------------
--Smart start insert
vim.g.autostartinsert = true


--#[Virtual Edit]
vim.opt.virtualedit = "onemore" --allow to Snap cursor to closest char at eol
--"block" → Allows cursor to move where there is no actual text in visual block mode.
--"insert" → Allows inserting in positions where there is no actual text.
--"all" → Enables virtual editing in all modes.
--"onemore" → Allows the cursor to move one character past the end of a line.
--"none" → Default, disables virtual editing.

--Smart virt edit
vim.api.nvim_create_autocmd("ModeChanged", {
    group = "UserAutoCmds",
    pattern = "*",
    callback = function()
        local mode = vim.fn.mode()
        if mode == "n" or mode == "\22" then vim.opt.virtualedit = "all"     end
        if mode == "i"                  then vim.opt.virtualedit = "block"   end
        if mode == "v" or mode == "V"   then vim.opt.virtualedit = "onemore" end
    end,
})


--Define what a word is
vim.opt.iskeyword = "@,48-57,192-255,-,_"
-- @ -> alphabet,
-- 48-57 -> 0-9 numbers,
-- 192-255 -> extended Latin chars


--Backspace behaviour
vim.opt.backspace = { "indent", "eol", "start" }
--"indent" → Allows Backspace to delete auto-indent.
--"eol   " → Allows Backspace to delete past line breaks.
--"start"  → Allows Backspace at the start of insert mode.


--Smart autosave
vim.g.autosave_enabled = true

---@bool
local function file_was_saved_manually(path)
    if vim.fn.filereadable(path) == 1 then
        --A file can be readable fs_stat can still fail in some case:
        --Race condition: file was deleted after the readable check.
        --Permissions issues.
        --Path is a symlink to a broken target.
        local stat = vim.loop.fs_stat(path)

        if stat then
            local mtime = os.date("*t", stat.mtime.sec)
            local now   = os.date("*t")

            local was_saved_manually = mtime.year  == now.year  and
                                       mtime.month == now.month and
                                       mtime.day   == now.day
            return was_saved_manually
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



--[Undo]
vim.opt.undolevels = 2000

--Persistent undo
vim.opt.undofile = true

local undodir = vim.fn.stdpath("data") .. "/undo"

if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end

vim.opt.undodir = undodir

--autoclean undofiles for deleted files
--for name, _ in vim.fs.dir(undodir) do
--    local undo_path = undodir .. "/" .. name
--    local real_path = name:gsub("%%", "/")

--    if not vim.fn.filereadable(real_path) or vim.fn.isdirectory(real_path) == 1 then
--        os.remove(undo_path)
--    end
--end



--## [Spellcheck]
----------------------------------------------------------------------
vim.opt.spell = false
--vim.api.nvim_create_autocmd({ "FileType" }, {
--    pattern = { "markdown", "plaintext" },
--    callback = function()
--        vim.opt.spell = true
--    end,
--})

--vim.opt.spelllang = {
--    "en_us",
--    --"en_fr"
--}
--option.spelloptions:append("noplainbuffer") --no spelling for certain buftype



--## [Formating]
----------------------------------------------------------------------
local formatopts = {} --will hold all users formats opts
--View the current formatoptions with:
-- :set verbose=1 formatoptions?


--### Identation
vim.opt.autoindent  = true
vim.opt.smartindent = true  --Do smart autoindenting when starting a new line
--vim.opt.copyindent = true
--vim.opt.indentkeys = "0{,0},0),0],:,0#,!^F,o,O,e"
--A list of keys that, when typed in Insert mode, cause reindenting of
--the current line. Only happens if 'indentexpr' isn't empty.

vim.opt.expandtab   = true --Use spaces instead of tabs
vim.opt.shiftround  = true --always aligns to a multiple of "shiftwidth". Prevents "misaligned" indents.
vim.opt.shiftwidth  = 4 --Number of spaces to use for indentation
vim.opt.tabstop     = 4
vim.opt.softtabstop = 4 --Number of spaces to use for pressing TAB in insert mode

--##[Text Wrapping]
--"t" Auto-wrap text using textwidth (for non-comments).
--"w" Auto-wrap lines in insert mode, even without spaces.
--"v" Don't auto-wrap lines in visual mode.
--table.insert(formatopts, "t")
--table.insert(formatopts, "w")
vim.opt.textwidth = 80

--Visual only wraping
vim.opt.wrap        = false --word wrap off by default
vim.opt.breakindent = true --wrapped lines conserve whole block identation

--##[Paragraph & Line Formatting]
--"a"	Auto-format paragraphs as you type (very aggressive).
--"l"   on joins, Don’t break long lines in insert mode.
--"n"	Recognize numbered lists (1., 2., etc.) and format them properly.
--"2"	Use a two-space indent for paragraph continuation.
table.insert(formatopts, "n")

--##[Comments]
--"c" Auto-wrap comments using textwidth.
--"r" Continue comments when pressing <Enter> in insert mode.
--"o" Continue comments when opening a new line with o or O.
--"q" Allow gq to format comments.
--"j" Remove comment leaders when joining lines with J.
--"b" No automatic formatting in block comments.
table.insert(formatopts, "c")
table.insert(formatopts, "j")
table.insert(formatopts, "q")

--Force selected format options because it can be overwriten by other things
vim.api.nvim_create_autocmd({"FileType", "BufNewFile"}, {
    group = "UserAutoCmds",
    pattern = "*",
    callback = function()
        local ft = vim.bo.filetype
        if ft == "text" or ft == "markdown" then
            utils.insert_unique(formatopts, "t")
            utils.insert_unique(formatopts, "w")
        else
            for i = #formatopts, 1, -1 do
                if formatopts[i] == "t" then
                    table.remove(formatopts, i)
                end
            end
            for i = #formatopts, 1, -1 do
                if formatopts[i] == "w" then
                    table.remove(formatopts, i)
                end
            end

        end

        local fopts = table.concat(formatopts)
        vim.opt.formatoptions = fopts

    end,
})


