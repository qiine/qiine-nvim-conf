-------------------------------------------------------
-- View --
-------------------------------------------------------

local utils = require("utils.utils")

------------------------------------



--## [Rendering]
----------------------------------------------------------------------
vim.opt.updatetime = 200 --screen redraw speed in ms

--v.opt.lazyredraw  = true  -- will scroll the view when moving the cursor
-- Allow scrolling beyond the end of the file
vim.opt.scrolloff     = 2
vim.opt.sidescrolloff = 5
--v.opt.sidescroll = 1

--colorcolumn
--vim.opt.colorcolumn="80"


--shortmess
vim.opt.shortmess:append("si")
-- "f"	Use "(file # of #)" instead of full file name in messages
-- "i"	Don't give intro message when starting Vim
-- "l"	Don't show "line x of y" in messages
-- "m"	Don't show [modified] message
-- "n"	Don't show "file [New]" when editing a new file
-- "r"	Don't show hit-enter prompts (e.g., after messages that pause the UI)
-- "s"	Don't show "search hit BOTTOM, continuing at TOP"
-- "t"	Truncate file messages at the start if too long
-- "w"	Don't show "written" after :w
-- "c"	Don't show completion messages (-- XXX completion (YYY) etc.)
-- "a"	Abbreviation: combine c, s, and w (used in some plugin defaults)



--## [Windows]
----------------------------------------------------------------------
--Splits
vim.opt.splitbelow = true -- Open new split windows below the current window
vim.opt.splitright = true -- Open new split windows to the right of the current window



--## [Cursor]
----------------------------------------------------------------------
--{modes}:{shape}-{blinking options}
local cursor_styles = {
    "n:block",
    "v:block",
    "i-ci-ve-c-t:ver85", -- Insert, Command Insert, Visual-Exclude: Block cursor
    "r-cr:hor40", -- Replace, Command Replace: 20% height horizontal bar
    "o:hor50", -- Operator-pending: 50% height horizontal bar
    "a:blinkwait900-blinkoff900-blinkon950-Cursor/lCursor", -- Global blinking settings
    --Cursor stays solid for 700ms before blinking starts.
    --blinkoff400 -> Cursor is off for 400ms while blinking.
    --blinkon250 -> Cursor is on for 250ms while blinking.
}
vim.opt.guicursor = table.concat(cursor_styles, ",")

vim.opt.cursorcolumn = false

--stopsel: Stop selection when leaving visual mode.
--v.opt.keymodel=startsel
--startsel: Start selection when entering visual mode.



--## [Search]
----------------------------------------------------------------------
vim.opt.ignorecase = true
vim.opt.smartcase  = true --case-sensitive only if uppercase letters are typed
vim.opt.hlsearch   = true --Highlight all matches
vim.opt.incsearch  = true --Highlight as you type

--revert search highlight
vim.api.nvim_create_autocmd('InsertEnter', {
    group = "UserAutoCmds",
    pattern = '*',
    callback = function()
        vim.opt.hlsearch = false
    end,
})

vim.api.nvim_set_hl(0, "IncSearch", { fg = "NONE", bg = "#bfbfbf", bold = false })



--## [Gutter]
----------------------------------------------------------------------
vim.g.gutter_show = true

vim.opt.signcolumn = "no" --show error/warning/hint and others
--"yes"    → Always keeps the sign column visible (prevents text movement).
--"no"     → Disables the sign column.
--"auto"   → Only shows the sign column when needed. (jiterry)
--"auto:X" → Keeps the column visible when up to X signs are present
--"number" → Merges the sign column with the number column.


vim.opt.cursorline    = true   --highlight gutter at curso pos
vim.opt.cursorlineopt = "both" --highlight numbers as well

--line Numbers
vim.opt.number         = true
vim.opt.relativenumber = false
vim.opt.numberwidth    = 1


--### [Folds]
vim.opt.foldcolumn = "1"
--"0" Hides fold numbers
--"1" Show dedicated fold column and numbers in the gutter

vim.opt.foldenable = true --see actual folds in gutter,
--if false but foldcolumn=1, there will simply be an empty column

vim.opt.foldmethod = "expr" --Use indentation for folds (or "syntax", "manual", etc.)
vim.opt.foldexpr   = "v:lua.vim.treesitter.foldexpr()"

vim.opt.foldlevel      = 99 --hack to Keep folds open by default
vim.opt.foldlevelstart = 99
vim.opt.foldnestmax    = 7


--fillchars
vim.opt.fillchars:append({
    fold      = ".", --in place of the folded text
    foldopen  = "⌄", --   ⌄ ▾
    foldclose = ">", -- > ▸
    foldsep   = " ", -- │  --separate folds (for open folds)

    diff      = "╱",
    vert      = "|",
    eob       = "~",
})



--## [Whitespace symbols]
----------------------------------------------------------------------
vim.opt.list = true
vim.opt.listchars:append({
    tab="▸▸",
    eol=" ",
    nbsp="␣",
    precedes="⟽", -- ┅--⇛ ↤ ⸱ « ≪ ⋯
    extends="⟾",  -- ⇒ ⇛ ↦ ⤍ ┅
    conceal="."
})

vim.g.show_eol = false  --will show: "¶"

if vim.g.show_eol == true then
    vim.opt.listchars:append({eol="¶"})
else
    vim.opt.listchars:remove({"eol"})
end

