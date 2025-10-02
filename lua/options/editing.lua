--------------------------------------------------
-- Edit --
--------------------------------------------------

local utils = require("utils.utils")
local v = vim


-- ## [General]
----------------------------------------------------------------------
-- Smart start insert
vim.g.autostartinsert = true


-- Define what a word is
vim.opt.iskeyword = "@,48-57,192-255,-,_"
-- @       -> alphabet,
-- 48-57   -> 0-9 numbers,
-- 192-255 -> extended Latin chars


-- Backspace behaviour
vim.opt.backspace = { "indent", "eol", "start" }
--"indent" -- Allows Backspace to delete auto-indent.
--"eol   " -- Allows Backspace to delete past line breaks.
--"start"  -- Allows Backspace at the start of insert mode.



-- ## [Nav]
----------------------------------------------------------------------
-- Virtual Edit
vim.opt.virtualedit = "none" --allow to Snap cursor to closest char at eol
-- "none"    -- Default, disables virtual editing.
-- "onemore" -- Allows the cursor to move one character past the end of a line.
-- "block"   -- Allows cursor to move where there is no actual text in visual block mode.
-- "insert"  -- Allows inserting in positions where there is no actual text.
-- "all"     -- Enables virtual editing in all modes.

vim.api.nvim_create_autocmd("ModeChanged", {
    group = "UserAutoCmds",
    pattern = "*",
    callback = function()
        local mode = vim.fn.mode()
        if mode == "n"  then vim.opt.virtualedit = "all"     return end
        if mode == "i"  then vim.opt.virtualedit = "none"    return end
        if mode == "v"  then vim.opt.virtualedit = "onemore" return end
        if mode == "V"  then vim.opt.virtualedit = "onemore" return end
        if mode == "" then vim.opt.virtualedit = "block"   return end
    end,
})

-- define % motion /matching/
vim.opt.matchpairs:append({"<:>"})



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

-- Handle Large file
vim.api.nvim_create_autocmd('BufReadPost', {
    group = 'UserAutoCmds',
    callback = function(args)
        if vim.b[args.buf].is_bigfile then
            vim.cmd("BigfileMode")
        end
    end,
})



-- ## [Undo]
----------------------------------------------------------------------
vim.opt.undolevels = 2000

-- Persistent undo
vim.opt.undofile = true

vim.api.nvim_create_autocmd("BufReadPre", {
    group = "UserAutoCmds",
    callback = function(args)
        local fsize = vim.fn.getfsize(args.file)
        if fsize > 2048*2048 then
            vim.opt_local.undolevels = -1
            vim.opt_local.undofile   = false
        end
    end,
    desc = "Handle large file",
})

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



-- ## [Text inteligence]
----------------------------------------------------------------------
vim.lsp.enable({
    "lua-ls",
    "ts-ls",
    "rust-analyzer",
})



-- ### [Spelling]
vim.opt.spell = false
--TODO make it ignore fenced code in marksown
--maybe allow only for comment for other filetypes?

-- SpellIgnore rules
-- vim.api.nvim_create_autocmd("Syntax", {
--     group = vim.api.nvim_create_augroup("SpellIgnore", {clear=true}),
--     callback = function()
--         -- Make URL tokens spell-ignored
--         vim.cmd [[
--             syn match UrlNoSpell /http\S\+/ contains=@NoSpell containedin=@AllSpell transparent
--         ]]

--         -- Abbreviations in ALLCAPS (2+ letters/digits)
--         vim.cmd [[
--             syn match AbbrevNoSpell /\<[A-Z][A-Z0-9]\+\>/ contains=@NoSpell containedin=@AllSpell transparent
--         ]]
--     end,
-- })

-- Define a highlight group for URLs
vim.api.nvim_set_hl(0, "MyUrl", { fg = "#6aafc1", bold = true })

-- Apply the syntax match
-- vim.cmd [[
--     syntax match MyUrl /.*/
-- ]]



