
-- # Tabline


-- vim.opt.showtabline = 2  -- always show tabline

-- simple tabline function
-- function _G.PillTabline()
    --     local s = ""
    --     local tabs = vim.api.nvim_list_tabpages()
    --     local current = vim.api.nvim_get_current_tabpage()

    --     for i, tab in ipairs(tabs) do
    --         local is_active = (tab == current)

    --         local hl_left  = is_active and "%#TabLinePillActiveLeft#"   or "%#TabLinePillInactiveLeft#"
    --         local hl_text  = is_active and "%#TabLinePillActiveText#"   or "%#TabLinePillInactiveText#"
    --         local hl_right = is_active and "%#TabLinePillActiveRight#"  or "%#TabLinePillInactiveRight#"

    --         s = s .. hl_left .. ""
    --         s = s .. hl_text .. " " .. i .. " "
    --         s = s .. hl_right .. ""
    --         s = s .. "%#TabLine# "
    --     end

    --     return s
    -- end
    -- vim.opt.tabline = "%!v:lua.PillTabline()"




