
-- v-enveloppe --

local M = {}

function M.enveloppe_select(schar, echar)
    vim.cmd('norm! m`') -- save curso pos
    vim.cmd('norm! ') -- update `>`< proper pos
    vim.cmd('norm! `>a'..echar) -- "a" first, order matter
    vim.cmd('norm! `<i'..schar)
    vim.cmd('norm! ``') -- Restore curso pos
end

function M.setup()
    --paren
    vim.keymap.set("i", "<C-(>", '<esc>m`"_diwi(<esc>P`]a)``')
    vim.keymap.set("n", "<C-(>", 'm`"_diwi(<esc>P`]a)``' )
    vim.keymap.set("x", '<C-(>', function() M.enveloppe_select('(',')') end)

    --vim.keymap.set("v", '<C-[>', function() M.enveloppe_selection('[',']') end)

    vim.keymap.set("x", '<C-{>', function() M.enveloppe_select('{','}') end)

    --chevron
    vim.keymap.set("i", '<C-<>', "<esc>mzdiwi<<esc>P`]a><esc>`zli",      { desc = "enveloppe word angled brackets" })
    vim.keymap.set("n", '<C-<>', "mzdiwi<<esc>P`]a><esc>`zl",            { desc = "enveloppe word angled brackets" })
    vim.keymap.set("x", '<C-<>', function() M.enveloppe_select("<",">") end)

    --single quotes
    vim.keymap.set("i", "<C-'>", [[<esc>m`"zdiwi'<esc>"zP`]a'<esc>``li]], { desc = "Surround visual selection with char" })
    vim.keymap.set("n", "<C-'>", [[m`"zdiwi'<esc>"zP`]a'<esc>``l]], { desc = "Surround visual selection with char" })
    vim.keymap.set("x", "<C-'>", function() M.enveloppe_select("'","'") end)

    --double quote
    vim.keymap.set("i", '<C-">', '<esc>m`"zdiwi"<esc>"zP`]a"<esc>``li', {desc = "Surround visual selection with char" })
    vim.keymap.set("n", '<C-">', 'm`"zdiwi"<esc>"zP`]a"<esc>``l',       {desc = "Surround visual selection with char" })
    vim.keymap.set("x", '<C-">', function() M.enveloppe_select('"','"') end)

    vim.keymap.set("x", '<C-|>', function() M.enveloppe_select('|','|') end)

    --*
    vim.keymap.set("x", '<C-*>', function() M.enveloppe_select('*','*') end)

    vim.keymap.set("x", '<C-->', function() M.enveloppe_select('-','-') end)

    -- /
    vim.keymap.set("x", '<C-/>', function() M.enveloppe_select('/','/') end)

end


--------
return M

