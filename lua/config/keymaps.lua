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


--<esc> = \27
--<cr> = \n
--<Tab> = \t
--<C-BS> = ^H

--modes helpers
local modes = { "i", "n", "v", "o", "s", "t", "c" }



--## [Settings]
----------------------------------------------------------------------
vim.opt.timeoutlen = 300 --delay between key press to register shortcuts



--## [Internal]
----------------------------------------------------------------------
--Ctrl+q to quit
map(modes, "<C-q>", function() v.cmd("qa!") end, {noremap=true, desc="Force quit all buffer"})

--Quick restart nvim
map(modes, "<C-M-r>", "<cmd>Restart<cr>")

--F5 reload buffer
map({"i","n","v"}, '<F5>', function() vim.cmd("e!") print("'-File reloaded-'") end, {noremap = true})


--g
map("i",       '<C-g>', "<esc>g", {noremap=true})
map({"n","v"}, '<C-g>', "g",      {noremap=true})


--## [File]
----------------------------------------------------------------------
--Create new file
map({"i","n","v"}, "<C-n>", function()
    local buff_count = vim.api.nvim_list_bufs()
    local newbuff_num = #buff_count
    v.cmd("enew")
    vim.cmd("e untitled_"..newbuff_num)
end)

--Open file picker
map(modes, "<C-o>", function() vim.cmd("FilePicker") end)

--ctrl+s save
map(modes, "<C-s>", function()
    local cbuf = vim.api.nvim_get_current_buf()
    local path = vim.api.nvim_buf_get_name(0)

    if vim.fn.filereadable(path) == 1 then   --Check file exist on disk
        vim.cmd("write")
    else
        if vim.fn.confirm("File does not exist. Create it?", "&Yes\n&No", 1) == 1 then
            vim.ui.input(
                { prompt = "Save as: ", default = path, completion = "dir" },
                function(input)
                    vim.api.nvim_command("redraw") --Hide prompt

                    if input == nil or input == "" then
                        vim.notify("Creation cancelled.", vim.log.levels.INFO) return
                    end

                    vim.api.nvim_buf_set_name(cbuf, input)
                    vim.cmd("write")
                    vim.cmd("edit!") --refresh name
                end
            )
        end
    end
end)

