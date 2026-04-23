
-- # Org

-- Goal:
-- As little extension to neovim as possible to wrangle most organisational activities

----------------------------------------------------------------------
local jrn  = require("org.journal")
local plan = require("org.plan")
----------------------------------------------------------------------


local M = {}


-- Setup
function M.setup()
    require("org.notes").setup()
    require("org.plan").setup()
    require("org.journal").setup()
end




M.jrn  = jrn
M.plan = plan
-------------
return M