vim.opt.spellcapcheck = ""
-- Pattern to locate the end of a sentence.  The following word will be
-- checked to start with a capital letter.  If not then it is highlighted
-- with SpellCap |hl-SpellCap| (unless the word is also badly spelled).
-- When this check is not wanted make this option empty.
-- Only used when 'spell' is set.
-- Be careful with special characters, see |option-backslash| about
-- including spaces and backslashes.
-- To set this option automatically depending on the language, see
-- |set-spc-auto|.


-- ### Language
local preferedlangs = {
    "en",
    "fr"
}

vim.opt.spelllang = "en"

-- TODO make it use our own custom dico
vim.opt.spellfile = {
    vim.fn.stdpath("config") .. "/spell/en.utf-8.add",
}

vim.api.nvim_create_user_command("PickDocsLanguage", function()
    local dictpath = vim.fn.stdpath("config").."/spell/"

    vim.ui.select(preferedlangs, {prompt = "Pick documents language"},
    function(choice)
        if choice then
            vim.opt.spelllang = choice
            vim.opt.spellfile = dictpath..choice..".utf-8.add"
        end
    end)
end, {})



-- ## [Formatting]
----------------------------------------------------------------------
local formatopts = {} --will hold all users formats opts
-- View the current formatoptions with ':set verbose=1 formatoptions?'


-- ### Indentation
vim.opt.shiftwidth  = 4    -- Number of spaces to use for indentation
vim.opt.shiftround  = true -- always aligns to a multiple of "shiftwidth". Prevents "misaligned" indents.
vim.opt.tabstop     = 4
vim.opt.softtabstop = 4    -- Number of spaces to use for pressing TAB in insert mode

vim.opt.expandtab   = true -- Use spaces instead of tabs

vim.opt.autoindent  = true -- keep indent of prev line when making a new one
vim.opt.smartindent = true -- simple syntax-aware indent on top of autoindent for certain langs.
-- vim.opt.copyindent = true
-- vim.opt.indentkeys = "0{,0},0),0],:,0#,!^F,o,O,e"
-- A list of keys that, when typed in Insert mode, cause reindenting of
-- the current line. Only happens if 'indentexpr' isn't empty.


-- ### Text Wrapping
-- "t" Auto-wrap text using textwidth (for non-comments).
-- "w" Auto-wrap lines in insert mode, even without spaces.
-- "v" Don't auto-wrap lines in visual mode.
-- table.insert(formatopts, "t")
-- table.insert(formatopts, "w")
vim.opt.textwidth = 80

-- Visual only wraping
vim.opt.wrap        = false --word wrap off by default
vim.opt.breakindent = true --wrapped lines conserve whole block identation

--### Paragraph & Line Formatting
--"a"	Auto-format paragraphs as you type (very aggressive).
--"l"   on joins, Don’t break long lines in insert mode.
--"n"	Recognize numbered lists (1., 2., etc.) and format them properly.
--"2"	Use a two-space indent for paragraph continuation.
table.insert(formatopts, "n")

--### Comments
--"c" Auto-wrap comments using textwidth.
--"r" Continue comments when pressing <Enter> in insert mode.
--"o" Continue comments when opening a new line with o or O.
--"q" Allow gq to format comments.
--"j" Remove comment leaders when joining lines with J.
--"b" No automatic formatting in block comments.
table.insert(formatopts, "c")
table.insert(formatopts, "j")
table.insert(formatopts, "q")

-- vim.opt.commentstring = "-- %s"

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

-- Detect binary files
-- vim.api.nvim_create_autocmd("BufReadPost", {
--     group = "UserAutoCmds",
--     callback = function(args)
--        local path = args.file
--        if path == "" then return end

--         local result = vim.system(
--             { "file", "--mime-type", "-b", path },
--             { text = true }
--         ):wait()
--         if result.code ~= 0 then return end

--         local mime = vim.trim(result.stdout or "")
--         if not mime:match("^text/") then
--             vim.cmd("%!xxd")
--         end
--     end,
-- })

