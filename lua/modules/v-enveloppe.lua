
-- v-enveloppe --

local M = {}


function M.enveloppe_selection(schar, echar)
    vim.cmd('norm! m`')  --save curso pos
    vim.cmd('norm! "zd') --get and rem text
    vim.cmd('norm! i'..schar)
    vim.cmd('norm! "zP')
    vim.cmd('norm! a'..echar)
    vim.cmd('norm! ``')  --restore curso pos
end

function M.setup()
    --paren
    vim.keymap.set("i", "<C-(>", '<esc>m`"_diwi(<esc>P`]a)``')
    vim.keymap.set("n", "<C-(>", 'm`"_diwi(<esc>P`]a)``' )
    vim.keymap.set("v", '<C-(>', function() M.enveloppe_selection('(',')') end)

    --vim.keymap.set("v", '<C-[>', function() M.enveloppe_selection('[',']') end)

    vim.keymap.set("v", '<C-{>', function() M.enveloppe_selection('{','}') end)

    --chevron
    vim.keymap.set("i", '<C-<>', "<esc>mzdiwi<<esc>P`]a><esc>`zli",      { desc = "enveloppe word angled brackets" })
    vim.keymap.set("n", '<C-<>', "mzdiwi<<esc>P`]a><esc>`zl",            { desc = "enveloppe word angled brackets" })
    vim.keymap.set("v", '<C-<>', function() M.enveloppe_selection("<",">") end)

    --single quotes
    vim.keymap.set("i", "<C-'>", [[<esc>m`"zdiwi'<esc>"zP`]a'<esc>``li]], { desc = "Surround visual selection with char" })
    vim.keymap.set("n", "<C-'>", [[m`"zdiwi'<esc>"zP`]a'<esc>``l]], { desc = "Surround visual selection with char" })
    vim.keymap.set("v", "<C-'>", function() M.enveloppe_selection("'","'") end)

    --double quote
    vim.keymap.set("i", '<C-">', '<esc>m`"zdiwi"<esc>"zP`]a"<esc>``li', {desc = "Surround visual selection with char" })
    vim.keymap.set("n", '<C-">', 'm`"zdiwi"<esc>"zP`]a"<esc>``l',       {desc = "Surround visual selection with char" })
    vim.keymap.set("v", '<C-">', function() M.enveloppe_selection('"','"') end)

    vim.keymap.set("v", '<C-|>', function() M.enveloppe_selection('|','|') end)

    --*
    vim.keymap.set("v", '<C-*>', function() M.enveloppe_selection('*','*') end)

    vim.keymap.set("v", '<C-->', function() M.enveloppe_selection('-','-') end)
end


--------
return M

