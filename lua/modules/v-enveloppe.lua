
-- v-enveloppe --

local M = {}

local enveloppe_pairs = {
    singlequotes   = { open = "'", close = "'" },
    doublequotes   = { open = '"', close = '"' },
    backtick       = { open = '`', close = '`' },

    parentheses    = { open = "(", close = ")" },
    brackets       = { open = "{", close = "}" },
    -- squarebrackets = { open = "[", [close] = "]" }, --collide with esc mapping

    pipes          = { open = "|", close = "|" },
    slashes        = { open = "/", close = "/" },

    chevrons       = { open = "<", close = ">" },
    asterisks      = { open = "*", close = "*" },

    -- dashes         = { open = "-", close = "-" }, -- collide with zoomout
    underscore     = { open = "_", close = "_" },
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
        vim.cmd("norm! %")
    end
end

---@ param open string
---@ param close string
local function enveloppe_selection(open, close)
    vim.cmd('norm! ') -- trick for correct `<`> pos
    vim.cmd('norm! `>a'..close) -- "a" first, order matter
    vim.cmd('norm! `<i'..open)
    vim.cmd('norm! `>')
end

---@ param char string
local function find_matchingpair(char)
    for _, pair in pairs(enveloppe_pairs) do
        if     char == pair.open  then return pair.close
        elseif char == pair.close then return pair.open
        end
    end

    if char:match("[%a%p]") then -- any letters any punctuation
        return char
    end

    return nil
end

-- map("n", "<Del>", function()
--     local char = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]

--     local objs = "[(){}'\"%[%]<>]"

--     if not char:match(objs) then
--         vim.cmd('norm! "_x')
--     else
--         local cursopos = vim.api.nvim_win_get_cursor(0)

--         if char:match("[(){}%[%]]") then
--             vim.cmd('norm! "zdi'..char)
--             vim.cmd('norm! "_d%')
--             vim.cmd('norm! "zP')
--         else
--             vim.cmd('norm! "zdi'..char)

--             vim.cmd('norm! "_xh')
--             local otherchar = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]
--             if otherchar:match(objs) then
--                 vim.cmd('norm! "_x')
--                 vim.cmd('norm! "zP')
--             end
--         end

--         vim.api.nvim_win_set_cursor(0, cursopos)
--     end
-- end)

function M.setup()
    -- enveloppe sel
    for _, pair in pairs(enveloppe_pairs) do
        vim.keymap.set({"i","n","x"}, '<C-'..pair.open..'>', function()
            local m = vim.fn.mode()
            if m == "v" or m == "V" or m == "\22" then
                enveloppe_selection(pair.open, pair.close)
            else
                vim.cmd("norm! viw")
                enveloppe_selection(pair.open, pair.close)
            end
        end)
    end


    -- replace pair
    vim.keymap.set('n', "<C-r>", function()
        local baseguicursor = vim.opt.guicursor:get()
        vim.opt_local.guicursor = { "n:hor90", "a:blinkwait900-blinkoff900-blinkon950-Cursor/lCursor" }

        local char = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('.'))[1]
        local inchar = vim.fn.getcharstr()
        local matchchar = find_matchingpair(inchar)

        if matchchar then
            vim.cmd('norm! mz'); jumptomatch(char)
            vim.cmd('norm! r' .. matchchar)
            vim.cmd('norm! `z')
            vim.cmd('norm! r' .. inchar)
        end

        vim.opt.guicursor = baseguicursor --reset curso
    end)


end


--------
return M

