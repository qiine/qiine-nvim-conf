--winbar

vim.api.nvim_set_hl(0, "WinBar", { fg = "#737373", bg = "NONE", bold = false })
vim.api.nvim_set_hl(0, "WinBarNC", { fg = "#737373", bg = "NONE" })

--_G.on_click_handle = function(minwid, clicks, button, mods)
--    print("You clicked the 📁 icon!")
--end

local function toggle_filebrowser() --toggle neotree
    --return "%@v:lua.require('config.ui.winbar').on_click_handler@%"..">>"
    --return "%@v:lua.print('hello')@%T".."⇥"
    return "⇥"
    --on_click=function() vim.cmd("Neotree toggle") end,
end

local function path_bar() --path
    local cf = vim.fn.expand("%:p")
    local dir = vim.fn.fnamemodify(cf, ":h")
    local home = vim.fn.expand("~")
    local short = vim.fn.substitute(dir, "^" .. vim.fn.escape(home, "\\") .. "/", "~/", "")
    --vim.fn.pathshorten
    local fancy = short:gsub("/", "🮥 ") --› > 〉  › ›
    return "📁│"..fancy..""  --/.
end

local function fav() --add to favorite butt
    return "☆" --☆ ★
end

local function burger() --burger
    return "≡"
end

--render all
local function render()
    return table.concat({
        "     ",
        toggle_filebrowser(),
        " ",
        path_bar(),

        "%=", --middle split

        fav(),
        " ",
        burger()
    })
end

--attach
vim.api.nvim_create_autocmd({ "BufNew", "BufWinEnter", "WinEnter" }, {
    group    = "UserAutoCmds",
    pattern  = "*",
    callback = function()
        vim.wo.winbar = require("config.ui.winbar").render()
    end,
})

return { render = render }




--local M = {}
--- Window bar that shows the current file path (in a fancy way).
---@return string
--function M.render()
--    -- Get the path and expand variables.
--    local path = vim.fs.normalize(vim.fn.expand '%:p' --[[@as string]])

--    -- Replace slashes by arrows.
--    local separator = ' %#WinbarSeparator# '

--    local prefix, prefix_path = '', ''

--    -- If the window gets too narrow, shorten the path and drop the prefix.
--    if vim.api.nvim_win_get_width(0) < math.floor(vim.o.columns / 3) then
--        path = vim.fn.pathshorten(path)
--    else
--        -- For some special folders, add a prefix instead of the full path (making
--        -- sure to pick the longest prefix).
--        ---@type table<string, string>
--        local special_dirs = {
--            CODE = vim.g.projects_dir,
--            -- stylua: ignore
--            DOTFILES = vim.fn.stdpath 'config' --[[@as string]],
--            HOME = vim.env.HOME,
--            PERSONAL = vim.g.personal_projects_dir,
--        }
--        for dir_name, dir_path in pairs(special_dirs) do
--            if vim.startswith(path, vim.fs.normalize(dir_path)) and #dir_path > #prefix_path then
--                prefix, prefix_path = dir_name, dir_path
--            end
--        end
--        if prefix ~= '' then
--            path = path:gsub('^' .. prefix_path, '')
--            prefix = string.format('%%#WinBarSpecial#%s %s%s', "V", prefix, separator)
--        end
--    end

--    -- Remove leading slash.
--    path = path:gsub('^/', '')

--    return table.concat {
--        ' ',
--        prefix,
--        table.concat(
--            vim.tbl_map(function(segment)
--                return string.format('%%#Winbar#%s', segment)
--            end, vim.split(path, '/')),
--            separator
--        )
--    }
--end


--vim.api.nvim_create_autocmd('BufWinEnter', {
--    group = vim.api.nvim_create_augroup('mariasolos/winbar', { clear = true }),
--    desc = 'Attach winbar',
--    callback = function(args)
--        if
--            not vim.api.nvim_win_get_config(0).zindex -- Not a floating window
--            and vim.bo[args.buf].buftype == '' -- Normal buffer
--            and vim.api.nvim_buf_get_name(args.buf) ~= '' -- Has a file name
--            and not vim.wo[0].diff -- Not in diff mode
--            then
--                vim.wo.winbar = "%{%v:lua.require'winbar'.render()%}"
--            end
--        end,
--})

--return M
