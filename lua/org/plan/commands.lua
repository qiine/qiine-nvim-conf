
-- # org plan cmds


local plan = require("org.plan.api")
local overview = require("org.plan.overview")


vim.api.nvim_create_user_command("PlanTaskAdd", function(opts)
    plan.task_add(opts.args[1] and opts.args[1] or "Newtask")
    print("Task created")
end, {nargs="?"})


vim.api.nvim_create_user_command("PlanExplorer", function()
    vim.cmd("tabnew | Oil "..plan.plandir)
end, {})


vim.api.nvim_create_user_command("PlanDebugDB", plan.debug_tasks_db, {})


-- ## Overview
vim.api.nvim_create_user_command("PlanOverviewOpen", function()
    overview.open()
end, {})

vim.api.nvim_create_user_command("PlanOverviewDebugTasksData", function()
    print(vim.inspect(overview.uistate))
end, {})

vim.api.nvim_create_user_command("PlanOverviewDebugInspectTask", function()
    overview.task_inspect_at_cursor()
end, {})


