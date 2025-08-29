-------------------------
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

    vim.cmd("new"); vim.cmd("enew") vim.cmd("file! message")

    vim.api.nvim_set_option_value("buftype", "nofile", {buf=0})
    vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
    vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})

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



--## [Registers]
----------------------------------------------------------------------
vim.api.nvim_create_user_command("ClearClipboard", function()
    vim.fn.setreg("+", " ") --need white space here
end, {})

vim.api.nvim_create_user_command("LiveReg", function()
    vim.cmd("vsp|enew"); vim.cmd("file! Reg")

    local buf = vim.api.nvim_get_current_buf()

    vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
    vim.api.nvim_set_option_value("buflisted", false,  { buf = buf })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })

    vim.opt_local.statuscolumn = ""
    vim.opt_local.signcolumn   = "no"
    vim.opt_local.number       = false
    vim.opt_local.foldcolumn   = "0"

    local function refresh()
        if not vim.api.nvim_buf_is_valid(buf) then return false end

        local raw   = vim.fn.execute("reg")
        local lines = vim.split(raw, "\n", { trimempty = true })
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

        return true
    end

    -- start timer
    --local timer_new = vim.uv.new_timer()

    local timer = vim.fn.timer_start(350, function()
        if not refresh() then
            vim.fn.timer_stop(timer)
        end
    end, { ["repeat"] = -1 })

    refresh()

    -- stop timer if buffer is wiped
    vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = buf,
        callback = function()
            vim.fn.timer_stop(timer)
        end,
    })
end, {})



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
        "OnHidden:   "..tostring(vim.api.nvim_get_option_value("bufhidden", {buf = inbuf})),

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

vim.api.nvim_create_user_command("BufferCopy", function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    vim.fn.setreg("+", table.concat(lines, "\n"))
    print("Buffer copied")
end, {})



--## [Files]
----------------------------------------------------------------------
vim.api.nvim_create_user_command("CopyFilePath", function()
    vim.fn.setreg("+", vim.fn.expand("%:p"))
    print("Copied file path: " ..'"'..vim.fn.getreg("+")..'"')
end, {})

vim.api.nvim_create_user_command("CopyFileDirPath", function()
    vim.fn.setreg("+", vim.fn.expand("%:p:h"))
    print("Copied file dir path: " ..'"'..vim.fn.getreg("+")..'"')
end, {})

vim.api.nvim_create_user_command("CdFileDir", function()
    vim.cmd("cd %:p:h")
    vim.cmd("pwd")
end, {})

