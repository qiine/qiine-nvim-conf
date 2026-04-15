
-- # Org


local jrn = require("org.journal")


local M = {}


-- Setup
function M.setup()
    require("org.plan") -- need setup?
    require("org.journal").setup()
end



M.jrn = jrn
--------
return M
