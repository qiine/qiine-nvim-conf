
-- drawer --

local M = {}

local defheight = 11

---@return number|nil
function M.find()
    local tab_winids = vim.api.nvim_tabpage_list_wins(0)

    for _, winid in ipairs(tab_winids) do
        if vim.w[winid].type == "drawer" then
            return winid
        end
    end
    return nil
end

---@param focus? boolean
---@param opts? table
---@return number
function M.open(focus, opts)
    if focus == nil then focus = true end
    local defopts = {
        height = defheight,
        showbuftype = "qf",
    }
    opts = vim.tbl_deep_extend("force", defopts,  opts or {})

    -- Check existing
    local drawer_winid = M.find()
    if drawer_winid then
        if focus then
            vim.api.nvim_set_current_win(drawer_winid)
            return drawer_winid
        else
            return drawer_winid
        end
    end

    -- def drawer buf
    local bufid = vim.api.nvim_create_buf(false, false)
    vim.bo[bufid].bufhidden = "wipe"

    -- open drawer
    local winid = vim.api.nvim_open_win(bufid, focus, {
        win = -1, -- ensure to the very bot
        split = 'below',
        height = opts.height
    })
    -- set custom wintype "drawer"
    vim.w[winid].type = "drawer"

    if opts and opts.buftype then
        if opts.buftype == "term" then
            vim.cmd("cclose")
            vim.cmd("terminal")
        elseif opts.buftype == "qf" then
            -- vim.cmd("bw")
            -- vim.cmd("copen")
        end
    end

    vim.bo[0].buflisted = false
    vim.bo[0].bufhidden = "wipe"

    vim.api.nvim_create_autocmd({"WinNew", "WinEnter"}, {
        group = vim.api.nvim_create_augroup('DrawerAutocmdGroup', {clear=true}),
        callback = function(param)
            -- TODO not great
            if vim.w[0].type == "drawer" then
                -- print("Hello")
                -- Next <cmd>bp<cr>
                vim.keymap.set({ "i", "n", "v", "t" }, "<C-Tab>", "<Nop>", {buffer=true})
                -- Prev <cmd>bp<cr>
                vim.keymap.set({ "i", "n", "v", "t" }, "<C-S-Tab>", "<Nop>", {buffer=true})
            end
        end
    })

    return winid
end

function M.close()
    local tab_winids = vim.api.nvim_tabpage_list_wins(0)

    for _, winid in ipairs(tab_winids) do
        if vim.w[winid].type == "drawer" then
            if winid then
                vim.api.nvim_win_close(winid, true)
            end
        end
    end
end

---@param focus? boolean
---@param opts? table
function M.toggle(focus, opts)
    if focus == nil then focus = true end

    if M.find() then
        M.close()
    else
        M.open(focus, opts)
    end
end





--------
return M
