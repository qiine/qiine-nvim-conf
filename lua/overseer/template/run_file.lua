return {
    name = 'run file',
    builder = function()
        local fpath = vim.fn.expand('%:p')
        local fdir  = vim.fn.expand('%:p:h')
        local ft    = vim.bo.filetype

        local runcmd = {
            ["lua"]    = "lua",
            ["bash"]   = "bash",
            ["python"] = "python",
        }

        return {
            name = 'run file',
            cmd = { runcmd[ft] },
            args = { fpath },
            cwd = fdir,
        }
    end,
    condition = {
        filetype = { "lua", "bash", "python" },
    },
}

