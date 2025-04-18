-- _
--| |
--| | _____ _   _ _ __ ___   __ _ _ __  ___
--| |/ / _ \ | | | '_ ` _ \ / _` | '_ \/ __|
--|   <  __/ |_| | | | | | | (_| | |_) \__ \
--|_|\_\___|\__, |_| |_| |_|\__,_| .__/|___/
--           __/ |               | |
--          |___/                |_|

local utils = require("utils.utils")

local v     = vim
local vapi  = vim.api
local vcmd  = vim.cmd
local vmap  = vim.keymap.set
local nvmap = vim.api.nvim_set_keymap
----------------------------------------


--[Doc]--------------------------------------------------
--vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
--mode:  mode in which the mapping will work
--lhs: key combination you want to bind.
--rhs: The action or command that should be executed when the key is pressed.
--opts: Optional settings, usually passed as a table.

--Setting key example:
--vim.keymap.set("i", "<C-d>", "dd",{noremap = true, silent = true, desc ="ctrl+d delette line"})
--noremap = true,  Ignore any existing remappings will act as if there is no custom mapping.
--silent = true Prevents displaying command in the command-line when executing the mapping.

--calling func in keymap
--vim.keymap.set("n", "<M-n>", function()v.cmd("echo 'hello copy'") end, {noremap = true})

--!WARNING! using vim.cmd("Some command") in a setkey will be auto-executed  when the file is sourced !!

