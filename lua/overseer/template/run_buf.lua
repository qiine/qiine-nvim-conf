return {
    name = "run buf",
    builder = function()
        local ft = vim.bo.filetype

        local runcmd = {
            ["sh"]     = "bash",
            ["python"] = "python",
            ["lua"]    = "lua",
        }

        local tmpfextension = {
            ["sh"]     = ".sh",
            ["python"] = ".py",
            ["lua"]    = ".lua",
        }

        -- Write buf to tmp file if no file
        local filepath = ""
        if vim.uv.fs_stat(vim.api.nvim_buf_get_name(0)) then
            filepath = vim.api.nvim_buf_get_name(0)
        else
            local tmpfilepath  = vim.fn.tempname()..tmpfextension[ft]
            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            vim.fn.writefile(lines, tmpfilepath)

            filepath = tmpfilepath
        end

        local cmd = {}
        cmd = { runcmd[ft] }

        local args = {}
        args = { filepath }

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

