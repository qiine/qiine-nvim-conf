
-- # Plan cmds


local plan = require("org.plan.api")
local overview = require("org.plan.overview")


vim.api.nvim_create_user_command("PlanTaskAdd", function(opts)
    plan.task_add(opts.args[1] and opts.args[1] or "Newtask")
    print("Task created")
end, {nargs="?"})


vim.api.nvim_create_user_command("PlanExplorer", function()
    vim.cmd("tabnew | Oil "..plan.plandir)
end, {})


vim.api.nvim_create_user_command("PlanDebugDB", function()
    plan.debug_tasks_db()
end, {})


-- ## Overview
vim.api.nvim_create_user_command("PlanOverviewOpen", function()
    overview.open()
end, {})

vim.api.nvim_create_user_command("PlanOverviewDebugTasksData", function()
    print(vim.inspect(overview._tasksdat))
end, {})

vim.api.nvim_create_user_command("PlanOverviewDebugInspectTask", function()
    overview.inspect_task_at_cursor()
end, {})


