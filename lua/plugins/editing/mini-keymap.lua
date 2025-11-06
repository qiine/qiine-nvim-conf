return
{
    'nvim-mini/mini.keymap',
    version = false,
    enabled = true,
    desc = {"Smart keymaps, allow multi-step actions and configurable delay"},

    config = function()
        require('mini.keymap').setup()
        local combo = require('mini.keymap').map_combo

        -- to middle of line
        combo({"i","n","v"}, "<C-Left><C-Right>", "<Cmd>norm! gm<CR>", { delay = 25 })
        combo({"i","n","v"}, "<C-Left><C-Right>", "<Cmd>norm! gm<CR>", { delay = 25 })

        -- to middle of screen
        combo({"i","n","v"}, "<M-Left><M-Right>", "<Cmd>norm! gmM<CR>", { delay = 25 })
        combo({"i","n","v"}, "<M-Left><M-Right>", "<Cmd>norm! gmM<CR>", { delay = 25 })


        -- Quick normal
        combo({"i","n","o","v","c","t"}, "<Left><Right>", "<Esc>", { delay = 25 })
        combo({"i","n","o","v","c","t"}, "<Right><Left>", "<Esc>", { delay = 25 })

        -- Quick normal while fast move
        -- Only for right side
        combo("i", '<C-Down><C-Right>', '<Esc><Down><Right>', { delay = 300 })
        combo("i", '<C-Right><C-Down>', '<Esc><Down><Right>', { delay = 300 })

        combo("i", '<C-Up><C-Right>', '<Esc><Up><Right>', { delay = 300 })
        combo("i", '<C-Right><C-Up>', '<Esc><Up><Right>', { delay = 300 })

        combo("i", '<C-Right><C-Left>', '<Esc>', { delay = 100 })
        combo("i", '<C-Left><C-Right>', '<Esc>', { delay = 100 })


        -- Expand visual selection
        combo({"i","n","v"}, "<S-Left><S-Right>", function()
            vim.cmd('norm! ') -- hack for proper vis pos
            local vst, vsh = vim.api.nvim_buf_get_mark(0, "<"), vim.api.nvim_buf_get_mark(0, ">")

            if math.abs(vst[1] - vsh[1]) > 0 then
                vim.cmd(((vst[2]+1) < (vsh[2]+1)) and "norm!`>^v`<g_" or "norm!`<^v`>g_")
            else
                vim.api.nvim_feedkeys("^vg_", "n", true)
            end
        end)
        combo({"i","n","v"}, "<S-Right><S-Left>", function()
            vim.cmd('norm! ') -- hack for proper vis pos
            local vst, vsh = vim.api.nvim_buf_get_mark(0, "<"), vim.api.nvim_buf_get_mark(0, ">")

            if math.abs(vst[1] - vsh[1]) > 0 then
                vim.cmd(((vst[2]+1) < (vsh[2]+1)) and "norm!`>^v`<g_" or "norm!`<^v`>g_")
            else
                vim.api.nvim_feedkeys("^vg_", "n", true)
            end
        end)


        -- to vis line
        combo("i", "<C-M-Left><C-M-Right>", "<esc>V")
        combo("i", "<C-M-Right><C-M-Left>", "<esc>V")
    end
}

