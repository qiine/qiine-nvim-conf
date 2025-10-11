
-- Favor --
-- Favoritisme --

local M = {}


-- ## [var]
----------------------------------------------------------------------
local home = os.getenv("HOME")

M.db_path = home .. "/Personal/Org/fav.json"

-- M.fav = { ["name"] = "path" } --id --group --type

M.quickbinds =
{
    [1] = "keymaps.lua",
    [2] = "common_commands.lua",
    [3] = "Neovim.md",
    [4] = "init.lua",
    [5] = "",
    [6] = "",
    [7] = "",
    [8] = "",
    [9] = "",
}

M.icon_infav    = "★"
M.icon_notinfav = "☆"



-- ## [lib]
----------------------------------------------------------------------
-- ### [Helpers]
local function notif(msg, lvl)
    local sever = {
        debug = vim.log.levels.DEBUG,
        trace = vim.log.levels.TRACE,
        info  = vim.log.levels.INFO,
        err   = vim.log.levels.ERROR,
        warn  = vim.log.levels.WARN,
        off   = vim.log.levels.OFF,
    }

    local level = sever[lvl] or vim.log.levels.INFO
    vim.notify(msg, level)
end


-- ### [I/O]
---@return table
local function check_db()
    if M.db_path then
        return { stat=true, msg="Favorites db ok", loglvl="info"}
    else
        return { stat=false, msg="Could not find fav db!", loglvl="err"}
    end
end

---@return table
local function fetch_db()
    local chkdb = check_db()
    if not chkdb.stat then return { stat=false, msg=chkdb.msg, loglvl="err" } end

    local db_ok, db = pcall(vim.fn.readfile, M.db_path)
    if not db_ok then
        return { stat=false, msg="Could not read database!", loglvl="err", data={} }
    end

    return { stat=true, msg="Database loaded", loglvl="info", data=db }
end

---@return table
local function read()
    local db = fetch_db()
    if not db.stat then return {stat=false, msg=db.msg, loglvl=db.loglvl, data={} } end

    local json_ok, favs = pcall(vim.fn.json_decode, table.concat(db.data, "\n"))
    if not json_ok or type(favs) ~= "table" then
        return { stat=false, msg="Invalid JSON in database", loglvl="err", data={} }
    end

    return { stat=true, msg="", loglvl="info", data=favs }
end

---@param data table
---@return table
local function write(data)
    local cdb = check_db()
    if not cdb.stat then return {stat=false, msg=cdb.msg, loglvl=cdb.loglvl } end

    -- To json frmt
    local json_ok, json = pcall(vim.fn.json_encode, data)
    if not json_ok then return { stat=false, msg="Failed to encode favorites", loglvl="err" } end

    -- Optional, keep human readable formatting
    json = json:gsub(",", ",\n\t"):gsub("{", "{\n\t"):gsub("}", "\n}")

    -- Write
    local lines = vim.split(json, "\n", { plain = true })
    local w_ok, err = pcall(vim.fn.writefile, lines, M.db_path)
    if not w_ok then return { stat=false, msg="Failed to write favorites: ".. tostring(err), loglvl="err" } end

    return { stat=true, msg="Favorites saved", loglvl="info" }
end


-- ### [Manage fav]
---@param db table
---@param name string
---@return boolean
function M.check_is_faved(db, name) return db[name] ~= nil end

---@param name string
---@param path string
function M.add_fav(name, path)
    if not name or name == "" or not path or path == "" then
        return { stat=false, msg="Expect name <name> and <path>", loglvl="err" }
    end

    local res = read()
    if not res.stat then return { stat=false, msg=res.msg, loglvl=res.loglvl } end

    local favs = res.data

    if M.check_is_faved(favs, name) then
        return { stat=false, msg="Already a favorite: \""..name.."\"", loglvl="info" }
    end

    favs[name] = path
    local wf = write(favs)
    if not wf.stat then return {stat=false, msg=wf.msg, loglvl=wf.loglvl } end

    return { stat=true, msg="Added to favorites: \""..name.."\"", loglvl="info" }
end

---@param name string
function M.rem(name)
    if not name or name == "" then return {stat=false, msg="Expect <name>", loglvl="err"} end

    local res = read(); if not res.stat then return {stat=false, msg=res.msg, loglvl=res.loglvl} end

    local favs = res.data

    if not M.check_is_faved(favs, name) then
        return { stat=false, msg="Remove failed, not in favorites: \""..name.."\"", loglvl="info" }
    end

    favs[name] = nil; write(favs) -- rem and writedown

    return { stat=true, msg="Removed favorite: \""..name.."\"", loglvl="info" }
