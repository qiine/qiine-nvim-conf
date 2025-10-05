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
    ".", ",", ";", ":", "!", "?", "'", "\"",
    "-", "_", "|",
    "^", "`",
    "(", ")", "[", "]", "{", "}",
}

M.numbers = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" }

M.math = {
    "-", "<", ">",
    "%", "+", "*", "/", "=", "~",
}



--[strings]--------------------------------------------------
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

--Get selected text
-- -@return table
function M.get_slectedtext()
    local mode = vim.fn.mode()
    --if mode ~= 'v' and mode ~= 'V' and mode ~= '\22' then
    --    return ""
    --end

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>gv', true, false, true), "n", false)
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local lines = vim.fn.getline(start_pos[2], end_pos[2])

    -- Adjust start and end columns
    local start_col = start_pos[3]
    local end_col = end_pos[3]

    --if #lines == 0 then return {""} end

    -- Trim the first and last lines to selection
    --lines[1] = lines[1]:sub(start_col, #lines[1])
    --if #lines > 1 then
    --    lines[#lines] = lines[#lines]:sub(1, end_col)
    --end

    --return table.concat(lines, "\n")
    return lines
end



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



--[Editing]--------------------------------------------------
function M.bool_toggle(bword)
    local toggle_map = {
        ["true"] = "false", ["false"] = "true",
        ["yes"] = "no", ["no"] = "yes",
        ["on"] = "off", ["off"] = "on",
        ["activate"] = "deactivate", ["deactivate"] = "activate",
        ["enable"] = "disable", ["disable"] = "enable",
        ["always"] = "never", ["never"] = "always",
        ["ascending"] = "descending", ["descending"] = "ascending",
    }

    --Store case

    local bwtoggle = toggle_map[string.lower(bword)]

    --apply case back

    if bwtoggle then
        vim.cmd("normal! ciw" .. bwtoggle) vim.cmd("normal! b")
    end
end

function M.lessergreater_toggle(lessgreat)
    if lessgreat == ">" then vim.cmd("normal! r<")
    elseif lessgreat == "<" then vim.cmd("normal! r>")
    end
end

function M.smartincrement()
    local word = vim.fn.expand("<cword>")
    local num = tonumber(word) --also check if word is a number in a string

    if num then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-A>", true, false, true), "n", false)
        return
    end

    --increment letter so a becomes b (roman alphabet)
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
    local num = tonumber(word) --also check if word is a number in a string

    if num then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-X>", true, false, true), "n", false)
        return
    end

    --decrement letter so b becomes a (roman alphabet)
    if #word == 1 and word:match("%a") then
        local next_char = string.char(word:byte() - 1)
        vim.cmd("normal! r"..next_char)
        return
    end

    M.bool_toggle(word)

    M.lessergreater_toggle(word)
end



--[cursor]--------------------------------------------------
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



--## [Keys]
----------------------------------------------------------------------
function M.send_keystroke(key, mode, immediate)
    if immediate == nil then immediate = true end   --default val

    local termkey = vim.api.nvim_replace_termcodes(key, true, true, true)
    local keystroke = vim.api.nvim_feedkeys(termkey, mode, immediate)

    return keystroke
end



--## [Files]
----------------------------------------------------------------------
function M.make_relative_path_to_root(root_path, path)
    local root = vim.fs.normalize(root_path)
    local abs_path = vim.fs.normalize(path)
    return abs_path:sub(#root + 2)  -- +2 to remove root + "/" or "\"
end

function M.create_file(name, path, opts)

end



--------
return M
