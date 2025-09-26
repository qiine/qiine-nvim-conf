
--███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
--████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
--██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
--██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
--██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
--╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
-- init --
----------------------------------------------------

--vim.opt.shell = "bash"

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

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank({higroup='Visual', timeout = 185})
    end,
})



-------------------------------

-- This avoid breaking everything when a lua modules has errors
local function safe_require(module_name)
    local status, module = pcall(require, module_name)
    if not status then
        vim.notify(
            "Error with module: '" .. module_name .. "'\n" .. module .. "\nmodule loading aborted",
            vim.log.levels.ERROR
        )
        return nil
    end

    return module
end

-- ## Custom modules
local module   --will hold special local modules

module = safe_require("modules.nenveloppe") if module then module.setup() end
-- module = safe_require("modules.dialeur.dialeur") if module then module.setup() end
safe_require("modules.tiny-session")
safe_require("modules.rouleau-nvim")
safe_require("modules.historybuf")
safe_require("modules.planv")

-- ## Commands
safe_require("utils.common_commands")
safe_require("utils.commands_aliases")
safe_require("utils.common_autocmds")

-- ## Plugins
safe_require("options.lazy")

safe_require("options.keymaps")
safe_require("options.mousemaps")

-- ## options
safe_require("options.internal")
safe_require("options.editing")

-- ### ui
safe_require("options.ui.theme")
safe_require("options.ui.conceal")
safe_require("options.ui.view")
safe_require("options.ui.menus")
safe_require("options.ui.winbar")
safe_require("options.ui.statusline")



-- Debug messages on errors
vim.api.nvim_create_autocmd("Vimenter", {
     pattern = "*",
     callback = function()
         vim.cmd("messages")
     end,
})

