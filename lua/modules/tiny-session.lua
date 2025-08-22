--------------------------------------------------------------------------------
-- tiny-session --
--------------------------------------------------------------------------------

local M = {}

--Global Session loc: "~/.local/share/nvim/global_session.vim"
GLOBAL_SESSION = vim.fn.stdpath("data") .. "/global_session.vim"

--nvim session setings
vim.opt.sessionoptions = {
    "curdir",
    --"blank",  	--empty windows
    --"buffers",   --hidden and unloaded buffers, not just those in windows
    "tabpages",  --all tab pages; without this only the current tab page is restored
    --"terminal",
    "folds",     --manually created folds, opened/closed folds and local fold options
    --"globals",	--global variables that start with an uppercase letter and contain at least one lowercase letter.  Only String and Number types are stored.
    --"options",	--all options and mappings (also global values for local options)
    --"localoptions"	--options and mappings local to a window or buffer (not global values for local options)
    "winsize",
    --"resizes",	--size of the Vim window: 'lines' and 'columns'
    --"winpos",	 --position of the whole Vim window
    --"help",	 --the help window
    --"skiprtp",	--exclude 'runtimepath' and 'packpath' from the options
    --"sesdir", 	--the dir in which the session file is stored will become the current dir
}

--clean session
function M.session_clean(session)
    --filter missing files
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


function M.globalsession_save()
    if vim.fn.win_gettype() == "command" then return end  --mksession not allowed in cmdline
    vim.cmd("mksession! " .. GLOBAL_SESSION)
    --M.session_clear_hiddenbufs(GLOBAL_SESSION)
end

--cmd create/save session
vim.api.nvim_create_user_command("SaveGlobalSession", function()
    M.globalsession_save()
    --print("global session saved: " .. GLOBAL_SESSION)
end, {})

--edit global session file
vim.api.nvim_create_user_command("EditGlobalSession", function()
    vim.cmd("e "..GLOBAL_SESSION)
end, {})

--Load session
vim.api.nvim_create_user_command("LoadGlobalSession", function()
    --vim.cmd("silent! source " .. GLOBAL_SESSION)
    print("Loading last global session")
    vim.cmd("source " .. GLOBAL_SESSION)
end, {})

--Flush global session file
vim.api.nvim_create_user_command("DeleteGlobalSession", function()
    vim.fn.delete(GLOBAL_SESSION)
    print('Global session: "'..GLOBAL_SESSION..'" deleted')
end, {})


vim.api.nvim_create_augroup('TinySession', { clear = true })

--Smart auto save session
--vim.api.nvim_create_autocmd({"BufAdd","BufDelete", "DirChanged", "VimLeavePre"}, {
vim.api.nvim_create_autocmd({"VimLeavePre"}, {
    group = 'TinySession',
    pattern = '*',
    callback = function()
        M.globalsession_save()
    end,
})



