
-- Arborescence
-- arbores

local M = {}

-- Recursively collect function symbols
local function collect_functions(symbols, results, prefix)
    prefix = prefix or ""
    for _, item in ipairs(symbols) do
        local kind = vim.lsp.protocol.SymbolKind[item.kind] or "?"
        if kind == "Function" or kind == "Method" then
            table.insert(results, prefix .. item.name)
        end
        if item.children then
            collect_functions(item.children, results, prefix .. "  ")
        end
    end
end

function M.get_functions(bufnr)
    bufnr = bufnr or 0
    local clients = vim.lsp.get_clients({bufnr = bufnr})
    if #clients == 0 then return {} end

    local res = vim.lsp.buf_request_sync(bufnr, "textDocument/documentSymbol", {
        textDocument = { uri = vim.uri_from_bufnr(bufnr) }
    }, 1000)

    if not res then return {} end

    local symbols = {}
    for _, client_res in pairs(res) do
        for _, item in ipairs(client_res.result or {}) do
            collect_functions({item}, symbols)
        end
    end

    return symbols
end

function M.arbores_open_win()
    vim.cmd("vsp|enew"); vim.cmd("file! arbores")

    vim.api.nvim_win_set_width(0, 30)

    vim.api.nvim_set_option_value("buftype",  "nofile", {buf=0})
    vim.api.nvim_set_option_value("buflisted", false,   {buf=0})
    vim.api.nvim_set_option_value("bufhidden", "wipe",  {buf=0})
    vim.api.nvim_set_option_value("swapfile",  false,   {buf=0})

    vim.bo.filetype = "arbores"

    vim.opt_local.statuscolumn = ""
    vim.opt_local.signcolumn   = "no"
    vim.opt_local.number       = false
    vim.opt_local.foldcolumn   = "0"

    -- gather symbols
    local curbuf = vim.fn.bufnr("#")
    if curbuf == -1 then return end

    local funcs = M.get_functions(curbuf)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {"Functions"})
    vim.api.nvim_buf_set_lines(0, -1, -1, false, funcs)

    -- create namespace once
    local ns = vim.api.nvim_create_namespace("arbores_ns")

    -- define highlight group (underline style)
    vim.api.nvim_set_hl(0, "ArboresUnderline", { bg = "#bfbfbf", underline = true })

    -- apply to a line (here: line 0)
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_extmark(0, ns, 0, 0, {
        end_col = 1,
        hl_group = "ArboresUnderline",
    })


end


vim.api.nvim_create_user_command("ArboresToggle", function()
    if vim.bo.filetype == "arbores" then vim.cmd("bd") return end

    M.arbores_open_win()
end, {})


-- arbores toggle open
-- vim.keymap.set({"i","n","v","c"}, "<C-S-b>", function()
--     if vim.bo.filetype == "arbores" then vim.cmd("bd") return end

--     M.arbores_open_win()
-- end)



--------
return M

