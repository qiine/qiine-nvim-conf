
-- Winbar --

local M = {}

-- theme
vim.api.nvim_set_hl(0, "WinBar", { fg = "#595959", bg = "#e6e6e6", bold = false })
vim.api.nvim_set_hl(0, "WinBarNC", { fg = "#595959", bg = "#e6e6e6" })


-- ## [Components]
function M.nvim_logo()
    _G.winbar_say_neovim = function()
        print(" NEOVIM! ")
    end

    return "%@v:lua.winbar_say_neovim@%X"   --
end

function M.toggle_filebrowser() --toggle neotree
    _G.winbar_neotree_toggle = function()
        vim.cmd("Neotree toggle")
    end

    return "%@v:lua.winbar_neotree_toggle@ ⇥ %X"
end

-- fpath
---@return string
function M.path_bar()
    -- fdir = vim.fs.normalize(vim.trim(fdir))
    -- vim.fs.abspath(path)

    local fpath = vim.fn.expand("%:p")
    local fdir  = vim.fn.expand("%:p:h")
    local fname  = vim.fn.expand("%:p:t")

    local path = fpath
    if vim.bo.filetype == "oil" then path = vim.fn.getcwd() end

    local is_narrowin = vim.api.nvim_win_get_width(0) < 60

    local barpath = ""

    if #fdir > 75 or is_narrowin then
        barpath = vim.fn.pathshorten(path, 1)
    else
        barpath = path
    end

    local pathchevrons = barpath:gsub("/", "🮥 ")   --› > 〉  › ›

    _G.winbar_path_toclipboard = function()
        vim.fn.setreg("+", fpath); print("path copied") -- always ues abs fpath, the more useful
    end

    return "%@v:lua.winbar_path_toclipboard@"..pathchevrons.."%X"
end

function M.favs()
    local favz = require("modules.favorizer")

    if favz.check_file_infavs() then
        return favz.icon_infav
    else
        return favz.icon_notinfav
    end
end

function M.burger() -- burger
    _G.winbar_burger_toggle = function()
        local path = vim.fn.stdpath("config").."/init.lua"
        vim.cmd("e "..path)
    end

    return "%@v:lua.winbar_burger_toggle@".."≡".."%X"
end


function M.draw()
    -- local out = {}
    -- for _, item in ipairs(M.winbar_comps) do
    --     if type(item) == "function" then
    --         local ok, res = pcall(item)
    --         if ok and res then
    --             table.insert(out, res)
    --         end
    --     else
    --         table.insert(out, item)
    --     end
    -- end

    -- return table.concat(out, "")
    return table.concat({
    " ",
    M.nvim_logo(),
    " ",
    M.toggle_filebrowser(),
    M.path_bar(),

    "%=", --middle split

    M.favs(),
    " ",
    M.burger(),
    " ",
}, "")
end

function M.show()  vim.o.winbar = M.draw() end
function M.clear() vim.o.winbar = ""       end

M.excluded_filetype = {
    "help",
    "vim",
    "qf",
    "trouble",
    "neo-tree",
    "dashboard",
    "alpha",
    "Outline",
}

M.excluded_buftype = {
    "terminal",
    "prompt"
}


-- cmds
vim.api.nvim_create_user_command("WinbarShow", function()
    M.show()
end, {})

vim.api.nvim_create_user_command("WinbarClear", function()
    M.clear()
end, {})


-- autocmds
vim.api.nvim_create_autocmd({"WinEnter", "BufWinEnter"}, {
    group    = "UserAutoCmds",
    callback = function(args)
        vim.defer_fn(function()
            -- win
            -- prevent errors with very small windows
            if vim.api.nvim_win_get_height(0) < 5 then return end

            -- off in floatwin
            if vim.api.nvim_win_get_config(0).relative ~= "" then
                vim.opt_local.winbar = nil return
            end


            -- buff
            if vim.tbl_contains(M.excluded_buftype, vim.bo.buftype) then
                vim.opt_local.winbar = nil return
            end

            -- if not vim.api.nvim_get_option_value("buflisted",  {buf=0}) then
            --     vim.opt_local.winbar = nil return
            -- end

            -- off in diff mode
            if vim.wo[0].diff then vim.opt_local.winbar = nil return end


            -- ft
            if vim.tbl_contains(M.excluded_filetype, vim.bo.filetype) then
                vim.opt_local.winbar = nil return
            end

            -- TODO Smarter way to redraw winbar taht allow to turn it off
            -- bo a given buffer
            vim.wo.winbar = M.draw()
        end, 5)  -- give time for proper buftype update
    end,
})


return M
