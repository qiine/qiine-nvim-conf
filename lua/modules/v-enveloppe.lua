
-- v-enveloppe --

local M = {}

function M.setup()

    --paren
    vim.keymap.set("i", "<C-(>", "<esc>mzdiwi(<esc>P`]a)`z" )
    vim.keymap.set("n", "<C-(>", "mzdiwi(<esc>P`]a)`z" )
    vim.keymap.set("v", "<C-(>", "mzdi(<esc>P`]a)`z" )

    --vim.keymap.set("v", "<C-[>", "mzdi[<esc>P`]`z" )
    vim.keymap.set("v", "<C-{>", "mzdi{<esc>P`]a}`z" )

    --chevron
    vim.keymap.set("i", '<C-<>', "<esc>mzdiwi<<esc>P`]a><esc>`zli",      { desc = "enveloppe word angled brackets" })
    vim.keymap.set("n", '<C-<>', "mzdiwi<<esc>P`]a><esc>`zl",            { desc = "enveloppe word angled brackets" })
    vim.keymap.set("v", "<C-<>", "mzdi<<esc>P`]a><esc>`zl",              { desc = "enveloppe word angled brackets" })

    --single quotes
    vim.keymap.set("i", "<C-'>", "<esc>mzdiwi'<esc>P`]a'<esc>`zli", { desc = "Surround visual selection with char" })
    vim.keymap.set("n", "<C-'>", "mzdiwi'<esc>P`]a'<esc>`zl", { desc = "Surround visual selection with char" })
    vim.keymap.set("v", "<C-'>", "mzdi'<esc>P`]a'<esc>`zl", { desc = "Surround visual selection with char" })

    --double quote
    vim.keymap.set("i", '<C-">', '<esc>mzdiwi"<esc>P`]a"<esc>`zli', { desc = "Surround visual selection with char" })
    vim.keymap.set("n", '<C-">', 'mzdiwi"<esc>P`]a"<esc>`zl', { desc = "Surround visual selection with char" })
    vim.keymap.set("v", '<C-">', 'mzdi"<esc>P`]a"<esc>`zl', { desc = "Surround visual selection with char" })

    --*
    vim.keymap.set("v", "<C-*>", "mzdi*<esc>P`]a*<esc>`z" )

end


--------
return M

