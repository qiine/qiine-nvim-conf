
local M = {}


-- UI
function _G.foldexpr_planv()
    local line = vim.fn.getline(vim.v.lnum)

    if line:match("^-") then return ">1" end

    -- if line:match("^%s*$") then return "0" end
    if line:match("^---") then return "0" end
    if line:match("^──") then return "0" end
    if line:match("^━━") then return "0" end

    if line == "" then return "0" end

    return "="
end




--------
return M


