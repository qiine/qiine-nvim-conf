-----------
--Setings--
-----------


--[System]--------------------------------------------------
vim.opt.clipboard = ''  -- "", "unnamed", "unnamedplus"

--allow some type of yanking to go to sys clip
vim.api.nvim_create_autocmd("TextYankPost", {
    group = "UserAutoCmds",
    pattern = "*",
    callback = function()
        if vim.v.register == '"' then
            local op = vim.v.operator
            if op == "y" or op == "d" then
                vim.fn.setreg("+", vim.fn.getreg('"'))
            end
        end
    end,
})

--crude yank history
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        local old_c = vim.fn.getreg('c')
        local old_b = vim.fn.getreg('b')
        local old_a = vim.fn.getreg('a')
        local new_yank = vim.fn.getreg('+')

        vim.fn.setreg('d', old_c)
        vim.fn.setreg('c', old_b)
        vim.fn.setreg('b', old_a)
        vim.fn.setreg('a', new_yank)
    end,
})



--[Files]--------------------------------------------------
vim.opt.swapfile = false --no swap files

vim.opt.hidden = true --Allows switching buffers without saving

vim.opt.autoread = false --auto reload file on modif

--Sets the value of the Vim 'path' option, which controls where Vim looks for
--files when using commands like :find, gf
vim.opt.path = { ".", "**" }

--make nvim use fd or rg for ex when using find cmd
--vim.opt.findfunc =



