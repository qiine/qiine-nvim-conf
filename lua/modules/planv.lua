
-- PLANV --

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
--------------------

M.states = {
    pv_buf = nil,
    pv_win = nil,
}

M.task_template = {
    id = 0,
    title = "",
    active = true,
    completed = false,
    priority = 0,
    desc = "",
    tags = {},
    creation_time = "",
    due_date = "",
}

M.tasks_active = {}

M.tasks_backlog = {}

M.task_completed = {}

function M.task_add()
    local task = vim.deepcopy(M.task_template)

    local id = #M.tasks_active + 1
    task.id = id
    task.title = "Newtask".. id
    task.date = os.date("%Y-%m-%d %H:%M")

    table.insert(M.tasks_active, task)
end


function M.task_edit()
    vim.cmd("startinsert")
end

function M.task_delete(task_id)
    table.remove(M.tasks_active, task_id)
end


local function render_task(task)
    local status = task.completed and "[x]" or "[ ]"
    return string.format("%s %s (prio:%d)", status, task.title, task.priority)
end

-- Re-render all tasks in the buffer
function M.render()
    local lines = {}
    for _, task in ipairs(M.tasks_active) do
        table.insert(lines, render_task(task))
    end

    table.insert(lines, 1, "[Active tasks]")

    vim.api.nvim_buf_set_lines(M.states.pv_buf, 0, -1, false, lines)
end

function M.open_window_float()
    M.states.pv_buf = vim.api.nvim_create_buf(false, true)

    local vimwin_w = vim.o.columns
    local vimwin_h = vim.o.lines

    local fwsize = {w = 66, h = 22}

    local fwopts = {
        title     = "planv",
        title_pos = "center",

        relative = "editor",
        border   = "single",

        width  = fwsize.w,
        height = fwsize.h,
        col = math.floor((vimwin_w - fwsize.w) / 2),
        row = math.floor((vimwin_h - fwsize.h) / 2),
    }

    M.states.pv_win = vim.api.nvim_open_win(M.states.pv_buf, true, fwopts)

    vim.opt_local.statuscolumn = ""
    vim.opt_local.signcolumn   = "no"
    vim.opt_local.number       = false
    vim.opt_local.foldcolumn   = "0"

    -- vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
    vim.api.nvim_set_option_value("buflisted", false,  { buf = M.states.pv_buf })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = M.states.pv_buf })

    M.render()

    -- Mapping
    vim.keymap.set("n", "n", function()
        M.task_add()
        M.render()
    end, {buffer=M.states.pv_buf, noremap=true})

    vim.keymap.set("n", "e", function()
        M.task_edit()
        M.render()
    end, {buffer=M.states.pv_buf, noremap=true})

    vim.keymap.set("n", "d", function()
        M.task_delete()
        M.render()
    end, {buffer=M.states.pv_buf, noremap=true})
end

vim.api.nvim_create_user_command("Planv", function()
    M.open_window_float()
end, {})


-- UI
function _G.foldexpr_planv()
    local line = vim.fn.getline(vim.v.lnum)

    if line:match("^%- ") then return ">1" end

    -- if line:match("^%s*$") then return "0" end
    if line:match("^---") then return "0" end
    if line:match("^──") then return "0" end

    return "="
end


--------------------
return M

