
-- # org plan keymaps


local plan = require("org.plan")


-- Open journal
vim.keymap.set({"i","n","v"}, "<S-Space>op", function()
    plan.overview_show()
end)

vim.keymap.set({"i","n","v"}, "<S-Space>opa", function()
    plan.task_add_intr()
end)

vim.keymap.set({"i","n","v"}, "<S-Space>ope", function()
    local cursopos = vim.api.nvim_win_get_cursor(0)
    vim.cmd("term dstask edit "..cursopos[1]-3)
end)

vim.keymap.set({"i","n","v"}, "<S-Space>opr", function()
    local id = vim.api.nvim_win_get_cursor(0)[1]-3
    plan.task_rm(id)
    print("Task rm "..id)
end)

