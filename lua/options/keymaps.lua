-- _
-- _
--| |
--| | _____ _   _ _ __ ___   __ _ _ __  ___
--| |/ / _ \ | | | '_ ` _ \ / _` | '_ \/ __|
--|   <  __/ |_| | | | | | | (_| | |_) \__ \
--|_|\_\___|\__, |_| |_| |_|\__,_| .__/|___/
--           __/ |               | |
--          |___/                |_|

local utils = require("utils.utils")
local lsnip = require("luasnip")

local v   = vim
local map = vim.keymap.set
----------------------------------------


-- Modes helpers
local modes = { "i", "n", "v", "o", "s", "t", "c" }



-- ## [Internal]
----------------------------------------------------------------------
vim.o.timeoutlen = 375 --delay between key press to register shortcuts

-- Ctrl+q to quit
map(modes, "<C-q>", "<cmd>qa!<CR>", {noremap=true, desc="Force quit nvim"})

-- Quick restart nvim
map(modes, "<C-M-r>", "<cmd>Restart<cr>")

-- F5 reload buffer
map({"i","n","v"}, '<F5>', "<cmd>e!<CR><cmd>echo'-File reloaded-'<CR>", {noremap=true})

-- g
map("i",       '<C-g>', "<esc>g", {noremap=true})
map({"n","v"}, '<C-g>', "g",      {noremap=true})

-- Super esc
map({'i','n','s'}, '<esc>', function()
    vim.cmd('noh')
    return '<esc>'
end, {expr = true, desc = "Escape, clear hlsearch"})



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

    -- custom save warning if buf modified and it is it's last win
    if bufmodif and #bufwindows <= 1 then
        local choice = vim.fn.confirm("Unsaved changes, quit anyway? ", "&Yes\n&No", 1)
        if choice ~= 1 then return end
    end

    -- try close cmdline before
    if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end

    -- Try :close first, in case both splits are same buf (fails if no split)
    -- It avoids wiping the shared buffer in this case
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



-- ## [Files]
----------------------------------------------------------------------
-- File action
map(modes, "<C-g>fm", "<cmd>FileMove<CR>")
map(modes, "<C-g>fr", "<cmd>FileRename<CR>")
map(modes, "<C-g>fd", "<cmd>FileDelete<CR>")


-- ### [File Save]
-- Save current
map({"i","n","v","c"}, "<C-s>", "<cmd>FileSaveInteractive<CR>")

-- Save as
map({"i","n","v","c"}, "<C-M-s>", "<cmd>FileSaveAsInteractive<CR>")


-- Resource curr file
map(modes, "ç", function()  --"<altgr-r>"
    local cf = vim.fn.expand("%:p")
    vim.cmd("source "..cf)

    print("Ressourced: "..'"'..vim.fn.fnamemodify(cf, ":t")..'"')
end)


-- Open file manager
-- map(modes, "<C-e>", '<Cmd>lua require("oil").open(vim.fn.getcwd())<CR>')
map(modes, "<C-e>", function()
    local home = vim.fn.expand("~")
    local cdir = vim.fn.getcwd()
    local rootdir = vim.fs.dirname(vim.fs.find({".git", "Makefile", "package.json" }, {upward = true })[1])
    local cur_win = vim.api.nvim_get_current_win()

    -- require("neo-tree.command").execute({
    --     action = "show",
    --     dir = rootdir,
    --     position = "left",
    --     reveal = true,
    --     focus = false,
    --     window = { width = 20 },
    --     filesystem = {bind_to_cwd = false}
    -- })

    vim.api.nvim_set_current_win(cur_win)  -- restore focus
    require("oil").open(cdir)
end)

-- Open file picker
map(modes, "<C-o>", "<cmd>FilePicker<CR>")



-- ## [Register]
----------------------------------------------------------------------



-- ## [View]
----------------------------------------------------------------------
-- alt-z toggle line soft wrap
map({"i","n","v"}, "<A-z>", function() vim.opt.wrap = not vim.opt.wrap:get() end)

-- Toggle auto hard wrap lines
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

        vim.notify("Hide gutter")
    else
        vim.g.gutter_show = true

        local confp = vim.fn.stdpath("config")
        vim.cmd("so ".. confp .."/lua/options/ui/view.lua")
        vim.cmd("so ".. confp .."/lua/plugins/ui/editor/statuscol.lua")

        vim.notify("Show gutter")
    end
end, {desc = "Toggle Gutter" })


