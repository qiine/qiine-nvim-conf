
-- # org plan overview


local plan = require("org.plan.api")


local M = {}


M.tasksdata = {}
M.uistate = {}


---@return table out, table
function M.build()
    local out = {}
    local tasksdat = {}

    -- Header
    local heading = {
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
        "■ Tasks",
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    }
    for _, line in ipairs(heading) do
        table.insert(out, line)
        table.insert(tasksdat, {})
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
        table.insert(tasksdat, {})

        for _, td in ipairs(tasksdb) do
            local proj = (td.project and td.project ~= "") and td.project or "ungrouped"

            if group == proj then
                local tinfo = table.concat({
                    "□ ",
                    td.summary,
                    " | ",
                    -- td.priority,
                    -- " ",
                    -- "[" .. table.concat(td.tags, " ") .. "]",
                    -- " ",
                    -- "(" .. td.id .. ")",
                    -- " ",
                    -- td.due,
                }, "")

                table.insert(out, tinfo)
                table.insert(tasksdat, {
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
        table.insert(tasksdat, {})
    end

    return out, tasksdat
end

---@return table| nil
function M.get_task_data(id)
    return M.tasksdata[id] or nil
end

---@return table| nil
function M.get_task_data_at_cursor(id)
    local cursopos = vim.api.nvim_win_get_cursor(0)
    return M.tasksdata[cursopos[1]] or nil
end

function M.task_ed_at_cursor()
    -- local cursopos = vim.api.nvim_win_get_cursor(0)
    -- local tid = M.tasksdata[cursopos[1]].id
    local tid = M.get_task_data_at_cursor().id

    if not tid then return end

    vim.cmd("vs")
    vim.cmd("vert resize +15")
    vim.cmd("term dstask edit "..tid)

    vim.bo[0].buflisted = false
    vim.b.wintype = "overview_task"
end

function M.task_inspect_at_cursor()
    local cursopos = vim.api.nvim_win_get_cursor(0)
    print(vim.inspect(M.tasksdata[cursopos[1]]))
end

---@param content table
function M.render(content)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, content)
end

function M.open()
    -- Create buf
    local isbufoverview = false

    if vim.fn.expand("%:p:t") == "Plan overview" then
        isbufoverview = true
    else
        for _, bufid in ipairs(vim.api.nvim_list_bufs()) do
            local bufname = vim.api.nvim_buf_get_name(bufid)
            if vim.fn.fnamemodify(bufname, ":t") == "Plan overview" then
                vim.api.nvim_set_current_buf(bufid)
                isbufoverview = true
                break
            end
        end
    end

    if not isbufoverview then
        vim.cmd("tabnew")
        vim.api.nvim_buf_set_name(0, "Plan overview"); vim.cmd("e!")
    end

    vim.opt_local.number = false
    local planbuf = vim.api.nvim_get_current_buf()

    -- vim.wo.foldlevel=0
    -- vim.opt_local.foldmethod="expr"
    -- vim.opt_local.foldexpr='v:lua.foldexpr_planv()'

    vim.bo[planbuf].buftype = "nofile"
    -- vim.bo[planbuf].filetype = "markdown"
    vim.bo[planbuf].modifiable = true


    -- Display
    M.uistate, M.tasksdata = M.build()
    M.render(M.uistate)


    -- Keymaps

    vim.keymap.set({"i","n","v"}, "<C-S-n>", function()
        plan.task_add_intr()
        M.uistate, M.tasksdata = M.build()
        M.render(M.uistate)
    end, {buffer=true})

    vim.keymap.set({"i","n","v"}, "<S-Del>", function()
        local ok, out, err = plan.task_rm(M.get_task_data_at_cursor().id)
        if ok then
            vim.notify(out, vim.log.levels.INFO)
        else
            vim.notify(err, vim.log.levels.ERROR)
        end

        M.uistate, M.tasksdata = M.build()
        M.render(M.uistate)
    end, {buffer=true})

    vim.keymap.set({"i","n","v"}, "<C-CR>", function()
        M.task_ed_at_cursor()
    end, {buffer=true})


    vim.keymap.set({"i","n","v"}, "<F5>", function()
        M.uistate, M.tasksdata = M.build()
        M.render(M.uistate)
    end, {buffer=true})

    vim.keymap.set({"i","n","v"}, "<C-S-H>", function()
        M.task_inspect_at_cursor()
    end, {buffer=true})
end


--------
return M

