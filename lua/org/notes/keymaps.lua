
-- # org notes keymaps

local api = require("org.notes")


vim.keymap.set({"i","n","v","t"}, "<M-n>n", "<Cmd>NoteCreate<CR>")
vim.keymap.set({"i","n","v","t"}, "<M-n>nc", "<Cmd>NoteCreateCWD<CR>")


vim.keymap.set({"i","n","v","t"}, "<C-M-o>na", api.create_intr)
vim.keymap.set({"i","n","v","t"}, "<F25>", api.create_intr) -- C-F1

vim.keymap.set({"i","n","v"}, "<C-M-o>e", api.explore)


-- idea capture S-F6
vim.keymap.set({"i","n","v","t"}, "<F18>", function()
    vim.cmd("tabnew ~/Personal/Org/Notes/idea.md")
    vim.cmd("norm! G0i")
end)



