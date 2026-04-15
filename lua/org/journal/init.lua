
-- # Journal


local M = {}


function M.open()
    vim.cmd("tabnew | Oil ~/Personal/Org/Journal/")
end


function M.setup()
    require("org.journal.keymaps")
    require("org.journal.commands")
end


--------
return M


