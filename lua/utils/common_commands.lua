------------------------
-- User commands --
-------------------------
local v = vim


local utils = require("utils.utils")
-------------------------



--## [Common]
----------------------------------------------------------------------
--Quick ressource curr
vim.api.nvim_create_user_command("RessourceCurrent", function()
    local currf = vim.fn.expand("%:p")
    vim.cmd("source " ..currf)
end, {})

--Restart nvim
vim.api.nvim_create_user_command("Restart", function()
    local curfile = vim.fn.expand("%:p") --Get curr file location
    local curdir  = vim.fn.fnamemodify(curfile, ':h')

    vim.cmd("SaveGlobalSession")

    local sess = GLOBAL_SESSION
    vim.loop.spawn("wezterm", {
        --args = { "-e", "nvim", "+cd " .. curdir, curfile },

        --cwd = curdir,

        args = { "-e", "nvim", "-S", GLOBAL_SESSION },
    })
    vim.cmd("qa!")
end, {})

vim.api.nvim_create_user_command("RestartSafeMode", function()
    vim.fn.jobstart({ "nvim -u NONE" }, {detach=true})
    vim.cmd("qa!")
end, {})

vim.api.nvim_create_user_command("DumpMessagesToBuffer", function()
    local cmd_output = vim.fn.execute('messages')
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(cmd_output, '\n'))
end, {})

--insert today
vim.api.nvim_create_user_command("Today", function()
    local date  = os.date("*t")
    local today = string.format("%04d/%02d/%02d %02d:%02d", date.year, date.month, date.day, date.hour, date.min)
    vim.api.nvim_put({ today }, "c", true, true)
end, {})

vim.api.nvim_create_user_command("WebSearch", function()
    vim.cmd('norm! gv"+y')
    local text = vim.fn.getreg('+')
    vim.ui.open(text, {cmd={"firefox"}})
    vim.system(
        {"firefox", "https://duckduckgo.com/?q=" .. text}, {detach=true}
    )
end, {range=true})



--## [Buffers]
----------------------------------------------------------------------
vim.api.nvim_create_user_command("BufferInfo", function(opts)
    local inbuf = tonumber(opts.args) or vim.api.nvim_get_current_buf()

    local infos = {
        "Name:       "..vim.api.nvim_buf_get_name(inbuf),
        "Id:         "..inbuf,
        "Buftype:    "..vim.api.nvim_get_option_value("buftype", {buf = inbuf}),
        "Loaded:     "..tostring(vim.api.nvim_buf_is_loaded(inbuf)), --hidden
        "Listed:     "..tostring(vim.api.nvim_get_option_value("buflisted", {buf = inbuf})),
        "Modifiable: "..tostring(vim.api.nvim_get_option_value("modifiable", {buf = inbuf})),
        "Modified:   "..tostring(vim.api.nvim_get_option_value("modified", {buf = inbuf})),

        "Filetype:   "..vim.api.nvim_get_option_value("filetype", { buf = inbuf }),
        "FileOnDisk: "..tostring(vim.fn.filereadable(vim.api.nvim_buf_get_name(inbuf))==1),
        "linecount:  "..vim.api.nvim_buf_line_count(inbuf),

        "PrevBuf:    "..vim.api.nvim_buf_get_name(vim.fn.bufnr("#")),
        "PrevBufId:  "..vim.fn.bufnr("#"),

        "windowsIds: "..table.concat(vim.tbl_map(tostring, vim.fn.win_findbuf(inbuf)), ", "),
    }

    vim.notify(table.concat(infos, "\n"), vim.log.levels.INFO)
end, {nargs= "?"})

vim.api.nvim_create_user_command("WipeHiddenBuffers", function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if not vim.api.nvim_buf_is_loaded(buf) then
            vim.api.nvim_buf_delete(buf, {force=true})
            print("wipeing buffer")
        end
   end
end, {})

vim.api.nvim_create_user_command("DeleteAllBuffers", function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        vim.api.nvim_buf_delete(buf, {force=true})
    end
end, {})



--## [Files]
----------------------------------------------------------------------
vim.api.nvim_create_user_command("CopyFilePath", function()
    vim.cmd("let @+ = expand('%')")
    print("Copied path: " .. vim.fn.getreg("+"))
end, {})

vim.api.nvim_create_user_command("CopyFileDirPath", function()
    vim.cmd("let @+ = expand('%:h')")
    print("Copied path: " .. vim.fn.getreg("+"))
end, {})

