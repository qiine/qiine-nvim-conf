
-- # git commands


local api  = require("git")
local U    = require("git.utils")
local term = require("term")


-- ## [Actions]
----------------------------------------------------------------------
vim.api.nvim_create_user_command("GitTrackFile", api.track_curfile, {})

vim.api.nvim_create_user_command("GitUnstageAll", api.unstage_all, {})

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


vim.api.nvim_create_user_command("GitHunkToggleHighlight", function()
    local hunk_ns = vim.api.nvim_get_namespaces()["githunks"]

    if hunk_ns then
        return vim.api.nvim_buf_clear_namespace(0, hunk_ns, 0, -1)
    end

    vim.cmd("GitHunksHighlight")
end, {})

vim.api.nvim_create_user_command("GitSuggestCommitMsg", function()
    local diff = vim.system({"git", "--no-pager", "diff", "--staged"}, {text=true}):wait()
    if diff.code ~= 0 then print("diff err"); return end
    if diff.stdout == "" then print("No staged changes"); return end

    -- local difflns = vim.split(diff.stdout, "\n", { plain = true })
    local difflns = vim.trim(diff.stdout)
    -- vim.cmd("norm i"..difflns)
    -- vim.api.nvim_put(difflns, "c", true, true)

    local pimsg = vim.system({
      "pi",
      "-ne",
      "--no-session",
      "--tools",
      "read,grep,find",
      "-p",
      "@"..vim.fn.expand("~/.pi/agent/prompts/commit_msg.md"),
    }, {text=true, stdin=difflns}):wait()

    if pimsg.code ~= 0 then print("pi failed: "..pimsg.stderr); return end

    local msg = vim.trim(pimsg.stdout)
    if msg == "" then print("Empty commit message") return end

    -- vim.cmd("norm i"..msg)
    vim.api.nvim_put(vim.split(vim.inspect(msg), "\n", {text=true}), "c", true, true)
end, {})



-- ## [Logs]
----------------------------------------------------------------------
-- ### Repo
vim.api.nvim_create_user_command("GitPrintRoot", function()
    print(vim.fn.systemlist("git rev-parse --show-toplevel")[1])
end, {})

vim.api.nvim_create_user_command("GitHistory", api.log_history, {})

vim.api.nvim_create_user_command("GitPrintRoot", function()
    print(vim.fn.systemlist("git rev-parse --show-toplevel")[1])
end, {})

vim.api.nvim_create_user_command("GitDashboard", function()
    term.open_fwin(nil, {
        title = "Push",
        wratio = 0.75,
        hratio = 0.65,
    })

    vim.api.nvim_chan_send(vim.b.terminal_job_id, "git status\n")
end, {})

vim.api.nvim_create_user_command("GitPrintPorcelainStatus", function(opts)
    api.print_porcelainstatus(opts.fargs)
end, {nargs = "*"})

vim.api.nvim_create_user_command("GitLogFileSplit", function()
    local fp =  vim.fn.expand("%:p")

    vim.cmd("vs | term dash")

    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = 0 })
    vim.api.nvim_set_option_value("buflisted", false,  { buf = 0 })

    vim.api.nvim_chan_send(vim.b.terminal_job_id, "git log HEAD "..fp.."\n")
end, {})




