
-- # git commands


local api  = require("git")
local U    = require("git.utils")
local term = require("term")


-- ## [Actions]
----------------------------------------------------------------------
vim.api.nvim_create_user_command("GitTrackFile", api.track_curfile, {})

vim.api.nvim_create_user_command("GitStageAll", api.add_all, {})
vim.api.nvim_create_user_command("GitAddAll",   api.add_all, {})
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

vim.api.nvim_create_user_command("GitCommitAll", function()
    local ga_res = vim.system({"git", "add", "-A"}, {cwd=vim.fn.getcwd(), text=true}):wait()
    if ga_res.code ~= 0 then
      vim.notify(ga_res.stderr , vim.log.levels.ERROR); return
    end

    term.open_fwin(nil, {
      title = "Commit all",
      wratio = 0.85, hratio = 0.75,
    }, "bash --norc")

    vim.api.nvim_chan_send(vim.b.terminal_job_id, "git commit".."\n")
end, {})

vim.api.nvim_create_user_command("GitAmend", function(opts)
    term.open_fwin(nil, {
      title = "Commit amend",
      wratio = 0.85, hratio = 0.75,
    }, "bash --norc")

    vim.api.nvim_chan_send(vim.b.terminal_job_id, "git commit --amend".."\n")
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


vim.api.nvim_create_user_command("RemoteRepoBrowse", function(opts)
    local path = opts.args
    local cachepath = vim.fn.stdpath("cache").."/git_remote_browse/"

    -- check existing
    if vim.uv.fs_stat(cachepath..path) then
        vim.cmd("cd "..cachepath..path)
        require("oil").open(cachepath..path)
        return
    end

    local function gen_reponame(text)
        -- trim url
        text = text:gsub("https?://", "")
        text = text:gsub("github", "")
        text = text:gsub("%.com/",  "")

        -- replace remaining separators and punctuation
        text = text:gsub("[:/\\?#@.]", "_")

        local hash = vim.fn.sha256(text):sub(1, 5)

        return text.."_"..hash
    end
    local reponame = gen_reponame(path)

    -- Make repo dir
    local repodir = vim.fs.normalize(cachepath..reponame)

    local mkdir_ok = vim.fn.mkdir(repodir, "p")

    -- clone
    vim.system(
        { "git", "clone", "--depth=10", path, repodir },
        {text=true},
        function(res)
            vim.schedule(function()
                if res.code ~= 0 then
                    vim.notify("Clone failed\n"..res.stderr, vim.log.levels.ERROR) return
                end

                vim.cmd("cd "..repodir)
                require("oil").open(repodir)

                vim.notify("Created: "..reponame, vim.log.levels.INFO)
            end)
        end
    )
end, {
nargs="?",
complete = function()
    local srchpath = vim.fn.stdpath("cache").."/git_remote_browse/"
    local dirs = {}
    for name, type in vim.fs.dir(srchpath) do
        if type == "directory" then table.insert(dirs, name) end
    end

    return dirs
end,
})




-- [vc tools]
----------------------------------------------------------------------
vim.api.nvim_create_user_command("LazyGit", function(opts)
  local bufid = vim.api.nvim_create_buf(false, true)

  local edw_w = vim.o.columns
  local edw_h = vim.o.lines

  local wsize = {
    w = math.floor(edw_w * 1),
    h = math.floor(edw_h * 0.85),
  }

  local wopts = {
    title     = "LazyGit",
    title_pos = "center",
    relative  = "editor",
    width     = wsize.w,
    height    = wsize.h,
    col       = math.floor((edw_w - wsize.w) / 2),
    row       = math.floor((edw_h - wsize.h) / 2) - 1,
    border    = "single",
  }

  vim.api.nvim_open_win(bufid, true, wopts)

  vim.cmd.terminal("lazygit")

  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = 0 })
  vim.api.nvim_set_option_value("buflisted", false, { buf = 0 })
end, {})




