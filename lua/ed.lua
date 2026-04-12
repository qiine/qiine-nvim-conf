
-- # Editing

local M = {}


-- ## [Vis]
---@return table
function M.get_selection_text()
    local vmode = vim.fn.mode():match("[Vv\22]")

    local lines = vim.fn.getregionpos(vim.fn.getpos("v"), vim.fn.getpos("."), {
        type = vmode,
        eol = true,
        exclusive = false,
    })

    local sel_text = {}
    for _, reg in ipairs(lines) do
        local r1, c1, r2, c2 = reg[1][2], reg[1][3], reg[2][2], reg[2][3]
        local buf_text = vim.api.nvim_buf_get_text(0, r1 - 1, c1 - 1, r2 - 1, c2, {})
        vim.list_extend(sel_text, buf_text)
    end
    return sel_text
end

---@param dir string
---@param count number
function M.move_sel(dir, count)
    local mode = vim.fn.mode()

    if mode == 'i' and dir:match("[hl]") then vim.cmd("stopinsert|norm! viw") return end

    if (mode == 'i' and dir:match("[jk]")) or mode == "n" then
        if dir == "h" then vim.cmd('norm! "zx'..count..'h"zP')   return end
        if dir == "l" then vim.cmd('norm! "zx'..count..'l"zP')   return end

        if dir == "k" then vim.cmd('m.-'..(count+1)..'|norm!==') return end
        if dir == "j" then vim.cmd('m.'..count..'|norm!==')      return end
    end

    if mode:match("[vV\22]") then
        vim.cmd('norm! ') -- hack to refresh vis pos
        local vst, vsh = vim.api.nvim_buf_get_mark(0, "<"), vim.api.nvim_buf_get_mark(0, ">")
        vim.cmd('norm! gv')

        -- TODO detect sof and eof
        local atsol = (math.min((vst[2]), (vsh[2])) < 1)

        if (math.abs(vst[1] - vsh[1]) > 0 or mode == "V") and mode ~= "" then -- multilines move
            local defsw = vim.opt.shiftwidth:get()
            local vo = vim.opt_local

            if dir == "h" then vo.shiftwidth = 1; vim.cmd("norm! <gvh"); vo.shiftwidth = defsw; return end
            if dir == "l" then vo.shiftwidth = 1; vim.cmd("norm! >gvl"); vo.shiftwidth = defsw; return end

            if dir == "k" then vim.cmd("'<,'>m '<-"..(count+1).."|norm!gv=gv") return end
            if dir == "j" then vim.cmd("'<,'>m '>+"..count.."|norm!gv=gv")     return end
        end

        -- Single line selection move
        if  atsol and dir == "h" then return end

        local cmd = '"zygv"_x' .. count .. dir .. '"zP' -- "zy avoids polluting reg"
        if mode == "v"  then cmd = cmd.."`[v`]"  end
        if mode == "" then cmd = cmd.."`[`]" end
        vim.cmd("silent keepjumps norm! " .. cmd)
    end
end




--------
return M

