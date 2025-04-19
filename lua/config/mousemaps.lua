
-- Mouse lol --

local v = vim
local vapi = vim.api
local vmap = vim.keymap.set
local nvmap = vim.api.nvim_set_keymap
local vcmd = vim.cmd
-----------------------------------------------

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


