-- ed --

local v = vim
local vap = vim.api
local vopt = vim.opt
---------------------

-------------------------------------------------------
-- Navigation --
-------------------------------------------------------
vim.g.buffenter_startinsert = true

--[Mouse]
v.opt.mouse = "a"
--"" Mouse support disabled.
--"n"   Enabled in Normal mode.
--"v"	Enabled in Visual mode.
--"i"	Enabled in Insert mode.
--"c"	Enabled in Command-line mode.
--"h"	Enabled in Help pages.
--"a"	Enabled everywhere (equivalent to "nvich").

--v.opt.mousescroll = "ver:0,hor:0"

--mouse selectmode

--Neovim does not track mouse movement unless you click or scroll.
--This means that just moving the cursor around inside the terminal window will not trigger any events.
--Some UI plugins (like floating windows, statuslines, and overlays) use this to provide hover tooltips, previews, or dynamic highlighting.
vim.opt.mousemoveevent = true

--v.opt.mousemodel = "normal" --used for selection extension in normal mode it will simply recreate a seelction

--"block" → Allows cursor to move where there is no actual text in visual block mode.
--"insert" → Allows inserting in positions where there is no actual text.
--"all" → Enables virtual editing in all modes.
--"onemore" → Allows the cursor to move one character past the end of a line.
--"none" → Default, disables virtual editing.
vim.opt.virtualedit = "onemore" --allow to Snap cursor to closest char at eol

-------------------------------------------------------
-- View --
-------------------------------------------------------
--Disable nvim intro
v.opt.shortmess:append("sI")

--v.opt.lazyredraw = true  -- will scroll the view when moving the cursor
-- Allow scrolling beyond the end of the file
--v.opt.scrolloff = 999
--v.opt.sidescrolloff = 999

vim.opt.splitbelow = true -- Open new split windows below the current window
vim.opt.splitright = true -- Open new split windows to the right of the current window

v.opt.showmode = false --show curr mode in cmd

-- vim.opt.showcmd = false
--displaying selection info. It also shows incomplete commands in the bottom-right corner.

--{modes}:{shape}-{blinking options}
local cursor_styles = {
    "n-v-c:block", -- Normal, Visual, Command: Block cursor
    "i-ci-ve:ver85", -- Insert, Command Insert, Visual-Exclude: Block cursor
    "r-cr:hor40", -- Replace, Command Replace: 20% height horizontal bar
    "o:hor50", -- Operator-pending: 50% height horizontal bar
    "a:blinkwait900-blinkoff900-blinkon950-Cursor/lCursor", -- Global blinking settings
    --Cursor stays solid for 700ms before blinking starts.
    --blinkoff400 → Cursor is off for 400ms while blinking.
    --blinkon250 → Cursor is on for 250ms while blinking.
}
vim.opt.guicursor = table.concat(cursor_styles, ",")
vim.opt.cursorline = true

--stopsel: Stop selection when leaving visual mode.
--v.opt.keymodel=startsel
--startsel: Start selection when entering visual mode.

--Search
vim.opt.ignorecase = true
vim.opt.smartcase = true --case-sensitive only if uppercase letters are typed
vim.opt.hlsearch = true --Highlight all matches
vim.opt.incsearch = true --Highlight as you type

vim.opt.updatetime = 200 --screen redraw speed in ms

--[Gutter]
------------------------------
--vim.opt.statuscolumn = "%s%l %c"

v.opt.signcolumn = "yes" --whow letters for error/warning/hint
--"yes" → Always keeps the sign column visible (prevents text movement).
--"no" → Disables the sign column.
--"auto" → Only shows the sign column when needed.
--"auto:X" → Keeps the column visible when up to X signs are present
--"number" → Merges the sign column with the number column.

--Numbers
v.opt.number = true
v.opt.relativenumber = false

--Folding
v.opt.foldenable = true

--"0" Hides fold numbers and uses "fillchars" for fold lines
--"1" Show dedicated fold column and numbers in the gutter
v.opt.foldcolumn = "1"
v.opt.foldmethod = "expr" --Use indentation for folds (or "syntax", "manual", etc.)
v.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
v.opt.foldlevel = 99 --hack to Keep folds open by default
v.opt.foldlevelstart = 99
vim.opt.foldnestmax = 7

vim.opt.fillchars = {
    fold = ".", --in place of the folded text
    foldopen = "", -- 
    foldclose = "", -- >
    foldsep = " ", --│  --separate folds (for open folds)
    eob = "~",
    diff = "╱",
    --horiz     = '━',
    --horizup   = '┻',
    --horizdown = '┳',
    --vert      = '┃',
    --vertleft  = '┫',
    --vertright = '┣',
    --verthoriz = '╋',
}

-------------------------------------------------------
-- Editing --
-------------------------------------------------------
--Define what a word is
vim.opt.iskeyword = "@,48-57,192-255,-,_" --@: alphabet, 48-57: 0-9, 192-255: extended Latin chars

v.opt.backspace = { "indent", "eol", "start" }
--"indent" → Allows Backspace to delete auto-indent.
--"eol" → Allows Backspace to delete past line breaks.
--"start" → Allows Backspace at the start of insert mode.

vim.opt.spell = false
-- Disable spell check for markdown and plaintext
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "markdown", "plaintext" },
    callback = function()
        vim.opt.spell = false
    end,
})

-- Enable spell check for all other file types
-- (optional, if you want it enabled for others)
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "*",
    callback = function()
        vim.opt.spell = true
    end,
})

vim.opt.spelllang = "en_gb" -- Set the spell check language

