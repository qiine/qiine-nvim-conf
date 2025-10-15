
-- _
--| |
--| | _____ _   _ _ __ ___   __ _ _ __  ___
--| |/ / _ \ | | | '_ ` _ \ / _` | '_ \/ __|
--|   <  __/ |_| | | | | | | (_| | |_) \__ \
--|_|\_\___|\__, |_| |_| |_|\__,_| .__/|___/
--           __/ |               | |
--          |___/                |_|

local utils    = require("utils.utils")
local ts_utils = require("nvim-treesitter.ts_utils")
local lsnip    = require("luasnip")

local v   = vim
local map = vim.keymap.set
----------------------------------------



-- ## [key Options]
vim.o.timeoutlen = 375 --delay between key press to register shortcuts

-- define % motion /matching/
vim.opt.matchpairs:append({"<:>"})

-- Virtual Edit
vim.opt.virtualedit = "none" -- Snap cursor to closest char at eol
-- "none"    -- Default, disables virtual editing.
-- "onemore" -- Allows the cursor to move one character past the end of a line.
-- "block"   -- Allows cursor to move where there is no actual text in visual block mode.
-- "insert"  -- Allows inserting in positions where there is no actual text.
-- "all"     -- Enables virtual editing in all modes.

vim.api.nvim_create_autocmd({"BufEnter", "ModeChanged"}, {
    group = "UserAutoCmds",
    callback = function()
        local mode = vim.fn.mode()
        if mode == "n"  then vim.o.virtualedit = "all"     return end
        if mode == "i"  then vim.o.virtualedit = "none"    return end
        if mode == "v"  then vim.o.virtualedit = "onemore" return end
        if mode == "V"  then vim.o.virtualedit = "onemore" return end
        if mode == "" then vim.o.virtualedit = "block"   return end
    end,
})


-- Modes helpers
local modes = { "i", "n", "v", "o", "s", "t", "c" }



-- ## [General]
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

