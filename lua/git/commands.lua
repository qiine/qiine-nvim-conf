
local M = {}

vim.api.nvim_create_user_command("GitRestoreFile", function(opts)
    local rev = opts.args ~= "" and opts.args or "HEAD"

    local fpath = vim.api.nvim_buf_get_name(0)

    -- Check if file exists in rev
    local ls_res = vim.system({"git", "ls-tree", "-r", "--name-only", rev, fpath}, {text=true}):wait()
    if ls_res.code ~= 0 or ls_res.stdout == "" then
        return vim.notify("File does not exist at revision " .. rev, vim.log.levels.ERROR)
    end

    local res = vim.system({"git", "restore", "-s", rev, "--", fpath}, {text=true}):wait()
    if res.code == 0 then
        vim.cmd("edit!")
        vim.notify("File restored to "..rev, vim.log.levels.INFO)
    else
        vim.notify("git restore failed: "..res.stderr, vim.log.levels.ERROR)
    end
end, {nargs="?"})


vim.api.nvim_create_user_command("GitLogFileSplit", function()
    local fp =  vim.fn.expand("%:p")

    vim.cmd("vs | term dash")

    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = 0 })
    vim.api.nvim_set_option_value("buflisted", false,  { buf = 0 })

    vim.api.nvim_chan_send(vim.b.terminal_job_id, "git log HEAD "..fp.."\n")
end, {})


-- ### [Repo admin]
vim.api.nvim_create_user_command("GitPrintRoot", function()
    print(vim.fn.systemlist("git rev-parse --show-toplevel")[1])
end, {})

vim.api.nvim_create_user_command("GitLogFile", function()
    require("neogit").action("log", "log_current", { "--", vim.fn.expand("%:p") })()
end, {})

vim.api.nvim_create_user_command("GitHunksHighlight", function()
    local ns = vim.api.nvim_create_namespace("githunks")

    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

    local fp = vim.fn.expand("%:p")
    local diff = vim.fn.systemlist("git --no-pager diff -U0 HEAD -- " .. fp)

    local added_start, added_count
    local deleted_start, deleted_count

    for _, line in ipairs(diff) do
        -- Hunk header like @@ -12,0 +34,5 @@
        local ds, dc, as, ac = line:match("^@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@")
        if ds and as then
            deleted_start = tonumber(ds)
            deleted_count = tonumber(dc ~= "" and dc or "1")
            added_start = tonumber(as)
            added_count = tonumber(ac ~= "" and ac or "1")

            -- Highlight added lines
            for i = 0, added_count - 1 do
                local lnum = added_start + i - 1
                vim.api.nvim_buf_set_extmark(0, ns, lnum, 0, {
                    hl_group = "DiffAdd",
                    line_hl_group = "DiffAdd",
                    hl_mode = "combine",
                })
            end

            -- For deleted lines: cannot highlight buffer lines; could use signs or virtual text
            -- Example: place virtual text to show deletions
            for i = 0, deleted_count - 1 do
                local lnum = deleted_start + i - 1
                vim.api.nvim_buf_set_extmark(0, ns, lnum, 0, {
                    virt_text = {{"-", "DiffDelete"}},
                    virt_text_pos = "overlay",
                })
            end
        end
    end
end, {})


--------
return M

