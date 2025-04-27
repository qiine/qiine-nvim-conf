
-- Conceal --


local utils = require("utils.utils")

local v = vim
local vap = vim.api
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

vim.opt.concealcursor="n" --stay concealed in normal mode aswel

--Selective conceal activation
vim.api.nvim_create_autocmd('BufEnter', {
    group = 'UserAutoCmds',
    pattern = { "*.lua", "*.cpp", "*.c", "*.h", "*.rs", "*.sh" },
    callback = function()
        vim.opt.conceallevel=1
    end,
})


vim.api.nvim_create_autocmd("FileType", {
    group = "UserAutoCmds",
    pattern = "json",
    callback = function()

    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = "UserAutoCmds",
    pattern = {"lua"},
    callback = function()
        vim.cmd[[ syntax match concealfunction /::/ conceal cchar=• ]]
        --vim.cmd[[ syntax match pyNiceOperator "<=" conceal cchar=≤ ]]
        --vim.cmd[[ syntax match pyNiceOperator ">=" conceal cchar=≥ ]]
        --vim.cmd[[syntax match ConcealFunction /\<function\>/ conceal cchar=f containedin=ALL]]
    end,
})

--test::do
--⛬ ⫶ ∴ ⋮ ▪ ∷ ⁘ ᠅⸭  ⁖  ᐧ 𝋣
--  ⏺   🞄 ᭼ 𝀝 𝀛  •
--§class


--vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
--    group = 'UserAutoCmds',
--    pattern = '*',
--    callback = function()
--        if vim.bo.buftype ~= "" then return end

--        local buffer_id = vim.api.nvim_get_current_buf()
--        local cp = utils.get_cursor_pos()
--        local cchar = utils.get_char_at_cursorpos()

--        local ns = vim.api.nvim_create_namespace("overlay_notequal")
--        --local mark_id = nil

--        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1) --clear prev mark
--        --find all isntance of ~= in curr buffer and there position
--        --create a makr for ecah
--        vim.api.nvim_buf_set_extmark(buffer_id, ns, cp[1], cp[2], {
--            --id = mark_id,
--            virt_text = { { "!=", "Comment" } },
--            virt_text_pos = 'overlay', --eol overlay inline
            --hl_mode = "combine" -- replace, combine
--        })
--    end,
--})


--overlay ~= with !=  for lua
local ns = vim.api.nvim_create_namespace("overlay_lua")
vim.api.nvim_create_augroup("Overlay_Lua", { clear = true })

vim.api.nvim_create_autocmd({"BufEnter","TextChangedI"}, {
    group = "Overlay_Lua",
    pattern = "*.lua",
    callback = function()
        if vim.bo.buftype ~= "" then return end

        local buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

        -- Overlay ~= on !=
        for row, line in ipairs(lines) do
            local start = 1
            while true do
                local s, e = line:find("~=", start, true)
                if not s then break end

                vim.api.nvim_buf_set_extmark(buf, ns, row - 1, s - 1, {
                    virt_text = { { "!", "Operator" } },
                    virt_text_pos = "overlay",
                    hl_mode = "combine"
                })

                start = e + 1
            end
        end
    end,
})



--Match whole word 'function' and overlay 'fn'
--local fstart = 1
--while true do
--    local fs, fe = line:find("%f[%w]function%f[%W]", fstart)
--    if not fs then break end

--    vim.api.nvim_buf_set_extmark(buf, ns, row - 1, fs - 1, {
    --        virt_text = { { "ƒ", "Keyword" } },
    --        virt_text_pos = "overlay",
    --        hl_mode = "combine"
    --    })

    --    fstart = fe + 1
    --end
