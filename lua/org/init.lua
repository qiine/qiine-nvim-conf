
-- # Org


-- Goal:
-- As little extension to neovim as possible to wrangle most organisational activities


local M = {}

M.constant = require("org.constant")

M.notes    = require("org.notes")
M.jrn      = require("org.journal")
M.plan     = require("org.plan")



-- Setup
function M.setup(opts)
    require("org.time").setup()
    require("org.notes").setup()
    require("org.journal").setup()
    require("org.plan").setup()
    require("org.fav").setup()
    -- require("org.mail").setup()
end



-------------
return M
