
-- # Sessions options

vim.opt.sessionoptions = {
    "curdir",
    --"blank",  	-- empty windows
    "buffers",   -- hidden and unloaded buffers, not just those in windows
    "tabpages",  -- all tab pages; without this only the current tab page is restored
    --"terminal",
    -- "folds",     -- manually created folds, opened/closed folds and local fold options
    --"globals",    -- global variables that start with an uppercase letter and contain at least one lowercase letter.
                    -- Only String and Number types are stored.
    --"options",     -- all options and mappings (also global values for local options)
    --"localoptions"  -- options and mappings local to a window or buffer (not global values for local options)
    "winsize",
    --"resizes",	-- size of the Vim window: 'lines' and 'columns'
    --"winpos",	 -- position of the whole Vim window
    --"help",	 -- the help window
    --"skiprtp",	-- exclude 'runtimepath' and 'packpath' from the options
    --"sesdir", 	-- the dir in which the session file is stored will become the current dir
}

