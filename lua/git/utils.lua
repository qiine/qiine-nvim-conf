
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

---@param path string
---@param repodir string?
---@return string|nil out, string|nil err
function M.get_porcelainstatus(path, repodir)
    if not path or path == "" then return nil, "get_path_porcelainstatus err: No path" end
    path = vim.fs.normalize(vim.fn.expand(path))
    if path:sub(1, 1) ~= "/" then
        return nil, "get_path_porcelainstatus err: invalid path: "..path
    end

    if not repodir or repodir == "" then
        repodir = vim.fn.getcwd()
    else
        repodir = vim.fn.expand(repodir)
    end
    repodir = vim.fs.normalize(repodir)
    if repodir:sub(1, 1) ~= "/" then
        return nil, "get_path_porcelainstatus err: invalid repodir: "..repodir
    end

    -- Compute status
    local cmd = {"git", "status", "--porcelain", "--", path}
    local res_status = vim.system(cmd, {cwd=repodir, text=true}):wait()
    if res_status.code ~= 0 then
        local err = "get_path_porcelainstatus err: "..res_status.stderr
        return nil, err
    end

    local out = ""
    out = string.sub(res_status.stdout, 1, 2) -- XY  -- strip fpath
    out = string.gsub(out, " ", " ")  -- •  -- replace empty-string with smthng for clarity
    -- if res_status.stdout == "" then out = "" end

    return out, nil
end



--------
return M


