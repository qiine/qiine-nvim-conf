return {
    name = "run nvimlua",
    builder = function()
        local ftmp  = vim.fn.tempname()..".lua"
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        vim.fn.writefile(lines, ftmp)

        return {
            -- name = 'run nvimlua',
            cmd  = { "nvim" },
            args = { "--headless", "-l", ftmp },
            -- args = { "--headless", "--clean", "--noplugin", "-u", "NONE",  },
            -- "-l", ftmp
            --headless --noplugin  }"
            cwd  = vim.fn.getcwd()
        }
    end,
    condition = {
        filetype = { "lua" },
    },
}

