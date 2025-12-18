
-- windows --

local M = {}

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

---@param buf number?
---@param enter boolean?
---@param opts table?
---@return number
function M.fwin_open(buf, enter, opts)
    buf   = buf and buf or 0
    enter = enter and enter or true
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



--------
return M

