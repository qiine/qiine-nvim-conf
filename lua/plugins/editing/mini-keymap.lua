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

        combo("i", '<C-Down><C-Right><C-Down><C-Right>', '<Esc><Down><Right>', { delay = 50 })
        combo("i", '<C-Down><C-Left><C-Down><C-Left>', '<Esc><Down><Left>', { delay = 50 })
        combo("i", '<C-Up><C-Right><C-Up><C-Right>', '<Esc><Up><Right>', { delay = 50 })
        combo("i", '<C-Up><C-Left><C-Up><C-Left>', '<Esc><Up><Left>', { delay = 50 })


    end
}
