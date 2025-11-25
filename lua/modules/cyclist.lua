
-- flick
-- dial
-- cyclist
-- togger

-- TODO put this in a feature branch

local M = {}

-- cycle tables
M.toggle_table = {
    -- truth
    ["yes"]  = "no",    ["no"]    = "yes",
    ["true"] = "false", ["false"] = "true",

    -- action
    ["on"]       = "off",        ["off"]        = "on",
    ["activate"] = "deactivate", ["deactivate"] = "activate",
    ["enable"]   = "disable",    ["disable"]    = "enable",
    ["enabled"]  = "disabled",   ["disabled"]   = "enabled",

    ["always"] = "never", ["never"] = "always",
    ["all"] = "none", ["none"] = "all",

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
    "'", '"', '`',
}
M.quote_increm = {
    ["'"] = '"', ['"'] = "`",
}
M.quote_decrem = {
    ["`"] = '"', ['"'] = "'",
}

M.parens = {
    "(", "{", "[", ")", "}", "]",
}
M.paren_increm = {
    ["("] = '{', ['{'] = "[",
}
M.paren_decrem = {
    ["["] = '{', ['{'] = "(",
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

M.checkbox_states = {
    ["[x]"] = "[ ]",
    ["[ ]"] = "[x]",
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

---@param text string
---@return string
function M.get_checkbox_state(text) return M.checkbox_states[text] end

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

function M.is_checkbox(text) return vim.tbl_contains(M.checkbox_states, text) end

---@return boolean
function M.is_cursor_on_checkbox()
    local line = vim.api.nvim_get_current_line()

    local col  = vim.fn.col('.')
    local lcol = vim.fn.col('.') - 1
    local rcol = vim.fn.col('.') + 1

    local char = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]
    local lchar = line:sub(lcol, lcol)
    local rchar = line:sub(rcol, rcol)

    return char:match("[x%s]") and lchar == "[" and rchar == "]"
end


---@param text string
---@param reverse boolean
---@return boolean
function M.cycle_omni_text(text, reverse)
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

    if M.is_checkbox(text) then
        res = M.get_checkbox_state(text)
    end

    if not res then return false end
    print(text) -- [ ]
    vim.cmd('norm! "_c'..res); return true
end

---@param reverse boolean
function M.cycle_omni_num(reverse)
    vim.cmd('norm! '..(reverse and '' or ''))
end

function M.cycle_omni_selected(reverse)
    local text = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('v'))[1]

    local num = tonumber(text)
    if num then
        M.cycle_omni_num(reverse)
    else
        M.cycle_omni_text(text, reverse)
    end

    vim.cmd("norm! gv")
end


function M.cycle_omni_atcursor(reverse)
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

    if M.is_cursor_on_checkbox() then
        vim.cmd('norm! mz')
        vim.cmd('norm! hv2l"zy') -- TODO BUG fail for [ ] but not [x]
        text = vim.fn.getreg("z")
        vim.cmd('norm! `z')
        vim.cmd('norm! hv2l')
    end

    local num = tonumber(text)
    if num then
        M.cycle_omni_num(reverse) -- TODO increm purely in lua
    else
        M.cycle_omni_text(text, reverse)
    end

    vim.cmd("norm! `z")
end



--------
return M
