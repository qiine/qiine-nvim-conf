
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



    --paren
    vim.keymap.set("i", "<C-(>", "<esc>mzdiwi(<esc>P`]a)`z" )
    vim.keymap.set("n", "<C-(>", "mzdiwi(<esc>P`]a)`z" )
    vim.keymap.set("v", "<C-(>", "mzdi(<esc>P`]a)`z" )

    --vim.keymap.set("v", "<C-[>", "mzdi[<esc>P`]`z" )
    vim.keymap.set("v", "<C-{>", "mzdi{<esc>P`]a}`z" )

    --chevron
    vim.keymap.set("i", '<C-<>', "<esc>mzdiwi<<esc>P`]a><esc>`zli", { desc = "enveloppe word angled brackets" })
    vim.keymap.set("n", '<C-<>', "mzdiwi<<esc>P`]a><esc>`zl",            { desc = "enveloppe word angled brackets" })
    vim.keymap.set("v", "<C-<>", "mzdi<<esc>P`]a><esc>`zl",              { desc = "enveloppe word angled brackets" })

    --quotes
    vim.keymap.set("i", '<C-">', '<esc>mzdiwi"<esc>P`]a"<esc>`zli', { desc = "Surround visual selection with char" })
    vim.keymap.set("n", '<C-">', 'mzdiw"<esc>P`]a"<esc>`zl', { desc = "Surround visual selection with char" })
    vim.keymap.set("v", '<C-">', 'mzdi"<esc>P`]a"<esc>`zl', { desc = "Surround visual selection with char" })

    vim.keymap.set("v", "<C-'>", "mzdi'<esc>P`]a'<esc>`zl", { desc = "Surround visual selection with char" })

    vim.keymap.set("v", "<C-*>", "mzdi*<esc>P`]a*<esc>`z" )

end


--------
return M

