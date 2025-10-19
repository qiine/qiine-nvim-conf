
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

    ["public"] = "private", ["private"] = "public",

    ["=="] = "!=", ["!="] = "==",
    ["-"]  = "+", ["+"]  = "-",
    -- ["/"]  = [[\]], ["\\"]  = "/",
}

M.quotes = {
    "'",
    '"',
    '`',
}

M.quote_increm = {
    ["'"] = '"',
    ['"'] = "`",
}

M.quote_decrem = {
    ["`"] = '"',
    ['"'] = "'",
}

M.parens = {
    "(",
    "{",
    "[",
    ")",
    "}",
    "]",
}

M.paren_increm = {
    ["("] = '{',
    ['{'] = "[",
}

M.paren_decrem = {
    ["["] = '{',
    ['{'] = "(",
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
function M.get_next_quote(text) return M.quote_increm[text] end

---@param text string
---@return string
function M.get_prev_quote(text) return M.quote_decrem[text] end

---@param text string
---@return string
function M.get_next_paren(text) return M.paren_increm[text] end

---@param text string
---@return string
function M.get_prev_paren(text) return M.paren_decrem[text] end

---@param num number
---@return number
function M.get_next_num(num) return num + 1 end

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
---@return boolean
function M.is_paren(text) return vim.tbl_contains(M.parens, text) end


---@param text string
---@param reverse boolean
---@return boolean
function M.dial_omni_text(text, reverse)
    local res

    if M.is_quote(text) then
        res = reverse and M.get_prev_quote(text) or M.get_next_quote(text)
    end

    if M.is_paren(text) then
        res = reverse and M.get_prev_paren(text) or M.get_next_paren(text)
    end

    if M.is_toggleable(text) then
        res = M.get_toggle(text)
    end

    if not res then return false end

    vim.cmd('norm! "_c'..res); return true
end

---@param reverse boolean
function M.dial_omni_num(reverse)
    vim.cmd('norm! '..(reverse and '' or ''))
end

function M.dial_omni_selected(reverse)
    local text = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('v'))[1]

    local num = tonumber(text)
    if num then
        M.dial_omni_num(reverse)
    else
        M.dial_omni_text(text, reverse)
    end

    vim.cmd("norm! gv")
end


function M.dial_omni_atcursor(reverse)
    local text

    vim.cmd("norm! mz")

    local char = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]
    vim.cmd('norm! "zyiw`z'); local word = vim.fn.getreg("z")
    vim.cmd('norm! "zyiW`z'); local WORD = vim.fn.getreg("z")

    if char:match("[(){}%[%]'\"`<>+-]") then
        text = char; vim.cmd("norm! v")
    -- elseif WORD:match("") then
        -- text = WORD; vim.cmd("norm! viW")
    else
        text = word; vim.cmd("norm! viw")
    end

    local num = tonumber(text)
    if num then
        M.dial_omni_num(reverse)
    else
        M.dial_omni_text(text, reverse)
    end

    vim.cmd("norm! `z")
end



--------
return M
