
-- # org plan overview


local plan = require("org.plan.api")


local M = {}


M.tasksdata = {}
M.uistate = {}

M.activelist = {}
M.backlog = {}


---@param data table
---@return string text
function M.taskcard(data)
    local visuals = table.concat({
        "□ ",
        data.summary,
        " | ",
        -- data.priority,
        -- " ",
        -- "[" .. table.concat(data.tags, " ") .. "]",
        -- " ",
        -- "(" .. data.id .. ")",
        -- " ",
        -- data.due,
    }, "")
    return visuals
end

---@return table out, table
function M.build()
    local visuals = {}
    local data = {}

    -- Header
    local heading = {
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
        "■ Tasks",
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    }
    for _, line in ipairs(heading) do
        table.insert(visuals, line)
        table.insert(data, {})
    end

    -- Tasks
    local tasksdb = plan.gather_tasks_db()
    tasksdb = tasksdb and tasksdb or {}


    -- Group tasks visually
    table.insert(visuals, "■■ Active")
    table.insert(data, {})
    for k, td in pairs(tasksdb) do
        if td.status == "active" then
            table.insert(visuals, M.taskcard(td))
            table.insert(data, td)
        end
    end
    table.insert(visuals, "") -- space at the end of each group
    table.insert(data, {})


    table.insert(visuals, "■■ Backlog")
    table.insert(data, {})
    for k, td in pairs(tasksdb) do
        if td.status == "paused" then
            table.insert(visuals, M.taskcard(td))
            table.insert(data, td)
        end
    end
    table.insert(visuals, "") -- space at the end of each group
    table.insert(data, {})


    M.uistate = visuals
    M.tasksdata = data

    return visuals, data
end

---@return table| nil
function M.get_task_data(id)
    return M.tasksdata[id] or nil
end

---@return table| nil
function M.get_task_data_at_cursor()
    local cursopos = vim.api.nvim_win_get_cursor(0)
    return M.tasksdata[cursopos[1]] or nil
end

---@param status string
function M.task_set_status_at_cursor(status)
    local tid = M.get_task_data_at_cursor().id
    if not tid then return end

    plan.task_set_state(status, tid)
end

function M.task_toggle_status_at_cursor()

    local taskda = M.get_task_data_at_cursor()
    if not taskda then return end
    local curstatus = taskda.status

    local newstatus = ""
    if curstatus == "active" then newstatus = "pending" else  newstatus = "active" end
    print(curstatus.." "..taskda.summary)
    plan.task_set_state(newstatus, taskda.id)
end

function M.task_ed_at_cursor()
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

function M.render()
    M.build()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, M.uistate)
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
    M.render()


    -- Keymaps
    vim.keymap.set({"i","n","v"}, "<C-S-n>", function()
        plan.task_add_intr()
        M.render()
    end, {buffer=true})

    vim.keymap.set({"i","n","v"}, "<S-Del>", function()
        local ok, out, err = plan.task_rm(M.get_task_data_at_cursor().id)
        if ok then
            vim.notify(out, vim.log.levels.INFO)
        else
            vim.notify(err, vim.log.levels.ERROR)
        end

        M.render()
    end, {buffer=true})

    vim.keymap.set({"i","n","v"}, "<C-Space>", function()
        M.task_toggle_status_at_cursor()
        M.render()
    end, {buffer=true})

    vim.keymap.set({"i","n","v"}, "<C-S-D>", function()
        M.task_set_status_at_cursor("done")
        M.render()
    end, {buffer=true})

    vim.keymap.set({"i","n","v"}, "<C-CR>", function()
        M.task_ed_at_cursor()
    end, {buffer=true})


    vim.keymap.set({"i","n","v"}, "<F5>", function()
        M.render()
    end, {buffer=true})

    vim.keymap.set({"i","n","v"}, "<C-S-H>", function()
        M.task_inspect_at_cursor()
    end, {buffer=true})
end


--------
return M

