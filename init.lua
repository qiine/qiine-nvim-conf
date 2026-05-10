--███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
--████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
--██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
--██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
--██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
--╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
-- init --
----------------------------------------------------


vim.opt.termguicolors = true


-- Leader key
-- vim.g.mapleader = ""
-- vim.g.maplocalleader = ""


-- [Modules]
----------------------------------------------------------------------
-- This avoid breaking everything when a lua modules has errors
local function safe_require(name)
    local ok, mod = pcall(require, name)
    if not ok then
        vim.notify("Require: "..name..", failed\n"..mod, vim.log.levels.ERROR); return nil
    end
    return mod
end

---@return boolean status
local function safe_setup(name, mod, opts)
    if not mod then
        vim.notify(name.." invalid module", vim.log.levels.WARN); return false
    end

    if type(mod.setup) ~= "function" then
        vim.notify(name.." no setup()!", vim.log.levels.WARN); return false
    end

    local ok, err = pcall(function() mod.setup(opts or {}) end)
    if not ok then
        vim.notify(name.." setup failed:\n"..err, vim.log.levels.ERROR); return false
    end

    return true
end


-- ## [Extensions]
safe_require("modules.enveloppe")
safe_require("modules.historybuf")

local git = safe_require("git"); safe_setup("git", git)
local org = safe_require("org"); safe_setup("org", org)
local ai  = safe_require("ai" ); safe_setup("ai",  ai )


-- ## [Commands]
safe_require("commands")
safe_require("commands_aliases")
safe_require("autocmds")

-- ## [Plugins]
safe_require("options.lazy")

-- ### Built-in plugins
vim.cmd.packadd("nvim.undotree")
vim.cmd.packadd("nvim.difftool")
vim.cmd.packadd("cfilter")


-- ## [options]
safe_require("options.keymaps")
safe_require("options.abbreviations")
safe_require("options.mousemaps")

safe_require("options.rendering")
safe_require("options.internal")
safe_require("options.editing")
safe_require("options.textintel")
local session = safe_require("session"); safe_setup("session", session)

safe_require("options.ui.colors") safe_require("options.ui.conceal")
safe_require("options.ui.colors") safe_require("options.ui.conceal")
safe_require("options.ui.view")
safe_require("options.ui.menus")
safe_require("options.ui.statusline")
safe_require("options.ui.tabs")

-- ## [ui]
safe_require("ui.winbar")
safe_require("ui.quickfix")




