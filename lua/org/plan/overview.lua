
-- # org plan overview


local plan = require("org.plan.api")


local M = {}


---@class PlanUIState
---@field visuals string|nil
---@field data table|nil

---@type PlanUIState[]
M.uistate = {}

M.boards = {
    ["default"] = {},
    ["health"] = {},
    ["tech"] = {},
}

M.curr_board = "default"


---@param data table
---@return string
function M.taskcard(data)
    local card = {}

    local tittle = "□ "..data.summary

    local metadat = table.concat({
        data.priority,
        " ",
        "["..table.concat(data.tags, " ").."]",
        -- " ", "("..data.id..")",
        -- " ", "("..data.id..")",
        -- " ",
        -- data.due,
    }, "")

    local target = 60
    local tittle_width = vim.fn.strdisplaywidth(tittle)

    if tittle_width > target then
        tittle = vim.fn.strcharpart(tittle, 0, target - 4) .. "  ⋯ "
    else
        tittle = tittle..string.rep(" ", target - tittle_width)
    end

    local card_text = tittle.." | "..metadat

    return card_text
end

---@param visuals? string
---@param data? table
function M.push_uistate(visuals, data)
    visuals = visuals or ""
    -- data = data or {}
    data = data or nil

    table.insert(M.uistate, { ["visuals"] = visuals, ["data"] = data })
end

---@param tasks table
function M.group_by_board(tasks)
    -- reset boards
    for name, _ in pairs(M.boards) do
        M.boards[name] = {}
    end

    for _, td in pairs(tasks) do
        local name = td.project or "default"

        if M.boards[name] then
            table.insert(M.boards[name], td)
        else
            table.insert(M.boards["default"], td)
        end
    end
end

