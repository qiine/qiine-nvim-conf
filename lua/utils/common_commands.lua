-------------------------
-- User commands --
-------------------------
local v = vim
local vapi = vim.api
local vcmd = vim.cmd

local utils = require("utils.utils")
-------------------------



vim.api.nvim_create_user_command("WorkDirToCurrent", function()
    vim.cmd("cd %:p:h") -- ":h" rem file name
end, {})

--Quick ressource curr
vim.api.nvim_create_user_command("RessourceCurrent", function()
    local currf = vim.fn.expand("%:p")
    vim.cmd("source " .. currf)
end, {})

--Restart nvim
vim.api.nvim_create_user_command("Restart", function()
    local curfile = vim.fn.expand("%:p") --Get curr file location
    local curdir = vim.fn.fnamemodify(curfile, ':p:h')

    vim.cmd("SaveGlobalSession")

    local sess = GLOBAL_SESSION
    vim.loop.spawn("wezterm", {
        --args = { "-e", "nvim", "--cmd", "cd " .. curdir, curfile },
        --cwd = curdir

        args = { "-e", "nvim", "-S", GLOBAL_SESSION },
    })
    vim.cmd("qa!")
end, {})

vim.api.nvim_create_user_command("RestartSafeMode", function()
    vim.fn.jobstart({ "nvim -u NONE" }, { detach = true })
    vim.cmd("qa!")
end, {})

--Easy lazy plug install
vim.api.nvim_create_user_command("PlugInstall", function(opts)
    local plug_dir = vim.fn.stdpath("config") .. "/lua/plugins/"

    local plug_url = opts.args
    plug_url = plug_url:gsub(",", "")
    plug_url = plug_url:gsub('"', "")
    plug_url = plug_url:gsub("'", "")

    --Check URL empty or malformed
    if plug_url == "" or not plug_url:match(".+/.+") then
        print("Invalid URL. Usage: :PlugInstall user/repo")
        return
    end

    --Extracting plug name
    local last_slash = plug_url:find("/[^/]*$")
    local plug_name = last_slash and plug_url:sub(last_slash + 1)
    --plug_name=plug_name:gsub('.', "-", 1)

    local plug_path = plug_dir .. plug_name .. ".lua"

    --Check if plugin already installed
    local file_exists = vim.loop.fs_stat(plug_path) ~= nil
    if file_exists then
        print("Plugin '" .. plug_name .. "' already installed.")
        return
    end

    --Creating the file
    local plug_content = 'return{ "' .. plug_url .. '", }'
    local file = io.open(plug_path, "w")
    if file then
        file:write(plug_content)
        file:close()
        print("Installing " .. plug_name .. " in " .. plug_path)
    else
        print("Failed to install" .. plug_name .. " hint: " .. plug_path)
    end
end, { nargs = 1 })

--TODO open help in separate tab
-- vim.api.nvim_create_user_command("H", function(opts)
-- vim.cmd("enew")
-- vim.cmd("setlocal buftype=help")
-- vim.cmd("help "..opts.args)
-- end, { nargs = "*" })

--insert today
vim.api.nvim_create_user_command("Today", function()
    local date = os.date("*t")
    local today = string.format("%04d/%02d/%02d %02d:%02d", date.year, date.month, date.day, date.hour, date.min)
    vim.api.nvim_put({ today }, "c", true, true)
end, {})



--## [Files]
----------------------------------------------------------------------
vim.api.nvim_create_user_command("CopyFileAbsolutePath", function()
    vim.cmd("let @+ = expand('%:p')")
    local apath = vim.fn.getreg("+")
    print("Copied path: " .. apath)
end, {})

vim.api.nvim_create_user_command("FilePicker", function()
    local handle = io.popen('kdialog --getopenfilename')
    if handle then
        local result = handle:read("*a")
        handle:close()
        local filepath = vim.fn.trim(result)
        if filepath ~= "" then
            vim.cmd("edit " .. vim.fn.fnameescape(filepath))
        end
    end
end, {})


vim.api.nvim_create_user_command("FileMove", function()
    local fpath = vim.api.nvim_buf_get_name(0)

    if vim.fn.filereadable(fpath) == 0 then
        vim.notify("No file to move", vim.log.levels.ERROR) return
    end

    local fname = vim.fn.fnamemodify(fpath, ":t")
    local fdir  = vim.fn.fnamemodify(fpath, ":h")

    vim.ui.input(
        {
            prompt     = "Move to dir: ",
            default    = fdir,
            completion = "shellcmd"
        },
        function(input)
            vim.api.nvim_command("redraw") --Hide prompt

            if input == nil or input == "" or input == fpath then
                vim.notify("Move cancelled.", vim.log.levels.INFO) return
            end

            --assemble path
            local target_path = input .. "/" .. fname

            local stat = vim.loop.fs_stat(target_path)
            if stat then
                vim.notify("Move failed: target file already exists", vim.log.levels.ERROR) return
            end

            local ok, err = vim.loop.fs_rename(fpath, target_path)
            if not ok then
                vim.notify("Move failed: " .. err, vim.log.levels.ERROR) return
            end

            --Reload buffer with new file
            vim.api.nvim_buf_set_name(0, target_path)
            vim.cmd("e!") --refresh buf to new path
            vim.notify("Moved to: " .. input, vim.log.levels.INFO)
        end
    )
end, {})

