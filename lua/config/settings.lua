


-------------------------------------------------------
-- System --
-------------------------------------------------------
vim.opt.clipboard = 'unnamedplus'

--opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }

------------------------------------------------------------
-- Files --
------------------------------------------------------------
vim.opt.undofile = false -- Save undo history
--vim.opt.undodir = vim.fn.stdpath("state") --"~/.local/state/nvim/undo"

vim.opt.swapfile = false --no swap files

vim.opt.hidden = true --Allows switching buffers without saving

vim.opt.autoread = false --auto reload file on modif

--Sets the value of the Vim 'path' option, which controls where Vim looks for
--files when using commands like :find, gf
vim.opt.path = { ".", "**" }

--make nvim use fd or rg for ex when using find cmd
--vim.opt.findfunc =
