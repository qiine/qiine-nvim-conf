-- _
--| |
--| | _____ _   _ _ __ ___   __ _ _ __  ___
--| |/ / _ \ | | | '_ ` _ \ / _` | '_ \/ __|
--|   <  __/ |_| | | | | | | (_| | |_) \__ \
--|_|\_\___|\__, |_| |_| |_|\__,_| .__/|___/
--           __/ |               | |
--          |___/                |_|

local utils    = require("utils")
local fs       = require("fs")
local win      = require("ui.win")
local drawer   = require("ui.drawer")
local term     = require("term")

local git      = require("git.git")

local ts_utils = require("nvim-treesitter.ts_utils")
local lsnip    = require("luasnip")


local v   = vim
local map = vim.keymap.set

-- Modes helpers
local modes = { "i", "n", "v", "o", "s", "t", "c" }


----------------------------------------

-- ## [key Options]
vim.o.timeoutlen = 400 --delay between key press to register shortcuts

-- Define % motion /matching/
vim.opt.matchpairs:append({"<:>"})

-- Virtual Edit
vim.o.virtualedit = "none" -- Snap cursor to closest char at eol
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


-- ## [General]
----------------------------------------------------------------------
-- Ctrl+q to quit
map(modes, "<C-q>", "<cmd>qa!<CR>", {noremap=true, desc="Force quit nvim"})

-- Quick restart nvim
map(modes, "<C-M-r>", "<cmd>Restart<cr>")

-- F5 reload buffer
map({"i","n","v"}, "<F5>", "<cmd>e!<CR><cmd>echo'Buffer reloaded'<CR>")

-- Omni esc
map({'i','n','x'}, '<esc>', function() -- need "x", mess with s mode otherwise
    vim.cmd('noh')
    return '<esc>'
end, {expr = true, desc = "Escape and clear hlsearch"})

-- g
map("i",       '<C-g>', "<esc>g", {noremap=true})
map({"n","v"}, '<C-g>', "g",      {noremap=true})

-- Help
map({"i","n"}, "<F1>", function()
    if vim.bo.buftype == "help" then return vim.cmd("bwipeout!") end

    vim.cmd("help")
    vim.api.nvim_win_set_height(0, 18)
end)



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
    local curtabwins_valid = vim.tbl_filter(
        function(input)
            local buf = vim.api.nvim_win_get_buf(input)
            return vim.bo[buf].filetype ~= "scrollview"
        end,
        vim.api.nvim_tabpage_list_wins(0)
    )
    local tabwincnt  = #curtabwins_valid
    local isfloatwin = vim.api.nvim_win_get_config(0).relative ~= ""

    local bufid     = vim.api.nvim_win_get_buf(0)
    local bufwincnt = #(vim.fn.win_findbuf(bufid))
    local buftype   = vim.bo[bufid].buftype
    local bufmodif  = vim.bo[bufid].modified

    -- Try close cmdline before anything
    if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end

    -- Custom unsaved warning
    if bufmodif and bufwincnt == 1 then
        local choice = vim.fn.confirm("Unsaved changes, quit anyway? ", "&Yes\n&No", 1)
        if choice ~= 1 then return end
    end

    -- determine if last valid buf
    local bufs = vim.tbl_filter(function(buf)
        return vim.bo[buf].filetype ~= "scrollview"
                and vim.bo[buf].buflisted
                or vim.bo[buf].filetype == "oil"
    end, vim.api.nvim_list_bufs())

    if #bufs == 1 then -- create default buf (dashboard)
        vim.cmd("enew");  vim.bo[0].buflisted=false; vim.bo[0].bufhidden="wipe"
        vim.cmd("Alpha"); vim.cmd("stopinsert")
    end

    if vim.fn.winlayout()[1] ~= "leaf" or isfloatwin then -- detect if curr tab has splits
        if bufwincnt == 1 then -- avoids destroying buf we want to keep if in 2+ splits
            if tabwincnt == 2 then
                -- Try close aerial/neo-tree when killing curr buf bc :close is buggy on it
                vim.cmd("AerialCloseAll")

                -- Try close neo-tree
                for _, bfid in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.bo[bfid].filetype == "neo-tree" then
                        vim.cmd("bwipeout "..bfid)
                    end
                end

                vim.cmd("cclose")
            end --tabwincnt?

            vim.cmd("silent! close")
            vim.cmd("silent! bd! "..bufid) -- "bd!" bc I tend to not want to keep bufs in splits

            if buftype == "" and vim.bo[0].filetype ~= "alpha" then -- help merge splits if other buf is unlist, wipe
                vim.bo[0].buflisted = true; vim.bo[0].bufhidden = ""
            end
        else
            vim.cmd("close")
        end
    else -- no splits so just destroy curbuf
        if buftype == "terminal" then
            vim.cmd("silent! bwipeout! "..bufid)
        else
            vim.cmd("silent! bd! "..bufid)
        end
    end
end, {noremap=true})



