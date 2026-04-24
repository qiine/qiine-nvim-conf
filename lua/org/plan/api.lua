
-- org plan api

local M = {}


M.plandir = vim.fn.expand("~/Personal/Org/Plan/.dstask/")


---@return boolean status, string msg
function M.task_add(tittle)
    if not tittle then return false, "err, no task tittle" end

    local cmd = {"dstask", "start", tittle}
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

---@return boolean ok, string msg
function M.task_rm(id)
    local cmd = {"dstask", "remove", id}
    local dstsk = vim.system(cmd, {text=true}):wait()
    if dstsk.code ~= 0 then
        return false, "Failed to rm "..id.."\n"..dstsk.stderr
    end

    return true, "Task rm "..id
end

---@param status string
function M.task_set_status(status, id)
    if not id then return false, "err, no task id" end

    local statuses = {
        ["active"]   = "start",
        ["paused"]   = "stop",
        ["resolved"] = "done"
    }

    local cmd = {"dstask", statuses[status], id}
    local dstsk = vim.system(cmd, {text=true}):wait()
    if dstsk.code ~= 0 then return false, dstsk.stderr end

    return true, "Set "..status.." id:"..id
end


---@return table|nil data, string|nil raw
function M.gather_tasks_db()
    local cmd = {"dstask", "show-open"}
    local dstsk = vim.system(cmd, {text=true}):wait()
    local data = vim.json.decode(dstsk.stdout)
    local raw = dstsk.stdout

    return data, raw
end

---@return table
function M.get_tasksfiles()
    return vim.fs.find(
        function(name, path)
            return not path:match("/%.git/") and name:match("%.yml")
        end, { path = M.plandir, type = "file", limit = math.huge}
    )
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

function M.task_picker()
    require("fzf-lua").task = function()
        if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end

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
    require("fzf-lua").task()
end

function M.plan_grep()
    require("fzf-lua").live_grep({
        winopts = { title = "Grep Tasks" },
        -- rg_opts = "--hidden --glob '!.git/*'",
        cwd = M.plandir,
    })
end


-----
return M

