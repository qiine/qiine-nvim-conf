
-- git --

local gu   = require("git.utils")
local win  = require("ui.win")
local term = require("term")

local M = {}

function M.print_gitroot_dir()
    print(gu.find_gitroot(vim.fn.getcwd()))
end


-- ## [Staging]
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

function M.log_pretty()
    local repname = gu.find_gitroot_cwd()

    term.open_fwin(nil, {
        title = "git log: "..repname,
        wratio = 0.95, hratio = 0.85,
    }, "dash")

    local cmd = "git log --graph --decorate --pretty=oneline --abbrev-commit --all"

    vim.api.nvim_chan_send(vim.b.terminal_job_id, cmd.."\n")

    vim.cmd("stopinsert")
end



--------
return M



