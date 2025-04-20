-- Create a project overview scratch buffer that concatenates all project files
-- Usage: call
-- lua require('modules.rouleau-nvim').show()

local M = {}

function M.get_all_files(dir, files)
    local handle = vim.loop.fs_scandir(dir)
    if not handle then return files end

    while true do
        local name, type = vim.loop.fs_scandir_next(handle)
        if not name then break end

        local full_path = dir .. "/" .. name
        if type == "file" then
            table.insert(files, full_path)
        elseif type == "directory" and name ~= ".git" then
            M.get_all_files(full_path, files)
        end
    end
    return files
end

function M.show()
    local cwd = vim.fn.getcwd()
    local files = M.get_all_files(cwd, {})

    local lines = {}
    for _, file in ipairs(files) do
        table.insert(lines, string.rep("=", 80))
        table.insert(lines, "-- " .. file)
        table.insert(lines, string.rep("=", 80))
        local f = io.open(file, "r")
        if f then
            for line in f:lines() do
                table.insert(lines, line)
            end
            f:close()
            table.insert(lines, "")
        end
    end

    vim.cmd("enew")
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.swapfile = false
    vim.bo.filetype = "rouleau"

    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

return M