vim.api.nvim_create_user_command("CDFileDir", function()
    vim.cmd("cd %:p:h")
end, {})

vim.api.nvim_create_user_command("FilePicker", function()
    local curfdir = vim.fn.expand("%:p")

    local cmd = string.format('kdialog --getopenfilename "%s"', curfdir)
    local handle = io.popen(cmd)
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
    local fname = vim.fn.fnamemodify(fpath, ":t")
    local fdir  = vim.fn.fnamemodify(fpath, ":h")

    if vim.fn.filereadable(fpath) == 0 then
        vim.notify("No file on disk to move", vim.log.levels.ERROR) return
    end

    local function prompt_user()
        vim.ui.input({
            prompt="Move to: ", default=fdir, completion="dir",
        },
        function(input)
            vim.api.nvim_command("redraw") --Hide prompt

            if input == nil then
                vim.notify("Move cancelled. ", vim.log.levels.INFO) return
            end
            if input == "" then
                vim.notify("Input cannot be empty!", vim.log.levels.WARN)
                return prompt_user()
            end

            --assemble path
            local target_path = vim.fs.joinpath(input, fname)

            --check target dirs
            if not vim.uv.fs_stat(input) then
                local choice = vim.fn.confirm("Directory does not exist. Create it?", "&Yes\n&No", 1)
                if choice == 1 then
                    local ret, err = vim.uv.fs_mkdir(input, 666) -- rw-rw-rw
                    if not ret then
                        vim.notify("Directory creation failed: " .. err, vim.log.levels.ERROR) return
                    end
                else
                    vim.notify("Directory creation cancelled.", vim.log.levels.INFO)
                    return prompt_user()
                end
            end

            --check target for existing file
            if vim.uv.fs_stat(target_path) then
                local choice = vim.fn.confirm("File with same name at path, Overwrite?", "&Yes\n&No", 1)
                if choice ~= 1 then
                    vim.notify("Overwriting cancelled.", vim.log.levels.INFO)
                    return prompt_user()
                end
            end

            --now lets movein'
            local ret, err = vim.uv.fs_rename(fpath, target_path)
            if not ret then
                vim.notify("Move failed: " .. err, vim.log.levels.ERROR) return
            end

            --Update buffer
            vim.api.nvim_buf_set_name(0, target_path); vim.cmd("e!") --refresh buf to new path
            vim.notify("Moved to: " .. input, vim.log.levels.INFO)
        end)
    end
    prompt_user()
end, {})

vim.api.nvim_create_user_command("FileRename", function()
    local old_fpath = vim.api.nvim_buf_get_name(0)

    if vim.fn.filereadable(old_fpath) == 0 then
        vim.notify("No file to rename", vim.log.levels.ERROR) return
    end

    local old_dir  = vim.fn.fnamemodify(old_fpath, ":h")
    local old_name = vim.fn.fnamemodify(old_fpath, ":t")

    local function prompt_user()
        vim.ui.input({
            prompt="New name = ", default=old_name, completion="file",
        },
        function(input)
            vim.api.nvim_command("redraw") --Hide init prompt

            if input == nil then
                vim.notify("Rename canceled", vim.log.levels.INFO) return
            end
            if input == "" then
                vim.notify("Input cannot be empty!", vim.log.levels.WARN)
                return prompt_user()
            end

            local new_fpath = vim.fs.joinpath(old_dir,input)

            --check target for existing file
            if vim.uv.fs_stat(new_fpath) then
                local choice = vim.fn.confirm("Already a file with same name. Overwrite?", "&Yes\n&No", 1)
                if choice ~= 1 then
                    vim.notify("Overwriting cancelled.", vim.log.levels.INFO)
                    return prompt_user()
                end
            end

            local ret, err = vim.uv.fs_rename(old_fpath, new_fpath)
            if not ret then
                vim.notify("Rename failed: " .. err, vim.log.levels.ERROR) return
            end

            --Reload buffer with new file
            vim.api.nvim_buf_set_name(0, new_fpath); vim.cmd("e!") --refresh buf to new name
            vim.notify('Renamed to: "'..input..'"', vim.log.levels.INFO)
        end)
    end
    prompt_user()
end, {})


