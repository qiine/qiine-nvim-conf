return {
    name = "run buf",
    builder = function()
        local buft = vim.bo.filetype
        local runcmd = {
            ["lua"]    = "lua",
            ["bash"]   = "bash",
            ["python"] = "python",
        }
        local tmpfextension = {
            ["lua"]    = ".lua",
            ["bash"]   = ".sh",
            ["python"] = ".py",
        }
        local ftmp  = vim.fn.tempname()..tmpfextension[buft]
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        vim.fn.writefile(lines, ftmp)

        return {
            name = 'run buf',
            cmd  = { runcmd[buft] },
            args = { ftmp },
            cwd  = vim.fn.getcwd()
        }
    end,
    condition = {
        filetype = { "lua", "bash", "python" },
    },
}

