
-- # time

local M = {}


---Returns current local time as ISO 8601 string
---Example: "2026-06-10T14:30:00+0200"
---@return string
function M.now()
    local date = tostring(os.date("%Y-%m-%dT%H:%M:%S%z"))
    date = date:gsub("([+-]%d%d)(%d%d)$", "%1:%2")

    return date
end



function M.setup()
    require("org.time.commands")
end


--------
return M