-- Omni esc
-- map({'i','n','x'}, '<esc>', "<Cmd>noh<CR><esc>")
map({'i','n','v'}, '<esc>', function()
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
map({"i","n","v","c"}, "<S-Ç>", function()  --"<S-altgr-r>"
    local cf = vim.fn.expand("%:p")
    vim.cmd("source "..cf)
    print("Ressourced: "..'"'..vim.fn.fnamemodify(cf, ":t")..'"')
end)


-- Open file manager
map(modes, "<C-e>", function()
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

-- Browse project files
-- map(modes, "<C-S-e>", function()

-- Open file picker
map(modes, "<C-o>", "<cmd>FilePicker<CR>")



-- ## [Register]
----------------------------------------------------------------------



-- ## [View]
----------------------------------------------------------------------
-- alt-z toggle line soft wrap
map({"i","n","v"}, "<C-g>z", function() vim.opt.wrap = not vim.opt.wrap:get() end)

-- Toggle auto hard wrap lines
map({"i","n","v"}, "<C-g>Z", function()
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
-- fold curr
map({"i","n","v"}, "<M-z>", "<Cmd>norm! za<CR>")
map({"i","n","v"}, "<C-S-z>", "<Cmd>norm! za<CR>")

-- Fold all
vim.keymap.set({"i","n","v"}, "<M-S-z>", function()
    local count = vim.v.count

    local folded = false
    for lnum = 1, vim.api.nvim_buf_line_count(0) do
        if vim.fn.foldclosed(lnum) > 0 then
            folded = true
            break
        end
    end

    if folded then
        vim.cmd("norm! zR")  -- open all
    else
        vim.cmd("norm! zM")  -- close all
    end
end)


-- ## [Windows]
----------------------------------------------------------------------
-- Rebind win prefix
map({"i","n","v"}, "<M-w>", "<esc><C-w>", {noremap=true})
map("t",           "<M-w>", "<Esc> <C-\\><C-n><C-w>", {noremap=true})

-- Open window
map(modes, "<M-w>n", function ()
    -- local wopts = {
    --     split = "right",
    --     height = 33,
    --     width = 38
    -- }
    -- vim.api.nvim_open_win(0, true, wopts)
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

-- Resize wins
local function resize_win(dir, amount)
    local curwin = vim.api.nvim_get_current_win()
    vim.cmd('wincmd t') -- always resize from top left
    vim.cmd(dir.." resize "..amount)
    vim.api.nvim_set_current_win(curwin)
end

-- Resize hor
map({"i","n","v"}, "<M-w><Up>",    function() resize_win("hor", "-5") end, {noremap = true})
map({"i","n","v"}, "<M-w><Down>",  function() resize_win("", "+5") end, {noremap = true})
-- Resize vert
map({"i","n","v"}, "<M-w><Right>", function() resize_win("vert", "+5") end, {noremap = true})
map({"i","n","v"}, "<M-w><Left>",  function() resize_win("vert", "-5") end, {noremap = true})

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
-- ### [Scrolling]
map({"i","n","v","c","t"}, "<M-C-S-Right>", "<Cmd>silent! norm! 7zl<CR>")
map({"i","n","v","c","t"}, "<M-C-S-Left>",  "<Cmd>silent! norm! 7zh<CR>")
map({"i","n","v","c","t"}, "<M-C-S-Down>",  "<Cmd>silent! norm! 4<CR>")
map({"i","n","v","c","t"}, "<M-C-S-Up>",    "<Cmd>silent! norm! 4<CR>")

-- m' is used to write into jump list
-- Fast left/right move in normal mode
map('n', '<C-Right>', "m'7l")
map('n', '<C-Left>',  "m'7h")

-- ctrl+up/down to move fast
map("i",       "<C-Up>", "<esc>m'3ki")
map({"n","v"}, "<C-Up>", "m'3k")

map("i",       "<C-Down>", "<esc>m'3ji")
map({"n","v"}, "<C-Down>", "m'3j")


-- ### [Jump]
-- Jump to start/end of line
map({"i","n","v"}, "<M-Left>",  "<cmd>norm! 0<cr>")
map("c",           "<M-Left>",  "<C-a>")

map("i",           "<M-Right>", "<cmd>norm! $a<cr>") -- notice the 'a'
map({"n","v"},     "<M-Right>", function()
    if vim.fn.getline(".") == "" then
        vim.cmd("norm! 0"..vim.opt.textwidth:get().."l")
    else
        vim.cmd("norm! $")
    end
end)
map("c",           "<M-Right>", "<C-e>")

-- Jump home/end
map("i",       "<Home>", "<Esc>ggI")
map({"n","v"}, "<Home>", "gg0")

map("i",       "<End>", "<Esc>GA")
map({"n","v"}, "<End>", "G$")

-- Jump screen up/down
map({"i","n","v"}, "<M-Up>", function()
    local wheight = vim.api.nvim_win_get_height(0)
    local cpos    = vim.api.nvim_win_get_cursor(0)

    if cpos[1] == vim.fn.line("w0") then
        vim.cmd("norm! "..wheight.."k")
    end

    vim.cmd("norm! H")
end)
map({"i","n","v"}, "<M-Down>", function()
    local wheight = vim.api.nvim_win_get_height(0)
    local cpos    = vim.api.nvim_win_get_cursor(0)

    if cpos[1] == vim.fn.line("w$") then
        vim.cmd("norm! "..wheight.."j")
    end

    vim.cmd("norm! L")
end)

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
    -- vim.cmd("norm v%")

    local node = ts_utils.get_node_at_cursor()
    local char = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]

    if node:type() == "function_definition" or node:type() == "function_declaration" then
        local curso_spos = vim.api.nvim_win_get_cursor(0)

        vim.cmd("norm vaf")

        local curso_epos = vim.api.nvim_win_get_cursor(0)

        if curso_spos[1] == curso_epos[1] and curso_spos[2] == curso_epos[2] then
            vim.cmd('norm! o')
        end

        vim.cmd('norm! ')
        return
    end

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

-- Jump nav mark
map({"i","n","v"}, "<S-M-m>", "<Cmd>norm! mJ<CR><Cmd>echo'Jump mark set'<CR>")
map({"i","n","v"}, "<M-m>",   "<Cmd>norm! `Jzz<CR>")

-- To next/prev cursor jump loc
map({"i","n","v"}, "<M-PageDown>",  "<Esc><C-o>")
map({"i","n","v"}, "<M-PageUp>",    "<Esc><C-i>")


-- Jump seek
map("n", "f", function()
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

-- ### Directory navigation
-- Move one dir up
map({"i","n","v"}, "<C-Home>", "<Cmd>cd .. | pwd<CR>")

-- To prev directory
map({"i","n","v"}, "<C-End>", "<cmd>cd - | pwd<CR>")


-- Interactive cd
map({"i","n","v","c"}, "<M-End>", function()
    vim.api.nvim_feedkeys(":cd ", "n", false)
    vim.api.nvim_feedkeys("	", "c", false) --triggers comp menu
    -- vim.api.nvim_create_autocmd('DirChanged', {
    --     group = 'UserAutoCmds',
    --     callback = function()
    --         print(vim.fn.getcwd())
    --     end,
    -- })
end)

-- cd shortcuts
-- cd curr file dir
map({"i","n","v"}, "<C-S-Home>", function() vim.cmd("cd "..vim.fn.expand("%:h").."|pwd") end)

-- cd proj root
map({"i","n","v"}, "<M-Home>", function()
    local rootdir = vim.fs.dirname(vim.fs.find({".git", "Makefile", "package.json" }, {upward = true })[1])
    if rootdir then
        vim.cmd("cd "..rootdir)
        vim.cmd("pwd")
    end
end)

-- cd to home
map({"i","n","v"}, "<M-S-Home>", function() vim.cmd("cd | pwd") end)

-- cd to sys root dir
map({"i","n","v"}, "<M-C-S-Home>", function() vim.cmd("cd / | pwd") end)


-- Hyper act
map({"i","n","v"}, "<C-CR>", "<Cmd>HyperAct<CR>", {noremap=true})


-- Open task
-- General task
map({"i","n","v","c","t"}, "<F4>", function()
    local fname = vim.fn.expand("%:t")

    if fname ~= "plan.md" then
        vim.cmd("e /home/qm/Personal/Org/plan.md")
        vim.opt_local.foldlevel = 2
    elseif fname == "plan.md" then
        vim.cmd("bwipeout")
    end
end)

-- Project task <S-F4>
map({"i","n","v","c","t"}, "<F16>", function()
    local fname = vim.fn.expand("%:t")

    if fname ~= "todo.md" then
        vim.cmd("e /home/qm/Personal/dotfiles/User/nvim/todo.md")
    elseif fname == "plan.md" then
        vim.cmd("bwipeout")
    end
end)


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

map("v", "<M-f>n", '<Cmd>WebSearch<CR>')



-- ## [Selections]
----------------------------------------------------------------------
-- Selection anchors sawp
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

-- ### Visual block selection
-- Move to visual block selection regardless of mode
local function arrow_blockselect(dir)
    if vim.fn.mode() == "" then vim.cmd("norm! "              ..dir)
    else                          vim.cmd("stopinsert|norm!"..dir)
    end
end

map({"i","n","v"}, "<S-M-Left>",  function() arrow_blockselect("h") end)
map({"i","n","v"}, "<S-M-Right>", function() arrow_blockselect("l") end)
map({"i","n","v"}, "<S-M-Up>",    function() arrow_blockselect("k") end)
map({"i","n","v"}, "<S-M-Down>",  function() arrow_blockselect("j") end)



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
map({"i","n"}, "<C-S-n>v", function()
    lsnip.try_insert_snippet("var")
end)

map({"i","n"}, "<C-S-n>vt", function()
    lsnip.try_insert_snippet("var table")
end)

-- Insert func
map({"i","n"}, "<C-S-n>f", function()
    lsnip.try_insert_snippet("func")
end)

map({"i","n"}, "<C-S-n>fa", function()
    lsnip.try_insert_snippet("anon func")
end)

-- Insert if
map({"i","n"}, "<C-S-n>i", function()
    lsnip.try_insert_snippet("if")
end)

-- Insert loop
map({"i","n"}, "<C-S-n>fe", function()
    lsnip.try_insert_snippet("for each")
end)

-- Insert print
map({"i","n"}, "<C-S-n>p", function()
    lsnip.try_insert_snippet("print")
end)


-- ### [Clipboard]
-- #### Copy
map("v", "<C-c>", function()
    vim.cmd('norm! mz"+y`z'); print("Selection copied")
end, {noremap=true})

-- Smart copy
map({"i","n"}, "<C-c>", function()
    local char = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("."))[1]
    vim.cmd('norm! mz"zyiw`z'); local word = vim.fn.getreg("z")
    vim.cmd('norm! mz"zyi'..char..'`z'); local obj  = vim.fn.getreg("z")

    if char == " " or char == "" then return end

    if char:match("[(){}%[%]'\"`<>]") and obj ~= "" then
        vim.fn.setreg("+", obj)
        print("Obj copied") return
    end

    if vim.fn.match(word, [[\v^\k+$]]) ~= -1 then
        vim.fn.setreg("+", word)
        print("Word copied") return
    end

    vim.fn.setreg("+", char)
    print("Char copied") return
end, {noremap=true})

-- Copy line
map({"i","n"}, "<C-S-c>", function()
    vim.cmd('norm! mz0"+y$`z'); print("Line Copied")
end, {noremap=true})

-- Yank line, exclude newline char
map("n", "yy", "0y$", {noremap=true})

-- Copy append selection
map("v", "<S-M-c>", function()
    local reg_prev = vim.fn.getreg("+")

    vim.cmd('norm! mz"+y`z')

    vim.fn.setreg("+", reg_prev .. vim.fn.getreg("+"))

    print("Appended to clipboard")
end)


-- #### [Cut]
map("v", "<C-x>", '"+d<esc>', {noremap=true})

-- Cut line
map({"i","n"}, "<C-S-x>", function()
    vim.cmd('norm! mz0"+d$`z')
end, {noremap=true})

-- Smart cut
map({"i","n"}, "<C-x>", function()
    local char = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("."))[1]
    vim.cmd('norm! mz"zyiw`z'); local word = vim.fn.getreg("z")
    vim.cmd('norm! mz"zyi'..char..'`z'); local obj  = vim.fn.getreg("z")

    if char == " " or char == "" then return end

    if char:match("[(){}%[%]'\"`<>]") and obj ~= "" then
        vim.cmd('norm! mz"+di'..char..'`z')
        print("Obj cut") return
    end

    if vim.fn.match(word, [[\v^\k+$]]) ~= -1 then
        vim.cmd('norm! mz"+diw`z')
        print("Word cut") return
    end

    vim.cmd('norm! "+dl')
    print("Char cut") return
end, {noremap=true})


-- #### [Paste]
map("i", "<C-v>", '<Cmd>norm! "+Pa<CR>')
map("v", "<C-v>", '"_d"+P')

-- Smart paste
map("n", "<C-v>", function()
    local curso_pos = vim.fn.getpos(".")
    local char   = vim.fn.getregion(curso_pos, curso_pos)[1]
    -- local char_l = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]
    -- local char_r = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]
    vim.cmd('norm! mz"zyiw`z'); local word = vim.fn.getreg("z")

    -- local char_isolated = char_l == " " and char_r == " "
    if vim.fn.match(word, [[\v^\k+$]]) ~= -1 then
        vim.cmd('norm! "_diw"+P')
    else
        vim.cmd('norm! "+P')
    end

    -- Format after paste
    local ft = vim.bo.filetype
    if ft == "" then
        -- no formating for unknown ft
    elseif ft == "markdown" or ft == "text" then
        vim.cmd("norm! `[v`]gq")
    else
        vim.cmd("norm! `[v`]=")
    end

    vim.cmd("norm! `]") -- Proper curso placement
end)
map("c", "<C-v>", '<C-R>+')
map("t", "<C-v>", '<Esc> <C-\\><C-n>"+Pi') --TODO kinda weird


-- Paste swap selected
vim.keymap.set("v", "<S-M-v>", function()
    local text = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))[1]
    local vst, vsh = vim.api.nvim_buf_get_mark(0, "["), vim.api.nvim_buf_get_mark(0, "]")

    vim.cmd('norm! "_d"+P') -- replace target

    -- replace origin
    vim.api.nvim_buf_set_text(0,
        vst[1]-1, vst[2], vsh[1]-1, vsh[2]+1,
        {text}
    )