-- ## [Filesystem]
----------------------------------------------------------------------
-- Open surrounding files
map({"i","n","v"}, "<C-S-PageUp>", function() fs.file_open_next(false) end)
map({"i","n","v"}, "<C-S-PageDown>", function() fs.file_open_next(true) end)

-- File action
map({"i","n","v"}, "<C-g>fn", fs.file_create)
map({"i","n","v"}, "<C-g>fd", fs.file_dup)
-- map({"i","n","v"}, "<C-g>fm", "<Cmd>FileMove<CR>")
map({"i","n","v"}, "<C-g>fm", fs.file_move_cur_interac)
map({"i","n","v"}, "<C-g>fr", "<Cmd>FileRename<CR>")
map({"i","n","v"}, "<M-S-Del>", "<Cmd>FileDelete<CR>")

-- ### Write
-- Save current
map({"i","n","v","c"}, "<C-s>", "<Cmd>FileSaveInteractive<CR>")

-- Save as
map({"i","n","v","c"}, "<C-M-s>", "<Cmd>FileSaveAsInteractive<CR>")

map("v", "<C-g>fa", function() fs.append_select_to_file() end)
map("v", "<C-g>fc", function() fs.move_select_to_file() end)

-- Ressource curr file
map({"i","n","v","c"}, "<S-Ç>", function()  --"<S-altgr-r>"
    local cf = vim.fn.expand("%:p")
    vim.cmd("source "..cf)
    print("Ressourced: "..'"'..vim.fn.fnamemodify(cf, ":t")..'"')
end)


-- ### File explorer
map({"i","n","v"}, "<C-g>fl", "<Cmd>!pwd; ls -lFAh<CR>")

-- Open filetree
map({"i","n","v","t"}, "<C-b>", function()
    local rootdir = fs.utils.get_file_proj_rootdir(vim.api.nvim_buf_get_name(0))

    require("neo-tree.command").execute({
        action = "show",
        toggle = true,
        focus  = false,
        dir    = rootdir,
    },{})
end)

-- Open file explorer
map({"i","n","v","t"}, "<C-e>", function()
    local pbuf       = vim.api.nvim_get_current_buf()
    local pbufwincnt = #(vim.fn.win_findbuf(pbuf))
    local pbufhide   = vim.bo[pbuf].bufhidden ~= ""

    require("oil").open(
        vim.fn.getcwd(),
        nil,
        function()
            if pbufhide then return end

            if vim.fn.winlayout()[1] ~= "leaf" then -- detect if curr tab has splits
                if pbufwincnt > 1 then return end -- avoids destroying buf we want to keep

                vim.bo[0].buflisted = false
            end

            vim.cmd("silent! bd "..pbuf)
        end
    )
end)

-- Open file explorer in hor split
map({"i","n","v","t"}, "<C-S-e>s", function()
    vim.cmd("split h")

    require("oil").open(
        vim.fn.getcwd(),
        nil,
        function() vim.bo[0].buflisted = false end
    )
end)

-- Browse project files
map({"i","n","v","t"}, "<C-S-e>", function()
    local rootdir = vim.fs.dirname(vim.fs.find({".git", "Makefile", "package.json" }, {upward = true })[1])

    require("oil").open(vim.fn.getcwd())

    vim.cmd("silent! bwipeout #")

    require("neo-tree.command").execute({
        action = "show",
        dir    = rootdir,
        focus  = false,
    },
    {
        bind_to_cwd = false
    })
end)

-- Open file picker
map(modes, "<C-o>", "<cmd>OpenDesktopFilePicker<CR>")


-- ### Outliner
map({"i","n","v"}, "<C-S-B>", "<cmd>AerialToggle<CR>")
-- map({"i","n","v"}, "<C-S-B>", "<cmd>AerialToggle!<CR>") -- ! prevent focus



