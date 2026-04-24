
-- # org plan keymaps


local plan = require("org.plan.api")
local overview = require("org.plan.overview")


-- Open overview
vim.keymap.set({"i","n","v"}, "<S-Space>op", plan.overview.open)

vim.keymap.set({"i","n","v"}, "<S-Space>opa", plan.task_add_intr)

vim.keymap.set({"i","n","v"}, "<S-Space>ope", function()
    vim.cmd("tabnew | Oil "..plan.plandir)
end)

vim.keymap.set({"i","n","v"}, "<S-Space>opf", plan.task_picker)
vim.keymap.set({"i","n","v"}, "<S-Space>opg", plan.plan_grep)


-- Project task <M-F6>
vim.keymap.set({"i","n","v","c","t"}, "<F54>", function()
    if vim.fn.expand("%:t") == "todo.md" then vim.cmd("bwipeout") return end

    vim.cmd("tabnew ~/Personal/dotfiles/User/nvim/todo.md")
end)


-- open curr proj doc
-- map({"i","n","v","c","t"}, "<F3>", function()



