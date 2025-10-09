
-- Favor --
-- Favoritisme --

local M = {}


-- ## [var]
----------------------------------------------------------------------
local home = os.getenv("HOME")

M.db_path = home .. "/Personal/Org/fav.json"

-- M.fav = { ["name"] = "path" } --id --group --type



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
function M.read()
    if not M.db_path then
        notif("Could not find favorites database!", "err") return {}
    end

    local db_ok, data = pcall(vim.fn.readfile, M.db_path)
    if not db_ok then
        notif("Could not read database!", "err") return {}
    end

    local json = table.concat(data, "\n")

    local json_ok, favs = pcall(vim.fn.json_decode, json)
    if not json_ok or type(favs) ~= "table" then
        notif("Invalid JSON in database", "warn") return {}
    end

    return favs
end

function M.write(tbl)
    local json_ok, json = pcall(vim.fn.json_encode, tbl)
    if not json_ok then
        notif("Failed to encode favorites", "err") return
    end

    -- Optional, keep human readable formating
    json = json:gsub(",", ",\n\t"):gsub("{", "{\n\t"):gsub("}", "\n}")

    local lines = vim.split(json, "\n", { plain = true })

    local write_ok, err = pcall(vim.fn.writefile, lines, M.db_path)
    if not write_ok then
        notif("Failed to write favorites: " .. tostring(err), "err") return
    end
end

-- ### [Manage fav]
---@param name string
---@param path string
function M.add(name, path)
    if not name or not path or name == "" or path == "" then
        notif("Usage: FavAdd <name> <path>", "err") return
    end

    local favs = M.read()
    favs[name] = path
    M.write(favs)
    notif("Added to favorite: "..'"'..name..'"', "info")
end

---@param name string
function M.rem(name)
    if not name or name == "" then
        vim.notify("Usage: FavRm <name>", vim.log.levels.ERROR)
        return
    end

    local favs = M.read()
    if favs[name] then
        favs[name] = nil
        M.write(favs)
        notif("Removed favorite: "..'"'..name..'"', "info")
    else
        notif("No such favorite: "..'"'..name..'"', "warn")
    end
end

---@return table
function M.get_names()
    local favs = M.read()

    if not favs then return {} end

    local names = {}
    for key, value in pairs(favs) do
        table.insert(names, key)
    end

    return names
end

---@param name string
function M.open(name)
    if not name or name == "" then
        vim.notify("Invalid favorite name provided", vim.log.levels.ERROR)
        return
    end

    local favs = M.read()
    if not favs then return end

    local path = favs[name]

    if not path or path == "" then
        vim.notify("Invalid favorite file path: " .. name, vim.log.levels.ERROR)
        return
    end

    local fpath_ok = pcall(vim.fn.readfile, path)
    if not fpath_ok then
        vim.notify("Could not read favortie file!", vim.log.levels.ERROR)
        return {}
    end

    vim.cmd("edit " .. vim.fn.fnameescape(path))
end



-- ## [cmds]
----------------------------------------------------------------------
vim.api.nvim_create_user_command("FavAdd", function(opts)
    local args = vim.split(opts.args, " ", {trimempty = true})

    -- Auto pick curr if nothing provided
    if #args == 0 then
        local fpath = vim.fn.expand("%:p")
        local fname = vim.fn.expand("%:t")

        M.add(fname, fpath)
        return
    else
        M.add(args[1], args[2])
    end
end, {nargs = "*"})

vim.api.nvim_create_user_command("FavRem", function(opts)
    -- Auto rem curr if no arg
    if opts.args == "" then
        M.rem(vim.fn.expand("%:t")) return
    else
        M.rem(opts.args)
    end
end, {nargs = "*"})

vim.api.nvim_create_user_command("FavOpen", function(opts)
    M.open(opts.args)
end, {nargs=1})


-- debug
vim.api.nvim_create_user_command("FavOpenDB", function()
    vim.cmd("e " .. M.db_path)
end, {})

vim.api.nvim_create_user_command("FavDumpDB", function()
    vim.cmd("enew")

    local favs = M.get_names()

    -- local lines = vim.split(vim.inspect(favs), "\n")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, favs)
end, {})



-- ## [Keymaps]
----------------------------------------------------------------------
local binds =
{
    ["1"] = "keymaps.lua",
    ["2"] = "common_commands.lua",
    ["3"] = "Neovim.md",
    ["4"] = "init.lua",
    ["5"] = "",
    ["6"] = "",
    ["7"] = "",
    ["8"] = "",
    ["9"] = "",
}

-- Speed dial
for bind, file in pairs(binds) do
    vim.keymap.set({"i","n","v","c","t"}, "<C-"..bind..">", function() M.open(file) end)
end

vim.keymap.set({"i","n","v"}, "<M-b>a", "<Cmd>FavAdd<CR>")
vim.keymap.set({"i","n","v"}, "<M-b>r", "<Cmd>FavRem<CR>")



--------
return M

