
local M = {}

---@param searchdir string
---@return string
function M.search_gitroot(searchdir)
    local res = vim.system({"git", "rev-parse", "--show-toplevel"}, {cwd=searchdir, text=true}):wait()
    return vim.trim(res.stdout)
end

---@param path string
---@param gitroot string
---@return string
function M.make_path_gitroot_rel(path, gitroot)
    return path:sub(#gitroot + 2)
end

--------
return M
