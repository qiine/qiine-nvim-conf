
-- ai


local win = require("ui.win")
local ed = require("ed")


local M = {}

local modelspath = vim.fn.expand("~/Personal/Assets/AI/Models/llms")

---@return table
function M.answer(prompt)
    prompt = prompt or ""

    local ai_res = vim.system({"pi", "--tools", "read,ls,grep,find", prompt}, {text=true}):wait()
    if ai_res.code ~= 0 then vim.notify("AI error: "..ai_res.stderr, vim.log.levels.ERROR) return "" end

    return vim.split(vim.trim(ai_res.stdout), "\n")
end

function M.answer_win(answer)
    -- ai buf
    local ai_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[ai_buf].buftype = "nofile"
    vim.bo[ai_buf].bufhidden  = "wipe"
    vim.bo[ai_buf].modifiable = true
    vim.bo[ai_buf].filetype = "markdown"

    -- Fill ai text
    vim.api.nvim_buf_set_lines(ai_buf, 1, -1, false, answer)

    -- ai win
    win.fwin_open(ai_buf, true, {title="AI answer"})
    vim.opt_local.number = false
end

function M.prompt_intr()
    vim.ui.input({prompt="Prompt: ", default=""}, function(input)
        vim.cmd("redraw") -- clear init prompt
        if input == nil then vim.notify("AI canceled.", vim.log.levels.INFO) return end

        M.anwser_win(M.answer(input))
    end)
end



-- Setup
function M.setup(opts)
    require("ai.keymaps")
    require("ai.commands")
end


--------
return M
