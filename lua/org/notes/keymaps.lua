
-- # org notes keymaps


local notes = require("org.notes")


vim.keymap.set({"i","n","v","t"}, "<S-M-o>na", notes.create_intr)
vim.keymap.set({"i","n","v","t"}, "<F25>",     notes.create_intr) -- C-F1

vim.keymap.set({"i","n","v"}, "<S-M-o>n", notes.explore)

-- Find files in notes
vim.keymap.set({"i","n","v","c","t"}, "<F1>", function()
    if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end

    require("fzf-lua").files({
        winopts = { title = "Find notes", },
        prompt = "Note> ",
        cwd = notes.notespath,
        actions = {
            ["default"] = function(selected, opts)
                if not selected or #selected == 0 then return end

                vim.cmd("tabnew")
                require("fzf-lua.actions").file_edit(selected, opts)
            end
        },
    })
end)


-- Idea capture  S-F6
vim.keymap.set({"i","n","v","t"}, "<F18>", function()
    vim.cmd("tabnew ~/Personal/Org/Notes/idea.md")
    vim.cmd("norm! G0i")
end)
vim.keymap.set({"i","n","v","t"}, "<S-M-o>i", function()
    vim.cmd("tabnew ~/Personal/Org/Notes/idea.md")
    vim.cmd("norm! G0i")
end)



