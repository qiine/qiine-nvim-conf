return {
    name = "run project",
    builder = function()
        local cwd = require("fs").utils.find_proj_rootdir()
        local cmd = ""
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
            -- TODO FEAT first search init/main etc then fallback to currfile
            local buft = vim.bo.filetype

            local taskcmd = {
                ["lua"]   = "lua",
                ["bash"]  = "bash",
                ["rust"]  = "rustc "..vim.fn.expand("%:p").."; ./main",
            }

            local taskcmd_args = {
                ["lua"]   = { vim.fn.expand("%:p") },
                ["bash"]  = { vim.fn.expand("%:p") },
            }

            cmd  = taskcmd[buft]
            args = taskcmd_args[buft]
        end

        cmd = cmd or {"echo 'Could not determine how to run project!'"}

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

