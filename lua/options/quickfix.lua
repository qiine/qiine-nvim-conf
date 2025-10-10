
-- quickfix list --


-- ## [Keymaps]
----------------------------------------------------------------------
vim.keymap.set({"i","n","v","c","t"}, "<F9>", "<Cmd>QuickFixToggle<CR>")

-- add to qf
vim.keymap.set({"i","n","v"}, "<M-q>a", function()
    local fname = vim.fn.expand("%:p")

    local cursopos = vim.api.nvim_win_get_cursor(0)

    vim.fn.setqflist({}, "a", {
        items = {
            {
                filename = fname,
                lnum = cursopos[1],
                col  = cursopos[2],
                text = ""
            }
        }
    })

    print("Curr file added to quickfix")
end)


-- Go to next quickfix entry
vim.keymap.set({"i","n","v"}, "<M-C-PageDown>",  function()
    local qf = vim.fn.getqflist(); if #qf == 0 then return end
    vim.cmd("cnext");
    -- print("Quickfix: " .. vim.fn.line(".") .. "/" .. #qf)
end,
{ silent=false, desc="Next quickfix item" })

-- Go to previous quickfix entry
vim.keymap.set({"i","n","v"}, "<M-C-PageUp>", function()
    local qf = vim.fn.getqflist() if #qf == 0 then return end
    vim.cmd("cprev")
    -- print("Quickfix: " .. vim.fn.line(".") .. "/" .. #qf)
end,
{ silent=false, desc="Previous quickfix item" })



-- ## [cmds]
----------------------------------------------------------------------
vim.api.nvim_create_user_command("QuickFixToggle", function()
    if vim.bo.buftype == "quickfix" then vim.cmd("cclose") return end

    -- Proper cmdline close
    if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end

    vim.cmd("copen")
end, {})

vim.api.nvim_create_user_command("SendSearchToQuickFix", function()
    vim.cmd('vimgrep /'..vim.fn.getreg("/")..'/ %')
    vim.cmd("copen")
end, {})

vim.api.nvim_create_user_command("GatherProjectTodos", function()
    vim.cmd("cclose")
    vim.cmd("cd ".. vim.lsp.buf.list_workspace_folders()[1])

    vim.cmd("vimgrep /".."TODO".."/g `git ls-files`")
    vim.cmd("copen")
end, {})

vim.api.nvim_create_user_command("DiagToQuicFix", function(opts)
    local args = opts.args

    -- severity = { min = vim.diagnostic.severity.WARN },  -- includes WARN and ERROR

    if args == "project" then
        vim.diagnostic.setqflist({ open = true})
    else
        vim.diagnostic.setqflist({ open = true, bufnr = 0 })
    end
end, {
desc = "Send diagnostics to quickfix list",
nargs = "?",
complete = function() return { "buffer" } end,
})

vim.api.nvim_create_user_command("ShowJumpLocList", function()
    local marks = vim.fn.getmarklist()
    vim.list_extend(marks, vim.fn.getmarklist(0)) --

    local qf = {}

    for _, mark in ipairs(marks) do
        local pos = mark.pos
        local bufnr = pos[1]
        local lnum = pos[2]
        local col  = pos[3]
        local name = mark.mark:sub(2)  -- remove leading quote
        local filename = vim.api.nvim_buf_get_name(bufnr)

        if filename ~= "" and lnum > 0 then
            table.insert(qf, {
                bufnr = bufnr,
                lnum = lnum,
                col  = col,
                text = "Mark: ".. name
            })
        end
    end

    vim.fn.setqflist(qf, 'r')  -- replace current quickfix list
    vim.cmd('copen')
end, {})


-- autocmds
vim.api.nvim_create_autocmd('BufWinEnter', {
    group = vim.api.nvim_create_augroup('QuickfixAutoCmd', {clear=true}),
    callback = function()
        if vim.bo.buftype == 'quickfix' then
            vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
            vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})

            vim.api.nvim_win_set_height(0, 9)

            vim.opt_local.signcolumn = "no" --show error/warning/hint and others

            vim.cmd("stopinsert")

            -- Adds curr file to the quickfix list
            vim.keymap.set("n", "a%", function()
                vim.cmd("wincmd w")
                local fname = vim.fn.expand("%:p")
                if fname == "" then print("No filename") return end

                vim.fn.setqflist({}, "a", {
                    items = {
                        {
                            filename = fname,
                            lnum = 1,
                            col  = 1,
                            text = ""
                        }
                    }
                })

                vim.cmd("wincmd w")
                print("File added to quickfix")
            end, {buffer=true, noremap=true})

            -- To next entry
            vim.keymap.set("n", "<Tab>", function()
                vim.cmd("norm! j")
                vim.cmd("cc "..vim.fn.line("."))
                vim.cmd("wincmd w")
            end, {buffer=true, noremap=true})

            -- To prev entry
            vim.keymap.set("n", "<S-Tab>", function()
                vim.cmd("norm! k")
                vim.cmd("cc "..vim.fn.line("."))
                vim.cmd("wincmd w")
            end, {buffer=true, noremap=true})

            -- Open entry, close qf
            vim.keymap.set("n", "<CR>", "<CR>zz", {buffer=true, noremap=true})

            -- Del entrie
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


            -- clear all
            vim.keymap.set("n", "c", function()
                vim.fn.setqflist({}, 'r')
                print("Quicfix cleared")
            end, { buffer = true })
        end
    end,
})
