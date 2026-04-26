
-- # time cmd


local M = {}


-- Insert Now
vim.api.nvim_create_user_command("Now", function()
    local date = tostring(os.date("%Y/%m/%d %H:%M"))
    vim.api.nvim_put({ date }, "c", false, false)
end, {})




--------
return M

