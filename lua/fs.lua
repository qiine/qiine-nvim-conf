
-- Filesystem --

-- fs utils
local U = {}

---@param dirpath string
---@param ignore? table
---@return table
function U.dir_get_files(dirpath, ignore)
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

-- nav
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
    local prevf = files[nextfid-1]
    local nextf  = files[nextfid]
    local afterf  = files[nextfid+1]

    local prevfname = prevf and vim.fn.fnamemodify(afterf, ':t') or " "
    local nextfname  = vim.fn.fnamemodify(nextf, ':t')
    local afterfname  = prevf and vim.fn.fnamemodify(prevf, ':t') or " "

    if not nextf or nextf == cfpath then return end

    local oldbuf = vim.api.nvim_get_current_buf()
    vim.cmd("e! "..nextf)
    vim.api.nvim_buf_delete(oldbuf, {force=true})

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

