
-- quickfix list --

vim.api.nvim_create_autocmd('BufWinEnter', {
    group = vim.api.nvim_create_augroup('QuickfixAutoCmd', {clear=true}),
    callback = function()
        if vim.bo.buftype == 'quickfix' then
            vim.api.nvim_set_option_value("buflisted", false,  {buf=0})
            vim.api.nvim_set_option_value("bufhidden", "wipe", {buf=0})

            -- Adds curr file to the quickfix list

            -- vim.keymap.set("n", "<Up>", function()

            -- end, {buffer=true, noremap=true})
            -- vim.keymap.set("n", "<Down>", function()

            -- end, {buffer=true, noremap=true})

            -- Open entry
            vim.keymap.set("n", "<CR>", function()
                vim.cmd("cc "..vim.fn.line("."))
            end, {buffer=true, noremap=true})


            vim.keymap.set("n", "dd", function()
                local idx = vim.fn.line('.')
                local qflist = vim.fn.getqflist()

                table.remove(qflist, idx)
                vim.fn.setqflist(qflist, 'r')
            end, { buffer = true })

            vim.keymap.set("n", "c", function()
                vim.fn.setqflist({}, 'r')
                print("Quicfix cleared")
            end, { buffer = true })

        end
    end,
})
