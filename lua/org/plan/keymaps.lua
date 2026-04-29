
-- # org plan keymaps


local plan = require("org.plan.api")
local overview = require("org.plan.overview")


-- Open overview
vim.keymap.set({"i","n","v"}, "<S-M-o>p", plan.overview.open)
vim.keymap.set({"i","n","v"}, "<F3>",     plan.overview.open)

vim.keymap.set({"i","n","v"}, "<S-M-o>pa", plan.task_add_intr)
vim.keymap.set({"i","n","v"}, "<F27>", plan.task_add_intr) -- C-F3

vim.keymap.set({"i","n","v"}, "<S-M-o>pe", function()
    vim.cmd("tabnew | Oil "..plan.plandir)
end)

vim.keymap.set({"i","n","v"}, "<S-M-o>pf", plan.task_picker)
vim.keymap.set({"i","n","v"}, "<S-M-o>pg", plan.task_grep)


-- Project task <M-F3>
vim.keymap.set({"i","n","v","t"}, "<F15>", function()
    if vim.fn.expand("%:t") == "todo.md" then vim.cmd("bwipeout") return end

    vim.cmd("tabnew ~/Personal/dotfiles/User/nvim/todo.md")
end)




