-------------------------
-- utils --
-------------------------

local v    = vim
local vapi = vim.api
local vmap = vim.keymap.set
-----------------------------

local M = {}

function M.is_tty()
    local b = vim.fn.has("unix") == 1 and vim.fn.getenv("DISPLAY") == nil and vim.fn.getenv("WAYLAND_DISPLAY") == nil
    return b
end
--if is_tty() then
--    print("Running in TTY")
--else
--    print("Not in TTY")
--end



--[Characters]--------------------------------------------------
---@return string
---@param pos number[]
function M.get_char_at_pos(pos)
    local line = vim.fn.getline(pos[1])
    local char = line:sub(pos[2], pos[2])
    return char
end

---@return string
function M.get_char_at_cursorpos()
    local cpos = M.get_cursor_pos()
    local char = M.get_char_at_pos(cpos)
    return char
end

M.alphabet_lowercase = {
    "a", "b", "c", "d", "e", "f", "g",
    "h", "i", "j", "k", "l", "m", "n",
    "o", "p", "q", "r", "s", "t", "u",
    "v", "w", "x", "y", "z"
}

M.alphabet_uppercase = {
    "A", "B", "C", "D", "E", "F", "G",
    "H", "I", "J", "K", "L", "M", "N",
    "O", "P", "Q", "R", "S", "T", "U",
    "V", "W", "X", "Y", "Z"
}

M.punctuation = {
    ".", ",", ";", ":", "!", "?",
    "-", "_", "|", "/",
    "^", "`", "'", "\"",
    "(", ")", "[", "]", "{", "}",
}

M.numbers = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" }

M.math = {
    "-", "<", ">",
    "%", "+", "*", "/", "=", "~",
}



-- ## [Strings]
----------------------------------------------------------------------
function M.isword(string)
    return string:match("%S") ~= nil
end

function M.trim_whitespaces(s)
    return string.gsub(s, "%s+", "")
end



--TODO fancy make spreadshit from string func
--local function format_to_table(str, delimiter, row, col)
--    local entries = vim.split(str, delimiter)
--    local out = {}
--    local line = ""
--
--    for i, v in ipairs(entries) do
--        line = line .. v .. " "  -- You can add a custom separator here
--        if i % per_row == 0 then
--            table.insert(out, line)
--            line = ""
--        end
--    end
--
--    -- If there's any remaining items in the last line, add them
--    if line ~= "" then table.insert(out, line) end
--
--    return table.concat(out, "\n")
--end
--,a = 2, b = 3, c = 10,



-- ## [Tables]
----------------------------------------------------------------------
function M.tables_append(ta, tb)
    local res = {}
    for _, t in ipairs(ta) do table.insert(res, t) end
    for _, t in ipairs(tb) do table.insert(res, t) end
    return res
end

-- Insert unique value
---@table
function M.insert_unique(t, val)
    for _, v in ipairs(t) do
        if v == val then return end
    end
    table.insert(t, val)
end






-- ## [cursor]
----------------------------------------------------------------------
function M.get_cursor_pos()
    local cpos = vim.api.nvim_win_get_cursor(0)
    --row is 1-based, col is 0-based, so we increment col to make both 1-based
    return { cpos[1], cpos[2] + 1 }
    --return cpos
end

function M.is_cursor_inside_word()
    local char = M.get_char_at_cursorpos()
    return M.isword(char)
end

--local function M.selection_anchor_side()
--    local anchor = vim.fn.getpos("v")
--    local cur = vim.fn.getcurpos()
--
--    if anchor[2] < cur[2] then
--        return true  -- anchor is on an earlier line
--    elseif anchor[2] == cur[2] and anchor[3] < cur[3] then
--        return true  -- same line, anchor is to the left
--    else
--        return false -- anchor is after or same as cursor
--    end
--end



-- ## [Keys]
----------------------------------------------------------------------
function M.send_keystroke(key, mode, immediate)
    if immediate == nil then immediate = true end   --default val

    local termkey = vim.api.nvim_replace_termcodes(key, true, true, true)
    local keystroke = vim.api.nvim_feedkeys(termkey, mode, immediate)

    return keystroke
end


-- ## [Filesystem]
----------------------------------------------------------------------
---@return boolean|nil
function M.is_bin(path)
    if vim.fn.filereadable(path) ~= 1 then
        return nil
    end

    local res = vim.system(
        { "file", "-b", "--mime", path },
        { text = true }
    ):wait()

    if res.code ~= 0 or not res.stdout then return nil end
    local restrim = vim.fn.trim(res.stdout)

    return restrim:find("charset=binary") ~= nil
end





--------
return M
