
-- Panneau

local M = {}

local pan_content = {}

local header = {
    "███╗   ██╗██╗   ██╗██╗███╗   ███╗",
    "████╗  ██║██║   ██║██║████╗ ████║",
    "██╔██╗ ██║██║   ██║██║██╔████╔██║",
    "██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
    "██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
    "╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
}


-- helper to center text based on window width
local function center_text(text)
    local width = vim.api.nvim_get_option_value("columns", {})
    local padding = math.floor((width - #text) / 2)
    return string.rep(" ", math.max(padding, 0)) .. text
end

function M.button(txt, keybind, opts)
    local def_opts = {
        cursor   = 2,
        position = "center",
        width    = 45,
        align_shortcut = "right",
        hl_shortcut = "AlphaButtonShortcut",
        hl          = "AlphaButton",
    }

end


local menu = {
    { "n", "  New File", ":enew<CR>" },
    { "f", "󰈞  Find File", ":Telescope find_files<CR>" },
    { "r", "󰄉  Recent Files", ":Telescope oldfiles<CR>" },
    { "q", "󰅚  Quit", ":qa!<CR>" },
}

-- setup mappings
-- for _, item in ipairs(menu) do
--     vim.keymap.set("n", item[1], item[3], { buffer = buf, nowait = true, silent = true })
-- end

function M.open_panneau()
    local panbuf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(panbuf)


    for _, l in ipairs(header) do
        table.insert(pan_content, l)
    end

    table.insert(pan_content, "Neovim is awesome")
    table.insert(pan_content, "")


    vim.api.nvim_buf_set_lines(panbuf, 0, -1, false, pan_content)

    -- vim.bo[buf].bufhidden = "wipe"
    vim.opt_local.wrap       = false
    vim.opt_local.spell      = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.number     = false
    vim.opt_local.foldcolumn = "0"

    vim.api.nvim_set_option_value("buftype", "nofile", { buf = panbuf })
    vim.api.nvim_set_option_value("filetype", "dashboard", { buf = panbuf })
    vim.bo[panbuf].modifiable = false
end

-- -- open automatically if no file passed on startup
-- function M.setup()
--     vim.api.nvim_create_autocmd("VimEnter", {
--         callback = function()
--             if vim.fn.argc() == 0 then
--                 M.open()
--             end
--         end
--     })
-- end

vim.api.nvim_create_user_command("PanneauOpen", function()
    M.open_panneau()
end, {})



return M