end,
{desc="first copy origin text, then select target text and paste swap"})

-- Paste swap word
vim.keymap.set({"i","n"}, "<M-v>", function()
    local vst, vsh = vim.api.nvim_buf_get_mark(0, "["), vim.api.nvim_buf_get_mark(0, "]")

    -- replace target
    vim.cmd('norm! "zyiw');
    local text = vim.fn.getreg("z")

    -- replace origin
    vim.api.nvim_buf_set_text(0,
        vst[1]-1, vst[2], vsh[1]-1, vsh[2]+1,
        {text}
    )

    vim.cmd('norm! "_diw') --avoids trashing regs
    vim.cmd('norm! "+P')
end,
{desc="Same as paste swap but auto select word"})


-- Duplicate
map({"i","n"}, "<C-d>", function() vim.cmd('norm!"zyy'..vim.v.count..'"zp') end, {desc="dup line"})
map("v",       "<C-d>", '"zy"zP', {desc="dup sel"})


-- ### [Undo/redo]
-- ctrl+z to undo
map("i",       "<C-z>",   "<C-o>u", {noremap = true})
map({"n","v"}, "<C-z>",   "<esc>u", {noremap = true})

-- Redo
map("i",       "<C-y>",   "<C-o><C-r>")
map({"n","v"}, "<C-y>",   "<esc><C-r>")


