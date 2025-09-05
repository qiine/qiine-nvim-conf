
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


--## [Settings]
----------------------------------------------------------------------
vim.opt.timeoutlen = 375 --delay between key press to register shortcuts



-- ## [Internal]
----------------------------------------------------------------------
-- Ctrl+q to quit
map(modes, "<C-q>", "<cmd>qa!<CR>", {noremap=true, desc="Force quit nvim"})

-- Quick restart nvim
map(modes, "<C-M-r>", "<cmd>Restart<cr>")

-- F5 reload buffer
map({"i","n","v"}, '<F5>', "<cmd>e!<CR><cmd>echo'-File reloaded-'<CR>", {noremap=true})

-- g
map("i",       '<C-g>', "<esc>g", {noremap=true})
map({"n","v"}, '<C-g>', "g",      {noremap=true})



-- ## [Buffers]
----------------------------------------------------------------------
-- Create new buffer
map({"i","n","v"}, "<C-n>", function()
    local buff_count  = vim.api.nvim_list_bufs()
    local newbuff_num = #buff_count
    v.cmd("enew"); vim.cmd("e untitled_"..newbuff_num)
end)

-- Reopen prev
map(modes, "<C-S-t>", "<cmd>OpenLastClosedBuf<cr>")

-- Omni close
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

    -- try close cmdline before
    if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("<C-L>", "n", false) end

    -- Try :close first, in case both splits are same buf (fails if no split)
    -- It avoids killing the shared buffer in this case
    -- #vim.fn.win_findbuf(0)
    local res, err = pcall(vim.cmd, "close")
    if not res then
        if buftype == "terminal" then
            vim.cmd("bwipeout!")
        else
            vim.cmd("bwipeout!")
            -- vim.cmd("bd!")
            -- can also close tabs,
            -- bypass save warnings,
            -- not bwipeout to preserve alternate file '#'
        end
    end
end, {noremap=true})



--## [Register]
----------------------------------------------------------------------
map("n", "<C-r>", "i<C-r>")



--## [Files]
----------------------------------------------------------------------
-- Open nvim native file explorer
map(modes, "<C-e>", "<Cmd>Ex<CR>")

--Open file picker
map(modes, "<C-o>", "<cmd>FilePicker<CR>")

map(modes, "<C-g>fm", "<cmd>FileMove<CR>")
map(modes, "<C-g>fr", "<cmd>FileRename<CR>")
map(modes, "<C-g>fd", "<cmd>FileDelete<CR>")


-- ### [Save]
map({"i","n","v","c"}, "<C-s>", "<cmd>FileSaveInteractive<CR>")

-- Save as
map({"i","n","v","c"}, "<C-M-s>", "<cmd>FileSaveAsInteractive<CR>")


-- Resource curr file
map(modes, "ç", function()  --"<altgr-r>"
    local cf    = vim.fn.expand("%:p")
    local fname = '"'..vim.fn.fnamemodify(cf, ":t")..'"'

    vim.cmd("source "..cf); print("Ressourced: "..fname)
end)



-- ## [View]
----------------------------------------------------------------------
-- alt-z toggle line virtual wrap
map({"i","n","v"}, "<A-z>", function()
    vim.opt.wrap = not vim.opt.wrap:get()
end)

-- toggle auto wrap lines
map({"i","n","v"}, "M-C-z", function()
    -- "t" Auto-wrap text using textwidth (for non-comments).
    -- "w" Auto-wrap lines in insert mode, even without spaces.
end)