--to unmap a key use <Nop>
--vim.keymap.set("i", "<C-d>", "<Nop>",{noremap = true"})

--Keys
----------------
--<C-o> allows to execute one normal mode command while staying in insert mode.

--<esc> = \27
--<cr> = \n
--<Tab> = \t
--<C-BS> = ^H

--<cmd>
--doesn't change modes which helps perf
--`<cmd>` does need <CR>. while ":" triggers "CmdlineEnter" implicitly

--":"supports Ex ranges like '<,'>.

local esc = "<Esc>"
local entr = "<CR>"
local tab = "<Tab>"
local space = "<Space>"

--modes helpers
local modes = { "i", "n", "v", "o", "t", "c" }

local function currmod() return vim.api.nvim_get_mode().mode end


--[Internal]--------------------------------------------------
--vim.g.mapleader = " "

--Ctrl+q to quit
vmap(modes, "<C-q>", function() v.cmd("qa!") end, {noremap=true, desc="Force quit all buffer"})

--Ressource curr file
vmap(modes, "ç", --altgr-r
function()
local cf = vim.fn.expand("%:p")
vim.cmd("source "..cf)

local fname = '"'..vim.fn.fnamemodify(cf, ":t")..'"'
vim.cmd(string.format("echo '%s ressourced'", fname))
end
)

--Quick restart nvim
vmap(modes, "<C-M-r>", "<cmd>Restart<cr>")

--F5 refresh buffer
vmap({"i","n","v"}, '<F5>', function() vim.cmd("e!") vim.cmd("echo'-File reloaded-'") end, {noremap = true})


---[LSP]
--Goto deffinition
vmap("i", "<F12>", "<Esc>gdi")
vmap("n", "<F12>", "gd")
vmap("v", "<F12>", "<Esc>gd")



--[File]----------------------------------------
--ctrl+s save
vmap(modes, "<C-s>", "<cmd>write<cr>", {noremap = true})
vmap(modes, "<C-S-s>", "<cmd>wa<cr>", {noremap = true})

--Create new file
local function create_newfile()
local buff_count = vim.api.nvim_list_tabpages()
local newbuff_num = #buff_count
v.cmd("tabnew")
v.cmd("edit untitled_" .. newbuff_num)
end
vmap(modes, "<C-n>", create_newfile, {noremap = true})



--[View]--------------------------------------------------
--alt-z toggle line wrap
vmap(
{"i", "n", "v"}, "<A-z>",
function()
    v.opt.wrap = not vim.opt.wrap:get()  --Toggle wrap
end,
{noremap = true}
)

--Gutter on/off
vmap("n", "<M-g>", function()
local toggle = "yes"
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.signcolumn = "no"
vim.opt.foldenable = false
end, {noremap=true, desc = "Toggle Gutter" })


--[Folding]
-- vmap({"i","n","v}", "<M-f>",
--     function()
--         if v.fn.foldclosed(".") == -1 then
--             v.cmd("foldclose")
--         else
--             v.cmd("foldopen")
--         end
--     end,
-- {noremap = true, silent = true}
-- )

--virt lines
vmap("n", "gl", "<cmd>Toggle_VirtualLines<CR>", {noremap=true})


--[Tabs]--------------------------------------------------
--create new tab
vmap(
modes,"<C-t>",
function() vim.cmd("tabnew") end,
{noremap = true, silent = true}
)
--tabs close
vmap(
modes,
"<C-w>",
function() vim.cmd("bd!") end,
{noremap = true, silent = true}
)

--tabs nav
vmap(modes, "<C-Tab>", "<cmd>bnext<cr>", {noremap = true, silent = true})



--[Windows]----------------------------------------
vmap("i", "<M-w>", "<esc><C-w>")
vmap("n", "<M-w>", "<C-w>")
vmap("v", "<M-w>", "<Esc><C-w>")



--[Navigation]----------------------------------------
--Jump next word
vmap('i', '<C-Right>', '<C-o>w', { noremap = true, silent = true })
vmap('v', '<C-Right>', 'w', { noremap = true, silent = true })

--Jump previous word
vmap('i', '<C-Left>', '<C-o>b', { noremap = true, silent = true })
vmap('v', '<C-Left>', 'b', {noremap = true, silent = true })

--to next/prev cursor loc
vmap({"i","v"}, "<C-PageDown>", "<Esc><C-o>")
vmap("n", "<C-PageDown>", "<C-o>")

vmap({"i","v"}, "<C-PageUp>", "<Esc><C-i>")
vmap("n", "<C-PageUp>", "<C-i>")

--smart Jump to link
vmap({"i","n"}, "<C-CR>",
function()
    local word = vim.fn.expand("<cfile>")
    local filetype = vim.bo.filetype

    -- crude check: if it's a URL or a file-like string
    if word:match("^https?://") or vim.fn.filereadable(word) == 1 then
        vim.cmd.normal("gx")
    else
        vim.cmd.normal("%")
    end
end
)


--#[Fast cursor move]
--Fast move normal mode
vmap('n', '<C-Right>', '5l', { noremap = true, silent = true })
vmap('n', '<C-Left>', '5h', { noremap = true, silent = true })

--ctrl+up/down to move fast
vmap("i", "<C-Up>", function() vim.cmd("normal! 3k") end, {noremap = true, silent = true })
vmap("n", "<C-Up>", "4k", {noremap = true, silent = true })
vmap("v", "<C-Up>", "3k", {noremap = true, silent = true })

vmap("i", "<C-Down>", function() vim.cmd("normal! 3j") end, {noremap = true, silent = true })
vmap("n", "<C-Down>", "4j", {noremap = true, silent = true })
vmap("v", "<C-Down>", "3j", {noremap = true, silent = true })

--alt+left/right move to start/end of line
vmap("i", "<M-Left>", function() vim.cmd("normal! 0") end, {noremap=true})
vmap("n", "<M-Left>", "0")
vmap("v", "<M-Left>", "0")

vmap("i", "<M-Right>", "<Esc>$a")
vmap("n", "<M-Right>", "$")
vmap("v", "<M-Right>", "$")

--Quick home/end
vmap("i", "<Home>", "<Esc>gg0i", {noremap=true})
vmap({"n","v"}, "<Home>", "gg0", {noremap=true})

vmap("i", "<End>", "<Esc>G0i", {noremap=true})
vmap({"n","v"}, "<End>", "G0", {noremap=true})



--[Selection]----------------------------------------
--Select word under cursor
vmap("i", "<S-w>", "<Esc>viw")
vmap("n", "<S-w>", "viw")

vmap("n", "ww", "viw")

vmap("i", "«", "<esc>viw") --<altgr-w>
vmap("n", "«", "viw")
vmap("v", "«", "iw")

--Visual block
vmap("i", "<M-v>", "<esc><C-S-v>", {noremap=true})
vmap({"n","v"}, "<M-v>", "<C-S-v>", {noremap=true})

--ctrl+a select all
vmap(modes, "<C-a>", "<Esc>ggVG", {noremap = true, silent = true })

--shift+arrows vis select
vmap("i", "<S-Left>", "<Esc>hv", {noremap = true, silent = true})
vmap("n", "<S-Left>", "vh", {noremap = true, silent = true})
vmap("v", "<S-Left>", "<Left>")

vmap("i", "<S-Right>", "<Esc>v", {noremap = true, silent = true})
vmap("n", "<S-Right>", "vl", {noremap = true, silent = true})
vmap("v", "<S-Right>", "<Right>")

vmap("i", "<S-Up>", "<Esc>vk", {noremap=true, silent=true})
vmap("n", "<S-Up>", "vk", {noremap=true, silent=true})
vmap("v", "<S-Up>", "k", {noremap=true, silent=true}) --avoid fast scrolling around

vmap("i", "<S-Down>", "<Esc>vh", {noremap=true, silent=true})
vmap("n", "<S-Down>", "vj", {noremap=true, silent=true})
vmap("v", "<S-Down>", "j", {noremap=true, silent=true}) --avoid fast scrolling around

--Alt-arrow block selection
vmap({"i","n"}, "<M-Up>", "<Esc><C-v>k")
vmap("v", "<M-Up>", "k")

vmap({"i","n"}, "<M-Down>", "<Esc><C-v>j")
vmap("v", "<M-Down>", "j")


--*[Grow select]
--grow horizontally TODO proper anchor logic
vmap("i", "<M-PageUp>", "<Esc>vl")
vmap("n", "<M-PageUp>", "vl")
vmap("v", "<M-PageUp>", "l")

vmap("i", "<M-PageDown>", "<Esc>vh")
vmap("n", "<M-PageDown>", "vh")
vmap("v", "<M-PageDown>", "oho")

--grow do end/start of line
vmap("i", "<S-PageUp>", "<Esc><S-v>k")
vmap("n", "<S-PageUp>", "<S-v>k")
vmap("v", "<S-PageUp>",
    function ()
        local m = vim.api.nvim_get_mode().mode
        if m == "V" then vim.cmd("normal! k")
        else             vim.cmd("normal! <S-v>k")
        end
    end
)

vmap("i", "<S-PageDown>", "<Esc><S-v>j")
vmap("n", "<S-PageDown>", "<S-v>j")
vmap("v", "<S-PageDown>",
    function ()
        local m = vim.api.nvim_get_mode().mode
        if m == "V" then vim.cmd("normal! j")
        else             vim.cmd("normal! <S-v>j")
        end
    end
)

--#[search]
vmap("i", "<C-f>", "<Esc>/")
vmap("n","<C-f>", "/")
vmap("v", "<C-f>", "<Esc>*<cr>")



--[Editing]--------------------------------------------------
vmap("i", "<Ins>", "<Esc>", {noremap = true})
vmap("n", "<Ins>", "i", {noremap = true})
vmap("v", "<Ins>", "<Esc>i", {noremap = true})

--Visual insert mode
vmap("v", "<M-i>", "I", {noremap=true})

--#[Copy / Cut / Past]
--Copy
-- ' "+ ' is the os register
vmap("i", "<C-c>",
    function()
        vim.cmd('normal! ^"+y$')
        --local copied_text = vim.fn.getreg("+")
        --local message = string.format('echo "Copied: %s"', copied_text)
        vim.cmd("echo 'copied !'")
    end,
{noremap=true})
vmap("n", "<C-c>", '"+yl', {noremap = true})
vmap("v", "<C-c>", '"+y', {noremap = true})

--Fast copy word
vmap("n", "<C-c><C-c>", 'viw"+y')

--ctrl+x cut
vmap("i", "<C-x>", '<esc>^"+y$"_ddi', {noremap = true})
vmap("n", "<C-x>", '"+x', { noremap = true, silent = true })
vmap("v", "<C-x>", '"+d<Esc>', { noremap = true, silent = true }) --d both delette and copy so..

--Map Ctrl-v  paste
vmap("i", "<C-v>", '<esc>"+Pli')
vmap("n", "<C-v>", '"+p')
vmap("v", "<C-v>", '"_d"+P')
vmap("c", "<C-v>", '<C-R>+')
vmap("t", "<C-v>", '<C-o>"+P')

--#[Dup]
vmap("i", "<C-d>", '<Esc>yypi')
vmap("n", "<C-d>", 'yyp')
vmap("v", "<C-d>", '"+yP')--TODO does not place text proper


--#[Undo/redo]
--ctrl+z to undo
vmap("i", "<C-z>", function() v.cmd("normal! u") end, {noremap = true})
vmap({"n","v"}, "<C-z>", "u", {noremap = true})

--redo
vmap("i", "<C-y>", "<cmd>normal! <C-r><cr>", {noremap = true})
vmap({"n","v"}, "<C-y>", "<C-r>", {noremap = true})


--#[Deletion]
--backspace delete char
--vmap("i", "<BS>", "<C-o>x", {noremap=true, silent=true}) --maybe not needed on wezterm
vmap("n", "<BS>", '<Esc>"_X<Esc>')
vmap("v", "<BS>", '"_x')

--Ctrl+BS remove word
vmap("i", "<C-H>", "<C-w>")
vmap("n", "<C-H>", '"_dB')
vmap("v", "<C-H>", '"_dB"')

--Shift+backspace clear line
vmap("i", "<S-BS>", '<Esc>0"_d$i', {silent = true})
vmap("n", "<S-BS>", '0"_d$', {silent = true})
vmap("v", "<S-BS>", '<Esc>"_cc', {silent=true})

--*[Del]
vmap("n", "<Del>", 'v"_d<esc>')
vmap("v", "<Del>", '"_d<esc>i')

--ctrl+Del rem word
vmap("i", "<C-Del>", '<C-o>"_dw', {noremap = true, silent = true})
vmap({"n","v"}, "<C-Del>", 'dw', {noremap = true, silent = true})

--Delete entire line (Shift + Del)
vmap("i", "<S-Del>", '<C-o>"_dd', {noremap = true})
vmap("n", "<S-Del>", '"_dd', {noremap = true})
vmap("v", "<S-Del>", '<S-v>"_d', {noremap=true}) --expand sel before del


--*[Replace]
--Typing in visual mode insert chars
local chars = utils.table_flatten(
    {
        utils.alphabet_lowercase,
        utils.alphabet_uppercase,
        utils.numbers,
        utils.punctuation,
    }
)
for _, char in ipairs(chars) do
    vmap('v', char, "<del><Esc>i"..char, {noremap=true})
end
vmap("v", "<space>", "<del>i<space>", {noremap=true})
vmap("v", "<cr>", "<del>i<cr>", {noremap=true})

--replace selection with char
vmap("v", "<F2>", "\"zy:%s/<C-r>z//g<Left><Left>", {noremap = true, silent = false })


--*[Incrementing]
--vmap("n", "+", "<C-a>")
vmap("v", "+", "<C-a>gv")

--vmap("n", "-", "<C-x>") -- Decrement
vmap("v", "-", "<C-x>gv") -- Decrement

--To upper/lower case
vmap("n", "<M-+>", "vgU<esc>", {noremap = true})
vmap("v", "<M-+>", "gUgv", {noremap = true})

vmap("n", "<M-->", "vgu<esc>", {noremap = true})
vmap("v", "<M-->", "gugv", {noremap = true})

--Smart increment/decrement
vmap({"n"}, "+", function() utils.smartincrement() end)
vmap({"n"}, "-", function() utils.smartdecrement() end)


--*[Formating]
----[Ident]
vmap("n", "<space>", "i<space><esc>")

--smart tab insert
vim.keymap.set("i", "<Tab>",
    function()
        local inword = utils.is_cursor_inside_word()
        if inword then vcmd("normal! v>") vim.cmd("normal! 4l")
        else vim.cmd("normal! i\t") --don't care about softab here
        end
    end
)
vmap("n", "<Tab>", "v>")
vmap("v", "<Tab>", ">gv")

vmap("i", "<S-Tab>", "<C-d>")
vmap("n", "<S-Tab>", "v<")
vmap("v", "<S-Tab>", "<gv")


--#[Line break]
vmap("n", "<cr>", "i<cr><esc>")

--1 above
vmap("i", "<S-cr>", "<Esc>O")
vmap("n", "<S-cr>", "O<esc>")
vmap("v", "<S-cr>", "<esc>O<esc>vgv")

--1 below
vmap("i", "<M-cr>", "<Esc>o")
vmap("n", "<M-cr>", 'o<Esc>')
vmap("v", "<M-cr>", "<Esc>o<Esc>vgv")

--New line above and below
vmap("i", "<S-M-cr>", "<esc>o<esc>kO<esc>ji")
vmap("n", "<S-M-cr>", "o<esc>kO<esc>j")


--#[Join]
vmap("v", "<C-j>", "<S-j>")

vmap("i", "<C-j>", "<Esc>vj<S-j><Esc>i") --Join one below
vmap("n", "<C-j>", "vj<S-j>")      --|


--#[move lines]
--Move char
vmap("n", "<C-S-Right>", "xp", {noremap=true, silent=true})
vmap("n", "<C-S-Left>", "x2hp", {noremap=true, silent=true})
--vmap("n", "<C-S-Up>", "xkp", {noremap=true, silent=true}) not super useful
--vmap("n", "<C-S-Down>", "xjp", {noremap=true, silent=true}) -|

--Move selection
vmap("v", "<C-S-Right>", "dplgv", {noremap=true, silent=true})
--#- a1at-

--Move whole line
vmap("i", "<C-S-Up>", "<Esc>:m .-2<CR>==i", {noremap=true})
vmap("n", "<C-S-Up>", ":m .-2<CR>==", {noremap = true, silent = true})
vmap('v', '<C-S-Up>', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

vmap("i", "<C-S-Down>", "<Esc>:m .+1<cr>==i", {noremap=true})
vmap("n", "<C-S-Down>", ":m .+1<cr>==", {noremap = true, silent = true})
vmap('v', '<c-s-down>', ":m '>+1<cr>gv=gv", {noremap = true, silent = true })


--*[Commenting]
vmap("i", "<M-a>", "<cmd>normal gcc<cr>", {remap = true}) --remap needed
vmap("n", "<M-a>", "gcc", {remap = true}) --remap needed
vmap("v", "<M-a>", "gcgv",  {remap = true}) --remap needed

--record
vmap("n", "<M-r>", "q", {remap = true})



--[code runner]----------------------------------------
vmap({"i","n"}, "<F20>", --equivalent to <S-F8>
    function()
        vim.cmd("stopinsert")
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local line = vim.fn.getline(row)
        local result = load("return " .. line)()
        vim.fn.append(row, "-> " .. vim.inspect(result))
    end
)

vmap({"i","n"}, "<F56>", --equivalent to <M-F8>
    function()
        vim.cmd("stopinsert")
        local row = vim.api.nvim_win_get_cursor(0)[1]  -- Get the current line number
        local line = vim.fn.getline(row)  -- Get the content of the current line
        vim.cmd(line)
    end
)



--[cmd]----------------------------------------
--Open command line
vmap("i", "œ", "<esc>:", {noremap=true})
vmap("n", "œ", ":", {noremap=true})
vmap("v", "œ", ":", {noremap=true})
vmap("t", "œ", "<Esc> <C-\\><C-n>", {noremap=true})

--Cmd close
vmap("c", "œ", "<Esc><cmd>echon' '<CR>") --echon' ' clear command-line

--Cmd menu nav
vmap("c", "<Up>", "<C-p>")
vmap("c", "<Down>", "<C-n>")
vmap("c", "<S-Tab>", "<C-n>")

--Accept
--vmap('c', '<cr>', '<CR>')
vmap('c', '<tab>', '<CR>')



--[Terminal]----------------------------------------
--Open term
vmap({"i","n","v"}, "<M-t>", function() v.cmd("term") end, {noremap=true})

vmap("t", "<esc>", "<Esc> <C-\\><C-n>", {noremap=true})


