
-- jrn keymaps


local jrn = require("org.journal")


-- Open journal entry list
vim.keymap.set({"i","n","v","t"}, "<S-Space>j", function() jrn.open() end)
vim.keymap.set({"i","n","v","t"}, "<S-Space>oj", function() jrn.open() end)

-- Create new entry
vim.keymap.set({"i","n","v","t"}, "<F30>", function() jrn.add_entry() end) -- C-F6
vim.keymap.set({"i","n","v","t"}, "<S-Space>ja", function() jrn.add_entry() end)

-- Open last journal entry
vim.keymap.set({"i","n","v","t"}, "<S-Space>jl", function()
    local journal_dir = vim.fn.expand("~/Personal/Org/Journal/")
    local files = vim.fn.readdir(journal_dir)

    if #files == 0 then print("No journal entries found") return end

    table.sort(files, function(a, b) return a > b end) -- sort descending (latest first)

    local latest = files[1]
    local path = journal_dir..latest

    vim.cmd("tabnew "..vim.fn.fnameescape(path))
    vim.bo.bufhidden = "wipe"
end)

