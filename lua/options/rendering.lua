
-- # Rendering


vim.o.updatetime = 150 --screen redraw speed in ms


--v.opt.lazyredraw  = true  -- will scroll the view when moving the cursor
-- Allow scrolling beyond the end of the file
vim.o.scrolloff     = 0
vim.o.sidescrolloff = 5
--v.o.sidescroll = 1


-- Shortmess
vim.o.shortmess = "astFTIcC"
--l  use "999L, 888B" instead of "999 lines, 888 bytes"
--m  use "[+]" instead of "[Modified]"
--r  use "[RO]" instead of "[readonly]"
--w  use "[w]" instead of "written" for file write message
--  and "[a]" instead of "appended" for ':w >> file' command
--a  all of the above abbreviations

--o  overwrite message for writing a file with subsequent
--  message for reading a file (useful for ":wn" or when
-- 'autowrite' on)
--O  message for reading a file overwrites any previous
--  message;  also for quickfix message (e.g., ":cn")
--t  truncate file message at the start if it is too long
--  to fit on the command-line, "<" will appear in the left most
--  column; ignored in Ex mode
--T  truncate other messages in the middle if they are too
--  long to fit on the command line; "..." will appear in the
--  middle; ignored in Ex mode
--W  don't give "written" or "[w]" when writing a file
--A  don't give the "ATTENTION" message when an existing swap file is found
--I  don't give the intro message when starting Vim
--c  don't give |ins-completion-menu| messages; for
--  example, "-- XXX completion (YYY)", "match 1 of 2", "The only
--  match", "Pattern not found", "Back at original", etc.
--C  don't give messages while scanning for ins-completion  *shm-C*
--  items, for instance "scanning tags"
--q  do not show "recording @a" when recording a macro  *shm-q*
--F  don't give the file info when editing a file, like
--  `:silent` was <used for the command; note that this also
--  affects messages from 'autoread' reloading

--s  don't give "search hit BOTTOM, continuing at TOP" or
--  "search hit TOP, continuing at BOTTOM" messages; when using
--  the search count do not show "W" before the count message
--S  do not show search count message when searching, e.g.
--  "[1/5]". When the "S" flag is not present (e.g. search count
--  is shown), the "search hit BOTTOM, continuing at TOP" and
--  "search hit TOP, continuing at BOTTOM" messages are only
--  indicated by a "W" (Mnemonic: Wrapped) letter before the
--  search count statistics.


-- -- -- clear highlight when moving
-- vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
--     group = "UserAutoCmds",
--     callback = function()
--         -- vim.lsp.buf.clear_references()
--         -- vim.opt.hlsearch = false
--     end,
-- })


-- Fix term and nvim bg missmatch
local aug = vim.api.nvim_create_augroup("TermbgSync", { clear = true })

local has_tty = false
for _, ui in ipairs(vim.api.nvim_list_uis()) do
    if ui.stdout_tty then
        has_tty = true; break
    end
end

-- crude skip very dumb terminals
local term = vim.env.TERM or ""
local dumbterm = term == "dumb" or term == ""

if has_tty and not dumbterm then
    local function sync()
        local ok, normal = pcall(vim.api.nvim_get_hl, 0, { name = "Normal" })
        if not ok or not normal.bg then return end
        io.stdout:write(string.format("\027]11;#%06x\007", normal.bg))
    end

    vim.api.nvim_create_autocmd({ "UIEnter", "ColorScheme", "VimResume" }, {
        group = aug,
        callback = sync,
    })

    vim.api.nvim_create_autocmd({"VimLeavePre", "VimSuspend" }, {
        group = aug,
        callback = function()
            io.stdout:write("\027]111\027\\") -- safe reset, ignored if unsupported
        end,
    })
end




