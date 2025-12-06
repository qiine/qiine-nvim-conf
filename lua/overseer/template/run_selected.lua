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
            cwd  = vim.fn.getcwd()
        }
    end,
    condition = {
        filetype = { "lua", "bash", "python" },
    },
}

