
-- # org plan keymaps


local plan = require("org.plan.api")
local overview = require("org.plan.overview")


-- Open journal
vim.keymap.set({"i","n","v"}, "<S-Space>op", function()
    plan.overview.open()
end)

vim.keymap.set({"i","n","v"}, "<S-Space>opa", function()
    plan.task_add_intr()
end)

vim.keymap.set({"i","n","v"}, "<S-Space>ope", function()
    vim.cmd("tabnew | Oil "..plan.plandir)
end)

vim.keymap.set({"i","n","v"}, "<S-Space>opr", function()
    -- vim.api.nvim_echo({{"rm task id: "}}, false, {})
    -- local id = vim.fn.getcharstr()
    -- plan.task_rm(id)
    -- print("Task rm "..id)
end)

