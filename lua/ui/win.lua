
-- windows --

local M = {}

-- split

---@param direction string
function M.open_split_ephem(direction)
    local cmd = {
        hor  = "split",
        vert = "vsplit",
    }
    vim.cmd(cmd[direction])

    local winid = vim.api.nvim_get_current_win()

    -- mark any buffer opened in this wind unlisted, wipe
    vim.api.nvim_create_autocmd("BufWinEnter", {
        group    = "UserAutoCmds",
        callback = function(args)
            if vim.api.nvim_get_current_win() == winid then
                vim.bo[args.buf].buflisted = false
                vim.bo[args.buf].bufhidden = "wipe"
            end
        end,
    })
end

function M.split_maximize_toggle()
    local tab_width  = vim.o.columns
    local tab_height = vim.o.lines - vim.o.cmdheight

    local wwidth  = vim.api.nvim_win_get_width(0)
    local wheight = vim.api.nvim_win_get_height(0)

    if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end

    local isfocused = wwidth >= tab_width * 0.8 and wheight >= tab_height * 0.8
    if isfocused then
        vim.cmd("wincmd =") -- equalize all win size
    else
        vim.cmd("wincmd |") -- try Maximise
        vim.cmd("wincmd _")
    end
end


-- float win

---@param buf number?
---@param enter boolean?
---@param opts table?
---@return number
function M.fwin_open(buf, enter, opts)
    buf   = buf and buf or 0
    enter = enter ~= nil and enter or true
    opts  = opts or {}

    local edw = { w = vim.o.columns, h = vim.o.lines }

    local wsize = { -- relative size
        w = math.floor(edw.w * (opts.wratio and opts.wratio or 0.85) ),
        h = math.floor(edw.h * (opts.hratio and opts.hratio or 0.8) ),
    }

    local wopts = {
        title     = opts.title and opts.title or vim.fn.expand("%:t"),
        title_pos = opts.title_pos and opts.title_pos or "center",

        relative  = opts.relative and opts.relative or "editor",
        anchor    = opts.anchor and opts.anchor or "NW",
        width     = wsize.w,
        height    = wsize.h,
        col       = math.floor((edw.w - wsize.w) / 2),
        row       = math.floor((edw.h - wsize.h) / 2) - 1,

        border    = opts.border and opts.border or "single",
    }

    -- if opts then
    --     wopts = vim.tbl_deep_extend("force", wopts, opts)
    -- end

    local fwin = vim.api.nvim_open_win(buf, enter, wopts)

    vim.api.nvim_set_option_value("winblend", 0, {win=fwin})

    return fwin
end

---@param fwin number
function M.fwin_hide_toggle(fwin)
    fwin = fwin or 0
    if vim.api.nvim_win_get_config(fwin).hide then
        vim.api.nvim_win_set_config(fwin, {hide=false})
    else
        vim.api.nvim_win_set_config(fwin, {hide=true})
    end
end

function M.fwin_show_all()
    local tabfwins = vim.tbl_filter(
        function(input)
            return vim.api.nvim_win_get_config(input).relative ~= ""
        end,
        vim.api.nvim_tabpage_list_wins(0)
    )

    for _, fwin in ipairs(tabfwins) do
        vim.api.nvim_win_set_config(fwin, {hide=false})
        -- vim.api.nvim_set_current_win(fwin) -- does nto ficus the correc win
    end
end



--------
return M

