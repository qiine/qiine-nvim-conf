
-- buffers --

local M = {}
local U = {}

-- TODO a bit crude
---@param bufid? number
---@return boolean|nil
function U.was_saved_manually(bufid)
    bufid = bufid or vim.api.nvim_get_current_buf()

    local bname = vim.api.nvim_buf_get_name(bufid)

    local stat = vim.uv.fs_stat(bname)

    if not stat then return nil end

    local mtime = os.date("*t", stat.mtime.sec)
    local now   = os.date("*t")

    return mtime.year  == now.year
       and mtime.month == now.month
       and mtime.day   == now.day
end

function M.save_buffers()
    local bufs = vim.api.nvim_list_bufs()

    for _, buf in ipairs(bufs) do
        vim.api.nvim_buf_call(buf, function() -- nvim_buf_call, ensure proper bufs info
            local bname = vim.api.nvim_buf_get_name(buf)

            if
                    vim.bo[buf].buftype == ""
                and vim.bo[buf].modifiable
                and not vim.bo[buf].readonly
                and vim.fn.filereadable(bname) == 1
                and U.was_saved_manually(buf)
            then
                vim.cmd("silent update")
                -- print("autosaved: "..bname)
            end
        end)
    end
end





--------
M.utils = U
return M