--### File perms
vim.api.nvim_create_user_command("SetFileReadonly", function()
    local path = vim.api.nvim_buf_get_name(0)
    local name = vim.fn.fnamemodify(path, ":t")

    if path == "" then
        vim.notify("No file for current buffer", vim.log.levels.WARN) return
    end

    vim.bo.readonly = true  --optional refresh lualine
    local ret = os.execute("chmod -w " .. vim.fn.shellescape(path))
    if ret == 0 then
        vim.print(name .. ", now readonly")
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
        vim.print(name .. ", now writable")
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
        vim.print(name .. ", now executable")
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
        vim.print(name .. ", no longer executable")
    else
        vim.notify("Failed to remove executable flag", vim.log.levels.ERROR)
    end
end, {})


--Easy del files without file browser
vim.api.nvim_create_user_command("FileDelete", function()
    local fpath = vim.api.nvim_buf_get_name(0)
    local fname = vim.fn.fnamemodify(fpath, ":t")

    if fpath == "" or vim.fn.filereadable(fpath) == 0 then
        vim.notify("No file to delete", vim.log.levels.ERROR) return
    end

    local choice = vim.fn.confirm('Delete "' .. fname .. '" ?', "&Yes\n&No", 1)
    if choice == 1 then
        vim.uv.fs_unlink(fpath, function(err)
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
    else
        vim.notify("Delete canceled", vim.log.levels.INFO) return
    end
end, {})

vim.api.nvim_create_user_command("SymlinkToFile", function()
    local bufid = vim.api.nvim_get_current_buf()
    local fpath = vim.api.nvim_buf_get_name(bufid)

    vim.ui.input({
        prompt = "Symlink path: ", default = vim.fn.expand("~").."/", completion = "dir",
    },
    function(input)
        vim.api.nvim_command("redraw") --Hide prompt

        if input == nil then
            vim.notify("linking cancelled. ", vim.log.levels.INFO) return
        end
        --if input == "" then

        local res = vim.system({"ln", "-s", fpath, input}, {text=true}):wait()
        if res.code ~= 0 then
            vim.notify("Linking failed!\n" .. (res.stderr or "Unknown error"), vim.log.levels.ERROR) return
        end

        vim.notify("Symlink created at: " .. input, vim.log.levels.INFO)
    end)
end, {})



--## [Editing]
--------------------------------------------------
--Trim select, include tab and break lines
vim.api.nvim_create_user_command("TrimWhitespacesLine", function(opts)
    vim.cmd("s/\\s//g")
    vim.cmd("norm! i")
end, {range=true})

vim.api.nvim_create_user_command("TrimTrailSpacesBuffer", function()
    local curpos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, curpos)
end, {})

--Append underline unicode character to each selected chars
vim.api.nvim_create_user_command("UnderlineSelected", function(opts)
    local start_line = opts.line1 - 1
    local end_line   = opts.line2

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
end, {range=true})

