
local M = {}

function M.surround_selection()
    local _, ls, cs = unpack(vim.fn.getpos('v'))
    local _, le, ce = unpack(vim.fn.getpos('.'))
    -- return vim.api.nvim_buf_get_text(0, ls-1, cs-1, le-1, ce, {})

    local char = vim.fn.getcharstr()
    --if char == "" then return end

    -- Get visual selection range
    --local _, start_line, start_col, _ = unpack(vim.fn.getpos("'<"))
    --local _, end_line, end_col, _ = unpack(vim.fn.getpos("'>"))

    -- Get the lines in the selection
    --local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

    print(char)
    -- Handle only single-line selection for now
    --if #lines == 1 then
    --    local line = lines[1]

    --    -- Build the new line with the char surrounding the selected text
    --    local new_line = line:sub(1, start_col - 1) ..
    --                     char ..
    --                     line:sub(start_col, end_col) ..
    --                     char ..
    --                     line:sub(end_col + 1)

    --    -- Replace the original line with the modified one
    --    vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, { new_line })
    --end
end

function M.enveloppe_word_doublequote()
    local word = vim.fn.expand("<cword>")
    word = '"'..word..'"'

    vim.cmd('normal! ciw'..word)
    vim.cmd('normal! bb')
end

--function M.enveloppe_word_singlequote()
--    local selectstring = vim.fn.expand("'<,'>")
--    word = "'"..word.."'"
--    print(word)
--    --vim.cmd('normal! "_diw'..word)
--    --vim.cmd('normal! bb')
--end


function M.setup(opts)
    opts = opts or {}

    vim.keymap.set("n", '"', M.enveloppe_word_doublequote, { desc = "enveloppe word doublequote" })
    --vim.keymap.set("v", "<C-'>", M.enveloppe_word_singlequote, { desc = "enveloppe word doublequote" })

    vim.keymap.set("n", '<C-e>', M.surround_selection, { desc = "Surround visual selection with char" })

end

return M

