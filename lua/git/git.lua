
local gu = require("git.utils")

local M = {}

function M.print_gitroot_dir()
    print(gu.search_gitroot(vim.fn.getcwd()))
end


-- ### [Staging]
---@param fpath? string
function M.add_file(fpath)
    fpath = fpath and fpath or vim.fn.expand("%:p")

    if vim.fn.filereadable(fpath) == 0 then
        return vim.notify("git add failed, file invalid!", vim.log.levels.ERROR)
    end

    vim.cmd("silent !git add "..fpath)

    vim.notify("git add "..fpath, vim.log.levels.INFO)
end

function M.add_all_repo()
    vim.cmd("silent !git add -A")
    vim.notify("git add all repo", vim.log.levels.INFO)
end

function M.unstage_file()
    vim.cmd("silent !git reset %")
    vim.notify("git unstaged "..vim.fn.expand("%:p"), vim.log.levels.INFO)
end

function M.unstage_all_repo()
    vim.cmd("silent !git reset")
    vim.notify("git unstaged all", vim.log.levels.INFO)
end



--------
return M


