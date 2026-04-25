
-- org plan api

local M = {}


M.plandir = vim.fn.expand("~/Personal/Org/Plan/.dstask/")

---@return table
function M.get_tasksfiles()
    return vim.fs.find(
        function(name, path)
            return not path:match("/%.git/") and name:match("%.yml$")
        end, { path = M.plandir, type = "file", limit = math.huge}
    )
end

---@return string

function M.task_get_fpath(uuid)
    local path = vim.fs.find(function(name, path)
        return not path:match("/%.git/") and name == uuid..".yml"
    end, { path = M.plandir, type = "file", limit = math.huge })

    return path[1]
end

---@return boolean status, string msg
function M.task_add(tittle)
    if not tittle then return false, "err, no task tittle" end

    local cmd = {"dstask", "start", tittle}
    local dstsk = vim.system(cmd, {text=true}):wait()
    if dstsk.code ~= 0 then return false, dstsk.stderr end

    return true, ""
end

function M.task_add_intr()
    vim.ui.input({prompt="Task: ", default=""},
    function(input)
        vim.api.nvim_command("redraw") --Hide prompt
        if input == nil then vim.notify("Task creation canceled.", vim.log.levels.INFO) return end

        local ok, err = M.task_add(input)
        if not ok then vim.notify(err, vim.log.levels.ERROR); return end

        vim.notify("Task created: "..input, vim.log.levels.INFO)
    end)
end

---@param id number
---@return boolean ok, string msg
function M.task_rm(id)
    if not id then return false, "err, invalid id" end

    local cmd = {"dstask", "remove", tostring(id)}
    local dstsk = vim.system(cmd, {text=true}):wait()
    if dstsk.code ~= 0 then
        return false, "Failed to rm "..id.."\n"..dstsk.stderr
    end

    return true, "Task rm "..id
end

---@param status string
---@param id number
function M.task_set_status(status, id)
    if not id then return false, "err, invalid id" end

    local statuses = {
        ["active"]   = "start",
        ["paused"]   = "stop",
        ["resolved"] = "done"
    }

    local cmd = {"dstask", statuses[status], tostring(id)}
    local dstsk = vim.system(cmd, {text=true}):wait()
    if dstsk.code ~= 0 then return false, dstsk.stderr end

    return true, "Set "..status.." id:"..id
end

---@param uuid string
---@return number|nil prio
function M.task_get_prio(uuid)
    if not uuid then return end

    local tpath = M.task_get_fpath(uuid)
    local lines = vim.fn.readfile(tpath)

    local p
    for i, line in ipairs(lines) do
        if line:match("^priority:%s*P%d+") then
            p = tonumber(line:match("P(%d+)")); break  -- priority: P2
        end
    end

    return p or nil
end

---@param uuid string
---@param p number
function M.task_set_prio(uuid, p)
    if not uuid then return end
    p = p or 1

    local tpath = M.task_get_fpath(uuid)
    local lines = vim.fn.readfile(tpath)

    local found = false
    for i, line in ipairs(lines) do
        if line:match("^priority:%s*P%d+") then
            lines[i] = "priority: P"..tostring(p)
            found = true
            break
        end
    end

    if not found then return end

    vim.fn.writefile(lines, tpath)
end

---@param uuid string
---@param amnt? number
---@param decrem? boolean
function M.task_bump_prio(uuid, amnt, decrem)
    if not uuid then return end
    amnt = amnt or 1
    if not decrem then decrem = false end

    local curprio = M.task_get_prio(uuid)
    if not curprio then return end

    local newprio = decrem and curprio + amnt or curprio - amnt
    newprio = math.max(newprio, 0)
    M.task_set_prio(uuid, newprio)
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

    vim.api.nvim_buf_set_lines(0, 0, -1, false, out)
    vim.bo[planbuf].modifiable = false
end

function M.task_picker()
    local tfiles = M.get_tasksfiles()

    require("fzf-lua").fzf_exec(tfiles, {
        winopts = { title = "Find Tasks", },
        prompt = "Task> ",
        previewer = "builtin",
        actions = {
            ["default"] = function(entry)
                vim.cmd("e "..entry[1])
            end
        },
    })
end

function M.task_grep()
    require("fzf-lua").live_grep({
        winopts = { title = "Grep Tasks" },
        -- rg_opts = "--hidden --glob '!.git/*'",
        cwd = M.plandir,
    })
end


-----
return M

