
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
local function pcall_require(module)
    local ok, res = pcall(require, module)
    if not ok then
        vim.notify("error: "..res.."\n", vim.log.levels.ERROR)
        return nil
    end

    return res
end

-- ## Modules
pcall_require("session").setup()
pcall_require("modules.enveloppe")
pcall_require("modules.historybuf")
pcall_require("modules.favorizer")
pcall_require("modules.arbores")
pcall_require("modules.lsvi")

pcall_require("org").setup()
pcall_require("git").setup()
pcall_require("ai")

-- ## Commands
pcall_require("commands")
pcall_require("commands_aliases")
pcall_require("autocmds")

-- ## Plugins
pcall_require("options.lazy")

vim.cmd('packadd nvim.undotree')
vim.cmd('packadd nvim.difftool')


-- ## options
pcall_require("options.keymaps")
pcall_require("options.abbreviations")
pcall_require("options.mousemaps")

pcall_require("options.internal")
pcall_require("options.editing")
pcall_require("options.textintel")

pcall_require("options.ui.theme")
pcall_require("options.ui.conceal")
pcall_require("options.ui.view")
pcall_require("options.ui.menus")
pcall_require("options.ui.statusline")
pcall_require("options.ui.tabs")

-- ## ui
pcall_require("ui.winbar")
pcall_require("ui.quickfix")