function M.build()
    M.uistate = {}  -- reset ui

    -- Tasks dat
    local tasksdb = plan.gather_tasks_db()
    tasksdb = tasksdb and tasksdb or {}

    M.group_by_board(tasksdb)
    local curboard = M.boards[M.curr_board]
    if not curboard then return end

    -- Header
    local heading = {
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
        "■ "..M.curr_board.." Tasks",
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    }
    for _, line in ipairs(heading) do
        M.push_uistate(line)
    end

    -- sort
    local active = {}
    local backlog = {}

    for _, td in pairs(curboard) do
        if td.status == "active" then
            table.insert(active, td)
        elseif td.status == "paused" then
            table.insert(backlog, td)
        end
    end

    local function sort_prio(tasks)
        table.sort(tasks, function(a, b)
            return (a.priority or 0) < (b.priority or 0)
        end)
    end
    sort_prio(active)
    sort_prio(backlog)


    -- build
    M.push_uistate("■■ Active".." ".."["..tostring(#active).."]")
    for _, td in ipairs(active) do
        M.push_uistate(M.taskcard(td), td)
    end
    M.push_uistate("", {}) -- padding

    M.push_uistate("■■ Backlog".." ".."["..tostring(#backlog).."]")
    for _, td in ipairs(backlog) do
        M.push_uistate(M.taskcard(td), td)
    end
    M.push_uistate("", {}) -- padding
end

-- Rendering
function M.render()
    M.build()

    local visuals = {}
    for i, val in ipairs(M.uistate) do
        table.insert(visuals, val.visuals)
    end

    vim.api.nvim_buf_set_lines(0, 0, -1, false, visuals)
end


-- Retrieval
---@return table| nil
function M.task_get_data_at_cursor()
    local cursrpos = vim.api.nvim_win_get_cursor(0)
    local row = M.uistate[cursrpos[1]]

    return row and row.data or nil
end

function M.task_set_status_at_cursor(status)
    local tdat = M.task_get_data_at_cursor()
    if not tdat or not tdat.id then return end

    local ok, msg = plan.task_set_status(status, tdat.id)
    vim.notify(msg, vim.log.levels.INFO)
    return ok
end

function M.task_toggle_status_at_cursor()
    local tdat = M.task_get_data_at_cursor()
    if not tdat or not tdat.id then return end

    local newstat = tdat.status == "active" and "paused" or "active"
    local ok, msg = plan.task_set_status(newstat, tdat.id)
    vim.notify(msg, vim.log.levels.INFO)
    return ok
end

function M.task_set_prio_at_cursor(p)
    local tdat = M.task_get_data_at_cursor()
    if not tdat or not tdat.uuid then return end

    plan.task_set_prio(tdat.uuid, p)
end

function M.task_bump_prio_at_cursor(decrem, amnt)
    local tdat = M.task_get_data_at_cursor()
    if not tdat or not tdat.uuid then return end

    plan.task_bump_prio(tdat.uuid, amnt, decrem)
end

function M.task_ed_at_cursor()
    local tdat = M.task_get_data_at_cursor()
    if not tdat or not tdat.uuid then return end

    local tpath = vim.fs.normalize(plan.plandir..tdat.status.."/"..tdat.uuid..".yml")

    vim.cmd("vs"); vim.cmd("vert resize +10")
    vim.cmd("e "..tpath)

    vim.bo[0].buflisted = false
    vim.b.wintype = "overview_task"
end

function M.task_inspect_at_cursor()
    local tdat = M.task_get_data_at_cursor()
    print(vim.inspect(tdat))
end

function M.set_board(name)
    name = name and name or "default"
    M.curr_board = name

    M.render()
end

function M.board_cycle(reverse)
    reverse = reverse or false

    local bnames = {}
    for name, _ in pairs(M.boards) do
        table.insert(bnames, name)
    end

    if #bnames == 0 then return end

    table.sort(bnames) -- deterministic order

    local curidx = 1
    for i, name in ipairs(bnames) do
        if name == M.curr_board then
            curidx = i; break
        end
    end

    if reverse then
        curidx = (curidx - 2) % #bnames + 1
    else
        curidx = curidx % #bnames + 1
    end

    M.curr_board = bnames[curidx]

    M.render()
end

function M.create_buf()
    vim.cmd("tabnew")
    vim.api.nvim_buf_set_name(0, "Plan overview"); vim.cmd("e!")

    vim.opt_local.number = false
    local planbuf = vim.api.nvim_get_current_buf()

    -- vim.wo.foldlevel=0
    -- vim.opt_local.foldmethod="expr"
    -- vim.opt_local.foldexpr='v:lua.foldexpr_planv()'

    vim.bo[planbuf].buftype = "nofile"
    -- vim.bo[planbuf].filetype = "markdown"
    vim.bo[planbuf].modifiable = true
end

function M.open()
    -- buf
    local isbufoverview = false

    if vim.fn.expand("%:p:t") == "Plan overview" then
        vim.cmd("bwipeout!")
        return
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
        M.create_buf()
    end


    M.curr_board = "default"

    -- Display
    M.render()


    -- ## Keymaps
    -- t add
    vim.keymap.set({"i","n","v"}, "<C-S-n>", function()
        plan.task_add_intr()
        M.render()
    end, {buffer=true})

    -- t rm
    vim.keymap.set({"i","n","v"}, "<S-Del>", function()
        local ok, out = plan.task_rm(M.task_get_data_at_cursor().id)
        vim.notify(out, vim.log.levels.INFO)
        M.render()
    end, {buffer=true})

    -- t toggle
    vim.keymap.set({"i","n","v"}, "<C-Space>", function()
        M.task_toggle_status_at_cursor()
        M.render()
    end, {buffer=true})

    -- t done
    vim.keymap.set({"i","n","v"}, "<C-S-D>", function()
        M.task_set_status_at_cursor("resolved")
        M.render()
    end, {buffer=true})

    -- prio
    vim.keymap.set({"i","n","v"}, "<C-S-Up>", function()
        M.task_bump_prio_at_cursor()
        M.render()
    end, {buffer=true})
    vim.keymap.set({"i","n","v"}, "<C-S-Down>", function()
        M.task_bump_prio_at_cursor(true)
        M.render()
    end, {buffer=true})

    -- t ed
    vim.keymap.set({"i","n"}, "<C-CR>", M.task_ed_at_cursor, {buffer=true})
    vim.keymap.set("n", "<CR>", M.task_ed_at_cursor, {buffer=true})

    -- board
    vim.keymap.set({"i","n","v"}, "<M-S-Tab>", function()
        M.board_cycle()
    end, {buffer=true})
    vim.keymap.set({"i","n","v"}, "<M-C-S-Tab>", function()
        M.board_cycle(true)
    end, {buffer=true})

    -- Search
    vim.keymap.set({"i","n","v"}, "<C-S-F>", plan.task_picker, {buffer=true})
    vim.keymap.set({"i","n","v"}, "<C-S-G>", plan.task_grep,   {buffer=true})

    -- refrersh
    vim.keymap.set({"i","n","v"}, "<F5>", M.render, {buffer=true})

    -- debug
    vim.keymap.set({"i","n","v"}, "<C-S-H>", M.task_inspect_at_cursor, {buffer=true})
end


--------
return M

