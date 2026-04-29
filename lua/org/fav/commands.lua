
-- # fav commands


local fav = require("org.fav")


-- debug
vim.api.nvim_create_user_command("FavOpenDB", function()
    vim.cmd("e "..fav.favdb_path)
end, {})

vim.api.nvim_create_user_command("FavExploreWatchlist", fav.explore_watchlist, {})