vim.api.nvim_create_user_command("FileRename", function()
    local old_filepath = vim.api.nvim_buf_get_name(0)

    if vim.fn.filereadable(old_filepath) == 0 then
        vim.notify("No file to rename", vim.log.levels.ERROR) return
    end

    local old_dir = vim.fn.fnamemodify(old_filepath, ":h")
    local old_name = vim.fn.fnamemodify(old_filepath, ":t")

    vim.ui.input(
        {
            prompt = "New name: ",
            default = old_name,
            completion = "file"
        },
        function(input)
            vim.api.nvim_command("redraw") --Hide prompt
            if input == nil or input == "" or input == old_name then
                vim.notify("Rename cancelled", vim.log.levels.INFO) return
            end

            local new_filepath = old_dir .. "/" .. input
            local ok, err = vim.loop.fs_rename(old_filepath, new_filepath)

            if not ok then
                vim.notify("Rename failed: " .. err, vim.log.levels.ERROR) return
            end

            -- Reload buffer with new file
            vim.api.nvim_buf_set_name(0, new_filepath)
            vim.cmd("e!") --refresh buf to new name
            vim.notify("Renamed to " .. input, vim.log.levels.INFO)
        end
    )
end, {})


--### File perms
vim.api.nvim_create_user_command("SetFileReadonly", function()
    local path = vim.api.nvim_buf_get_name(0)
    local name = vim.fn.fnamemodify(path, ":t")

    if path == "" then
        vim.notify("No file for current buffer", vim.log.levels.WARN) return
    end

    vim.bo.readonly = true  --optional refresh lualine
    local ok = os.execute("chmod -w " .. vim.fn.shellescape(path))

    if ok == 0 then
        vim.print(name .. " now readonly")
    else
        vim.notify("Failed to set file as readonly", vim.log.levels.ERROR)
    end
end, {})

vim.api.nvim_create_user_command("SetFileWritable", function()
    local path = vim.api.nvim_buf_get_name(0)
    local name = vim.fn.fnamemodify(path, ":t")

    if path == "" then
        vim.notify("No file for current buffer", vim.log.levels.ERROR) return
    end

    vim.bo.readonly = false  --optional refresh lualine
    local ok = os.execute("chmod +w " .. vim.fn.shellescape(path))

    if ok == 0 then
        vim.print(name .. " now writable")
    else
        vim.notify("Failed to set file as writable", vim.log.levels.ERROR)
    end
end, {})

vim.api.nvim_create_user_command("SetFileExecutable", function()
    local path = vim.api.nvim_buf_get_name(0)
    local name = vim.fn.fnamemodify(path, ":t")

    if path == "" then
        vim.notify("No file for current buffer", vim.log.levels.ERROR) return
    end

    local ok = os.execute("chmod +x " .. vim.fn.shellescape(path))

    if ok == 0 then
        vim.print(name .. " now executable")
    else
        vim.notify("Failed to set file as executable", vim.log.levels.ERROR)
    end
end, {})

vim.api.nvim_create_user_command("SetFileNotExecutable", function()
    local path = vim.api.nvim_buf_get_name(0)
    local name = vim.fn.fnamemodify(path, ":t")

    if path == "" then
        vim.notify("No file for current buffer", vim.log.levels.ERROR) return
    end

    local ok = os.execute("chmod -x " .. vim.fn.shellescape(path))

    if ok == 0 then
        vim.print(name .. " no longer executable")
    else
        vim.notify("Failed to remove executable flag", vim.log.levels.ERROR)
    end
end, {})


--Easy del files without file browser
vim.api.nvim_create_user_command("FileDelete", function()
    local fpath = vim.api.nvim_buf_get_name(0)

    if fpath == "" or vim.fn.filereadable(fpath) == 0 then
        vim.notify("No file to delete", vim.log.levels.ERROR) return
    end

    vim.loop.fs_unlink(fpath, function(err)
        if err then
            vim.schedule(function()
                vim.notify("Delete failed: " .. err, vim.log.levels.ERROR)
            end)
            return
        end

        vim.schedule(function()
            vim.cmd('bdelete!')
            vim.notify("Deleted: " .. fpath, vim.log.levels.INFO)
        end)
    end)
end, {})