-- ## [View]
----------------------------------------------------------------------
-- Toggle line soft wrap
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
map({"i","n","v"}, "<M-S-z>", function()
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
local ldwin = "<M-w>"

-- Rebind win prefix
map({"i","n","v","c"}, ldwin, "<esc><C-w>", {noremap=true})
map("t",               ldwin, "<Esc> <C-\\><C-n><C-w>", {noremap=true})


-- ### Create
-- Open hor/ver split
map(modes, ldwin.."v", function() win.open_split_ephem("vert") end)
map(modes, ldwin.."w", function() win.open_split_ephem("hor") end)

-- Open float win
map(modes, ldwin.."n",  win.fwin_open)
map(modes, ldwin.."nf", win.fwin_open)

-- Swap splits
map({"i","n","v","t"}, ldwin.."<S-Left>",  "<cmd>wincmd H<CR>")
map({"i","n","v","t"}, ldwin.."<S-Right>", "<cmd>wincmd L<CR>")
map({"i","n","v","t"}, ldwin.."<S-Up>",    "<cmd>wincmd K<CR>")
map({"i","n","v","t"}, ldwin.."<S-Down>",  "<cmd>wincmd J<CR>")

-- Focus cur split close all others
map({"i","n","v","t"}, ldwin.."<S-f>", "<cmd>only<CR>")


-- ### Size
-- Maximize split toggle
map(modes, ldwin.."f", win.split_maximize_toggle)

-- Auto resize wins splits
local function resize_win(dir, amount)
    local curwin = vim.api.nvim_get_current_win()

    vim.cmd('wincmd t') -- always resize from top left
    vim.cmd(dir.." resize "..amount)

    vim.api.nvim_set_current_win(curwin)
end

-- Resize hor split
map({"i","n","v","t"}, ldwin.."<Up>",    function() resize_win("hor", "-2")  end, {noremap=true})
map({"i","n","v","t"}, ldwin.."<Down>",  function() resize_win("",    "+2")  end, {noremap=true})
-- Resize vert split
map({"i","n","v","t"}, ldwin.."<Right>", function() resize_win("vert", "+4") end, {noremap=true})
map({"i","n","v","t"}, ldwin.."<Left>",  function() resize_win("vert", "-4") end, {noremap=true})

-- Detach win
map(modes, ldwin.."d", function()
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

-- fwin toggle hide
map({"i","n","v","t"}, ldwin.."c", win.fwin_hide_toggle)

-- fwin show all
map({"i","n","v","t"}, ldwin.."C", win.fwin_show_all)


-- Drawer
map({"i","n","v","t"}, "<F7>", drawer.toggle)


-- ### Nav
-- To next window (include splits)
map(modes, "<M-Tab>", "<Cmd>wincmd w<Cr>")

-- To window
map(modes, ldwin.."<C-Left>",  "<Cmd>wincmd h<CR>")
map(modes, ldwin.."<C-Right>", "<Cmd>wincmd l<CR>")
map(modes, ldwin.."<C-Up>",    "<Cmd>wincmd k<CR>")
map(modes, ldwin.."<C-Down>",  "<Cmd>wincmd j<CR>")



-- ## [Tabs]
----------------------------------------------------------------------
-- Create new tab
map(modes, "<C-t>", function()
    vim.cmd("Alpha")
end)

-- Tabs nav
-- next
-- map(modes, "<C-Tab>",   "<cmd>bnext<CR>")
map(modes, "<C-Tab>",   "<cmd>BufferNext<CR>")
-- Prev
-- map(modes, "<C-S-Tab>", "<cmd>bp<CR>")
map(modes, "<C-S-Tab>", "<cmd>BufferPrevious<CR>")



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
-- map("i",       "<Up>", "<cmd>norm! g<Up><CR>") -- use norm to avoid visual glitch
-- map({"n","v"}, "<Up>", "g<up>")

-- map("i",       "<Down>", "<cmd>norm! g<Down><CR>")
-- map({"n","v"}, "<Down>", "g<Down>")

--maybe?
-- vim.keymap.set('n', 'j', [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']], { expr = true })
-- vim.keymap.set('n', 'k', [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']], { expr = true })


-- ### [Scrolling]
map({"i","n","v","c","t"}, "<M-C-S-Right>", "<Cmd>silent! norm! 7zl<CR>")
map({"i","n","v","c","t"}, "<M-C-S-Left>",  "<Cmd>silent! norm! 7zh<CR>")
map({"i","n","v","c","t"}, "<M-C-S-Down>",  "<Cmd>silent! norm! 4<CR>")
map({"i","n","v","c","t"}, "<M-C-S-Up>",    "<Cmd>silent! norm! 4<CR>")



-- ### [Fast and furious cursor move]
-- Fast left/right move in normal mode
map({"n","v"}, "<C-Right>", "<Cmd>norm! 7l<CR>")
map({"n","v"}, "<C-Left>",  "<Cmd>norm! 7h<CR>")

-- ctrl+up/down to move fast
map("i",       "<C-Up>", "<esc>m'3ki")
map({"n","v"}, "<C-Up>", "m'3k")

map("i",       "<C-Down>", "<esc>m'3ji")
map({"n","v"}, "<C-Down>", "m'3j")


-- ### [Jump]
-- Jump to start/end of line
map({"i","n","v"}, "<M-Left>", "<cmd>norm! 0<cr>")
map("c",           "<M-Left>", "<C-b>", {noremap=true})
map("t",           "<M-Left>", "<C-a>", {noremap=true})

map("i",           "<M-Right>", "<C-o>A") -- notice the 'a'
map({"n","v"},     "<M-Right>", function()
    if vim.fn.getline(".") == "" then -- to eol even if empty
        vim.cmd("norm! 0"..vim.opt.textwidth:get().."l")
    else
        vim.cmd("norm! $")
    end
end)
map("c",           "<M-Right>", "<C-e>", {noremap=true})
map("t",           "<M-Right>", "<C-e>", {noremap=true})

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
map("i", '<C-Right>', function()
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
map("i", '<C-Left>', function()
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
-- Set nav mark
map({"i","n","v"}, "<S-M-m>", "<Cmd>norm! mJ<CR><Cmd>echo'Jump mark set'<CR>")
-- Jump to nav mark
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
map({"i","n","v"}, "<C-End>", "<Cmd>cd - | pwd<CR>")


-- Interactive cd
map({"i","n","v","c"}, "<M-End>", function()
    vim.api.nvim_feedkeys(":cd ", "n", false)
    vim.api.nvim_feedkeys("	", "c", false) --triggers comp menu
    vim.api.nvim_create_autocmd('DirChanged', {
        group = 'UserAutoCmds',
        command = "pwd",
    })
end)

-- cd shortcuts
-- cd curr file dir
map({"i","n","v"}, "<C-S-Home>", function()
    vim.cmd("cd "..vim.fn.expand("%:p:h").." | pwd")
end)

-- cd curr file proj root dir
map({"i","n","v"}, "<M-Home>", function()
    local rootdir = fs.utils.get_file_proj_rootdir(vim.api.nvim_buf_get_name(0))
    vim.cmd("cd "..rootdir.." | pwd")
end)

-- cd to home
map({"i","n","v"}, "<M-S-Home>", function() vim.cmd("cd | pwd") end)

-- cd to sys root dir
map({"i","n","v"}, "<M-C-S-Home>", function() vim.cmd("cd / | pwd") end)


-- Hyper act
map({"i","n","x"}, "<C-CR>", "<Cmd>HyperAct<CR>", {noremap=true})


-- Task planner
-- General task
map({"i","n","v","c","t"}, "<F4>", function()
    if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end

    if vim.fn.expand("%:t") == "plan.txt" then vim.cmd("bwipeout") return end

    vim.cmd("enew")
    vim.cmd("e /home/qm/Personal/Org/plan.txt")

    vim.opt_local.number = false

    vim.wo.foldlevel=0
    vim.opt_local.foldmethod="expr"
    vim.opt_local.foldexpr='v:lua.foldexpr_planv()'
end)

-- Project task <S-F4>
map({"i","n","v","c","t"}, "<F16>", function()
    if vim.fn.expand("%:t") == "todo.md" then vim.cmd("bwipeout") return end

    vim.cmd("e /home/qm/Personal/dotfiles/User/nvim/todo.md")
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
        vim.api.nvim_feedkeys([[/\V"]], "c", false)
        vim.api.nvim_feedkeys("\13", "c", false) -- enter auto start search
    end
end)

-- Search Help for selection
map("v", "<F1>", 'y:h <C-r>"<CR>')

-- map("v", "<M-f>n", '<Cmd>WebSearch<CR>')



-- ## [Selections]
----------------------------------------------------------------------
-- Selection anchors swap
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

-- Select last pasted text
map({"i","n","v"}, "<C-g>vp", "<Esc><Cmd>norm! `[v`]<CR>")
map("n", "gvp", "`[v`]")

-- Select to home/end
map({"i","n","v"}, "<S-Home>", "<esc>vgg0")
map({"i","n","v"}, "<S-End>",  "<Esc>vG$")

-- To Visual Line selection
-- TODO a bit hacky we would want proper <M-C-Right><M-C-Left>
map({"i","n","v"}, "<M-C-Right>", function()
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
    local vst, vsh = vim.fn.line("v"), vim.fn.line(".")

    if vim.fn.mode() ~= "V" then vim.cmd("norm! V") end

    if vsh > vst then vim.cmd("norm! ok")
    else              vim.cmd("norm! k")
    end
end)

map("i", "<S-PageDown>", "<Esc>Vj")
map("n", "<S-PageDown>", function()vim.cmd('norm!V'..vim.v.count..'j')end)
map("v", "<S-PageDown>", function()
    local vst, vsh = vim.fn.line("v"), vim.fn.line(".")

    if vim.fn.mode() ~= "V" then vim.cmd("norm! V") end

    if vsh > vst then vim.cmd("norm! j")
    else                  vim.cmd("norm! oj")
    end
end)

-- Shrink visual line selection up/down
map("v", "<C-S-PageUp>", function()
    return vim.fn.mode() == "V" and vim.cmd("norm! k") or vim.cmd("norm! Vk")
end)

map("v", "<C-S-PageDown>", function()
    return vim.fn.mode() == "V" and vim.cmd("norm! j") or vim.cmd("norm! Vj")
end)

-- ### Visual block selection
map({"n","v"}, "<S-M-v>", "<C-v>", {noremap=true})

-- Move to visual block selection regardless of mode
local function arrow_blockselect(dir)
    local m = vim.fn.mode()
    if     m == ""            then vim.cmd("norm! "..dir)
    elseif m == "v" or m == "V" then vim.cmd("norm! "..dir)
    else                             vim.cmd("stopinsert | norm! "..dir)
    end
end

map({"i","n","x"}, "<S-M-Left>",  function() arrow_blockselect("h") end)
map({"i","n","x"}, "<S-M-Right>", function() arrow_blockselect("l") end)
map({"i","n","x"}, "<S-M-Up>",    function() arrow_blockselect("k") end)
map({"i","n","x"}, "<S-M-Down>",  function() arrow_blockselect("j") end)



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


-- ### Abrev
-- map("ia", "", "")


-- ### Insert snippets
-- Insert var
map({"i","n"}, "<C-S-n>v",  function() lsnip.insert_snippet("var") end)
map({"i","n"}, "<C-S-n>vt", function() lsnip.insert_snippet("var table") end)

-- Insert func
map({"i","n"}, "<C-S-n>f",  function() lsnip.insert_snippet("func") end)
map({"i","n"}, "<C-S-n>fl", function() lsnip.insert_snippet("func loc") end)
map({"i","n"}, "<C-S-n>fa", function() lsnip.insert_snippet("func anon") end)

-- Insert if
map({"i","n"}, "<C-S-n>i",  function() lsnip.insert_snippet("if") end)

-- Insert loop
map({"i","n"}, "<C-S-n>fe", function() lsnip.insert_snippet("for each") end)

map({"i","n"}, "<C-S-n>r",  function() lsnip.insert_snippet("return") end)


map({"i","n"}, "<C-S-n>p",  function() lsnip.insert_snippet("print") end)


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

    if vim.fn.match(word, [[\k]]) ~= -1 then
        vim.fn.setreg("+", word)
        print("Word copied") return
    end

    vim.fn.setreg("+", char)
    print("Char copied")
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
map({"i","n"}, "<C-S-x>", '<Cmd>norm! mz0"+dd`z<CR>')

-- Smart cut
map({"i","n"}, "<C-x>", function()
    local char = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("."))[1]
    vim.cmd('norm! mz"zyiw`z'); local word = vim.fn.getreg("z")
    vim.cmd('norm! mz"zyi'..char..'`z'); local obj  = vim.fn.getreg("z")

    if char == " " or char == "" then return end

    if char:match("[(){}%[%]'\"`<>]") and obj ~= "" then
        vim.cmd('norm! mz"+di'..char..'`z')
        return print("Obj cut")
    end

    if vim.fn.match(word, [[\k]]) ~= -1 then
        vim.cmd('norm! mz"+diw`z')
        return print("Word cut")
    end

    vim.cmd('norm! "+dl')
    return print("Char cut")
end, {noremap=true})


-- #### [Paste]
map("i", "<C-v>", '<Esc>"+Pa')
map("v", "<C-v>", '"_d"+P')
map("c", "<C-v>", '<C-R>+')
map("t", "<C-v>", '<Esc> <C-\\><C-n>"+Pi') --TODO kinda weird

-- Smart paste
map("n", "<C-v>", function()
    local curso_pos = vim.fn.getpos(".")
    local char   = vim.fn.getregion(curso_pos, curso_pos)[1]
    -- local char_l = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]
    -- local char_r = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]
    vim.cmd('norm! mz"zyiw`z'); local word = vim.fn.getreg("z")

    -- local char_isolated = char_l == " " and char_r == " "
    if vim.fn.match(word, [[\k]]) ~= -1 then
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

-- Paste swap selected
-- TODO BUG buggy if swap from right to left
map("v", "<C-S-v>", function()
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
vim.keymap.set({"i","n"}, "<C-S-v>", function()
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
-- <M-S-BS> <C-BS> because of wezterm
map({"i","n"}, "<S-M-BS>", '<cmd>norm! "_db<CR>')
-- map({"i","n"}, "<S-M-BS>", function()
--     local line = vim.api.nvim_get_current_line()
--     local col  = vim.fn.col('.') - 1
--     local lchar = line:sub(col, col)

--     local col2  = vim.fn.col('.') - 2
--     local lchar2 = line:sub(col2, col2)

--     local curso_prvrow = vim.api.nvim_win_get_cursor(0)[1]

--     if col > 0 then -- less greedy algo
--         if lchar:match("%s") then
--             vim.cmd('norm! vgel"_d')
--         else
--             if lchar2:match("%s") or #line <= 1 then -- word is one char long
--                 vim.cmd('norm! "_dh')
--             else
--                 vim.cmd('norm! gevbgel"_d')
--             end
--         end
--     end

--     -- back to start line
--     if curso_prvrow > vim.api.nvim_win_get_cursor(0)[1] then vim.cmd("norm! j0") end
-- end)
map("c", "<S-M-BS>", '<C-w>')

-- Remove to start of line
map({"i","n","v"}, "<M-BS>", function()
    vim.cmd('norm! '..(vim.fn.mode() == "" and '0"_d' or '"_d0') )
end)
map("c", "<M-BS>", "<C-u>")

-- #### Clear
-- Clear char
map({"n","v"}, "<BS>", 'r ')

-- Clear from cursor to sol
--kmap({"i","n"}, "<M-BS>", "<cmd>norm! v0r <CR>"

-- Clear line
map({"i","n","v"}, "<S-BS>", function()
    vim.cmd('norm! '..(vim.fn.mode() == "V" and 'r ' or 'Vr ') )
end)

-- #### Delete
-- Del char
map("n", "<Del>", 'v"_d')
map("v", "<Del>", '"_di')

-- Delete right word
map("i",       "<C-Del>", '<C-o>"_dw')
map({"n","v"}, "<C-Del>", '"_dw')
-- TODO BUG with word with "."
map("c",       "<C-Del>", "<C-Right><C-w>")

-- Del to end of line
map({"i","n","v"}, "<M-Del>", function()
    vim.cmd('norm! '..(vim.fn.mode() == "" and '$"_d' or 'v$h"_d') )
end)
map("c", "<M-Del>", "<C-Right><C-w><C-Right><C-w><C-Right><C-w>") -- TODO very ugly

-- Delete line
map({"i","n","v"}, "<S-Del>", function()
    vim.cmd("norm! "..(vim.fn.mode() == "V" and '"_d' or 'V"_d') )
end)
map("c", "<S-Del>", "<C-Left><C-w>")

-- Del line, detect empty line without trashing reg
map("n", "dd", function()
    return vim.fn.getline(".") == "" and '"_dd' or '0d$"_dd' -- avoids yanking \n
end, {expr=true})

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
map("v", "<M-r>", "r")

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
map({"i","n","v"}, "<C-g>v", function() toggle_visualreplace() end)


-- ### Substitute mode
map("n", "s", "<Nop>")

map({"i","n"}, "<M-S-s>",
[[<Esc>:%s/\V//g<Left><Left><Left>]],
{desc = "Enter substitute mode"})

-- Substitute inside selection
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


-- TODO Smart swap word around
map("n", "<M-s>", function()
    vim.fn.search("\\k*\\<", "b")
    vim.cmd('norm! mz')
    vim.cmd('norm! "zdiw')
    local wordl = vim.fn.getreg("z")

    vim.fn.search("\\k*\\<", "")
    vim.cmd('norm! "zdiw')
    vim.cmd('norm! i'..wordl)

    vim.cmd('norm! `z')
    vim.cmd('norm! "zP')
end)


-- ### Incrementing
map({"n","v"}, "<C-g>+", "g")
map({"n","v"}, "<C-g>-", "g")

-- Smart increment/decrement
map("n", "+", '<Cmd>lua require("modules.cyclist").cycle_omni_atcursor()<CR>')
map("v", "+", '<Cmd>lua require("modules.cyclist").cycle_omni_selected()<CR>')

-- decrem
map("n", "-", '<Cmd>lua require("modules.cyclist").cycle_omni_atcursor(true)<CR>')
map("v", "-", '<Cmd>lua require("modules.cyclist").cycle_omni_selected(true)<CR>')

-- To upper/lower case
map("i", "<M-+>", "<cmd>norm! mzviwgU`z<CR>")
map("n", "<M-+>", "vgU<esc>")
map("v", "<M-+>", "gUgv")

map("i", "<M-->", "<cmd>norm! mzviwgu`z<CR>")
map("n", "<M-->", "vgu<esc>")
map("v", "<M-->", "gugv")


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


-- ### [Line break]
map("n", "<CR>", function()
    return vim.bo.buftype == "" and "i<CR><esc>" or "<CR>"
end, {expr=true})

-- Line break above
map({"i","n"}, "<S-CR>", function() vim.cmd('norm! '..vim.v.count..'O') end)
--TODO buggy
map("v",       "<S-CR>", "<esc>O<esc>gv")

-- Line break below
map({"i","n"}, "<M-CR>", function() vim.cmd('norm! '..vim.v.count..'o') end)
map("v",       "<M-CR>", "<esc>o<esc>gv")

-- Line break above and below
map({"i","n"}, "<S-M-cr>", "<cmd>norm!mzo<CR><cmd>norm!kO<CR><cmd>norm!`z<CR>")
-- map({"i","n"}, "<S-M-cr>", "<Cmd>norm! ]\<space><CR>")

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

    if mode:match("[vV\22]") then
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
map("n", "q",  '<nop>')

-- record
map({"i","n","v"}, "<C-!>r", '<esc>qq')
-- rec stop
map({"i","n","v"}, "<C-!>s", '<esc>q')
-- exec
map("n",           "<C-!>e", '@q')



-- ## [Text intel]
----------------------------------------------------------------------
-- ### [Word processing]
local ldwrd = "<M-s>"

-- Toggle spellcheck
map({"i","n","v","c","t"}, ldwrd.."s", function()
    vim.opt.spell = not vim.opt.spell:get()
    print("Spellchecking: " .. tostring(vim.opt.spell:get()))
end, { desc = "Toggle spell checking" })

-- Pick documents language
map({"i","n","v","c","t"}, ldwrd.."l", "<Cmd>PickCurrDocLang<CR>")

-- Suggest
map({"i","n","v"}, ldwrd.."c", "<Cmd>FzfLua spell_suggest<CR>")

-- Quick correct
map({"i","n","v"}, "<M-c>", "<Cmd>norm! m`1z=``<CR>")

-- Add word to dictionary
map({"i","n"}, ldwrd.."a", "<Esc>zg")
map("x",       ldwrd.."a", "zg")

-- Add word to selected dict
map({"i","n","x"}, ldwrd.."ad", function()
    local langs = vim.opt.spelllang:get()
    vim.ui.select(langs, { prompt = "Pick dict lang: " }, function(choice)
        if not choice then return end

        local langindex -- find id for choice string
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

        local spelf = vim.fn.readfile(vim.opt.spellfile:get()[langindex])
        if vim.tbl_contains(spelf, word) then
            vim.notify(word.." Already in dictionary") return
        end

        vim.cmd(tostring(langindex).."spellgood "..word)
        print("Word '"..word.."' added to dict "..choice)
    end)
end)


-- Remove from dictionary
map({"i","n"}, ldwrd.."r", "<Esc>zug")
map("x",       ldwrd.."r", "zug")

-- Show definition for word
map({"i","n","v"}, ldwrd.."d", function()
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

map({"i","n","v"}, "<F58>", "<Cmd>DiagnosticVirtualTextToggle<CR>")

-- To next diag
map({"i","n","v"}, "<M-C-S-PageUp>", function() vim.diagnostic.jump({count=-1}) end)
map({"i","n","v"}, "<M-C-S-PageDown>", function() vim.diagnostic.jump({count=1}) end)

-- Ref panel
map({"i","n","v"}, "<F11>", "<cmd>Trouble lsp_references toggle focus=true<cr>")
map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")

-- Goto definition
map("i", "<F12>", "<Esc>gdi")
map("n", "<F12>", "gd")
map("n", "<F24>", ":lua vim.lsp.buf.definition()<cr>")
map("n", "<F60>", ":lua vim.lsp.buf.implementation()<cr>")

-- Peak win open
map({"i","n"}, "<C-h>", function()
    local ogbufid  = vim.api.nvim_get_current_buf()
    local ogbufpah = vim.api.nvim_buf_get_name(0)
    local ogwinh   = vim.api.nvim_win_get_height(0)

    local params = vim.lsp.util.make_position_params(0, "utf-8")

    vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
        -- gather lsp data
        if err or not result or vim.tbl_isempty(result) then
            return vim.cmd([[echohl ErrorMsg | echom "Definition not found" | echohl None]])
        end

        local def   = result[1]
        local uri   = def.uri or def.targetUri
        local range = def.range or def.targetSelectionRange

        local filepath = vim.uri_to_fname(uri)
        local line = range.start.line

        vim.cmd("norm! zb") -- put og text at win bottom

        -- Create peakwin --
        vim.cmd("split"); vim.cmd("e "..filepath)
        vim.api.nvim_win_set_height(0, math.floor(ogwinh * 0.70 ))

        vim.w.wintype = "peakwin"

        if ogbufpah ~= vim.api.nvim_buf_get_name(0) then
            vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
            vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})
        end

        vim.api.nvim_win_set_cursor(0, {line + 1, range.start.character})

        -- scroll peak view
        vim.cmd("norm! zt")
        vim.cmd("norm! zt") -- It seem to work better if called twice..

        -- back to og win cursorpos
        vim.api.nvim_create_autocmd('WinEnter', {
            group = 'UserAutoCmds',
            once = true,
            buffer = ogbufid,
            command = "normal! zz",
        })
    end)
end)


-- Show hover window
map({"i","n"}, "<C-S-H>", function()
    vim.lsp.buf.hover()
    vim.lsp.buf.hover() -- weird but needed to enter hover win

    -- vim.wo[winid].wrap       = false
    -- vim.wo[winid].spell      = false
    -- vim.wo[winid].signcolumn = "no"
    -- vim.wo[winid].number     = false
    -- vim.wo[winid].foldcolumn = "0"
end)

-- Show signature
map({"i","n"}, "<M-h>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>")


-- Rename symbol
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
        vim.cmd("norm! zz")
        require('gitsigns').preview_hunk_inline()
    end
end)
map({"i","n","v","c"}, "<M-S-PageDown>", function()
    if vim.wo.diff then
        vim.cmd.normal({']cz.', bang = true})
    else
        require('gitsigns').nav_hunk('next')
        vim.cmd("norm! zz")
        require('gitsigns').preview_hunk_inline()
    end
end)


-- Diff put
map({"i","n"}, "<S-Space>dp", "<cmd>.diffput<cr>")
map("v",       "<S-Space>dp", ":diffput<cr>")

-- Diff get
map({"i","n"}, "<S-Space>dg", "<cmd>.diffget<cr>")
map("v",       "<S-Space>dg", ":diffget<cr>")



-- ## [git]
----------------------------------------------------------------------
local ldvc = "<S-Space>g"

-- Staging
map({"i","n","v"}, ldvc.."s", git.add_file)

-- Stage hunk under cursor
map({"i","n","v"}, ldvc.."ss", "<Cmd>Gitsigns stage_hunk<CR>")

-- Stage edit patch file
map({"i","n","v"}, ldvc.."se", function()
    local fp = vim.fn.expand("%:p")

    term.open_fwin(nil, {
        title = "Stage patches",
        wratio = 0.85, hratio = 0.75,
    }, "dash")

    vim.api.nvim_chan_send(vim.b.terminal_job_id, "git add -e "..fp.."\n")
end)

map({"i","n","v"}, ldvc.."sa", git.add_all_repo)

map({"i","n","v"}, ldvc.."u", git.unstage_file)
map({"i","n","v"}, ldvc.."uu", git.unstage_all_repo)

-- git commit
map({"i","n","v"}, ldvc.."c", function()
    term.open_fwin(nil, {
        title = "Commit",
        wratio = 0.85, hratio = 0.75,
    }, "bash --norc")

    vim.api.nvim_chan_send(vim.b.terminal_job_id, "git commit -v\n")
end)

-- Commit curr file
map({"i","n","v"}, ldvc.."cc", function()
    local fp   = vim.fn.expand("%:p")
    local fdir = vim.fn.expand("%:p:h")

    term.open_fwin(nil, {
        title = "Commit file",
        wratio = 0.85, hratio = 0.75,
    }, "bash --norc")

    vim.api.nvim_chan_send(vim.b.terminal_job_id, "cd "..fdir.."\n")
    vim.api.nvim_chan_send(vim.b.terminal_job_id, "git add "..fp.."\n")
    vim.api.nvim_chan_send(vim.b.terminal_job_id, "git commit -ov "..fp.."\n")
end)

-- git push
map({"i","n","v"}, ldvc.."<S-p>", function()
    term.open_fwin(nil, {
        title = "Push",
        wratio = 0.75, hratio = 0.65,
    })

    vim.api.nvim_chan_send(vim.b.terminal_job_id, "git push\n")
end)

-- diff with head curr file
map({"i","n","v"}, ldvc.."d", "<Cmd>GitDiffFileRevision<CR>")


map({"i","n","v"}, ldvc.."h", git.log_pretty)

-- git log curr file
map("n", ldvc.."hf", function()
     require("neogit").action("log", "log_current", { "--", vim.fn.expand("%:p") })()
end, {desc = "Neogit Log curr file"})


-- Open LazyGit
map(modes, ldvc.."z", "<Cmd>LazyGit<cr>")

-- neogit
map({"i","n","v"}, ldvc,  "<Cmd>Neogit<CR>")
map({"i","n","v"}, ldvc.."g", "<Cmd>Neogit<CR>")




-- ## [Task]
----------------------------------------------------------------------
-- Exec sel
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

-- run current file or buf (F56 is <M-F8>)
map({"i","n","v"}, "<F56>", function()
    local fpath = vim.fn.expand('%:p')

    if vim.fn.filereadable(fpath) == 1 then
        require('overseer').run_task({name = "run file"}, function(task)
            if task then
                require('overseer').open({ enter = false })
            end
        end)
    else
        require("overseer").run_task({name = "run buf"}, function(task)
            if task then
                require('overseer').open({ enter = false })
            end
        end)
    end
end)

-- run project
map({"i","n","v"}, "<F8>", function()
    require('overseer').run_task({name = "run project"}, function(task)
        if task then
            require('overseer').open({ enter = false })
        end
    end)
end)

map({"i","n","v"}, "<S-Space>tv", "<Cmd>OverseerToggle<Cr>", {nowait=true})
map({"i","n","v"}, "<S-Space>tr", function()
    require('overseer').run_task({}, function(task)
        if task then
            require('overseer').open({ enter = false })
        end
    end)
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

-- clear all text
map("c", "<S-BS>", '<C-u>')

-- Close cmd
map("c", "<esc>", "<C-c>", {noremap=true})
map("c", "œ", "<C-c><C-l>")  --needs <C-c> and not <Esc> because Neovim behaves as if <Esc> was mapped to <CR> in cmd

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
        vim.cmd("startinsert")
        vim.keymap.set("n", "<M-`>", ':quit<CR>' , {buffer=true})
    end,
})


-- Open command line in term mode
map({"i","c"}, "<S-Œ>", "<esc>:!")
map({"n","v"}, "<S-Œ>", ":!")


-- cmd messages <S-F10>
map({"i","n","v","c","t"}, "<F22>", "<Esc><Cmd>ToggleMsgLog<CR>")



-- ## [Terminal]
----------------------------------------------------------------------
-- Open term tab
map({"i","n","v","t"}, "<M-t>t", "<cmd>term<CR>", {noremap=true})

-- Term toggle vert
map({"i","n","v","t"}, "<M-t>s", term.toggle_vert)

-- Term toggle hor
map({"i","n","v","t"}, "<M-t>h", term.toggle_hor)
map({"i","n","v","t"}, "<F6>",   term.toggle_hor)

-- Float term
map({"i","n","v","t"}, "<M-t>",  term.open_fwin)
map({"i","n","v","t"}, "<M-t>f", term.open_fwin)
map({"i","n","v","t"}, "<F18>",  term.open_fwin)

-- Exit term mode
map("t", "<M-Esc>", [[<Esc> <C-\><C-n>]], {noremap=true})





