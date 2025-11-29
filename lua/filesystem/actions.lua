
local M = {}

function M.append_select_to_file()
    vim.ui.input({prompt="Append selected to: ", default=vim.fn.getcwd(), completion="file"},
    function(input)
        if input == nil then vim.notify("Append canceled. ", vim.log.levels.INFO) return end

        vim.cmd("norm! ")
        local lines = vim.fn.getline("'<","'>")
        vim.fn.writefile(lines, input, "a")
    end)
end

function M.move_select_to_file()
    vim.ui.input({prompt="Move selected to: ", default=vim.fn.getcwd(), completion="file"},
    function(input)
        if input == nil then vim.notify("Move canceled. ", vim.log.levels.INFO) return end

        vim.cmd("norm! ")
        local lines = vim.fn.getline("'<","'>")
        vim.cmd("norm! gvd")
        vim.fn.writefile(lines, input, "a")
    end)
end



--------
return M




