
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


M.plandir = "~/Personal/Org/Plan/"


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

function M.overview_show()
    vim.cmd("tabnew")
    vim.api.nvim_buf_set_name(0, "Plan")

    local cmd = {"dstask", "show-open"}
    local dstsk = vim.system(cmd, {text=true}):wait()
    local tasks = vim.json.decode(dstsk.stdout)

    local summaries = {}
    for _, t in ipairs(tasks) do
        summaries[#summaries + 1] = "□ "..t.summary.." ".."("..t.id..")"
    end
    -- local out = vim.split(dstsk.stdout, "\n", {plain=true})
    local out = summaries

    vim.opt_local.number = false
    local planbuf = vim.api.nvim_get_current_buf()

    -- vim.wo.foldlevel=0
    -- vim.opt_local.foldmethod="expr"
    -- vim.opt_local.foldexpr='v:lua.foldexpr_planv()'

    vim.bo[planbuf].buftype = "nofile"
    -- vim.bo[planbuf].filetype = "markdown"
    vim.bo[planbuf].modifiable = true

    local heading = {
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
        "■ Tasks",
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    }
    vim.api.nvim_buf_set_lines(0, 0, -1, false, heading)
    vim.api.nvim_buf_set_lines(0, -1, -1, false, out)
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