-- ### [Deletion]
-- #### Remove
-- kmap("i", "<BS>", "<C-o>x", {noremap=true, silent=true}) --maybe not needed on wezterm
-- kmap("n", "<BS>", '<Esc>"_X<Esc>')

-- Remove word left
-- <M-S-BS> instead of <C-BS> because of wezterm
map("i", "<S-M-BS>", '<esc>"_dbi')
map("n", "<S-M-BS>", '"_db')
map("c", "<S-M-BS>", '<C-w>')

-- Remove to start of line
map({"i","n","v"}, "<M-BS>", function()
    if vim.fn.mode() == "" then
        vim.cmd('norm! 0"_d')
    else
        vim.cmd('norm! "_d0')
    end
end)

-- Clear char
map({"n","v"}, "<BS>", 'r ')

-- Clear from cursor to sol
--kmap({"i","n"}, "<M-BS>", "<cmd>norm! v0r <CR>"

-- Clear line
map({"i","n","v"}, "<S-BS>", "<cmd>norm!Vr <CR>")
map("c", "<S-BS>", '<C-u>')

-- #### Delete
-- Del char
map("n", "<Del>", 'v"_d')
map("v", "<Del>", '"_di')

-- Delete right word
map("i",       "<C-Del>", '<C-o>"_dw')
map({"n","v"}, "<C-Del>", '"_dw')
map("c",       "<C-Del>", '<C-right><C-w>')

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
        vim.cmd('norm! "_d')
    else
        vim.cmd('norm! V"_d')
    end
end)
map("c", "<S-Del>", "<C-u>")

