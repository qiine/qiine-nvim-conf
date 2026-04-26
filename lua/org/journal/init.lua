
-- # Journal


local M = {}


M.jdir = vim.fn.expand("~/Personal/Org/Journal/")


function M.add_entry()
    local date  = os.date("%Y-%m-%d")
    local fname = "Entry_"..date..".md"
    local fpath = M.jdir..fname

    local entryexist = vim.fn.filereadable(fpath) == 1

    if not entryexist then
        vim.fn.writefile({}, fpath) -- create entry
    end

    vim.cmd("tabnew "..fpath)
    vim.cmd("norm! i")
    -- vim.bo.bufhidden = "wipe"

    print(
        entryexist and
        "Opening: "..fname
        or
        "Creating journal entry: "..fname
    )
end

function M.explore()
    vim.cmd("tabnew | Oil "..M.jdir)
end



function M.setup()
    require("org.journal.keymaps")
    require("org.journal.commands")
end


--------
return M