vim.api.nvim_create_user_command("FileStat", function()
    print(vim.inspect(vim.uv.fs_stat(vim.fn.expand("%"))))
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

vim.api.nvim_create_user_command("FileSaveInteractive", function()
    local fpath       = vim.api.nvim_buf_get_name(0)
    local fstat       = vim.uv.fs_stat(fpath)
    local freadonly   = fstat and (bit.band(fstat.mode, 0x80) == 0)
    local fprivileged = fstat and fstat.uid == 0

    if not fstat then
        local choice = vim.fn.confirm("File does not exist. Create it?", "&Yes\n&No", 1)
        if choice == 1 then vim.cmd("FileSaveAsInteractive")                       return
        else                vim.notify("Creation cancelled.", vim.log.levels.INFO) return
        end
    end

    if fstat and not fprivileged and not freadonly then vim.cmd("write") return end
    if fstat and fprivileged and not freadonly then vim.cmd("SudoWrite") return end
    if fstat and freadonly then
        local choice = vim.fn.confirm("Can't write, file is readonly! Try force?", "&Yes\n&No", 1)
        if choice == 1 then vim.cmd("SudoWrite")                                      return
        else                vim.notify("Force write cancelled.", vim.log.levels.INFO) return
        end
    end
end, {})

vim.api.nvim_create_user_command("FileSaveAsInteractive", function()
    local fpath = vim.api.nvim_buf_get_name(0)

    local function prompt_user()
        vim.ui.input({prompt="Save as: ", default=fpath, completion="dir"},
        function(input)
            vim.api.nvim_command("redraw") --Hide prompt

            if     input == nil then
                vim.notify("Save cancelled.", vim.log.levels.INFO) return
            elseif input == ""  then
                vim.notify("Input cannot be empty!", vim.log.levels.INFO)
                return prompt_user()
            end

            local dir = vim.fs.dirname(input) -- check target dir
            if not vim.uv.fs_stat(dir) then
                local choice = vim.fn.confirm("Directory does not exist. Create it?", "&Yes\n&No", 1)
                if choice == 1 then
                    local ret, err = vim.uv.fs_mkdir(dir, tonumber("755", 8)) -- drwxr-xr-x
                    if not ret then
                        vim.notify("Directory creation failed: " .. err, vim.log.levels.ERROR) return
                    end
                else
                    vim.notify("Directory creation cancelled.", vim.log.levels.INFO)
                    return prompt_user()
                end
            end

            --check target path for existing file
            if vim.uv.fs_stat(input) then
                local choice = vim.fn.confirm("File with same name at path, Overwrite?", "&Yes\n&No", 1)
                if choice ~= 1 then
                    vim.notify("Overwriting cancelled.", vim.log.levels.INFO)
                    return prompt_user()
                end
            end

            vim.api.nvim_buf_set_name(0, input); vim.cmd("w!|e!") return --w! to bypass builtin overwite check
        end)
    end
    prompt_user()
end, {})

vim.api.nvim_create_user_command('SudoWrite', function()
    local fpath = vim.fn.shellescape(vim.fn.expand("%:p"))
    local tmp = vim.fn.tempname()

    vim.cmd('write! ' .. tmp)

    local edw_w = vim.o.columns
    local edw_h = vim.o.lines

    local wsize = { w = 45, h = 3 }

    local wopts = {
        title     = "Authentication required",
        title_pos = "center",
        relative  = "editor",
        style     = "minimal",
        border    = "single",
        width     = wsize.w,
        height    = wsize.h,
        col       = math.floor((edw_w - wsize.w) / 2),
        row       = math.floor((edw_h - wsize.h) / 2),
    }
    vim.api.nvim_open_win(0, true, wopts)

    vim.cmd("term sudo tee "..fpath.." < "..tmp.." > /dev/null")
end, {})

vim.api.nvim_create_user_command("FileMove", function()
    local fpath  = vim.api.nvim_buf_get_name(0)
    local fname  = vim.fn.fnamemodify(fpath, ":t")

    local function prompt_user()
        vim.ui.input({prompt="Move to: ", default=vim.fn.getcwd(), completion="dir"},
        function(input)
            vim.api.nvim_command("redraw") --Hide prompt

            if     input == nil then
                vim.notify("Move canceled. ", vim.log.levels.INFO) return
            elseif input == ""  then
                vim.notify("Input cannot be empty!", vim.log.levels.WARN)
                return prompt_user()
            end

            --check target dir
            if not vim.uv.fs_stat(input) then
                local choice = vim.fn.confirm("Directory doesn't exist. Create it?", "&Yes\n&No", 1)
                if choice == 1 then
                    local ret, err = vim.uv.fs_mkdir(input, tonumber("755", 8)) -- drwxr-xr-x
                    if not ret then
                        vim.notify("Directory creation failed: " .. err, vim.log.levels.ERROR) return
                    end
                else
                    vim.notify("Directory creation cancelled.", vim.log.levels.INFO)
                    return prompt_user()
                end
            end

            local target_path = vim.fs.joinpath(input, fname)

            --check target path for existing file
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
    local old_dir  = vim.fn.fnamemodify(old_fpath, ":h")
    local old_name = vim.fn.fnamemodify(old_fpath, ":t")

    local function prompt_user()
        vim.ui.input({prompt="New name = ", default=old_name, completion="file"},
        function(input)
            vim.api.nvim_command("redraw") --Hide init prompt

            if     input == nil then
                vim.notify("Rename canceled.", vim.log.levels.INFO) return
            elseif input == "" then
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

--Easy del files without file browser
vim.api.nvim_create_user_command("FileDelete", function()
    local fpath = vim.api.nvim_buf_get_name(0)
    local fname = vim.fn.fnamemodify(fpath, ":t")

    local choice = vim.fn.confirm('Delete "' .. fname .. '" ?', "&Yes\n&No", 1)
    if choice == 1 then
        vim.uv.fs_unlink(fpath, function(err)
            if err then
                --TODO rewrite this part better like the others in FileMove for
                --ex
                vim.schedule(function()
                    vim.notify("Delete failed: " .. err, vim.log.levels.ERROR)
                end)
                return
            end

            vim.schedule(function()
                vim.cmd('bdelete!'); vim.notify("Deleted: " .. fpath, vim.log.levels.INFO)
            end)
        end)
    else
        vim.notify("Delete canceled.", vim.log.levels.INFO) return
    end
end, {})

vim.api.nvim_create_user_command("SymlinkToFile", function()
    local bufid = vim.api.nvim_get_current_buf()
    local fpath = vim.api.nvim_buf_get_name(bufid)

    local function prompt_user()
        vim.ui.input({
            prompt = "Symlink path: ", default = vim.fn.expand("~").."/", completion = "dir",
        },
        function(input)
            vim.api.nvim_command("redraw") --Hide prompt

            if input == nil then
                vim.notify("linking cancelled. ", vim.log.levels.INFO) return
            elseif input == "" then
                vim.notify("Input cannot be empty!", vim.log.levels.WARN)
                return prompt_user()
            end

            local res = vim.system({"ln", "-s", fpath, input}, {text=true}):wait()
            if res.code ~= 0 then
                vim.notify("Linking failed!" .. (res.stderr or "Unknown error"), vim.log.levels.ERROR)
                return prompt_user()
            end

            vim.notify("Symlink created at: " .. input, vim.log.levels.INFO)
        end)
    end
    prompt_user()
end, {})


--### File perms
vim.api.nvim_create_user_command("SetFileReadonly", function()
    local path = vim.api.nvim_buf_get_name(0)
    local name = vim.fn.fnamemodify(path, ":t")

    if path == "" then
        vim.notify("No file for current buffer.", vim.log.levels.WARN) return
    end

    vim.bo.readonly = true  --optional refresh lualine
    local ret = os.execute("chmod -w " .. vim.fn.shellescape(path))
    if ret == 0 then
        vim.print(name .. ", now readonly")
    else
        vim.notify("Failed to set file as readonly.", vim.log.levels.ERROR)
    end
end, {})

vim.api.nvim_create_user_command("SetFileWritable", function()
    local path = vim.api.nvim_buf_get_name(0)
    local name = vim.fn.fnamemodify(path, ":t")

    if path == "" then
        vim.notify("No file for current buffer.", vim.log.levels.ERROR) return
    end

    vim.bo.readonly = false  --optional refresh lualine
    local ok = os.execute("chmod +w " .. vim.fn.shellescape(path))

    if ok == 0 then
        vim.print(name .. ", now writable.")
    else
        vim.notify("Failed to set file as writable.", vim.log.levels.ERROR)
    end
end, {})

vim.api.nvim_create_user_command("SetFileExecutable", function()
    local path = vim.api.nvim_buf_get_name(0)
    local name = vim.fn.fnamemodify(path, ":t")

    if path == "" then
        vim.notify("No file for current buffer.", vim.log.levels.ERROR) return
    end

    local ok = os.execute("chmod +x " .. vim.fn.shellescape(path))
    if ok == 0 then
        vim.print(name .. ", now executable")
    else
        vim.notify("Failed to set file as executable.", vim.log.levels.ERROR)
    end
end, {})

vim.api.nvim_create_user_command("SetFileNotExecutable", function()
    local path = vim.api.nvim_buf_get_name(0)
    local name = vim.fn.fnamemodify(path, ":t")

    if path == "" then
        vim.notify("No file for current buffer.", vim.log.levels.ERROR) return
    end

    local ok = os.execute("chmod -x " .. vim.fn.shellescape(path))
    if ok == 0 then
        vim.print(name .. ", no longer executable")
    else
        vim.notify("Failed to remove executable flag.", vim.log.levels.ERROR)
    end
end, {})


-- ### Extended attributes
vim.api.nvim_create_user_command("FileSetLangFattr", function(opts)
    if opts.args == "" then vim.notify("cmd need a lang! ", vim.log.levels.ERROR) return end

    local lang = opts.args
    local fpath = vim.fn.expand("%:p")
    local fname = vim.fn.expand("%:t")

    local res = vim.system({"setfattr", "-n", "user.lang", "-v", '"'..lang..'"', fpath}, {text=true}):wait()
    if res.code ~= 0 then
        vim.notify("SetLang for file failed:\n" .. res.stderr, vim.log.levels.ERROR) return
    else
        vim.notify('"'..fname..'"'.." lang is now: "..lang, vim.log.levels.INFO) return
    end
end, {nargs = 1})

vim.api.nvim_create_user_command("FileGetLangFattr", function()
    local fpath = vim.fn.expand("%:p")
    local fname = vim.fn.expand("%:t")

    local res = vim.system({"getfattr", "--only-values", "-n", "user.lang", fpath}, {text=true}):wait()

    if res.code ~= 0 then
        vim.notify("GetLang failed:\n" .. res.stderr, vim.log.levels.ERROR)
    else
        local lang = vim.trim(res.stdout or "")
        if lang == "" then vim.notify("No lang attr set", vim.log.levels.WARN)
        else               vim.notify('"'..fname..'"'.." lang is: "..lang, vim.log.levels.INFO)
        end
    end
end, {})



--## [Windows]
----------------------------------------------------------------------
vim.api.nvim_create_user_command("CreateFloatingWindow", function()
    local bufid = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufid })

    local edw_w = vim.o.columns
    local edw_h = vim.o.lines

    local wsize = {w = 65, h = 20}

    local wopts = {
        title = "Scratchpad",
        title_pos = "center",
        relative = "editor",
        border = "single",
        width  = wsize.w,
        height = wsize.h,
        col = math.floor((edw_w - wsize.w) / 2),
        row = math.floor((edw_h - wsize.h) / 2),
    }
    local win = vim.api.nvim_open_win(bufid, true, wopts)
end, {})

vim.api.nvim_create_user_command("WinInfo", function()
    local winid = vim.api.nvim_get_current_win()
    print(vim.inspect(vim.api.nvim_win_get_config(winid)))
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

vim.api.nvim_create_user_command("PrintCharInfo", function()
    vim.cmd('norm!"zyl')
    local char = vim.fn.getreg("z")
    print('char: '..'"'..char..'"'..' nr: '..vim.fn.char2nr(char))
end, {})

vim.api.nvim_create_user_command("OpenDigraph", function()
    local raw   = vim.fn.execute("digraphs")
    local lines = vim.split(raw, "\n", {trimempty = true})

    vim.cmd("enew"); vim.cmd("file Digraphs")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

    vim.api.nvim_set_option_value("buftype",   "nofile", {buf=0})
    --vim.api.nvim_set_option_value("buflisted",  false,   {buf=0})
    --vim.api.nvim_set_option_value("bufhidden",  "wipe",  {buf=0})
    vim.opt_local.statuscolumn = ""
    vim.opt_local.signcolumn   = "no"
    vim.opt_local.number       = false
    vim.opt_local.foldcolumn   = "0"
end, {})



--## [Version control]
----------------------------------------------------------------------
vim.api.nvim_create_user_command("PrintGitRoot", function()
    print(vim.fn.systemlist("git rev-parse --show-toplevel")[1])
end, {})

vim.api.nvim_create_user_command("GitCommitFile", function()
    --fetch git root
    local git_res = vim.system({"git", "rev-parse", "--show-toplevel"}, {text=true}):wait()
    if git_res.code ~= 0 then
        vim.notify("Not inside a Git repo:" .. git_res.stderr, vim.log.levels.ERROR) return
    end
    local git_root = vim.trim(git_res.stdout) --trim white space to avoid surprises

    local fpath = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())

    print("Git root: ".. git_root)
    print("Commiting: ".. vim.fn.fnamemodify(fpath, ":t"))

    vim.ui.input({prompt="Commit message = ", default=""}, --completion="dir"
    function(input)
        vim.api.nvim_command("redraw") --Hide prompt

        if input == nil then vim.notify("Commit canceled.", vim.log.levels.INFO) return end

        --stage curr file
        local stage_res = vim.system({"git", "add", "--", fpath}, {text=true}):wait()
        if stage_res.code ~= 0 then
            vim.notify("File staging failed: " .. stage_res.stderr, vim.log.levels.ERROR) return
        end

        --local onelinemessage = input:gsub("[\r\n]+", " ")
        local commit_res = vim.system({"git", "commit", "-m", input, "--", fpath}, {text=true}):wait()
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
    local rev = opts.args ~= "" and opts.args or "HEAD"

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
    local git_content = vim.fn.systemlist(string.format("git show %q:%q", rev, fpath_rootrelative))
    --local git_content = vim.system({"git", "show", rev, "--", fpath}, {text=true}):wait()


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
    vim.api.nvim_buf_set_lines(difbuf,  0,  0, false, git_metadata)
    vim.api.nvim_buf_set_lines(difbuf, -1, -1, false, {"============================================================"})
    vim.api.nvim_buf_set_lines(difbuf, -1, -1, false, git_content)

    vim.api.nvim_set_option_value("modifiable", false, { buf = difbuf })


    --Enable diff mode in both windows
    --rev buffer
    vim.cmd("diffthis")
    vim.opt_local.scrollbind   = true
    vim.opt_local.cursorbind   = true
    vim.opt_local.statuscolumn = ""
    vim.opt_local.signcolumn   = "no"
    vim.opt_local.number       = false
    vim.opt_local.foldcolumn   = "0"
    vim.opt_local.foldmethod   = "diff"
    vim.opt_local.foldlevel    = 99 --hack to Keep folds open by default

    vim.api.nvim_win_set_cursor(0, curso_pos) --cursor back to og pos

    vim.cmd("wincmd p") --back to og buf

    --og buffer
    vim.cmd("diffthis")
    vim.opt_local.scrollbind = true
    vim.opt_local.cursorbind = true
    vim.opt_local.foldcolumn = "1"
    vim.opt_local.foldmethod = "diff"
    vim.opt_local.foldlevel  = 99

    vim.cmd("wincmd w") --back to diff
end, {nargs = "?"})

vim.api.nvim_create_user_command("GitRestoreFile", function(opts)
    local rev = opts.args ~= "" and opts.args or "HEAD"

    local fpath = vim.api.nvim_buf_get_name(0)

    -- Check if file exists in rev
    local ls_res = vim.system({"git", "ls-tree", "-r", "--name-only", rev, fpath}, {text=true}):wait()
    if ls_res.code ~= 0 or ls_res.stdout == "" then
        vim.notify("File does not exist at revision " .. rev, vim.log.levels.ERROR)
        return
    end

    local res = vim.system({"git", "restore", "-s", rev, "--", fpath}, {text=true}):wait()
    if res.code == 0 then
        vim.cmd("edit!")
        vim.notify("File restored to ".. rev, vim.log.levels.INFO)
    else
        vim.notify("git restore failed: " .. git_res.stderr, vim.log.levels.ERROR)
    end
end, {nargs="?"})

vim.api.nvim_create_user_command("LazyGit", function(opts)
    vim.cmd.terminal("lazygit")
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


