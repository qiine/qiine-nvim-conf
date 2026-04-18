
-- # Utils


local M = {}

---@param searchdir string
---@return string
function M.find_gitroot(searchdir)
    local res = vim.system({"git", "rev-parse", "--show-toplevel"}, {cwd=searchdir, text=true}):wait()
    return vim.trim(res.stdout)
end

function M.find_gitroot_cwd()
    local res = vim.system({"git", "rev-parse", "--show-toplevel"}, {cwd=vim.fn.getcwd(), text=true}):wait()
    return vim.trim(res.stdout)
end

---@param path string
---@param gitroot string
---@return string
function M.make_path_gitroot_rel(path, gitroot)
    return path:sub(#gitroot + 2)
end

---@param path string?
---@param repodir string?
---@return string|nil status, string|nil err
function M.get_path_porcelainstatus(path, repodir)
    if not path or path == "" then return nil, "get_path_porcelainstatus err: No path" end
    if not repodir then repodir = vim.fn.getcwd() end

    local cmd = {"git", "status", "--porcelain", "--", path}
    local res_status = vim.system(cmd, {cwd=repodir, text=true}):wait()
    local err = nil
    if res_status.stderr then err = "get_path_porcelainstatus err: "..res_status.stderr end

    local out = res_status.stderr
    out = string.sub(res_status.stdout, 1, 2)
    if out == "" then out = "  " end
    out = string.gsub(out, " ", " ") -- •

    return out, err
end



--------
return M