end

---@return table
function M.get_favs()
    local res = read()
    if not res.stat then return {stat=false, msg=res.msg, loglvl=res.loglvl, data={}} end

    return res.data
end

---@return table
function M.get_favs_names()
    local res = read()
    if not res.stat then return {stat=false, msg=res.msg, loglvl=res.loglvl, data={} } end

    return vim.tbl_keys(res.data)
end

---@param name string
function M.open_fav(name)
    if not name or name == "" then
        return {stat=false, msg="Invalid fav name!", loglvl="err"}
    end

    local res = read(); if not res.stat then return {stat=false, msg=res.msg, loglvl=res.loglvl} end

    local favs = res.data
    local path = favs[name]
    if not path or path == "" then
        return {stat=false, msg="Invalid fav path: "..name, loglvl="err"}
    end

    if vim.fn.filereadable(path) ~= 1 then
        return {stat=false, msg="Could not read favorite file!", loglvl="err"}
    end

    vim.cmd("edit "..vim.fn.fnameescape(path)); return {stat=true, msg="Opened favorite: " .. name, loglvl="info"}
end

---@return boolean
function M.check_currfile_in_fav()
    return M.check_is_faved(M.get_favs(), vim.fn.expand("%:t"))
end



-- ## [cmds]
----------------------------------------------------------------------
vim.api.nvim_create_user_command("FavAdd", function(opts)
    local args = vim.split(opts.args, " ", {trimempty = true})

    local path, name

    if #args == 0 then -- Auto pick curr if nothing provided
        path = vim.fn.expand("%:p")
        name = vim.fn.expand("%:t")
    else
        path = args[2]
        name = args[1]
    end

    local res = M.add_fav(name, path)
    notif(res.msg, res.loglvl)
end, {nargs = "*"})

vim.api.nvim_create_user_command("FavRem", function(opts)
    local name

    if opts.args == "" then -- Auto rem curr if no arg
       name = vim.fn.expand("%:t")
    else
       name = opts.args
    end

    local res = M.rem(name);
    notif(res.msg, res.loglvl)
end, {nargs = "*"})

vim.api.nvim_create_user_command("FavOpen", function(opts)
    local res = M.open_fav(opts.args);
    notif(res.msg, res.loglvl)
end, {nargs=1})

vim.api.nvim_create_user_command("FavShowQuickBinds", function()
    local wopts = {}

    wopts.title =  "Quick binds"

    wopts.title_pos = "center"
    wopts.relative  = "editor"
    wopts.border    = "rounded" -- single

    wopts.width  = 35
    wopts.height = 9
    wopts.col = math.floor((vim.o.columns - wopts.width) / 2)
    wopts.row = math.floor((vim.o.lines - wopts.height) / 2)

    local fwin = vim.api.nvim_open_win(0, true, wopts)

    vim.cmd("enew")
    vim.api.nvim_set_option_value("buftype",   "nofile",    {buf=0})
    vim.api.nvim_set_option_value("filetype",  "favorizer", {buf=0})
    vim.api.nvim_set_option_value("buflisted", false,       {buf=0})
    vim.api.nvim_set_option_value("bufhidden", "wipe",      {buf=0})
    vim.opt_local.signcolumn = "no"
    vim.opt_local.number     = false
    vim.opt_local.foldcolumn = "0"

    local binds = {}
    for key, value in ipairs(M.quickbinds) do
        table.insert(binds, "["..key.."]".." = "..value)
    end

    vim.api.nvim_buf_set_lines(0, 0, -1, false, binds)
end, {})



-- debug
vim.api.nvim_create_user_command("FavOpenDB", function()
    vim.cmd("e " .. M.db_path)
end, {})

vim.api.nvim_create_user_command("FavDumpDB", function()
    vim.cmd("enew")

    local favs = M.get_favs_names()

    -- local lines = vim.split(vim.inspect(favs), "\n")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, favs)
end, {})



-- ## [Keymaps]
----------------------------------------------------------------------
-- Speed dial
for bind, file in pairs(M.quickbinds) do
    vim.keymap.set({"i","n","v","c","t"}, "<C-"..bind..">", function() M.open_fav(file) end)
end

vim.keymap.set({"i","n","v"}, "<M-b>a", "<Cmd>FavAdd<CR>")
vim.keymap.set({"i","n","v"}, "<M-b>r", "<Cmd>FavRem<CR>")



--------
return M

