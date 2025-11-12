
--[.csv]
----------------------------------------------------------------------
-- Unbind indent inc
vim.keymap.set({"i","n","v"}, "<Tab>", "", {buffer=true})

-- Unbind indent decrease
vim.keymap.set({"i","n","v"}, "<S-Tab>", "", {buffer=true})

-- Clear line
vim.keymap.set({"i","n","v"}, "<S-BS>", function()
    local crs_pos = vim.api.nvim_win_get_cursor(0)[1]
    vim.cmd("silent! "..crs_pos..[[s/[^|]\+//g]])
    vim.cmd("noh")
end, {buffer=true})

-- Trigger csv
vim.cmd("CsvViewEnable")


local ns = vim.api.nvim_create_namespace("underline_all")

vim.api.nvim_set_hl(0, "UnderlineAll", { underline = true })

vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

local lines = vim.api.nvim_buf_line_count(0)

local function draw_rows_lines()
    for i = 0, lines - 1 do
        -- set extmark from col 0 to end of line with the highlight
        local line_len = #vim.api.nvim_buf_get_lines(0, i, i + 1, false)[1]
        vim.api.nvim_buf_set_extmark(0, ns, i, 0, {
            end_row = i,
            end_col = line_len,
            hl_group = "UnderlineAll",
            hl_mode = "combine",
            hl_eol = true,  -- underline extends to end of line
        })
    end
end

local function toggle_extrow_lines()
    local extmarks = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})

    if #extmarks > 0 then
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    else
        draw_rows_lines()
    end
end

vim.api.nvim_create_user_command("CSVToggleDrawRowlines", function()
    toggle_extrow_lines()
end, {})

vim.api.nvim_create_autocmd(
    {"BufEnter", "FileType", "TextChanged", "TextChangedI"},
    {
        group = 'UserAutoCmds',
        callback = function()
            if vim.bo.filetype == "csv" then
                draw_rows_lines()
            end
        end,
    }
)





