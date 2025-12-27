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
            cmd  = { runcmd[buft] },
            args = { ftmp },
            cwd  = vim.fn.getcwd(),
            components = {
                -- {"open_output", direction="dock"},
                {"on_exit_set_status"}
                -- {"on_complete_dispose", timeout=100},
            },

        }
    end,
    condition = {
        filetype = { "lua", "bash", "python" },
    },

}

