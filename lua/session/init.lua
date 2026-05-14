--------------------------------------------------------------------------------
-- session --
--------------------------------------------------------------------------------

local M = {}

-- Global Session loc: "~/.local/share/nvim/session_global.vim"
M.globalsess_path = vim.fn.stdpath("data").."/session_global.vim"
M.localsess_path = vim.fn.getcwd().."/session_local.vim"


function M.save(scope)
    vim.cmd("%argdelete") -- clear arglist, no other way to filter for now
    vim.cmd("mksession! "..M.globalsess_path) -- "!" use force
end

function M.load(scope)
    local saved_modelines = vim.o.modelines

    vim.o.modelines = 0

    local ok, err = pcall(function()
        vim.cmd("source " .. M.globalsess_path)
    end)

    vim.o.modelines = saved_modelines

    if not ok then
        vim.notify("Failed to source session: "..tostring(err))
    end
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