--## [Editing]
--------------------------------------------------
--Trim select, include tab and break lines
vim.api.nvim_create_user_command("TrimSelectedWhitespaces", function(opts)
    vim.cmd(string.format("s/\\s//g"))
    vim.cmd("normal! <esc>")
end, { range = true })

vim.api.nvim_create_user_command("TrimCurrBufferTrailSpaces", function()
    local curpos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, curpos)
end, {})

--Append underline unicode character to each selected chars
vim.api.nvim_create_user_command("UnderlineSelected", function(opts)
    local start_line = opts.line1 - 1
    local end_line = opts.line2

    local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)

    local combining = '\u{0332}' --underline unicode
    local function underline(str)
        return str:gsub(".", function(c)
            -- avoid underlining newline or multibyte control chars
            return c:match("[%z\1-\127]") and c .. combining or c
        end)
    end

    for i, line in ipairs(lines) do
        lines[i] = underline(line)
    end

    vim.api.nvim_buf_set_lines(0, start_line, end_line, false, lines)
end, { range = true })

vim.api.nvim_create_user_command("ClearAllMarks", function()
    vim.cmd([[delmarks a-zA-Z0-9"<>'[].]])
    print("-All marks cleared-")
end, {desc = "Delete all marks in the current buffer"})

vim.api.nvim_create_user_command("CodeAction", function()
    require("tiny-code-action").code_action()
end, {})


--diff curr file with given rev
vim.api.nvim_create_user_command("DiffRevision", function(opts)
    --Process arg
    local rev = opts.args ~= "" and opts.args or "HEAD"

    local prev_workdir = vim.fn.getcwd()

    local filepath = vim.api.nvim_buf_get_name(0)
    local filename = vim.fn.expand("%:t")
    local filetype = vim.bo.filetype

    --pulling git data
    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
    vim.fn.chdir(git_root)
    local filepath_rootrelative = vim.fn.fnamemodify(filepath, ":.")

    local log_level = "-1"
    if rev:match("^HEAD~%d+$") then
        log_level = rev:match("%d+")
    end

    local git_metadata = vim.fn.systemlist(string.format("git log -1 %s -- %s", rev, filepath_rootrelative))
    local git_content = vim.fn.systemlist(string.format("git show '%s':%s", rev, filepath_rootrelative))

    print("shell_error after git show:", vim.v.shell_error)

    if vim.v.shell_error ~= 0 then
        vim.notify("Git revision or file not found: " .. rev .. ":" .. filepath_rootrelative, vim.log.levels.ERROR)
        return
    end

    --We can go back to prev wrkdir
    vim.fn.chdir(prev_workdir)


    --Create new empty buffer
    local curso_pos = vim.api.nvim_win_get_cursor(0)

    vim.cmd("vsplit")
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, buf)

    vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
    vim.api.nvim_set_option_value("filetype", filetype, { buf = buf })
    vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
    vim.api.nvim_set_option_value("buflisted", true, { buf = buf })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })

    --Write content of commit to said buffer
    vim.api.nvim_buf_set_lines(buf, 0, 0, false, git_metadata)
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, {"============================================================"})
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, git_content)


    --Enable diff mode in both windows
    --rev buffer
    vim.cmd("diffthis")
    vim.wo.scrollbind = true
    vim.wo.cursorbind = true
    vim.wo.foldmethod = "diff"
    vim.wo.foldlevel = 99 --hack to Keep folds open by default

    vim.cmd("wincmd p") --back to og buf

    --og buffer
    vim.cmd("diffthis")
    vim.wo.scrollbind = true
    vim.wo.cursorbind = true
    vim.wo.foldmethod = "diff"
    vim.wo.foldlevel = 99

    vim.api.nvim_win_set_cursor(0, curso_pos) --cursor back to og pos
    --vim.cmd("wincmd p") --to rev buffer again

end, {nargs = "?"})



--## [Formating]
--------------------------------------------------
--wrap line into paragraph
vim.api.nvim_create_user_command("WrapSelection", function()
    vim.cmd("normal! gww")
end, { range = true })

vim.api.nvim_create_user_command("DumpMessagesToBuffer", function()
    local cmd_output = vim.fn.execute('messages')

    vim.cmd("enew")

    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(cmd_output, '\n'))
end, {})



--## [View]
--------------------------------------------------
vim.api.nvim_create_user_command("ToggleEndOfLineChar", function()
    local listchars = vim.opt.listchars:get()

    if listchars.eol == "¶" then
        vim.opt.listchars:remove("eol")
    else
        vim.opt.listchars:append({ eol = "¶" })
    end
end, {})



