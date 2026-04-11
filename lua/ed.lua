
-- # Editing

local M = {}

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


--------
return M

