
-- enveloppe --

local M = {}

function M.get_visual_selection()
    local _, csrow, cscol, cerow, cecol
    local mode = vim.fn.mode()
    if mode == "v" or mode == "V" or mode == "" then
        --if we are in visual mode use the live position
        _, csrow, cscol, _ = unpack(vim.fn.getpos("."))
        _, cerow, cecol, _ = unpack(vim.fn.getpos("v"))
        if mode == "V" then
            -- visual line doesn't provide columns
            cscol, cecol = 0, 999
        end
        -- exit visual mode
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
    else
        -- otherwise, use the last known visual position
        _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
        _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
    end
    -- swap vars if needed
    if cerow < csrow then
        csrow, cerow = cerow, csrow
    end
    if cecol < cscol then
        cscol, cecol = cecol, cscol
    end
    local lines = vim.fn.getline(csrow, cerow)
    local n = cerow - csrow + 1

    if n <= 0 then return "" end

    lines[n] = string.sub(lines[n], 1, cecol)
    lines[1] = string.sub(lines[1], cscol)
    return table.concat(lines, "\n")
end

function M.envelope_selected_doublequote()
    local string = M.get_visual_selection()
    vim.cmd('normal! "_d')
    local surrounded = '"'..string..'"'
    vim.api.nvim_put({surrounded}, "", false, false)
end

function M.envelope_selected_singlequote()
    local string = M.get_visual_selection()
    vim.cmd('normal! "_d')
    local surrounded = "'"..string.."'"
    vim.api.nvim_put({surrounded}, "", false, false)
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

    vim.keymap.set("v", '<C-">', M.envelope_selected_doublequote, { desc = "Surround visual selection with char" })
    vim.keymap.set("v", "<C-'>", M.envelope_selected_singlequote, { desc = "Surround visual selection with char" })

end

return M

