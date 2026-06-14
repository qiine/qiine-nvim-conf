return {
    name = "run buf",
    builder = function()
        local ft = vim.bo.filetype

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

        -- Write buf to tmp file
        local tmpfile  = vim.fn.tempname()..tmpfextension[ft]
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        vim.fn.writefile(lines, tmpfile)

        local cmd = runcmd[ft]
        local args = { tmpfile }

        return {
            cmd  = cmd,
            args = args,
            cwd  = vim.fn.getcwd(),
            components = {
                -- {"open_output", direction="dock"},
                {"open_output", direction = "float", focus = false},
                {"on_exit_set_status"}
                -- {"on_complete_dispose", timeout=100},
            },

        }
    end,
    -- condition = {
    --     filetype = { "lua", "bash", "python" },
    -- },

}

