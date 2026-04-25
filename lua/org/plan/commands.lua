
-- # org plan cmds


local plan = require("org.plan.api")
local overview = require("org.plan.overview")


-- ## General
vim.api.nvim_create_user_command("PlanTaskAdd", plan.task_add_intr, {})

vim.api.nvim_create_user_command("PlanExplorer", function()
    vim.cmd("tabnew | Oil "..plan.plandir)
end, {})


vim.api.nvim_create_user_command("PlanDebugDB", plan.debug_tasks_db, {})



-- ## Overview
vim.api.nvim_create_user_command("PlanOverviewOpen", overview.open, {})

vim.api.nvim_create_user_command("PlanOverviewDebugTasksData", function()
    print(vim.inspect(overview.uistate))
end, {})



