
-- # org notes


local fs = require("fs")


local M = {}


M.notespath = vim.fn.expand("~/Personal/Org/Notes")


---@return boolean
function M.is_in_note_repo()
    local repopath = fs.utils.find_proj_rootdir_for_path(vim.fn.getcwd())
    return M.notespath == repopath
end

---@param name? string
---@param dir? string
---@return string|nil notepath, string msg
function M.create(name, dir)
    if not name or name == "" then name = "Newnote" end
    dir = dir and dir or M.notespath

    local fpath = vim.fs.normalize(dir.."/"..name..".md")
    if vim.uv.fs_stat(fpath) then return nil, "Note with same name already exist!" end

    local lines = vim.fn.readfile(vim.fn.stdpath("config").."/snippets/markdown.json")
    local snippets = vim.fn.json_decode(table.concat(lines, "\n"))
    local snippet  = snippets["note template"]
    local body = vim.deepcopy(snippet.body)
    for i, line in ipairs(body) do
        body[i] = line:gsub("%${1:.-}", name)
    end

    local ok = vim.fn.writefile(body, fpath) -- create and write note
    if not ok then return nil, "Note creation failed" end

    return fpath, "Note created: "..fpath
end

function M.create_intr()
    vim.ui.input({prompt="Note name: ", default="", completion="file"},
    function(input)
        vim.api.nvim_command("redraw") -- Hide prompt
        if input == nil then vim.notify("Note creation canceled. ", vim.log.levels.INFO) return end

        -- If in note repo, create in cwd, handy
        local notedir = M.is_in_note_repo() and vim.fn.getcwd() or nil

        local fpath, msg = M.create(input, notedir)
        if not fpath then vim.notify(msg, vim.log.levels.ERROR); return end

        vim.cmd("e "..fpath); vim.cmd("norm! 6j"); vim.cmd("startinsert")  -- open it

        vim.notify(msg, vim.log.levels.INFO)
    end)
end


function M.explore()
    vim.cmd("Oil "..M.notespath)
end


-- Setup
function M.setup()
    require("org.notes.commands")
    require("org.notes.keymaps")
end


--------
return M