--line wrap symbol
vim.opt.showbreak = "↳"

--Show/hide whitespace symbols when selecting
vim.api.nvim_create_autocmd("ModeChanged", {
    group = "UserAutoCmds",
    pattern = "*:*",
    callback = function()
        local mode = vim.fn.mode()
        if mode == "v" or mode == "V" then
            vim.opt.listchars:append({space=".", tab= "» ", trail="⬝"})
        else
            vim.opt.listchars:remove({"space", "tab", "trail"})
            vim.opt.listchars:append({tab="  "}) --buggy without this
        end
    end,
})

--TODO Show eol char when cursor on it
--vim.api.nvim_create_autocmd({"CursorMoved","ModeChanged"}, {
--    group = 'UserAutoCmds',
--    pattern = '*',
--    callback = function()
--        local mode = vim.fn.mode()
--        if mode ~= "n" then return end

--        local cchar = utils.get_char_at_cursorpos()
--        if cchar == "¶" then
--            vim.opt.listchars:append({eol="¶"})
--        end
--    end,
--})


--vim.api.nvim_buf_set_extmark(0, ns, row - 1, #line, {
--          virt_text = {{"¶", "NonText"}},
--          virt_text_pos = "overlay",
--          hl_mode = "combine"
--      })



--Show/hide whitespace symbols when selecting
--vim.api.nvim_create_autocmd("CursorMoved", {
--    group = "UserAutoCmds",
--    pattern = "*",
--    callback = function()
--        --local cchar = vim.fn.screenchar(vim.fn.line('.'), vim.fn.col('.'))
--        local cchar = vim.fn.screenstring(vim.fn.line('.'), vim.fn.col('.'))
--        vim.cmd("echo'"..cchar.."'")
--    end,
--})



--## [Diagnostic]
----------------------------------------------------------------------
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
        --    local icons = {
        --        [vim.diagnostic.severity.ERROR] = " ",
        --        [vim.diagnostic.severity.WARN]  = " ",
        --        [vim.diagnostic.severity.INFO]  = " ",
        --        [vim.diagnostic.severity.HINT]  = " ",
        --    }

        --    local icon = icons[diagnostic.severity] or ""
        --    return icon .. diagnostic.message
        --end,
    },
    --virtual_lines = {
    --    enabled = false,
    --    current_line = false,
    --    severity = { min = "ERROR" },
    --},
    signs = {
        enabled = true,
        text =
        {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.INFO]  = "",
            [vim.diagnostic.severity.HINT]  = ""
        },
        severity = { min = "WARN" },
    },
    severity_sort = true,
    float = {
        focusable = false,
        style     = "minimal",
        border    = "rounded",
        source    = true,
        header    = "4",
    },
})

--Manual diag show
vim.api.nvim_create_user_command("DiagnosticShow", function()
    vim.diagnostic.show(nil, 0)
end, {})

--Manual diag hide
vim.api.nvim_create_user_command("DiagnosticHide", function()
    vim.diagnostic.hide(nil,0)
end, {})

--Auto show
vim.api.nvim_create_autocmd("InsertEnter", {
    group = "UserAutoCmds",
    pattern = "*",
    callback = function()
        vim.diagnostic.hide(nil, 0)
    end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
    group = "UserAutoCmds",
    pattern = "*",
    callback = function()
        vim.diagnostic.show(nil, 0)
    end,
})

--Show on save
vim.api.nvim_create_autocmd("BufWritePre", {
    group = "UserAutoCmds",
    pattern = "*",
    callback = function()
        vim.diagnostic.show(nil, 0)
    end,
})


--Inlay hint for type
--vim.api.nvim_create_autocmd("LspAttach", {
--    callback = function(args)
--        local client = vim.lsp.get_client_by_id(args.data.client_id)
--
--        if client:supports_method("textDocument/inlayHint") then
--            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
--        end
--    end,
--})



--## [Commandline]
----------------------------------------------------------------------
vim.opt.cmdheight = 1
vim.opt.showmode  = false --show curr mode in cmd

-- vim.opt.showcmd = false
--displaying selection info. It also shows incomplete commands in the bottom-right corner.

--vim.api.nvim_create_autocmd("CmdlineEnter", {
--    callback = function()
--        vim.opt.cmdheight = 1
--    end,
--})
--
--vim.api.nvim_create_autocmd("CmdlineLeave", {
--    callback = function()
--        vim.opt.cmdheight = 0
--    end,
--})

--vim.api.nvim_create_autocmd("MsgEnter", {
--    callback = function()
--        vim.wo.cmdheight = 1  -- Show the command line for messages
--    end,
--})

--Auto complete entry menu for excmd
vim.opt.wildmenu    = true --we use blink.cmp instead
vim.opt.wildmode    = "longest:full,full"
vim.opt.wildoptions = "pum"


--AutoClear the command line
--vim.api.nvim_create_autocmd("CmdlineLeave", {
--    group = "UserAutoCmds",
--    callback = function()
--        vim.defer_fn(function()
--            vim.cmd('echo""')
--        end, 100000)
--    end,
--})



--## [Statusline]
----------------------------------------------------------------------
vim.opt.laststatus = 3
--0 → Never show the statusline.
--1 → Show the statusline only when there are multiple windows.
--2 → Always show the statusline in evry window.
--3 → (Global Statusline) A single statusline is displayed at the bottom, shared across all windows.



