
-- quickfix list --

vim.api.nvim_create_autocmd('BufWinEnter', {
    group = vim.api.nvim_create_augroup('QuickfixAutoCmd', {clear=true}),
    callback = function()
        if vim.bo.buftype == 'quickfix' then
            vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
            vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})

            vim.api.nvim_win_set_height(0, 9)
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
                print("Added to quickfix")
            end, {buffer=true, noremap=true})

            -- To next entry
            vim.keymap.set("n", "<Tab>", function()
                vim.cmd("norm! j")
                vim.cmd("cc "..vim.fn.line("."))
                vim.cmd("wincmd w")
            end, {buffer=true, noremap=true})

            vim.keymap.set("n", "<S-Tab>", function()
                vim.cmd("norm! k")
                vim.cmd("cc "..vim.fn.line("."))
                vim.cmd("wincmd w")
            end, {buffer=true, noremap=true})

            -- Open entry
            vim.keymap.set("n", "<CR>", function()
                local qfl = vim.fn.getqflist()
                if #qfl > 0 then
                    vim.cmd("cc "..vim.fn.line("."))
                else
                    vim.cmd("lne "..vim.fn.line("."))
                end

                vim.cmd("cclose")
                vim.cmd("stopinsert")
            end, {buffer=true, noremap=true})

            -- del entrie
            vim.keymap.set("n", "d", function()
                local idx = vim.fn.line('.')
                local qflist = vim.fn.getqflist()

                table.remove(qflist, idx)
                vim.fn.setqflist(qflist, 'r')
            end, { buffer = true })

            vim.keymap.set("n", "<Del>", function()
                local idx = vim.fn.line('.')
                local qflist = vim.fn.getqflist()

                table.remove(qflist, idx)
                vim.fn.setqflist(qflist, 'r')
            end, { buffer = true })


            -- clear all
            vim.keymap.set("n", "c", function()
                vim.fn.setqflist({}, 'r')
                print("Quicfix cleared")
            end, { buffer = true })
        end
    end,
})
