
-- flick
-- dial
-- togger


local M = {}

-- dial tables
M.toggle_table = {
    ["yes"]  = "no",    ["no"]    = "yes",
    ["true"] = "false", ["false"] = "true",

    ["on"]   = "off",   ["off"] = "on",
    ["activate"] = "deactivate", ["deactivate"] = "activate",
    ["enable"] = "disable", ["disable"] = "enable",
    ["enabled"] = "disabled", ["disabled"] = "enabled",

    ["always"] = "never", ["never"] = "always",

    -- direction
    ["left"] = "right", ["right"] = "left",
    ["up"] = "down", ["down"] = "up",
    ["ascending"] = "descending", ["descending"] = "ascending",
    [">"] = "<", ["<"] = ">",

    ["add"] = "subtract", ["subtract"] = "add",

    ["=="] = "!=", ["!="] = "==",
    ["-"]  = "+", ["+"]  = "-",
    -- ["/"]  = [[\]], ["\\"]  = "/",
}

M.quotes = {
    "'",
    '"',
    '`',
}

M.quote_increments = {
    ["'"] = '"',
    ['"'] = "`",
}

M.quote_decrements = {
    ["`"] = '"',
    ['"'] = "'",
}

M.paren_cycle = {
    ["("] = '{',
    ['{'] = "[",
}

M.day_cycle = {
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday",
}

---@param text string
---@return string
function M.get_toggle(text) return M.toggle_table[text] end

---@param text string
---@return string
function M.get_next_quote(text) return M.quote_increments[text] end

---@param text string
---@return string
function M.get_prev_quote(text) return M.quote_decrements[text] end

---@param text string
---@return string
function M.get_next_paren(text) return M.paren_cycle[text] end

---@param num number
---@return number
function M.get_next_num(num)
    return num + 1
end

---@param day string
---@return string
function M.get_next_day(day)
    for i, d in ipairs(M.day_cycle) do
        if d == day then
            return M.day_cycle[i % #M.day_cycle + 1]
        end
    end
    error("Invalid day: " .. tostring(day))
end

---@param text string
---@return boolean
function M.is_toggleable(text) return vim.tbl_contains(M.toggle_table, text) end

---@param text string
---@return boolean
function M.is_quote(text) return vim.tbl_contains(M.quotes, text) end

---@param text string
---@param reverse boolean
function M.dial_omni(text, reverse)
    local replacement

    local num = tonumber(text)
    if num then return vim.cmd('norm! '..(reverse and '' or '')) end

    if M.is_quote(text) then
        replacement = reverse and M.get_prev_quote(text) or M.get_next_quote(text)
    end

    if M.is_toggleable(text) then
        replacement = M.get_toggle(text)
    end

    if replacement then
        vim.cmd('norm! "_c'..replacement)
    end
end

function M.dial_omni_selected(reverse)
    local text = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('v'))[1]

    M.dial_omni(text, reverse)
    vim.cmd("norm! gv")
end


function M.dial_omni_atcursor(reverse)
    local text

    vim.cmd("norm! mz")

    local char = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]
    vim.cmd('norm! viw"zygv') local word = vim.fn.getreg("z")

    if char:match("[(){}%[%]'\"`<>+-]") then
        text = char
        vim.cmd("norm! `zv")
    else
        text = word
    end

    M.dial_omni(text, reverse)
    vim.cmd("norm! `z")
end




--------
return M
