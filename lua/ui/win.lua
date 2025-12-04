
local W = {}

function W.split_maximize_toggle()
    local tab_width  = vim.o.columns
    local tab_height = vim.o.lines - vim.o.cmdheight

    local wwidth  = vim.api.nvim_win_get_width(0)
    local wheight = vim.api.nvim_win_get_height(0)

    if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end

    local isfocused = wwidth >= tab_width * 0.8 and wheight >= tab_height * 0.8
    if isfocused then
        vim.cmd("wincmd =") -- equalize all win size
    else
        vim.cmd("wincmd |") -- try Maximise
        vim.cmd("wincmd _")
    end
end


--------
return W
