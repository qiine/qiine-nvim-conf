
-- historybuf --

local prevbufs = {}
local max_history = 20

-- Track previous buffers
vim.api.nvim_create_autocmd("BufDelete", {
    callback = function(args)
        local bufid = args.buf
        if not vim.api.nvim_buf_is_valid(bufid) then return end
        if not vim.api.nvim_get_option_value("buflisted", {buf=bufid}) then return end

        -- insert unique buf
        for _, v in ipairs(prevbufs) do
            if v == bufid then return end
        end
        table.insert(prevbufs, bufid)

        -- Keep size limit
        if #prevbufs > max_history then
            table.remove(prevbufs, 1)
        end
    end,
})

vim.api.nvim_create_user_command("OpenPrevBuf", function()
    if #prevbufs == 0 then vim.notify("No previous buffer") return end

    -- Rem last item from the table and return it
    local bufid = table.remove(prevbufs, #prevbufs)
    local bname = vim.api.nvim_buf_get_name(bufid)

    if bufid and vim.api.nvim_buf_is_valid(bufid) then
        vim.cmd("e "..bname)
    end
end, {})

vim.api.nvim_create_user_command("ShowBufHistory", function()
    for _, buf in ipairs(prevbufs) do
        local bufname = vim.api.nvim_buf_get_name(buf)
        vim.notify(bufname ~= "" and bufname or "[No Name]", vim.log.levels.INFO)
    end
end, {})

vim.api.nvim_create_user_command("ClearBufHistory", function()
    prevbufs = {}
    vim.notify("Buffer history cleared", vim.log.levels.INFO)
end, {})
