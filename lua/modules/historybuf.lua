
-- historybuf --
--track previousely closed buffers for current session

local closedbufs = {}
local max_history = 25

-- Track previous buffers
vim.api.nvim_create_autocmd("BufDelete", {
    callback = function(args)
        local bufid = args.buf
        local bufname = vim.api.nvim_buf_get_name(args.buf)

        if
            not vim.api.nvim_buf_is_valid(bufid)                                or
            not vim.api.nvim_get_option_value("buflisted", {buf=bufid})         or
            vim.api.nvim_get_option_value("buftype", {buf=bufid}) == "terminal" or
            bufname == ""
        then return end

        -- insert unique buf
        for _, cbuf in ipairs(closedbufs) do
            if cbuf == bufid then return end
        end

        table.insert(closedbufs, bufname)

        -- Keep size limit
        if #closedbufs > max_history then
            table.remove(closedbufs, 1)
        end
    end,
})

vim.api.nvim_create_user_command("OpenLastClosedBuf", function()
    if #closedbufs == 0 then vim.notify("No previous buffer") return end

    -- Rem last item from the table and return it
    local bufname = table.remove(closedbufs, #closedbufs)
    if not bufname then return end

    vim.cmd("e "..bufname)
end, {})

vim.api.nvim_create_user_command("PickClosedBuf", function()
    if #closedbufs == 0 then vim.notify("No previous buffer") return end

    vim.ui.select(closedbufs, {prompt = "Pick closed buffer:"},
    function(choice)
        if choice then vim.cmd("e " .. choice) end
    end)
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