-- Gutter on/off
map({"i","n","v"}, "<M-g>", function()
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


-- ### [Folds]
map({"i","n","v"}, "<M-S-z>", "<Cmd>norm! za<CR>")

-- virt lines
map("n", "gl", "<cmd>Toggle_VirtualLines<CR>", {noremap=true})



-- ## [Tabs]
----------------------------------------------------------------------
--create new tab
map(modes,"<C-t>", "<Cmd>Alpha<CR>")

--Tabs nav
--next
map(modes, "<C-Tab>",   "<cmd>bnext<cr>")
--prev
map(modes, "<C-S-Tab>", "<cmd>bp<cr>")



--## [Windows]
----------------------------------------------------------------------
--rebind win prefix
map({"i","n","v"}, "<M-w>", "<esc><C-w>",   {noremap=true})
map("t", "<M-w>", "<Esc> <C-\\><C-n><C-w>", {noremap=true})

--Open window
map(modes, "<M-w>n", function ()
    local wopts = {
        split = "right",
        height = 33,
        width = 25
    }
    vim.api.nvim_open_win(0, true, wopts)
end)

--Open floating window
map(modes, "<M-w>nf", function ()
    local fname = vim.fn.expand("%:t")

    local edw_w = vim.o.columns
    local edw_h = vim.o.lines

    local wsize = {w = 66, h = 22}

    local wopts = {
        title     = fname,
        title_pos = "center",
        relative = "editor",
        border = "single",
        width  = wsize.w,
        height = wsize.h,
        col = math.floor((edw_w - wsize.w) / 2),
        row = math.floor((edw_h - wsize.h) / 2),
    }
    local fwin = vim.api.nvim_open_win(0, true, wopts)
end)

--make ver split
map(modes, "<M-w>s", "<cmd>vsp<cr>") --default nvim sync both, we don't want that
--make hor split
map(modes, "<M-w>h", "<cmd>new<cr>")

--To next window (include splits)
map(modes, "<M-Tab>", "<cmd>wincmd w<cr>")

-- Toggle focus for split
map(modes, "<M-w>f", function()
    local win     = vim.api.nvim_get_current_win()
    local wwidth  = vim.api.nvim_win_get_width(win)
    local wheight = vim.api.nvim_win_get_height(win)

    local tab_width  = vim.o.columns
    local tab_height = vim.o.lines - vim.o.cmdheight

    local focused = wwidth >= tab_width * 0.9 and wheight >= tab_height * 0.9
    if focused then
        vim.cmd("wincmd =") --equalize all win size
    else
        vim.cmd("wincmd |")
        vim.cmd("wincmd _")
    end
end)

--resize hor
map("n", "<M-w><Up>",   ":resize +5<CR>", {noremap = true})
map("n", "<M-w><Down>", ":resize -5<CR>", {noremap = true})
--resize vert
map("n", "<M-w><Left>",  ":vert resize -5<CR>", {noremap = true})
map("n", "<M-w><Right>", ":vert resize +5<CR>", {noremap = true})

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



-- ## [Navigation]
----------------------------------------------------------------------
-- Threat wrapped lines as distinct lines for up/down nav
map("i", "<Up>", "<cmd>norm! g<Up><CR>")
map({"n","v"}, "<Up>", "g<up>")

map("i", "<Down>", "<cmd>norm! g<Down><CR>")
map({"n","v"}, "<Down>", "g<Down>")

-- Jump to next word
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

-- Jump to previous word
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

-- To next/prev cursor jump loc
map({"i","v"}, "<M-PageDown>",  "<Esc><C-o>")
map("n",       "<M-PageDown>",  "<C-o>")
map({"i","v"}, "<M-PageUp>",    "<Esc><C-i>")
map("n",       "<M-PageUp>",    "<C-i>")


-- ### [Fast and furious cursor move]
-- Fast left/right move in normal mode
map('n', '<C-Right>', "m'5l")
map('n', '<C-Left>',  "m'5h")

-- ctrl+up/down to move fast
map("i",       "<C-Up>", "<esc>m'3ki")
map({"n","v"}, "<C-Up>", "m'3k")

map("i",       "<C-Down>", "<esc>m'3ji")
map({"n","v"}, "<C-Down>", "m'3j")


-- alt+left/right move to start/end of line
map("i",       "<M-Left>", "<Esc>m'0i")
map({"n","v"}, "<M-Left>", "m'0")

map("i",       "<M-Right>", "<Esc>m'$a")
map({"n","v"}, "<M-Right>", "m'$")

-- Jump home/end
map("i",       "<Home>", "<Esc>gg0i")
map({"n","v"}, "<Home>", "gg0")

--kmap("i",       "<M-Up>", "<Esc>gg0i")  --collide with <esc><up>
--kmap({"n","v"}, "<M-Up>", "gg0")

map("i",       "<End>", "<Esc>G$a")
map({"n","v"}, "<End>", "G$")

-- kmap("i", "<M-Down>", "<Esc>G$i")  --collide with <esc><up>
-- kmap({"n","v"}, "<M-Down>", "G$")

map("n", "f", function()
    -- TODO JumpToCharAcrossLines()
end, {remap = true})


-- ### Search
map({"i","n","v","c"}, "<C-f>", function()
    vim.fn.setreg("/", "") --clear last search and hl
    vim.opt.hlsearch = true

    --proper clear and exit cmd mode
    if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "n", false) end

    if vim.fn.mode() ~= "v" then
        vim.api.nvim_feedkeys([[/\V]], "n", false) --need feedkey, avoid glitchy cmd
    else
        vim.api.nvim_feedkeys([[y/\V"]], "n", false)
    end
end)

-- Search Help for selection
map("v", "<F1>", 'y:h <C-r>"<CR>')


-- ### Navigation directory
-- Move one dir up
map({"i","n","v"}, "<C-Home>", "<cmd>cd ..<CR><cmd>pwd<CR>")

-- To last directory
map({"i","n","v"}, "<M-Home>", "<cmd>cd -<CR><cmd>pwd<CR>")

-- Interactive cd
map({"i","n","v","c"}, "<C-End>", function()
    vim.api.nvim_feedkeys(":cd ", "n", false)
    vim.api.nvim_feedkeys("	", "c", false) --triggers comp menu
end)

-- cd file dir
map(modes, "<C-p>f", "<cmd>cd %:p:h | pwd<CR>")

-- cd project root
map(modes, "<C-p>p", function()
    local res = vim.system({"git", "rev-parse", "--show-toplevel"}, {text=true}):wait()
    if res.code ~= 0 then
        vim.notify("Not inside a Git repo:"..res.stderr, vim.log.levels.ERROR) return
    end
    local groot = vim.trim(res.stdout) --trim white space to avoid surprises

    vim.cmd("cd " .. groot); vim.cmd("pwd")
end)



-- ## [Selection]
----------------------------------------------------------------------
-- Swap selection anchors
map("v", "<M-v>", "o")

-- ### Visual selection
-- shift+arrows visual select
map("i", "<S-Left>", "<Esc>hv",  {noremap = true})
map("n", "<S-Left>", "vh",       {noremap = true})
map("v", "<S-Left>", "<Left>")

map("i", "<S-Right>", "<Esc>v",  {noremap = true}) --note the v without l for insert only
map("n", "<S-Right>", "vl",      {noremap = true})
map("v", "<S-Right>", "<Right>")

map({"i","n"}, "<S-Up>",    "<Esc>vgk", {noremap=true})
map("v",       "<S-Up>",    "gk",       {noremap=true}) --avoid fast scrolling around

map({"i","n"}, "<S-Down>", "<Esc>vgj",  {noremap=true})
map("v",       "<S-Down>", "gj",        {noremap=true}) --avoid fast scrolling around

-- Select word under cursor
map({"i","n","v"}, "<C-S-w>", "<esc>viw")

-- Sel in paragraph
map({"i","n","v"}, "<C-S-p>", "<esc>vip")

-- Select to home/end
map({"i","n","v"}, "<S-Home>", "<esc>vgg0")
map({"i","n","v"}, "<S-End>",  "<Esc>vG$")

-- To Visual Line selection
-- TODO a bit hacky we would want proper <M-C-Right><M-C-Left>
map("i", "<M-C-Right>", "<Esc>V")
map({"n","v"}, "<M-C-Right>", function()
    if vim.fn.mode() ~= "V" then vim.cmd("norm! V") end
end)
map("i", "<M-C-Left>", "<Esc>V")
map({"n","v"}, "<M-C-Left>", function()
    if vim.fn.mode() ~= "V" then vim.cmd("norm! V") end
end)

-- ctrl+a select all
map({"i","n","v"}, "<C-a>", "<Esc>G$vgg0")


-- ### Grow select
-- Grow visual line selection up/down
map("i", "<S-PageUp>", "<Esc>Vk")
map("n", "<S-PageUp>", function()vim.cmd('norm!V'..vim.v.count..'k')end)
map("v", "<S-PageUp>", function()
    local vst_l, vsh_l = vim.fn.line("v"), vim.fn.line(".")

    if vim.fn.mode() == "V" then
        if vsh_l > vst_l then vim.cmd("norm! ok")
        else                  vim.cmd("norm! k")
        end
    else
        vim.cmd("norm! Vk")
    end
end)

map("i", "<S-PageDown>", "<Esc>Vj")
map("n", "<S-PageDown>", function()vim.cmd('norm!V'..vim.v.count..'j')end)
map("v", "<S-PageDown>", function()
    local vst_l, vsh_l = vim.fn.line("v"), vim.fn.line(".")

    if vim.fn.mode() == "V" then
        if vsh_l > vst_l then vim.cmd("norm! j")
        else                  vim.cmd("norm! oj")
        end
    else
        vim.cmd("norm! Vj")
    end
end)

-- shrink visual line selection up/down
map("v", "<C-S-PageUp>", function()
    if vim.fn.mode() == "V" then
        vim.cmd("norm! k")
    else
        vim.cmd("norm! Vk")
    end
end)

map("v", "<C-S-PageDown>", function()
    if vim.fn.mode() == "V" then
        vim.cmd("norm! j")
    else
        vim.cmd("norm! Vj")
    end
end)


-- ### Visual line selection
map({"i","n","v"}, "<C-S-a>", "<Cmd>norm! V<CR>")


-- ### Visual block selection
-- Move to visual block selection regardless of mode
local function move_vis_blockselect(dir)
    if vim.fn.mode() == "" then vim.cmd("norm! "              ..dir)
    else                          vim.cmd("stopinsert|norm!"..dir)
    end
end

map({"i","n","v"}, "<S-M-Left>",  function() move_vis_blockselect("h") end)
map({"i","n","v"}, "<S-M-Right>", function() move_vis_blockselect("l") end)
map({"i","n","v"}, "<S-M-Up>",    function() move_vis_blockseletc("k") end)
map({"i","n","v"}, "<S-M-Down>",  function() move_vis_blockselect("j") end)



-- ## [Editing]
----------------------------------------------------------------------
-- Toggle insert/normal with insert key
map("i", "<Ins>", "<Esc>")
map("n", "<Ins>", "i")
map("v", "<Ins>", function ()
    --seems to be more reliable
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>i", true, false, true), "n", false)
end)
map("c", "<Ins>", "<C-c>i")
map("t", "<Ins>", "<Esc> <C-\\><C-n>")


--To Visual insert mode
map("v", "<M-i>", "I")

-- insert at end of each lines
map("v", "î", function()
    if vim.fn.mode() == '\22' then
        vim.api.nvim_feedkeys("$A", "n", false)
    else
        vim.cmd("norm! "); vim.api.nvim_feedkeys("$A", "n", false)
    end
end)


-- Insert chars in visual mode
vim.g.visualreplace = true

---@param active bool
local function set_visualreplace(active)
    local chars = vim.iter({
        utils.alphabet_lowercase, utils.alphabet_uppercase,
        utils.numbers,
        utils.punctuation,
    }):flatten(1):totable()

    for _, char in ipairs(chars) do
        if active then
            map('v', char, '"_d<esc>i'..char, {noremap=true})
        else
            pcall(vim.keymap.del, 'v', char)
        end
    end
end

local function toggle_visualreplace()
    vim.g.visualreplace = not vim.g.visualreplace

    set_visualreplace(vim.g.visualreplacee)

    vim.notify("Visual replace: ".. tostring(vim.g.visualreplace))
end

-- visual replace on by default
set_visualreplace(vim.g.visualreplace)

map("v", "<space>", '"_di<space>', {noremap=true})
map("v", "<cr>",    '"_di<cr>',    {noremap=true})

vim.keymap.set({"i","n","v"}, "<S-M-v>", function() toggle_visualreplace() end)


-- Insert literal
-- TODO update wezterm? so we can use C-i again without coliding with Tab
-- map("i", "<C-i>l", "<C-v>", {noremap=true})
map("n", "<C-i>l", "i<C-v>")

-- Insert digraph
map("n", "<C-S-k>", "i<C-S-k>")


-- ### Insert snipet
--insert function()
--kmap("i", "<C-S-i>")

--map("i", "<C-i>sf", "")

-- Insert print snippet
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


-- ### [Copy / Paste]
-- Copy whole line in insert
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


-- Copy append selection
map("v", "<S-M-c>", function()
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

-- Paste
map({"i","n","v"}, "<C-v>", function()
    local mode = vim.fn.mode()
    if mode == "v" or mode == "V" or mode == "" then vim.cmd('norm! "_d') end

    vim.cmd('norm! "+P') --paste from clipboard

    --Format after paste
    local ft = vim.bo.filetype

    if ft == "" then
        -- no formating for unknown ft
    elseif ft == "markdown" or ft == "text" then
        vim.cmd("norm! `[v`]gqw")
    else
        vim.cmd("norm! `[v`]=") --auto fix indent
    end

    -- Proper curso placement
    vim.cmd("norm! `]")
    if mode == "i" then vim.cmd("norm! a") end
end)
map("c", "<C-v>", '<C-R>+')
map("t", "<C-v>", '<Esc> <C-\\><C-n>"+Pi') --TODO kinda weird

-- Paste replace word
map("i", "<C-S-v>", '<esc>"_diw"+Pa')
map({"n","v"}, "<C-S-v>", '<esc>"_diw"+P')

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


-- ### Deletion
-- #### Remove
-- Remove char
-- kmap("i", "<BS>", "<C-o>x", {noremap=true, silent=true}) --maybe not needed on wezterm
-- kmap("n", "<BS>", '<Esc>"_X<Esc>')
map("n", "<BS>", 'r ')
map("v", "<BS>", '"_xi')

-- Remove word left
-- <M-S-BS> instead of <C-BS> because of wezterm
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
--Change in word
map({"i","n"}, "<C-S-r>", '<esc>"_ciw')

--Replace visual selection with char
map("v", "<M-r>", "r")


-- Substitue mode
map("n", "s", "<Nop>")

map({"i","n"}, "<M-S-s>",
[[<Esc>:%s/\V//g<Left><Left><Left>]],
{desc = "Enter substitue mode"})

map({"i","n"}, "<F50>",
[[<esc>yiw:%s/\V<C-r>"//g<Left><Left>]],
{desc = "Substitue word under cursor" })

-- Substitue in selection
map("v", "<F2>",
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


-- ### Formating
-- #### Indentation
--space bar in normal mode
map("n", "<space>", "i<space><esc>")

-- tab indent
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

-- Trigger Auto indent
map({"i","n"}, "<C-=>", "<esc>==")
map("v",       "<C-=>", "=")


-- ### [Line break]
map("n", "<cr>", "i<CR><esc>")

-- Line break above
map({"i","n"}, "<S-CR>", function() vim.cmd('norm! '..vim.v.count..'O') end)
map("v",       "<S-CR>", "<esc>O<esc>gv")

-- Line break below
map({"i","n"}, "<M-CR>", function() vim.cmd('norm! '..vim.v.count..'o') end)
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

-- ### [Line join]
-- Join below
map("i",       "<C-j>", "<C-o><S-j>")
map({"n","v"}, "<C-j>", "<S-j>") --this syntax allow to use motions

-- Join to upper
map("i", "<C-S-j>", "<esc>k<S-j>i") --this syntax allow to use motions
map("n", "<C-S-j>", "k<S-j>")


-- ### [Text move]
-- Move single char
map("n", "<C-S-Right>", '"zx"zp')
map("n", "<C-S-Left>",  '"zxh"zP')
-- map("n", "<C-S-Up>", '"zxk"zP') -- rarely useful in practice
-- map("n", "<C-S-Down>", '"zxj"zP')

---@param dir string
---@param amount number
local function move_selected(dir, amount)
    local mode = vim.fn.mode()

    if mode == 'i' then vim.cmd("stopinsert") vim.cmd("norm! viw") end

    vim.cmd('norm! ') -- hack to refresh vis pos
    local vst, vsh = vim.api.nvim_buf_get_mark(0, "<"), vim.api.nvim_buf_get_mark(0, ">")
    local atsol = math.min((vst[2]), (vsh[2]))
    -- TODO detect sof and eof
    vim.cmd('norm! gv')

    if math.abs(vst[1] - vsh[1]) > 0 or mode == "V" then -- multilines move
        if dir == "k" then vim.cmd("'<,'>m '<-"..(amount+1).."|norm!gv=gv") return end
        if dir == "j" then vim.cmd("'<,'>m '>+"..amount.."|norm!gv=gv")     return end
    end

    if (atsol < 1) and dir == "h" then return end

    local cmd = '"zygv"_x' .. amount .. dir .. '"zP'
    if mode == "v"  then cmd = cmd.."`[v`]"  end
    if mode == "" then cmd = cmd.."`[`]" end
    vim.cmd("silent keepjumps norm! " .. cmd)
end

-- Move selected text
map({"i","x"}, "<C-S-Left>",  function() move_selected("h", vim.v.count1) end)
map({"i","x"}, "<C-S-Right>", function() move_selected("l", vim.v.count1) end)
map({"i","x"}, "<C-S-Up>",    function() move_selected("k", vim.v.count1) end)
map({"i","x"}, "<C-S-Down>",  function() move_selected("j", vim.v.count1) end)

-- Move line
map({'i','n'}, '<C-S-Down>', function()vim.cmd('m.'..vim.v.count1..'|norm!==')end,      {desc='Move curr line down'})
map({'i','n'}, '<C-S-Up>',   function()vim.cmd('m.-'..(vim.v.count1+1)..'|norm!==')end, {desc='Move curr line up'})


-- ### [Comments]
map({"i","n"}, "<M-a>", "<cmd>norm gcc<cr>", {noremap=true})
map("v",       "<M-a>", "gcgv", {remap=true})


-- ### [Macro]
map("n", "q", "<nop>")
map("n", "<M-S-r>", "qq", {noremap = true})



-- ## [Text intelligence]
----------------------------------------------------------------------
-- ### [Word processing]
-- Toggle spellcheck
map({"i","n","v","c","t"}, "<M-s>s", function()
    vim.opt.spell = not vim.opt.spell:get()
    print("Spellchecking: " .. tostring(vim.opt.spell:get()))
end, { desc = "Toggle spell checking" })

-- Pick documents language
map({"i","n","v","c","t"}, "<M-s>l", "<cmd>PickDocsLanguage<CR>")

-- Suggest
map({"i","n","v"}, "<M-s>c", "<Cmd>FzfLua spell_suggest<CR>")

-- Quick correct
map({"i","n","v"}, "<M-c>", "<Cmd>norm! m`1z=``<CR>")

-- Add word to dictionary
map({"i","n"}, "<M-s>a", "<Esc>zg")
map("v",       "<M-s>a", "zg")
--TODO check if word already in dict
-- map({"i","n"},       "<M-s>a", "zg")
-- function()
--     local word = vim.fn.expand("<cword>")
--     vim.cmd("norm! zg")
--     custom zg that avoids duplicates
--     local spellf = vim.opt.spellfile:get()[1]

--      local exists = false
--          local lines = vim.fn.readfile(spellfile)
--          for _, l in ipairs(lines) do
--              if l == word then
--                  exists = true
--                  break
--              end
--          end
--      end

--      if not exists then
--          vim.cmd("normal! zg") -- call original zg
--      else
--          vim.notify("Already in dictionary: " .. word)
--      end
--     end, { noremap = true })

-- Remove from dictionary
map({"i","n"}, "<M-s>r", "<Esc>zug")
map("v",       "<M-s>r", "zug")

-- Show definition for word
map({"i","n","v"}, "<M-s>d", function()
    local word = vim.fn.expand("<cword>")

    vim.cmd("vsp|enew")

    vim.api.nvim_set_option_value("buftype", "nofile", {buf=0})
    vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
    vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})

    vim.opt_local.statuscolumn = ""
    vim.opt_local.signcolumn   = "no"
    vim.opt_local.number       = false
    vim.opt_local.foldcolumn   = "0"

    local res = vim.system({"dict", "-C", "-s", "exact", "-d", "wn", word}, {text=true}):wait()
    if res.code ~= 0 then vim.notify("dict error \n" .. res.stderr, vim.log.levels.ERROR) end

    -- TODO thesaurus hack
    -- local tres = vim.system({"dict", "-C", "-s", "exact", "-d", "wn", word}, {text=true}):wait()
    -- local lines = {}
    -- for l in res.stdout:gmatch("[^\n]+") do
    --     if l:match("^syn:") then
    --         for syn in l:gmatch("%w+") do
    --             table.insert(lines, syn)
    --         end
    --     end
    -- end

    local lines = vim.split(res.stdout,"\n")
    --filter noisy info like provenance of definition
    --lines = vim.list_slice(lines, 0)

    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end)

-- diag panel
map({"i","n","v"}, "<F10>", "<cmd>Trouble diagnostics toggle focus=true filter.buf=0<cr>")


-- ref panel
map({"i","n","v"}, "<F11>", "<cmd>Trouble lsp_references toggle focus=true<cr>")

-- Goto definition
map("i", "<F12>", "<Esc>gdi")
map("n", "<F12>", "<Esc>gd")
-- map("n", "<F12>", ":lua vim.lsp.buf.definition()<cr>")
map("v", "<F12>", "<Esc>gd")

-- Show hover window
map({"i","n","v"}, "<C-h>", "<Cmd>lua vim.lsp.buf.hover()<CR>")

-- Rename symbol
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

-- smart contextual action
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


-- ### Diff
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

map(modes, "<C-g>gl", "<Cmd>LazyGit<cr>")



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
--F56 is <M-F8>
map({"i","n"}, "<F56>", function() vim.cmd('norm! 0"zy$'); vim.cmd('@z') end)
map("v", "<F56>", function() vim.cmd('norm! "zy'); vim.cmd('@z') end)



-- ## [Vim Command]
----------------------------------------------------------------------
-- Open command line
map("i",       "œ", "<esc>:")
map({"n","v"}, "œ", ":")
map("t",       "œ", "<Esc><C-\\><C-n>:")

-- Open command line window
vim.cmd('set cedit=<C-u>')

-- Open command line in term mode
map({"i","c"}, "<S-Œ>", "<esc>:!")
map({"n","v"}, "<S-Œ>", ":!")

-- cmd completion menu
-- vmap("c", "<C-d>", "<C-d>")

-- Cmd menu nav
map("c", "<Up>", "<C-p>")
map("c", "<Down>", "<C-n>")

map("c", "<S-Tab>", "<C-n>")

-- Clear cmd in insert
map("i", "<C-l>", "<C-o><C-l>")

-- Cmd close
map("c", "œ", "<C-c><C-L>")  --needs <C-c> and not <Esc> because Neovim behaves as if <Esc> was mapped to <CR> in cmd
-- map("c", "<esc>", "<C-c>", {noremap=true})

-- Easy exit command line window
vim.api.nvim_create_autocmd({ "CmdwinEnter" }, {
    callback = function()
        vim.keymap.set("n", "<esc>", ":quit<CR>", {buffer=true})
    end,
})



-- ## [Terminal]
----------------------------------------------------------------------
-- Open term
map({"i","n","v"}, "<M-t>", "<cmd>term<CR>", {noremap=true})

-- Quick split term
map({"i","n","v"}, "<M-w>t", function()
    vim.cmd("vsp|term")

    vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
    vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})
end, {noremap=true})

-- Exit
map("t", "<esc>", "<Esc> <C-\\><C-n>", {noremap=true})





