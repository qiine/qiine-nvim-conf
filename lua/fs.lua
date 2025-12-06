
-- Filesystem --

-- fs utils
local U = {}

---@param dirpath string
---@param ignore? table
---@return table
function U.dir_get_files_path(dirpath, ignore)
    ignore = ignore and ignore or {}

    local files = {}
    for name, type in vim.fs.dir(dirpath) do
        if type == "file" then
            local fpath =  dirpath.."/"..name
            local ft    = vim.filetype.match({ filename = fpath })

            if not vim.tbl_contains(ignore, ft) then
                table.insert(files, fpath)
            end
        end
    end

    return files
end


-- fs
local M = {}
---@param fpath? string
---@param focus? boolean
function M.File_Dup(fpath, focus)
    fpath = fpath or vim.fn.expand("%:p")
    if focus == nil then focus = true end

    local fdir       = vim.fn.fnamemodify(fpath, ":h")
    local fpathnoext = vim.fn.fnamemodify(fpath, ":r")
    local fext       = vim.fn.fnamemodify(fpath, ":e")

    -- Check existing
    local dupfpath = ""

    local fpaths = U.dir_get_files_path(fdir)
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
function M.File_Create(dir, focus)
    dir = dir or vim.fn.getcwd()
    if focus == nil then focus = true end

    -- auto name
    local nfpath = ""

    nfpath = dir.."/".."newfile"

    local cwdfpaths = U.dir_get_files_path(dir)
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
    reverse = reverse or false

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
    local prevf = files[nextfid+1]
    local nextf  = files[nextfid]
    local afterf  = files[nextfid-1]

    local prevfname = prevf and vim.fn.fnamemodify(prevf, ':t') or "   "
    local nextfname  = vim.fn.fnamemodify(nextf, ':t')
    local afterfname  = afterf and vim.fn.fnamemodify(afterf, ':t') or " / "

    if nextf and nextf ~= cfpath then
        local curbufh = vim.bo[0].bufhidden

        vim.cmd("e! " .. nextf)
        -- rem curr buf or let it del itself if it can
        if curbufh == "" then vim.cmd("silent! bd #") end
    end

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

