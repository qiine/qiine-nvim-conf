------------------------------------------------------
-- View --
-------------------------------------------------------

local utils = require("utils")
------------------------------------



-- ## [Rendering]
----------------------------------------------------------------------
vim.o.updatetime = 150 --screen redraw speed in ms

--v.opt.lazyredraw  = true  -- will scroll the view when moving the cursor
-- Allow scrolling beyond the end of the file
vim.o.scrolloff     = 0
vim.o.sidescrolloff = 5
--v.o.sidescroll = 1

-- colorcolumn
--vim.o.colorcolumn="80"


-- Shortmess
vim.o.shortmess = "astFTIcC"
--l	use "999L, 888B" instead of "999 lines, 888 bytes"
--m	use "[+]" instead of "[Modified]"
--r	use "[RO]" instead of "[readonly]"
--w	use "[w]" instead of "written" for file write message
--  and "[a]" instead of "appended" for ':w >> file' command
--a	all of the above abbreviations

--o	overwrite message for writing a file with subsequent
--  message for reading a file (useful for ":wn" or when
-- 'autowrite' on)
--O	message for reading a file overwrites any previous
--  message;  also for quickfix message (e.g., ":cn")
--t	truncate file message at the start if it is too long
--  to fit on the command-line, "<" will appear in the left most
--  column; ignored in Ex mode
--T	truncate other messages in the middle if they are too
--  long to fit on the command line; "..." will appear in the
--  middle; ignored in Ex mode
--W	don't give "written" or "[w]" when writing a file
--A	don't give the "ATTENTION" message when an existing swap file is found
--I	don't give the intro message when starting Vim
--c	don't give |ins-completion-menu| messages; for
--  example, "-- XXX completion (YYY)", "match 1 of 2", "The only
--  match", "Pattern not found", "Back at original", etc.
--C	don't give messages while scanning for ins-completion	*shm-C*
--  items, for instance "scanning tags"
--q	do not show "recording @a" when recording a macro	*shm-q*
--F	don't give the file info when editing a file, like
--  `:silent` was <used for the command; note that this also
--  affects messages from 'autoread' reloading

--s	don't give "search hit BOTTOM, continuing at TOP" or
--  "search hit TOP, continuing at BOTTOM" messages; when using
--  the search count do not show "W" before the count message
--S	do not show search count message when searching, e.g.
--  "[1/5]". When the "S" flag is not present (e.g. search count
--  is shown), the "search hit BOTTOM, continuing at TOP" and
--  "search hit TOP, continuing at BOTTOM" messages are only
--  indicated by a "W" (Mnemonic: Wrapped) letter before the
--  search count statistics.

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank({higroup='Visual', timeout = 180})
    end,
})


-- Highlight on entering Visual mode
-- vim.api.nvim_create_autocmd("ModeChanged", {
--     group = "UserAutoCmds",
--     pattern = "*:[vV\x16]",  -- entering visual mode
--     callback = function()
--         -- local clients = vim.lsp.get_clients({ bufnr = 0 })
--         -- local supports_highlight = false

--         -- for _, client in ipairs(clients) do
--         --     if client.server_capabilities.documentHighlightProvider then
--         --         supports_highlight = true
--         --         break
--         --     end
--         -- end

--         -- if supports_highlight then
--         --     vim.lsp.buf.clear_references()
--         --     vim.lsp.buf.document_highlight()
--         -- end
--     end,
-- })

-- -- -- clear highlight when moving
-- vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
--     group = "UserAutoCmds",
--     callback = function()
--         -- vim.lsp.buf.clear_references()
--         -- vim.opt.hlsearch = false
--     end,
-- })


-- ## [Windows]
----------------------------------------------------------------------
--Splits
vim.o.splitbelow = true -- Open new hor split windows below the current window
vim.o.splitright = true -- Open new ver split windows to the right of the current window

-- Floating windows borders style
vim.o.winborder = "none" -- single rounded



-- ## [Cursor]
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

vim.o.cursorcolumn = false
-- Cursorline only for active win
vim.api.nvim_create_autocmd({"WinEnter", "BufEnter"}, {
    group   = "UserAutoCmds",
    command = "lua vim.opt_local.cursorline = true",
})
vim.o.cursorlineopt = "both" --highlight numbers as well

--stopsel: Stop selection when leaving visual mode.
--v.opt.keymodel=startsel
--startsel: Start selection when entering visual mode.



-- ## [Search]
----------------------------------------------------------------------
vim.o.ignorecase = true
vim.o.smartcase  = true --case-sensitive only if uppercase letters are typed
vim.o.hlsearch   = true --Highlight all matches
vim.o.incsearch  = true --Highlight as you type

-- Stop search highlight when editing
vim.api.nvim_create_autocmd("InsertEnter", {
    group   = 'UserAutoCmds',
    command = "lua vim.o.hlsearch = false"
})

-- Search text highlight col
vim.api.nvim_set_hl(0, "IncSearch", { fg = "NONE", bg = "#bfbfbf", bold = false })



-- ## [Gutter]
----------------------------------------------------------------------
vim.g.gutter_show = true

