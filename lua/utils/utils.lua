-------------------------
-- utils --
-------------------------

local v    = vim
local vapi = vim.api
local vcmd = vim.cmd
local vmap = vim.keymap.set
-----------------------------

local M = {}

function M.is_tty()
    return vim.fn.has("unix") == 1 and vim.fn.getenv("DISPLAY") == nil and vim.fn.getenv("WAYLAND_DISPLAY") == nil
end
--if is_tty() then
--    print("Running in TTY")
--else
--    print("Not in TTY")
--end

--Search selected in v mode
function M.SearchSelected()
    -- Get the selected text
    local selected_text = vim.fn.getreg('"')
    print("hello")
    -- Search for the selected text
    if selected_text ~= "" then
        vim.cmd("normal! /" .. selected_text)
    else
        print("No text selected")
    end
end



--[Characters]--------------------------------------------------
---@return string
---@param pos number[]
function M.get_char_at_pos(pos)
    local line = vim.fn.getline(pos[1])
    local char = line:sub(pos[2], pos[2])
    return char
end

function M.get_char_at_cursorpos()
    local cpos = M.get_cursor_pos()
    local char = M.get_char_at_pos({cpos[1], cpos[2]+1})
    return char
end

---@return boolean
function M.string_contains(str, substr)
    return string.find(str, substr) ~= nil
end

M.alphabet_lowercase = {
    "b", "b", "c", "d", "e", "f", "g",
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

M.numbers = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" }

M.punctuation = {
    ".", ",", ";", ":", "!", "?", "'", "\"",
    "-", "_", "(", ")", "[", "]", "{", "}",
    "<", ">", "/", "|", "@", "#", "$",
    "%", "^", "&", "*", "+", "=", "~", "`"
}



--[strings]--------------------------------------------------
function M.isword(string)
    return string:match("%S") ~= nil
end

function M.trim_whitespaces(s)
    return string.gsub(s, "%s+", "")
end

--TODO fancy make table from string func
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


--[Tables]--------------------------------------------------
function M.tables_append(ta, tb)
    local res = {}
    for _, t in ipairs(ta) do table.insert(res, t) end
    for _, t in ipairs(tb) do table.insert(res, t) end
    return res
end

function M.table_flatten(t)
    local result = {}

    for _, subtable in ipairs(t) do
        -- Append each nested table's contents into the result
        for _, value in ipairs(subtable) do
            table.insert(result, value)
        end
    end

    return result
end



--[Editing]--------------------------------------------------
function M.bool_toggle(bword)
    local toggle_map = {
        ["true"] = "false", ["false"] = "true",
        ["yes"] = "no", ["no"] = "yes",
        ["on"] = "off", ["off"] = "on",
        ["activate"] = "deactivate", ["deactivate"] = "activate",
        ["enable"] = "disable", ["disable"] = "enable",
    }

    local wtoggle = toggle_map[string.lower(bword)]
    if wtoggle then
        vim.cmd("normal! ciw" .. wtoggle) vim.cmd("normal! b")
    end
end

function M.lessergreater_toggle(lessgreat)
    if lessgreat == ">" then vim.cmd("normal! r<")
    elseif lessgreat == "<" then vim.cmd("normal! r>")
    end
end

function M.smartincrement()
    local word = vim.fn.expand("<cword>")
    local num = tonumber(word)

    if num then
        local num_increm = num + 1
        local incremented_word = tostring(num_increm)

        vim.cmd("normal! ciw" .. incremented_word)
        return
    end

    if #word == 1 and word:match("%a") then
        local next_char = string.char(word:byte() + 1)
        vim.cmd("normal! r"..next_char)
        return
    end

    M.bool_toggle(word)

    M.lessergreater_toggle(word)
end

function M.smartdecrement()
    local word = vim.fn.expand("<cword>")
    local num = tonumber(word)

    if num then
        local num_decrem = num - 1
        local decremented_word = tostring(num_decrem)

        vim.cmd("normal! ciw" .. decremented_word)
        return
    end

    if #word == 1 and word:match("%a") then
        local next_char = string.char(word:byte() - 1)
        vim.cmd("normal! r"..next_char)
        return
    end

    M.bool_toggle(word)
end



--[cursor]--------------------------------------------------
function M.get_cursor_pos()
    --return {row, col}, but column is zero-based and row is 1-based!
    return vim.api.nvim_win_get_cursor(0)
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



--[Keys]--------------------------------------------------
function M.send_keystroke(key, mode, immediate)
    if immediate == nil then immediate = true end   --default val

    local termkey = vapi.nvim_replace_termcodes(key, true, true, true)
    local keystroke = vapi.nvim_feedkeys(termkey, mode, immediate)

    return keystroke
end



--------
return M
