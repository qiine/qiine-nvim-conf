
-- org plan api

local M = {}


M.plandir = vim.fn.expand("~/Personal/Org/Plan/.dstask/")

---@return boolean status, string err
function M.task_add(tittle)
    if not tittle then return false, "err, no task tittle" end

    local cmd = {"dstask", "start", tittle}
    local dstsk = vim.system(cmd, {text=true}):wait()
    if dstsk.code ~= 0 then return false, dstsk.stderr end

    return true, ""
end

---@param status string
function M.task_set_state(status, id)
    if not id then return false, "err, no task id" end

    local statuses = {
        ["active"] = "start",
        ["pending"] = "stop",
        ["resolved"] = "done"
    }

    local cmd = {"dstask", statuses[status], id}
    local dstsk = vim.system(cmd, {text=true}):wait()
    if dstsk.code ~= 0 then return false, dstsk.stderr end

    return true, ""
end

function M.task_add_intr()
    vim.ui.input({prompt="Task: ", default="Newtask"},
    function(input)
        vim.api.nvim_command("redraw") --Hide prompt
        if input == nil then vim.notify("Task creation canceled.", vim.log.levels.INFO) return end

        local ok, err = M.task_add(input)
        if not ok then vim.notify(err, vim.log.levels.ERROR); return end

        vim.notify("Task created: "..input, vim.log.levels.INFO)
    end)
end

---@return boolean ok, string out, string err
function M.task_rm(id)
    local cmd = {"dstask", "remove", id}
    local dstsk = vim.system(cmd, {text=true}):wait()
    if dstsk.code ~= 0 then
        return false, "Failed to rm "..id, dstsk.stdout
    end

    return true, "Task rm "..id, ""
end

---@return table|nil data, string|nil raw
function M.gather_tasks_db()
    local cmd = {"dstask", "show-open"}
    local dstsk = vim.system(cmd, {text=true}):wait()
    local data = vim.json.decode(dstsk.stdout)
    local raw = dstsk.stdout

    return data, raw
end

function M.debug_tasks_db()
    -- debug buf
    vim.cmd("tabnew")

    local planbuf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(planbuf, "Plan debug"); vim.cmd("e!")
    -- vim.opt_local.number = true
    vim.bo[planbuf].buftype = "nofile"

    -- data
    local dat, raw = M.gather_tasks_db()
    if not raw then print("db err") return end

    -- Render
    local out = vim.split(raw, "\n")

    vim.api.nvim_buf_set_lines(0, 0, 0, false, out)
    vim.bo[planbuf].modifiable = false
end


-----
return M

