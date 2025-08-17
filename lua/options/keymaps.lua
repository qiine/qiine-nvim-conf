-- _
--| |
--| | _____ _   _ _ __ ___   __ _ _ __  ___
--| |/ / _ \ | | | '_ ` _ \ / _` | '_ \/ __|
--|   <  __/ |_| | | | | | | (_| | |_) \__ \
--|_|\_\___|\__, |_| |_| |_|\__,_| .__/|___/
--           __/ |               | |
--          |___/                |_|

local utils = require("utils.utils")

local v   = vim
local map = vim.keymap.set
----------------------------------------


--modes helpers
local modes = { "i", "n", "v", "o", "s", "t", "c" }



--## [Settings]
----------------------------------------------------------------------
vim.opt.timeoutlen = 375 --delay between key press to register shortcuts



--## [Internal]
----------------------------------------------------------------------
--Ctrl+q to quit
map(modes, "<C-q>", "<cmd>qa!<CR>", {noremap=true, desc="Force quit nvim"})

--Quick restart nvim
map(modes, "<C-M-r>", "<cmd>Restart<cr>")

--F5 reload buffer
map({"i","n","v"}, '<F5>', "<cmd>e!<CR><cmd>echo'-File reloaded-'<CR>", {noremap=true})

--g
map("i",       '<C-g>', "<esc>g", {noremap=true})
map({"n","v"}, '<C-g>', "g",      {noremap=true})



--## [Buffers]
----------------------------------------------------------------------
--Create new buffer
map({"i","n","v"}, "<C-n>", function()
    local buff_count  = vim.api.nvim_list_bufs()
    local newbuff_num = #buff_count
    v.cmd("enew"); vim.cmd("e untitled_"..newbuff_num)
end)

--reopen prev
map(modes, "<C-S-t>", "<cmd>OpenLastClosedBuf<cr>")

--Omni close
map(modes, "<C-w>", function()
    local bufid      = vim.api.nvim_get_current_buf()
    local buftype    = vim.api.nvim_get_option_value("buftype", {buf=bufid})
    local bufmodif   = vim.api.nvim_get_option_value("modified", {buf=bufid})
    local bufwindows = vim.fn.win_findbuf(bufid)

    --custom save warning if buf modified and it is it's last win
    if bufmodif and #bufwindows <= 1 then
        local choice = vim.fn.confirm("Unsaved changes, quit anyway? ", "&Yes\n&No", 1)
        if choice ~= 1 then return end
    end

    --close cmdline before
    if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("<C-L>", "n", false) end

    --try :close splits first, in case both splits are same buf
    --It avoids killing the shared buffer in this case
    local ret, err = pcall(vim.cmd, "close")
    if not ret then
        if buftype == "terminal" then
            vim.cmd("bwipeout!")
        else
            vim.cmd("bwipeout!")
            --vim.cmd("bd!")
            --can also close tabs,
            --bypass save warnings,
            --not bwipeout to preserve #file
        end
    end
end, {noremap=true})



--## [Register]
----------------------------------------------------------------------
map("n", "<C-r>", "i<C-r>")



--## [Files]
----------------------------------------------------------------------
--Open file picker
map(modes, "<C-o>", "<cmd>FilePicker<CR>")

map(modes, "<C-s>", "<cmd>FileSaveInteractive<CR>")

--Save all buffers
map(modes, "<M-S-s>", function()
    local bufs = vim.api.nvim_list_bufs()
    for _, buf in ipairs(bufs) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.fn.filereadable(vim.api.nvim_buf_get_name(buf)) == 1 then
            --nvim_buf_call Ensure proper bufs info
            vim.api.nvim_buf_call(buf, function()
                if vim.bo.modifiable and not vim.bo.readonly and vim.bo.buftype == "" then
                    vim.cmd("write") --we can safely write
                end
            end)
        end
    end
end)

--save as
map(modes, "<C-M-s>", "<cmd>FileSaveAsInteractive<CR>")


--Ressource curr file
map(modes, "ç", function()  --"<altgr-r>"
    local cf    = vim.fn.expand("%:p")
    local fname = '"'..vim.fn.fnamemodify(cf, ":t")..'"'

    vim.cmd("source "..cf); print("Ressourced: "..fname)
end)

map(modes, "<C-g>fd", "<cmd>FileDelete<CR>")



--## [View]
----------------------------------------------------------------------
--alt-z toggle line wrap
map({"i","n","v"}, "<A-z>", function()
    vim.opt.wrap = not vim.opt.wrap:get()
end)