--Save all buffers
map(modes, "<C-S-s>", function()
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
map(modes, "<M-C-S>", function()
    local cbuf = vim.api.nvim_get_current_buf()
    local path = vim.api.nvim_buf_get_name(0)

    vim.ui.input(
        { prompt = "Save as: ", default = path, completion = "dir"},
        function(input)
            vim.api.nvim_command("redraw") --Hide prompt

            if input == nil or input == "" then
                vim.notify("Save cancelled.", vim.log.levels.INFO) return
            end

            vim.api.nvim_buf_set_name(cbuf, input)
            vim.cmd("write")
            vim.cmd("edit!") --refresh name
        end
    )
end)


--Ressource curr file
map(modes, "ç", --"<altgr-r>"
    function()
        local cf = vim.fn.expand("%:p")

        vim.cmd("source "..cf)

        --broadcast
        local fname = '"'..vim.fn.fnamemodify(cf, ":t")..'"'
        vim.cmd(string.format("echo '%s ressourced'", fname))
    end
)



--## [View]
----------------------------------------------------------------------
--alt-z toggle line wrap
map({"i","n","v"}, "<A-z>", function()
    vim.opt.wrap = not vim.opt.wrap:get()  --Toggle wrap
end)

--Gutter on/off
map({"i","n"}, "<M-g>", function()
    local toggle = "yes"
    vim.opt.number = false
    vim.opt.relativenumber = false
    vim.opt.signcolumn = "no"
    vim.opt.foldenable = false
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
map( modes,"<C-t>", function() vim.cmd("Alpha") end)

--Tabs nav
--next
map(modes, "<C-Tab>",   "<cmd>bnext<cr>")
--prev
map(modes, "<C-S-Tab>", "<cmd>bp<cr>")



--## [Windows]
----------------------------------------------------------------------
map("i", "<M-w>", "<esc><C-w>")
map("n", "<M-w>", "<C-w>")
map("v", "<M-w>", "<Esc><C-w>")

--To next window
map({"i","n","v","c"}, "<M-Tab>", function()
    vim.cmd("norm! w")
end)

map("n", "<M-w>H", "<C-w>t<C-w>H",{noremap=true})
map("n", "<M-w>V", "<C-w>t<C-w>K",{noremap=true})

--resize vert
map("n", "<M-w><Left>",  ":vertical resize -5<CR>", {noremap = true})
map("n", "<M-w><Right>", ":vertical resize +5<CR>", {noremap = true})
--resize hor
map("n", "<M-w><Up>",   ":resize +5<CR>", {noremap = true})
map("n", "<M-w><Down>", ":resize -5<CR>", {noremap = true})

--Omni close
map(modes, "<C-w>", function()

    local bufid = vim.api.nvim_get_current_buf()
    local bufmodif = vim.api.nvim_get_option_value("modified", { buf = bufid })

    --check if splits point to same buf, no need to prompt in this case!
    local bufwindows = vim.fn.win_findbuf(bufid)

    if bufmodif and #bufwindows <= 1 then
        local choice = vim.fn.confirm("Unsaved changes, quit anyway? ", "&Yes\n&No", 1)
        if choice ~= 1 then return end
    end

    --try close splits first, in case both splits are same buf
    --that avoids killing the shared buffer in this case
    local ok, err = pcall(vim.cmd, "close")
    if not ok then vim.cmd("bd!") end --effectively close the tab
end)



--## [Navigation]
----------------------------------------------------------------------
map("n", "<Left>",  "<Left>",  { noremap = true })  --avoid opening folds
map("n", "<Right>", "<Right>", { noremap = true })

--Jump to next word
map({"i","v"}, '<C-Right>', function()
    local cursr_prevrow = vim.api.nvim_win_get_cursor(0)[1]

    vim.cmd("normal! w")

    if cursr_prevrow ~= vim.api.nvim_win_get_cursor(0)[1] then
        vim.cmd("normal! b")

        if vim.fn.mode() == "v" then vim.cmd("normal! $")
        else                         vim.cmd("normal! A") end
    end
end)

--Jump to previous word
map({"i","v"}, '<C-Left>', function()
    local cursr_prevrow = vim.api.nvim_win_get_cursor(0)[1]

    vim.cmd("normal! b")

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
map('n', '<C-Right>', "5l")
map('n', '<C-Left>',  "5h")

--ctrl+up/down to move fast
map("i", "<C-Up>", "<C-o>3k")
map("n", "<C-Up>", "3k")
map("v", "<C-Up>", "3k")

map("i", "<C-Down>", "<C-o>3j")
map("n", "<C-Down>", "3j")
map("v", "<C-Down>", "3j")


--alt+left/right move to start/end of line
map("i",       "<M-Left>", "<Esc>0i")
map({"n","v"}, "<M-Left>", "0")

map("i",       "<M-Right>", "<Esc>$a")
map({"n","v"}, "<M-Right>", "$")

--Quick home/end
map("i",       "<Home>", "<Esc>gg0i")
map({"n","v"}, "<Home>", "gg0")

--kmap("i",       "<M-Up>", "<Esc>gg0i")  --collide with <esc><up>
--kmap({"n","v"}, "<M-Up>", "gg0")

map("i",       "<End>", "<esc>G0i")
map({"n","v"}, "<End>", "G0")

--kmap("i", "<M-Down>", "<Esc>G0i")  --collide with <esc><up>
--kmap({"n","v"}, "<M-Down>", "G0")

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



--## [Selection]
----------------------------------------------------------------------
--Swap selection anchors
map("v", "<M-v>", "o")

--Select word under cursor
map({"i","n","v"}, "<C-S-w>", "<esc>viw")

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

--Select to home
map("i", "<S-Home>", "<Esc>vgg0i")
map("n", "<S-Home>", "vgg0")
map("v", "<S-Home>", "g0")

--select to end
map("i", "<S-End>", "<Esc>vGi")
map("n", "<S-End>", "vG")
map("v", "<S-End>", "G")

--sel in paragraph
map({"i","n","v"}, "<C-S-p>", "<esc>vip")

--ctrl+a select all
map(modes, "<C-a>", "<Esc>GGVgg")


--Visual block selection
map({"i","n"}, "<S-M-Left>", "<Esc><C-v>h")
map("v", "<S-M-Left>",
    function()
        if vim.fn.mode() == '\22' then  --"\22" is vis block mode
            vim.cmd("normal! h")
        else
            vim.cmd("normal! h")
        end
    end
)

map({"i","n"}, "<S-M-Right>", "<Esc><C-v>l")
map("v", "<S-M-Right>",
    function()
        if vim.fn.mode() == '\22' then
            vim.cmd("normal! l")
        else
            vim.cmd("normal! l")
        end
    end
)

map({"i","n"}, "<S-M-Up>", "<Esc><C-v>k")
map("v", "<S-M-Up>",
    function()
        if vim.fn.mode() == '\22' then
            vim.cmd("normal! k")
        else
            vim.cmd("normal! k")
        end
    end
)

map({"i","n"}, "<S-M-Down>", "<Esc><C-v>j")
map("v", "<S-M-Down>",
    function()
        if vim.fn.mode() == '\22' then
            vim.cmd("normal! j")
        else
            vim.cmd("normal! j")
        end
    end
)


--### [Grow select]
--grow horizontally TODO proper anchor logic
map("i", "<C-S-PageDown>", "<Esc>vl")
map("n", "<C-S-PageDown>", "vl")
map("v", "<C-S-PageDown>", "l")

map("i", "<C-S-PageUp>", "<Esc>vh")
map("n", "<C-S-PageUp>", "vh")
map("v", "<C-S-PageUp>", "oho")

--grow do end/start of line
map("i", "<S-PageUp>", "<Esc><S-v>k")
map("n", "<S-PageUp>", "<S-v>k")
map("v", "<S-PageUp>",
    function ()
        if vim.fn.mode() == "V" then
            vim.cmd("normal! k")
        else
            vim.cmd("normal! Vk")
        end
    end
)

map("i", "<S-PageDown>", "<Esc><S-v>j")
map("n", "<S-PageDown>", "<S-v>j")
map("v", "<S-PageDown>",
    function ()
        local m = vim.api.nvim_get_mode().mode
        if vim.fn.mode() == "V" then
            vim.cmd("normal! j")
        else
            vim.cmd("normal! Vj")
        end
    end
)


--#[select search]
map("i", "<C-f>", "<Esc><C-l>:/")
map("n", "<C-f>", "/")
map("v", "<C-f>", 'y<Esc><C-l>:/<C-r>"')

--search Help for selection
map("v", "<F1>", 'y:h <C-r>"<CR>')

--Search in notes
map({"i","n"}, "<F49>", function()   --<M-F1>
    require("fzf-lua").files({
        cwd = "~/Personal/KnowledgeBase/Notes/"
    })
end)
map("v", "<F49>", function()   --<M-F1>
    require("fzf-lua").grep_visual({
        cwd = "~/Personal/KnowledgeBase/Notes/"
    })
end)




--## [Editing]
----------------------------------------------------------------------
--toggle insert/normal with insert key
map("i", "<Ins>", "<Esc>")
map("n", "<Ins>", "i")
map("v", "<Ins>", function ()
    --seems to be more relyable
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>i", true, false, true), "n", false)
end)


--To Visual insert mode
map("v", "<M-i>", "I")

--Insert literal
--kmap("i", "<C-i>", "<C-v>") --collide with tab :(
map("n", "<C-i>", "i<C-v>")

--Insert snipet
--insert function()
--kmap("i", "<C-S-i>")

map("v", "î",
    function()
        if vim.fn.mode() == '\22' then  --"\22" is vis block mode
            --"$A" insert at end of each lines from vis block mode
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("$A", true, false, true), "n", false)
        else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-v>", true, false, true), "n", false)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("$A", true, false, true), "n", false)
        end
    end
)


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
map("v", "<cr>", '"_di<cr>', {noremap=true})


--#[Copy / Paste]
--Copy whole line in insert
map("i", "<C-c>", function()
    local line = vim.api.nvim_get_current_line()

    if line ~= "" then
        vim.cmd([[norm! m'0"+y$`']])
        vim.cmd("echo 'line copied!'")
    end
end, {noremap=true})

map("n", "<C-c>", function()
    local char = utils.get_char_at_cursorpos()

    if  char ~= " " and char ~= "" then
        vim.cmd('norm! "+yl')
    end
end, {noremap = true})

map("v", "<C-c>", function()
    vim.cmd('norm! m`"+y``'); print("copied")
end, {noremap=true})


--copy append selection
map("v", "<M-c>", function()
    local reg_prev = vim.fn.getreg("+")

    vim.cmd('normal! mz"+y`z')

    vim.fn.setreg("+", reg_prev .. vim.fn.getreg("+")) --apppend

    print("appended to clipboard")
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

--cut line with x
--map("n", "xx", 'dd')

--Paste
map({"i","n","v"}, "<C-v>", function()
    local mode = vim.fn.mode()
    if mode == "v" or mode == "V" or mode == "" then vim.cmd('norm! "_d') end

    vim.cmd('norm! "+P')

    --Format after paste
    local ft = vim.bo.filetype
    if ft == "markdown" or ft == "text" then
        vim.cmd("norm! `[v`]gqw")
    else
        vim.cmd("norm! `[v`]=") --auto fix ident
    end

    --proper cursor placement
    vim.cmd("norm! `]")
    if mode == "i" then vim.cmd("norm! a") end
end)

map("c", "<C-v>", '<C-R>+')
map("t", "<C-v>", '<C-o>"+P')

--paste replace word
map("i", "<C-S-v>", '<esc>"_diw"+Pa')
map("n", "<C-S-v>", '<esc>"_diw"+P')

--Duplicate
map("i", "<C-d>", '<esc>""yy""pi')
map("n", "<C-d>", '""yy""p')
map("v", "<C-d>", '""y""P')


--#[Undo/redo]
--ctrl+z to undo
map("i",       "<C-z>",   "<C-o>u", {noremap = true})
map({"n","v"}, "<C-z>",   "<esc>u", {noremap = true})

--redo
map("i",       "<C-y>",   "<C-o><C-r>")
map({"n","v"}, "<C-y>",   "<esc><C-r>")
map("i",       "<C-S-z>", "<C-o><C-r>")
map({"n","v"}, "<C-S-z>", "<esc><C-r>")


--#[Deletion]
--##[Backspace]
--BS remove char
--kmap("i", "<BS>", "<C-o>x", {noremap=true, silent=true}) --maybe not needed on wezterm
--kmap("n", "<BS>", '<Esc>"_X<Esc>')
map("n", "<BS>", 'r ')
map("v", "<BS>", '"_xi')

--remove word left
--<M-S-BS> instead of <C-BS> because of wezterm
map("i", "<M-S-BS>", '<esc>"_dbi')
map("n", "<M-S-BS>", '"_db')
map("v", "<M-S-BS>", 'r ') --clear selected char

--Backspace replace with white spaces, from cursor to line start
--kmap({"i","n"}, "<M-BS>",
    --better?
    --vim.cmd("norm! v0R ")

--    function()
--        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
--        local line = vim.api.nvim_get_current_line()

--        local left = line:sub(1, col)
--        local right = line:sub(col + 1)

--        local spaces = left:gsub(".", " ")
--        vim.api.nvim_set_current_line(spaces .. right)

--        -- Keep cursor pos
--        vim.api.nvim_win_set_cursor(0, {row, col})
--    end
--)

--Remove to start of line
map("i", "<M-BS>", '<esc>"_d0i')
map("n", "<M-BS>", '"_d0')

--Shift+backspace clear line
map("i", "<S-BS>", '<esc>"_cc')
map("n", "<S-BS>", '"_cc<esc>')
map("v", "<S-BS>", '<esc>"_cc<esc>')


--##[Delete]
map("n", "<Del>", 'v"_d<esc>')
map("v", "<Del>", '"_di')

--Delete right word
map("i",       "<C-Del>", '<C-o>"_dw')
map({"n","v"}, "<C-Del>", '"_dw')
--map("c",       "<C-Del>", '"_dw') does not work in cmd

--Delete in word
map("i", "<C-S-Del>", '<esc>"_diwi')
map("n", "<C-S-Del>", '"_diw')

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
map("i", "<M-Del>", '<Esc>"_d$i')
map("n", "<M-Del>", '"_d$')

--Delete line
map("i", "<S-Del>", '<esc>"_ddi')
map("n", "<S-Del>", '"_dd')
map("v", "<S-Del>", function()
    if vim.fn.mode() == "V" then  --avoid <S-v> on line select, because it would unselect instead
        vim.cmd('normal! "_d')
    else
        vim.cmd('normal! V"_d')
    end
end)


--#[Replace]
--replace selection with char
--kmap("n", "*", "")
--kmap("v", "*", "\"zy:%s/<C-r>z//g<Left><Left>")

map("i", "<C-S-R>", "<esc>ciw")
map("n", "<C-S-R>", "ciw")

--replace visual selection with char
map("v", "<M-r>", "r")


--substitue mode
map({"i","n"}, "<M-s>",
"<Esc>:%s/\\v//g<Left><Left><Left>",
{desc = "Enter substitue mode"})

--sub word
map("v", "<M-s>",
[[y<esc>:%s/\v<C-r>"//g<Left><Left>]],
{desc = "substitue word under cursor" })


--#[Incrementing]
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


--#[Formating]
--##[Ident]
--space bar in normal mode
map("n", "<space>", "i<space><esc>")

--tab ident
vim.keymap.set("i", "<Tab>", function()
    local width = vim.opt.shiftwidth:get()
    vim.cmd("norm! v>")
    vim.cmd("norm! ".. width .. "l")
end)

map("i", "<Tab>", function()
    local width = vim.opt.shiftwidth:get()
    vim.cmd("norm! v>")
    vim.cmd("norm! ".. width .. "l")
end)
map("n", "<Tab>", "v>")
map("v", "<Tab>", ">gv")

map("i", "<S-Tab>", "<C-d>")
map("n", "<S-Tab>", "v<")
map("v", "<S-Tab>", "<gv")

--trigger Auto ident
map("i", "<C-=>", "<C-o>==")
map("v", "<C-=>", "=")


--##[Line break]
map("n", "<cr>", "i<cr><esc>")

--breakline above
map("i", "<S-CR>", "<C-o>O")
map("n", "<S-CR>", "O<esc>")
map("v", "<S-CR>", "<esc>O<esc>vgv")

--breakline below
map("i", "<M-CR>", "<C-o>o")
map("n", "<M-CR>", 'o<Esc>')
map("v", "<M-CR>", "<Esc>o<Esc>vgv")

--New line above and below
map("i", "<S-M-cr>", "<esc>mzo<esc>kO<esc>`zi")
map("n", "<S-M-cr>", "m'o<esc>kO<esc>`'")
map("v", "<S-M-cr>", function ()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    vim.api.nvim_feedkeys("\27", "n", false)
    local anchor_start_pos = vim.fn.getpos("'<")

    if (anchor_start_pos[3]-1) ~= cursor_pos[2] then
        vim.cmd("normal! o")
    end
    vim.cmd("normal! gv")

    --vim.cmd("normal! O")
end)


--##[Join]
--Join below
map("i",       "<C-j>", "<C-o><S-j>")
map({"n","v"}, "<C-j>", "<S-j>")

--Join to upper
map("i", "<C-S-j>", "<esc>k<S-j>i")
map("n", "<C-S-j>", "k<S-j>")

--##[move text]
--Move single char
map("n", "<C-S-Right>", "xp")
map("n", "<C-S-Left>",  "xhP")
--vmap("n", "<C-S-Up>", "xkp")
--vmap("n", "<C-S-Down>", "xjp")

--Move selected text
--Move left
map("i", "<C-S-Left>", '<esc>viwdhPgvhoho')
map("v", "<C-S-Left>", function()
    local col = vim.api.nvim_win_get_cursor(0)[2]

    if vim.fn.mode() == 'v' and col > 0 then
        local cmd = 'dhP<esc>gvhoho'
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

--Move right
map("i", "<C-S-Right>", '<esc>viwdpgvlolo')
map("v", "<C-S-Right>", 'dp<esc>gvlolo')

--move selected line verticaly
map('v', '<C-S-Up>', function()
    local l1 = vim.fn.line("v") local l2 = vim.fn.line(".")
    local mode = vim.fn.mode()

    if math.abs(l1 - l2) > 0 or mode == "V" then --move whole line if multi line select
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(":m '<-2<cr>gv=gv", true, false, true), "n", false)
    else
        vim.cmd('normal! dkP')

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
        vim.cmd('normal! djP')

        local anchor_start_pos = vim.fn.getpos("'<")[3]
        vim.cmd('normal! v'..anchor_start_pos..'|') -- reselect visual selection
    end
end)

--Move whole line
map("i", "<C-S-Up>", "<Esc>:m .-2<CR>==i")
map("n", "<C-S-Up>", ":m .-2<CR>==")

map("i", "<C-S-Down>", "<Esc>:m .+1<cr>==i")
map("n", "<C-S-Down>", ":m .+1<cr>==")


--#[Comments]
map("i", "<M-a>", "<cmd>norm gcc<cr>", {remap = true}) --remap needed
map("n", "<M-a>", "gcc",   {remap = true}) --remap needed
map("v", "<M-a>", "gcgv",  {remap = true}) --remap needed


--#[Macro]
map("n", "<C-r>", "q", {remap = true})



--## [Text inteligence]
----------------------------------------------------------------------
--Goto definition
map({"i","n","v"}, "<F10>", "<esc><cmd>Trouble diagnostics toggle focus=true filter.buf=0<cr>")

map({"i","n","v"}, "<F11>", "<esc><cmd>Trouble lsp_references toggle focus=true<cr>")

map("i", "<F12>", "<Esc>gdi")
map("n", "<F12>", "<Esc>gd")
--map("n", "<F12>", ":lua vim.lsp.buf.definition()<cr>")
map("v", "<F12>", "<Esc>gd")

--show hover window
map({"i","n","v"}, "<C-h>", function() vim.lsp.buf.hover() end)

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
        vim.cmd("normal! gx")
    elseif vim.fn.filereadable(word) == 1 then
        vim.cmd("normal! gf")
    else
        vim.cmd("normal! %")
    end
    --to tag
    --<C-]>
end)

map({"i","n","v","c"}, "<M-C-PageUp>", function() vim.cmd("norm! [c") end)
map({"i","n","v","c"}, "<M-C-PageDown>", function() vim.cmd("norm! ]c") end)


--## [code runner]
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
    vim.cmd("norm! 0y$")
    vim.cmd('@"')
end)



--## [vim cmd]
----------------------------------------------------------------------
--Open command line
map("i",       "œ", "<esc>:")
map({"n","v"}, "œ", ":")
map("t",       "œ", "<Esc> <C-\\><C-n>")

--Open command line in term mode
map({"i","c"}, "<S-Œ>", "<esc>:!")
map({"n","v"}, "<S-Œ>", ":!")

--cmd completion menu
--vmap("c", "<C-d>", "<C-d>")

--Cmd menu nav
map("c", "<Up>", "<C-p>")
map("c", "<Down>", "<C-n>")

--accept
map("c", "<S-Tab>", "<C-n>")

--Clear cmd in insert
map("i", "<C-l>", "<C-o><C-l>")

--Cmd close
map("c", "œ", "<C-c><C-L>")  --needs <C-c> and not <Esc> because Neovim behaves as if <Esc> was mapped to <CR> in cmd
map("c", "<esc>", "<C-c>", {noremap=true})

--Easy exit command line window
vim.api.nvim_create_autocmd({ "CmdwinEnter" }, {
    callback = function()
        vim.keymap.set("n", "<esc>", ":quit<CR>", {buffer=true})
    end,
})



--## [Terminal]
----------------------------------------------------------------------
--Open term
map({"i","n","v"}, "<M-t>",  function() v.cmd("term") end, {noremap=true})

--quick split term
map({"i","n","v"}, "<M-w>t", function()
    vim.cmd("vsp|term")
    local bufid = vim.api.nvim_get_current_buf()
    vim.api.nvim_set_option_value("buflisted", true,   { buf = bufid })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufid })
end, {noremap=true})

--exit
map("t", "<esc>", "<Esc> <C-\\><C-n>", {noremap=true})



