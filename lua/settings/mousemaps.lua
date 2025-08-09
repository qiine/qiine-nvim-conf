
-- Mouse lol --

local v = vim
local vapi = vim.api
local vmap = vim.keymap.set
local nvmap = vim.api.nvim_set_keymap
local vcmd = vim.cmd
-----------------------------------------------



--[Settings]--------------------------------------------------
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



--[Nav]--------------------------------------------------
--scrolling
--nvmap("i", "<ScrollWheelUp>", "<Nop>", {noremap=true, silent=true})
--nvmap("n", "<ScrollWheelUp>", "<Nop>", {noremap=true, silent=true})

--nvmap("i", "<ScrollWheelDown>", "<Nop>", {noremap=true, silent=true})
--nvmap("n", "<ScrollWheelDown>", "<Nop>", {noremap=true, silent=true})

nvmap('n', '<ScrollWheelLeft>', '<cmd>echo Scrolling left<CR>', {noremap=true})
nvmap('n', '<ScrollWheelRight>', '<cmd>echo Scrolling right<CR>', {noremap=true})


---Ctrl+wheel zoom
--nvmap("i", "<C-ScrollWheelUp>", "<Nop>", {noremap=true, silent=true})
--nvmap("n", "<C-ScrollWheelUp>", "<Nop>", {noremap=true, silent=true})
--
--nvmap("i", "<C-ScrollWheelDown>", "<Nop>", {noremap=true, silent=true})
--nvmap("n", "<C-ScrollWheelDown>", "<Nop>", {noremap=true, silent=true})


--Middle click
--nvmap("i", "<MiddleMouse>", "")
--nvmap("n", "<MiddleMouse>", "")
--nvmap("v", "<MiddleMouse>", "")

--nvmap('n', '<LeftMouse>', '', {noremap=true, silent=true})
--nvmap('n', '<RightMouse>', '', { noremap=true, silent=true})

--double left click insert
vmap("n", "<2-LeftMouse>", "i", {noremap = true})


--show hover with ctrl+rightclick
vmap({"i","n","v"}, '<C-RightMouse>', "<LeftMouse><cmd>lua vim.lsp.buf.hover()<CR>")
--function() vim.lsp.buf.hover() end)


