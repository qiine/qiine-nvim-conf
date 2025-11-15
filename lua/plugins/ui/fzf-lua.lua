return
{
    "ibhagwan/fzf-lua",
    enabled = true,

    dependencies = { "nvim-tree/nvim-web-devicons" },

    config = function()
        local fzfl = require("fzf-lua")
        fzfl.register_ui_select()
        fzfl.setup({
            defaults = {
                actions = {
                    ["esc"] = "",  --restore esc to normal mode (now quit with C-w)
                },
            },
            keymap = {
                builtin = { },
                fzf = { },
            },

            winopts = {
                title_pos    = "center",
                border       = "rounded", --single
                height       = 0.75,      -- window height
                width        = 1,         -- window width
                row          = 0.50,      -- window row position (0=top, 1=bottom)
                col          = 0.51,      -- window col position (0=left, 1=right)
                backdrop     = 100,       --opacity

                preview = {
                    default    = "builtin",
                    border     = "border", -- single, border
                    layout     = "horizontal",
                    horizontal = "right:47%",
                    -- hidden     = "hidden",
                    winopts = {  -- builtin previewer window options
                        signcolumn    = "no",
                        number        = true,
                        cursorline    = true,
                        cursorlineopt = "both",
                        list          = true, --list chars
                        foldcolumn    = "0",
                        foldenable    = false,
                        foldmethod    = "manual",
                        foldlevel     = 99
                    },
                },
            },

            fzf_opts = {
                ["--layout"] = "default",  -- default, reverse (search bar pos)
                -- ["--marker"] = '>',
                -- ["--with-nth"] = "1..",
                -- ["--info"]     = "inline-right",
                -- ["--prompt"] = "", --hide >
                -- ["--highlight-line"] = false,
            },

            files = {
                cmd = [[
                    rg --files --hidden \
                    -g 'Downloads/**' \
                    -g '/**' \
                    -g '!.git/**' \
                    -g '!.npm/**' \
                    -g '!*.log' \
                    -g '!.local/share/**' \
                    -g '!.local/share/Trash/**' \
                    -g '!.local/share/nvim/undo/**' \
                    -g '!cache/**' \
                    -g '!.var/**' \
                    -g '!.cache/**' \
                    -g '!node_modules/**' \
                    -g '!.mozilla/**' \
                    -g '!.cargo/**' \
                    -g '!*/steam-runtime-sniper/**' \
                    -g '!**/containers/**'
                ]],

                -- fd_opts = {"-a"},
                case_mode   = 'smart',
                file_icons  = true,
                color_icons = false,

                actions = {
                    ['default'] = require('fzf-lua.actions').file_edit, --allow open multiples
                    --replace curr buf with pick
                    ---https://github.com/ibhagwan/fzf-lua/discussions/1997
                    ['alt-enter'] = function(sel, o)
                        local entry = require('fzf-lua.path').entry_to_file(sel[1], o, o._uri)
                        local fpath = entry.bufname or entry.uri and entry.uri:match("^%a+://(.*)") or entry.path

                        vim.cmd("file! " ..fpath.."|e!")
                    end,
                }
            },

            grep = {
                -- live_grep and then run a filter on the filenames.
                -- Ex: Find all occurrences of "enable" but only in the "plugins" directory.
                -- ex: > enable --*/plugins/*
                rg_glob = true, -- enable glob parsing
                glob_flag = "--iglob", -- case insensitive globs
                glob_separator = "%s%-%-", -- query separator pattern (lua): ' --'
            },

            buffers = {
                prompt            = 'Buffers❯ ',
                file_icons        = true,         -- show file icons (true|"devicons"|"mini")?
                color_icons       = true,         -- colorize file|git icons
                cwd               = nil,          -- buffers list for a given dir
                cwd_only          = false,        -- buffers for the cwd only
                sort_lastused     = true,         -- sort buffers() by last used
                show_unloaded     = true,         -- show unloaded buffers
                show_unlisted     = true,
            },

            oldfiles = {
                stat_file = true,                --check file still exist
                include_current_session = true,  -- include bufs from current session
            },
        })

        -- Custom previewer
        local builtin = require("fzf-lua.previewer.builtin")

        local function make_preview(preview_lines)
            local M = builtin.base:extend()

            function M:new(o, opts, fzf_win)
                M.super.new(self, o, opts, fzf_win)
                setmetatable(self, M)
                return self
            end

            function M:populate_preview_buf(entry)
                local buf = self:get_tmp_buffer()

                local lines = preview_lines(entry)
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

                self:set_preview_buf(buf)
                self.win:update_preview_title(tostring(entry))
            end

            return M
        end


        -- ## base pickers
        -- Search builtin's
        vim.keymap.set({"i","n","v","c","t"}, "<M-f>i", function()
            if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end
            require("fzf-lua").builtin({})
        end, {silent = true, desc = "Search builtins" })


        -- ### Find files
        -- Find files in currdir
        vim.keymap.set({"i","n","v","c","t"}, "<M-f>c", function()
            if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end
            require("fzf-lua").files({})
        end, {silent=true, desc="Fuzzy find dir in cwd"})

        -- Find files in project
        vim.keymap.set({"i","n","v","c","t"}, "<C-S-f>", function()
            if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end
            require("fzf-lua").files({
                cwd = require("fzf-lua.path").git_root({}),
            })
        end, {silent=true, desc="Fuzzy find file in project" })

        -- find files in home
        vim.keymap.set({"i","n","v","c","t"}, "<M-f>", function()
            if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end
            require("fzf-lua").files({ cwd="~", })
        end, { silent=true, desc="Fuzzy find file in HOME"})

        -- find files in notes
        vim.keymap.set({"i","n","v","c","t"}, "<F49>", function()  --<M-F1>
            if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end
            require("fzf-lua").files({
                prompt = "Notes> ",
                cwd = "~/Personal/Org/Notes/"
            })
        end)

        -- find files for selected in notes
        vim.keymap.set("v", "<F49>", function()   --<M-F1>
            vim.cmd('norm! "zy')
            require("fzf-lua").files({
                prompt = "Notes> ",
                cwd = "~/Personal/Org/Notes/",
                fzf_opts = {
                    ['--query'] = vim.trim(vim.fn.getreg("z"))
                },
            })
        end)


        -- find recent files
        vim.keymap.set({"i","n","v","c","t"}, "<M-f>r", function()
            if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end
            require("fzf-lua").oldfiles()
        end, {silent=true, desc="Fuzzy find recent files"})


        -- ### grep
        -- grep curr dir
        vim.keymap.set({"i","n","v","c","t"}, "<M-f>gc", function()
            if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end
            require("fzf-lua").live_grep({})
        end, { silent = true, desc = "grep curr dir" })

        -- grep in home
        vim.keymap.set({"i","n","v","c","t"}, "<M-f>g", function()
            if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end
            require("fzf-lua").live_grep({ cwd = "~" })
        end, { silent = true, desc = "Live grep in home" })

        -- grep curr project
        vim.keymap.set({"i","n","v","c","t"}, "<C-S-g>", function()
            if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end
            require("fzf-lua").live_grep({
                cwd = require("fzf-lua.path").git_root({}),
            })
        end, { noremap = true, silent = true, desc = "live grep project" })

        -- grep curr project for selected
        vim.keymap.set("v", "<C-S-g>", function()
            require("fzf-lua").grep_visual({
                cwd = require("fzf-lua.path").git_root({})
            })
        end, {noremap=true, silent=true, desc="live grep selected in project"})

        -- grep in notes
        vim.keymap.set({"i","n","c","t"}, "<F13>", function()   --<S-F1>
            if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end
            require("fzf-lua").live_grep({
                prompt = "Notes> ",
                cwd = "~/Personal/Org/Notes/"
            })
        end)
        -- grep in notes for selected
        vim.keymap.set("v", "<F13>", function()   --<S-F1>
            require("fzf-lua").grep_visual({
                cwd = "~/Personal/Org/Notes/"
            })
        end)

        -- Search buffers
        vim.keymap.set({"i","n","v","c","t"}, "<M-f>b", function()
            if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end
            require("fzf-lua").buffers({})
        end, {silent=true, desc="Search buffers"})


        -- Search helptags
        vim.keymap.set({"i","n","v","c","t"}, "<M-f>h", function()
            if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end
            require("fzf-lua").helptags({})
        end, {silent=true, desc="search helptags"})


        -- Search ft and set it
        vim.keymap.set({"i","n","v","c"}, "<M-f>t", function()
            if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end
            require("fzf-lua").filetypes({})
        end, {silent = true, desc = "search and set filetypes" })


        vim.keymap.set({"i","n","v","c"}, "<M-f>m", function()
            if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end
            require("fzf-lua").manpages({})
        end, {silent = true, desc = "search manpages" })



        -- ## Custom pickers
        -- Fuzzy cd from curr dir
        fzfl.fuzzy_cd = function()
            local cwd = vim.fn.getcwd()

            fzfl.fzf_exec("fdfind . --type d", {     --or fd
                prompt = "cd ",
                cwd = cwd,
                actions = {
                    ["default"] = function(selected)
                        if selected then
                            vim.fn.chdir(cwd.."/"..selected[1])

                            vim.cmd("pwd")

                            if vim.bo.filetype == "oil" then
                                require("oil").open(cwd.."/"..selected[1])
                            end
                        end
                    end,
                },
            })
        end

        vim.keymap.set({"i","n","v","t"}, "<M-f>dc", function() fzfl.fuzzy_cd() end,
        {silent=true, desc="Fuzzy cd to directory"})

        -- Fuzzy cd from root
        fzfl.fuzzy_cd_fromroot = function()
            fzfl.fzf_exec("fdfind . --type d", {     --or fd
                prompt = "cd /",
                cwd = "/",
                actions = {
                    ["default"] = function(selected)
                        if selected then
                            vim.fn.chdir("/"..selected[1])
                            vim.cmd("pwd")
                            if vim.bo.filetype == "oil" then
                                require("oil").open("/"..selected[1])
                            end
                        end
                    end,
                },
            })
        end

        vim.keymap.set({"i","n","v","t"}, "<M-f>d", function() fzfl.fuzzy_cd_fromroot() end,
        {silent=true, desc="Fuzzy cd from root dir"})

        -- fav files
        fzfl.favorites = function()
            if vim.fn.mode() == "c" then vim.api.nvim_feedkeys("", "c", false) end

            local favz = require("modules.favorizer")
            local favs, favs_names = favz.get_favs(), favz.get_favs_names()
            fzfl.fzf_exec(favs_names, {
                prompt = "Fav> ",
                -- previewer = "builtin",
                previewer = function()
                    return make_preview(function(entry)
                        return vim.fn.readfile(favs[entry])
                    end)
                end,
                actions = {
                    ["default"] = function(selected)
                        favz.open_fav(selected[1])

                        -- TODO find way to put this inside alpha.nvim instead
                        -- ensure destroy dashboard
                        local alt = vim.fn.bufnr("#")
                        if vim.bo[alt].filetype == "alpha" then
                            vim.cmd("bwipeout " .. alt)
                        end

                    end
                },
            })
        end

        vim.keymap.set({"i","n","v","c","t"}, "<M-f>f", function() fzfl.favorites() end,
        {silent=true, desc="Fuzzy find favorites files"})

        -- Find proj
        -- TODO find project using .git
        -- https://www.reddit.com/r/neovim/comments/1hhiidm/a_few_nice_fzflua_configurations_now_that_lazyvim/
        fzfl.projects = function()
            fzfl.fzf_exec("fdfind '.git$' -t d -d 20 -a -HI | xargs -I{} dirname {}", {
                prompt = "Project> ",
                cwd = "~/Personal/",
                actions = {
                    ["default"] = function(selected)
                        if selected then
                            vim.cmd.cd(selected[1])
                            print("Changed directory to: " .. selected[1])
                        end
                    end
                },
            })
        end

        vim.keymap.set({"i","n","v","t"}, "<M-f>p", function() fzfl.projects() end,
        {silent=true, desc = "Search projects"})

        -- Symbol explorer
        fzfl.snippet = function()
            local snips = require("luasnip").get_snippets(vim.bo.filetype)

            local items = {}
            local lookup = {}
            for _, snip in ipairs(snips) do
                local label = snip.name or snip.trigger
                table.insert(items, label)
                lookup[label] = snip
            end

            fzfl.fzf_exec(items, {
                prompt = "insert snippet> ",
                actions = {
                    ["default"] = function(selected)
                        if selected and #selected > 0 then
                            local label = selected[1]
                            local snip = lookup[label]
                            if snip then
                                require("luasnip").snip_expand(snip)
                            end
                        end
                    end,
                },
            })
        end

        vim.keymap.set({"i","n","v","t"}, "<M-f>s", function() fzfl.snippet() end,
        {silent=true, desc="Fuzzy find snippets"})

        -- API explorer
        fzfl.api = function()
            fzfl.fzf_exec(vim.tbl_keys(vim.api), {
                prompt = "insert api> ",
                actions = {
                    ["default"] = function(selected)
                        if selected and #selected > 0 then
                            vim.api.nvim_put({ "vim.api."..selected[1].."()"}, "c", false, true)
                        end
                    end,
                },
            })
        end

        vim.keymap.set({"i","n","v","t"}, "<M-f>a", function() fzfl.api() end,
        {silent=true, desc="Fuzzy find "})

        -- Dictionary browser
        fzfl.dictionary = function()
            fzfl.fzf_exec("cat /etc/dictionaries-common/words", {
                prompt = "Word> ",
                previewer = function()
                    return make_preview(function(entry)
                        -- local res = vim.system({"dict", "-C", "-s", "exact", "-d", "gcide", entry}, { text = true }):wait()
                        local res = vim.system({"dict", "-C", "-s", "exact", "-d", "wn", entry}, { text = true }):wait()
                        return vim.split(res.stdout, "\n")
                    end)
                end,
                winopts = {
                    height = 0.80, width = 1.00,
                    preview = {
                        layout = "horizontal",
                        horizontal = "right:77%",
                        wrap = true,
                        winopts = {
                            number = false,
                        },
                    },
                },
                actions = {
                    ["default"] = function(selected)
                        local out = table.concat(selected, "")
                        vim.cmd("norm! i"..out)
                    end,
                },
            })
        end

        vim.keymap.set({"i","n","v","t"}, "<M-f>w", function() fzfl.dictionary() end,
        {silent=true, desc = "Search dictionary"})

        vim.api.nvim_create_user_command("OpenDictionary", function()
            vim.cmd("FzfLua dictionary")
        end, {})

        -- env var
        vim.keymap.set("n", "<M-f>e", function()
            local env = vim.fn.environ()
            local entries = {}

            for k, v in pairs(env) do
                table.insert(entries, string.format("%s=%s", k, v))
            end

            fzfl.fzf_exec(entries, {
                prompt = "Env> ",
                actions = {
                    ["default"] = function(selected)
                        if not selected or #selected == 0 then return end
                        local line = selected[1]
                        local var, val = line:match("([^=]+)=(.*)")
                        if var and val then
                            print(string.format("%s=%s", var, val))
                        end
                    end,
                },
            })
        end, { desc = "List environment variables" })


    end --config
}
