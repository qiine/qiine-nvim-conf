
-- # Commands

local api = require("git")
local u = require("utils")


vim.api.nvim_create_user_command("GitUnstageAll", api.unstage_all, {})


-- ## [Logging]
----------------------------------------------------------------------
vim.api.nvim_create_user_command("GitPrintRoot", function()
    print(vim.fn.systemlist("git rev-parse --show-toplevel")[1])
end, {})

vim.api.nvim_create_user_command("GitHistory", api.log_history, {})


vim.api.nvim_create_user_command("GitLogFileSplit", function()
    local fp =  vim.fn.expand("%:p")

    vim.cmd("vs | term dash")

    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = 0 })
    vim.api.nvim_set_option_value("buflisted", false,  { buf = 0 })

    vim.api.nvim_chan_send(vim.b.terminal_job_id, "git log HEAD "..fp.."\n")
end, {})


