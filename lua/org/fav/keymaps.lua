
-- # fav keymaps


local fav = require("org.fav")


vim.keymap.set({"i","n","v"}, "<S-M-o>w", fav.explore_watchlist)



