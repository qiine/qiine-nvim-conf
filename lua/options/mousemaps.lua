
-- Mouse lol --

local v = vim
local vapi = vim.api
local map = vim.keymap.set
local vcmd = vim.cmd
-----------------------------------------------



-- [Settings]
----------------------------------------------------------------------
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



-- [Nav]
----------------------------------------------------------------------
-- scrolling
-- nvmap("i", "<ScrollWheelUp>", "<Nop>", {noremap=true, silent=true})
-- nvmap("n", "<ScrollWheelUp>", "<Nop>", {noremap=true, silent=true})

-- nvmap("i", "<ScrollWheelDown>", "<Nop>", {noremap=true, silent=true})
-- nvmap("n", "<ScrollWheelDown>", "<Nop>", {noremap=true, silent=true})

map('n', '<ScrollWheelLeft>', '<cmd>echo Scrolling left<CR>', {noremap=true})
map('n', '<ScrollWheelRight>', '<cmd>echo Scrolling right<CR>', {noremap=true})

---Ctrl+wheel zoom
--map("i", "<C-ScrollWheelUp>", "<Nop>", {noremap=true, silent=true})
--map("n", "<C-ScrollWheelUp>", "<Nop>", {noremap=true, silent=true})
--
-- map("i", "<C-ScrollWheelDown>", "<Nop>", {noremap=true, silent=true})
-- map("n", "<C-ScrollWheelDown>", "<Nop>", {noremap=true, silent=true})

-- Middle click
-- map("i", "<MiddleMouse>", "<MiddleMouse>")
-- map("n", "<MiddleMouse>", "<MiddleMouse>")
-- map("v", "<MiddleMouse>", "<MiddleMouse>")

-- map('n', '<LeftMouse>', '', {noremap=true, silent=true})
-- map('n', '<RightMouse>', '', { noremap=true, silent=true})

map({"i","n","v"}, '<C-LeftMouse>', function()
    vim.api.nvim_feedkeys("<LeftMouse>", "n", false)

    local word = vim.fn.expand("<cword>")
    local WORD = vim.fn.expand("<cWORD>")
    local char = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]

    if WORD:match("^https?://") then
        vim.cmd("silent! !" .. "xdg-open " .. WORD) return
    end

    local path = vim.fn.expand(WORD)
    if vim.fn.filereadable(path) == 1 then vim.cmd("norm! gf") return end

    if char:match("[(){}%[%]'\"`<>|]") then
        vim.cmd("norm %") return --no bang ! to use custom keymap
    end

    vim.cmd("lua vim.lsp.buf.implementation()")
end)


-- vis
map({"i","n","v"}, "<M-LeftMouse>", "<esc><C-v><LeftMouse>", {noremap = true})



-- [Edit]
----------------------------------------------------------------------
-- Double left click insert
map("n", "<2-LeftMouse>", "i", {noremap = true})



-- [Text inteligence]
----------------------------------------------------------------------
-- show hover with ctrl+rightclick, <LeftMouse> is use to force focus of the word
map({"i","n","v"}, '<C-RightMouse>', "<esc><LeftMouse><cmd>lua vim.lsp.buf.hover()<CR>")


