
-- # org notes keymaps


local notes = require("org.notes")


vim.keymap.set({"i","n","v","t"}, "<S-M-o>na", notes.create_intr)
vim.keymap.set({"i","n","v","t"}, "<F25>",     notes.create_intr) -- C-F1

vim.keymap.set({"i","n","v"}, "<S-M-o>n", notes.explore)


-- find files in notes
vim.keymap.set({"i","n","v","c","t"}, "<F1>", function()  --<M-F1>
    if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end

    require("fzf-lua").files({
        winopts = { title = "Find file notes", },
        prompt = "Notes> ",
        cwd = "~/Personal/Org/Notes/"
    })
end)

-- find files for selected in notes
vim.keymap.set("v", "<F49>", function()   --<M-F1>
    vim.cmd('norm! "zy')
    require("fzf-lua").files({
        winopts = { title = "Find file selected", },
        prompt = "Notes> ",
        cwd = "~/Personal/Org/Notes/",
        fzf_opts = {
            ['--query'] = vim.trim(vim.fn.getreg("z"))
        },
    })
end)


-- idea capture S-F6
vim.keymap.set({"i","n","v","t"}, "<F18>", function()
    vim.cmd("tabnew ~/Personal/Org/Notes/idea.md")
    vim.cmd("norm! G0i")
end)



