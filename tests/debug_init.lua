--Use this file as a minimal test config
--type:
--nvim -u ~/Personal/dotfiles/User/nvim/tests/debug_init.lua


vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
        vim.hl.on_yank({higroup = 'IncSearch', timeout = 200})
    end,
})



vim.opt.number = true

