
-- # csv


local csvw = require('csvview')


-- ## [utils]
----------------------------------------------------------------------
local bufid = vim.api.nvim_get_current_buf()

-- Simple delimiter detection algorithm
local function detect_delimiter(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 10, false)

    -- Candidates to try
    local candidates = { ",", "\t", ";", "|", ":" }
    local scores = {}

    for _, delim in ipairs(candidates) do
        local field_counts = {}
        local valid_lines = 0

        -- Count fields per line
        for _, line in ipairs(lines) do
            if line ~= "" then
                local count = select(2, line:gsub(vim.pesc(delim), "")) + 1
                table.insert(field_counts, count)
                valid_lines = valid_lines + 1
            end
        end

        if valid_lines < 2 then
            scores[delim] = 0
            goto continue
        end

        -- Calculate consistency score
        -- Prefer delimiters with consistent field counts
        local avg = 0
        for _, count in ipairs(field_counts) do
            avg = avg + count
        end
        avg = avg / valid_lines

        -- Skip if too few fields
        if avg < 2 then
            scores[delim] = 0
            goto continue
        end

        -- Calculate variance
        local variance = 0
        for _, count in ipairs(field_counts) do
            variance = variance + (count - avg) ^ 2
        end
        variance = variance / valid_lines

        -- Score based on consistency (lower variance is better)
        scores[delim] = math.exp(-variance / avg)

        ::continue::
    end

    -- Return best delimiter
    local best_delim = ","
    local best_score = 0
    for delim, score in pairs(scores) do
        if score > best_score then
            best_delim = delim
            best_score = score
        end
    end

    return best_delim, scores
end




-- ## [View]
----------------------------------------------------------------------
local ns = vim.api.nvim_create_namespace("underline_all")


vim.api.nvim_set_hl(0, "UnderlineAll", { underline = true })

vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

local function draw_rows_lines()
    local lines = vim.api.nvim_buf_line_count(0)

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

local function toggle_extmarks_rowlines()
    local extmarks = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})

    if #extmarks > 0 then
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    else
        draw_rows_lines()
    end
end



-- ## [Commands]
---------------------------------------------------------------------
vim.api.nvim_create_user_command("CSVToggleDrawRowlines", function()
    toggle_extmarks_rowlines()
end, {})


vim.api.nvim_create_user_command("CSVAppendColumnEnd", function(opts)
    local val = opts.args ~= "" and opts.args or "New"
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local input = table.concat(lines, "\n")

    local res = vim.system(
        {"awk", "-F|", "BEGIN{OFS=\"|\"} {$(NF+1)=\""..val.."\"}1"},
        {stdin=input, text=true}
    ):wait()

    if res.code == 0 then
        local output_lines = vim.split(res.stdout, "\n", {plain=true})
        vim.api.nvim_buf_set_lines(0, 0, -1, false, output_lines)
    else
        vim.notify("awk failed: " .. res.stderr, vim.log.levels.ERROR)
    end
end, {nargs="?"})



-- ## [AutoCmds]
----------------------------------------------------------------------
vim.api.nvim_create_autocmd({"BufEnter", "FileType", "TextChanged", "TextChangedI"}, {
    group = 'UserAutoCmds',
    callback = function()
        if vim.bo.filetype == "csv" then
            draw_rows_lines()
            vim.cmd("CsvViewEnable delimiter="..detect_delimiter(bufid))
        end
    end,
})



-- ## [Keymaps]
----------------------------------------------------------------------
-- Unbind indent inc
vim.keymap.set({"i","n","v"}, "<Tab>", "", {buffer=true})

-- Unbind indent decrease
vim.keymap.set({"i","n","v"}, "<S-Tab>", "", {buffer=true})

-- Clear line, preserve delims
vim.keymap.set({"i","n","v"}, "<S-BS>", function()
    local crs_pos = vim.api.nvim_win_get_cursor(0)[1]

    local csvw_info = vim.b[bufid].csvview_info

    if not csvw_info then
        vim.notify("csvview not enabled for this buffer", vim.log.levels.WARN); return
    end

    local delim = csvw_info.delimiter.text

    -- local escaped_delim = vim.fn.escape(delim, [[\/^$.*+?()[]{}|]])
    local escaped_delim = vim.fn.escape(delim, [[\]])

    vim.cmd("silent! "..crs_pos.."s/[^"..escaped_delim.."]//g")
    vim.cmd("noh")
end, {buffer=true})


-- Togg render
vim.keymap.set({"i","n","v"}, "<F29>",  function() -- C-F5
    vim.cmd("CsvViewEnable delimiter="..detect_delimiter(bufid))
    draw_rows_lines()
end, {buffer=true})

vim.keymap.set({"i","n","v"}, "<F17>",  function() -- S-F5
    vim.cmd("CsvViewDisable")
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end, {buffer=true})




