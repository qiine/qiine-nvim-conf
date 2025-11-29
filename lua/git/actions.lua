
local u = require("git.utils")

local M = {}

function M.print_gitroot_dir()
    print(u.search_gitroot(vim.fn.getcwd()))
end

---@param fpath string
---@param silent? boolean
function M.add_file(fpath, silent)
    if not fpath or fpath == "" or vim.fn.filereadable(fpath) == 0 then
        return vim.notify("git add failed, file invalid!", vim.log.levels.ERROR)
    end
    silent = silent and silent or false

    vim.cmd("silent !git add "..fpath)

    if not silent then vim.notify("git add "..fpath, vim.log.levels.INFO) end
end

function M.add_all_repo()
    vim.cmd("silent !git add -A")
    vim.notify("git add all repo", vim.log.levels.INFO)
end

function M.unstaged_file()
    vim.cmd("silent !git reset %")
    vim.notify("git unstaged "..vim.fn.expand("%:p"), vim.log.levels.INFO)
end



--------
return M


