
-- Overview

local plan = require("org.plan.api")


local M = {}

M._tasksdat = {}


---@return table out, table taskdat
function M.build()
    local out = {}

    -- Header
    local heading = {
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
        "■ Tasks",
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    }
    for _, line in ipairs(heading) do
        table.insert(out, line)
        table.insert(M._tasksdat, {})
    end

    -- Tasks
    local tasksdb = plan.gather_tasks_db()
    tasksdb = tasksdb and tasksdb or {}


    local groups = {}
    local seen = {}

    -- Extract groups
    for _, td in ipairs(tasksdb) do
        local proj = (td.project and td.project ~= "") and td.project or "ungrouped"
        if not seen[proj] then
            seen[proj] = true
            table.insert(groups, proj)
        end
    end

    -- Group tasks visually
    for _, group in ipairs(groups) do
        table.insert(out, "## "..group)
        table.insert(M._tasksdat, {})

        for _, td in ipairs(tasksdb) do
            local proj = (td.project and td.project ~= "") and td.project or "ungrouped"

            if group == proj then
                local tinfo = table.concat({
                    "□ ",
                    td.summary,
                    " | ",
                    -- td.priority,
                    " ",
                    -- "[" .. table.concat(td.tags, " ") .. "]",
                    " ",
                    "(" .. td.id .. ")",
                }, "")

                table.insert(out, tinfo)
                table.insert(M._tasksdat, {
                    id       = td.id,
                    summary  = td.summary,
                    priority = td.priority,
                    tags     = td.tags,
                    project  = td.project,
                    due      = td.due,
                })
            end
        end

        table.insert(out, "") -- space at the end of each group
        table.insert(M._tasksdat, {})
    end

    return out, M._tasksdat
end

function M.render()
    local out, taskdat = M.build()

    M._tasksdat = taskdat

    -- Insert result to buffer
    vim.api.nvim_buf_set_lines(0, 0, -1, false, out)
end

---@return table| nil
function M.get_taskdat_at_cursor()
    local cursopos = vim.api.nvim_win_get_cursor(0)
    -- local tasks, tasksdats = M.build()
    --  print(tostring(cursopos[1]))
    local out = M._tasksdat[cursopos[1]] or nil
    return out

    -- return tasksdats
end

function M.open()
    vim.cmd("tabnew")
    vim.api.nvim_buf_set_name(0, "Plan"); vim.cmd("e!")

    vim.opt_local.number = false
    local planbuf = vim.api.nvim_get_current_buf()

    -- vim.wo.foldlevel=0
    -- vim.opt_local.foldmethod="expr"
    -- vim.opt_local.foldexpr='v:lua.foldexpr_planv()'

    vim.bo[planbuf].buftype = "nofile"
    -- vim.bo[planbuf].filetype = "markdown"
    vim.bo[planbuf].modifiable = true

    M.render()


    -- Keymaps
    vim.keymap.set({"i","n","v"}, "<F5>", function()
        M.render()
    end, {buffer=true})

    vim.keymap.set({"i","n","v"}, "<C-S-N>", function()
        plan.task_add_intr()
        M.render()
    end, {buffer=true})

    vim.keymap.set({"i","n","v"}, "<C-S-CR>", function()
        local t = M.get_taskdat_at_cursor()
        if t then
            print(t.id, t.summary)
        end
    end, {buffer=true})
end


vim.api.nvim_create_user_command("PlanDebugtasksDat", function()
    print(vim.inspect(M._tasksdat))
end, {})
--------
return M

