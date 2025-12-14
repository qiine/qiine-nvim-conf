
--███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
--████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
--██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
--██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
--██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
--╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
-- init --
----------------------------------------------------

-- vim.opt.shell = "bash" -- dash

--vim.opt.termguicolors controls whether 24-bit RGB color (true color) is used in the terminal.
--If curr term support termguicolors, COLORTERM environment variable will return truecolor regardless.
--Warning some themes auto set termguicolors to true !
--To check termguicolors status:
--lua print(vim.opt.termguicolors:get())
--for COLORTERM
--lua print(vim.fn.getenv("COLORTERM"))
if vim.fn.getenv("COLORTERM") == "truecolor" then   --smart set termguicolors
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
local function safe_require(module)
    local ok, res = pcall(require, module)
    if not ok then
        vim.notify("error: in "..module.."\n"..res, vim.log.levels.ERROR)
        return nil
    end

    return res
end

-- ## Custom modules
safe_require("modules.enveloppe")
safe_require("modules.tiny-session")
safe_require("modules.historybuf")
safe_require("modules.favorizer")
safe_require("modules.arbores")
safe_require("modules.planv")

-- ## Commands
safe_require("commands")
safe_require("commands_aliases")
safe_require("autocmds")

-- ## Plugins
safe_require("options.lazy")

safe_require("options.keymaps")
safe_require("options.abbreviations")
safe_require("options.mousemaps")

-- ## options
safe_require("options.internal")
safe_require("options.editing")
safe_require("options.textintel")
safe_require("options.ui.theme")
safe_require("options.ui.conceal")
safe_require("options.ui.view")
safe_require("options.ui.menus")
safe_require("options.ui.statusline")

-- ## ui
safe_require("ui.winbar")
safe_require("ui.quickfix")




