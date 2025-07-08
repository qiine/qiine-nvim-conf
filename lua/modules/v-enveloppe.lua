
-- v-enveloppe --

local M = {}

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


function M.enveloppe_word_singlequote()
    local word = vim.fn.expand("<cword>")
    word = "'"..word.."'"

    vim.cmd('normal! ciw'..word)
    vim.cmd('normal! bb')
end

function M.enveloppe_word_doublequote()
    local word = vim.fn.expand("<cword>")
    word = '"'..word..'"'

    vim.cmd('normal! ciw'..word)
    vim.cmd('normal! bb')
end

function M.enveloppe_word_angledbracket()
    local word = vim.fn.expand("<cword>")
    word = '<'..word..'>'

    vim.cmd('normal! ciw'..word)
    vim.cmd('normal! bb')
end


function M.setup(opts)
    opts = opts or {}



    vim.keymap.set({"i","n"}, "<C-'>", M.enveloppe_word_singlequote, { desc = "enveloppe word singlequote" })
    vim.keymap.set({"i","n"}, '<C-">', M.enveloppe_word_doublequote, { desc = "enveloppe word doublequote" })

    vim.keymap.set("i", "<C-(>", "<esc>diwi(<esc>P`]a)<esc>gv" )
    vim.keymap.set("n", "<C-(>", "diwi(<esc>P`]a)<esc><C-O>" )
    vim.keymap.set("v", "<C-(>", "di(<esc>P`]a)" )

    --vim.keymap.set("v", "<C-[>", "di[<esc>P`]a]" )

    vim.keymap.set("v", "<C-{>", "di{<esc>P`]a}" )

    vim.keymap.set({"i","n"}, '<C-<>', M.enveloppe_word_angledbracket, { desc = "enveloppe word angled brackets" })
    vim.keymap.set("v", "<C-<>", "di<<esc>P`]a>")

    vim.keymap.set("v", '<C-">', M.envelope_selected_doublequote, { desc = "Surround visual selection with char" })
    vim.keymap.set("v", "<C-'>", M.envelope_selected_singlequote, { desc = "Surround visual selection with char" })

end


--------
return M

