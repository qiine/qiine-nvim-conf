
-- terminal --

local win = require("ui.win")
local drawer = require("ui.drawer")

local M = {}
local U = {}

function M.toggle_hor()
    drawer.toggle(true, {buftype="term"})
end

function M.toggle_vert()
    if vim.bo.buftype == "terminal" then return vim.cmd("bd!") end

    vim.cmd("vsp | term")

    vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
    vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})
end

---@param enter boolean?
---@param wopts table?
---@return number
function M.open_fwin(enter, wopts, shell)
    enter = enter and enter or true
    wopts = wopts or {title="Terminal"}
    shell = shell and shell or "bash"

    local buf = vim.api.nvim_create_buf(false, false)

    local winid = win.fwin_open(buf, enter, wopts)

    vim.cmd("term "..shell)
    vim.api.nvim_set_option_value("buflisted", false,  {buf=buf})
    vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=buf})

    vim.cmd("startinsert")

    return winid
end

--------
M.utils = U
return M
