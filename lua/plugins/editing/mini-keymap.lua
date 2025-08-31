return
{
    'nvim-mini/mini.keymap',
    version = false,
    enabled = true,
    desc = {"Smart keymaps, allow multi-step actions and configurable delay"},

    config = function()
        require('mini.keymap').setup()
        local combo = require('mini.keymap').map_combo

        -- Quick normal
        combo("i", "<Left><Right>", "<Esc>", { delay = 25 })
        combo("i", "<Right><Left>", "<Esc>", { delay = 25 })

        combo("v", "<Left><Right>", "<Esc>")
        combo("v", "<Right><Left>", "<Esc>")

        -- Quick normal while fast move
        -- Only for right side
        combo("i", '<C-Down><C-Right>', '<Esc><Down><Right>', { delay = 300 })
        combo("i", '<C-Right><C-Down>', '<Esc><Down><Right>', { delay = 300 })

        combo("i", '<C-Up><C-Right>', '<Esc><Up><Right>', { delay = 300 })
        combo("i", '<C-Right><C-Up>', '<Esc><Up><Right>', { delay = 300 })

        combo("i", '<C-Right><C-Left>', '<Esc>', { delay = 100 })
        combo("i", '<C-Left><C-Right>', '<Esc>', { delay = 100 })

        -- Select all line
        combo({"i","n","v"}, "<S-Left><S-Right>", "<esc>^v<Cmd>norm!g_<CR>")
        combo({"i","n","v"}, "<S-Right><S-Left>", "<esc>^v<Cmd>norm!g_<CR>")

        combo({"i","n","v"}, "<C-S-Left><C-S-Right>", "<esc>V")
        combo({"i","n","v"}, "<C-S-Right><C-S-Left>", "<esc>V")
    end
}
