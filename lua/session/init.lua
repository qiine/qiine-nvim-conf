--------------------------------------------------------------------------------
-- session --
--------------------------------------------------------------------------------

local M = {}

-- Global Session loc: "~/.local/share/nvim/session_global.vim"
M.globalses_path = vim.fn.stdpath("data").."/session_global.vim"
M.localses_path = vim.fn.getcwd().."/session_local.vim"


function M.save(scope)
    vim.cmd("argdelete")
    vim.cmd("mksession! "..M.globalses_path) -- "!" use force
end

function M.load(scope)
    -- print("Loading last global session")
    -- vim.cmd("silent! source "..api.session_path_global)
    vim.cmd("source "..M.globalses_path)
end

-- clean session
function M.clean(session)
    -- filter missing files
    local safe_buf = {}

    for line in io.lines(session) do
        local filepath = line:match("badd%s+[^%s]+%s+(.*)")
        if filepath then
            if vim.fn.filereadable(filepath) == 1 then
                table.insert(safe_buf, line)
            else
                --nofile
            end
        else
            table.insert(safe_buf, line)
        end
    end

    -- Rewrite the session file
    local f = io.open(session, "w")
    if f then
        for _, line in ipairs(safe_buf) do
            f:write(line .. "\n")
        end
        f:close()
    else
        return --fail
    end
end


function M.setup()
    require("session.options")
    require("session.commands")
    require("session.autocmds")
end


--------
return M

