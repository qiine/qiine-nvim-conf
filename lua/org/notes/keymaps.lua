
-- # org notes keymaps


vim.keymap.set({"i","n","v","t"}, "<M-n>n", "<Cmd>NoteCreate<CR>")
vim.keymap.set({"i","n","v","t"}, "<M-n>nc", "<Cmd>NoteCreateCWD<CR>")


-- idea capture S-F6
vim.keymap.set({"i","n","v","t"}, "<F18>", function()
    vim.cmd("tabnew ~/Personal/Org/Notes/idea.md")
    vim.cmd("norm! G0i")
end)

