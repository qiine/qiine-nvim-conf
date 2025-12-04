return {
    name = 'lua run file',
    builder = function()
        return {
            name = 'lua run file',
            cmd = { 'lua' },
            args = {
                vim.fn.expand '%:p',
            },
        }
    end,
    condition = {
        filetype = { 'lua' },
    },
}

