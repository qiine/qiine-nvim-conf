
-- # git


local U    = require("git.utils")
local win  = require("ui.win")
local term = require("term")


local M = {}


-- ## [Staging]
----------------------------------------------------------------------
---@param fpath? string
function M.add_file(fpath)
    fpath = fpath and fpath or vim.fn.expand("%:p")

    if vim.fn.filereadable(fpath) == 0 then
        return vim.notify("git add failed, file invalid!", vim.log.levels.ERROR)
    end

    vim.cmd("silent !git add "..fpath)
    vim.notify("git add "..fpath, vim.log.levels.INFO)
end

function M.add_all()
    vim.cmd("silent !git add -A")
    vim.notify("git add all repo", vim.log.levels.INFO)
end

function M.unstage_file()
    vim.cmd("silent !git reset %")
    vim.notify("git unstaged "..vim.fn.expand("%:p"), vim.log.levels.INFO)
end

function M.unstage_all()
    local groot = U.find_gitroot_cwd()

    local res_unst = vim.system({"git", "reset"}, {cwd=groot, text=true}):wait()
    if res_unst.code ~= 0 then vim.notify(res_unst.stderr, vim.log.levels.ERROR) return end

    vim.notify("git unstaged all, in: "..'"'..groot..'"', vim.log.levels.INFO)
end

---@param msg string?
function M.commit_curr(msg)
    local fp   = vim.fn.expand("%:p")
    local fdir = vim.fn.expand("%:p:h")

    term.open_fwin(nil, {
        title = "Commit file",
        wratio = 0.85, hratio = 0.75,
    }, "bash --norc")

    vim.api.nvim_chan_send(vim.b.terminal_job_id, "cd "..fdir.."\n")
    vim.api.nvim_chan_send(vim.b.terminal_job_id, "git add "..fp.."\n")
    vim.api.nvim_chan_send(vim.b.terminal_job_id, "git commit -ov "..fp.."\n")
end


-- ## [log]
function M.print_gitroot_dir()
    print(U.find_gitroot_cwd())
end

function M.print_porcelainstatus(paths)
    print(U.get_path_porcelainstatus(paths))
end

function M.log_history()
    local res_groot = vim.system({"git", "rev-parse", "--show-toplevel"}, {cwd=vim.fn.getcwd(), text=true}):wait()
    local groot = vim.trim(res_groot.stdout)

    local cmd = {
        "git", "log",
        "--graph", "--pretty=format:[%ad] %s (%an)", "--date=short", "--name-status",
    }

    local res_gith = vim.system(cmd, {cwd=vim.fn.getcwd(), text=true}):wait()
    if res_gith.code ~= 0 then vim.notify(res_gith.stderr, vim.log.levels.ERROR) return end
    local lines = vim.split(vim.trim(res_gith.stdout), "\n")

    local lines_edit = {}
    for i, line in ipairs(lines) do
        if line:match("^|") then
            -- extract status + path
            local status, path = line:match("^|%s*(%u)%s+(.+)$")

            if status and path then
                local new_path = groot.."/"..path
                lines_edit[i] = status.." "..new_path
            else
                lines_edit[i] = line
            end
        else
            lines_edit[i] = line
        end
    end

    vim.cmd("tabnew Git-History")
    vim.bo[0].buftype = "nofile"
    vim.bo[0].filetype = "githistory"

    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines_edit)
end



-- [Setup]
----------------------------------------------------------------------
function M.setup()
    require("git.commands")
    require("git.keymaps")
end


M.utl = U
--------
return M



