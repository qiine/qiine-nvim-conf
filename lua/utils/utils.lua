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
---@param cpos number[] 
function M.get_char_at_pos(cpos)
    local line = vim.fn.getline(cpos[1])
    local char = line:sub(cpos[2], cpos[2])
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
function M.trim_whitespaces(s)
    return string.gsub(s, "%s+", "")
end

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

-- Trim leading/trailing whitespace when yanking
function M.TrimWhitespaceOnYank()
    local start_line, start_col = unpack(vim.api.nvim_buf_get_mark(0, '"'))
    local end_line, end_col = unpack(vim.api.nvim_buf_get_mark(0, "'"))
    
    -- Get the yanked text range
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    
    for i, line in ipairs(lines) do
        lines[i] = line:match("^%s*(.-)%s*$")
    end

    --Put the trimmed lines into the unnamed register
    vim.fn.setreg('"', lines)
end


--[cursor]--------------------------------------------------
function M.get_cursor_pos()
    --return {row, col}, but column is zero-based and row is 1-based!
    return vim.api.nvim_win_get_cursor(0)
end

function M.is_cursor_inside_word()
    local word_under_cursor = vim.fn.expand('<cword>')
    return word_under_cursor ~= ''
end

function M.is_cursor_at_wordend()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()

    col = col + 1   -- Advance col by 1 since Neovim's col is 0-based in Lua

    -- Check if current char is a word character and next is not
    if line:sub(col, col):match("%w") and not line:sub(col + 1, col + 1):match("%w") then
        return true
    end
end

function M.is_cursor_at_wordstart()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()

    -- Lua strings are 1-based
    local cursor_col = col + 1

    -- Current char
    local curr = line:sub(cursor_col, cursor_col)
    -- Previous char (empty string if at start of line)
    local prev = cursor_col > 1 and line:sub(cursor_col - 1, cursor_col - 1) or ""

    -- Check if cursor is on a word character and the previous is not
    if curr:match("%w") and (prev == "" or not prev:match("%w")) then
        return true
    end

    -- Special check for <Tab> or spaces between words
    if prev:match("%s") or prev == "" then
        -- Handle edge cases like space or tab before the word
        return true
    end

    return false
end

--function M.is_cursor_inside_word()
--    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
--    local line = vim.api.nvim_get_current_line()
--    if col == 0 or col > #line then
--        return false
--    end
--    local char = line:sub(col, col)
--    return char:match("%w") ~= nil
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