--Gutter on/off
map({"i","n"}, "<M-g>", function()
    if vim.g.gutter_show then
        vim.g.gutter_show = false

        vim.wo.statuscolumn   = ""
        vim.wo.signcolumn     = "no"
        vim.wo.number         = false
        vim.wo.relativenumber = false
        vim.wo.foldcolumn     = "0"
    else
        local confp = vim.fn.stdpath("config")
        vim.cmd("so ".. confp .."/lua/plugins/ui/editor/statuscol.lua")
        vim.cmd("so ".. confp .."/init.lua")
        vim.cmd("so ".. confp .."/lua/config/ui/view.lua")
    end
end, {desc = "Toggle Gutter" })


--#[Folding]
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
map("n", "gl", "<cmd>Toggle_VirtualLines<CR>", {noremap=true})



--## [Tabs]
----------------------------------------------------------------------
--create new tab
map(modes,"<C-t>", function() vim.cmd("Alpha") end)

--Tabs nav
--next
map(modes, "<C-Tab>",   "<cmd>bnext<cr>")
--prev
map(modes, "<C-S-Tab>", "<cmd>bp<cr>")



--## [Windows]
----------------------------------------------------------------------
map({"i","n","v"}, "<M-w>", "<esc><C-w>",   {noremap=true})
map("t", "<M-w>", "<Esc> <C-\\><C-n><C-w>", {noremap=true})

--make ver split
map(modes, "<M-w>s", "<cmd>vsp<cr>") --default nvim sync both, we don't want that
--make hor split
map(modes, "<M-w>h", "<cmd>new<cr>")

--To next window (include splits)
map(modes, "<M-Tab>", "<cmd>wincmd w<cr>")

--focus split
map(modes, "<M-w>f", "<cmd>wincmd |<cr><cmd>wincmd _<cr>")

--resize hor
map("n", "<M-w><Up>",   ":resize +5<CR>", {noremap = true})
map("n", "<M-w><Down>", ":resize -5<CR>", {noremap = true})
--resize vert
map("n", "<M-w><Left>",  ":vert resize -5<CR>", {noremap = true})
map("n", "<M-w><Right>", ":vert resize +5<CR>", {noremap = true})

--open new win
map(modes, "<M-w>n", function ()
    local wopts = {
        split = "right",
        height = 30,
        width = 20
    }
    vim.api.nvim_open_win(0, true, wopts)
end)

--detach win
map(modes, "<M-w>d", function()
    --TODO
    --the idea would be to close curr win save its buff and reopen as split and carry prev settings

    --local buf = vim.api.nvim_get_current_buf()
    --local winid = vim.api.nvim_get_current_win()
    --local wopts = vim.api.nvim_win_get_config(winid)

    --wopts.relative = "editor"
    --wopts.col = 20
    --wopts.row = 20

    --vim.api.nvim_win_set_config(winid, wopts)
end)



--## [Navigation]
----------------------------------------------------------------------
map("n", "<Left>",  "<Left>",  { noremap = true })  --avoid opening folds
map("n", "<Right>", "<Right>", { noremap = true })

--Jump to next word
map({"i","v"}, '<C-Right>', function()
    local cursr_prevrow = vim.api.nvim_win_get_cursor(0)[1]

    if vim.fn.mode() == "" then vim.cmd("norm! 5l")
    else                          vim.cmd("normal! w") end

    if cursr_prevrow ~= vim.api.nvim_win_get_cursor(0)[1] then
        vim.cmd("normal! b")
        local m = vim.fn.mode()
        if   m == "v" or m == "V" then vim.cmd("norm! $")
        else                           vim.cmd("norm! A") end
    end
end)

--Jump to previous word
map({"i","v"}, '<C-Left>', function()
    local cursr_prevrow = vim.api.nvim_win_get_cursor(0)[1]

    if vim.fn.mode() == "" then vim.cmd("norm! 5h")
    else
        vim.cmd("normal! b")
    end

    if cursr_prevrow ~= vim.api.nvim_win_get_cursor(0)[1] then
        vim.cmd("normal! w")
        vim.cmd("normal! 0")
    end
end)

--to next/prev cursor jump loc
map({"i","v"}, "<M-PageDown>",  "<Esc><C-o>")
map("n",       "<M-PageDown>",  "<C-o>")
map({"i","v"}, "<M-PageUp>",    "<Esc><C-i>")
map("n",       "<M-PageUp>",    "<C-i>")


--#[Fast cursor move]
--Fast left/right move in normal mode
map('n', '<C-Right>', "m'5l")
map('n', '<C-Left>',  "m'5h")

