
-- # Plan

-- PLANV
-- leplan
-- planv
-- petitplan
-- todoer
-- qtask
-- speedplan
-- speedtask
-- planist
-- taskel
-- tasklet


local M = {}


M.plandir = vim.fn.expand("~/Personal/Org/Plan/")


function M.task_add(tittle)
    local cmd = {"dstask", "add", tittle}
    local dstsk = vim.system(cmd, {text=true}):wait()
end

function M.task_add_intr()
    vim.ui.input({prompt="Task: ", default=""},
    function(input)
        vim.api.nvim_command("redraw") --Hide prompt
        if input == nil then vim.notify("Task creation canceled.", vim.log.levels.INFO) return end

        local cmd = {"dstask", "add", input}
        local dstsk = vim.system(cmd, {text=true}):wait()
        if dstsk.code ~= 0 then vim.notify(dstsk.stderr, vim.log.levels.INFO) end

        vim.notify("Task created: "..input, vim.log.levels.INFO)
    end)
end

function M.task_rm(id)
    local cmd = {"dstask", "remove", id}
    local dstsk = vim.system(cmd, {text=true}):wait()
end

---@return table|nil data, string|nil raw
function M.gather_tasks_data()
    local cmd = {"dstask", "show-open"}
    local dstsk = vim.system(cmd, {text=true}):wait()
    local data = vim.json.decode(dstsk.stdout)
    local raw = dstsk.stdout

    return data, raw
end

function M.debug_db()
    -- debug buf
    vim.cmd("tabnew")
    vim.api.nvim_buf_set_name(0, "Plan debug")

    local planbuf = vim.api.nvim_get_current_buf()

    -- vim.opt_local.number = true

    vim.bo[planbuf].buftype = "nofile"


    -- data
    local dat, raw = M.gather_tasks_data()

    if not raw then print("db err") return end

    local out = vim.split(raw, "\n")

    vim.bo[planbuf].modifiable = true
    vim.api.nvim_buf_set_lines(0, 0, 0, false, out)
    vim.bo[planbuf].modifiable = false
end

function M.overview_render()
    -- Header
    local heading = {
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
        "■ Tasks",
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    }

    -- Tasks
    local tasksdat = M.gather_tasks_data()
    tasksdat = tasksdat and tasksdat or {}

    local function insert_uniq(t, val)
        for _, v in ipairs(t) do
            if v == val then return end
        end
        table.insert(t, val)
    end

    local groups = {}
    local seen = {}

    -- for _, td in ipairs(tasksdat) do
    --     if td.project and td.project ~= "" then
    --         insert_uniq(groups, td.project)
    --     end
    -- end
    -- table.insert(groups, "ungrouped")

    for _, td in ipairs(tasksdat) do
        local proj = (td.project and td.project ~= "") and td.project or "ungrouped"
        if not seen[proj] then
            seen[proj] = true
            table.insert(groups, proj)
        end
    end

    local out = {}
    -- Head
    for _, line in ipairs(heading) do
        table.insert(out, line)
    end

    -- Tasks
    for _, group in ipairs(groups) do
        table.insert(out, "## "..group)

        for _, td in ipairs(tasksdat) do
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
            end
        end
        table.insert(out, "")
    end

    vim.api.nvim_buf_set_lines(0, 0, -1, false, out)
end

function M.overview_show()
    vim.cmd("tabnew")
    vim.api.nvim_buf_set_name(0, "Plan")

    vim.opt_local.number = false
    local planbuf = vim.api.nvim_get_current_buf()

    -- vim.wo.foldlevel=0
    -- vim.opt_local.foldmethod="expr"
    -- vim.opt_local.foldexpr='v:lua.foldexpr_planv()'

    vim.bo[planbuf].buftype = "nofile"
    -- vim.bo[planbuf].filetype = "markdown"
    vim.bo[planbuf].modifiable = true

    M.overview_render()

    vim.keymap.set({"i","n","v"}, "<F5>", function()
        M.overview_render()
    end, {buffer=true})
end



-- ## Setup
----------------------------------------------------------------------
function M.setup()
    function _G.foldexpr_planv()
        local line = vim.fn.getline(vim.v.lnum)

        if line:match("^-") then return ">1" end

        -- if line:match("^%s*$") then return "0" end
        if line:match("^---") then return "0" end
        if line:match("^──") then return "0" end
        if line:match("^━━") then return "0" end

        if line == "" then return "0" end

        return "="
    end



    require("org.plan.keymaps")
    require("org.plan.commands")
end


--------
return M


