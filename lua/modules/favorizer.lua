
-- Favor --
-- Favoritisme --

local M = {}


-- ## [var]
local home = os.getenv("HOME")

M.favdbpath = home .. "/Personal/Org/fav.json"

M.fav = { ["name"] = "path" }

-- local favs = vim.fn.readfile(M.favdbpath)

-- local ok, favs = pcall(vim.fn.json_decode, content)
-- if not ok then favs = {} end


-- ## [lib]
---@return table
function M.read_favdb()
    if not M.favdbpath then
        vim.notify("Could not find favorites database!", vim.log.ERROR)
        return {}
    end

    local data = table.concat(vim.fn.readfile(M.favdbpath), "\n")
    local ok, favs = pcall(vim.fn.json_decode, data)

    if not ok then return {} end

    return favs
end

-- function M.write_favs(tbl)
--     local data = vim.fn.json_encode(tbl)
--     vim.fn.writefile(vim.split(data, "\n"), M.favdbpath)
-- end

---@param favname string
---@param favpath string
function M.add(favname, favpath)
    local favs = M.read_favdb()
    favs[favname] = favpath

    local json = vim.fn.json_encode(favs)

    -- keep human readable formating
    json = json:gsub(",", ",\n"):gsub("{", "{\n"):gsub("}", "\n}")

    vim.fn.writefile(vim.split(json, "\n"), M.favdbpath)

end

---@return table
function M.get_favs()
    local favs = M.read_favdb()
    if favs then
        return favs
    else
        return {}
    end
end

function M.rem(favpath)
    local lines = vim.fn.readfile(M.favdbpath)
    local new_lines = {}

    for _, line in ipairs(lines) do
        if line ~= favpath then
            table.insert(new_lines, line)
        end
    end

    vim.fn.writefile(new_lines, M.favdbpath)
end

---@param favname string
function M.open(favname)
    if not favname then return end

    local favs = M.read_favdb()
    if not favs then return end

    if favs[favname] then
        vim.cmd("e "..favs[favname]) return
    else
        vim.notify("Could not open fav: "..favname..", broken link!", vim.log.WARN)
        return
    end
end


-- ## [cmds]
vim.api.nvim_create_user_command("FavAdd", function(opts)
    M.add(opts.args[1], opts.args[2])
end, {nargs = "?"})

vim.api.nvim_create_user_command("FavRm", function(opts)

end, {nargs = "?"})

vim.api.nvim_create_user_command("FavAddCurFile", function()
    local curfpath = vim.fn.expand("%:p")
    local curfname = vim.fn.expand("%:t")
    M.add(curfname, curfpath)

    print("Adding to fav: " ..'"'..curfpath..'"')
end, {})

vim.api.nvim_create_user_command("FavRemCurFile", function()
    local curfpath = vim.fn.expand("%:p")
    M.rem(curfpath)
    print("Remove from fav: " ..'"'..curfpath..'"')
end, {})

vim.api.nvim_create_user_command("FavOpen", function(opts)
    if not opts.args then
        vim.notify("No favorite to open!", vim.log.levels.ERROR) return
    end

    M.open(opts.args)
end, {nargs="?"})



-- ## [Mapping]
local binds =
{
    ["1"] = "keymaps.lua",
    ["2"] = "common_commands.lua",
    ["3"] = "init.lua",
    ["4"] = "",
    ["5"] = "",
    ["6"] = "",
    ["7"] = "",
    ["8"] = "",
    ["9"] = "",
}

for bind, file in pairs(binds) do
    vim.keymap.set({"i","n","v","c","t"}, "<C-"..bind..">", function()
        M.open(file)
    end)
end



--------
return M