map("n", "dd", function()
    if vim.fn.getline(".") == "" then -- Del empty line without trashing reg
        vim.cmd('norm! "_dd')
    else
        vim.cmd('norm! 0d$"_dd') -- avoids yanking \n
    end
end)

-- Smart delete
map({"i","n"}, "<C-S-Del>", function()
    local char = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]

    if char:match("[(){}%[%]'\"`<>]") then
        vim.cmd('norm! "_di'..char)
        -- vim.cmd('norm "_d%') -- off for now
    else
        vim.cmd('norm! "_diw')
    end
end)

-- TODO C-S-BS collides
-- Smart delete inside
-- map({"i","n"}, "<S-M-BS>", function()
    -- local char = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]

    -- if char:match("[(){}%[%]'\"`<>]") then
    --     vim.cmd('norm! "_di'..char)
    -- else
    --     vim.cmd('norm! "_diw')
    -- end
-- end)


-- ### [Replace]
-- Change in word
map({"i","n"}, "<C-S-r>", '<esc>"_ciw')

-- Replace selected char
map("v", "<C-r>", "r")

-- Replace visual selection with key
vim.g.visualreplace = true

---@param active boolean
local function set_visualreplace(active)
    local chars = vim.iter({
        utils.alphabet_lowercase,
        utils.alphabet_uppercase,
        utils.numbers,
        utils.punctuation,
    }):flatten(1):totable()

    for _, char in ipairs(chars) do
        if active then
            map('x', char, '"_d<esc>i'..char, {noremap=true})
        else
            pcall(vim.keymap.del, 'x', char)
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

