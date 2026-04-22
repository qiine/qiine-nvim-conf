
-- # org plan

-- PLANV
-- leplan
-- planv
-- petitplan
-- todoer
-- qtask
-- speedplan
-- speedtask
-- planist
-- taskel
-- tasklet

local M = {}

M = require("org.plan.api")

M.overview = require("org.plan.overview")



-- ## Setup
----------------------------------------------------------------------
function M.setup()
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



    require("org.plan.keymaps")
    require("org.plan.commands")
end



--------
return M


