
-- # fav


local M = {}


M = require("org.fav.favorizer")


M.favdb_path = vim.fn.expand("~/Personal/Org/fav.json")
M.watchlist_path = vim.fn.expand("~/Personal/Org/Watchlist")



-- function M.add_fav()
-- end


function M.watchlist_add()

end

function M.explore_watchlist()
    vim.cmd("tabnew | Oil "..M.watchlist_path)
end



-- Setup
function M.setup()
    require("org.fav.commands")
    require("org.fav.keymaps")
end


--------
return M

