
-- # Notes

local fs = require("fs")
local api = require("org.notes")


vim.api.nvim_create_user_command("NoteCreate", function(opts)
    local notespath = api.notespath

    local cwd = vim.fn.getcwd()
    vim.cmd("lcd "..notespath)

    vim.ui.input({prompt="Note name: ", default="Newnote", completion="file"},
    function(notename)
        vim.api.nvim_command("redraw")
        if notename == nil then vim.notify("Note creation canceled. ", vim.log.levels.INFO) return end

        vim.ui.input({prompt="Category: ", default="", completion="dir"},
        function(category)
            vim.cmd("lcd "..cwd)
            if category == nil then vim.notify("Note creation canceled. ", vim.log.levels.INFO) return end

            local notepath = vim.fs.normalize(notespath.."/"..category.."/"..notename..".md")

            if vim.uv.fs_stat(notepath) then
                vim.notify("Note with same name already exist! ", vim.log.levels.ERROR) return
            end

            local lines = vim.fn.readfile(vim.fn.stdpath("config").."/snippets/markdown.json")
            local snippets = vim.fn.json_decode(table.concat(lines, "\n"))
            local snippet  = snippets["note template"]
            local body = vim.deepcopy(snippet.body)
            for i, line in ipairs(body) do
                body[i] = line:gsub("%${1:.-}", notename)
            end

            vim.fn.writefile(body, notepath) -- create note

            vim.cmd("e "..notepath); vim.cmd("startinsert | norm! 6j") -- open it

            vim.notify("Note created: "..notepath, vim.log.levels.INFO)
        end)
    end)
end, {})

vim.api.nvim_create_user_command("NoteCreateCWD", function(opts)
    local notespath = vim.fn.expand("~/Personal/Org/Notes")
    local cwd = vim.fn.getcwd()

    if notespath ~= fs.utils.find_proj_rootdir_for_path(cwd) then
        vim.notify("CWD not in notes dir! ", vim.log.levels.ERROR) return
    end

    vim.ui.input({prompt="New note name: ", default="Newnote", completion="file"},
    function(input)
        vim.api.nvim_command("redraw") -- Hide prompt
        if input == nil then vim.notify("Note creation canceled. ", vim.log.levels.INFO) return end

        local notepath = cwd.."/"..input..".md"

        if vim.uv.fs_stat(notepath) then
            vim.notify("Note with same name already exist! ", vim.log.levels.ERROR) return
        end

        local lines = vim.fn.readfile(vim.fn.stdpath("config").."/snippets/markdown.json")
        local snippets = vim.fn.json_decode(table.concat(lines, "\n"))
        local snippet = snippets["note template"]
        local body = vim.deepcopy(snippet.body)
        for i, line in ipairs(body) do
            body[i] = line:gsub("%${1:.-}", input)
        end

        vim.fn.writefile(body, notepath) -- create note

        vim.cmd("e "..notepath); vim.cmd("startinsert | norm! 6j") -- open it

        print("Note created: "..notepath)
    end)
end, {})




