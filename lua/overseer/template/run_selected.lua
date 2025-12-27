return {
    name = "run selection",
    builder = function()
        local buft = vim.bo.filetype

        local runcmd = {
            ["lua"]    = "lua",
            ["bash"]   = "bash",
            ["python"] = "python",
        }

        local tmpfext = {
            ["lua"]    = ".lua",
            ["bash"]   = ".sh",
            ["python"] = ".py",
        }

        -- send sel to temp filetype
        local lines = vim.fn.getline("'<","'>")
        local ftmp  = vim.fn.tempname()..tmpfext[buft]
        vim.fn.writefile(lines, ftmp)

        if type(lines) == "string" then lines = { lines } end
        local vimapi = false
        for _, l in ipairs(lines) do
            if l:find("vim", 1, true) then
                vimapi = true break
            end
        end

        local args = { ftmp }
        if vimapi then args = { "--headless", "-l", ftmp } end

        return {
            name = 'run selection',
            cmd  = { vimapi and "nvim" or runcmd[buft] },
            args = args,
            cwd  = vim.fn.getcwd(),
            components = {
                -- {"open_output", direction="dock"},
                {"on_exit_set_status"},
            },
        }
    end,
    condition = {
        filetype = { "lua", "bash", "python" },
    },
}

