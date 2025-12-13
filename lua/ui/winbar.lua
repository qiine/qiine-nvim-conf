
-- Winbar --

local fs = require("fs")

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
    local fname = vim.fn.expand("%:p:t")

    local wwidth = vim.api.nvim_win_get_width(0)
    local is_narrowin = wwidth < 65

    -- Process bar path
    local barpath = ""

    barpath = fpath
    if vim.bo.filetype == "oil" then barpath = vim.fn.getcwd() end

    -- Shorten
    barpath = vim.fn.fnamemodify(barpath, ":~")

    if #fpath > 75 or (#fpath > math.floor(wwidth*0.80)) then
        barpath = fs.utils.path_compress(barpath)
    end

    local pathchevrons = barpath:gsub("/", "🮥 ")   --› > 〉  › ›

    -- click func
    _G.winbar_path_toclipboard = function()
        vim.fn.setreg("+", fpath); print("path copied") -- always use abs fpath, bcs more useful imao
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
    "OverseerList",
    "msglog",
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

            if vim.w[0].type == "drawer" then
                vim.opt_local.winbar = nil return
            end

            -- buff
            -- ignore buftype
            if vim.tbl_contains(M.excluded_buftype, vim.bo.buftype) then
                vim.opt_local.winbar = nil return
            end

            -- probably don't need winbar here
            if  vim.bo.buftype == "nofile"         and
                vim.api.nvim_buf_get_name(0) == "" and
                vim.bo[0].bufhidden == "wipe"      then

                vim.opt_local.winbar = nil return
            end

            -- if not vim.api.nvim_get_option_value("buflisted",  {buf=0}) then
            --     vim.opt_local.winbar = nil return
            -- end

            -- off in diff mode
            if vim.wo[0].diff then vim.opt_local.winbar = nil return end


            -- ft
            -- ignore ftype
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