vim.api.nvim_create_user_command("ClearAllMarks", function()
    vim.cmd([[delmarks a-zA-Z0-9"<>'[].]])
    print("[All marks cleared]")
end, {desc = "Delete all marks in the current buffer"})

--Open code action floating win
vim.api.nvim_create_user_command("CodeAction", function()
    require("tiny-code-action").code_action()
end, {})



--## [Version control]
----------------------------------------------------------------------
--Handy Show git root
vim.api.nvim_create_user_command("PrintGitRoot", function()
    print(vim.fn.systemlist("git rev-parse --show-toplevel")[1])
end, {})

vim.api.nvim_create_user_command("GitCommitFile", function()
    --fetch git root
    local git_res = vim.system({"git", "rev-parse", "--show-toplevel"}, {text=true}):wait()
    if git_res.code ~= 0 then
        vim.notify("Not inside a Git repo:\n" .. git_res.stderr, vim.log.levels.ERROR) return
    end
    local git_root = vim.trim(git_res.stdout) --trim white space to avoid surprises

    vim.ui.input({
        prompt = "Commit message: ", default = "", --completion = "dir",
    },
    function(input)
        vim.api.nvim_command("redraw") --Hide prompt

        if input == nil then
            vim.notify("Commit canceled. ", vim.log.levels.INFO) return
        end

        --calc path local to git root
        local fpath = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())

        local rel_path = vim.fs.relpath(git_root, fpath)

        --stage curr file
        local stage_res = vim.system({"git", "add", "--", rel_path}, {text=true}):wait()
        if stage_res.code ~= 0 then
            vim.notify("File staging failed: " .. stage_res.stderr, vim.log.levels.ERROR) return
        end

        --local onelinemessage = input:gsub("[\r\n]+", " ")
        local commit_res = vim.system({"git", "commit", "-m", input, "--", rel_path}, {text=true}):wait()
        if commit_res.code == 0 then
            local message_res = vim.system({"git", "log", "-1", '--pretty=format:%d [%h] "%s"'}, {text=true}):wait()
            if message_res.code == 0 then
                vim.notify(message_res.stdout)
            else
                vim.notify("Failed to get commit summary: " .. message_res.stderr, vim.log.levels.ERROR)
            end
        else
            vim.notify("Commit failed: " .. commit_res.stderr, vim.log.levels.ERROR)
        end
    end)
end, {})

--diff curr file with given rev
vim.api.nvim_create_user_command("DiffRevision", function(opts)
    --Process arg
    local rev = opts.args ~= "" and opts.args or "HEAD~1"

    local prev_workdir = vim.fn.getcwd()

    local bufid    = vim.api.nvim_get_current_buf()
    local fpath    = vim.api.nvim_buf_get_name(bufid)
    local filename = vim.fn.expand("%:t")
    local filetype = vim.bo.filetype

    --pulling git data
    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
    vim.fn.chdir(git_root)
    local fpath_rootrelative = vim.fn.fnamemodify(fpath, ":.")

    local git_metadata = vim.fn.systemlist(string.format("git log -1 %s -- %s", rev, fpath_rootrelative))
    local git_content  = vim.fn.systemlist(string.format("git show %q:%q", rev, fpath_rootrelative))

    if vim.v.shell_error ~= 0 then
        vim.notify(
            "error for rev: '" .. rev .. "', revision or file not found'" .. fpath_rootrelative .. "'",
            vim.log.levels.ERROR)
        return
    end

    vim.fn.chdir(prev_workdir) --We can go back to prev wrkdir

    --Create new empty buffer
    local curso_pos = vim.api.nvim_win_get_cursor(0)

    vim.cmd("vsplit")
    local difbuf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, difbuf)

    vim.api.nvim_set_option_value("buftype",   "nofile",  { buf = difbuf })
    vim.api.nvim_set_option_value("filetype",   filetype, { buf = difbuf })
    vim.api.nvim_set_option_value("modifiable", true,     { buf = difbuf })
    vim.api.nvim_set_option_value("buflisted",  true,     { buf = difbuf })
    vim.api.nvim_set_option_value("bufhidden",  "wipe",   { buf = difbuf })

    --Write content of commit to said buffer
    vim.api.nvim_buf_set_lines(difbuf, 0, 0, false, git_metadata)
    vim.api.nvim_buf_set_lines(difbuf, -1, -1, false, {"============================================================"})
    vim.api.nvim_buf_set_lines(difbuf, -1, -1, false, git_content)

    vim.api.nvim_set_option_value("modifiable", false, { buf = difbuf })


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

vim.api.nvim_create_user_command("ToggleColorcolumn", function()
    local col = vim.opt.colorcolumn:get()

    if #col > 0 then
        vim.opt_local.colorcolumn = {}
    else
        vim.opt_local.colorcolumn = { vim.opt.textwidth:get() }
    end
end, {})

vim.api.nvim_create_user_command("FacingPages", function()
    local win_left = vim.api.nvim_get_current_win()

    --calc target row for right pane
    --local target_row = vim.fn.getpos(".")[2] + vim.api.nvim_win_get_height(win_left)
    --target_row = math.min(target_row, vim.api.nvim_buf_line_count(0))

    vim.cmd("vsplit")
    local win_right = vim.api.nvim_get_current_win()

    --vim.cmd("norm! "..target_row.."G"); vim.cmd("norm! zt")

    --back to og win
    vim.api.nvim_set_current_win(win_left)

    local group = vim.api.nvim_create_augroup("ScrollSync", { clear = true })
    local syncing = false
    vim.api.nvim_create_autocmd("WinScrolled", {
        group = group,
        callback = function(args)
            if syncing then return end; syncing = true

            local curr_win = vim.api.nvim_get_current_win()

            local other_win = curr_win == win_left and win_right or win_left

            if not vim.api.nvim_win_is_valid(other_win) then return end

            --local topline = vim.fn.line('w0', curr_win) +30
            local target_row = vim.fn.getpos(".")[2] + vim.api.nvim_win_get_height(win_left)
            target_row = math.min(target_row, vim.api.nvim_buf_line_count(0))

            vim.api.nvim_win_call(other_win, function()
                --vim.cmd("norm! ")
                vim.cmd("norm! ".. target_row .."G")
                vim.cmd("norm! zt")
            end)

            syncing = false
        end,
    })
end, {})


