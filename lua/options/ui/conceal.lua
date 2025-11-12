-- test
--------------------------------------------------
-- Conceal --
--------------------------------------------------
local tns = vim.api.nvim_create_namespace('testns')

vim.api.nvim_create_user_command("Textext", function()
    vim.api.nvim_buf_clear_namespace(0, tns, 0, -1)

    vim.api.nvim_buf_set_extmark(0, tns, 0, 1, {
        virt_text = {{"hello", "normal"}},
        virt_text_pos = "overlay",
        -- conceal = "abcd",
        -- end_col = 6,
    })
end, {})

local utils = require("utils.utils")

local v    = vim
local vap  = vim.api
local vopt = vim.opt
--------------------------------------------------


vim.opt.conceallevel=0
--  0		Text is shown normally
--	1		Each block of concealed text is replaced with one
--			character.  If the syntax item does not have a custom
--			replacement character defined (see |:syn-cchar|) the
--			character defined in 'listchars' is used.
--			It is highlighted with the "Conceal" highlight group.
--	2		text hidden unless it has a custom replacement character defined (see |:syn-cchar|).
--	3		completely hidden.

vim.opt.concealcursor = "invc" -- stay concealed in insert, normal, vis, cmd

-- Selective conceal activation
vim.api.nvim_create_autocmd('BufEnter', {
    group = 'UserAutoCmds',
    pattern = { "*.lua", "*.cpp", "*.c", "*.h", "*.rs", "*.sh" },
    callback = function()
        vim.opt.conceallevel=2
    end,
})


vim.api.nvim_create_autocmd("FileType", {
    group = "UserAutoCmds",
    pattern = "json",
    callback = function()
        vim.opt.conceallevel=0
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = "UserAutoCmds",
    pattern = {"lua"},
    callback = function()
        vim.cmd[[ syntax match concealfunction /::/ conceal cchar=• ]]
        --vim.cmd[[ syntax match pyNiceOperator "<=" conceal cchar=≤ ]]
        --vim.cmd[[ syntax match pyNiceOperator ">=" conceal cchar=≥ ]]
    end,
})

-- test::do
--⛬ ⫶ ∴ ⋮ ▪ ∷ ⁘ ᠅⸭  ⁖  ᐧ 𝋣
--  ⏺   🞄 ᭼ 𝀝 𝀛  •
--§class



-- Extmarks overlays
vim.g.extoverlays = true

local ns_eo = vim.api.nvim_create_namespace('extoverlay')

local overlays = {
    ["function"] = "󰊕unction",
    ["~="] = "!=",
}

local function apply_overlays(bufnr)
    bufnr = bufnr or 0

    vim.api.nvim_buf_clear_namespace(bufnr, ns_eo, 0, -1)

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    for lnum, line in ipairs(lines) do
        for word, overlay in pairs(overlays) do
            local col = 0
            while true do
                local start, finish = string.find(line, word, col, true)
                if not start then break end

                -- Check if it's a whole word (not part of another word)
                local before = start > 1 and line:sub(start - 1, start - 1) or " "
                local after = finish < #line and line:sub(finish + 1, finish + 1) or " "

                if before:match("[%W_]") and after:match("[%W_]") then
                    vim.api.nvim_buf_set_extmark(bufnr, ns_eo, lnum - 1, start - 1, {
                        end_col = finish,
                        virt_text = { {overlay, "Keyword"} },
                        virt_text_pos = "overlay",
                        hl_mode = "combine"
                    })
                end

                col = finish + 1
            end
        end
    end
end

local function toggle_overlays()
    local bufnr    = vim.api.nvim_get_current_buf()
    local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, ns_eo, 0, -1, {})

    if #extmarks > 0 then
        vim.api.nvim_buf_clear_namespace(bufnr, ns_eo, 0, -1)
        vim.g.overlays = false
        print("extoverlays disabled")
    else
        apply_overlays(bufnr)
        vim.g.overlays = true
        print("extoverlays enabled")
    end
end

vim.api.nvim_create_user_command('ToggleOverlays', toggle_overlays, {})

vim.api.nvim_create_autocmd({"BufEnter", "FileType", "TextChanged", "TextChangedI"}, {
    group = "UserAutoCmds",
    pattern = { "*.lua" },
    callback = function()
        if vim.g.extoverlays == true then
            apply_overlays()
        else
            return
        end
    end
})



-- Extmarks abbrevs
vim.g.extabbrevs = false

local ns_eb = vim.api.nvim_create_namespace('extabbrev')
local abbreviations = {
    ["function"] = "󰊕n",
    ["return"] = "ret",
    ["require"] = "req",
    ["local"] = "loc",
}

local function apply_abbreviations(bufnr)
    bufnr = bufnr or 0

    vim.api.nvim_buf_clear_namespace(bufnr, ns_eb, 0, -1)

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    for lnum, line in ipairs(lines) do
        for word, abbrev in pairs(abbreviations) do
            local col = 0
            while true do
                local start, finish = string.find(line, word, col, true)
                if not start then break end

                -- Check if it's a whole word (not part of another word)
                local before = start > 1 and line:sub(start - 1, start - 1) or " "
                local after = finish < #line and line:sub(finish + 1, finish + 1) or " "

                if before:match("[%W_]") and after:match("[%W_]") then
                    vim.api.nvim_buf_set_extmark(bufnr, ns_eb, lnum - 1, start - 1, {
                        end_col = finish,
                        conceal = "",
                        virt_text = { {abbrev, "Keyword"} },
                        virt_text_pos = "inline", -- overlay
                    })
                end

                col = finish + 1
            end
        end
    end
end

local function toggle_extabbrev()
    local bufnr    = vim.api.nvim_get_current_buf()
    local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, ns_eb, 0, -1, {})

    if #extmarks > 0 then
        vim.api.nvim_buf_clear_namespace(bufnr, ns_eb, 0, -1)
        vim.g.extabbrevs = false
        print("extabbrev disabled")
    else
        apply_abbreviations(bufnr)
        vim.g.extabbrevs = true
        print("extabbrev enabled")
    end
end

vim.api.nvim_create_user_command('ToggleAbbrev', toggle_extabbrev, {})

vim.api.nvim_create_autocmd({"BufEnter", "FileType", "TextChanged", "TextChangedI"}, {
    group = "UserAutoCmds",
    pattern = { "*.lua" },
    callback = function()
        if vim.g.extabbrevs == true then
            apply_abbreviations()
        else
            return
        end
    end
})