-- TODO p3 maybe we could simply watch for key map and ignore arrow key for ex
vim.keymap.set({"i","n","v"}, "<C-g>v", function() toggle_visualreplace() end)


-- ### Substitute mode
map("n", "s", "<Nop>")

map({"i","n"}, "<M-S-s>",
[[<Esc>:%s/\V//g<Left><Left><Left>]],
{desc = "Enter substitute mode"})

-- Substitute in selection
map("v", "<M-S-s>",
[[<esc>:'<,'>s/\V//g<Left><Left><Left>]],
{desc = "Enter substitute mode in selection"})

-- Sub word (exclusive)
map({"i","n"}, "<F50>", -- <M-F2>
[[<esc>yiw:%s/\V\<<C-r>"\>//g<Left><Left>]],
{desc = "Substitute word under cursor" })

-- Sub selected (exclusive)
map("v", "<F2>",
[[y:%s/\V\<<C-r>"\>//g<Left><Left>]],
{desc = "Substitute selected" })

-- TODO p3 Filter buffer content by word
map({"i","n"}, "<S-ª>",
[[<Esc>:%s/\v(word)|./\1/g<Left><Left>]],
{desc = "Inverse filter" })


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

-- ### [Formatting]
-- space
map("n", "<space>", "i<space><esc>")

-- #### Indentation
-- Indent inc
map({"i","n"}, "<Tab>", function()
    local swidth = vim.opt.shiftwidth:get()
    local crspos = vim.api.nvim_win_get_cursor(0)

    if vim.fn.getline(".") ~= "" then
        vim.cmd("norm! v>")
    else
        vim.cmd("norm! "..swidth.."i ") -- indent even empty lines
    end

    if vim.fn.mode() == "i" then
        vim.api.nvim_win_set_cursor(0, {crspos[1], crspos[2]+swidth}) -- crs follow indent change
    end
end)
map("x", "<Tab>", ">gv")

-- Indent decrease
map("i", "<S-Tab>", "<C-d>")
map("n", "<S-Tab>", "v<")
map("x", "<S-Tab>", "<gv")

-- Trigger Auto indent
map("i", "<C-=>", "<C-o>==")
map("n", "<C-=>", "==")
map("x", "<C-=>", "=")


-- ### [Break line]
map("n", "<cr>", function()
    if vim.bo.buftype == "" then
        return "i<CR><esc>"
    else
        return "<CR>"
    end
end, {expr=true})

-- Break line above
map({"i","n"}, "<S-CR>", function() vim.cmd('norm! '..vim.v.count..'O') end)
map("v",       "<S-CR>", "<esc>O<esc>gv")

-- Break line below
map({"i","n"}, "<M-CR>", function() vim.cmd('norm! '..vim.v.count..'o') end)
map("v",       "<M-CR>", "<esc>o<esc>vgv")

-- New line above and below
map({"i","n"}, "<S-M-cr>", "<cmd>norm!mzo<CR><cmd>norm!kO<CR><cmd>norm!`z<CR>")
map("v", "<S-M-cr>", function() vim.cmd("norm! `<O`>ogv") end)


-- ### [Line join/split]
-- Join below
map("i",       "<C-j>", "<C-o><S-j>")
map({"n","v"}, "<C-j>", "<S-j>") -- this syntax allow to use count

-- Join to upper
map("i", "<C-S-j>", "<esc>k<S-j>i") --this syntax allow to use count
map("n", "<C-S-j>", "k<S-j>")

-- Split
map("n", "<M-j>", function()
    vim.cmd("silent! "..[[s/, /,\r/g]])
    vim.cmd("noh")
end)


-- ### [Text move]
---@param dir string
---@param count number
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

        local cmd = '"zygv"_x' .. count .. dir .. '"zP' -- "zy avoids polluting reg"
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
map({"i","n"}, "<C-S-a>", "<cmd>norm gcc<cr>", {noremap=true})
map("v",       "<C-S-a>", "gcgv", {remap=true})


-- ### [Macro]
-- avoid colliding with wincmd
map("n", "qq", '<nop>')
map("n", "q", '<nop>')

-- record
map({"i","n","v"}, "<C-!>r", '<esc>qq')
-- rec stop
map({"i","n","v"}, "<C-!>s", '<esc>q')
-- exec
map("n", "<C-!>e", '@q')



-- ## [Text intelligence]
----------------------------------------------------------------------
-- ### [Word processing]
-- Toggle spellcheck
map({"i","n","v","c","t"}, "<M-s>s", function()
    vim.opt.spell = not vim.opt.spell:get()
    print("Spellchecking: " .. tostring(vim.opt.spell:get()))
end, { desc = "Toggle spell checking" })

-- Pick documents language
map({"i","n","v","c","t"}, "<M-s>l", "<cmd>PickDocÇanguage<CR>")

-- Suggest
map({"i","n","v"}, "<M-s>c", "<Cmd>FzfLua spell_suggest<CR>")

-- Quick correct
map({"i","n","v"}, "<M-c>", "<Cmd>norm! m`1z=``<CR>")

-- Add word to dictionary
map({"i","n"}, "<M-s>a", "<Esc>zg")
map("x",       "<M-s>a", "zg")
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

-- Add word to selected dict
map({"i","n","x"}, "<M-s>ad", function()
    local langs = vim.opt.spelllang:get()
    vim.ui.select(langs, { prompt = "Pick dict lang: " }, function(choice)
        if not choice then return end

        local langindex
        for i, s in ipairs(langs) do
            if s == choice then langindex = i break end
        end

        local word
        if vim.fn.mode() == "v" then
            word = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))[1]
        else
            vim.cmd('norm! mz"zyiw`z')
            word = vim.fn.getreg("z")
        end

        local spelf = vim.fn.readfile(vim.opt.spellfile:get()[1])
        if vim.tbl_contains(spelf, word) then
            vim.notify("Already in dictionary: " .. word)
        else
            local cmd = vim.fn.mode() == "v" and "norm! " or "norm! gv"
            vim.cmd(cmd .. langindex .. "zg")
        end
    end)
end)


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
map({"i","n","v"}, "<F10>", "<Cmd>Trouble diagnostics toggle focus=true filter.buf=0<cr>")

map({"i","n","v"}, "<F22>", "<Cmd>DiagnosticVirtualTextToggle<CR>")

map({"i","n","v"}, "<C-PageUp>d",  "]d")
map({"i","n","v"}, "<C-PageDow>d", "[d")

-- Ref panel
map({"i","n","v"}, "<F11>", "<cmd>Trouble lsp_references toggle focus=true<cr>")

-- Goto definition
map("i", "<F12>", "<Esc>gdi")
map("n", "<F12>", "gd")
-- map("n", "<F12>", ":lua vim.lsp.buf.definition()<cr>")
map("v", "<F12>", "<Esc>gd")


-- Show hover window
map({"i","n"}, "<C-h>", function()
    vim.lsp.buf.hover()
    vim.lsp.buf.hover() -- second time to go into fwin weird

    vim.opt_local.winborder  = "single" -- double
    -- vim.opt_local.wrap       = false
    -- vim.opt_local.spell      = false
    -- vim.opt_local.signcolumn = "no"
    -- vim.opt_local.number     = false
    -- vim.opt_local.foldcolumn = "0"
end)

-- Show signature
map({"i","n"}, "<M-h>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>")


-- Rename symbol
--vmap({"i","n"}, "<F2>", function()
--    vim.api.nvim_create_autocmd({ "CmdlineEnter" }, {
--        callback = function()
           local key = vim.api.nvim_replace_termcodes("<C-f>", true, false, true)
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
-- exec sel
vim.keymap.set("v", "<M-S-p>", function()
    local sel = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))[1]
    vim.fn.setreg("z", "lua print("..sel..")")
    vim.cmd("@z")
end)

-- run curr line only and insert res below (<C-F8>)
map({"i","n"}, "<F32>","<cmd>SnipRunLineInsertResult<CR>")

-- Run selected code, insert res, <F20> equivalent to <S-F8>
map("v", "<F20>", "<cmd>SnipRunSelectedInsertResult<CR>")

-- Run whole file until curr line and insert res
map({"i","n"}, "<F20>", "<cmd>SnipRunToLineInsertResult<CR>")

-- run curretn file F56 is <M-F8>
map({"i","n","v"}, "<F56>", function()  end)

-- run project
vim.keymap.set({"i","n","v"}, "<F8>", function()
    local cwd = vim.fn.getcwd()
    local markers = {".git", "Makefile", "package.json"}
    local diroot = vim.fs.dirname(vim.fs.find(markers, {upward=true})[1])

    local file = vim.fn.expand("%:p")
    local ft = vim.bo.filetype
    local nofile = file == "" or vim.fn.filereadable(file) == 0
    local buft = vim.bo.buftype

    if diroot and vim.fn.filereadable(diroot .. "/Makefile") == 1 then
        vim.fn.chdir(diroot)
        vim.cmd("silent! make")
        vim.cmd("copen")
    else
        local cmd
        if nofile then -- Dump buffer to temp file
            local tmp = vim.fn.tempname() .. "." .. ft
            vim.fn.writefile(vim.api.nvim_buf_get_lines(0, 0, -1, false), tmp)
            file = tmp
        end

        if ft == "lua" then
            cmd = "lua " .. vim.fn.shellescape(file)
        elseif ft == "python" then
            cmd = "python " .. vim.fn.shellescape(file)
        elseif ft == "sh" then
            cmd = "bash " .. vim.fn.shellescape(file)
        else
            vim.notify("No runner defined for filetype: " .. ft, vim.log.levels.WARN)
        end

        if buft ~= "terminal" then
            vim.cmd("split | resize 9")
            vim.cmd("terminal")
            vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
            vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})

            vim.cmd("startinsert")
        end
        vim.fn.setreg("z", cmd)
        vim.cmd('norm! "zP')
        vim.api.nvim_feedkeys("\13", "t", false)
    end

    vim.fn.chdir(cwd)
end)



-- ## [Command line]
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


-- cmd messages <S-F10>
map({"i","n","v","c","t"}, "<F22>", "<Esc><Cmd>MsgLog<CR>")



-- ## [Terminal]
----------------------------------------------------------------------
-- Open term
map({"i","n","v"}, "<M-t>", "<cmd>term<CR>", {noremap=true})

-- Quick split term
map({"i","n","v"}, "<M-w>t", function()
    vim.cmd("vsp | term")

    vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
    vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})
end, {noremap=true})

map({"i","n","v"}, "<M-w>th", function()
    vim.cmd("split | term")

    vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
    vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})
    vim.api.nvim_win_set_height(0, 9)
end, {noremap=true})

-- Exit term mode
map("t", "<esc>", "<Esc> <C-\\><C-n>", {noremap=true})





