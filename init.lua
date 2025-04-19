
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

vim.opt.encoding = "UTF-8"


-------------------------------


local function safe_require(module_name)
    local status, err = pcall(require, module_name)
    if not status then
        vim.notify(
            "Error with module: '"..module_name.."'\n"..err.."\nmodule loading aborted",
            vim.log.levels.ERROR
        )
    end
end

safe_require("modules.tinysession")

safe_require("utils.common_commands")
safe_require("utils.commands_aliases")
safe_require("utils.common_autocmds")

safe_require("config.lazy") --plugins

safe_require("config.keymaps")
safe_require("config.mousemaps")

--settings
safe_require("config.settings")

safe_require("config.ui.editor")
safe_require("config.ui.view")
safe_require("config.ui.menus")
safe_require("config.ui.theme")


--debug messages
vim.api.nvim_create_autocmd("Vimenter", {
     pattern = "*",
     callback = function()
         vim.cmd("messages")
     end,
})

-------------------------------


--neovide
-- if vim.g.neovide then
--     vim.g.neovide_position_animation_length = 0
--     vim.g.neovide_cursor_animation_length = 0.00
--     vim.g.neovide_cursor_trail_size = 0
--     vim.g.neovide_cursor_animate_in_insert_mode = false
--     vim.g.neovide_cursor_animate_command_line = false
--     vim.g.neovide_scroll_animation_far_lines = 0
--     vim.g.neovide_scroll_animation_length = 0.00
--
--
--     vim.g.neovide_scale_factor = 1.0
--
--     local change_scale_factor = function(delta)
--         vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
--     end
--
--     vim.keymap.set("n", "<C-+>", function()
--         change_scale_factor(1.25)
--     end)
--
--     vim.keymap.set("n", "<C--", function()
--         change_scale_factor(1/1.25)
--     end)
-- end


