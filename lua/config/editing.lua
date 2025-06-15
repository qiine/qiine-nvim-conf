
-- ed --

local v = vim
local vap = vim.api
local vopt = vim.opt
---------------------



--[Navigation]--------------------------------------------------
vim.g.autostartinsert = true


--[Mouse]
v.opt.mouse = "a"
--""    Mouse support disabled.
--"n"   Enabled in Normal mode.
--"v"	Enabled in Visual mode.
--"i"	Enabled in Insert mode.
--"c"	Enabled in Command-line mode.
--"h"	Enabled in Help pages.
--"a"	Enabled everywhere (equivalent to "nvich").

--v.opt.mousescroll = "ver:0,hor:0"

--mouse selectmode

vim.opt.mousemoveevent = true
--Neovim does not track mouse movement unless you click or scroll.
--This means that just moving the cursor around inside the terminal window will not trigger any events.
--Some UI plugins (like floating windows, statuslines, and overlays) use this to provide hover tooltips, previews, or dynamic highlighting.

--v.opt.mousemodel = "normal" --used for selection extension in normal mode it will simply recreate a seelction

vim.opt.virtualedit = "onemore" --allow to Snap cursor to closest char at eol
--"block" → Allows cursor to move where there is no actual text in visual block mode.
--"insert" → Allows inserting in positions where there is no actual text.
--"all" → Enables virtual editing in all modes.
--"onemore" → Allows the cursor to move one character past the end of a line.
--"none" → Default, disables virtual editing.

--Smart virt edit
vim.api.nvim_create_autocmd("ModeChanged", {
    group = "UserAutoCmds",
    pattern = "*:*",
    callback = function()
        local mode = vim.fn.mode()
        if mode == "n"                then vim.opt.virtualedit = "all"     end
        if mode == "i"                then vim.opt.virtualedit = "block"   end
        if mode == "v" or mode == "V" then vim.opt.virtualedit = "onemore" end
    end,
})



--[Editing]--------------------------------------------------
--#[Keymapping]
v.opt.timeoutlen = 300 --delay between key press to register shortcuts

--Define what a word is
vim.opt.iskeyword = "@,48-57,192-255,-,_" --@: alphabet, 48-57: 0-9, 192-255: extended Latin chars

v.opt.backspace = { "indent", "eol", "start" }
--"indent" → Allows Backspace to delete auto-indent.
--"eol" → Allows Backspace to delete past line breaks.
--"start" → Allows Backspace at the start of insert mode.


--#[Undo]
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


--#[Spellcheck]
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



--#[Formating]
local formatopts = {} --will hold all users formats opts

--View the current formatoptions with:
-- :set verbose=1 formatoptions?


--##[Identation]
vim.opt.autoindent = true
vim.opt.smartindent = true
--vim.opt.indentkeys = "0{,0},0),0],:,0#,!^F,o,O,e"

v.opt.expandtab = true --Use spaces instead of tabs
vim.opt.shiftround = true --always aligns to a multiple of "shiftwidth". Prevents "misaligned" indents.
v.opt.shiftwidth = 4 -- Number of spaces to use for indentation
v.opt.tabstop = 4
v.opt.softtabstop = 4 -- Number of spaces to use for pressing TAB in insert mode

--##[Text Wrapping]
--"t" Auto-wrap text using textwidth (for non-comments).
--"w" Auto-wrap lines in insert mode, even without spaces.
--"v" Don't auto-wrap lines in visual mode.
--table.insert(formatopts, "t")
--table.insert(formatopts, "w")
vim.opt.textwidth = 80
--vim.api.nvim_create_autocmd("ModeChanged", {
--    pattern = {"txt", "md"},
--    callback = function()
--        vim.opt_local.formatoptions:append("t")
--    end,vim.opt_local.formatoptions:append("w")
--})

--Visual only wraping
vim.opt.wrap = false --word wrap off by default
vim.opt.breakindent = true --wrapped lines conserve whole block identation

--##[Paragraph & Line Formatting]
--"a"	Auto-format paragraphs as you type (very aggressive).
--"l" on joins, Don’t break long lines in insert mode.
--"n"	Recognize numbered lists (1., 2., etc.) and format them properly.
--"2"	Use a two-space indent for paragraph continuation.
table.insert(formatopts, "n")

--##[Commenting]
--"c" Auto-wrap comments using textwidth.
--"r" Continue comments when pressing <Enter> in insert mode.
--"o" Continue comments when opening a new line with o or O.
--"q" Allow gq to format comments.
--"j" Remove comment leaders when joining lines with J.
--"b" No automatic formatting in block comments.
table.insert(formatopts, "c")
table.insert(formatopts, "j")
table.insert(formatopts, "q")

--Force selected format options because it can be overwrited by other things
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        local ft = vim.bo.filetype
        if ft == "text" or ft == "markdown" then
            table.insert(formatopts, "t")
            table.insert(formatopts, "w")
        end

        local fopts = table.concat(formatopts)
        vim.opt.formatoptions = fopts

    end,
})



--vim.on_key(function(char)
--    if vim.fn.mode() ~= "n" then return end

--    local current_time = now()
--    table.insert(last_keys, current_time)

--    -- trim to last N keys
--    while #last_keys > key_limit do
--        table.remove(last_keys, 1)
--    end

--    -- check timing
--    if #last_keys == key_limit and (last_keys[#last_keys] - last_keys[1]) < threshold_ms then
--        vim.schedule(function()
--            if vim.fn.mode() == "n" then
--                vim.cmd("startinsert")
--            end
--        end)
--        last_keys = {}
--    end
--end, ns)


-- Attach key logger only in normal mode
--local function attach_keylogger()
--    vim.on_key(function(char)
--        vim.schedule(function()
--            if vim.fn.keytrans(char) == "<Up>" then
--                vim.cmd("startinsert")
--            end
--        end)
--    end, ns_id)
--end

