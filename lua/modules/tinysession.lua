
-- Session management --

--Session loc: "~/.local/share/nvim/global_session.vim"
GLOBAL_SESSION = vim.fn.stdpath("data") .. "/global_session.vim"

--Session setings
vim.opt.sessionoptions = {
    "curdir",
    --"blank"	empty windows
    "buffers", --hidden and unloaded buffers, not just those in windows
    "tabpages", --all tab pages; without this only the current tab page is restored
    "terminal",
    "folds", --manually created folds, opened/closed folds and local fold options
    --"globals"	global variables that start with an uppercase letter and contain at least one lowercase letter.  Only String and Number types are stored.
    --"options"	all options and mappings (also global values for local options)
    --"localoptions"	options and mappings local to a window or buffer (not global values for local options)
    "winsize",
    --"resize"	size of the Vim window: 'lines' and 'columns'
    --"winpos"	position of the whole Vim window
    --"help"	the help window
    --"skiprtp"	exclude 'runtimepath' and 'packpath' from the options
    --"sesdir"	the dir in which the session file is stored will become the current dir
}

--create/save session
vim.api.nvim_create_user_command("SaveGlobalSession", function()
    vim.cmd("mksession! " .. GLOBAL_SESSION)
    print("global session saved: " .. GLOBAL_SESSION)
end, {})

--edit global session file
vim.api.nvim_create_user_command("EditGlobalSession", function()
    vim.cmd("e "..GLOBAL_SESSION)
end, {})

--Load session
vim.api.nvim_create_user_command("LoadGlobalSession", function()
    if vim.fn.filereadable(GLOBAL_SESSION) == 1 then
        vim.cmd("silent! source " .. GLOBAL_SESSION)
        print("loading global session: " .. GLOBAL_SESSION)
    else
        print("No global session file found.")
    end
end, {})


vim.api.nvim_create_augroup('TinySession', { clear = true })

--Smart auto save session
vim.api.nvim_create_autocmd({"BufAdd","BufDelete","VimLeavePre"}, {
    group = 'TinySession',
    pattern = '*',
    callback = function()
        vim.cmd("mksession! " .. GLOBAL_SESSION)
    end,
})



