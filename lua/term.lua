
-- terminal --

local win = require("ui.win")
-- local drawer = require("ui.drawer")

local U = {}
local M = {}

--## quickterm
M.quickterm_bufid = nil

---@return number
function M.quickterm_create()
    if M.quickterm_bufid and vim.api.nvim_buf_is_valid(M.quickterm_bufid) then
        vim.api.nvim_set_current_buf(M.quickterm_bufid)
        vim.cmd("startinsert")
    else -- create it
        vim.cmd("term")
        M.quickterm_bufid = vim.api.nvim_get_current_buf()
        vim.bo[M.quickterm_bufid].buflisted = false
    end

    return M.quickterm_bufid
end

function M.open()
    vim.cmd("term")
end

-- maybe quickterm ?
-- function M.toggle_hor()
--     vim.cmd("term")
-- end

function M.toggle_vert()
    if vim.bo.buftype == "terminal" then return vim.cmd("bd!") end

    vim.cmd("vsp | term")

    vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
    vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})
end

---@param enter boolean?
---@param wopts table?
---@param shell string?
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
