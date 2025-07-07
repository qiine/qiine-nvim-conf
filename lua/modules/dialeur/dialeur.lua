
local M = {}

vim.api.nvim_create_augroup('DialeurAutoCmd', { clear = true })

function M.setup()
    vim.api.nvim_create_autocmd('BufEnter', {
        group = 'DialeurAutoCmd',
        pattern = '*.md',
        callback = function()
            --vim.opt_local.number         = false
        end,
    })
end

return M

