-------------------------------------------------------
-- View --
-------------------------------------------------------

local utils = require("utils.utils")

local v = vim
local vap = vim.api
local vopt = vim.opt
------------------------------------


v.opt.shortmess:append("si")
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

--Splits
vim.opt.splitbelow = true -- Open new split windows below the current window
vim.opt.splitright = true -- Open new split windows to the right of the current window

v.opt.showmode = false --show curr mode in cmd

-- vim.opt.showcmd = false
--displaying selection info. It also shows incomplete commands in the bottom-right corner.


--#[Cursor]
--{modes}:{shape}-{blinking options}
local cursor_styles = {
    "n-v-c:block", -- Normal, Visual, Command: Block cursor
    "i-ci-ve-c-t:ver85", -- Insert, Command Insert, Visual-Exclude: Block cursor
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

--vim.opt.colorcolumn="80"

--[Rendering]
vim.opt.updatetime = 200 --screen redraw speed in ms

--v.opt.lazyredraw = true  -- will scroll the view when moving the cursor
-- Allow scrolling beyond the end of the file
v.opt.scrolloff = 3
v.opt.sidescrolloff = 5
--v.opt.sidescroll=1



--[Gutter]--------------------------------------------------
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

--[Folding]
v.opt.foldenable = true

--"0" Hides fold numbers and uses "fillchars" for fold lines
--"1" Show dedicated fold column and numbers in the gutter
v.opt.foldcolumn = "1"
v.opt.foldmethod = "expr" --Use indentation for folds (or "syntax", "manual", etc.)
v.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
v.opt.foldlevel = 99 --hack to Keep folds open by default
v.opt.foldlevelstart = 99
vim.opt.foldnestmax = 7

vim.opt.fillchars:append({
    fold = ".", --in place of the folded text
    foldopen = "", -- 
    foldclose = ">", --
    foldsep = " ", --│  --separate folds (for open folds)

    eob="~",
})


--[Whitespace symbols]
v.opt.list = true
vim.opt.listchars:append({
    tab="  ",
    eol=" ",
    nbsp="␣",
    precedes="⇐",
    extends="⇒",
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

--local function update_eol_display()
--  -- Check if the cursor is at the end of the line
--  local line = vim.fn.line('.')
--  local col = vim.fn.col('.')
--  local line_len = vim.fn.col('$') - 1
--
--  -- Only show EOL if cursor is at the end of the line
--  if col == line_len then
--    vim.opt.listchars = { eol = "¶" }
--  else
--    vim.opt.listchars = { eol = "" }
--  end
--end

--[Diagnostic]
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
--vim.api.nvim_create_autocmd("ModeChanged", {
--    group = vim.api.nvim_create_augroup("diagnostic_redraw", {}),
--    callback = function()
--        pcall(vim.diagnostic.show)
--    end,
--})

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


--[Conceal]
vim.opt.conceallevel=0
--0		Text is shown normally
--	1		Each block of concealed text is replaced with one
--			character.  If the syntax item does not have a custom
--			replacement character defined (see |:syn-cchar|) the
--			character defined in 'listchars' is used.
--			It is highlighted with the "Conceal" highlight group.
--	2		Concealed text is completely hidden unless it has a
--			custom replacement character defined (see
--			|:syn-cchar|).
--	3		Concealed text is completely hidden.

vim.opt.concealcursor=n

--vim.api.nvim_create_autocmd("FileType", {
--    pattern = {"lua"},
--    callback = function()
--        vim.cmd [[
--            syntax match ConcealFunction /\_<function\>/ conceal cchar=𝒇𝒏
--            syntax match ConcealFunction /\_::/ conceal cchar=⋮ --⁝⁞
--        ]]
--    end,
--})
----§class


------------------------------------------
-- Command line --
------------------------------------------
vim.opt.cmdheight=1

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

--AutoClear the command line
vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = "UserAutoCmds",
    callback = function()
        vim.defer_fn(function()
            vim.cmd('echo""')
        end, 100000)
    end,
})