-- ### [Folds]
map({"i","n","v"}, "<M-S-z>", "<Cmd>norm! za<CR>")



-- ## [Windows]
----------------------------------------------------------------------
-- Rebind win prefix
map({"i","n","v"}, "<M-w>", "<esc><C-w>", {noremap=true})
map("t",           "<M-w>", "<Esc> <C-\\><C-n><C-w>", {noremap=true})

-- Open window
map(modes, "<M-w>n", function ()
    local wopts = {
        split = "right",
        height = 33,
        width = 38
    }
    vim.api.nvim_open_win(0, true, wopts)
end)

-- Open floating window
map(modes, "<M-w>nf", function ()
    local fname = vim.fn.expand("%:t")

    local edw_w = vim.o.columns
    local edw_h = vim.o.lines

    local wsize = {w = 66, h = 22}

    local wopts = {
        title     = fname,
        title_pos = "center",
        relative  = "editor",
        border    = "single",
        width  = wsize.w,
        height = wsize.h,
        col = math.floor((edw_w - wsize.w) / 2),
        row = math.floor((edw_h - wsize.h) / 2),
    }
    local fwin = vim.api.nvim_open_win(0, true, wopts)
end)

-- Make ver split
map(modes, "<M-w>s", "<cmd>vsp<cr>") --default nvim sync both, we don't want that
-- Make hor split
map(modes, "<M-w>h", "<cmd>sp<cr>")

-- To next window (include splits)
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
        vim.cmd("wincmd =") -- equalize all win size
    else
        vim.cmd("wincmd |") -- try focus
        vim.cmd("wincmd _")
    end
end)

-- Resize hor
map("n", "<M-w><Up>",   ":resize +5<CR>", {noremap = true})
map("n", "<M-w><Down>", ":resize -5<CR>", {noremap = true})
-- Resize vert
map("n", "<M-w><Left>",  ":vert resize -5<CR>", {noremap = true})
map("n", "<M-w><Right>", ":vert resize +5<CR>", {noremap = true})

-- Detach win
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



-- ## [Tabs]
----------------------------------------------------------------------
-- Create new tab
map(modes,"<C-t>", "<Cmd>Alpha<CR>")

-- Tabs nav
-- next
map(modes, "<C-Tab>",   "<cmd>bnext<cr>")
-- Prev
map(modes, "<C-S-Tab>", "<cmd>bp<cr>")



-- ## [Custom Text objects]
----------------------------------------------------------------------
local function select_texobj_paired(char)
    vim.cmd('norm! ')
    vim.fn.search(char, 'bcWs')
    vim.cmd('norm! v')
    vim.fn.search(char, 'zWs')
end

-- Around pipe
map({"x","o"}, 'AP', function() select_texobj_paired('|') end, {noremap=true, silent=true})

map({"x","o"}, '%', function()
    local char = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]
    if char:match("['\"`]") then
        vim.cmd("norm! v2i"..char)
    else
        vim.cmd('norm! v%')
    end
end)



-- ## [Navigation]
----------------------------------------------------------------------
-- Threat wrapped lines as distinct lines for up/down nav
map("i",       "<Up>", "<cmd>norm! g<Up><CR>") -- use norm to avoid visual glitch
map({"n","v"}, "<Up>", "g<up>")

map("i",       "<Down>", "<cmd>norm! g<Down><CR>")
map({"n","v"}, "<Down>", "g<Down>")

