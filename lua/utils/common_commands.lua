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

--Quick ressource
vim.api.nvim_create_user_command("RessourceCurrent", function()
    local currf = vim.fn.expand("%:p")
    vim.cmd("source " .. currf)
end, {})

--Restart
vim.api.nvim_create_user_command("Restart", function()
    local curfile = vim.fn.expand("%:p") -- Get the current file location
    local nvim_command = "nvim " .. curfile

    -- Stop all LSP clients
    for _, client in ipairs(vim.lsp.get_active_clients()) do
        client.stop()
    end

    vim.loop.spawn("wezterm", { args = { "-e", "nvim", curfile } })
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

    -- Check if plugin already installed
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

--Handy goto vline
vim.api.nvim_create_user_command("ToVLine", function()
    vapi.nvim_feedkeys(
        vapi.nvim_replace_termcodes("<S-V>", true, true, true),
        "n",
        true
    )
end, {})

--[Editing]
--Trim select, include tab and break lines
vim.api.nvim_create_user_command("TrimWhitespacesSelection", function(opts)
    vim.cmd(string.format("s/\\s//g"))
    vim.cmd("normal! <esc>")
end, { range = true })

vim.api.nvim_create_user_command("ToggleEndOfLineChar", function()
    local listchars = vim.opt.listchars:get()

    if listchars.eol == "¶" then
        vim.opt.listchars:remove("eol")
        vim.g.show_eol = false
    else
        vim.opt.listchars:append({ eol = "¶" })
        vim.g.show_eol = true
    end
end, {})

--[Formating]
--Format whole buff using conform.nvim
vim.api.nvim_create_user_command("FormatBuffer", function()
    require("conform").format()
end, {})

vim.api.nvim_create_user_command("FormatSelected", function()
    require("conform").format()
end, { range = true })

--wrap line into paragraph
vim.api.nvim_create_user_command("WrapSelection", function()
    vim.cmd("normal! gww")
end, { range = true })