--[Formating]
local formatopts = {} --will hold all users formats opts

--View the current formatoptions with:
-- :set verbose=1 formatoptions?

--[Identation]
------------------------------
vim.opt.autoindent = true
vim.opt.smartindent = true

v.opt.expandtab = true --Use spaces instead of tabs
vim.opt.shiftround = true --always aligns to a multiple of "shiftwidth". Prevents "misaligned" indents.
v.opt.shiftwidth = 4 -- Number of spaces to use for indentation
v.opt.tabstop = 4
v.opt.softtabstop = 4 -- Number of spaces to use for pressing TAB in insert mode

v.opt.list = true --display non-printable characters (spaces, tabs, newlines)
default_lchars =
    { space = " ", tab = "  ", trail = " ", eol = " ", nbsp = "␣" }
vim.g.show_eol = false --"¶"
v.opt.listchars = default_lchars

--Show listchars when selecting
vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:[vV]*",
    callback = function()
        local eolchar = " "
        if vim.g.show_eol then
            eolchar = "¶"
        end

        vim.opt.listchars = {
            space = ".",
            tab = "» ",
            trail = "⬝",
            eol = eolchar,
            nbsp = "␣",
        }
    end,
})
--Hide them back
vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:[nio]*",
    callback = function()
        vim.opt.listchars = default_lchars

        local eolchar = " "
        if vim.g.show_eol then
            eolchar = "¶"
        end
        vim.opt.listchars:append({ eol = eolchar })
    end,
})

--[Commenting]
--------------------------------
--"c" Auto-wrap comments using textwidth.
--"r" Continue comments when pressing <Enter> in insert mode.
--"o" Continue comments when opening a new line with o or O.
--"q" Allow gq to format comments.
--"j" Remove comment leaders when joining lines with J.
table.insert(formatopts, "c")
table.insert(formatopts, "j")
table.insert(formatopts, "q")

--Text Wrapping
------------------------------
--"t" Auto-wrap text using textwidth (for non-comments).
--"w" Auto-wrap lines in insert mode, even without spaces.
vim.opt.textwidth = 80
vim.opt.wrap = false --word wrap off by default
vim.opt.breakindent = true --wrapped lines conserve whole block identation
vim.opt.showbreak = "↳" --lien wrap symbol

--Paragraph & Line Formatting
-----------------------------
--a	Auto-format paragraphs as you type (very aggressive).
--n	Recognize numbered lists (1., 2., etc.) and format them properly.
--2	Use a two-space indent for paragraph continuation.
table.insert(formatopts, "n")

--Line Joins strategy
--l	Don’t break long lines in insert mode.
--v	Don't auto-wrap lines in visual mode.
--b	No automatic formatting in block comments.
table.insert(formatopts, "l")

--Force selected format options because it can be overwrited by other things
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        local fopts = table.concat(formatopts)
        vim.opt.formatoptions = fopts
    end,
})

--[Diag]
vim.diagnostic.config({
    underline = true,
    update_in_insert = false, --false so diags update on InsertLeave

    virtual_text = {
        enabled = true,
        current_line = false,
        severity = { min = "INFO" },
        prefix = "●",
        suffix = "",
        --format = function(diagnostic)
        --    return "●| "..diagnostic.message.." "
        --end,
    },
    --virtual_lines = {
    --    enabled = false,
    --    current_line = false,
    --    severity = { min = "ERROR" },
    --},
    signs = {
        enabled = true,
        severity = { min = "WARN" },
    },

    severity_sort = true,
    float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = true,
        header = "4",
    },
})
--TODO
--local og_virt_text
--local og_virt_line
--vim.api.nvim_create_autocmd({ 'CursorMoved', 'DiagnosticChanged' }, {
--  group = vim.api.nvim_create_augroup('diagnostic_only_virtlines', {}),
--  callback = function()
--    if og_virt_line == nil then
--      og_virt_line = vim.diagnostic.config().virtual_lines
--    end
--
--    -- ignore if virtual_lines.current_line is disabled
--    if not (og_virt_line and og_virt_line.current_line) then
--      if og_virt_text then
--        vim.diagnostic.config({ virtual_text = og_virt_text })
--        og_virt_text = nil
--      end
--      return
--    end
--
--    if og_virt_text == nil then
--      og_virt_text = vim.diagnostic.config().virtual_text
--    end
--
--    local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
--
--    if vim.tbl_isempty(vim.diagnostic.get(0, { lnum = lnum })) then
--      vim.diagnostic.config({ virtual_text = og_virt_text })
--    else
--      vim.diagnostic.config({ virtual_text = false })
--    end
--  end
--})

--make sure Redraw diag on mode change
vim.api.nvim_create_autocmd("ModeChanged", {
    group = vim.api.nvim_create_augroup("diagnostic_redraw", {}),
    callback = function()
        pcall(vim.diagnostic.show)
    end,
})

--Inlay hint for type
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        if client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end
    end,
})
------------------------------------------------------------
-- Files --
------------------------------------------------------------
v.opt.undofile = false -- Save undo history
--v.opt.undodir = vim.fn.stdpath("state") --"~/.local/state/nvim/undo"

v.opt.swapfile = false --no swap files

v.opt.hidden = true --Allows switching buffers without saving

v.opt.autoread = false --auto reload file on modif

------------------------------------------------------------
-- Command line --
------------------------------------------------------------
--Auto complete menu for cmd
vim.opt.wildmenu = false --we use blink.cmp instead
vim.opt.wildmode = "longest:full,full"
vim.opt.wildoptions = "pum"

--Term

--Keymapping
v.opt.timeoutlen = 300
