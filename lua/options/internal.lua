-----------
--Setings--
-----------



--## [System]
----------------------------------------------------------------------
vim.opt.encoding = "UTF-8"

vim.opt.clipboard = ''  -- "", "unnamed", "unnamedplus"

-- Allow some type of yanking to go to sys clip
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
        local old_d = vim.fn.getreg('d')
        local old_c = vim.fn.getreg('c')
        local old_b = vim.fn.getreg('b')
        local old_a = vim.fn.getreg('a')
        local new_yank = vim.fn.getreg('+')

        vim.fn.setreg('e', old_d)
        vim.fn.setreg('d', old_c)
        vim.fn.setreg('c', old_b)
        vim.fn.setreg('b', old_a)
        vim.fn.setreg('a', new_yank)
    end,
})



-- ## [Files]
----------------------------------------------------------------------
vim.opt.swapfile = false --no swap files

vim.opt.hidden = true --Allows switching buffers without saving

vim.opt.autoread = false --auto reload file on modif

-- Sets the value of the Vim 'path' option, which controls where Vim looks for
-- files when using commands like :find, gf
vim.opt.path = { ".", "**" }

--make nvim use fd or rg for ex when using find cmd
--vim.opt.findfunc =


--vim.opt.fixeol = false -- don't make unnecessary changes



-- ## [Buffers]
----------------------------------------------------------------------
--vim.opt.hidden = false -- always destroy buffers when closed



-- ## [shada]
----------------------------------------------------------------------
vim.opt.shada = "!,'1000,<50,s10,h"
--The ShaDa file is used to store:
--- The command line history.
--- The search string history.
--- The input-line history.
--- Contents of non-empty registers.
--- Marks for several files.
--- File marks, pointing to locations in files.
--- The buffer list.
--- Global variables.
-- ' → store marks ('a … 'z)
--- Last search/substitute pattern (for 'n' and '&').
-- % → store file marks (cursor positions)
-- h → disable effect of 'hlsearch' on startup
-- < → number of lines of registers
-- s → max item size in KiB