--maybe?
-- vim.keymap.set('n', 'j', [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']], { expr = true })
-- vim.keymap.set('n', 'k', [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']], { expr = true })

-- ### [Fast and furious cursor move]
-- m' is used to write into jump list
-- Fast left/right move in normal mode
map('n', '<C-Right>', "m'5l")
map('n', '<C-Left>',  "m'5h")

-- ctrl+up/down to move fast
map("i",       "<C-Up>", "<esc>m'3ki")
map({"n","v"}, "<C-Up>", "m'3k")

map("i",       "<C-Down>", "<esc>m'3ji")
map({"n","v"}, "<C-Down>", "m'3j")


-- ### [Jump]
-- Jump to next word
map({"i","v"}, '<C-Right>', function()
    local curso_prevrow = vim.api.nvim_win_get_cursor(0)[1]

    if vim.fn.mode() == "" then vim.cmd("norm! 5l")
    else                          vim.cmd("norm! w") end

    if curso_prevrow ~= vim.api.nvim_win_get_cursor(0)[1] then
        vim.cmd("norm! b")
        local m = vim.fn.mode()
        if m == "v" or m == "V" then vim.cmd("norm! $")
        else                         vim.cmd("norm! A") end
    end
end)

-- Jump to previous word
map({"i","v"}, '<C-Left>', function()
    local curso_prevrow = vim.api.nvim_win_get_cursor(0)[1]

    if vim.fn.mode() == "" then vim.cmd("norm! 5h")
    else                          vim.cmd("norm! b")
    end

    if curso_prevrow ~= vim.api.nvim_win_get_cursor(0)[1] then
        vim.cmd("norm! w0")
    end
end)

-- Jump matching pair
map("n", "%", function()
    local char = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]

    print(char)
    if char:match("['\"`]") then  --`
        local curso_spos = vim.api.nvim_win_get_cursor(0)

        vim.cmd("norm! v2i"..char)

        local curso_epos = vim.api.nvim_win_get_cursor(0)

        if curso_spos[1] == curso_epos[1] and curso_spos[2] == curso_epos[2] then
            vim.cmd('norm! o')
        end

        vim.cmd('norm! ')

    elseif char:match("[|]") then
        local curso_spos = vim.api.nvim_win_get_cursor(0)

        vim.cmd("norm vAP")

        local curso_epos = vim.api.nvim_win_get_cursor(0)

        if curso_spos[1] == curso_epos[1] and curso_spos[2] == curso_epos[2] then
            vim.cmd('norm! o')
        end

        vim.cmd('norm! ')
    else
        vim.api.nvim_feedkeys("%", "n", false)
    end
end, {noremap=true})

-- To next/prev cursor jump loc
map({"i","n","v"}, "<M-PageDown>",  "<Esc><C-o>")
map({"i","n","v"}, "<M-PageUp>",    "<Esc><C-i>")

-- Jump to start/end of line
map({"i","n","v"}, "<M-Left>",  "<cmd>norm! 0<cr>")
map("i",           "<M-Right>", "<cmd>norm! $a<cr>") -- notice the 'a'
map({"n","v"},     "<M-Right>", "<cmd>norm! $<cr>")

-- Jump home/end
map("i",       "<Home>", "<Esc>ggI")
map({"n","v"}, "<Home>", "gg0")

--kmap("i",       "<M-Up>", "<Esc>gg0i")  --collide with <esc><up>
--kmap({"n","v"}, "<M-Up>", "gg0")

map("i",       "<End>", "<Esc>GA")
map({"n","v"}, "<End>", "G$")

-- kmap("i", "<M-Down>", "<Esc>G$i")  --collide with <esc><up>
-- kmap({"n","v"}, "<M-Down>", "G$")

-- Jump seek
map({"n","v"}, "f", function()
    vim.api.nvim_echo({{"f"}}, false, {})

    -- Gather first char
    local c1 = vim.fn.getcharstr()

    if c1 == vim.keycode("<Esc>") then
        vim. api.nvim_echo({{""}}, false, {}) return
    end
    vim.api.nvim_echo({{"f"..c1}}, false, {})

    -- Gather sec char
    local c2 = vim.fn.getcharstr()
    if c2 == vim.keycode("<Esc>") then return end

    -- Seek until last visible line
    -- Prevent messing with scrolling while seeking
    local defscrollo = vim.opt.scrolloff:get()
    vim.opt_local.scrolloff = 0

    -- Start search from the first visible row/col
    local strtline = vim.fn.line("w0")
    local endline  = vim.fn.line("w$")
    vim.api.nvim_win_set_cursor(0, {strtline, 0})

    local seq = vim.pesc(c1 .. c2) -- escape so special chars work
    vim.fn.search(seq, 'cWzs', endline)

    -- reset
    vim.o.scrolloff = defscrollo
    vim.api.nvim_echo({{""}}, false, {})
end)

-- Hyper act
map({"i","n","v"}, "<C-CR>", "<Cmd>HyperAct<CR>", {noremap=true})

-- Open quickfix list
map({"i","n","v","c","t"}, "<F9>", function()
    if vim.bo.buftype == "quickfix" then vim.cmd("cclose") return end

    -- proper cmd close
    if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end

    vim.cmd("copen")

    vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
    vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})
end)


-- Open task
-- General task
map({"i","n","v","c","t"}, "<F4>", "<Cmd>Planv<CR>")

-- Project task
-- map({"i","n","v","c","t"}, "<F16>", "<Cmd>Planv<CR>")


-- open curr proj doc
-- map({"i","n","v","c","t"}, "<F3>", function()


-- ### Search
map({"i","n","v","c"}, "<C-f>", function()
    vim.fn.setreg("/", "") --clear last search and hl
    vim.o.hlsearch = true

    -- Proper clear and exit cmd mode
    if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end

    if vim.fn.mode() ~= "v" then
        vim.api.nvim_feedkeys([[/\V]], "n", false) -- need feedkey, avoid glitchy cmd
    else
        vim.cmd("norm! y")
        vim.api.nvim_feedkeys([[/\V"
]], "c", false)
    end
end)

-- Search Help for selection
map("v", "<F1>", 'y:h <C-r>"<CR>')


-- ### Directory navigation
-- Move one dir up
map({"i","n","v"}, "<C-Home>", "<cmd>cd ..<CR>")

-- To prev directory
map({"i","n","v"}, "<C-End>", "<cmd>cd -<CR>")

-- Interactive cd
map({"i","n","v","c"}, "<M-End>", function()
    vim.api.nvim_feedkeys(":cd ", "n", false)
    vim.api.nvim_feedkeys("	", "c", false) --triggers comp menu
end)

-- cd file dir
map(modes, "<C-p>f", "<cmd>cd %:p:h<CR>")

-- cd project root
map(modes, "<C-p>p", function()
    local res = vim.system({"git", "rev-parse", "--show-toplevel"}, {text=true}):wait()
    if res.code ~= 0 then
        vim.notify("Not inside a Git repo:"..res.stderr, vim.log.levels.ERROR) return
    end
    local groot = vim.trim(res.stdout) -- trim white space to avoid surprises

    vim.cmd("cd " .. groot)
end)



-- ## [Selections]
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
map("v", "<S-Right>", "<Right>", {noremap = true})

map({"i","n"}, "<S-Up>",   "<Esc>vgk", {noremap=true})
map("v",       "<S-Up>",   "gk",       {noremap=true}) --avoid fast scrolling around

map({"i","n"}, "<S-Down>", "<Esc>vgj",  {noremap=true})
map("v",       "<S-Down>", "gj",        {noremap=true}) --avoid fast scrolling around

-- Select word under cursor
map({"i","n","v"}, "<C-S-w>", "<esc>viw")

-- Select to home/end
map({"i","n","v"}, "<S-Home>", "<esc>vgg0")
map({"i","n","v"}, "<S-End>",  "<Esc>vG$")

-- To Visual Line selection
-- TODO a bit hacky we would want proper <M-C-Right><M-C-Left>
map({"i","n","v"}, "<C-M-Right>", function()
    if vim.fn.mode() ~= "V" then vim.cmd("norm! V") end
end)
map({"i","n","v"}, "<M-C-Left>", function()
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

-- Shrink visual line selection up/down
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
local function move_blockselect(dir)
    if vim.fn.mode() == "" then vim.cmd("norm! "              ..dir)
    else                          vim.cmd("stopinsert|norm!"..dir)
    end
end

map({"i","n","v"}, "<S-M-Left>",  function() move_blockselect("h") end)
map({"i","n","v"}, "<S-M-Right>", function() move_blockselect("l") end)
map({"i","n","v"}, "<S-M-Up>",    function() move_blockselect("k") end)
map({"i","n","v"}, "<S-M-Down>",  function() move_blockselect("j") end)



-- ## [Editing]
----------------------------------------------------------------------
-- ### Insert
-- Toggle insert/normal with insert key
map("i", "<Ins>", "<Esc>")
map("n", "<Ins>", "i")
map("v", "<Ins>", function () vim.api.nvim_feedkeys("i", "n", false) end)
map("c", "<Ins>", "<C-c>i")
map("t", "<Ins>", "<Esc> <C-\\><C-n>")


-- To Visual insert mode
map("v", "<M-i>", "I")

-- Insert at end of each lines
map("v", "î", function()
    if vim.fn.mode() == '\22' then
        vim.api.nvim_feedkeys("$A", "n", false)
    else
        vim.cmd("norm! "); vim.api.nvim_feedkeys("$A", "n", false)
    end
end)

-- Insert raw escape seq for key
map({"i","n"}, "<C-S-i>", function()
    vim.cmd([[norm! i\]] .. vim.fn.getchar())
end, {noremap=true})

-- Insert literal
-- TODO update wezterm? so we can use C-i again without coliding with Tab
-- map("i", "<C-i>l", "<C-v>", {noremap=true})
map("n", "<C-i>l", "i<C-v>")


-- Insert digraph
map("n", "<C-S-k>", "i<C-S-k>")


-- ### Insert snippets
-- Insert var
map({"i","n","v"}, "<C-S-n>v", function()
    lsnip.try_insert_snippet("var")
end)

-- Insert func
map({"i","n","v"}, "<C-S-n>f", function()
    lsnip.try_insert_snippet("func")
end)

-- Insert if
map({"i","n","v"}, "<C-S-n>if", function()
    lsnip.try_insert_snippet("if")
end)

-- Insert loop
-- map({"i","n","v"}, "<C-S-n>p", function()
    --     lsnip.try_insert_snippet("print")
-- end)

-- Insert print
map({"i","n","v"}, "<C-S-n>p", function()
    lsnip.try_insert_snippet("print")
end)



-- ### [Copy / Paste]
-- Copy whole line in insert
map("i", "<C-c>", function()
    if vim.fn.getline(".")  ~= "" then
        vim.cmd('norm! mz0"+y$`z')
        vim.cmd('stopinsert')
        print("Line copied.")
    end
end, {noremap=true})

map("n", "<C-c>", function()
    local char = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]

    if char ~= " " and char ~= "" then
        vim.cmd('norm! "+yl')
    end
end, {noremap = true})

map("v", "<C-c>", function()
    vim.cmd('norm! mz"+y`z'); print("Selection copied")
end, {noremap=true})


-- Copy append selection
map("v", "<S-M-c>", function()
    local reg_prev = vim.fn.getreg("+")

    vim.cmd('norm! mz"+y`z')

    vim.fn.setreg("+", reg_prev .. vim.fn.getreg("+"))

    print("Appended to clipboard")
end)


-- Copy word
map({"i","n","v"}, "<C-S-c>", function()
    vim.cmd('norm! mzviw"+y`z'); print("Word Copied")
end, {noremap=true})

-- Cut
map("i", "<C-x>", '<esc>0"+y$"_dd', {noremap = true}) --cut line, avoids reg"
map("n", "<C-x>", '"+x',             {noremap = true})
map("v", "<C-x>", '"+d<esc>',        {noremap = true}) --d both delete and copy so..

-- Cut word
map({"i","n"}, "<C-S-x>", '<cmd>norm! viw"+x<cr>')
map("v",       "<C-S-x>", '<esc>viw"+x')

-- Paste
map({"i","n","v"}, "<C-v>", function()
    local mode = vim.fn.mode()
    if mode == "v" or mode == "V" or mode == "" then vim.cmd('norm! "_d') end

    vim.cmd('norm! "+P') -- paste from sys clipboard

    -- Format after paste
    local ft = vim.bo.filetype

    if ft == "" then
        -- no formating for unknown ft
    elseif ft == "markdown" or ft == "text" then
        vim.cmd("norm! `[v`]gqq")
    else
        vim.cmd("norm! `[v`]=") --auto fix indent
    end

    -- Proper curso placement
    vim.cmd("norm! `]"); if mode == "i" then vim.cmd("norm! a") end
end)
map("c", "<C-v>", '<C-R>+')
map("t", "<C-v>", '<Esc> <C-\\><C-n>"+Pi') --TODO kinda weird

-- Paste replace word
map({"i","n","v"}, "<C-S-v>", '<cmd>norm! "_diw"+P<CR>')

-- Duplicate
map({"i","n"}, "<C-d>", function() vim.cmd('norm!"zyy'..vim.v.count..'"zp') end, {desc="dup line"})
map("v",      "<C-d>", '"zy"zP', {desc="dup sel"})


-- ### [Undo/redo]
-- ctrl+z to undo
map("i",       "<C-z>",   "<C-o>u", {noremap = true})
map({"n","v"}, "<C-z>",   "<esc>u", {noremap = true})

-- Redo
map("i",       "<C-y>",   "<C-o><C-r>")
map({"n","v"}, "<C-y>",   "<esc><C-r>")
map("i",       "<C-S-z>", "<C-o><C-r>")
map({"n","v"}, "<C-S-z>", "<esc><C-r>")


-- ### [Deletion]
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

-- Remove to start of line
map("i",       "<M-BS>", '<esc>"_d0i')
map({"n","v"}, "<M-BS>", '<esc>"_d0')


-- Clear selected char
map("v", "<M-S-BS>", 'r ') -- TODO better keybind hack with westerm

-- Clear from cursor to sol
--kmap({"i","n"}, "<M-BS>", "<cmd>norm! v0r <CR>"

-- Clear line
map({"i","n","v"}, "<S-BS>", "<cmd>norm!Vr <CR>")


-- #### Delete
-- Del char
map("n", "<Del>", 'v"_d')
map("v", "<Del>", '"_di')

-- Delete right word
map("i",       "<C-Del>", '<C-o>"_dw')
map({"n","v"}, "<C-Del>", '"_dw')
-- map("c",       "<C-Del>", '"_dw') does not work in cmd bc not a buf

-- Del to end of line
map({"i","n","v"}, "<M-Del>", function()
    if vim.fn.mode() == "" then
        vim.cmd('norm! $"_d')
    else
        vim.cmd('norm! v$h"_d')
    end
end)

-- Delete line
map({"i","n","v"}, "<S-Del>", function()
    if vim.fn.mode() == "V" then
        vim.cmd('norm!"_d')
    else
        vim.cmd('norm!V"_d')
    end
end)

-- Delete empty line without affecting reg
map("n", "dd", function()
    if vim.fn.getline(".") == "" then
        vim.cmd('norm! "_dd')
    else
        vim.cmd('norm! 0d$"_dd') -- avoids yanking \n
    end
end)

-- Smart delete string
map({"i","n"}, "<C-S-Del>", function()
    local cursopos = vim.api.nvim_win_get_cursor(0)

    vim.cmd('norm! viw"zy')
    local txt = vim.fn.getreg("z")

    vim.api.nvim_win_set_cursor(0, cursopos)

    local isword = vim.fn.match(txt, [[\k]]) == 0
    if isword then
        vim.cmd('norm! "_diw')
    else
        local obj = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]
        vim.cmd('norm! "_di'..obj)
    end
end)


-- ### [Replace]
-- Change in word
map({"i","n"}, "<C-S-r>", '<esc>"_ciw')

-- Replace selected char
map("v", "<M-r>", "r")

-- Replace visual selection with key
vim.g.visualreplace = true

---@param active boolean
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

    set_visualreplace(vim.g.visualreplace)

    vim.notify("Visual replace: ".. tostring(vim.g.visualreplace))
end

-- Visual replace on by default
set_visualreplace(vim.g.visualreplace)

map("v", "<space>", '"_di<space>', {noremap=true})
map("v", "<cr>",    '"_di<cr>',    {noremap=true})

-- TODO maybe we could simply watch for key map and ignore arrow key for ex
vim.keymap.set({"i","n","v"}, "<S-M-v>", function() toggle_visualreplace() end)


-- ### Substitute mode
map("n", "s", "<Nop>")

map({"i","n"}, "<M-S-s>",
[[<Esc>:%s/\V//g<Left><Left><Left>]],
{desc = "Enter substitue mode"})

-- Substitute in selection
map("x", "<M-S-s>",
[[<esc>:'<,'>s/\V//g<Left><Left><Left>]],
{desc = "Enter substitue mode in selection"})

-- sub word (exclusive)
map({"i","n"}, "<F50>", -- <M-F2>
[[<esc>yiw:%s/\V\<<C-r>"\>//g<Left><Left>]],
{desc = "Substitue word under cursor" })

-- sub selected (exclusive)
map("x", "<F2>",
[[y:%s/\V\<<C-r>"\>//g<Left><Left>]],
{desc = "Substitue selected" })


-- ### Incrementing
-- map("n", "+", "<C-a>")
map("v", "+", "<C-a>gv")

-- map("n", "-", "<C-x>") --Decrement
map("v", "-", "<C-x>gv") --Decrement

-- To upper/lower case
map("i", "<M-+>", "<cmd>norm! mzviwgU`z<CR>")
map("n", "<M-+>", "vgU<esc>")
map("v", "<M-+>", "gUgv")

map("i", "<M-->", "<cmd>norm! mzviwgu`z<CR>")
map("n", "<M-->", "vgu<esc>")
map("v", "<M-->", "gugv")

-- Smart increment/decrement
map({"n"}, "+", function() utils.smartincrement() end)
map({"n"}, "-", function() utils.smartdecrement() end)


-- ### Formatting
-- #### Indentation
-- Space bar in normal mode
map("n", "<space>", "i<space><esc>")

-- Indent inc
map("i", "<Tab>", function()
    local width = vim.opt.shiftwidth:get()
    vim.cmd("norm! v>")
    vim.cmd("norm! ".. width .. "l") -- smartly move cursor
end)
map("n", "<Tab>", "v>")
map("x", "<Tab>", ">gv")

-- Indent decrease
map("i", "<S-Tab>", "<C-d>")
map("n", "<S-Tab>", "v<")
map("x", "<S-Tab>", "<gv")

-- Trigger Auto indent
map({"i","n"}, "<C-=>", "<esc>==")
map("x",       "<C-=>", "=")


-- ### [Line break]
map("n", "<cr>", "i<CR><esc>")

-- Line break above
map({"i","n"}, "<S-CR>", function() vim.cmd('norm! '..vim.v.count..'O') end)
map("v",       "<S-CR>", "<esc>O<esc>gv")

-- Line break below
map({"i","n"}, "<M-CR>", function() vim.cmd('norm! '..vim.v.count..'o') end)
map("v",       "<M-CR>", "<esc>o<esc>vgv")

-- New line above and below
map({"i","n"}, "<S-M-cr>", "<cmd>norm!mzo<CR><cmd>norm!kO<CR><cmd>norm!`z<CR>")
map("v", "<S-M-cr>", function() vim.cmd("norm! `<O`>ogv") end)


-- ### [Line join]
-- Join below
map("i",       "<C-j>", "<C-o><S-j>")
map({"n","v"}, "<C-j>", "<S-j>") -- this syntax allow to use count

-- Join to upper
map("i", "<C-S-j>", "<esc>k<S-j>i") --this syntax allow to use count
map("n", "<C-S-j>", "k<S-j>")


-- ### [Text move]
---@param dir string
---@param amount number
local function move_selected(dir, count)
    local mode = vim.fn.mode()

    if mode == 'i' and dir:match("[hl]") then vim.cmd("stopinsert|norm! viw") return end

    if (mode == 'i' and dir:match("[jk]")) or mode == "n" then
        if dir == "h" then vim.cmd('norm! "zxh"zP')              return end
        if dir == "l" then vim.cmd('norm! "zxl"zP')              return end

        if dir == "k" then vim.cmd('m.-'..(count+1)..'|norm!==') return end
        if dir == "j" then vim.cmd('m.'..count..'|norm!==')      return end
    end

    if mode == "v" or "V" or "" then
        vim.cmd('norm! ') -- hack to refresh vis pos
        local vst, vsh = vim.api.nvim_buf_get_mark(0, "<"), vim.api.nvim_buf_get_mark(0, ">")
        vim.cmd('norm! gv')

        -- TODO detect sof and eof
        local atsol = (math.min((vst[2]), (vsh[2])) < 1)

        if (math.abs(vst[1] - vsh[1]) > 0 or mode == "V") and mode ~= "" then -- multilines move
            local defsw = vim.opt.shiftwidth:get()
            local vo = vim.opt_local

            if dir == "h" then vo.shiftwidth = 1; vim.cmd("norm! <gvh"); vo.shiftwidth = defsw; return end
            if dir == "l" then vo.shiftwidth = 1; vim.cmd("norm! >gvl"); vo.shiftwidth = defsw; return end

            if dir == "k" then vim.cmd("'<,'>m '<-"..(count+1).."|norm!gv=gv") return end
            if dir == "j" then vim.cmd("'<,'>m '>+"..count.."|norm!gv=gv")     return end
        end

        -- Single line selection move
        if  atsol and dir == "h" then return end

        local cmd = '"zygv"_x' .. count .. dir .. '"zP' -- "zy avoids polluting "reg
        if mode == "v"  then cmd = cmd.."`[v`]"  end
        if mode == "" then cmd = cmd.."`[`]" end
        vim.cmd("silent keepjumps norm! " .. cmd)
    end
end

-- Move selected text
map({"i","n","x"}, "<C-S-Left>",  function() move_selected("h", vim.v.count1) end)
map({"i","n","x"}, "<C-S-Right>", function() move_selected("l", vim.v.count1) end)
map({"i","n","x"}, "<C-S-Up>",    function() move_selected("k", vim.v.count1) end)
map({"i","n","x"}, "<C-S-Down>",  function() move_selected("j", vim.v.count1) end)


-- ### [Comments]
map({"i","n"}, "<M-a>", "<cmd>norm gcc<cr>", {noremap=true})
map("v",       "<M-a>", "gcgv", {remap=true})


-- ### [Macro]
-- collide with wincmd
map("n", "qq", '<nop>')
map("n", "q", '<nop>')

map({"i","n","v"}, "<S-M-m>", '<esc>qq')
map("n", "<M-m>", '@q')



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


-- ### [LSP]
-- Diag panel
map({"i","n","v"}, "<F10>", "<cmd>Trouble diagnostics toggle focus=true filter.buf=0<cr>")

map({"i","n","v"}, "<F22>", "<Cmd>DiagnosticVirtualTextToggle<CR>")

-- Ref panel
map({"i","n","v"}, "<F11>", "<cmd>Trouble lsp_references toggle focus=true<cr>")

-- Goto definition
map("i", "<F12>", "<Esc>gdi")
map("n", "<F12>", "<Esc>gd")
-- map("n", "<F12>", ":lua vim.lsp.buf.definition()<cr>")
map("v", "<F12>", "<Esc>gd")

-- Show hover window
map({"i","n"}, "<C-h>", "<Cmd>lua vim.lsp.buf.hover()<CR>")

-- Show signature
map({"i","n"}, "<C-S-h>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>")


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

-- lsp rename
map({"i","n"}, "<F2>", function()
    -- live-rename is a plugin for fancy in buffer rename preview
    require("live-rename").rename({ insert = true })
end)


-- ### Diff
-- next/prev diff or local modification
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


-- Diff put
map({"i","n"}, "<C-g>dp", "<cmd>.diffput<cr>")
map("v",       "<C-g>dp", ":diffput<cr>")

-- Diff get
map({"i","n"}, "<C-g>dg", "<cmd>.diffget<cr>")
map("v",       "<C-g>dg", ":diffget<cr>")



-- ## [Version control]
----------------------------------------------------------------------
map({"i","n","v"}, "<C-g>gc", "<cmd>GitCommitFile<cr>", {noremap=true})

map(modes, "<C-g>gl", "<Cmd>LazyGit<cr>")



-- ## [Code runner]
----------------------------------------------------------------------
-- run project
-- map({"i","n","v","c"}, "F8", )

-- run curretn file
-- map({"i","n","v"}, "", )

-- run code at cursor with sniprun
-- run curr line only and insert res below (<C-F8>)
map({"i","n"}, "<F32>","<cmd>SnipRunLineInsertResult<CR>")

-- Run selected code in visual mode
-- <F20> equivalent to <S-F8>
map("v", "<F20>", "<cmd>SnipRunSelectedInsertResult<CR>")

-- Run whole file until curr line and insert
map({"i","n"}, "<F20>", "<cmd>SnipRunToLineInsertResult<CR>")

-- exec curr line as ex command
-- F56 is <M-F8>
map({"i","n"}, "<F56>", function() vim.cmd('norm! 0"zy$'); vim.cmd('@z') end)
map("v",       "<F56>", function() vim.cmd('norm! "zy'); vim.cmd('@z') end)



-- ## [Vim Command]
----------------------------------------------------------------------
-- Open command line
map("i",       "œ", "<esc>:")
map({"n","v"}, "œ", ":")
map("t",       "œ", "<Esc><C-\\><C-n>:")

-- cmd completion menu
-- map("c", "<C-d>", "<C-d>")

-- Cmd menu nav
map("c", "<Up>", "<C-p>")
map("c", "<Down>", "<C-n>")

map("c", "<S-Tab>", "<C-n>")

-- Cmd close
map("c", "œ", "<C-c><C-L>")  --needs <C-c> and not <Esc> because Neovim behaves as if <Esc> was mapped to <CR> in cmd
-- map("c", "<esc>", "<C-c>", {noremap=true})

-- Clear cmd in insert
map("i", "<C-l>", "<C-o><C-l>")


-- Cmd win
-- Open command line window
vim.cmd('set cedit=') -- avoids interferences

map("n", "q:", 'q:')
map({"i","n","v","c"}, "<M-`>", '<esc>q:')
map("t", "<M-`>", '<Esc><C-\\><C-n>q:')

-- Easy exit command line window
vim.api.nvim_create_autocmd({ "CmdwinEnter" }, {
    group = "UserAutoCmds",
    callback = function()
        vim.keymap.set("n", "<esc>", ":quit<CR>",  {buffer=true})
        vim.keymap.set("n", "<M-`>", ':quit<CR>' , {buffer=true})
    end,
})


-- Open command line in term mode
map({"i","c"}, "<S-Œ>", "<esc>:!")
map({"n","v"}, "<S-Œ>", ":!")



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

-- Exit term mode
map("t", "<esc>", "<Esc> <C-\\><C-n>", {noremap=true})





