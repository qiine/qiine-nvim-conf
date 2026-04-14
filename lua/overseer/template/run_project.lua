return {
    name = "run project",
    builder = function()
        local cwd = require("fs").utils.find_proj_rootdir_for_path(vim.fn.getcwd()) or vim.fn.getcwd()
        local ft = vim.bo.filetype

        local cmd = ""
        local args = {}

        -- search build tools
        local valid_buildtool = false

        local function buildfile_exist(buildfile)
            return vim.fn.filereadable(cwd.."/"..buildfile) == 1
        end

        -- set build isntruct
        if buildfile_exist("Makefile") then
            valid_buildtool = true
            cmd = "make"
        elseif buildfile_exist("Cargo.toml") then
            valid_buildtool = true
            cmd = "cargo"
            args = { "run" }
        elseif buildfile_exist("package.json") then
            valid_buildtool = true
            cmd = "npm"
            args = { "run", "dev" }
        elseif buildfile_exist("configuration.nix") then
            valid_buildtool = true
            cmd = "sudo"
            args = { "nixos-rebuild", "switch" }
        end

        if not valid_buildtool then
            -- TODO FEAT first search init/main etc then fallback to currfile

            local taskcmd = {
                ["sh"]   = "bash",
                ["lua"]  = "lua",
                ["rust"] = "rustc",
            }

            local taskcmd_args = {
                ["sh"]   = { vim.fn.expand("%:p") },
                ["lua"]  = { vim.fn.expand("%:p") },
                ["rust"] = { vim.fn.expand("%:p"), "./main"},
            }

            cmd  = taskcmd[ft]
            args = taskcmd_args[ft]
        end

        cmd = cmd or {"echo 'Could not determine how to run project!'"}

        print(cmd.." "..vim.inspect(args))
        return {
            cmd  = cmd,
            args = args,
            cwd  = cwd,
            -- strategy   = {
            --     "jobstart",
            --     wrap_opts = {
            --         width = 158,
            --         height = 35,
            --     },
            -- },
            components = {
                -- {"open_output", direction="dock"},
                {"open_output", direction = "float", focus = false},
                {"on_output_quickfix", set_diagnostics=true, items_only=true, tail=true},
                -- {"on_result_diagnostics_quickfix", open=true},
                {"on_result_diagnostics", remove_on_restart=true},
                {"on_exit_set_status"},
                -- { "on_complete_dispose", require_view = {}, timeout=100 },
            },
        }
    end,
    desc = "Detect and run curr opened project",
}