vim.o.signcolumn = "no" --show error/warning/hint and others
--"yes"    → Always keeps the sign column visible (prevents text movement).
--"no"     → Disables the sign column.
--"auto"   → Only shows the sign column when needed. (jiterry)
--"auto:X" → Keeps the column visible when up to X signs are present
--"number" → Merges the sign column with the number column.

-- line Numbers
vim.o.number         = true
vim.o.relativenumber = false
vim.o.numberwidth    = 1


-- ### [Folds]
vim.o.foldenable = true  -- Actual folds icons in gutter
vim.o.foldcolumn = "1"
--"0" Hides fold numbers
--"1" Show dedicated fold column and numbers in the gutter

vim.o.foldmethod = 'expr' -- manual, expr
vim.o.foldexpr   = 'v:lua.vim.treesitter.foldexpr()'
-- Prefer LSP folding if client supports it
vim.api.nvim_create_autocmd('LspAttach', {
    group = 'UserAutoCmds',
    callback = function(args)
        if vim.bo.filetype == "markdown" then return end

        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client:supports_method('textDocument/foldingRange') then
            vim.defer_fn(function()
                if vim.api.nvim_buf_is_valid(0) then
                    vim.opt_local.foldexpr = 'v:lua.vim.lsp.foldexpr()'
                end
            end, 70) -- ms -- need to wait a bit to give time to lsp
        end
    end,
})


vim.o.foldnestmax    = 10
vim.o.foldlevelstart = 99 -- opens all folds on buf enter

vim.o.foldtext = "v:lua.FoldedText()"
function FoldedText()
    local line = vim.fn.getline(vim.v.foldstart)
    return line.." ⋯"
end

-- fold color
vim.api.nvim_set_hl(0, "Folded", { fg = "#555555", bg = "NONE" })

-- Those action opens fold
vim.o.foldopen = "block,hor,mark,percent,quickfix,search,tag,undo" -- hor -- open fold with arrows

-- No gutter for terms
vim.api.nvim_create_autocmd('BufWinEnter', {
    group    = 'UserAutoCmds',
    callback = function(param)
        vim.schedule(function()
            if vim.bo[0].buftype == "terminal" then
                vim.opt_local.statuscolumn   = ""
                vim.opt_local.signcolumn     = "no"
                vim.opt_local.number         = false
                vim.opt_local.relativenumber = false
                vim.opt_local.foldcolumn     = "0"
            end
        end)
    end,
})


-- Fillchars
vim.opt.fillchars:append({
    fold      = " ", --in place of the folded text  - ⋯
    foldopen  = "⌄", --   ⌄ ▾
    foldclose = ">", -- > ▸
    foldsep   = " ", -- │  --separate folds (for open folds)
    -- foldinner = '', -- TODO soon vim 0.12

    diff      = "╱",

    vert      = " ", -- ┃
    horiz     = "━", -- ━ ▔▁
    eob       = "~",
})



-- ## [Whitespace symbols]
----------------------------------------------------------------------
vim.o.list = true
vim.opt.listchars:append({
    space=" ",
    tab="» ",
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

-- line wrap symbol
vim.o.showbreak = "↳"

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


-- ## [Text intel]
----------------------------------------------------------------------
-- ### [Diagnostic]
vim.diagnostic.config({
    underline = true,
    update_in_insert = false, -- false so diags update on InsertLeave

    virtual_text = {
        enabled = true,
        current_line = false,
        severity = { min = "INFO" },
        prefix   = "●",
        suffix   = "",
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
        style     = "normal",
        border    = "rounded",
        source    = true,
        header    = "4",
    },
    -- jump = { float = true },
})

-- Manual diag show
vim.api.nvim_create_user_command("DiagnosticShow", function()
    vim.diagnostic.show(nil, 0)
end, {})

-- Manual diag hide
vim.api.nvim_create_user_command("DiagnosticHide", function()
    vim.diagnostic.hide(nil,0)
end, {})

-- Auto show
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



-- ## [Tabline]
----------------------------------------------------------------------
-- vim.opt.showtabline = 2  -- always show tabline

-- simple tabline function
-- function _G.PillTabline()
--     local s = ""
--     local tabs = vim.api.nvim_list_tabpages()
--     local current = vim.api.nvim_get_current_tabpage()

--     for i, tab in ipairs(tabs) do
--         local is_active = (tab == current)

--         local hl_left  = is_active and "%#TabLinePillActiveLeft#"   or "%#TabLinePillInactiveLeft#"
--         local hl_text  = is_active and "%#TabLinePillActiveText#"   or "%#TabLinePillInactiveText#"
--         local hl_right = is_active and "%#TabLinePillActiveRight#"  or "%#TabLinePillInactiveRight#"

--         s = s .. hl_left .. ""
--         s = s .. hl_text .. " " .. i .. " "
--         s = s .. hl_right .. ""
--         s = s .. "%#TabLine# "
--     end

--     return s
-- end
-- vim.opt.tabline = "%!v:lua.PillTabline()"




-- ## [Command line]
----------------------------------------------------------------------
vim.o.cmdheight = 1
vim.o.showmode = false --show curr mode in cmd


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


vim.o.messagesopt = "hit-enter,history:500"  -- wait:3000,
-- vim.o.messagesopt = "wait:3000,history:500"  -- wait:3000,




