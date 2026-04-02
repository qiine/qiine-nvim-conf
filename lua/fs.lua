
-- Filesystem --

-- fs utils
local U = {}

-- ## Path
function U.has_trailslash(path)
    return path:sub(-1) == "/"
end

---@param path string
function U.is_dir(path)
    if not path then return false end

    path = vim.fs.normalize(path)

    return vim.fn.isdirectory(path) == 1 or U.has_trailslash(path)
    -- local ok, stat = pcall(vim.uv.fs_stat, path)
    -- return ok and stat and stat.type == "directory"
end

---@param path string
function U.is_dir_valid(path)
    if not path or vim.fn.filereadable(path) then return false end

    path = vim.fs.normalize(path)

    return vim.fn.isdirectory(path) == 1 or U.has_trailslash(path)
end

function U.is_home_rel(path)
    return path:sub(1, 2) == "~/"
end

function U.is_abspath_inhome(path)
    local home = vim.fn.fnamemodify(path, ":~")
    return path ~= home
end

function U.is_abs(path)
    return path:sub(1, 1) == "/"
end

---Shorten path by cuting each subpath based on their length.
---
---It can shorten even more by cutting subpath at the middle more.
---Also has the ability to convert an abs path into home relative one.
---Configurable, keep relevant starting subpath and/or preserve file name+extension.
---
---@class pathcompress_opts
---@field minln number
---@field maxln number
---@field keepstart boolean
---@field keeptail boolean
---@field make_homerel boolean
---@field longpathlen number
---@field compressratio number
---@field replacestring string
---
---@param path string
---@param opts pathcompress_opts @compression settings
---@return string|nil
function U.path_compress(path, opts)
    local defopts = {
        minln         = 2,
        maxln         = 3,
        keepstart     = true,
        keeptail      = true,
        make_homerel  = true,
        longpathlen   = 78,
        compressratio = 0.4,
        replacestring = "…",
    }
    opts = vim.tbl_deep_extend("force", defopts, opts or {})

    if not path then return nil end
    if path == "" or path == "/" or path == "~/" or path == "~" then return path end

    -- Sanitize path
    path = vim.fs.normalize(vim.fn.expand(vim.trim(path)))

    if opts.make_homerel then path = vim.fn.fnamemodify(path, ":~") end

    local is_abs         = U.is_abs(path)
    local is_home_rel    = U.is_home_rel(path)
    local is_longpath    = #path > opts.longpathlen
    local has_trailslash = U.has_trailslash(path)

    -- Cut path into pieces
    if     is_abs      then path = path:sub(2)
    elseif is_home_rel then path = path:sub(3) end

    if has_trailslash  then path = path:sub(1, #path-1) end -- Avoids empty last item

    local subpaths = vim.split(path, "/", {plain=true})

    local function in_compress_range(i, ln, ratio)
        local band_size  = math.max(1, math.floor(ln * ratio))
        local band_start = math.floor((ln - band_size) / 2) + 1
        local band_end   = band_start + band_size - 1

        return i >= band_start and i <= band_end
    end

    local shortsubpaths = {}
    for i, subpath in ipairs(subpaths) do
        if opts.keepstart and i == 1 then -- Keep first, makes path easier to read
            table.insert(shortsubpaths, subpath)

        elseif is_longpath and in_compress_range(i, #subpaths, opts.compressratio) then
            table.insert(shortsubpaths, subpath:sub(1, opts.minln)..opts.replacestring)

        elseif opts.keeptail and i == #subpaths then -- Spare path end
            table.insert(shortsubpaths, subpath)

        elseif #subpath > opts.maxln then -- trim long subpaths
            table.insert(shortsubpaths, subpath:sub(1, opts.maxln)..opts.replacestring)

        else
            table.insert(shortsubpaths, subpath)
        end
    end
    local out = table.concat(shortsubpaths, "/")

    -- Post process
    if is_abs         then out = "/"..out  end
    if is_home_rel    then out = "~/"..out end
    if has_trailslash then out = out.."/"  end

    return out
end

---@param path string
---@return string|nil
function U.find_proj_rootdir_for_path(path)
    if not path then return nil end

    return vim.fs.root(
        path,
        {"Makefile", ".git", "Cargo.toml", "package.json"}
    )
    or nil
end

---@param path? string
---@return string|nil
function U.find_proj_root_for_file(path)
    if not path then return nil end

    local froot = vim.fs.root(path,
        { "README.md", "Makefile", ".git", "Cargo.toml", "package.json" }
    )

    if froot then
        return froot
    else
        local fdir = vim.fn.fnamemodify(path, ':h')
        local stat = vim.uv.fs_stat(fdir)

        if not stat or not stat.type == "directory" then return vim.fn.getcwd() end

        return fdir
    end
end

function U.make_path_projroot_rel(path, rootpath)
    return path:sub(#rootpath+2)
end


-- ## Files
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

---@param path string
---@return boolean|nil
function U.is_bin(path)
    if vim.fn.filereadable(path) ~= 1 then return nil end

    local res = vim.system(
        { "file", "-b", "--mime", path },
        { text = true }
    ):wait()

    if res.code ~= 0 or not res.stdout then return nil end

    local restrim = vim.fn.trim(res.stdout)

    return restrim:find("charset=binary") ~= nil
end



-- fs
local M = {}

---@param dir? string
---@param focus? boolean
function M.file_create(name, dir, focus)
    name = (name ~= nil or name == "") or "newfile"
    dir = dir or vim.fn.getcwd()
    if focus == nil then focus = true end

    local fpath = ""

    fpath = dir.."/"..name

    -- auto name
    local cwdfpaths = U.get_files_path_in_dir(dir)
    local count = 0
    for _, f in ipairs(cwdfpaths) do
        if vim.startswith(f, fpath) then
            count = count + 1
        end
    end
    local cntstr = count > 0 and tostring("("..count..")") or ""

    fpath = fpath..cntstr

    vim.fn.writefile({}, fpath)

    print("File created: "..fpath)

    if focus then vim.cmd.edit(fpath) end
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

---@param name string
---@param newname string
---@param force boolean? @Default false
---@param verbose boolean? @Default true
function M.rename(name, newname, force, verbose)
    if force == nil then force = false end
    if verbose == nil then verbose = true end

    if vim.fn.filereadable(newname) == 1 and not force then
        if verbose then vim.notify("Rename failed file with same name", vim.log.levels.ERROR) end
        return false
    end

    -- Now rename
    local res = vim.system({ "mv", "-f", name, newname }):wait()
    if res.code ~= 0 then
        vim.notify("Rename failed: "..res.stderr, vim.log.levels.ERROR)
        return false
    end

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
        oldUri = vim.uri_from_fname(name),
        newUri = vim.uri_from_fname(newname),
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

    if verbose then vim.notify("New name: "..vim.fn.fnamemodify(newname, ':t'), vim.log.levels.INFO) end
    return true
end

---@param src string
---@param dest string
---@param force boolean? @Default false
---@param verbose boolean? @Default true
function M.move(src, dest, force, verbose)
    if force == nil then force = false end
    if verbose == nil then verbose = true end

    local res = M.rename(src, dest, force, false)

    if verbose then
        vim.notify("Moved to: "..dest, vim.log.levels.INFO)
    end
end

function M.append_selection_to_file()
    vim.ui.input({prompt="Append selected to: ", default=vim.fn.getcwd(), completion="file"},
    function(input)
        if input == nil then vim.notify("Append canceled. ", vim.log.levels.INFO) return end

        vim.cmd("norm! ")
        local lines = vim.fn.getline("'<","'>")
        vim.fn.writefile(lines, input, "a")
    end)
end

function M.move_selection_to_file()
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
    if reverse == nil then reverse = false end

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
            vim.cmd("e "..nextf); --vim.cmd("e!")
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

function M.explorer_open_inplace(dir)
    dir = dir and vim.fs.normalize(dir) or nil

    local buf     = vim.api.nvim_get_current_buf()
    local bufpath = vim.api.nvim_buf_get_name(buf)
    local bufname = vim.fn.fnamemodify(bufpath, ":t")
    local bufdir  = vim.fn.expand("%:p:h")

    local bufhasfile = vim.fn.filereadable(bufpath) == 1

    local bufwincnt = #(vim.fn.win_findbuf(buf))
    local bufhidden = vim.bo[buf].bufhidden ~= ""

    local targetdir
    if dir and vim.uv.fs_stat(dir) ~= nil then
        targetdir = dir
    elseif bufhasfile and bufdir then -- try fallback to buf file dir
        targetdir = bufdir
    else
        targetdir = vim.fn.getcwd()
    end

    vim.cmd("cd "..targetdir)

    require("oil").open(
        targetdir,
        nil,
        function()
            if bufhidden then return end

            if vim.fn.winlayout()[1] ~= "leaf" then -- detect if curr tab has splits
                if bufwincnt > 1 then return end   -- avoids destroying buf we want to keep

                vim.bo[0].buflisted = false
            end

            vim.cmd("silent! bd "..buf)

            -- Place cursor on curr fname if applicable
            vim.cmd("normal! gg")
            vim.cmd([[silent! /\V\<]]..bufname..[[\>]])
            vim.cmd([[silent! /\V\<]]..bufname..[[\>]])
            vim.cmd("noh")
        end
    )
end


--------
M.utils = U
return M

