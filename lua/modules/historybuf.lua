
-- historybuf --

local closedbufs = {}
local max_history = 25

-- Track previous buffers
vim.api.nvim_create_autocmd("BufDelete", {
    callback = function(args)
        local bufid = args.buf

        if not vim.api.nvim_buf_is_valid(bufid) then return end
        if not vim.api.nvim_get_option_value("buflisted", {buf=bufid}) then return end

        -- insert unique buf
        for _, v in ipairs(closedbufs) do
            if v == bufid then return end
        end
        local bufname = vim.api.nvim_buf_get_name(args.buf)
        table.insert(closedbufs, bufname)

        -- Keep size limit
        if #closedbufs > max_history then
            table.remove(closedbufs, 1)
        end
    end,
})

vim.api.nvim_create_user_command("OpenPrevBuf", function()
    if #closedbufs == 0 then vim.notify("No previous buffer") return end

    -- Rem last item from the table and return it
    local bufname = table.remove(closedbufs, #closedbufs)
    if not bufname then return end

    vim.cmd("e "..bufname)
end, {})

vim.api.nvim_create_user_command("ShowBufHistory", function()
    for _, bufname in ipairs(closedbufs) do
        vim.notify(bufname ~= "" and bufname or "[No Name]", vim.log.levels.INFO)
    end
end, {})

vim.api.nvim_create_user_command("ClearBufHistory", function()
    closedbufs = {}
    vim.notify("Buffer history cleared", vim.log.levels.INFO)
end, {})
