
-- Enveloppe --

-- nenveloppe --
-- twinpick --

local M = {}

local matching_pairs = {
    parentheses          = { open = "(", close = ")"   },
    brackets             = { open = "{", close = "}"   },
    squarebrackets       = { open = "[", close = "]"   },
    doublesquarebrackets = { open = "[[", close = "]]" },

    chevrons             = { open = "<", close = ">"   },
}

local function jumptomatch(char)
    if char:match("['\"`]") then
        local curso_spos = vim.api.nvim_win_get_cursor(0)

        vim.cmd("norm! v2i"..char)

        local curso_epos = vim.api.nvim_win_get_cursor(0)

        if curso_spos[1] == curso_epos[1] and curso_spos[2] == curso_epos[2] then
            vim.cmd('norm! o')
        end

        vim.cmd('norm! ')
    else
        -- vim.api.nvim_feedkeys("%", "n", false)
        vim.cmd("norm %")
    end
end

---@param char string
local function find_matchingpair_char(char)
    for _, pair in pairs(matching_pairs) do
        if     char == pair.open  then return pair.close
        elseif char == pair.close then return pair.open
        end
    end

    -- if char:match("[%a%p]") then -- any letters any punctuation
    --     return char
    -- end

    return char
end

---@param char string
---@param charpos table
local function find_matchingpair_pos(char, charpos)
    local matchchar = find_matchingpair_char(char)
    local matchpos

    if not matchchar then return end

    if     char:match("[({%[<]") then
        matchpos = vim.fn.searchpairpos(char, '', matchchar, 'nW')
    elseif char:match("[)}%]>]") then
        matchpos = vim.fn.searchpairpos(matchchar, '', char , 'bW')
    else
        matchpos = vim.fn.searchpos(char, "nW")
    end

    return matchpos
end

---@ param open string
---@ param close string
local function enveloppe_selection(open, close)
    vim.cmd('norm! ') -- trick for correct `<`> pos
    vim.cmd('norm! `>a'..close) -- "a" first, order matter because whe del chars which triggers reorders
    vim.cmd('norm! `<i'..open)
    vim.cmd('norm! `>')
end

function M.setup()
    -- Smart auto pairing
    vim.keymap.set("i", "<", function()
        local crs_pos = vim.fn.getpos(".")
        local nxt_chr_pos = {0, crs_pos[2], crs_pos[3], 0}
        local nxt_chr = vim.fn.getregion(nxt_chr_pos, nxt_chr_pos)[1]

        if vim.bo.buftype == "" and nxt_chr == " " or nxt_chr == ""  then
            return "<>"
        else
            return "<"
        end
    end, {expr=true})


    vim.keymap.set({"i","n","x"}, '<C-S-s>', function()
        vim.api.nvim_echo({{"Surround:"}}, false, {})

        local schar = vim.fn.getcharstr()
        if schar == "" then
            vim.api.nvim_echo({}, false, {})
            return
        end

        local matchchar = find_matchingpair_char(schar)
        if matchchar then
            local m = vim.fn.mode()
            if m == "v" or m == "V" or m == "\22" then
                enveloppe_selection(schar, matchchar)
            else
                vim.cmd("norm! viw")
                enveloppe_selection(schar, matchchar)
            end
        end

        vim.api.nvim_echo({}, false, {})
    end, {noremap=true})


    -- replace pair
    vim.keymap.set('n', "<C-r>", function()
        local baseguicursor = vim.opt.guicursor:get()
        vim.opt_local.guicursor = { "n:hor90", "a:blinkwait900-blinkoff900-blinkon950-Cursor/lCursor" }

        local cchar  = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]
        local inchar = vim.fn.getcharstr()

        if inchar ~= "" then
            if inchar == vim.keycode("<Del>") then
                local curso_startpos  = vim.api.nvim_win_get_cursor(0)
                -- local match = find_matchingpair_pos(cchar, cpos)
                -- vim.api.nvim_buf_set_text(
                --     0,
                --     cpos[1]-1, cpos[2]-1,
                --     cpos[1]-1, cpos[2]+1,
                --     {""}
                -- )
                -- vim.api.nvim_buf_set_text(
                --     0,
                --     match[1]-1, match[2]-1,
                --     match[1]-1, match[2],
                --     {""}
                -- )
                -- vim.api.nvim_win_set_cursor(0, cpos)

                jumptomatch(cchar)
                local curso_newpos = vim.api.nvim_win_get_cursor(0)
                if  curso_startpos[2] > curso_newpos[2] then
                    jumptomatch(cchar)
                    vim.cmd('norm! "_x')
                    vim.api.nvim_win_set_cursor(0, curso_newpos)
                    vim.cmd('norm! "_x')
                    vim.api.nvim_win_set_cursor(0, curso_startpos)
                    vim.cmd('norm! g_')
                else
                    vim.cmd('norm! "_x')
                    vim.api.nvim_win_set_cursor(0, curso_startpos)
                    vim.cmd('norm! "_x')
                end
            else
                local matchchar = find_matchingpair_char(inchar)

                if matchchar then
                    vim.cmd('norm! mz'); jumptomatch(cchar)
                    vim.cmd('norm! r' .. matchchar)
                    vim.cmd('norm! `z')
                    vim.cmd('norm! r' .. inchar)
                end
            end
        end

        vim.opt.guicursor = baseguicursor --reset curso
    end)

end -- setup


--------
return M

