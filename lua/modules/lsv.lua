
function ls()
    local ls = {}
    for name, type in vim.fs.dir(searchdir) do
        vim.fn.match(word, [[\k]])
        if type == "file" then table.insert(files, searchdir.."/"..name) end
    end
    return
end

vim.api.nvim_create_user_command("Lsv", function()
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, 0, false, text)
    vim.cmd("r !ls -hAG")
end, {})
