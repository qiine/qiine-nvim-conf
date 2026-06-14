
-- # git keymaps

local git = require("git")
local term = require("term")


local ldvc = "<S-Space>g"


-- ## [Staging]
vim.keymap.set({"i","n"}, ldvc.."s", git.add)

-- Stage edit patch file
vim.keymap.set({"i","n","v"}, ldvc.."se", function()
    local fp = vim.fn.expand("%:p")

    term.open_fwin(nil, {
        title = "Stage patches",
        wratio = 0.85, hratio = 0.75,
    }, "dash")

    vim.api.nvim_chan_send(vim.b.terminal_job_id, "git add -e "..fp.."\n")
end)

vim.keymap.set({"i","n","v"}, ldvc.."sa", git.add_all)

vim.keymap.set({"i","n","v"}, ldvc.."u", git.unstage_file)
vim.keymap.set({"i","n","v"}, ldvc.."U", git.unstage_all)

-- Stage hunk under cursor
vim.keymap.set("v", ldvc.."s", "<Cmd>Gitsigns stage_hunk<CR><cmd>echo 'Hunk staged.'<CR>")


-- diff with head curr file
vim.keymap.set({"i","n","v"}, ldvc.."d", "<Cmd>GitDiffFileRevision<CR>")


-- Log
vim.keymap.set({"i","n","v"}, ldvc.."h", "<Cmd>CodeDiff history --inline<CR>")

-- git log curr file
vim.keymap.set("n", ldvc.."hf", function()
    require("neogit").action("log", "log_current", { "--", vim.fn.expand("%:p") })()
end, {desc = "Neogit Log curr file"})


-- Open LazyGit
vim.keymap.set({"i","n","v"}, ldvc.."z", "<Cmd>LazyGit<cr>")

-- neogit
vim.keymap.set({"i","n","v"}, ldvc,  "<Cmd>Neogit<CR>")
vim.keymap.set({"i","n","v"}, ldvc.."g", "<Cmd>Neogit<CR>")