--ctrl+up/down to move fast
map("i",       "<C-Up>", "<esc>m'3ki")
map({"n","v"}, "<C-Up>", "m'3k")

map("i",       "<C-Down>", "<esc>m'3ji")
map({"n","v"}, "<C-Down>", "m'3j")


--alt+left/right move to start/end of line
map("i",       "<M-Left>", "<Esc>m'0i")
map({"n","v"}, "<M-Left>", "m'0")

map("i",       "<M-Right>", "<Esc>m'$a")
map({"n","v"}, "<M-Right>", "m'$")

--jump home/end
map("i",       "<Home>", "<Esc>gg0i")
map({"n","v"}, "<Home>", "gg0")

--kmap("i",       "<M-Up>", "<Esc>gg0i")  --collide with <esc><up>
--kmap({"n","v"}, "<M-Up>", "gg0")

map("i",       "<End>", "<Esc>G$a")
map({"n","v"}, "<End>", "G$")

--kmap("i", "<M-Down>", "<Esc>G$i")  --collide with <esc><up>
--kmap({"n","v"}, "<M-Down>", "G$")

--jump to word
--function JumpToCharAcrossLines(target)
--    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
--    local lines = vim.api.nvim_buf_get_lines(0, row - 1, -1, false)

--    -- Adjust first line to start at current column
--    lines[1] = lines[1]:sub(col + 2)

--    local total_offset = col + 1

--    for i, line in ipairs(lines) do
--        local index = line:find(target, 1, true)
--        if index then
--            local target_row = row + i - 1
--            local target_col = (i == 1) and col + index or index - 1
--            vim.api.nvim_win_set_cursor(0, { target_row, target_col })
--            return
--        end
--    end
--end

map("n", "f", function()
    --JumpToCharAcrossLines()
end, {remap = true})


