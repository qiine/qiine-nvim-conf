
-- Filesystem --

-- fs utils
local U = {}

function U.has_trailslash(path)
    return path:sub(-1) == "/"
end

function U.is_dir(path)
    return vim.fn.isdirectory(path) == 1 or U.has_trailslash(path)
end

function U.is_abs(path)
    return path:sub(1, 1) == "/"
end

---@param path string
---@param opts? table
---@return string|nil
function U.path_shorten_adaptative(path, opts)
    local defopts = {
        minln = 2,
        maxln = 3,
        keeproot = true,
        keeptail = true,
        longpathlen = 78,
    }
    opts = vim.tbl_deep_extend("force", defopts,  opts or {})

    if not path or path == "" then return vim.notify("Invalid path", vim.log.levels.ERROR) end

    if path == "/" then return path end

    local isdir = U.is_dir(path)
    local isabs = U.is_abs(path)

    local islongpath = #path > opts.longpathlen
    local hastrailslash = U.has_trailslash(path)

    -- Cut into pieces
    local subpaths = vim.split(path, "/", {plain=true})
    -- Trim slashes for now
    if subpaths[1] == "" then table.remove(subpaths, 1) end
    if hastrailslash then table.remove(subpaths, #subpaths) end

    local shortsubpaths = {}

    local mid = math.ceil((#subpaths+1) / 2)

    for i, subpath in ipairs(subpaths) do
        if opts.keeproot and i == 1 then -- Keep first, makes path easier to read
            table.insert(shortsubpaths, subpath)

        elseif islongpath and math.abs(i - mid) <= 1 then -- Cut more aggressively in the middle
            table.insert(shortsubpaths, subpath:sub(1, opts.minln).."…")

        elseif opts.keeptail and i == #subpaths then -- Spare end subpath of dir
            table.insert(shortsubpaths, subpath)

        elseif #subpath > opts.maxln then -- trim long subpaths
            table.insert(shortsubpaths, subpath:sub(1, opts.maxln).."…")

        else
            table.insert(shortsubpaths, subpath)
        end
    end

    local out = table.concat(shortsubpaths, "/")

    -- Post process
    if isabs then out = "/"..out end
    if hastrailslash then out = out.."/" end

    return out
end

function U.make_path_projr_rel(path, rootpath)
    return path:sub(#rootpath+2)
end

---@param dirpath string
---@param ignore? table
---@return table
function U.get_files_path_in_dir(dirpath, ignore)
    ignore = ignore and ignore or {}

    local files = {}
    for name, type in vim.fs.dir(dirpath) do
        if type == "file" then
            local fpath = dirpath.."/"..name
            local ft    = vim.filetype.match({ filename = fpath })

            if not vim.tbl_contains(ignore, ft) then
                table.insert(files, fpath)
            end
        end
    end

    return files
end

---@param path? string
---@return string
function U.find_proj_rdir(path)
    path = path or vim.fn.getcwd()

    local root = vim.fs.root(path,
        { "Makefile", ".git", "Cargo.toml", "package.json" }
    )

    if root then
        return root
    else
        return vim.fn.getcwd()
    end
end

---@param fpath string
---@return string
function U.get_file_projr_dir(fpath)
    if not fpath or fpath == "" then return vim.fn.getcwd() end

    local froot = vim.fs.root(fpath,
        { "README.md", "Makefile", ".git", "Cargo.toml", "package.json" }
    )

    if froot then
        return froot
    else
        local fdir = vim.fn.fnamemodify(fpath, ':h')
        local stat = vim.uv.fs_stat(fdir)

        if not stat or not stat.type == "directory" then return vim.fn.getcwd() end

        return fdir
    end
end


-- fs
local M = {}

---@param oldpath string
---@param newpath string
function M.rename(oldpath, newpath, force)
    if force == nil then force = false end

    if vim.fn.filereadable(newpath) == 1 and not force then return end

    -- Now rename
    local ret, err = vim.uv.fs_rename(oldpath, newpath)
    if not ret then vim.notify("Rename failed: "..err, vim.log.levels.ERROR) return end

    -- will use oil for now
    -- require("oil.fs").recursive_move("file", oldpath, newpath, vim.schedule_wrap(function(err)
    --     if not err then
    --         vim.notify("File moved successfully!", vim.log.levels.INFO)
    --     else
    --         vim.notify("Error moving file: " .. err, vim.log.levels.ERROR)
    --     end
    -- end))

    -- lsp
    local changes = { files = { {
        oldUri = vim.uri_from_fname(oldpath),
        newUri = vim.uri_from_fname(newpath),
    } } }

    local clients = vim.lsp.get_clients()

    for _, client in ipairs(clients) do
        if client:supports_method("workspace/willRenameFiles") then
            local resp = client:request_sync("workspace/willRenameFiles", changes)
            if resp and resp.result ~= nil then
                vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
            end
        end
    end

    -- Some servers support only didRenameFiles (rare).
    for _, client in ipairs(clients) do
        if client:supports_method("workspace/didRenameFiles") then
            client:notify("workspace/didRenameFiles", changes)
        end
    end
end

---@param target string
function M.file_move_cur_interac(target)
    local fpath = vim.api.nvim_buf_get_name(0)
    local fdir  = vim.fn.fnamemodify(fpath, ":h")
    local fname = vim.fn.fnamemodify(fpath, ":t")

    local function prompt_user()
        vim.ui.input({prompt="Move to: ", default=fdir, completion="dir"},
        function(input)
            vim.api.nvim_command("redraw") -- ensure prompt hidden
            if input == nil then vim.notify("Rename canceled.", vim.log.levels.INFO) return end

            local newfpath = vim.fs.joinpath(input, fname)

            M.rename(fpath, newfpath)

            vim.cmd("e "..newfpath); vim.cmd("e!")
            if vim.bo[0].bufhidden == "" then vim.cmd("silent! bd #") end
            vim.notify('Moved to: "'..input..'"', vim.log.levels.INFO)
        end)
    end
    prompt_user()
end

---@param fpath? string
---@param focus? boolean
function M.file_dup(fpath, focus)
    fpath = fpath or vim.fn.expand("%:p")
    if focus == nil then focus = true end

    local fdir       = vim.fn.fnamemodify(fpath, ":h")
    local fpathnoext = vim.fn.fnamemodify(fpath, ":r")
    local fext       = vim.fn.fnamemodify(fpath, ":e")

    -- Check existing
    local dupfpath = ""

    local fpaths = U.get_files_path_in_dir(fdir)
    local count = 0
    for _, f in ipairs(fpaths) do
        if vim.startswith(vim.fn.fnamemodify(f, ":r"), fpathnoext) then
            count = count + 1
        end
    end

    dupfpath = fpathnoext.."("..tostring(count)..")".."."..fext

    -- write
    vim.fn.writefile(vim.fn.readfile(fpath), dupfpath)

    print("Dup created: "..dupfpath)

    if focus then vim.cmd.edit(dupfpath) end
end

---@param dir? string
---@param focus? boolean
function M.file_create(dir, focus)
    dir = dir or vim.fn.getcwd()
    if focus == nil then focus = true end

    -- auto name
    local nfpath = ""

    nfpath = dir.."/".."newfile"

    local cwdfpaths = U.get_files_path_in_dir(dir)
    local count = 0
    for _, f in ipairs(cwdfpaths) do
        if vim.startswith(f, nfpath) then
            count = count + 1
        end
    end
    local cntstr = count > 0 and tostring("("..count..")") or ""

    nfpath = nfpath..cntstr

    vim.fn.writefile({}, nfpath)

    print("File created: "..nfpath)

    if focus then vim.cmd.edit(nfpath) end
end

function M.append_select_to_file()
    vim.ui.input({prompt="Append selected to: ", default=vim.fn.getcwd(), completion="file"},
    function(input)
        if input == nil then vim.notify("Append canceled. ", vim.log.levels.INFO) return end

        vim.cmd("norm! ")
        local lines = vim.fn.getline("'<","'>")
        vim.fn.writefile(lines, input, "a")
    end)
end

function M.move_select_to_file()
    vim.ui.input({prompt="Move selected to: ", default=vim.fn.getcwd(), completion="file"},
    function(input)
        if input == nil then vim.notify("Move canceled. ", vim.log.levels.INFO) return end

        vim.cmd("norm! ")
        local lines = vim.fn.getline("'<","'>")
        vim.cmd("norm! gvd")
        vim.fn.writefile(lines, input, "a")
    end)
end


-- ### Nav
function M.file_open_next(reverse)
    if reverse == nil then reverse = true end
    local cwd = vim.fn.getcwd()
    local cfpath, cfdir = vim.fn.expand("%:p"), vim.fn.expand("%:p:h")

    local searchdir = cfdir == cwd and cfdir or cwd -- prefering cwd allow more nav freedom

    -- TODO FEAT allow to filter certain files like bin
    local files = {}
    for name, type in vim.fs.dir(searchdir) do
        if type == "file" then table.insert(files, searchdir.."/"..name) end
    end

    -- find curr file index
    table.sort(files)
    local idx = nil
    for i, file in ipairs(files) do
        if file == cfpath then idx = i break end
    end
    if not idx then idx = 1 end -- in case curfile !cwd, fallback to first item

    local nextfid
    if reverse then
        nextfid = math.min(idx+1, #files)
    else
        nextfid = math.max(idx-1, 1)
    end
    -- local previdx = (idx - 2) % #files + 1 -- wraparound
    local prevf  = files[nextfid+1]
    local nextf  = files[nextfid]
    local afterf = files[nextfid-1]

    local prevfname  = prevf and vim.fn.fnamemodify(prevf, ':t') or "   "
    local nextfname  = vim.fn.fnamemodify(nextf, ':t')
    local afterfname = afterf and vim.fn.fnamemodify(afterf, ':t') or " / "

    if nextf and nextf ~= cfpath then
        -- TODO set relevant split unlisted proper
        -- reuse split
        if vim.fn.winlayout()[1] ~= 'leaf' then -- detect if curr tab has split
            local bufid = vim.api.nvim_get_current_buf()
            local wins = vim.fn.win_findbuf(bufid)
            local wcnt = #wins
            if wcnt == 1 then
                vim.bo[bufid].buflisted = false
                vim.bo[bufid].bufhidden = "wipe"
            end
            vim.cmd("e "..nextf); --vim.cmd("e!")
        else -- rem curr buf or let it del itself if it can
            vim.cmd("e " .. nextf); --vim.cmd("e!")
            if vim.bo[0].bufhidden == "" then vim.cmd("silent! bd #") end
        end
    end

    -- ls surrounding files
    local cwdls = {
        "| "..afterfname,
        " | ",
        "*"..nextfname,
        " | ",
        ""..prevfname,
        " | ",
        "["..nextfid.."/"..#files.."]",
    }
    print(table.concat(cwdls, ""))
end


--------
M.utils = U
return M

