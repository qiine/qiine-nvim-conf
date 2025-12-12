return {
    name = "run smart",
    builder = function()
        local fs = require("fs")
        local cwd = fs.utils.find_proj_rdir()

        local cmd
        local args = {}

        -- search build tools
        local valid_buildtool = false
        local function exists(f)
            return vim.fn.filereadable(cwd.."/"..f) == 1
        end

        if exists("Makefile") then
            cmd = "make"; valid_buildtool = true
        elseif exists("Cargo.toml") then
            cmd = "cargo"; valid_buildtool = true
            args = { "run" }
        elseif exists("package.json") then
            cmd = "npm"; valid_buildtool = true
            args = { "run", "dev" }
        end

        if not valid_buildtool then
            local buft = vim.bo.filetype

            local runcmd = {
                ["lua"]   = "lua",
                ["bash"]  = "bash",
            }

            local runargs = {
                ["lua"]   = { vim.fn.expand("%:p") },
                ["bash"]  = {},
            }

            cmd = runcmd[buft]
            args = runargs[buft]
        end

        cmd = cmd or {"echo 'Could not determine how to run project!'"}

        return {
            cmd  = cmd,
            args = args,
            cwd  = cwd,
            components = {
                -- {"open_output", on_result=true}
                {"on_output_quickfix", set_diagnostics=true, items_only=true, tail=true},
                -- {"on_result_diagnostics_quickfix", open=true},
                {"on_result_diagnostics", remove_on_restart=true},
                -- {"on_complete_dispose", timeout=100},
            },
        }
    end,
}

