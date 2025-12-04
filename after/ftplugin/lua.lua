
-- lua --

vim.keymap.set("ia", "fn",  "function", {buffer=true})
vim.keymap.set("ia", "loc", "local",    {buffer=true})
vim.keymap.set("ia", "ret", "return",   {buffer=true})
vim.keymap.set("ia", "req", "require",  {buffer=true})

vim.keymap.set("ia", "!=",  "~=",       {buffer=true})


-- custom buf vars
vim.b[0].runcmd = "lua"



