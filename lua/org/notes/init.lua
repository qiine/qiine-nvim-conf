
-- # org notes


local M = {}

M.notespath = vim.fn.expand("~/Personal/Org/Notes")

function M.create(name)
    local notepath = vim.fs.normalize(M.notespath.."/"..name..".md")

    if vim.uv.fs_stat(notepath) then
        vim.notify("Note with same name already exist! ", vim.log.levels.ERROR) return
    end

    local lines = vim.fn.readfile(vim.fn.stdpath("config").."/snippets/markdown.json")
    local snippets = vim.fn.json_decode(table.concat(lines, "\n"))
    local snippet  = snippets["note template"]
    local body = vim.deepcopy(snippet.body)
    for i, line in ipairs(body) do
        body[i] = line:gsub("%${1:.-}", name)
    end

    vim.fn.writefile(body, notepath) -- create and write note
end

function M.create_intr()
    vim.ui.input({prompt="Note name: ", default="Newnote", completion="file"},
    function(input)
        vim.api.nvim_command("redraw") -- Hide prompt
        if input == nil then vim.notify("Note creation canceled. ", vim.log.levels.INFO) return end

        M.create(input)

        local notepath = vim.fs.normalize(M.notespath.."/"..input..".md")
        vim.cmd("e "..notepath); vim.cmd("norm! 6j"); vim.cmd("startinsert")  -- open it

        vim.notify("Note created: "..notepath, vim.log.levels.INFO)
    end)
end

function M.explore()
    vim.cmd("Oil "..M.notespath)
end

-- Setup
function M.setup()
    require("org.notes.commands")
    require("org.notes.keymaps")
end


--------
return M
