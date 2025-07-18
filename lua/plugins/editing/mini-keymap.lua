return
{
    'echasnovski/mini.keymap',
    version = false,
    enabled = true,
    desc = {"Smart keymaps, allow multi-step actions and configurable delay"},

    config = function()
        require('mini.keymap').setup()
        local combo = require('mini.keymap').map_combo

        --local delay_fastline = 275
        --combo("i", '<C-Right><Right>', '<Esc>$i', { delay = delay_fastline })
        --combo({"n", "v"}, '<C-Right><Right>', '$', { delay = delay_fastline })

        --combo("i", '<C-Left><Left>', '<Esc>0i', { delay = delay_fastline })
        --combo({"n", "v"}, '<C-Left><Left>', '0', { delay = delay_fastline })

        --quick insert
        --combo("n", "<Left><Right>", function() vim.cmd("startinsert") end, { delay = 25 })
        --combo("n", "<Right><Left>", function() vim.cmd("startinsert") end, { delay = 25 })

        --quick normal
        combo("i", "<Left><Right>", "<Esc>", { delay = 25 })
        combo("i", "<Right><Left>", "<Esc>", { delay = 25 })

        combo("v", "<Left><Right>", "<Esc>")
        combo("v", "<Right><Left>", "<Esc>")

        --quick normal while fast move
        --only for right side
        combo("i", '<C-Down><C-Right>', '<Esc><Down><Right>', { delay = 300 })
        combo("i", '<C-Right><C-Down>', '<Esc><Down><Right>', { delay = 300 })

        combo("i", '<C-Up><C-Right>', '<Esc><Up><Right>', { delay = 300 })
        combo("i", '<C-Right><C-Up>', '<Esc><Up><Right>', { delay = 300 })

        combo("i", '<C-Right><C-Left>', '<Esc>', { delay = 100 })
        combo("i", '<C-Left><C-Right>', '<Esc>', { delay = 100 })


        --to line select
        combo("i", "<S-Right><S-Left>", "<Esc>V")
        combo("i", "<S-Left><S-Right>", "<Esc>V")

        combo("n", "<S-Right><S-Left>", function() vim.cmd("norm! V") end) --need function otherwise will insert V, weird...
        combo("n", "<S-Left><S-Right>", function() vim.cmd("norm! V") end)

        combo("v", "<S-Right><S-Left>", function() vim.cmd("norm! V") end)
        combo("v", "<S-Left><S-Right>", function() vim.cmd("norm! V") end)
    end
}