--### search
map({"i","n","v","c"}, "<C-f>", function()
    vim.fn.setreg("/", "") --clear last search and hl
    vim.opt.hlsearch = true

    --proper clear and exit cmd mode
    if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "n", false) end

    if vim.fn.mode() ~= "v" then
        vim.api.nvim_feedkeys([[/\V]], "n", false) --need feedkey, avoid glitchy cmd
    else
        vim.api.nvim_feedkeys([[y/\V"]], "n", false)
    end
end)

--search Help for selection
map("v", "<F1>", 'y:h <C-r>"<CR>')


--### Directory nav
--Move one dir up
map({"i","n","v"}, "<C-Home>", "<cmd>cd ..<CR><cmd>pwd<CR>")

--to last directoy
map({"i","n","v"}, "<M-Home>", "<cmd>cd -<CR><cmd>pwd<CR>")

--Interactive cd
map({"i","n","v","c"}, "<C-End>", function()
    vim.api.nvim_feedkeys(":cd ", "n", false)
    vim.api.nvim_feedkeys("	", "c", false) --triggers comp menu
end)

--cd file dir
map(modes, "<C-p>f", "<cmd>cd %:p:h | pwd<CR>")

--cd project root
map(modes, "<C-p>p", function()
    local res = vim.system({"git", "rev-parse", "--show-toplevel"}, {text=true}):wait()
    if res.code ~= 0 then
        vim.notify("Not inside a Git repo:"..res.stderr, vim.log.levels.ERROR) return
    end
    local groot = vim.trim(res.stdout) --trim white space to avoid surprises

    vim.cmd("cd " .. groot); vim.cmd("pwd")
end)



--## [Selection]
----------------------------------------------------------------------
--Swap selection anchors
map("v", "<M-v>", "o")

--### Visual selection
--shift+arrows visual select
map("i", "<S-Left>", "<Esc>hv",  {noremap = true})
map("n", "<S-Left>", "vh",       {noremap = true})
map("v", "<S-Left>", "<Left>")

map("i", "<S-Right>", "<Esc>v",  {noremap = true}) --note the v without l for insert only
map("n", "<S-Right>", "vl",      {noremap = true})
map("v", "<S-Right>", "<Right>")

map({"i","n"}, "<S-Up>",    "<Esc>vk", {noremap=true})
map("v",       "<S-Up>",    "k",       {noremap=true}) --avoid fast scrolling around

map({"i","n"}, "<S-Down>", "<Esc>vj",  {noremap=true})
map("v",       "<S-Down>", "j",        {noremap=true}) --avoid fast scrolling around

--Select word under cursor
map({"i","n","v"}, "<C-S-w>", "<esc>viw")

--sel in paragraph
map({"i","n","v"}, "<C-S-p>", "<esc>vip")

--Select to home/end
map({"i","n","v"}, "<S-Home>", "<esc>vgg0")
map({"i","n","v"}, "<S-End>",  "<Esc>vG$")

--ctrl+a select all
map(modes, "<C-a>", "<Esc>G$vgg0")


--### Grow select
--grow horizontally TODO proper anchor logic
map("i", "<C-S-PageDown>", "<Esc>vl")
map("n", "<C-S-PageDown>", "vl")
map("v", "<C-S-PageDown>", "l")

map("i", "<C-S-PageUp>", "<Esc>vh")
map("n", "<C-S-PageUp>", "vh")
map("v", "<C-S-PageUp>", "oho")

--grow do end/start of line
map({"i","n"}, "<S-PageUp>", "<esc>Vk")
map("v", "<S-PageUp>", function()
    if vim.fn.mode() == "V" then
        vim.cmd("norm! k")
    else
        vim.cmd("norm! Vk")
    end
end)

map({"i","n"}, "<S-PageDown>", "<esc>Vj")
map("v", "<S-PageDown>", function()
    if vim.fn.mode() == "V" then
        vim.cmd("norm! j")
    else
        vim.cmd("norm! Vj")
    end
end)


--### Visual block selection
map({"i","n"}, "<S-M-Left>", "<Esc><C-v>h")
map("v", "<S-M-Left>", function()
    if vim.fn.mode() == '\22' then  --"\22" is vis block mode
        vim.cmd("norm! h")
    else
        vim.cmd("norm! h")
    end
end)

map({"i","n"}, "<S-M-Right>", "<Esc><C-v>l")
map("v", "<S-M-Right>", function()
    if vim.fn.mode() == '\22' then
        vim.cmd("norm! l")
    else
        vim.cmd("norm! l")
    end
end)

map({"i","n"}, "<S-M-Up>", "<Esc><C-v>k")
map("v", "<S-M-Up>", function()
    if vim.fn.mode() == '\22' then
        vim.cmd("norm! k")
    else
        vim.cmd("norm! k")
    end
end)

map({"i","n"}, "<S-M-Down>", "<Esc><C-v>j")
map("v", "<S-M-Down>", function()
    if vim.fn.mode() == '\22' then
        vim.cmd("norm! j")
    else
        vim.cmd("norm! j")
    end
end)



--## [Editing]
----------------------------------------------------------------------
--toggle insert/normal with insert key
map("i", "<Ins>", "<Esc>")
map("n", "<Ins>", "i")
map("v", "<Ins>", function ()
    --seems to be more reliable
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>i", true, false, true), "n", false)
end)
map("c", "<Ins>", "<C-c>i")


--To Visual insert mode
map("v", "<M-i>", "I")

map("v", "î", function()
    if vim.fn.mode() == '\22' then  --"\22" is vis block mode
        --"$A" insert at end of each lines from vis block mode
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("$A", true, false, true), "n", false)
    else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-v>", true, false, true), "n", false)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("$A", true, false, true), "n", false)
    end
end)

--Insert chars in visual mode
local chars = utils.table_flatten(
    {
        utils.alphabet_lowercase,
        utils.alphabet_uppercase,
        utils.numbers,
        utils.punctuation,
    }
)
for _, char in ipairs(chars) do
    map('v', char, '"_d<esc>i'..char, {noremap=true})
end
map("v", "<space>", '"_di<space>', {noremap=true})
map("v", "<cr>",    '"_di<cr>',    {noremap=true})


--Insert literal
--TODO update wezterm? so we can use C-i again without coliding with Tab
--map("i", "<C-i>l", "<C-v>", {noremap=true})
map("n", "<C-i>l", "i<C-v>")

--Insert digraph
map("n", "<C-S-k>", "i<C-S-k>")


--### Insert snipet
--insert function()
--kmap("i", "<C-S-i>")

--map("i", "<C-i>sf", "")

--insert print snippet
map({"n","v"}, "Ô", function()
    local txt = ""
    if vim.fn.mode() == "n"
    then txt = '""'
    else
        vim.cmd('norm! "zy')
        txt = vim.trim(vim.fn.getreg("z"))
        vim.cmd('norm! o')
    end

    local snip
    local ft = vim.bo.filetype
    if ft == "lua" then
        snip = string.format('print(%s)', txt)
    elseif ft == "python" then
        snip = string.format('print(%s)', txt)
    elseif ft == "javascript" or ft == "typescript"
    then
        snip = string.format('console.log(%s);', txt)
    elseif ft == "c" or ft == "cpp" then
        snip = string.format('printf("%s\\n"); // %s', txt, txt)
    end

    vim.cmd('norm! i' .. snip)
end)


--#[Copy / Paste]
--Copy whole line in insert
map("i", "<C-c>", function()
    local line = vim.api.nvim_get_current_line()

    if line ~= "" then
        vim.cmd([[norm! m`0"+y$``]])
        vim.cmd("echo 'line copied'")
    end
end, {noremap=true})

map("n", "<C-c>", function()
    local char = utils.get_char_at_cursorpos()

    if char ~= " " and char ~= "" then
        vim.cmd('norm! "+yl')
    end
end, {noremap = true})

map("v", "<C-c>", function()
    vim.cmd('norm! m`"+y``'); print("selection copied")
end, {noremap=true})


--copy append selection
map("v", "<M-c>", function()
    local reg_prev = vim.fn.getreg("+")

    vim.cmd('norm! mz"+y`z')

    vim.fn.setreg("+", reg_prev .. vim.fn.getreg("+"))

    print("Appended to clipboard")
end)


--Copy word
map({"i","n","v"}, "<C-S-c>", function()
    vim.cmd('norm! m`viw"+y``'); print("Word Copied")
end, {noremap=true})

--cut
map("i", "<C-x>", '<esc>0"+y$"_ddi', {noremap = true}) --cut line
map("n", "<C-x>", '"+x',             {noremap = true})
map("v", "<C-x>", '"+d<esc>',        {noremap = true}) --d both delete and copy so..

--cut word
map("i", "<C-S-x>", '<esc>viw"+xi')
map("n", "<C-S-x>", 'viw"+x')
map("v", "<C-S-x>", '<esc>m`viw"+x``:echo"Word Cut"<CR>')

--Paste
map({"i","n","v"}, "<C-v>", function()
    local mode = vim.fn.mode()
    if mode == "v" or mode == "V" or mode == "" then vim.cmd('norm! "_d') end

    vim.cmd('norm! "+P') --paste from clipboard

    --Format after paste
    local ft = vim.bo.filetype

    if ft == "" then
        --no formating
    elseif ft == "markdown" or ft == "text" then
        vim.cmd("norm! `[v`]gqw")
    else
        vim.cmd("norm! `[v`]=") --auto fix indent
    end

    --proper curso placement
    vim.cmd("norm! `]")
    if mode == "i" then vim.cmd("norm! a") end
end)

map("c", "<C-v>", '<C-R>+')
map("t", "<C-v>", '<Esc> <C-\\><C-n>"+Pi') --TODO kinda weird

--paste replace word
map("i", "<C-S-v>", '<esc>"_diw"+Pa')
map("n", "<C-S-v>", '<esc>"_diw"+P')

--Duplicate
map({"i","n"}, "<C-d>", function() vim.cmd('norm!"zyy'..vim.v.count..'"zp') end, {desc="dup line"})
map("v", "<C-d>", '"zy"zP', {desc="dup sel"})


--#[Undo/redo]
--ctrl+z to undo
map("i",       "<C-z>",   "<C-o>u", {noremap = true})
map({"n","v"}, "<C-z>",   "<esc>u", {noremap = true})

--redo
map("i",       "<C-y>",   "<C-o><C-r>")
map({"n","v"}, "<C-y>",   "<esc><C-r>")
map("i",       "<C-S-z>", "<C-o><C-r>")
map({"n","v"}, "<C-S-z>", "<esc><C-r>")


--### Deletion
--#### Remove
--Remove char
--kmap("i", "<BS>", "<C-o>x", {noremap=true, silent=true}) --maybe not needed on wezterm
--kmap("n", "<BS>", '<Esc>"_X<Esc>')
map("n", "<BS>", 'r ')
map("v", "<BS>", '"_xi')

--Remove word left
--<M-S-BS> instead of <C-BS> because of wezterm
map("i", "<M-S-BS>", '<esc>"_dbi')
map("n", "<M-S-BS>", '"_db')

--Remove to start of line
map("i",       "<M-BS>", '<esc>"_d0i')
map({"n","v"}, "<M-BS>", '<esc>"_d0')


--Clear selected char
map("v", "<M-S-BS>", 'r ') --TODO better keybind hack with westerm

--Clear from cursor to sol
--kmap({"i","n"}, "<M-BS>", "<cmd>norm! v0r <CR>"

--Clear line
map({"i","n","v"}, "<S-BS>", "<cmd>norm!Vr <CR>")



--### Del
map("n", "<Del>", 'v"_d<esc>')
map("v", "<Del>", '"_di')

--Delete right word
map("i",       "<C-Del>", '<C-o>"_dw')
map({"n","v"}, "<C-Del>", '"_dw')
--map("c",       "<C-Del>", '"_dw') does not work in cmd bc not a buf

--Delete in word
map({"i","n"}, "<C-S-Del>", '<cmd>norm!"_diw<CR>')
map("v",       "<C-S-Del>", '<esc>"_diwgv')

--Smart delete in
map({"i","n"}, "<C-M-Del>", function()
    local delete_commands = {
        ["("] = '"_di(', [")"] = '"_di(',
        ["["] = '"_di[', ["]"] = '"_di[',
        ["{"] = '"_di{', ["}"] = '"_di{',
        ["<"] = '"_di<', [">"] = '"_di<',

        ['"'] = '"_di"',
        ["'"] = '"_di',
        ["`"] = '"_di`',
    }

    local crow, ccol = unpack(vim.api.nvim_win_get_cursor(0))
    local cline = vim.fn.getline(crow)

    local pchar =  cline:sub(ccol, ccol)
    local cchar =  cline:sub(ccol+1, ccol+1)
    local nchar =  cline:sub(ccol+2, ccol+2)

    local pcommand = delete_commands[pchar]
    local ccommand = delete_commands[cchar]
    local ncommand = delete_commands[nchar]

    if ccommand then
        vim.cmd("normal! " .. ccommand ) return
    elseif pcommand then
        vim.cmd("normal! h" .. pcommand ) return
    elseif ncommand then
        vim.cmd("normal! l" .. ncommand ) return
    end
end)

--del to end of line
map({"i","n"}, "<M-Del>", '<cmd>norm!"_d$<CR>')
map("v",       "<M-Del>", '<esc>"_d$')

--Delete line
map({"i","n"}, "<S-Del>", '<cmd>norm!"_dd<CR>')
map("v",       "<S-Del>", function()
    if vim.fn.mode() == "V" then
        vim.cmd('norm!"_d')
    else
        vim.cmd('norm!V"_d')
    end
end)


--### Replace
--change in word
map({"i","n"}, "<C-S-r>", '<esc>"_ciw')

--replace visual selection with char
map("v", "<M-r>", "r")


-- Substitue mode
map({"i","n"}, "<M-s>",
[[<Esc>:%s/\V//g<Left><Left><Left>]]
,{desc = "Enter substitue mode"})


-- Substitue word
map({"i","n","v"}, "<C-S-s>",
[[<esc>yiw:%s/\V<C-r>"//g<Left><Left>]],
{desc = "Substitue word under cursor" })

-- Substitue in selection
map("v", "<M-s>",
[[<esc>:'<,'>s/\V//g<Left><Left><Left>]],
{desc = "Enter substitue mode in selection"})


--### Incrementing
--vmap("n", "+", "<C-a>")
map("v", "+", "<C-a>gv")

--vmap("n", "-", "<C-x>") --Decrement
map("v", "-", "<C-x>gv") --Decrement

--To upper/lower case
map("n", "<M-+>", "vgU<esc>")
map("v", "<M-+>", "gUgv")

map("n", "<M-->", "vgu<esc>")
map("v", "<M-->", "gugv")

--Smart increment/decrement
map({"n"}, "+", function() utils.smartincrement() end)
map({"n"}, "-", function() utils.smartdecrement() end)


--### Formating
--#### Indentation
--space bar in normal mode
map("n", "<space>", "i<space><esc>")

--tab indent
map("i", "<Tab>", function()
    local width = vim.opt.shiftwidth:get()
    vim.cmd("norm! v>")
    vim.cmd("norm! ".. width .. "l") --smartly move cursor
end)
map("n", "<Tab>", "v>")
map("v", "<Tab>", ">gv")

map("i", "<S-Tab>", "<C-d>")
map("n", "<S-Tab>", "v<")
map("v", "<S-Tab>", "<gv")

--trigger Auto ident
map({"i","n"}, "<C-=>", "<esc>==")
map("v",       "<C-=>", "=")


--##[Line break]
map("n", "<cr>", "i<CR><esc>")

--breakline above
map({"i","n"}, "<S-CR>", "<cmd>norm!O<CR>")
map("v",       "<S-CR>", "<esc>O<esc>gv")

--breakline below
map({"i","n"}, "<M-CR>", '<cmd>norm!o<CR>')
map("v",       "<M-CR>", "<esc>o<esc>vgv")

--New line above and below
map({"i","n"}, "<S-M-cr>", "<cmd>norm!m`o<CR><cmd>norm!kO<CR><cmd>norm!``<CR>")
map("v", "<S-M-cr>", function ()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    vim.api.nvim_feedkeys("\27", "n", false)
    local anchor_start_pos = vim.fn.getpos("'<")

    if (anchor_start_pos[3]-1) ~= cursor_pos[2] then
        vim.cmd("normal! o")
    end
    vim.cmd("norm! gv")

    --vim.cmd("normal! O")
end)

--##[Join]
--Join below
map("i",       "<C-j>", "<C-o><S-j>") --this syntax allow to use motions
map({"n","v"}, "<C-j>", "<S-j>")

--Join to upper
map("i", "<C-S-j>", "<esc>k<S-j>i") --this syntax allow to use motions
map("n", "<C-S-j>", "k<S-j>")

--##[move text]
--Move single char
map("n", "<C-S-Right>", '"zx"zp')
map("n", "<C-S-Left>",  '"zxh"zP')
--vmap("n", "<C-S-Up>", '"zxk"zp')
--vmap("n", "<C-S-Down>", '"zxj"zp')

--Move word right
map("i", "<C-S-Left>",  '<esc>viw"zdh"zPgvhoho')
map("i", "<C-S-Right>", '<esc>viw"zd"zpgvlolo')

--Move selected text
--Move left
map("v", "<C-S-Left>", function()
    local col = vim.api.nvim_win_get_cursor(0)[2]

    if vim.fn.mode() == 'v' and col > 0 then
        local cmd = '"zdh"zP<esc>gvhoho'
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd, true, false, true), "n", false)

        local cursor_pos = vim.api.nvim_win_get_cursor(0)

        --Tricks to refresh vim.fn.getpos("'<")
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>gv', true, false, true), "n", false)
        local anchor_start_pos = vim.fn.getpos("'<")

        if (anchor_start_pos[3]-1) ~= cursor_pos[2] then
            vim.cmd("normal! o")
        end

        --maybe wrap to next/prev line ?
    end
end)

--Move selection right
map("v", "<C-S-Right>", '"zd"zp<esc>gvlolo')

--move selected line verticaly
map('v', '<C-S-Up>', function()
    local l1 = vim.fn.line("v") local l2 = vim.fn.line(".")
    local mode = vim.fn.mode()

    if math.abs(l1 - l2) > 0 or mode == "V" then --move whole line if multi line select
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(":m '<-2<cr>gv=gv", true, false, true), "n", false)
    else
        vim.cmd('normal! "zdk"zP')

        local anchor_start_pos = vim.fn.getpos("'<")[3]
        vim.cmd('normal! v'..anchor_start_pos..'|') -- reselect visual selection
    end
end)

map('v', '<C-S-Down>', function ()
    local l1 = vim.fn.line("v") local l2 = vim.fn.line(".")
    local mode = vim.fn.mode()

    if math.abs(l1 - l2) > 0 or mode == "V" then --move whole line if multi line select
        vim.api.nvim_feedkeys( vim.api.nvim_replace_termcodes(":m '>+1<cr>gv=gv", true, false, true), "n", false)
    else
        vim.cmd('normal! "zdj"zP')

        local anchor_start_pos = vim.fn.getpos("'<")[3]
        vim.cmd('normal! v'..anchor_start_pos..'|') -- reselect visual selection
    end
end)

--Move line
map({'i','n'}, '<C-S-Up>', function()vim.cmd('m.-'..(vim.v.count1+1)..'|norm!==')end, {desc='Move curr line up'})
map({'i','n'}, '<C-S-Down>', function()vim.cmd('m.'..vim.v.count1..'|norm!==')end, {desc='Move curr line down'})


--#[Comments]
map({"i","n"}, "<M-a>", "<cmd>norm gcc<cr>", {noremap = true})
map("v",       "<M-a>", "gcgv", {remap = true})


--#[Macro]
--map("n", "<C-r>", "q", {remap = true})



--## [Text inteligence]
----------------------------------------------------------------------
--diag panel
map({"i","n","v"}, "<F10>", "<cmd>Trouble diagnostics toggle focus=true filter.buf=0<cr>")

--ref panel
map({"i","n","v"}, "<F11>", "<cmd>Trouble lsp_references toggle focus=true<cr>")

--Goto definition
map("i", "<F12>", "<Esc>gdi")
map("n", "<F12>", "<Esc>gd")
--map("n", "<F12>", ":lua vim.lsp.buf.definition()<cr>")
map("v", "<F12>", "<Esc>gd")

--show hover window
map({"i","n","v"}, "<C-h>", "<cmd>lua vim.lsp.buf.hover()<CR>")

--rename symbol
--vmap({"i","n"}, "<F2>", function()
--    vim.api.nvim_create_autocmd({ "CmdlineEnter" }, {
--        callback = function()
--            local key = vim.api.nvim_replace_termcodes("<C-f>", true, false, true)
--            vim.api.nvim_feedkeys(key, "c", false)
--            return true
--        end,
--    })
--    vim.lsp.buf.rename()
--end)

--lsp rename
map({"i","n"}, "<F2>", function()
    --live-rename is a plugin for fancy in buffer rename preview
    require("live-rename").rename({ insert = true })
end)

--smart contextual action
map({"i","n","v"}, "<C-CR>", function()
    local word = vim.fn.expand("<cfile>")
    local cchar = utils.get_char_at_cursorpos()
    local filetype = vim.bo.filetype

    if word:match("^https?://") then
        vim.cmd("norm! gx")
    elseif vim.fn.filereadable(word) == 1 then
        vim.cmd("norm! gf")
    else
        vim.cmd("norm! %")
    end
    --to tag
    --<C-]>
end)


--### Diff
--next/prev diff
map({"i","n","v","c"}, "<M-S-PageUp>", function()
    if vim.wo.diff then
        vim.cmd("norm! [cz.")
    else
        require('gitsigns').nav_hunk('prev')
    end
end)
map({"i","n","v","c"}, "<M-S-PageDown>", function()
    if vim.wo.diff then
        vim.cmd.normal({']cz.', bang = true})
    else
        require('gitsigns').nav_hunk('next')
    end
end)


--diff put
map({"i","n"}, "<C-g>dp", "<cmd>.diffput<cr>")
map("v",       "<C-g>dp", "<cmd>:'<,'>diffput<cr>")

--diff get
map({"i","n"}, "<C-g>dg", "<cmd>.diffget<cr>")
map("v",       "<C-g>dg", "<cmd>:'<,'>diffget<cr>")



--## [Version control]
----------------------------------------------------------------------
map({"i","n","v"}, "<C-g>gc", "<cmd>GitCommitFile<cr>", {noremap=true})



--## [Code runner]
----------------------------------------------------------------------
--run code at cursor with sniprun
--run curr line only and insert res below
map({"i","n"}, "<F32>","<cmd>SnipRunLineInsertResult<CR>")

--<F20> equivalent to <S-F8>
--run selected code in visual mode
map("v", "<F20>","<cmd>SnipRunSelectedInsertResult<CR>")

--run whole file until curr line and insert
map({"i","n"},"<F20>","<cmd>SnipRunToLineInsertResult<CR>")


--exec curr line as ex command
--map({"i","n"}, "<F56>", '<esc>0y$:<C-r>"<CR>')
map({"i","n","v"}, "<F56>", function()
    vim.cmd('norm! 0"zy$')
    vim.cmd('@z')
end)



--## [vim cmd]
----------------------------------------------------------------------
--Open command line
map("i",       "œ", "<esc>:")
map({"n","v"}, "œ", ":")
map("t",       "œ", "<Esc><C-\\><C-n>:")

--Open command line in term mode
map({"i","c"}, "<S-Œ>", "<esc>:!")
map({"n","v"}, "<S-Œ>", ":!")

--cmd completion menu
--vmap("c", "<C-d>", "<C-d>")

--Cmd menu nav
map("c", "<Up>", "<C-p>")
map("c", "<Down>", "<C-n>")

map("c", "<S-Tab>", "<C-n>")

--Clear cmd in insert
map("i", "<C-l>", "<C-o><C-l>")

--Cmd close
map("c", "œ", "<C-c><C-L>")  --needs <C-c> and not <Esc> because Neovim behaves as if <Esc> was mapped to <CR> in cmd
--map("c", "<esc>", "<C-c>", {noremap=true})

--Easy exit command line window
vim.api.nvim_create_autocmd({ "CmdwinEnter" }, {
    callback = function()
        vim.keymap.set("n", "<esc>", ":quit<CR>", {buffer=true})
    end,
})



--## [Terminal]
----------------------------------------------------------------------
--Open term
map({"i","n","v"}, "<M-t>", "<cmd>term<CR>", {noremap=true})

--quick split term
map({"i","n","v"}, "<M-w>t", function()
    vim.cmd("vsp|term")

    vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
    vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})
end, {noremap=true})

--exit
map("t", "<esc>", "<Esc> <C-\\><C-n>", {noremap=true})
