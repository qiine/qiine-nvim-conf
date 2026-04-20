
-- # Plan cmds

local plan = require("org.plan")


vim.api.nvim_create_user_command("PlanTaskAdd", function(opts)
    plan.task_add(opts.args[1] and opts.args[1] or "Newtask")
    print("Task created")
end, {nargs="?"})

vim.api.nvim_create_user_command("PlanOverview", function()
    plan.overview_show()
end, {})

vim.api.nvim_create_user_command("PlanExplorer", function()
    vim.cmd("tabnew | Oil "..plan.plandir)
end, {})



vim.api.nvim_create_user_command("PlanDebugDB", function()
    plan.debug_db()
end, {})
