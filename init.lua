
--███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
--████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
--██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
--██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
--██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
--╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
-- init --
----------------------------------------------------


-- vim.opt.termguicolors controls whether 24-bit RGB color (true color) is used in the terminal.
-- If curr term support termguicolors, COLORTERM environment variable will return truecolor regardless.
-- Warning some themes auto set termguicolors to true !
-- To check termguicolors status:
-- lua print(vim.opt.termguicolors:get())
-- for COLORTERM
-- lua print(vim.fn.getenv("COLORTERM"))
if vim.fn.getenv("COLORTERM") == "truecolor" then   -- smart set termguicolors
    vim.opt.termguicolors = true
else
    vim.opt.termguicolors = false --for tty
end


-- Leader key
-- vim.g.mapleader = ""
-- vim.g.maplocalleader = ""


-- [Modules]
----------------------------------------------------------------------
-- This avoid breaking everything when a lua modules has errors
local function safe_require(name)
    local ok, mod = pcall(require, name)
    if not ok then
        vim.notify("Require: "..name..", failed\n"..mod, vim.log.levels.ERROR)
        return nil
    end
    return mod
end

---@return boolean status
local function safe_setup(name, mod, opts)
    if not mod then
        vim.notify(name.." invalid module", vim.log.levels.WARN)
        return false
    end

    if type(mod.setup) ~= "function" then
        vim.notify(name.." No setup()!", vim.log.levels.WARN)
        return false
    end

    local ok, err = pcall(function() mod.setup(opts or {}) end)
    if not ok then
        vim.notify(name.." Setup failed\n"..err, vim.log.levels.ERROR)
        return false
    end

    return true
end

-- ## Extensions
safe_require("modules.enveloppe")
safe_require("modules.historybuf")
safe_require("modules.favorizer")
safe_require("modules.arbores")
safe_require("modules.lsvi")

local org = safe_require("org"); safe_setup("org", org)
local git = safe_require("git"); safe_setup("git", git)
safe_require("ai")

-- ## Commands
safe_require("commands")
safe_require("commands_aliases")
safe_require("autocmds")

-- ## Plugins
safe_require("options.lazy")

vim.cmd('packadd nvim.undotree')
vim.cmd('packadd nvim.difftool')


-- ## options
safe_require("options.keymaps")
safe_require("options.abbreviations")
safe_require("options.mousemaps")

safe_require("options.internal")
safe_require("options.editing")
safe_require("options.textintel")
safe_require("session").setup()

safe_require("options.ui.theme")
safe_require("options.ui.conceal")
safe_require("options.ui.view")
safe_require("options.ui.menus")
safe_require("options.ui.statusline")
safe_require("options.ui.tabs")

-- ## ui
safe_require("ui.winbar")
safe_require("ui.quickfix")




