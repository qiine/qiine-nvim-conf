
-- quickfix list --


-- ## [Keymaps]
----------------------------------------------------------------------
-- Toggle
vim.keymap.set({"i","n","v","c","t"}, "<F9>", "<Cmd>QuickfixToggle<CR>")

-- Add text to qf
    vim.keymap.set({"i","n","v"}, "<M-q>a", function()
    vim.fn.setqflist({}, "a", {
        items = {
            {
                bufnr    = 0,
                filename = vim.fn.expand("%:p"),
                lnum     = vim.api.nvim_win_get_cursor(0)[1],
                col      = vim.api.nvim_win_get_cursor(0)[2],
                text     = vim.api.nvim_get_current_line()
            }
        }
    })

    vim.notify("Line added to qf", vim.log.levels.INFO)
end)

-- Add search to qf
vim.keymap.set({"i","n","v"}, "<M-q>as", function()
    vim.cmd('vimgrep /'..vim.fn.getreg("/")..'/ %')
    vim.cmd("copen")
end)

-- Add file file to qf
vim.keymap.set({"i","n","v"}, "<M-q>af", function()
    vim.fn.setqflist({}, "a", {
        items = {
            {
                bufnr    = 0,
                filename = vim.fn.expand("%:p"),
                lnum     = vim.api.nvim_win_get_cursor(0)[1],
                col      = vim.api.nvim_win_get_cursor(0)[2],
                text     = ""
            }
        }
    })

    print("Added to quickfix "..vim.fn.expand("%:p"))
end)

-- Go to next quickfix entry
-- vim.keymap.set({"i","n","v"}, "<M-C-PageDown>",  function()
vim.keymap.set({"i","n","v"}, "<M-C-PageDown>",  function()
    local qf = vim.fn.getqflist();
    if #qf == 0 then return print("Nothing in qf") end

    local ok, err = pcall(vim.cmd, "cnext")
    if not ok then return end
end, {desc="Next quickfix item"})

-- Go to previous quickfix entry
vim.keymap.set({"i","n","v"}, "<M-C-PageUp>", function()
    local qf = vim.fn.getqflist();
    if #qf == 0 then return print("Nothing in qf") end

    local ok, err = pcall(vim.cmd, "cprev")
    if not ok then return end
end, {desc="Prev quickfix item"})

-- Clear qf
vim.keymap.set({"i","n","v","c","t"}, "<M-q>c", function()
    if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end -- esc cmd
    vim.cmd("QuickfixClear")
end, {desc="Clear qf"})



-- ## [cmds]
----------------------------------------------------------------------
vim.api.nvim_create_user_command("QuickfixToggle", function()
    if vim.bo.buftype == "quickfix" then vim.cmd("cclose") return end

    if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end -- esc cmd

    vim.cmd("copen")
end, {})

vim.api.nvim_create_user_command("QuickfixSendSearch", function()
    vim.cmd('vimgrep /'..vim.fn.getreg("/")..'/ %')
    vim.cmd("copen")
end, {})

vim.api.nvim_create_user_command("QuickfixSendProjTODOs", function()
    vim.cmd("cd ".. vim.lsp.buf.list_workspace_folders()[1])

    vim.cmd("vimgrep /".."TODO".."/ `git ls-files`")
    vim.cmd("copen")
end, {})

vim.api.nvim_create_user_command("QuickfixSendDiags", function(opts)
    local args = opts.args

    vim.diagnostic.setqflist({})
    vim.cmd('copen')
end, {
    nargs = "?",
    complete = function() return { "buffer" } end,
    desc = "Send diagnostics to quickfix list",
})

vim.api.nvim_create_user_command("QuickfixSendDiagsErr", function()
    vim.diagnostic.setqflist({open = true, nil, severity=vim.diagnostic.severity.ERROR})
    vim.cmd('copen')
end, {})

vim.api.nvim_create_user_command("ShowJumpLocList", function()
    local marks = vim.fn.getmarklist()
    vim.list_extend(marks, vim.fn.getmarklist(0)) --

    local qf = {}

    for _, mark in ipairs(marks) do
        local pos = mark.pos
        local lnum = pos[2]
        local col  = pos[3]
        local name = mark.mark:sub(2)  -- remove leading quote
        local filename = vim.api.nvim_buf_get_name(0)

        if filename ~= "" and lnum > 0 then
            table.insert(qf, {
                bufnr = 0,
                lnum  = lnum,
                col   = col,
                text  = "Mark: ".. name
            })
        end
    end

    vim.fn.setqflist(qf, 'r')  -- replace current quickfix list
    vim.cmd('copen')
end, {})

vim.api.nvim_create_user_command("QuickfixClear", function()
    vim.fn.setqflist({}, 'r')
    print("Quicfix list cleared")
end, {})


-- ## Autocmds
vim.api.nvim_create_augroup('QuickfixAutoCmd', {clear=true})

vim.api.nvim_create_autocmd('BufWinEnter', {
    group = "QuickfixAutoCmd",
    callback = function()
        if vim.bo.buftype == 'quickfix' then
            local qfbufid = vim.api.nvim_get_current_buf()

            vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
            vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})

            vim.api.nvim_win_set_height(0, 9)
            vim.opt_local.signcolumn = "no"

            vim.cmd("stopinsert")

            -- Nav
            -- To next entry
            vim.keymap.set("n", "<Tab>", function()
                local qfwinid = vim.api.nvim_get_current_win()

                vim.cmd("norm! j")
                vim.cmd("cc " .. vim.fn.line("."))

                local b = vim.api.nvim_get_current_buf()
                vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = b })

                vim.api.nvim_set_current_win(qfwinid)
            end, {buffer=true, noremap=true})

            -- To prev entry
            vim.keymap.set("n", "<S-Tab>", function()
                local qfwinid = vim.api.nvim_get_current_win()

                vim.cmd("norm! k")
                vim.cmd("cc " .. vim.fn.line("."))

                local b = vim.api.nvim_get_current_buf()
                vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = b })

                vim.api.nvim_set_current_win(qfwinid)
            end, {buffer=true, noremap=true})

            -- Select curr entry,
            vim.keymap.set("n", "<CR>", "<CR>zz<Cmd>wincmd w<CR>", {buffer=true, noremap=true})

            -- Open entry and close
            vim.keymap.set({"i","n"}, "<C-CR>", function()
                local ok = pcall(vim.cmd, "norm! \13zz")
                if ok then vim.cmd("cclose") end
            end)

            -- Del entry
            vim.keymap.set("n", "d", function()
                local idx = vim.fn.line('.')
                local qflist = vim.fn.getqflist()
                table.remove(qflist, idx)
                vim.fn.setqflist(qflist, 'r')
            end, {buffer = true})

            vim.keymap.set("n", "<Del>", function()
                local idx = vim.fn.line('.')
                local qflist = vim.fn.getqflist()
                table.remove(qflist, idx)
                vim.fn.setqflist(qflist, 'r')
            end, {buffer = true})


            -- Clear all
            vim.keymap.set("n", "c", function()
                vim.cmd("QuickfixClear")
            end, { buffer = true })
        end
    end,
})
