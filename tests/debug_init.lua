--Use this file as a minimal test config
--type nvim -u ~/Personal/dotfiles/User/nvim/tests/debug_init.lua

vim.cmd("aunmenu PopUp")
 vim.cmd [[
  anoremenu PopUp.Inspect     <cmd>Inspect<CR>
]]

vim.opt.number         = true

