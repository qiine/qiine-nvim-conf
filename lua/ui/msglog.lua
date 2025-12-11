
-- msglog --

local M = {}

function M.toggle()
    if vim.fn.expand("%:t") == "msglog" then vim.cmd("bwipeout") return end

    local cmdoutput = vim.fn.execute('messages')

    vim.cmd("split | e msglog")

    vim.api.nvim_win_set_height(0, 14)

    vim.opt_local.spell      = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.foldcolumn = "0"

    vim.api.nvim_set_option_value("buftype", "nofile", {buf=0})
    vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
    vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})
    vim.api.nvim_set_option_value("filetype", "log", {buf=0})
    -- vim.api.nvim_set_option_value("modifiable", false, {buf=0})

    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(cmdoutput, '\n'))

    vim.cmd("stopinsert")
    vim.cmd("norm! G")
end


--------
return M
